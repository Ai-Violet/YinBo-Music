<template>
  <div class="player-wrapper">
    <!-- 进度条（在播放栏上沿） -->
    <div
      class="progress-border"
      :class="{ dragging: isDraggingProgress }"
      ref="progressBar"
      @mousedown="handleProgressMouseDown"
      @mousemove="handleProgressHover"
      @mouseleave="handleProgressLeave"
    >
      <div class="progress-bg">
        <div class="progress-fill" :style="{ width: progressPercent + '%' }"></div>
      </div>
      <!-- 时间提示 -->
      <div
        class="time-tooltip"
        v-show="isHoveringProgress"
        :style="{ left: hoverPercent + '%' }"
      >
        {{ formatTime(hoverTime) }}
      </div>
    </div>

    <!-- 播放栏主体：中间为一体（模式/上/播/下/音量），两边往两端靠 -->
    <div class="player-container">
      <!-- 左侧：封面+昵称 | 间隔(2x) | 爱心+时长 -->
      <div class="player-left">
        <div class="cover-info-group">
          <div class="cover-wrapper" @click="openFullPlayer">
            <img
              :src="currentTrack?.coverUrl || defaultCover"
              alt="封面"
              class="track-cover"
              :class="{ rotating: isPlaying }"
            />
          </div>
          <div class="track-info" @click="openFullPlayer">
            <p class="track-name-wrap" ref="trackNameWrapRef">
              <span v-if="needNameScroll" class="track-name-inner scroll">
                {{ (currentTrack?.title || '歌曲名') + '    ' }}{{ currentTrack?.title || '歌曲名' }}
              </span>
              <span v-else class="track-name-inner">{{ currentTrack?.title || '歌曲名' }}</span>
            </p>
            <p class="artist-name-wrap" ref="artistNameWrapRef">
              <span v-if="needArtistScroll" class="artist-name-inner scroll">{{ (currentTrack?.artist || '歌手名称') + '    ' }}{{ currentTrack?.artist || '歌手名称' }}</span>
              <span v-else class="artist-name-inner"><ArtistLink :artist-id="currentTrack?.artistId" :artist-name="currentTrack?.artist || '歌手名称'" /></span>
            </p>
          </div>
          <div class="cover-adjacent">
            <el-button circle class="favorite-btn" @click="toggleFavorite">
              <el-icon>
                <svg v-if="isFavorite" viewBox="0 0 1024 1024" width="14" height="14">
                  <path fill="#C20C0C" d="M923 283.6c-13.4-31.1-32.6-58.9-56.9-82.8-24.3-23.8-52.5-42.4-84-55.5-32.5-13.5-66.9-20.3-102.4-20.3-49.3 0-97.4 13.5-139.2 39-10 6.1-19.5 12.8-28.5 20-9-7.2-18.5-13.9-28.5-20-41.8-25.5-89.9-39-139.2-39-35.5 0-69.9 6.8-102.4 20.3-31.4 13-59.7 31.7-84 55.5-24.4 23.9-43.5 51.7-56.9 82.8-13.9 32.3-21 66.6-21 101.9 0 33.3 6.8 68 20.3 103.3 11.3 29.5 27.5 60.1 48.2 91 32.8 48.9 77.9 99.9 133.9 151.6 92.8 85.7 184.3 144.9 188.4 147.6l24.7 16.1c10.9 7.1 25.1 7.1 36 0l24.7-16.1c4.1-2.7 95.5-61.9 188.4-147.6 56-51.7 101.1-102.7 133.9-151.6 20.7-30.9 37-61.5 48.2-91 13.5-35.3 20.3-70 20.3-103.3 0.1-35.3-7-69.6-20.9-101.9z"/>
                </svg>
                <svg v-else viewBox="0 0 1024 1024" width="14" height="14">
                  <path fill="currentColor" d="M923 283.6c-13.4-31.1-32.6-58.9-56.9-82.8-24.3-23.8-52.5-42.4-84-55.5-32.5-13.5-66.9-20.3-102.4-20.3-49.3 0-97.4 13.5-139.2 39-10 6.1-19.5 12.8-28.5 20-9-7.2-18.5-13.9-28.5-20-41.8-25.5-89.9-39-139.2-39-35.5 0-69.9 6.8-102.4 20.3-31.4 13-59.7 31.7-84 55.5-24.4 23.9-43.5 51.7-56.9 82.8-13.9 32.3-21 66.6-21 101.9 0 33.3 6.8 68 20.3 103.3 11.3 29.5 27.5 60.1 48.2 91 32.8 48.9 77.9 99.9 133.9 151.6 92.8 85.7 184.3 144.9 188.4 147.6l24.7 16.1c10.9 7.1 25.1 7.1 36 0l24.7-16.1c4.1-2.7 95.5-61.9 188.4-147.6 56-51.7 101.1-102.7 133.9-151.6 20.7-30.9 37-61.5 48.2-91 13.5-35.3 20.3-70 20.3-103.3 0.1-35.3-7-69.6-20.9-101.9zM512 814.8S156 586.7 156 385.5c0-91.7 70.6-166.1 157.6-166.1 68.2 0 126.4 44.1 148.5 106.1C511.3 261.4 633 176 710.4 176c87 0 157.6 74.4 157.6 166.1 0 201.2-356 429.3-356 429.3z"/>
                </svg>
              </el-icon>
            </el-button>
            <span class="track-time">{{ formatTime(currentTime) }} / {{ formatTime(duration) }}</span>
            <el-button
              circle
              class="control-btn comment-btn"
              :disabled="!currentTrack"
              title="查看评论"
              @click="openCommentDrawer"
            >
              <el-icon>
                <svg viewBox="0 0 24 24" width="18" height="18">
                  <path fill="currentColor" d="M21 6h-2v9H6v2c0 .55.45 1 1 1h11l4 4V7c0-.55-.45-1-1-1zm-4 6V3c0-.55-.45-1-1-1H3c-.55 0-1 .45-1 1v14l4-4h10c.55 0 1-.45 1-1z"/>
                </svg>
              </el-icon>
            </el-button>
            <el-button
              circle
              class="control-btn add-to-playlist-btn"
              :disabled="!currentTrack"
              title="添加到歌单"
              @click="showAddToPlaylistDialogAction"
            >
              <el-icon>
                <svg viewBox="0 0 24 24" width="18" height="18">
                  <path fill="currentColor" d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
                </svg>
              </el-icon>
            </el-button>
          </div>
        </div>
      </div>

      <!-- 中间：播放方式/上一首/暂停/下一首/音量为一体 -->
      <div class="player-center">
        <div class="control-buttons">
          <el-button circle class="control-btn" @click="togglePlayMode" :title="playModeTitle">
            <el-icon><component :is="playModeIcon" /></el-icon>
          </el-button>
          <el-button circle class="control-btn" @click="playPrevious">
            <el-icon><CaretLeft /></el-icon>
          </el-button>
          <el-button circle class="play-btn" @click="togglePlay">
            <el-icon><component :is="isPlaying ? VideoPause : VideoPlay" /></el-icon>
          </el-button>
          <el-button circle class="control-btn" @click="playNext">
            <el-icon><CaretRight /></el-icon>
          </el-button>
          <div class="volume-wrapper" ref="volumeWrapper">
            <el-button circle class="control-btn volume-btn" @click="toggleVolumePopup">
              <el-icon><component :is="volumeIcon" /></el-icon>
            </el-button>
            <div class="volume-popup" v-show="showVolumePopup" @click.stop>
              <div class="volume-info">
                <span class="volume-label">音量</span>
                <span class="volume-percent">{{ volumeValue }}%</span>
              </div>
              <el-slider
                v-model="volumeValue"
                :show-tooltip="false"
                @input="handleVolumeChange"
                class="volume-slider"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- 右侧：往右端靠 -->
      <div class="player-right">
        <div class="sleep-wrapper" ref="sleepWrapper">
          <el-button circle class="control-btn sleep-btn" :class="{ active: playerStore.sleepMode !== 'off' }" @click="toggleSleepPopup" title="睡眠定时">
            <el-icon><component :is="TimerIcon" /></el-icon>
          </el-button>
          <div class="sleep-popup" v-show="showSleepPopup" @click.stop>
            <div class="sleep-title">睡眠定时</div>
            <div
              v-for="opt in sleepOptions"
              :key="opt.value"
              class="sleep-option"
              :class="{ active: playerStore.sleepMode === opt.value }"
              @click="selectSleepMode(opt.value)"
            >
              {{ opt.label }}
            </div>
          </div>
        </div>
        <el-button circle class="control-btn" @click="showPlaylistDrawer = true" title="播放列表">
          <el-icon>
            <svg viewBox="0 0 24 24" width="18" height="18">
              <path fill="currentColor" d="M15 6H3v2h12V6zm0 4H3v2h12v-2zM3 16h8v-2H3v2zM17 6v8.18c-.31-.11-.65-.18-1-.18-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3V8h3V6h-5z"/>
            </svg>
          </el-icon>
        </el-button>
      </div>
    </div>

    <!-- 评论抽屉 -->
    <TrackCommentDrawer v-model="showCommentDrawer" :track="currentTrack" />

    <!-- 添加到歌单弹窗 -->
    <el-dialog
      v-model="showAddToPlaylistDialog"
      title="添加到歌单"
      width="400px"
      :close-on-click-modal="false"
      class="playlist-add-dialog"
    >
      <div v-if="currentTrack" class="add-to-playlist-content">
        <div class="selected-track-info">
          <img :src="currentTrack.coverUrl || defaultCover" alt="封面" class="track-cover-small" />
          <div class="track-text">
            <span class="track-title">{{ currentTrack.title }}</span>
            <span class="track-artist"><ArtistLink :artist-id="currentTrack.artistId" :artist-name="currentTrack.artist || ''" /></span>
          </div>
        </div>
        <div class="playlist-options">
          <div class="playlist-option-header">选择歌单</div>
          <div
            v-for="pl in myPlaylists"
            :key="pl.id"
            class="playlist-option-item"
            @click="addTrackToPlaylist(pl.id)"
          >
            <img :src="pl.coverUrl || defaultCover" alt="封面" class="pl-cover" />
            <div class="pl-info">
              <span class="pl-name">{{ pl.name }}</span>
              <span class="pl-count">{{ pl.trackCount || 0 }} 首</span>
            </div>
          </div>
          <div v-if="myPlaylists.length === 0" class="no-playlists">暂无歌单，请先创建歌单</div>
        </div>
      </div>
    </el-dialog>

    <!-- 播放列表抽屉 -->
    <el-drawer v-model="showPlaylistDrawer" title="播放列表" direction="rtl" size="380px" class="playlist-drawer">
      <div class="playlist-container">
        <div class="playlist-header">
          <span class="playlist-count">共 {{ playerStore.playlist.length }} 首</span>
          <button v-if="playerStore.playlist.length > 0" class="clear-btn" @click="clearPlaylist">
            <svg viewBox="0 0 24 24" width="14" height="14"><path fill="currentColor" d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/></svg>
            清空
          </button>
        </div>
        <div class="playlist-content">
          <template v-if="playlistWithCurrent.length > 0">
            <div
              v-for="(track, index) in playlistWithCurrent"
              :key="track.id"
              class="playlist-item"
              :class="{ active: track.isCurrent }"
              @click="playTrackFromPlaylist(track)"
            >
              <div class="track-index">
                <span v-if="!track.isCurrent">{{ index + 1 }}</span>
                <el-icon v-else class="playing-icon"><VideoPlay /></el-icon>
              </div>
              <div class="track-info">
                <p class="track-name">{{ track.title }}</p>
                <p class="track-artist"><ArtistLink :artist-id="track.artistId" :artist-name="track.artist" /></p>
              </div>
              <div class="track-actions">
                <button class="remove-btn" @click.stop="removeFromPlaylist(index)" title="移除">
                  <svg viewBox="0 0 24 24" width="14" height="14"><path fill="currentColor" d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
                </button>
              </div>
            </div>
          </template>
          <div v-else class="empty-playlist">
            <svg viewBox="0 0 24 24" width="48" height="48" style="opacity:0.2"><path fill="currentColor" d="M15 6H3v2h12V6zm0 4H3v2h12v-2zM3 16h8v-2H3v2zM17 6v8.18c-.31-.11-.65-.18-1-.18-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3V8h3V6h-5z"/></svg>
            <p>播放列表为空</p>
            <p class="empty-hint">播放歌曲后会自动添加到这里</p>
          </div>
        </div>
      </div>
    </el-drawer>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch, nextTick, h, inject } from 'vue'
import { usePlayerStore } from '../stores/player'
import { useUserStore } from '../stores/user'
import TrackCommentDrawer from './TrackCommentDrawer.vue'
import ArtistLink from './ArtistLink.vue'
import { useRouter } from 'vue-router'
import { storeToRefs } from 'pinia'
import { favoriteApi, playlistApi } from '../api'
import { ElMessage } from 'element-plus'
import { DEFAULT_AVATAR_COVER } from '../constants'

const defaultCover = DEFAULT_AVATAR_COVER

// 定义 emit
const emit = defineEmits(['show-full-player'])

// 注入 seek 方法
const startSeek = inject<() => void>('startSeek')
const seekTo = inject<(time: number) => void>('seekTo')
import {
  VideoPlay,
  VideoPause,
  CaretLeft,
  CaretRight,
  Close
} from '@element-plus/icons-vue'

// 音量图标
const VolumeIcon = {
  render() {
    return h('svg', {
      viewBox: '0 0 1024 1024',
      width: '1em',
      height: '1em'
    }, [
      h('path', {
        fill: 'currentColor',
        d: 'M512 320v384l-192-192h-128V320h128l192-192z M661.333333 512a148.8 148.8 0 0 0-34.56-96l60.16-60.586667A234.88 234.88 0 0 1 725.333333 512a234.88 234.88 0 0 1-38.4 156.586667l-60.16-60.586667A148.8 148.8 0 0 0 661.333333 512z M768 512a321.92 321.92 0 0 1-85.333333 213.333333l-59.733334-59.733333A234.88 234.88 0 0 0 682.666667 512a234.88 234.88 0 0 0-59.733334-153.6l59.733334-59.733333A321.92 321.92 0 0 1 768 512z'
      })
    ])
  }
}

// 低音量图标
const VolumeLowIcon = {
  render() {
    return h('svg', {
      viewBox: '0 0 1024 1024',
      width: '1em',
      height: '1em'
    }, [
      h('path', {
        fill: 'currentColor',
        d: 'M512 320v384l-192-192h-128V320h128l192-192z M661.333333 512a148.8 148.8 0 0 0-34.56-96l60.16-60.586667A234.88 234.88 0 0 1 725.333333 512a234.88 234.88 0 0 1-38.4 156.586667l-60.16-60.586667A148.8 148.8 0 0 0 661.333333 512z'
      })
    ])
  }
}

// 顺序播放图标：1-2-3 列表式
const OrderIcon = {
  render() {
    return h('svg', { viewBox: '0 0 24 24', width: '1em', height: '1em' }, [
      h('path', { fill: 'currentColor', d: 'M4 6h2v12H4zm4-2h12v2H8zm0 6h8v2H8zm0 6h12v2H8z' })
    ])
  }
}

// 单曲循环图标：数字 1 + 循环箭头
const SingleLoopIcon = {
  render() {
    return h('svg', { viewBox: '0 0 24 24', width: '1em', height: '1em' }, [
      h('path', { fill: 'currentColor', d: 'M7 7h2v10H7zm8-2c-3.31 0-6 2.69-6 6s2.69 6 6 6 6-2.69 6-6h-2c0 2.21-1.79 4-4 4s-4-1.79-4-4 1.79-4 4-4V3l4 4-4 4V7z' })
    ])
  }
}

// 随机播放图标：交叉箭头
const RandomIcon = {
  render() {
    return h('svg', { viewBox: '0 0 24 24', width: '1em', height: '1em' }, [
      h('path', { fill: 'currentColor', d: 'M10.59 9.17L5.41 4 4 5.41l5.17 5.17 1.42-1.41zM14.5 4l2.04 2.04L4 18.59 5.41 20 17.96 7.46 20 9.5V4h-5.5zm.33 9.41l-1.41 1.41 3.13 3.13L14.5 20H20v-5.5l-2.04 2.04-3.13-3.13z' })
    ])
  }
}

const playerStore = usePlayerStore()
const userStore = useUserStore()
const router = useRouter()
const { currentTrack, isPlaying, volume, currentTime, duration } = storeToRefs(playerStore)

const trackNameWrapRef = ref<HTMLElement | null>(null)
const artistNameWrapRef = ref<HTMLElement | null>(null)
const needNameScroll = ref(false)
const needArtistScroll = ref(false)

const checkTextOverflow = () => {
  nextTick(() => {
    const nameEl = trackNameWrapRef.value
    const artistEl = artistNameWrapRef.value
    if (nameEl) {
      const inner = nameEl.querySelector('.track-name-inner') as HTMLElement
      needNameScroll.value = !!(inner && inner.scrollWidth > nameEl.clientWidth)
    }
    if (artistEl) {
      const inner = artistEl.querySelector('.artist-name-inner') as HTMLElement
      needArtistScroll.value = !!(inner && inner.scrollWidth > artistEl.clientWidth)
    }
  })
}
watch(currentTrack, checkTextOverflow, { immediate: true })

const showCommentDrawer = ref(false)
const showPlaylistDrawer = ref(false)
const showAddToPlaylistDialog = ref(false)
const myPlaylists = ref<any[]>([])

const showAddToPlaylistDialogAction = async () => {
  if (!currentTrack.value) return
  if (!userStore.currentUser) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }
  showAddToPlaylistDialog.value = true
  try {
    const res = await playlistApi.getMyPlaylists(1, 100)
    if (res.data.code === 200) {
      const data = res.data.data
      myPlaylists.value = Array.isArray(data) ? data : (data?.records || [])
    }
  } catch (e) {
    myPlaylists.value = []
  }
}

const addTrackToPlaylist = async (playlistId: number) => {
  if (!currentTrack.value) return
  try {
    await playlistApi.addTrack(playlistId, currentTrack.value.id)
    ElMessage.success('已添加到歌单')
    showAddToPlaylistDialog.value = false
  } catch (e: any) {
    console.error('Add to playlist failed:', e)
    ElMessage.error(e.response?.data?.message || '添加失败')
  }
}
const playlistWithCurrent = computed(() =>
  playerStore.playlist.map(track => ({
    ...track,
    isCurrent: track.id === currentTrack.value?.id
  }))
)
const playTrackFromPlaylist = (track: any) => {
  playerStore.setCurrentTrack(track)
}
const removeFromPlaylist = (index: number) => {
  playerStore.removeFromPlaylist(index)
}
const clearPlaylist = () => {
  playerStore.clearPlaylist()
  ElMessage.success('播放列表已清空')
}
const showVolumePopup = ref(false)
const volumeWrapper = ref<HTMLElement | null>(null)
const showSleepPopup = ref(false)
const sleepWrapper = ref<HTMLElement | null>(null)

const sleepOptions = [
  { value: '15', label: '15 分钟后' },
  { value: '30', label: '30 分钟后' },
  { value: '60', label: '1 小时后' },
  { value: 'end', label: '播完当前歌曲' },
  { value: 'off', label: '关闭定时' }
] as const

const TimerIcon = {
  render() {
    return h('svg', { viewBox: '0 0 24 24', width: '1em', height: '1em' }, [
      h('path', {
        fill: 'currentColor',
        d: 'M15 1H9v2h6V1zm-4 13h2V8h-2v6zm8.03-6.61l1.42-1.42c-.43-.51-.9-.99-1.41-1.41l-1.42 1.42A8.962 8.962 0 0012 4c-4.97 0-9 4.03-9 9s4.03 9 9 9 9-4.03 9-9c0-2.12-.74-4.07-1.97-5.61zM12 20c-3.87 0-7-3.13-7-7s3.13-7 7-7 7 3.13 7 7-3.13 7-7 7z'
      })
    ])
  }
}

const toggleSleepPopup = () => {
  showSleepPopup.value = !showSleepPopup.value
}

const selectSleepMode = (mode: 'off' | '15' | '30' | '60' | 'end') => {
  playerStore.setSleepTimer(mode)
  showSleepPopup.value = false
  if (mode === 'off') {
    ElMessage.success('已关闭睡眠定时')
  } else if (mode === 'end') {
    ElMessage.success('将在当前歌曲播放完后停止')
  } else {
    ElMessage.success(`将在 ${mode} 分钟后停止播放`)
  }
}

// 音量值 - 从 playerStore 同步
const volumeValue = computed({
  get: () => Math.round(volume.value * 100),
  set: (val: number) => playerStore.setVolume(val / 100)
})

// 收藏状态 - 从 userStore 同步
const isFavorite = computed(() => {
  if (!currentTrack.value || !userStore.currentUser) return false
  return userStore.favorites.includes(currentTrack.value.id)
})

// 播放模式 - 从 playerStore 同步
const playMode = computed(() => {
  const mode = playerStore.playMode
  if (mode === 'order') return 0
  if (mode === 'single') return 1
  if (mode === 'random') return 2
  return 0
})

const playModeIcon = computed(() => {
  switch (playMode.value) {
    case 0:
      return OrderIcon
    case 1:
      return SingleLoopIcon
    case 2:
      return RandomIcon
    default:
      return OrderIcon
  }
})

const playModeTitle = computed(() => {
  switch (playMode.value) {
    case 0:
      return '顺序播放'
    case 1:
      return '单曲循环'
    case 2:
      return '随机播放'
    default:
      return '顺序播放'
  }
})


// 静音图标
const MuteIcon = {
  render() {
    return h('svg', {
      viewBox: '0 0 24 24',
      width: '1em',
      height: '1em'
    }, [
      h('path', {
        fill: 'currentColor',
        d: 'M5.889 16H2a1 1 0 01-1-1V9a1 1 0 011-1h3.889l5.294-4.332a.5.5 0 01.817.387v15.89a.5.5 0 01-.817.387L5.89 16z'
      }),
      h('path', {
        fill: 'currentColor',
        d: 'M17 11l4-4m0 0l4 4m-4-4v8',
        stroke: 'currentColor',
        'stroke-width': '2',
        transform: 'rotate(45 21 11)'
      })
    ])
  }
}

const volumeIcon = computed(() => {
  if (volumeValue.value === 0) {
    return MuteIcon
  } else if (volumeValue.value < 50) {
    return VolumeLowIcon
  } else {
    return VolumeIcon
  }
})

// 进度条相关
const progressPercent = computed(() => {
  if (duration.value === 0) return 0
  return (currentTime.value / duration.value) * 100
})

const isHoveringProgress = ref(false)
const hoverPercent = ref(0)
const hoverTime = ref(0)
const isDraggingProgress = ref(false)
const progressBar = ref<HTMLElement | null>(null)

const formatTime = (seconds: number): string => {
  const mins = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

const handleProgressHover = (e: MouseEvent) => {
  if (!progressBar.value) return
  const rect = progressBar.value.getBoundingClientRect()
  const x = e.clientX - rect.left
  hoverPercent.value = (x / rect.width) * 100
  hoverTime.value = (hoverPercent.value / 100) * duration.value
  isHoveringProgress.value = true
}

const handleProgressLeave = () => {
  if (!isDraggingProgress.value) {
    isHoveringProgress.value = false
  }
}

const handleProgressMouseDown = (e: MouseEvent) => {
  isDraggingProgress.value = true
  handleSeek(e)

  const handleMouseMove = (e: MouseEvent) => {
    handleSeek(e)
  }

  const handleMouseUp = () => {
    isDraggingProgress.value = false
    isHoveringProgress.value = false
    document.removeEventListener('mousemove', handleMouseMove)
    document.removeEventListener('mouseup', handleMouseUp)
  }

  document.addEventListener('mousemove', handleMouseMove)
  document.addEventListener('mouseup', handleMouseUp)
}

const handleSeek = (e: MouseEvent) => {
  if (!progressBar.value) return
  const rect = progressBar.value.getBoundingClientRect()
  const x = e.clientX - rect.left
  const percent = Math.max(0, Math.min(1, x / rect.width))
  const newTime = percent * duration.value
  
  // 使用 inject 的 seekTo 方法来跳转进度
  if (seekTo) {
    seekTo(newTime)
  }
  // 更新 store 中的 currentTime
  playerStore.setCurrentTime(newTime)
}

const togglePlay = () => {
  playerStore.togglePlay()
}

const playNext = () => {
  playerStore.playNext()
}

const playPrevious = () => {
  playerStore.playPrevious()
}

// 打开全屏播放器
const openFullPlayer = () => {
  emit('show-full-player')
}

const toggleFavorite = async () => {
  if (!currentTrack.value) return
  
  if (!userStore.currentUser) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }
  
  try {
    if (isFavorite.value) {
      await favoriteApi.remove(currentTrack.value.id)
      userStore.removeFavorite(currentTrack.value.id)
      ElMessage.success('已取消收藏')
    } else {
      await favoriteApi.add(currentTrack.value.id)
      userStore.addFavorite(currentTrack.value.id)
      ElMessage.success('收藏成功')
    }
  } catch (e: any) {
    console.error('Favorite error:', e)
    if (e.response?.status === 401) {
      ElMessage.warning('请先登录')
      router.push('/login')
    } else {
      ElMessage.error(e.response?.data?.message || '操作失败')
    }
  }
}

const togglePlayMode = () => {
  const modes: ('order' | 'single' | 'random')[] = ['order', 'single', 'random']
  const newMode = modes[(playMode.value + 1) % 3]
  playerStore.setPlayMode(newMode)
  const modeNames = { order: '顺序播放', single: '单曲循环', random: '随机播放' }
  ElMessage.success(modeNames[newMode])
}

const openCommentDrawer = () => {
  if (currentTrack.value) {
    showCommentDrawer.value = true
  }
}

const handleVolumeChange = (value: number) => {
  playerStore.setVolume(value / 100)
}

const toggleVolumePopup = () => {
  showVolumePopup.value = !showVolumePopup.value
}

// 点击外部关闭弹窗
const handleClickOutside = (e: MouseEvent) => {
  if (volumeWrapper.value && !volumeWrapper.value.contains(e.target as Node)) {
    showVolumePopup.value = false
  }
  if (sleepWrapper.value && !sleepWrapper.value.contains(e.target as Node)) {
    showSleepPopup.value = false
  }
}

// 全局键盘快捷键
const handleKeydown = (e: KeyboardEvent) => {
  const tag = (e.target as HTMLElement)?.tagName
  if (tag === 'INPUT' || tag === 'TEXTAREA' || (e.target as HTMLElement)?.isContentEditable) return

  switch (e.code) {
    case 'Space':
      e.preventDefault()
      playerStore.togglePlay()
      break
    case 'ArrowRight':
      e.preventDefault()
      playerStore.playNext()
      break
    case 'ArrowLeft':
      e.preventDefault()
      playerStore.playPrevious()
      break
    case 'ArrowUp':
      e.preventDefault()
      playerStore.setVolume(Math.min(1, playerStore.volume + 0.05))
      break
    case 'ArrowDown':
      e.preventDefault()
      playerStore.setVolume(Math.max(0, playerStore.volume - 0.05))
      break
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
  document.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
  document.removeEventListener('keydown', handleKeydown)
})
</script>

<style scoped>
.player-wrapper {
  position: fixed;
  bottom: 0;
  left: 0;
  z-index: var(--z-player);
  width: 100%;
}

/* Progress bar */
.progress-border {
  height: 3px;
  position: relative;
  cursor: pointer;
  transition: height var(--dur-fast);
}
.progress-border:hover,
.progress-border.dragging {
  height: 5px;
}
.progress-bg {
  width: 100%;
  height: 100%;
  background: rgba(255, 255, 255, 0.08);
}
.progress-fill {
  height: 100%;
  background: var(--accent);
  transition: width 0.1s linear;
  position: relative;
}
.progress-fill::after {
  content: '';
  position: absolute;
  right: -5px;
  top: 50%;
  transform: translateY(-50%) scale(0);
  width: 10px;
  height: 10px;
  background: #fff;
  border-radius: 50%;
  transition: transform var(--dur-fast);
  box-shadow: 0 0 6px var(--accent-glow);
}
.progress-border:hover .progress-fill::after,
.progress-border.dragging .progress-fill::after {
  transform: translateY(-50%) scale(1);
}
.time-tooltip {
  position: absolute;
  bottom: 12px;
  transform: translateX(-50%);
  background: var(--bg-elevated);
  color: var(--text-primary);
  padding: 3px 8px;
  border-radius: var(--radius-sm);
  font-size: var(--text-xs);
  pointer-events: none;
  border: 1px solid var(--border);
}

/* Main bar：中间为一体，两边往两端靠 */
.player-container {
  height: var(--player-h);
  background: var(--bg-secondary);
  border-top: 1px solid var(--border);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 var(--sp-5);
}

/* Left：封面+昵称+爱心+时长，整体靠左 */
.player-left {
  --cover-size: 48px;
  display: flex;
  align-items: center;
  flex: 1;
  min-width: 0;
  justify-content: flex-start;
}

.cover-info-group {
  display: flex;
  align-items: center;
  gap: var(--sp-2);
  flex: 1;
  min-width: 0;
}


/* Center：模式/上/播/下/音量为一体 */
.player-center {
  flex-shrink: 0;
  display: flex;
  justify-content: center;
  padding: 0 var(--sp-4);
}
.control-buttons {
  display: flex;
  align-items: center;
  gap: var(--sp-1);
}

/* Right：往右端靠 */
.player-right {
  display: flex;
  align-items: center;
  gap: var(--sp-1);
  flex: 1;
  min-width: 0;
  justify-content: flex-end;
}
.cover-wrapper {
  flex-shrink: 0;
  cursor: pointer;
  width: 48px;
  height: 48px;
  border-radius: 50%;
  overflow: hidden;
}
.cover-adjacent {
  display: flex;
  align-items: center;
  gap: var(--sp-2);
  flex-shrink: 0;
}
.track-cover {
  width: 100%;
  height: 100%;
  object-fit: cover;
  animation: rotate 20s linear infinite paused;
}
.track-cover.rotating { animation-play-state: running; }
.player-left .track-info {
  flex: 1;
  min-width: 0;
  max-width: 140px;
  cursor: pointer;
}
.player-left .track-info p {
  margin: 0;
  overflow: hidden;
  white-space: nowrap;
}
.track-name-wrap,
.artist-name-wrap {
  overflow: hidden;
  position: relative;
  text-overflow: ellipsis;
}
.track-name-inner,
.artist-name-inner {
  display: inline-block;
  white-space: nowrap;
}
.track-name-inner.scroll,
.artist-name-inner.scroll {
  transition: none;
}
.track-name-inner.scroll,
.artist-name-inner.scroll {
  animation: marquee 8s linear infinite;
}
@keyframes marquee {
  0% { transform: translateX(0); }
  100% { transform: translateX(-50%); }
}
.player-left .track-name-wrap {
  font-size: var(--text-base);
  color: var(--text-primary);
  font-weight: 500;
}
.player-left .artist-name-wrap {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  margin-top: 2px;
}
.favorite-btn {
  width: 32px;
  height: 32px;
  border: none;
  background: transparent;
  color: var(--text-tertiary);
  flex-shrink: 0;
  border-radius: var(--radius-sm);
  transition: all var(--dur-fast);
}
.favorite-btn:hover { color: var(--red); background: var(--bg-hover); }
.favorite-btn :deep(.el-icon) { font-size: 16px; }
.track-time {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  flex-shrink: 0;
  min-width: 80px;
  font-variant-numeric: tabular-nums;
}

.control-btn {
  width: 36px;
  height: 36px;
  border: none;
  background: transparent;
  color: var(--text-secondary);
  border-radius: var(--radius-sm);
  transition: all var(--dur-fast);
  outline: none;
  display: flex;
  align-items: center;
  justify-content: center;
}
.control-btn:hover { color: var(--text-primary); background: var(--bg-hover); }
.control-btn:active { transform: scale(0.92); }
.control-btn :deep(.el-icon) { font-size: 18px; }

/* 播放模式按钮：文字+图标，直观易懂 */
/* 评论按钮（在封面区域，爱心和时长右侧） */
.cover-adjacent .comment-btn {
  margin-left: var(--sp-1);
}
.comment-btn {
  color: var(--text-tertiary);
}
.comment-btn:hover:not(:disabled) {
  color: var(--accent);
}
.comment-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.cover-adjacent .add-to-playlist-btn {
  margin-left: var(--sp-1);
}
.add-to-playlist-btn {
  color: var(--text-tertiary);
}
.add-to-playlist-btn:hover:not(:disabled) {
  color: var(--accent);
}
.add-to-playlist-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.play-btn {
  width: 44px;
  height: 44px;
  border: none;
  background: var(--accent);
  color: #fff;
  border-radius: 50%;
  transition: all var(--dur-fast);
  display: flex;
  align-items: center;
  justify-content: center;
}
.play-btn:hover { background: var(--accent-hover); transform: scale(1.05); box-shadow: var(--shadow-glow); }
.play-btn :deep(.el-icon) { font-size: 22px; }

/* Volume popup */
.volume-wrapper { position: relative; }
.volume-popup {
  position: absolute;
  bottom: 52px;
  left: 50%;
  transform: translateX(-50%);
  width: 180px;
  background: var(--bg-elevated);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  padding: var(--sp-4);
  box-shadow: var(--shadow-md);
}
.volume-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: var(--sp-3);
  font-size: var(--text-sm);
}
.volume-label { color: var(--text-secondary); }
.volume-percent { color: var(--accent); font-weight: 600; }
.volume-slider :deep(.el-slider__runway) { height: 3px; background: rgba(255,255,255,0.1); }
.volume-slider :deep(.el-slider__bar) { height: 3px; background: var(--accent); }
.volume-slider :deep(.el-slider__button) { width: 10px; height: 10px; border: 2px solid var(--accent); background: #fff; }

.sleep-wrapper { position: relative; }
.sleep-btn.active { color: var(--accent) !important; }
.sleep-popup {
  position: absolute;
  bottom: 52px;
  right: 0;
  width: 170px;
  background: var(--bg-elevated);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  padding: var(--sp-2) 0;
  box-shadow: var(--shadow-md);
  z-index: 10;
}
.sleep-title {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  padding: var(--sp-2) var(--sp-4) var(--sp-3);
  border-bottom: 1px solid var(--border);
}
.sleep-option {
  padding: var(--sp-3) var(--sp-4);
  font-size: var(--text-sm);
  color: var(--text-secondary);
  cursor: pointer;
  transition: background var(--dur-fast);
}
.sleep-option:hover { background: var(--bg-hover); color: var(--text-primary); }
.sleep-option.active { color: var(--accent); font-weight: 600; }

/* 播放列表抽屉 */
.playlist-drawer :deep(.el-drawer) {
  background: var(--bg-primary) !important;
  border-left: 1px solid var(--border);
}
.playlist-drawer :deep(.el-drawer__header) {
  color: var(--text-primary) !important;
  background: var(--bg-secondary) !important;
  border-bottom: 1px solid var(--border);
  padding: var(--sp-4) var(--sp-5);
  margin-bottom: 0;
  font-weight: 600;
}
.playlist-drawer :deep(.el-drawer__body) {
  background: var(--bg-primary) !important;
  padding: 0;
  color: var(--text-primary);
}
.playlist-drawer :deep(.el-drawer__close-btn) {
  color: var(--text-tertiary);
}
.playlist-container { height: 100%; display: flex; flex-direction: column; }
.playlist-header { display: flex; justify-content: space-between; align-items: center; padding: var(--sp-3) var(--sp-5); background: var(--bg-secondary); border-bottom: 1px solid var(--border); }
.playlist-count { font-size: var(--text-sm); color: var(--text-secondary); font-weight: 500; }
.playlist-content { flex: 1; overflow-y: auto; padding: var(--sp-2) 0; }
.playlist-item { display: flex; align-items: center; padding: var(--sp-3) var(--sp-4); margin: var(--sp-1) var(--sp-2); border-radius: var(--radius-md); cursor: pointer; transition: all var(--dur-fast) var(--ease-out); border: 1px solid var(--border); background: var(--bg-card); }
.playlist-item + .playlist-item { margin-top: var(--sp-1); }
.playlist-item:hover { background: var(--bg-elevated); border-color: var(--border-hover); }
.playlist-item.active { background: var(--accent-muted); border-color: var(--border-accent); box-shadow: 0 0 0 1px var(--border-accent); }
.playlist-item.active .track-name { color: var(--accent-hover) !important; font-weight: 600; }
.playlist-item.active .track-index { color: var(--accent); }
.playlist-item .track-index { width: 30px; flex-shrink: 0; font-size: var(--text-sm); color: var(--text-tertiary); text-align: center; font-variant-numeric: tabular-nums; }
.playing-icon { color: var(--accent); animation: pulse-icon 1.5s ease-in-out infinite; }
@keyframes pulse-icon { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
.playlist-item .track-info { flex: 1; min-width: 0; padding: 0 var(--sp-3); }
.playlist-item .track-name { margin: 0; font-size: var(--text-sm); font-weight: 500; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; line-height: 1.4; }
.playlist-item .track-artist { margin: 2px 0 0; font-size: var(--text-xs); color: var(--text-tertiary); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; line-height: 1.3; }
.track-actions { flex-shrink: 0; opacity: 0; transition: opacity var(--dur-fast); }
.playlist-item:hover .track-actions { opacity: 1; }
.remove-btn { color: var(--text-tertiary); border-radius: var(--radius-sm); width: 28px; height: 28px; display: flex; align-items: center; justify-content: center; background: none; border: none; cursor: pointer; transition: all var(--dur-fast); }
.remove-btn:hover { color: var(--red); background: rgba(239, 68, 68, 0.1); }
.clear-btn { display: flex; align-items: center; gap: var(--sp-1); padding: var(--sp-1) var(--sp-3); border-radius: var(--radius-sm); font-size: var(--text-xs); color: var(--text-tertiary); background: transparent; border: 1px solid var(--border); cursor: pointer; transition: all var(--dur-fast); }
.clear-btn:hover { color: var(--red); border-color: rgba(239, 68, 68, 0.3); background: rgba(239, 68, 68, 0.08); }
.empty-playlist { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: var(--sp-16) var(--sp-8); color: var(--text-tertiary); gap: var(--sp-2); }
.empty-playlist p { margin: 0; font-size: var(--text-sm); }
.empty-hint { font-size: var(--text-xs) !important; color: var(--text-tertiary); opacity: 0.6; }

@keyframes rotate { to { transform: rotate(360deg); } }

:deep(.el-icon) svg { width: 1em; height: 1em; fill: currentColor; }
:deep(.el-icon) { display: inline-flex; align-items: center; justify-content: center; }

/* 添加到歌单弹窗 */
.playlist-add-dialog :deep(.el-dialog) {
  background: var(--bg-primary);
  border: 1px solid var(--border);
}
.playlist-add-dialog :deep(.el-dialog__header) {
  color: var(--text-primary);
  border-bottom: 1px solid var(--border);
}
.playlist-add-dialog :deep(.el-dialog__body) {
  color: var(--text-primary);
  background: var(--bg-primary);
}
.playlist-add-dialog :deep(.el-dialog__close) {
  color: var(--text-tertiary);
}
.add-to-playlist-content {
  padding: 10px 0;
}
.selected-track-info {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
  padding: var(--sp-3);
  background: var(--bg-hover);
  border-radius: var(--radius-md);
  margin-bottom: var(--sp-4);
}
.track-cover-small {
  width: 48px;
  height: 48px;
  border-radius: var(--radius-sm);
  object-fit: cover;
}
.track-text {
  display: flex;
  flex-direction: column;
  gap: 4px;
  overflow: hidden;
}
.track-text .track-title {
  font-size: var(--text-base);
  font-weight: 500;
  color: var(--text-primary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.track-text .track-artist {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}
.playlist-options {
  max-height: 300px;
  overflow-y: auto;
}
.playlist-option-header {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  padding: var(--sp-2) 0;
  border-bottom: 1px solid var(--border);
  margin-bottom: var(--sp-2);
}
.playlist-option-item {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
  padding: 10px;
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: background var(--dur-fast);
}
.playlist-option-item:hover {
  background: var(--bg-active);
}
.pl-cover {
  width: 40px;
  height: 40px;
  border-radius: var(--radius-sm);
  object-fit: cover;
}
.pl-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.pl-name {
  font-size: var(--text-base);
  font-weight: 500;
  color: var(--text-primary);
}
.pl-count {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}
.no-playlists {
  padding: var(--sp-6);
  text-align: center;
  color: var(--text-tertiary);
  font-size: var(--text-sm);
}
</style>
