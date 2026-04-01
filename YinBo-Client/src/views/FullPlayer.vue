<template>
  <div class="full-player">
    <!-- 背景模糊效果 -->
    <div class="background-blur" :style="{ backgroundImage: `url(${currentTrack?.coverUrl || defaultCover})` }"></div>
    
    <!-- 顶部控制栏 -->
    <header class="player-header">
      <button class="back-btn" @click="$emit('close')">
        <svg viewBox="0 0 24 24" width="24" height="24">
          <path fill="currentColor" d="M7.41 15.41L12 10.83l4.59 4.58L18 14l-6-6-6 6z"/>
        </svg>
      </button>
      <div class="header-info">
        <h3 class="track-title">{{ currentTrack?.title || '歌曲名' }}</h3>
        <p class="artist-name">
          <button type="button" class="artist-link-btn" @click="goToSingerPage()">
            {{ currentTrack?.artist || '歌手' }}
          </button>
        </p>
      </div>
      </header>

    <!-- 主内容区域 -->
    <main class="player-main">
      <!-- 左侧：唱片封面 -->
      <div class="disc-section">
        <div class="disc-wrapper" :class="{ playing: isPlaying }">
          <div class="disc-cover">
            <img 
              :src="currentTrack?.coverUrl || defaultCover" 
              :alt="currentTrack?.title"
              class="cover-image"
            />
          </div>
        </div>
      </div>

      <!-- 右侧：歌词区域 -->
      <div class="lyrics-section" :style="{ '--lyric-scale': lyricFontScale }">
        <div class="lyrics-header">
          <div class="track-tags">
            <!-- VIP tag if track is VIP only -->
            <span class="tag source">标准音质</span>
          </div>
        </div>
        
        <div class="lyrics-scroll" ref="lyricsContainer">
          <template v-if="lyricsLines.length > 0">
            <div 
              v-for="(line, index) in lyricsLines" 
              :key="index"
              class="lyrics-line"
              :class="{ active: currentLyricIndex === index }"
              @click="seekToLyric(line.time)"
            >
              <p class="lyric-text">{{ line.text }}</p>
              <p
                v-show="showTranslation && line.translation"
                class="lyric-translation"
              >{{ line.translation }}</p>
            </div>
          </template>
          <div v-else-if="lyricsLoading" class="no-lyrics">
            <p>加载歌词中...</p>
          </div>
          <div v-else class="no-lyrics">
            <p>纯音乐，请欣赏</p>
          </div>
        </div>

        <!-- 歌词控制按钮 -->
        <div class="lyrics-controls">
          <button class="lyric-btn" title="音轨">
            <svg viewBox="0 0 24 24" width="18" height="18">
              <path fill="currentColor" d="M12 3v9.28c-.47-.17-.97-.28-1.5-.28C8.01 12 6 14.01 6 16.5S8.01 21 10.5 21c2.49 0 4.5-2.01 4.5-4.5V6h4V3h-7z"/>
            </svg>
          </button>
          <button class="lyric-btn" :class="{ active: showTranslation }" @click="toggleTranslation" title="显示/隐藏翻译">
            <svg viewBox="0 0 24 24" width="18" height="18">
              <path fill="currentColor" d="M12.87 15.07l-2.54-2.51.03-.03c1.74-1.94 2.98-4.17 3.71-6.53H17V4h-7V2H8v2H1v1.99h11.17C11.5 7.92 10.44 9.75 9 11.35 8.07 10.32 7.3 9.19 6.69 8h-2c.73 1.63 1.73 3.17 2.98 4.56l-5.09 5.02L4 19l5-5 3.11 3.11.76-2.04zM18.5 10h-2L12 22h2l1.12-3h4.75L21 22h2l-4.5-12zm-2.62 7l1.62-4.33L19.12 17h-3.24z"/>
            </svg>
          </button>
          <button type="button" class="lyric-btn lyric-font-btn" title="歌词缩小" @click="shrinkLyricFont">A−</button>
          <button type="button" class="lyric-btn lyric-font-btn" title="歌词放大" @click="bumpLyricFont">A+</button>
        </div>
      </div>
    </main>

    <!-- 底部控制栏 -->
    <footer class="player-footer">
      <!-- 进度条 -->
      <div class="progress-section">
        <span class="time current">{{ formatTime(currentTime) }}</span>
        <div class="progress-bar" ref="progressBar" @click="handleProgressClick">
          <div class="progress-bg">
            <div class="progress-fill" :style="{ width: progressPercent + '%' }"></div>
          </div>
          <div class="progress-handle" :style="{ left: progressPercent + '%' }"></div>
        </div>
        <span class="time total">{{ formatTime(duration) }}</span>
      </div>

      <!-- 控制按钮 -->
      <div class="controls-section">
        <!-- 左侧：收藏和评论 -->
        <div class="left-controls">
          <button class="control-btn" @click="toggleFavorite">
            <svg v-if="isFavorite" viewBox="0 0 1024 1024" width="22" height="22">
              <path fill="#C20C0C" d="M923 283.6c-13.4-31.1-32.6-58.9-56.9-82.8-24.3-23.8-52.5-42.4-84-55.5-32.5-13.5-66.9-20.3-102.4-20.3-49.3 0-97.4 13.5-139.2 39-10 6.1-19.5 12.8-28.5 20-9-7.2-18.5-13.9-28.5-20-41.8-25.5-89.9-39-139.2-39-35.5 0-69.9 6.8-102.4 20.3-31.4 13-59.7 31.7-84 55.5-24.4 23.9-43.5 51.7-56.9 82.8-13.9 32.3-21 66.6-21 101.9 0 33.3 6.8 68 20.3 103.3 11.3 29.5 27.5 60.1 48.2 91 32.8 48.9 77.9 99.9 133.9 151.6 92.8 85.7 184.3 144.9 188.4 147.6l24.7 16.1c10.9 7.1 25.1 7.1 36 0l24.7-16.1c4.1-2.7 95.5-61.9 188.4-147.6 56-51.7 101.1-102.7 133.9-151.6 20.7-30.9 37-61.5 48.2-91 13.5-35.3 20.3-70 20.3-103.3 0.1-35.3-7-69.6-20.9-101.9z"/>
            </svg>
            <svg v-else viewBox="0 0 1024 1024" width="22" height="22">
              <path fill="currentColor" d="M923 283.6c-13.4-31.1-32.6-58.9-56.9-82.8-24.3-23.8-52.5-42.4-84-55.5-32.5-13.5-66.9-20.3-102.4-20.3-49.3 0-97.4 13.5-139.2 39-10 6.1-19.5 12.8-28.5 20-9-7.2-18.5-13.9-28.5-20-41.8-25.5-89.9-39-139.2-39-35.5 0-69.9 6.8-102.4 20.3-31.4 13-59.7 31.7-84 55.5-24.4 23.9-43.5 51.7-56.9 82.8-13.9 32.3-21 66.6-21 101.9 0 33.3 6.8 68 20.3 103.3 11.3 29.5 27.5 60.1 48.2 91 32.8 48.9 77.9 99.9 133.9 151.6 92.8 85.7 184.3 144.9 188.4 147.6l24.7 16.1c10.9 7.1 25.1 7.1 36 0l24.7-16.1c4.1-2.7 95.5-61.9 188.4-147.6 56-51.7 101.1-102.7 133.9-151.6 20.7-30.9 37-61.5 48.2-91 13.5-35.3 20.3-70 20.3-103.3 0.1-35.3-7-69.6-20.9-101.9zM512 814.8S156 586.7 156 385.5c0-91.7 70.6-166.1 157.6-166.1 68.2 0 126.4 44.1 148.5 106.1C511.3 261.4 633 176 710.4 176c87 0 157.6 74.4 157.6 166.1 0 201.2-356 429.3-356 429.3z"/>
            </svg>
          </button>
          <button class="control-btn" @click="openCommentDrawer" title="评论">
            <svg viewBox="0 0 24 24" width="22" height="22">
              <path fill="currentColor" d="M21 6h-2v9H6v2c0 .55.45 1 1 1h11l4 4V7c0-.55-.45-1-1-1zm-4 6V3c0-.55-.45-1-1-1H3c-.55 0-1 .45-1 1v14l4-4h10c.55 0 1-.45 1-1z"/>
            </svg>
          </button>
          <button class="control-btn add-to-playlist-btn" @click="showAddToPlaylistDialogAction" title="添加到歌单">
            <svg viewBox="0 0 24 24" width="22" height="22">
              <path fill="currentColor" d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
            </svg>
          </button>
          <button class="control-btn" title="下载音乐文件" @click="onDownloadCurrent">
            <svg viewBox="0 0 24 24" width="22" height="22">
              <path fill="currentColor" d="M19 9h-4V3H9v6H5l7 7 7-7zM5 18v2h14v-2H5z"/>
            </svg>
          </button>
        </div>

        <!-- 中间居中：播放模式 | 上一首 | 播放 | 下一首 | 音量 -->
        <div class="center-controls">
          <button class="control-btn" @click="togglePlayMode" :title="playModeTitle">
            <svg v-if="playMode === 'order'" viewBox="0 0 24 24" width="20" height="20">
              <path stroke="currentColor" stroke-width="2" fill="none" d="M4 6h16M4 12h16M4 18h16"/>
            </svg>
            <svg v-else-if="playMode === 'single'" viewBox="0 0 24 24" width="20" height="20">
              <path fill="currentColor" d="M12 5V1L7 6l5 5V7c3.31 0 6 2.69 6 6s-2.69 6-6 6-6-2.69-6-6H4c0 4.42 3.58 8 8 8s8-3.58 8-8-3.58-8-8-8z"/>
            </svg>
            <svg v-else viewBox="0 0 24 24" width="20" height="20">
              <path fill="currentColor" d="M10.59 9.17L5.41 4 4 5.41l5.17 5.17 1.42-1.41zM14.5 4l2.04 2.04L4 18.59 5.41 20 17.96 7.46 20 9.5V4h-5.5zm.33 9.41l-1.41 1.41 3.13 3.13L14.5 20H20v-5.5l-2.04 2.04-3.13-3.13z"/>
            </svg>
          </button>
          <button class="control-btn" @click="playPrevious">
            <svg viewBox="0 0 24 24" width="24" height="24">
              <path fill="currentColor" d="M6 6h2v12H6zm3.5 6l8.5 6V6z"/>
            </svg>
          </button>
          <button class="play-btn" @click="togglePlay">
            <svg v-if="isPlaying" viewBox="0 0 24 24" width="28" height="28">
              <path fill="currentColor" d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/>
            </svg>
            <svg v-else viewBox="0 0 24 24" width="28" height="28">
              <path fill="currentColor" d="M8 5v14l11-7z"/>
            </svg>
          </button>
          <button class="control-btn" @click="playNext">
            <svg viewBox="0 0 24 24" width="24" height="24">
              <path fill="currentColor" d="M6 18l8.5-6L6 6v12zM16 6v12h2V6h-2z"/>
            </svg>
          </button>
          <div class="volume-control">
            <button class="control-btn volume-btn" @click="toggleMute">
              <svg v-if="volumeValue === 0" viewBox="0 0 24 24" width="20" height="20">
                <path fill="currentColor" d="M5.889 16H2a1 1 0 01-1-1V9a1 1 0 011-1h3.889l5.294-4.332a.5.5 0 01.817.387v15.89a.5.5 0 01-.817.387L5.89 16z"/>
                <path fill="currentColor" d="M17 11l4-4m0 0l4 4m-4-4v8" stroke="currentColor" stroke-width="2" transform="rotate(45 21 11)"/>
              </svg>
              <svg v-else-if="volumeValue < 50" viewBox="0 0 24 24" width="20" height="20">
                <path fill="currentColor" d="M5.889 16H2a1 1 0 01-1-1V9a1 1 0 011-1h3.889l5.294-4.332a.5.5 0 01.817.387v15.89a.5.5 0 01-.817.387L5.89 16z"/>
                <path fill="none" stroke="currentColor" stroke-width="2" d="M15.536 8.464a5 5 0 010 7.072"/>
              </svg>
              <svg v-else viewBox="0 0 24 24" width="20" height="20">
                <path fill="currentColor" d="M5.889 16H2a1 1 0 01-1-1V9a1 1 0 011-1h3.889l5.294-4.332a.5.5 0 01.817.387v15.89a.5.5 0 01-.817.387L5.89 16z"/>
                <path fill="none" stroke="currentColor" stroke-width="2" d="M15.536 8.464a5 5 0 010 7.072M18.364 5.636a9 9 0 010 12.728"/>
              </svg>
            </button>
            <div class="volume-slider-wrapper">
              <input 
                type="range" 
                min="0" 
                max="100" 
                v-model="volumeValue" 
                class="volume-slider"
                @input="handleVolumeChange"
              />
            </div>
          </div>
        </div>
        <!-- 右侧：播放列表 -->
        <div class="right-controls">
          <button class="control-btn" @click="showPlaylistDrawer = true" title="播放列表">
            <svg viewBox="0 0 24 24" width="20" height="20">
              <path fill="currentColor" d="M4 6h16v2H4zm0 5h16v2H4zm0 5h16v2H4z"/>
            </svg>
          </button>
        </div>
      </div>
    </footer>

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
            <span class="track-artist">
              <button type="button" class="artist-link-btn" @click="goToSingerPage()">{{ currentTrack.artist || '歌手' }}</button>
            </span>
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

    <TrackCommentDrawer v-model="showCommentDrawer" :track="currentTrack" />

    <!-- 播放列表抽屉 -->
    <el-drawer
      v-model="showPlaylistDrawer"
      title="播放列表"
      direction="rtl"
      size="380px"
      class="playlist-drawer"
    >
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
                <p class="track-artist">
                  <button type="button" class="artist-link-btn" @click.stop="goToSingerPage(track)">{{ track.artist }}</button>
                </p>
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
import { ref, computed, watch, onMounted, onUnmounted, nextTick, inject } from 'vue'
import { useRouter } from 'vue-router'
import { usePlayerStore } from '../stores/player'
import { useUserStore } from '../stores/user'
import { storeToRefs } from 'pinia'
import { favoriteApi, trackApi, playlistApi } from '../api'
import TrackCommentDrawer from '../components/TrackCommentDrawer.vue'
import { downloadTrackFile } from '../utils/downloadTrack'
import { pairLyricLine } from '../utils/lyricLocale'
import { ElMessage } from 'element-plus'
import { VideoPlay } from '@element-plus/icons-vue'

const router = useRouter()
const emit = defineEmits(['close'])

// 注入 seek 方法
const seekTo = inject<(time: number) => void>('seekTo')

const playerStore = usePlayerStore()
const userStore = useUserStore()

// 从 store 获取状态
const { currentTrack, isPlaying, currentTime, duration, volume } = storeToRefs(playerStore)

// 默认封面
import { DEFAULT_AVATAR_COVER } from '../constants'
const defaultCover = DEFAULT_AVATAR_COVER

const TRANSLATION_LS_KEY = 'yinbo_fullplayer_show_translation'

// 本地状态
const isFavorite = ref(false)
const showTranslation = ref(
  typeof localStorage !== 'undefined' && localStorage.getItem(TRANSLATION_LS_KEY) === '0' ? false : true
)
const lyricFontScale = ref(1)
const LYRIC_FONT_MIN = 0.75
const LYRIC_FONT_MAX = 1.6
const bumpLyricFont = () => {
  lyricFontScale.value = Math.min(
    LYRIC_FONT_MAX,
    Math.round((lyricFontScale.value + 0.08) * 100) / 100
  )
}
const shrinkLyricFont = () => {
  lyricFontScale.value = Math.max(
    LYRIC_FONT_MIN,
    Math.round((lyricFontScale.value - 0.08) * 100) / 100
  )
}
const currentLyricIndex = ref(0)
const lyricsContainer = ref<HTMLElement | null>(null)
const progressBar = ref<HTMLElement | null>(null)
const previousVolume = ref(80)

// 添加到歌单
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

const onDownloadCurrent = () => {
  const t = currentTrack.value
  if (!t?.id) return
  downloadTrackFile({
    id: t.id,
    title: t.title,
    playUrl: t.playUrl,
    audioUrl: t.audioUrl
  })
}

// 播放列表
const showPlaylistDrawer = ref(false)
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

const showCommentDrawer = ref(false)

// 播放模式 - 从 store 获取
const playMode = computed(() => playerStore.playMode)

// 播放模式标题
const playModeTitle = computed(() => {
  switch (playMode.value) {
    case 'order':
      return '顺序播放'
    case 'single':
      return '单曲循环'
    case 'random':
      return '随机播放'
    default:
      return '顺序播放'
  }
})

// 音量控制
const volumeValue = computed({
  get: () => Math.round(volume.value * 100),
  set: (val: number) => playerStore.setVolume(val / 100)
})

const handleVolumeChange = (e: Event) => {
  const target = e.target as HTMLInputElement
  playerStore.setVolume(parseInt(target.value) / 100)
}

const toggleMute = () => {
  if (volumeValue.value > 0) {
    previousVolume.value = volumeValue.value
    playerStore.setVolume(0)
  } else {
    playerStore.setVolume(previousVolume.value / 100)
  }
}

// 歌词数据
const lyricsLines = ref<{ time: number; text: string; translation?: string }[]>([])
const lyricsLoading = ref(false)

// 解析歌词：LRC 时间轴、同行「原文 / 译」、相邻同时间戳双语行合并
const parseLyrics = (
  lyricsStr: string | undefined,
  trackDuration: number
): { time: number; text: string; translation?: string }[] => {
  if (!lyricsStr || !lyricsStr.trim()) {
    return []
  }
  const raw: { time: number; text: string; translation?: string }[] = []
  const lrcRegex = /\[(\d{1,2}):(\d{2})(?:\.(\d{1,3}))?\](.*)/g
  const lyricLines = lyricsStr.split(/\r?\n/)

  for (const line of lyricLines) {
    const trimmed = line.trim()
    if (!trimmed) continue
    const match = lrcRegex.exec(trimmed)
    if (match) {
      const minutes = parseInt(match[1], 10)
      const seconds = parseInt(match[2], 10)
      const msStr = match[3] || '0'
      const milliseconds = parseInt(msStr.padEnd(3, '0').slice(0, 3), 10)
      const text = (match[4] || '').trim()
      const time = minutes * 60 + seconds + milliseconds / 1000
      if (!text) continue
      const splitInline = text.match(/^(.+?)\s*[／/|｜]\s*(.+)$/)
      if (splitInline) {
        const { text: primary, translation } = pairLyricLine(
          splitInline[1].trim(),
          splitInline[2].trim()
        )
        raw.push({
          time,
          text: primary,
          ...(translation ? { translation } : {})
        })
      } else {
        raw.push({ time, text })
      }
    }
    lrcRegex.lastIndex = 0
  }

  let lines: { time: number; text: string; translation?: string }[] = []

  if (raw.length === 0) {
    const plainLines = lyricLines.map(l => l.trim()).filter(Boolean)
    const duration = trackDuration || 60
    const interval = plainLines.length > 0 ? duration / plainLines.length : 0
    plainLines.forEach((text, i) => {
      const splitInline = text.match(/^(.+?)\s*[／/|｜]\s*(.+)$/)
      if (splitInline) {
        const { text: primary, translation } = pairLyricLine(
          splitInline[1].trim(),
          splitInline[2].trim()
        )
        lines.push({
          time: i * interval,
          text: primary,
          ...(translation ? { translation } : {})
        })
      } else {
        lines.push({ time: i * interval, text })
      }
    })
  } else {
    raw.sort((a, b) => (a.time !== b.time ? a.time - b.time : a.text.length - b.text.length))
    const merged: { time: number; text: string; translation?: string }[] = []
    const EPS = 0.02
    for (let i = 0; i < raw.length; i++) {
      const cur = raw[i]
      if (merged.length > 0) {
        const prev = merged[merged.length - 1]
        if (
          Math.abs(prev.time - cur.time) < EPS &&
          !prev.translation &&
          prev.text !== cur.text
        ) {
          const paired = pairLyricLine(prev.text, cur.text)
          prev.text = paired.text
          prev.translation = paired.translation
          continue
        }
      }
      merged.push({
        time: cur.time,
        text: cur.text,
        ...(cur.translation ? { translation: cur.translation } : {})
      })
    }
    lines = merged
  }

  lines.sort((a, b) => a.time - b.time)
  return lines
}

// 加载歌词：优先使用 track.lyrics，若无则拉取详情
const loadLyrics = async (track: any) => {
  if (!track?.id) {
    lyricsLines.value = []
    return
  }
  if (track.lyrics && track.lyrics.trim()) {
    lyricsLines.value = parseLyrics(track.lyrics, duration.value || track.duration || 0)
    return
  }
  lyricsLoading.value = true
  try {
    const res = await trackApi.getDetail(track.id)
    if (res.data.code === 200 && res.data.data?.lyrics) {
      const d = res.data.data
      lyricsLines.value = parseLyrics(d.lyrics, d.duration || duration.value || 0)
    } else {
      lyricsLines.value = []
    }
  } catch {
    lyricsLines.value = []
  } finally {
    lyricsLoading.value = false
  }
}

// 监听歌曲变化，加载歌词
watch(currentTrack, (newTrack) => {
  if (newTrack) {
    loadLyrics(newTrack)
  } else {
    lyricsLines.value = []
  }
}, { immediate: true })

// 进度百分比
const progressPercent = computed(() => {
  if (duration.value === 0) return 0
  return (currentTime.value / duration.value) * 100
})

// 格式化时间
const formatTime = (seconds: number): string => {
  const mins = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

// 播放控制
const togglePlay = () => {
  playerStore.togglePlay()
}

const playNext = () => {
  playerStore.playNext()
}

const playPrevious = () => {
  playerStore.playPrevious()
}

// 收藏
const toggleFavorite = async () => {
  if (!currentTrack.value) return
  
  // Check if user is logged in
  if (!userStore.currentUser) {
    ElMessage.warning('请先登录')
    return
  }
  
  try {
    if (isFavorite.value) {
      await favoriteApi.remove(currentTrack.value.id)
      userStore.removeFavorite(currentTrack.value.id)
      isFavorite.value = false
      ElMessage.success('已取消收藏')
    } else {
      await favoriteApi.add(currentTrack.value.id)
      userStore.addFavorite(currentTrack.value.id)
      isFavorite.value = true
      ElMessage.success('已收藏')
    }
  } catch (e: any) {
    console.error('Favorite error:', e)
    if (e.response?.status === 401) {
      ElMessage.warning('请先登录')
    } else {
      ElMessage.error(e.response?.data?.message || '操作失败')
    }
  }
}

// 检查收藏状态
const checkFavorite = async () => {
  if (!currentTrack.value) return
  
  // First check local store
  if (userStore.favorites.includes(currentTrack.value.id)) {
    isFavorite.value = true
    return
  }
  
  // Then check from server
  try {
    const res = await favoriteApi.check(currentTrack.value.id)
    isFavorite.value = res.data.data
    
    // Sync to local store
    if (res.data.data && !userStore.favorites.includes(currentTrack.value.id)) {
      userStore.addFavorite(currentTrack.value.id)
    }
  } catch (e) {
    console.error('Check favorite error:', e)
    // Fallback to local store
    isFavorite.value = userStore.favorites.includes(currentTrack.value.id)
  }
}

// 播放模式
const togglePlayMode = () => {
  const modes: ('order' | 'single' | 'random')[] = ['order', 'single', 'random']
  const currentIndex = modes.indexOf(playMode.value)
  const newMode = modes[(currentIndex + 1) % modes.length]
  
  // 更新 store 中的播放模式
  playerStore.setPlayMode(newMode)
  
  const modeNames = { order: '顺序播放', single: '单曲循环', random: '随机播放' }
  ElMessage.success(modeNames[newMode])
}

const goToSingerPage = (track?: { artistId?: number; artist?: string } | null) => {
  const t = track ?? currentTrack.value
  if (!t) return
  if (t.artistId) router.push(`/singer/${t.artistId}`)
  else if (t.artist) router.push({ path: '/artist', query: { name: t.artist } })
  else return
  emit('close')
}

// 歌词控制
const toggleTranslation = () => {
  showTranslation.value = !showTranslation.value
  try {
    localStorage.setItem(TRANSLATION_LS_KEY, showTranslation.value ? '1' : '0')
  } catch {
    /* ignore */
  }
  void nextTick(() => scrollToCurrentLyric())
}

const seekToLyric = (time: number) => {
  if (seekTo) {
    seekTo(time)
  }
  playerStore.setCurrentTime(time)
}

// 进度条控制
const handleProgressClick = (e: MouseEvent) => {
  if (!progressBar.value) return
  
  const rect = progressBar.value.getBoundingClientRect()
  const clickX = e.clientX - rect.left
  const percent = clickX / rect.width
  const newTime = percent * duration.value
  
  if (seekTo) {
    seekTo(newTime)
  }
  playerStore.setCurrentTime(newTime)
}

// 分享
const shareTrack = () => {
  if (currentTrack.value) {
    ElMessage.success('分享链接已复制！')
  }
}

const openCommentDrawer = () => {
  if (!currentTrack.value) return
  showCommentDrawer.value = true
}

// 更新当前歌词行
const updateCurrentLyricIndex = () => {
  for (let i = lyricsLines.value.length - 1; i >= 0; i--) {
    if (currentTime.value >= lyricsLines.value[i].time) {
      currentLyricIndex.value = i
      break
    }
  }
}

// 自动滚动歌词
const scrollToCurrentLyric = async () => {
  await nextTick()
  if (!lyricsContainer.value) return
  
  const activeLine = lyricsContainer.value.querySelector('.lyrics-line.active') as HTMLElement
  if (activeLine) {
    const container = lyricsContainer.value
    const lineTop = activeLine.offsetTop
    const lineHeight = activeLine.offsetHeight
    const containerHeight = container.offsetHeight
    
    container.scrollTop = lineTop - containerHeight / 2 + lineHeight / 2
  }
}

// 监听当前歌曲变化
watch(currentTrack, (newTrack) => {
  if (newTrack) {
    checkFavorite()
  }
})

// 监听播放时间变化
watch(currentTime, () => {
  updateCurrentLyricIndex()
  scrollToCurrentLyric()
})

const bodyPrevOverflow = ref<string | null>(null)

onMounted(() => {
  bodyPrevOverflow.value = document.body.style.overflow
  document.body.style.overflow = 'hidden'
  checkFavorite()
})

onUnmounted(() => {
  document.body.style.overflow = bodyPrevOverflow.value ?? ''
})
</script>

<style scoped>
.full-player {
  --fp-mint: #5b9a88;
  --fp-mint-muted: rgba(91, 154, 136, 0.2);
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 2000;
  display: flex;
  flex-direction: column;
  background: linear-gradient(
    168deg,
    color-mix(in srgb, var(--bg-primary, #fafcfb) 88%, #dff5ea 12%) 0%,
    color-mix(in srgb, var(--bg-primary, #f6faf8) 82%, #cfe8f5 18%) 100%
  );
  color: var(--text-primary);
  overflow: hidden;
  overscroll-behavior: none;
  touch-action: pan-y;
}

.full-player::before {
  content: '';
  position: absolute;
  inset: 0;
  z-index: 0;
  pointer-events: none;
  background: linear-gradient(
    180deg,
    rgba(255, 255, 255, 0.38) 0%,
    rgba(236, 248, 241, 0.22) 45%,
    rgba(233, 242, 252, 0.28) 100%
  );
}

.background-blur {
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background-size: cover;
  background-position: center;
  filter: blur(72px) saturate(1.08) brightness(0.88);
  opacity: 0.42;
  z-index: -1;
}

.player-header {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  padding: var(--sp-4) var(--sp-6);
  background: rgba(255, 255, 255, 0.34);
  border-bottom: 1px solid rgba(91, 154, 136, 0.12);
  backdrop-filter: blur(18px) saturate(1.15);
}

.player-header .back-btn {
  width: 40px;
  height: 40px;
  border: none;
  background: var(--bg-hover);
  color: var(--text-primary);
  border-radius: var(--radius-full);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all var(--dur-fast) var(--ease-out);
}

.player-header .back-btn:hover {
  background: var(--border-hover);
}

.player-header .header-info {
  flex: 1;
  text-align: center;
  padding: 0 var(--sp-4);
}

.player-header .header-info .track-title {
  margin: 0;
  font-size: var(--text-lg);
  font-weight: 600;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.player-header .header-info .artist-name {
  margin: var(--sp-1) 0 0;
  font-size: var(--text-sm);
  color: var(--text-secondary);
}

.artist-link-btn {
  display: inline;
  max-width: 100%;
  padding: 0;
  border: none;
  background: none;
  font: inherit;
  font-size: inherit;
  color: inherit;
  cursor: pointer;
  text-align: inherit;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  vertical-align: bottom;
}

.artist-link-btn:hover {
  color: var(--fp-mint, #5b9a88);
}

.player-header .share-btn {
  width: 40px;
  height: 40px;
  border: none;
  background: var(--bg-hover);
  color: var(--text-primary);
  border-radius: var(--radius-full);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all var(--dur-fast) var(--ease-out);
}

.player-header .share-btn:hover {
  background: var(--border-hover);
}

.player-main {
  position: relative;
  z-index: 1;
  flex: 1;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--sp-10);
  padding: var(--sp-10) var(--sp-16);
  overflow: hidden;
}

.disc-section {
  display: flex;
  align-items: center;
  justify-content: center;
}

.disc-section .disc-wrapper {
  position: relative;
  width: 340px;
  height: 340px;
  animation: rotate 30s linear infinite;
  animation-play-state: paused;
}

.disc-section .disc-wrapper.playing {
  animation-play-state: running;
}

.disc-section .disc-wrapper .disc-cover {
  width: 100%;
  height: 100%;
  border-radius: var(--radius-full);
  overflow: hidden;
  box-shadow:
    0 14px 42px rgba(61, 124, 107, 0.14),
    0 4px 14px rgba(0, 0, 0, 0.06),
    inset 0 1px 0 rgba(255, 255, 255, 0.55);
}

.disc-section .disc-wrapper .disc-cover .cover-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: var(--radius-full);
}

.lyrics-section {
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.lyrics-section .lyrics-header {
  padding-bottom: var(--sp-4);
}

.lyrics-section .lyrics-header .track-tags {
  display: flex;
  gap: var(--sp-2);
}

.lyrics-section .lyrics-header .track-tags .tag {
  padding: var(--sp-1) var(--sp-3);
  border-radius: var(--radius-md);
  font-size: var(--text-xs);
  font-weight: 500;
}

.lyrics-section .lyrics-header .track-tags .tag.vip {
  background: linear-gradient(135deg, #ffd700, #ff8c00);
  color: #000;
}

.lyrics-section .lyrics-header .track-tags .tag.source {
  background: rgba(255, 255, 255, 0.55);
  color: var(--text-secondary);
  border: 1px solid rgba(91, 154, 136, 0.15);
}

.lyrics-section .lyrics-scroll {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  overflow-x: hidden;
  padding-right: var(--sp-4);
  overscroll-behavior: contain;
  -webkit-overflow-scrolling: touch;
  mask-image: linear-gradient(to bottom, transparent 0%, black 10%, black 90%, transparent 100%);
  -webkit-mask-image: linear-gradient(to bottom, transparent 0%, black 10%, black 90%, transparent 100%);
}

.lyrics-section .lyrics-scroll::-webkit-scrollbar {
  width: 4px;
}

.lyrics-section .lyrics-scroll::-webkit-scrollbar-thumb {
  background: var(--border-hover);
  border-radius: 2px;
}

.lyrics-section .lyrics-scroll .lyrics-line {
  padding: var(--sp-3) 0;
  cursor: pointer;
  transition: all var(--dur-normal) var(--ease-out);
  opacity: 0.5;
}

.lyrics-section .lyrics-scroll .lyrics-line:hover {
  opacity: 0.8;
}

.lyrics-section .lyrics-scroll .lyrics-line.active {
  opacity: 1;
}

.lyrics-section .lyrics-scroll .lyrics-line.active .lyric-text {
  font-size: calc(var(--text-lg) * var(--lyric-scale, 1));
  font-weight: 600;
  color: color-mix(in srgb, var(--fp-mint, #5b9a88) 75%, var(--text-primary) 25%);
}

.lyrics-section .lyrics-scroll .lyrics-line.active .lyric-translation {
  font-size: calc(var(--text-xs) * var(--lyric-scale, 1));
  font-weight: 400;
  color: var(--text-tertiary);
  opacity: 0.72;
}

.lyrics-section .lyrics-scroll .lyrics-line .lyric-text {
  margin: 0;
  font-size: calc(var(--text-md) * var(--lyric-scale, 1));
  line-height: 1.5;
  transition: all var(--dur-normal) var(--ease-out);
}

.lyrics-section .lyrics-scroll .lyrics-line .lyric-translation {
  margin: 2px 0 0;
  padding-left: 1px;
  font-size: calc(var(--text-xs) * var(--lyric-scale, 1));
  line-height: 1.45;
  color: var(--text-tertiary);
  opacity: 0.68;
  transition: all var(--dur-normal) var(--ease-out);
}

.lyrics-section .lyrics-scroll .no-lyrics {
  text-align: center;
  padding: var(--sp-16) 0;
  color: var(--text-tertiary);
}

.lyrics-section .lyrics-controls {
  display: flex;
  justify-content: flex-end;
  gap: var(--sp-2);
  padding-top: var(--sp-4);
}

.lyrics-section .lyrics-controls .lyric-btn {
  width: 36px;
  height: 36px;
  border: none;
  background: var(--bg-hover);
  color: var(--text-secondary);
  border-radius: var(--radius-full);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all var(--dur-fast) var(--ease-out);
}

.lyrics-section .lyrics-controls .lyric-btn:hover {
  background: var(--border-hover);
  color: var(--text-primary);
}

.lyrics-section .lyrics-controls .lyric-btn.active {
  background: var(--fp-mint-muted, rgba(91, 154, 136, 0.2));
  color: var(--fp-mint, #5b9a88);
  box-shadow: 0 0 0 1px rgba(91, 154, 136, 0.28);
}

.lyrics-section .lyrics-controls .lyric-btn.active {
  background: var(--accent);
  color: var(--text-primary);
}

.lyrics-section .lyrics-controls .lyric-font-btn {
  width: auto;
  min-width: 36px;
  padding: 0 10px;
  font-weight: 700;
  font-size: 14px;
}

.player-footer {
  position: relative;
  z-index: 1;
  padding: var(--sp-5) var(--sp-16) var(--sp-10);
  background: rgba(255, 255, 255, 0.36);
  border-top: 1px solid rgba(91, 154, 136, 0.1);
  backdrop-filter: blur(16px) saturate(1.12);
}

.player-footer .progress-section {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
  margin-bottom: var(--sp-5);
}

.player-footer .progress-section .time {
  font-size: var(--text-xs);
  color: var(--text-secondary);
  min-width: 40px;
}

.player-footer .progress-section .time.current {
  text-align: right;
}

.player-footer .progress-section .progress-bar {
  flex: 1;
  height: 4px;
  position: relative;
  cursor: pointer;
}

.player-footer .progress-section .progress-bar:hover .progress-handle {
  opacity: 1;
  transform: translate(-50%, -50%) scale(1);
}

.player-footer .progress-section .progress-bar .progress-bg {
  width: 100%;
  height: 100%;
  background: var(--border-hover);
  border-radius: 2px;
}

.player-footer .progress-section .progress-bar .progress-fill {
  height: 100%;
  background: var(--accent);
  border-radius: 2px;
  transition: width var(--dur-fast) linear;
}

.player-footer .progress-section .progress-bar .progress-handle {
  position: absolute;
  top: 50%;
  transform: translate(-50%, -50%) scale(0);
  width: 12px;
  height: 12px;
  background: var(--text-primary);
  border-radius: var(--radius-full);
  box-shadow: var(--shadow-md);
  opacity: 0;
  transition: all var(--dur-fast) var(--ease-out);
}

.player-footer .controls-section {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.player-footer .controls-section .left-controls {
  flex: 1;
  display: flex;
  align-items: center;
  gap: var(--sp-2);
  min-width: 0;
}

.player-footer .controls-section .center-controls {
  flex: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--sp-6);
}

.player-footer .controls-section .right-controls {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: var(--sp-2);
  min-width: 0;
}

.player-footer .controls-section .volume-control {
  display: flex;
  align-items: center;
  gap: var(--sp-1);
}

.player-footer .controls-section .volume-control .volume-btn {
  width: 40px;
  height: 40px;
}

.player-footer .controls-section .volume-control .volume-slider-wrapper {
  width: 60px;
  opacity: 0;
  transition: opacity var(--dur-fast) var(--ease-out), width var(--dur-fast) var(--ease-out);
}

.player-footer .controls-section .volume-control:hover .volume-slider-wrapper {
  opacity: 1;
}

.player-footer .controls-section .volume-control .volume-slider {
  -webkit-appearance: none;
  appearance: none;
  width: 100%;
  height: 4px;
  background: var(--border-hover);
  border-radius: 2px;
  outline: none;
}

.player-footer .controls-section .volume-control .volume-slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 12px;
  height: 12px;
  background: var(--text-primary);
  border-radius: var(--radius-full);
  cursor: pointer;
  box-shadow: var(--shadow-md);
}

.player-footer .controls-section .volume-control .volume-slider::-moz-range-thumb {
  width: 12px;
  height: 12px;
  background: var(--text-primary);
  border-radius: var(--radius-full);
  cursor: pointer;
  border: none;
}

.player-footer .controls-section .control-btn {
  width: 44px;
  height: 44px;
  border: none;
  background: transparent;
  color: var(--text-secondary);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-full);
  transition: all var(--dur-fast) var(--ease-out);
}

.player-footer .controls-section .control-btn:hover {
  background: var(--bg-hover);
  color: var(--text-primary);
}

.player-footer .controls-section .add-to-playlist-btn {
  margin-left: var(--sp-1);
}

.player-footer .controls-section .play-btn {
  width: 60px;
  height: 60px;
  border: none;
  background: var(--accent);
  color: var(--text-primary);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-full);
  transition: all var(--dur-fast) var(--ease-out);
  box-shadow: 0 4px 20px var(--accent-glow);
}

.player-footer .controls-section .play-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 6px 25px var(--accent-glow);
}

@keyframes rotate {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

@media (max-width: 1024px) {
  .player-main {
    grid-template-columns: 1fr;
    padding: var(--sp-5) var(--sp-8);
    gap: var(--sp-5);
  }

  .disc-section .disc-wrapper {
    width: 260px;
    height: 260px;
  }

  .player-footer {
    padding: var(--sp-4) var(--sp-8) var(--sp-8);
  }
}

@media (max-width: 768px) {
  .player-header {
    padding: var(--sp-3) var(--sp-4);
  }

  .player-main {
    padding: var(--sp-4);
  }

  .player-main .disc-section .disc-wrapper {
    width: 200px;
    height: 200px;
  }

  .player-footer {
    padding: var(--sp-3) var(--sp-4) var(--sp-6);
  }

  .player-footer .controls-section .center-controls {
    gap: var(--sp-4);
  }

  .player-footer .controls-section .play-btn {
    width: 52px;
    height: 52px;
  }
}

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
.playlist-add-dialog .add-to-playlist-content {
  padding: 10px 0;
}
.playlist-add-dialog .selected-track-info {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
  padding: var(--sp-3);
  background: var(--bg-hover);
  border-radius: var(--radius-md);
  margin-bottom: var(--sp-4);
}
.playlist-add-dialog .track-cover-small {
  width: 48px;
  height: 48px;
  border-radius: var(--radius-sm);
  object-fit: cover;
}
.playlist-add-dialog .track-text {
  display: flex;
  flex-direction: column;
  gap: 4px;
  overflow: hidden;
}
.playlist-add-dialog .track-text .track-title {
  font-size: var(--text-base);
  font-weight: 500;
  color: var(--text-primary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.playlist-add-dialog .track-text .track-artist {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}
.playlist-add-dialog .playlist-options {
  max-height: 300px;
  overflow-y: auto;
}
.playlist-add-dialog .playlist-option-header {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  padding: var(--sp-2) 0;
  border-bottom: 1px solid var(--border);
  margin-bottom: var(--sp-2);
}
.playlist-add-dialog .playlist-option-item {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
  padding: 10px;
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: background var(--dur-fast);
}
.playlist-add-dialog .playlist-option-item:hover {
  background: var(--bg-active);
}
.playlist-add-dialog .pl-cover {
  width: 40px;
  height: 40px;
  border-radius: var(--radius-sm);
  object-fit: cover;
}
.playlist-add-dialog .pl-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.playlist-add-dialog .pl-name {
  font-size: var(--text-base);
  font-weight: 500;
  color: var(--text-primary);
}
.playlist-add-dialog .pl-count {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}
.playlist-add-dialog .no-playlists {
  padding: var(--sp-6);
  text-align: center;
  color: var(--text-tertiary);
  font-size: var(--text-sm);
}

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

.playlist-container {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.playlist-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--sp-3) var(--sp-5);
  background: var(--bg-secondary);
  border-bottom: 1px solid var(--border);
}

.playlist-count {
  font-size: var(--text-sm);
  color: var(--text-secondary);
  font-weight: 500;
}

.playlist-content {
  flex: 1;
  overflow-y: auto;
  padding: var(--sp-2) 0;
}

.playlist-item {
  display: flex;
  align-items: center;
  padding: var(--sp-3) var(--sp-4);
  margin: var(--sp-1) var(--sp-2);
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all var(--dur-fast) var(--ease-out);
  border: 1px solid var(--border);
  background: var(--bg-card);
}

.playlist-item + .playlist-item {
  margin-top: var(--sp-1);
}

.playlist-item:hover {
  background: var(--bg-elevated);
  border-color: var(--border-hover);
}

.playlist-item.active {
  background: var(--accent-muted);
  border-color: var(--border-accent);
  box-shadow: 0 0 0 1px var(--border-accent);
}

.playlist-item.active .track-name {
  color: var(--accent-hover) !important;
  font-weight: 600;
}

.playlist-item.active .track-index {
  color: var(--accent);
}

.playlist-item .track-index {
  width: 30px;
  flex-shrink: 0;
  font-size: var(--text-sm);
  color: var(--text-tertiary);
  text-align: center;
  font-variant-numeric: tabular-nums;
}

.playing-icon {
  color: var(--accent);
  animation: pulse-icon 1.5s ease-in-out infinite;
}

@keyframes pulse-icon {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.playlist-item .track-info {
  flex: 1;
  min-width: 0;
  padding: 0 var(--sp-3);
}

.playlist-item .track-name {
  margin: 0;
  font-size: var(--text-base);
  color: var(--text-primary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  line-height: 1.4;
}

.playlist-item .track-artist {
  margin: 2px 0 0;
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  line-height: 1.3;
}

.playlist-item .track-artist .artist-link-btn {
  display: block;
  color: var(--text-tertiary);
  text-align: left;
  text-overflow: ellipsis;
  overflow: hidden;
}

.track-actions {
  flex-shrink: 0;
  opacity: 0;
  transition: opacity var(--dur-fast);
}

.playlist-item:hover .track-actions {
  opacity: 1;
}

.remove-btn {
  color: var(--text-tertiary);
  border-radius: var(--radius-sm);
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: none;
  border: none;
  cursor: pointer;
  transition: all var(--dur-fast);
}
.remove-btn:hover {
  color: var(--red);
  background: rgba(239, 68, 68, 0.1);
}

.clear-btn {
  display: flex;
  align-items: center;
  gap: var(--sp-1);
  padding: var(--sp-1) var(--sp-3);
  border-radius: var(--radius-sm);
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  background: transparent;
  border: 1px solid var(--border);
  cursor: pointer;
  transition: all var(--dur-fast);
}
.clear-btn:hover {
  color: var(--red);
  border-color: rgba(239, 68, 68, 0.3);
  background: rgba(239, 68, 68, 0.08);
}

.empty-playlist {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: var(--sp-16) var(--sp-8);
  color: var(--text-tertiary);
  gap: var(--sp-2);
}
.empty-playlist p {
  margin: 0;
  font-size: var(--text-sm);
}
.empty-hint {
  font-size: var(--text-xs) !important;
  color: var(--text-tertiary);
  opacity: 0.6;
}
</style>
