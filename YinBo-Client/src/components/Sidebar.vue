<template>
  <div class="sidebar-container" :class="{ collapsed: collapsed }" :style="{ width: collapsed ? '0px' : sidebarWidth + 'px' }">
    <div class="sidebar-content" :class="{ hidden: collapsed }">
      <!-- Logo区域 -->
      <div class="logo-section">
        <div class="logo-content">
          <div class="logo-icon">
            <svg viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z"/>
            </svg>
          </div>
          <span class="logo-text">音波音乐</span>
        </div>
      </div>

      <!-- 导航菜单 -->
      <div class="nav-section">
      <el-collapse v-model="activeNames" class="nav-collapse">
        <el-collapse-item name="myMusic">
          <template #title>
            <div class="collapse-header">
              <el-icon><Collection /></el-icon>
              <span>我的音乐</span>
            </div>
          </template>
          <div class="nav-item" :class="{ active: activeItem === 'favorites' }" @click="activeItem = 'favorites'">
            <el-icon><Star /></el-icon>
            <span>我喜欢的音乐</span>
            <div class="song-count">{{ favoritesCount }}首</div>
          </div>
          <div class="nav-item" :class="{ active: activeItem === 'artists' }" @click="activeItem = 'artists'">
            <el-icon><User /></el-icon>
            <span>我关注的歌手</span>
            <div class="song-count">{{ artistCount }}位</div>
          </div>
        </el-collapse-item>
      </el-collapse>
    </div>

    <!-- 创建的歌单区域 -->
    <div class="playlist-section">
      <div class="section-header">
        <h3>我创建的歌单 ({{ createdPlaylists.length }})</h3>
        <el-button type="text" class="add-playlist-btn" @click="showCreateDialog = true">
          <el-icon><Plus /></el-icon>
        </el-button>
      </div>
      
      <div class="playlist-list">
        <div
          v-for="playlist in displayedPlaylists"
          :key="playlist.id"
          class="playlist-item"
          :class="{ active: selectedPlaylistId === playlist.id }"
          @click="selectPlaylist(playlist.id)"
        >
          <div class="playlist-cover">
            <img :src="playlist.cover" :alt="playlist.name" @error="handleImageError" />
            <div class="play-overlay">
              <el-icon class="play-icon"><VideoPlay /></el-icon>
            </div>
          </div>
          <div class="playlist-info">
            <div class="playlist-name">{{ playlist.name }}</div>
            <div class="playlist-meta">
              <span>{{ playlist.trackCount }}首</span>
              <span>{{ playlist.playCount }}次播放</span>
            </div>
          </div>
        </div>
        
        <div v-if="hasMorePlaylists" class="playlist-item more" @click="togglePlaylistsExpand">
          <el-icon><component :is="isPlaylistsExpanded ? 'ArrowUp' : 'MoreFilled'" /></el-icon>
          <span>{{ isPlaylistsExpanded ? '收起歌单' : '加载更多歌单' }}</span>
        </div>
      </div>
    </div>

    <!-- 最近播放 -->
    <div class="recent-section">
      <div class="section-header">
        <h3>最近播放</h3>
        <el-button type="text" @click="clearRecentPlay">
          <el-icon><Delete /></el-icon>
        </el-button>
      </div>
      
      <div class="recent-list">
        <div
          v-for="item in displayedRecentPlayed"
          :key="`${item.type}-${item.id}`"
          class="recent-item"
          @click="playRecentItem(item)"
        >
          <div class="recent-cover">
            <img :src="item.cover" :alt="item.name" @error="handleImageError" />
          </div>
          <div class="recent-info">
            <div class="recent-name">{{ item.name }}</div>
            <div class="recent-artist">{{ item.artist }}</div>
          </div>
          <div class="recent-time">{{ formatTime(item.playTime) }}</div>
        </div>
        
        <div v-if="hasMoreRecent" class="recent-item more" @click="toggleRecentExpand">
          <el-icon><component :is="isRecentExpanded ? 'ArrowUp' : 'MoreFilled'" /></el-icon>
          <span>{{ isRecentExpanded ? '收起列表' : '加载更多' }}</span>
        </div>
      </div>
    </div>

    <!-- 底部提示 -->
    <div class="scroll-bottom-tip" v-if="isAtBottom">
      <span>已经在底部了哦 ~</span>
    </div>
    </div>

    <!-- 创建歌单对话框 -->
    <el-dialog v-model="showCreateDialog" title="创建新歌单" width="400px">
      <el-form :model="newPlaylistForm" label-width="80px">
        <el-form-item label="歌单名称">
          <el-input v-model="newPlaylistForm.name" placeholder="请输入歌单名称"></el-input>
        </el-form-item>
        <el-form-item label="描述">
          <el-input 
            v-model="newPlaylistForm.description" 
            type="textarea" 
            :rows="3"
            placeholder="请输入歌单描述（可选）"
          ></el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showCreateDialog = false">取消</el-button>
          <el-button type="primary" @click="createPlaylist">创建</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, onUnmounted } from 'vue'
import {
  Star,
  Headset,
  User,
  FolderOpened,
  MoreFilled,
  CollectionTag,
  Collection,
  Plus,
  VideoPlay,
  Delete,
  ArrowUp
} from '@element-plus/icons-vue'

interface Playlist {
  id: number
  name: string
  cover: string
  trackCount: number
  playCount: number
}

interface RecentItem {
  type: 'song' | 'playlist' | 'album'
  id: number
  name: string
  artist?: string
  cover: string
  playTime: Date
}

const props = defineProps<{
  width?: number
  collapsed?: boolean
}>()

const emit = defineEmits<{
  (e: 'selectPlaylist', id: number): void
  (e: 'playItem', item: RecentItem): void
}>()

const sidebarWidth = computed(() => props.width || 250)

const activeNames = ref<string[]>(['myMusic'])
const activeItem = ref<string>('')
const selectedPlaylistId = ref<number | null>(null)
const showCreateDialog = ref(false)
const isAtBottom = ref(false)

const favoritesCount = ref(666)
const historyCount = ref(1234)
const artistCount = ref(28)

const newPlaylistForm = reactive({
  name: '',
  description: ''
})

const createdPlaylists = ref<Playlist[]>([
  { id: 1, name: '工作时的背景音乐', cover: 'https://picsum.photos/seed/music1/60/60', trackCount: 88, playCount: 5200 },
  { id: 2, name: '跑步健身专用', cover: 'https://picsum.photos/seed/music2/60/60', trackCount: 156, playCount: 12500 },
  { id: 3, name: '睡前放松', cover: 'https://picsum.photos/seed/music3/60/60', trackCount: 45, playCount: 3200 },
  { id: 4, name: '周末party', cover: 'https://picsum.photos/seed/music4/60/60', trackCount: 200, playCount: 8900 },
  { id: 5, name: '中文经典', cover: 'https://picsum.photos/seed/music5/60/60', trackCount: 320, playCount: 25000 },
  { id: 6, name: '欧美流行', cover: 'https://picsum.photos/seed/music6/60/60', trackCount: 180, playCount: 15000 },
  { id: 7, name: '轻音乐', cover: 'https://picsum.photos/seed/music7/60/60', trackCount: 95, playCount: 8800 },
  { id: 8, name: '民谣精选', cover: 'https://picsum.photos/seed/music8/60/60', trackCount: 120, playCount: 9500 }
])

// 歌单展开状态
const isPlaylistsExpanded = ref(false)
const defaultShowCount = 6

// 当前显示的歌单
const displayedPlaylists = computed(() => {
  if (isPlaylistsExpanded.value) {
    return createdPlaylists.value
  }
  return createdPlaylists.value.slice(0, defaultShowCount)
})

// 是否有更多歌单
const hasMorePlaylists = computed(() => createdPlaylists.value.length > defaultShowCount)

// 切换歌单展开状态
const togglePlaylistsExpand = () => {
  isPlaylistsExpanded.value = !isPlaylistsExpanded.value
}

const recentPlayed = ref<RecentItem[]>([
  { type: 'song', id: 1, name: '平凡之路', artist: '朴树', cover: 'https://picsum.photos/seed/song1/50/50', playTime: new Date(Date.now() - 1000 * 60 * 5) },
  { type: 'playlist', id: 2, name: '华语经典', cover: 'https://picsum.photos/seed/playlist1/50/50', playTime: new Date(Date.now() - 1000 * 60 * 15) },
  { type: 'song', id: 3, name: '演员', artist: '薛之谦', cover: 'https://picsum.photos/seed/song2/50/50', playTime: new Date(Date.now() - 1000 * 60 * 30) },
  { type: 'song', id: 4, name: '晴天', artist: '周杰伦', cover: 'https://picsum.photos/seed/song3/50/50', playTime: new Date(Date.now() - 1000 * 60 * 60) },
  { type: 'album', id: 5, name: '七里香', cover: 'https://picsum.photos/seed/album1/50/50', playTime: new Date(Date.now() - 1000 * 60 * 120) },
  { type: 'song', id: 6, name: '夜曲', artist: '周杰伦', cover: 'https://picsum.photos/seed/song6/50/50', playTime: new Date(Date.now() - 1000 * 60 * 180) },
  { type: 'song', id: 7, name: '稻香', artist: '周杰伦', cover: 'https://picsum.photos/seed/song7/50/50', playTime: new Date(Date.now() - 1000 * 60 * 240) },
  { type: 'playlist', id: 8, name: '深夜情歌', cover: 'https://picsum.photos/seed/playlist2/50/50', playTime: new Date(Date.now() - 1000 * 60 * 300) }
])

// 最近播放展开状态
const isRecentExpanded = ref(false)
const defaultRecentShowCount = 6

// 当前显示的最近播放
const displayedRecentPlayed = computed(() => {
  if (isRecentExpanded.value) {
    return recentPlayed.value
  }
  return recentPlayed.value.slice(0, defaultRecentShowCount)
})

// 是否有更多最近播放
const hasMoreRecent = computed(() => recentPlayed.value.length > defaultRecentShowCount)

// 切换最近播放展开状态
const toggleRecentExpand = () => {
  isRecentExpanded.value = !isRecentExpanded.value
}

const selectPlaylist = (id: number) => {
  selectedPlaylistId.value = id
  emit('selectPlaylist', id)
}

const createPlaylist = () => {
  if (newPlaylistForm.name.trim()) {
    const newId = createdPlaylists.value.length + 1
    createdPlaylists.value.push({
      id: newId,
      name: newPlaylistForm.name,
      cover: `https://picsum.photos/seed/playlist${newId}/60/60`,
      trackCount: 0,
      playCount: 0
    })
    newPlaylistForm.name = ''
    newPlaylistForm.description = ''
    showCreateDialog.value = false
  }
}

const clearRecentPlay = () => {
  recentPlayed.value = []
}

const playRecentItem = (item: RecentItem) => {
  emit('playItem', item)
}

const formatTime = (date: Date): string => {
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  const minutes = Math.floor(diff / 60000)
  
  if (minutes < 60) {
    return `${minutes}分钟前`
  } else if (minutes < 1440) {
    return `${Math.floor(minutes / 60)}小时前`
  } else {
    return `${Math.floor(minutes / 1440)}天前`
  }
}

const handleImageError = (e: Event) => {
  const img = e.target as HTMLImageElement
  img.src = 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="60" height="60" viewBox="0 0 60 60"><rect fill="%23333" width="60" height="60"/><text fill="%23666" font-size="12" x="50%" y="50%" text-anchor="middle" dy=".3em">音乐</text></svg>'
}

// 滚动监听
const handleScroll = (e: Event) => {
  const target = e.target as HTMLElement
  const { scrollTop, scrollHeight, clientHeight } = target
  // 距离底部 10px 以内时显示提示
  isAtBottom.value = scrollHeight - scrollTop - clientHeight < 10
}

// 添加滚动监听
onMounted(() => {
  const sidebarContent = document.querySelector('.sidebar-content')
  if (sidebarContent) {
    sidebarContent.addEventListener('scroll', handleScroll)
  }
})

// 移除滚动监听
onUnmounted(() => {
  const sidebarContent = document.querySelector('.sidebar-content')
  if (sidebarContent) {
    sidebarContent.removeEventListener('scroll', handleScroll)
  }
})
</script>

<style scoped lang="scss">
.sidebar-container {
  background: #2C2C2C;
  border-right: 1px solid #1a1a1a;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  flex-shrink: 0;
  transition: width 0.3s ease;

  &.collapsed {
    border-right: none;
  }
}

.sidebar-content {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
  overflow-x: hidden;
  transition: opacity 0.3s ease;

  &.hidden {
    opacity: 0;
    pointer-events: none;
  }

  // 自定义滚动条样式
  &::-webkit-scrollbar {
    width: 4px;
  }

  &::-webkit-scrollbar-track {
    background: transparent;
  }

  &::-webkit-scrollbar-thumb {
    background: rgba(255, 255, 255, 0.2);
    border-radius: 2px;

    &:hover {
      background: rgba(255, 255, 255, 0.3);
    }
  }
}

.logo-section {
  display: flex;
  justify-content: center;
  padding: 24px 15px;
  border-bottom: 1px solid #3a3a3a;
  background: linear-gradient(180deg, rgba(194, 12, 12, 0.1) 0%, transparent 100%);

  .logo-content {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .logo-icon {
    width: 32px;
    height: 32px;
    color: #C20C0C;

    svg {
      width: 100%;
      height: 100%;
    }
  }

  .logo-text {
    font-size: 20px;
    font-weight: 600;
    color: #fff;
    letter-spacing: 2px;
  }
}

.nav-section {
  padding: 15px 10px;

  .section-title {
    margin: 0 0 10px 10px;
    font-size: 12px;
    color: #888;
    font-weight: normal;
  }
}

.nav-item, .playlist-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 15px;
  margin: 5px 0;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s ease;
  color: #bbb;
  font-size: 14px;

  &:hover {
    background: #3d3d3d;
    color: #fff;
  }

  &.active {
    background: linear-gradient(90deg, rgba(194, 12, 12, 0.2) 0%, transparent 100%);
    color: #fff;
    border-left: 3px solid #C20C0C;
    padding-left: 12px;
  }

  .el-icon {
    font-size: 16px;
    color: inherit;
    flex-shrink: 0;
  }

  .song-count {
    margin-left: auto;
    font-size: 12px;
    color: #666;
  }
}

.playlist-section {
  padding: 15px 10px;
  border-top: 1px solid #3a3a3a;

  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 5px;

    h3 {
      margin: 0;
      font-size: 13px;
      color: #888;
      font-weight: normal;
    }

    .add-playlist-btn {
      color: #888;
      font-size: 16px;
      padding: 4px;

      &:hover {
        color: #C20C0C;
        background: transparent;
      }
    }
  }
}

.playlist-list {
  .playlist-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 8px 10px;
    margin: 4px 0;
    border-radius: 6px;
    cursor: pointer;
    transition: all 0.2s ease;

    &:hover {
      background: #3a3a3a;

      .play-overlay {
        opacity: 1;
      }
    }

    &.active {
      background: linear-gradient(90deg, rgba(194, 12, 12, 0.15) 0%, transparent 100%);

      .playlist-name {
        color: #C20C0C;
      }
    }

    &.more {
      color: #888;
      justify-content: center;
      gap: 6px;

      .el-icon {
        font-size: 14px;
      }

      span {
        font-size: 13px;
      }

      &:hover {
        color: #C20C0C;
        background: rgba(194, 12, 12, 0.1);
      }
    }
  }

  .playlist-cover {
    position: relative;
    width: 50px;
    height: 50px;
    border-radius: 6px;
    overflow: hidden;
    flex-shrink: 0;

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .play-overlay {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0, 0, 0, 0.5);
      display: flex;
      align-items: center;
      justify-content: center;
      opacity: 0;
      transition: opacity 0.2s ease;

      .play-icon {
        font-size: 20px;
        color: #fff;
      }
    }
  }

  .playlist-info {
    flex: 1;
    min-width: 0;
    overflow: hidden;

    .playlist-name {
      font-size: 14px;
      color: #ddd;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .playlist-meta {
      display: flex;
      gap: 10px;
      margin-top: 4px;
      font-size: 12px;
      color: #666;
    }
  }
}

.recent-section {
  padding: 15px 10px;
  border-top: 1px solid #3a3a3a;

  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 5px;

    h3 {
      margin: 0;
      font-size: 13px;
      color: #888;
      font-weight: normal;
    }

    .el-button {
      color: #666;
      padding: 4px;

      &:hover {
        color: #C20C0C;
        background: transparent;
      }
    }
  }

  .recent-list {
    .recent-item {
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 8px 10px;
      margin: 4px 0;
      border-radius: 6px;
      cursor: pointer;
      transition: all 0.2s ease;

      &:hover {
        background: #3a3a3a;

        .recent-name {
          color: #C20C0C;
        }
      }

      &.more {
        color: #888;
        justify-content: center;
        gap: 6px;

        .el-icon {
          font-size: 14px;
        }

        span {
          font-size: 13px;
        }

        &:hover {
          color: #C20C0C;
          background: rgba(194, 12, 12, 0.1);
        }
      }
    }

    .recent-cover {
      width: 40px;
      height: 40px;
      border-radius: 4px;
      overflow: hidden;
      flex-shrink: 0;

      img {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }
    }

    .recent-info {
      flex: 1;
      min-width: 0;
      overflow: hidden;

      .recent-name {
        font-size: 13px;
        color: #ddd;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        transition: color 0.2s ease;
      }

      .recent-artist {
        font-size: 12px;
        color: #666;
        margin-top: 2px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
    }

    .recent-time {
      font-size: 11px;
      color: #555;
      flex-shrink: 0;
    }
  }
}

.collapse-header {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #bbb;

  .el-icon {
    font-size: 16px;
  }
}

:deep(.el-collapse) {
  border: none;
}

:deep(.el-collapse-item__header) {
  background: transparent;
  border: none;
  padding: 8px 10px;
  font-size: 14px;
  color: #bbb;
  height: auto;
  line-height: inherit;

  &:hover {
    background: transparent;
    color: #fff;
  }

  .el-collapse-item__arrow {
    color: #666;
  }
}

:deep(.el-collapse-item__wrap) {
  background: transparent;
  border: none;
}

:deep(.el-collapse-item__content) {
  padding-bottom: 0;
  padding-left: 10px;
}

:deep(.el-dialog) {
  background: #2C2C2C;
  border-radius: 8px;

  .el-dialog__header {
    border-bottom: 1px solid #3a3a3a;
    padding-bottom: 15px;
  }

  .el-dialog__title {
    color: #fff;
  }

  .el-dialog__body {
    padding: 20px;
  }

  .el-dialog__footer {
    border-top: 1px solid #3a3a3a;
    padding-top: 15px;
  }
}

:deep(.el-form-item__label) {
  color: #bbb;
}

:deep(.el-input__wrapper) {
  background: #3a3a3a;
  box-shadow: none;
  border: 1px solid #4a4a4a;

  &:hover {
    border-color: #C20C0C;
  }

  &.is-focus {
    border-color: #C20C0C;
  }
}

:deep(.el-textarea__inner) {
  background: #3a3a3a;
  border: 1px solid #4a4a4a;
  color: #fff;

  &:hover, &:focus {
    border-color: #C20C0C;
  }
}

:deep(.el-button--primary) {
  background: #C20C0C;
  border-color: #C20C0C;

  &:hover {
    background: #A30A0A;
    border-color: #A30A0A;
  }
}

:deep(.el-button--default) {
  background: transparent;
  border-color: #4a4a4a;
  color: #bbb;

  &:hover {
    border-color: #C20C0C;
    color: #C20C0C;
  }
}

// 底部提示样式
.scroll-bottom-tip {
  padding: 20px 15px;
  text-align: center;
  color: #666;
  font-size: 13px;
  background: linear-gradient(180deg, transparent 0%, rgba(194, 12, 12, 0.05) 100%);
  border-top: 1px solid #3a3a3a;
  margin-top: 10px;
  animation: fadeIn 0.3s ease;

  span {
    display: inline-block;
    padding: 8px 16px;
    background: rgba(255, 255, 255, 0.05);
    border-radius: 20px;
    color: #888;
  }
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@media (max-width: 768px) {
  .sidebar-container {
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    z-index: 100;
    transform: translateX(-100%);
    transition: transform 0.3s ease;
  }

  .sidebar-container.open {
    transform: translateX(0);
  }

  .logo-section {
    padding: 15px 10px;
  }

  .recent-section {
    display: none;
  }
}
</style>