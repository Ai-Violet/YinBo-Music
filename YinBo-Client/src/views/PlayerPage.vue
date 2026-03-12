<template>
  <div class="player-page-container">
    <!-- 顶部导航 -->
    <div class="page-header">
      <el-button @click="goBack" class="back-btn">
        <el-icon><ArrowLeft /></el-icon>
        返回
      </el-button>
    </div>

    <!-- 播放器主体 -->
    <div class="player-main">
      <!-- 左侧：歌曲封面 -->
      <div class="album-section">
        <div class="album-cover-wrapper">
          <img 
            :src="currentTrack?.cover || '/花君.png'" 
            :alt="currentTrack?.title" 
            class="album-cover"
            :class="{ rotating: isPlaying }"
          >
          <div class="vinyl-disc" :class="{ spinning: isPlaying }"></div>
        </div>
        
        <!-- 收藏和分享按钮 -->
        <div class="album-actions">
          <el-button 
            :type="isFavorite ? 'danger' : 'primary'" 
            @click="toggleFavorite"
            class="action-btn"
          >
            <el-icon><component :is="isFavorite ? StarFilled : Star" /></el-icon>
            {{ isFavorite ? '已收藏' : '收藏' }}
          </el-button>
          <el-button @click="shareTrack" class="action-btn">
            <el-icon><Share /></el-icon>
            分享
          </el-button>
        </div>
      </div>

      <!-- 右侧：歌曲信息和歌词 -->
      <div class="track-section">
        <!-- 歌曲基本信息 -->
        <div class="track-info">
          <h1 class="track-title">{{ currentTrack?.title || '未知歌曲' }}</h1>
          <p class="track-artist">{{ currentTrack?.artist || '未知歌手' }}</p>
          <p class="track-album">{{ currentTrack?.album || '未知专辑' }}</p>
          
          <!-- 播放统计 -->
          <div class="track-stats">
            <span class="stat-item">
              <el-icon><Headphones /></el-icon>
              {{ formatCount(playCount) }} 次播放
            </span>
            <span class="stat-item">
              <el-icon><Timer /></el-icon>
              {{ formatTime(currentTrack?.duration || 0) }}
            </span>
          </div>
        </div>

        <!-- 播放控制 -->
        <div class="player-controls">
          <div class="progress-section">
            <div class="time-display">
              <span class="current-time">{{ formatTime(currentTime) }}</span>
              <span class="total-time">{{ formatTime(duration) }}</span>
            </div>
            
            <div class="progress-bar" ref="progressBar" @click="handleProgressClick">
              <div class="progress-bg">
                <div class="progress-fill" :style="{ width: progressPercent + '%' }"></div>
              </div>
              <div class="progress-handle" :style="{ left: progressPercent + '%' }"></div>
            </div>
          </div>

          <div class="control-buttons">
            <el-button circle @click="togglePlayMode">
              <el-icon><component :is="playModeIcon" /></el-icon>
            </el-button>
            
            <el-button circle @click="playPrevious">
              <el-icon><DArrowLeft /></el-icon>
            </el-button>
            
            <el-button 
              circle 
              size="large" 
              :type="isPlaying ? 'primary' : 'default'"
              @click="togglePlay"
              class="play-pause-btn"
            >
              <el-icon><component :is="isPlaying ? VideoPause : VideoPlay" /></el-icon>
            </el-button>
            
            <el-button circle @click="playNext">
              <el-icon><DArrowRight /></el-icon>
            </el-button>
            
            <el-button circle @click="toggleLyrics">
              <el-icon><Document /></el-icon>
            </el-button>
          </div>

          <!-- 音量控制 -->
          <div class="volume-control">
            <el-slider
              v-model="volume"
              :min="0"
              :max="100"
              :show-tooltip="false"
              @input="handleVolumeChange"
              class="volume-slider"
            />
            <span class="volume-text">{{ volume }}%</span>
          </div>
        </div>

        <!-- 歌词显示 -->
        <div class="lyrics-section" v-if="showLyrics">
          <div class="lyrics-container">
            <div class="lyrics-header">
              <h3>歌词</h3>
              <el-button text @click="toggleLyricsMode">
                {{ lyricsMode === 'full' ? '精简' : '完整' }}模式
              </el-button>
            </div>
            
            <div class="lyrics-content" ref="lyricsContainer">
              <div
                v-for="(line, index) in currentLyrics"
                :key="index"
                class="lyrics-line"
                :class="{ active: currentLyricIndex === index, highlight: isHighlighted(index) }"
                @click="seekToLyric(line.time)"
              >
                {{ line.text }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 相关推荐 -->
    <div class="recommendations-section">
      <h3>相关推荐</h3>
      <div class="recommendations-grid">
        <div
          v-for="track in recommendedTracks"
          :key="track.id"
          class="recommendation-card"
          @click="playRecommendedTrack(track)"
        >
          <div class="rec-cover-wrapper">
            <img :src="track.cover" :alt="track.title" class="rec-cover">
            <div class="rec-play-overlay">
              <div class="rec-play-btn-circle">
                <el-icon><VideoPlay /></el-icon>
              </div>
            </div>
          </div>
          <div class="rec-info">
            <div class="rec-title">{{ track.title }}</div>
            <div class="rec-artist">{{ track.artist }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch, nextTick } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { usePlayerStore } from '../stores/player'
import { storeToRefs } from 'pinia'
import type { Track } from '../types/track'
import {
  ArrowLeft,
  StarFilled,
  Star,
  Share,
  Headset as Headphones,
  Timer,
  VideoPlay,
  VideoPause,
  DArrowLeft,
  DArrowRight,
  Document
} from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()
const playerStore = usePlayerStore()

// 播放器状态
const { currentTrack, isPlaying, volume, currentTime, duration } = storeToRefs(playerStore)

// 本地状态
const isFavorite = ref(false)
const playCount = ref(123456)
const showLyrics = ref(true)
const lyricsMode = ref<'full' | 'simple'>('full')
const currentLyricIndex = ref(0)
const progressBar = ref<HTMLElement>()
const lyricsContainer = ref<HTMLElement>()

// 播放模式
const playMode = ref(0) // 0: 列表循环, 1: 单曲循环, 2: 随机播放

// 播放模式图标
const playModeIcon = computed(() => {
  const icons = ['Refresh', 'RefreshRight', 'SwitchButton']
  return icons[playMode.value]
})

// 进度百分比
const progressPercent = computed(() => {
  if (duration.value === 0) return 0
  return (currentTime.value / duration.value) * 100
})

// 歌词数据
const lyricsData = ref([
  { time: 0, text: '这是第一行歌词' },
  { time: 30, text: '这是第二行歌词' },
  { time: 60, text: '这是第三行歌词' },
  { time: 90, text: '这是第四行歌词' },
  { time: 120, text: '这是第五行歌词' }
])

const currentLyrics = computed(() => {
  if (lyricsMode.value === 'simple') {
    return lyricsData.value.filter(line => line.text.length < 10)
  }
  return lyricsData.value
})

// 推荐歌曲
const recommendedTracks = ref<Track[]>([
  {
    id: 11,
    title: '推荐歌曲1',
    artist: '推荐歌手1',
    album: '推荐专辑1',
    duration: 210,
    cover: '/花君.png',
    url: '',
    isLiked: false
  },
  {
    id: 12,
    title: '推荐歌曲2',
    artist: '推荐歌手2',
    album: '推荐专辑2',
    duration: 195,
    cover: '/花君.png',
    url: '',
    isLiked: true
  },
  {
    id: 13,
    title: '推荐歌曲3',
    artist: '推荐歌手3',
    album: '推荐专辑3',
    duration: 225,
    cover: '/花君.png',
    url: '',
    isLiked: false
  },
  {
    id: 14,
    title: '推荐歌曲4',
    artist: '推荐歌手4',
    album: '推荐专辑4',
    duration: 180,
    cover: '/花君.png',
    url: '',
    isLiked: true
  }
])

// 工具函数
const formatTime = (seconds: number): string => {
  const mins = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

const formatCount = (count: number): string => {
  if (count >= 10000) {
    return `${(count / 10000).toFixed(1)}万`
  }
  return count.toString()
}

// 播放控制方法
const togglePlay = () => {
  playerStore.togglePlay()
}

const playNext = () => {
  playerStore.playNext()
}

const playPrevious = () => {
  playerStore.playPrevious()
}

const togglePlayMode = () => {
  playMode.value = (playMode.value + 1) % 3
}

const handleVolumeChange = (value: number) => {
  playerStore.setVolume(value / 100)
}

const toggleFavorite = () => {
  isFavorite.value = !isFavorite.value
}

const shareTrack = () => {
  console.log('分享歌曲')
}

// 进度条控制
const handleProgressClick = (e: MouseEvent) => {
  if (!progressBar.value) return
  
  const rect = progressBar.value.getBoundingClientRect()
  const clickX = e.clientX - rect.left
  const percent = clickX / rect.width
  const newTime = percent * duration.value
  
  playerStore.setCurrentTime(newTime)
}

// 歌词相关方法
const toggleLyrics = () => {
  showLyrics.value = !showLyrics.value
}

const toggleLyricsMode = () => {
  lyricsMode.value = lyricsMode.value === 'full' ? 'simple' : 'full'
}

const seekToLyric = (time: number) => {
  playerStore.setCurrentTime(time)
}

const isHighlighted = (index: number): boolean => {
  const line = currentLyrics.value[index]
  const nextLine = currentLyrics.value[index + 1]
  return currentTime.value >= line.time && 
         (!nextLine || currentTime.value < nextLine.time)
}

// 更新当前歌词行
const updateCurrentLyricIndex = () => {
  for (let i = currentLyrics.value.length - 1; i >= 0; i--) {
    if (currentTime.value >= currentLyrics.value[i].time) {
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

// 导航方法
const goBack = () => {
  router.go(-1)
}

// 推荐歌曲播放
const playRecommendedTrack = (track: Track) => {
  playerStore.setCurrentTrack(track)
  playerStore.play()
}

// 监听播放时间变化，更新歌词
watch(currentTime, () => {
  updateCurrentLyricIndex()
  scrollToCurrentLyric()
})

onMounted(() => {
  // 模拟播放进度
  const updateTime = () => {
    if (isPlaying.value && currentTime.value < duration.value) {
      currentTime.value += 1
    }
  }
  
  setInterval(updateTime, 1000)
})

onUnmounted(() => {
  // 清理
})
</script>

<style scoped lang="scss">
.player-page-container {
  min-height: calc(100vh - 72px);
  background: #f5f5f5;
  padding: 20px;
  padding-bottom: 100px;
}

.page-header {
  margin-bottom: 20px;

  .back-btn {
    background: #fff;
    border: 1px solid #e8e8e8;
    color: #666;

    &:hover {
      color: #C20C0C;
      border-color: #C20C0C;
    }
  }
}

.player-main {
  display: grid;
  grid-template-columns: 350px 1fr;
  gap: 30px;
  margin-bottom: 30px;
  background: #fff;
  border-radius: 16px;
  padding: 30px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.album-section {
  .album-cover-wrapper {
    position: relative;
    width: 280px;
    height: 280px;
    margin: 0 auto 24px;

    .album-cover {
      width: 100%;
      height: 100%;
      border-radius: 50%;
      object-fit: cover;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
      animation: rotate 20s linear infinite;
      animation-play-state: paused;

      &.rotating {
        animation-play-state: running;
      }
    }

    .vinyl-disc {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      width: 100px;
      height: 100px;
      border: 2px solid rgba(0, 0, 0, 0.1);
      border-radius: 50%;
      background: rgba(0, 0, 0, 0.3);

      &.spinning {
        animation: spin 2s linear infinite;
      }
    }
  }

  .album-actions {
    display: flex;
    justify-content: center;
    gap: 12px;

    .action-btn {
      padding: 10px 20px;
      border-radius: 20px;
      background: #fff;
      border: 1px solid #e8e8e8;
      color: #666;

      &:hover {
        color: #C20C0C;
        border-color: #C20C0C;
      }

      &.el-button--danger {
        background: #C20C0C;
        border-color: #C20C0C;
        color: #fff;

        &:hover {
          background: #a00a0a;
        }
      }
    }
  }
}

.track-section {
  color: #333;

  .track-info {
    margin-bottom: 30px;

    .track-title {
      font-size: 28px;
      font-weight: 600;
      margin: 0 0 10px 0;
      line-height: 1.3;
      color: #333;
    }

    .track-artist {
      font-size: 16px;
      margin: 0 0 6px 0;
      color: #666;
    }

    .track-album {
      font-size: 14px;
      margin: 0 0 16px 0;
      color: #999;
    }

    .track-stats {
      display: flex;
      gap: 20px;

      .stat-item {
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 13px;
        color: #999;
      }
    }
  }

  .player-controls {
    background: #f9f9f9;
    border-radius: 12px;
    padding: 20px;
    margin-bottom: 20px;

    .progress-section {
      margin-bottom: 20px;

      .time-display {
        display: flex;
        justify-content: space-between;
        margin-bottom: 10px;
        font-size: 12px;
        color: #999;
      }

      .progress-bar {
        position: relative;
        height: 4px;
        background: #e8e8e8;
        border-radius: 2px;
        cursor: pointer;

        .progress-fill {
          height: 100%;
          background: #C20C0C;
          border-radius: 2px;
          transition: width 0.1s linear;
        }

        .progress-handle {
          position: absolute;
          top: 50%;
          transform: translate(-50%, -50%);
          width: 12px;
          height: 12px;
          background: #fff;
          border: 2px solid #C20C0C;
          border-radius: 50%;
          box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
      }
    }

    .control-buttons {
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 16px;
      margin-bottom: 20px;

      .el-button {
        width: 40px;
        height: 40px;
        border: 1px solid #e8e8e8;
        background: #fff;
        color: #666;

        &:hover {
          color: #C20C0C;
          border-color: #C20C0C;
        }
      }

      .play-pause-btn {
        width: 56px;
        height: 56px;
        font-size: 20px;
        background: #C20C0C;
        border-color: #C20C0C;
        color: #fff;

        &:hover {
          background: #a00a0a;
        }
      }
    }

    .volume-control {
      display: flex;
      align-items: center;
      gap: 12px;

      .volume-slider {
        flex: 1;

        :deep(.el-slider__runway) {
          height: 4px;
          background: #e8e8e8;
        }

        :deep(.el-slider__bar) {
          height: 4px;
          background: #C20C0C;
        }

        :deep(.el-slider__button) {
          width: 12px;
          height: 12px;
          background: #fff;
          border: 2px solid #C20C0C;
        }
      }

      .volume-text {
        font-size: 12px;
        color: #999;
        min-width: 36px;
      }
    }
  }

  .lyrics-section {
    background: #f9f9f9;
    border-radius: 12px;
    padding: 20px;

    .lyrics-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;

      h3 {
        margin: 0;
        font-size: 16px;
        color: #333;
      }
    }

    .lyrics-content {
      max-height: 300px;
      overflow-y: auto;

      .lyrics-line {
        padding: 10px 0;
        font-size: 14px;
        line-height: 1.6;
        cursor: pointer;
        transition: all 0.3s;
        color: #666;

        &:hover {
          color: #333;
        }

        &.active {
          color: #C20C0C;
          font-size: 16px;
          font-weight: 500;
        }

        &.highlight {
          background: rgba(194, 12, 12, 0.05);
          border-radius: 6px;
          padding: 8px 12px;
          margin: 0 -12px;
        }
      }
    }
  }
}

.recommendations-section {
  background: #fff;
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);

  h3 {
    margin: 0 0 16px 0;
    color: #333;
    font-size: 18px;
    font-weight: 600;
  }

  .recommendations-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
    gap: 12px;

    .recommendation-card {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 12px;
      background: #f9f9f9;
      border-radius: 10px;
      cursor: pointer;
      transition: all 0.3s;

      &:hover {
        background: #f0f0f0;
        transform: translateY(-2px);
      }

      .rec-cover-wrapper {
        position: relative;
        width: 48px;
        height: 48px;
        flex-shrink: 0;
        border-radius: 8px;
        overflow: hidden;
      }

      .rec-cover {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }

      .rec-play-overlay {
        position: absolute;
        inset: 0;
        display: flex;
        align-items: center;
        justify-content: center;
        background: rgba(0,0,0,0.4);
        opacity: 0;
        transition: opacity 0.2s;
      }

      .recommendation-card:hover .rec-play-overlay {
        opacity: 1;
      }

      .rec-play-btn-circle {
        width: 28px;
        height: 28px;
        border-radius: 50%;
        background: var(--play-overlay-btn-bg);
        color: var(--play-overlay-btn-color);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
      }

      .rec-info {
        flex: 1;

        .rec-title {
          font-size: 14px;
          color: #333;
          font-weight: 500;
          margin-bottom: 4px;
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
        }

        .rec-artist {
          font-size: 12px;
          color: #999;
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
        }
      }
    }
  }
}

@keyframes rotate {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

@keyframes spin {
  from {
    transform: translate(-50%, -50%) rotate(0deg);
  }
  to {
    transform: translate(-50%, -50%) rotate(360deg);
  }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .player-page-container {
    padding: 15px;
  }
  
  .player-main {
    grid-template-columns: 1fr;
    gap: 24px;
  }
  
  .album-section {
    .album-cover-wrapper {
      width: 220px;
      height: 220px;
      margin: 0 auto 20px;
    }
    
    .album-actions {
      justify-content: center;
      gap: 12px;
    }
  }
  
  .track-section {
    .track-info {
      text-align: center;
      margin-bottom: 24px;
      
      .track-title {
        font-size: 22px;
        margin-bottom: 8px;
      }
      
      .track-artist {
        font-size: 15px;
        margin-bottom: 4px;
      }
      
      .track-album {
        font-size: 13px;
        margin-bottom: 12px;
      }
      
      .track-stats {
        justify-content: center;
        gap: 16px;
      }
    }
    
    .lyrics-section .lyrics-content {
      max-height: 200px;
    }
  }
  
  .recommendations-section {
    .recommendations-grid {
      grid-template-columns: 1fr;
    }
  }
}

@media (max-width: 480px) {
  .player-page-container {
    padding: 10px;
  }
  
  .player-main {
    padding: 20px;
    gap: 20px;
  }
  
  .page-header {
    margin-bottom: 16px;
    
    .back-btn {
      padding: 8px 12px;
      font-size: 14px;
    }
  }
  
  .album-section {
    .album-cover-wrapper {
      width: 180px;
      height: 180px;
    }
    
    .album-actions {
      flex-direction: column;
      gap: 8px;
      align-items: center;
      
      .action-btn {
        min-width: 120px;
        width: 120px;
      }
    }
  }
  
  .track-section {
    .track-info {
      .track-title {
        font-size: 18px;
      }
      
      .track-artist {
        font-size: 14px;
      }
      
      .track-album {
        font-size: 12px;
      }
      
      .track-stats {
        flex-direction: column;
        gap: 8px;
      }
    }
    
    .player-controls .control-buttons {
      gap: 12px;
      
      .el-button {
        width: 36px;
        height: 36px;
      }
      
      .play-pause-btn {
        width: 48px;
        height: 48px;
      }
    }
  }
}
</style>