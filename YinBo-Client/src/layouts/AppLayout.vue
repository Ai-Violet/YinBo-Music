<template>
  <div class="app-layout">
    <!-- 隐藏的音频播放器 -->
    <audio
      ref="audioRef"
      :src="currentTrack?.playUrl || currentTrack?.url"
      :volume="volume"
      @timeupdate="handleTimeUpdate"
      @loadedmetadata="handleLoadedMetadata"
      @ended="handleEnded"
      @error="handleAudioError"
      @canplay="handleCanPlay"
      style="display: none"
    />

    <!-- 主内容区域 -->
    <main class="main-content">
      <router-view v-slot="{ Component }">
        <transition name="page-fade" mode="out-in">
          <component :is="Component" :key="route.fullPath" />
        </transition>
      </router-view>
    </main>
    
    <!-- 固定播放栏 - 始终显示（除了管理后台） -->
    <Player v-if="!isAdminRoute" ref="playerRef" @show-full-player="openFullPlayer" />
    
    <!-- 全屏播放页面 -->
    <transition name="slide-up">
      <FullPlayer 
        v-if="showFullPlayer" 
        @close="closeFullPlayer"
      />
    </transition>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, provide, watch, defineAsyncComponent } from 'vue'
import { useRoute } from 'vue-router'
import { usePlayerStore } from '../stores/player'
import { storeToRefs } from 'pinia'
import { trackApi } from '../api'

// 异步加载组件避免循环依赖
const Player = defineAsyncComponent(() => import('../components/Player.vue'))
const FullPlayer = defineAsyncComponent(() => import('../views/FullPlayer.vue'))

const route = useRoute()
const playerStore = usePlayerStore()
const { currentTrack, isPlaying, volume, currentTime, duration } = storeToRefs(playerStore)

const audioRef = ref<HTMLAudioElement | null>(null)
const playerRef = ref<any>(null)
const showFullPlayer = ref(false)
const isSeeking = ref(false) // 用户是否正在拖动进度条
const retryTrackId = ref<number | null>(null)

const handleStorageSync = (event: StorageEvent) => {
  if (!event.key || !event.key.startsWith('yinbo_')) return
  playerStore.syncFromStorage()
}

const handleKeydown = (_e: KeyboardEvent) => {
  // Keyboard shortcuts handled in Player.vue
}

// 检查是否是管理后台路由
const isAdminRoute = computed(() => {
  return route.path.startsWith('/admin')
})

// 打开全屏播放器
const openFullPlayer = () => {
  showFullPlayer.value = true
}

// 关闭全屏播放器
const closeFullPlayer = () => {
  showFullPlayer.value = false
}

// 音频事件处理（节流 100ms + 取整，避免进度条抽搐）
let lastTimeUpdate = 0
const handleTimeUpdate = () => {
  if (!audioRef.value) return
  const now = Date.now()
  if (now - lastTimeUpdate < 100) return
  lastTimeUpdate = now
  playerStore.setCurrentTime(Math.round(audioRef.value.currentTime * 10) / 10)
}

const handleLoadedMetadata = () => {
  if (audioRef.value) {
    playerStore.setDuration(audioRef.value.duration)
    // 不再自动恢复进度，避免影响正常播放
  }
}

const handleEnded = async () => {
  // 先向后端打点记录播放（用于真实播放次数与时长统计）
  if (currentTrack.value) {
    try {
      const played = duration.value && duration.value > 0 ? Math.round(duration.value) : 0
      await trackApi.recordPlay(currentTrack.value.id, played)
    } catch (e) {
      console.error('recordPlay error:', e)
    }
  }

  playerStore.handleTrackEnd()
  if (playerStore.playMode === 'single' && playerStore.isPlaying && audioRef.value) {
    audioRef.value.currentTime = 0
    audioRef.value.play().catch(err => console.error('Replay error:', err))
  }
}

const handleAudioError = async (e: Event) => {
  console.error('Audio error:', e)

  // 若是播放链接过期，尝试重新获取一次播放地址
  if (currentTrack.value && retryTrackId.value !== currentTrack.value.id) {
    retryTrackId.value = currentTrack.value.id
    try {
      const res = await trackApi.getDetail(currentTrack.value.id)
      if (res.data.code === 200) {
        const fresh = res.data.data
        if (playerStore.currentTrack && playerStore.currentTrack.id === fresh.id) {
          // 合并最新的播放地址和封面
          playerStore.currentTrack = {
            ...playerStore.currentTrack,
            playUrl: fresh.playUrl,
            coverUrl: fresh.coverUrl
          } as any
        }
        if (audioRef.value) {
          audioRef.value.load()
          audioRef.value.play().catch(err => console.error('Retry play error:', err))
          return
        }
      }
    } catch (err) {
      console.error('Refresh play url error:', err)
    }
  }

  // 回退：若仍失败，跳到下一首
  setTimeout(() => {
    playerStore.playNext()
  }, 500)
}

const handleCanPlay = () => {
  // 音频可以播放时，如果正在播放状态则开始播放
  if (audioRef.value && isPlaying.value) {
    audioRef.value.play().catch(err => {
      console.error('Play error:', err)
    })
  }
}

// 监听播放状态变化
watch(isPlaying, (playing) => {
  if (audioRef.value) {
    if (playing) {
      audioRef.value.play().catch(err => {
        console.error('Play error:', err)
      })
    } else {
      audioRef.value.pause()
    }
  }
})

// 监听当前歌曲变化
watch(currentTrack, (newTrack, oldTrack) => {
  if (audioRef.value && newTrack) {
    // 只有当歌曲ID变化时才重新加载音频
    if (newTrack.id !== oldTrack?.id) {
      audioRef.value.load()
      if (isPlaying.value) {
        audioRef.value.play().catch(err => {
          console.error('Play error:', err)
        })
      }
    }
  }
})

// 监听音量变化
watch(volume, (newVolume) => {
  if (audioRef.value) {
    audioRef.value.volume = newVolume
  }
})

// 监听 currentTime 变化（用于拖动进度条跳转）
// 只有当 isSeeking 为 true 时才允许跳转（用户主动拖动进度条）
watch(currentTime, (newTime) => {
  if (isSeeking.value && audioRef.value && audioRef.value.duration > 0) {
    audioRef.value.currentTime = newTime
    isSeeking.value = false
  }
})

// 提供给子组件的方法：开始拖动进度条
const startSeek = () => {
  isSeeking.value = true
}

// 提供给子组件的方法：执行跳转
const seekTo = (time: number) => {
  if (audioRef.value && audioRef.value.duration > 0) {
    audioRef.value.currentTime = time
  }
}

// 提供打开全屏播放器的方法给子组件
provide('openFullPlayer', openFullPlayer)
provide('startSeek', startSeek)
provide('seekTo', seekTo)

// 监听键盘事件
onMounted(() => {
  // 设置初始音量
  if (audioRef.value) {
    audioRef.value.volume = volume.value
  }

  window.addEventListener('storage', handleStorageSync)
  document.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  // 保存播放进度
  playerStore.saveCurrentProgress()
  window.removeEventListener('storage', handleStorageSync)
  document.removeEventListener('keydown', handleKeydown)
})
</script>

<style scoped>
.app-layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  background: var(--bg-primary);
}

.main-content {
  flex: 1;
  padding-bottom: var(--player-h);
}

/* Page transition */
.page-fade-enter-active {
  transition: opacity var(--dur-normal) var(--ease-out), transform var(--dur-normal) var(--ease-out);
}
.page-fade-leave-active {
  transition: opacity var(--dur-fast);
}
.page-fade-enter-from {
  opacity: 0;
  transform: translateY(6px);
}
.page-fade-leave-to {
  opacity: 0;
}

/* Full player slide */
.slide-up-enter-active,
.slide-up-leave-active {
  transition: all var(--dur-slow) var(--ease-out);
}
.slide-up-enter-from,
.slide-up-leave-to {
  transform: translateY(100%);
  opacity: 0;
}
</style>
