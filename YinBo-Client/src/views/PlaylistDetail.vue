<template>
  <div class="playlist-detail-page">
    <div class="playlist-detail-sticky">
    <!-- 顶部导航 -->
    <div class="top-bar">
      <button class="back-btn" @click="goBack">
        <svg viewBox="0 0 24 24" width="20" height="20">
          <path fill="currentColor" d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"/>
        </svg>
      </button>
      <span class="page-title">歌单详情</span>
      <!-- 批量操作按钮 -->
      <div v-if="isOwner && tracks.length > 0" class="batch-actions">
        <button v-if="!isBatchMode" class="batch-btn" @click="enterBatchMode">
          <svg viewBox="0 0 24 24" width="16" height="16">
            <path fill="currentColor" d="M3 5h2V3c-1.1 0-2 .9-2 2zm0 8h2v-2H3v2zm4 8h2v-2H7v2zM3 9h2V7H3v2zm10-6h-2v2h2V3zm6 0v2h2c0-1.1-.9-2-2-2zM5 21v-2H3c0 1.1.9 2 2 2zm-2-4h2v-2H3v2zM9 3H7v2h2V3zm2 18h2v-2h-2v2zm8-8h2v-2h-2v2zm0 8c1.1 0 2-.9 2-2h-2v2zm0-12h2V7h-2v2zm0 8h2v-2h-2v2zm-4 4h2v-2h-2v2zm0-16h2V3h-2v2zM7 17h10V7H7v10zm2-8h6v6H9V9z"/>
          </svg>
          管理
        </button>
        <template v-else>
          <button class="batch-btn select-all-btn" @click="toggleSelectAll">
            <svg viewBox="0 0 24 24" width="16" height="16">
              <path fill="currentColor" :d="isAllSelected ? 'M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-9 14l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z' : 'M19 5v14H5V5h14m0-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2z'"/>
            </svg>
            {{ isAllSelected ? '取消全选' : '全选' }}
          </button>
          <button class="batch-btn delete-btn" :disabled="selectedTrackIds.length === 0" @click="batchRemove">
            <svg viewBox="0 0 24 24" width="16" height="16">
              <path fill="currentColor" d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/>
            </svg>
            删除({{ selectedTrackIds.length }})
          </button>
          <button class="batch-btn transfer-btn" :disabled="selectedTrackIds.length === 0" @click="showTransferModal = true">
            <svg viewBox="0 0 24 24" width="16" height="16">
              <path fill="currentColor" d="M12 4l-1.41 1.41L16.17 11H4v2h12.17l-5.58 5.59L12 20l8-8z"/>
            </svg>
            移动({{ selectedTrackIds.length }})
          </button>
          <button class="batch-btn cancel-btn" @click="exitBatchMode">取消</button>
        </template>
      </div>
    </div>

    <!-- 歌单信息 -->
    <div class="playlist-header">
      <div class="cover-wrapper" @click="isOwner && openCoverUpload()">
        <img :src="playlist?.coverUrl || defaultCover" alt="封面" class="cover" />
        <div v-if="isOwner" class="cover-edit-mask">
          <svg viewBox="0 0 24 24" width="24" height="24">
            <path fill="currentColor" d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/>
          </svg>
          <span>更换封面</span>
        </div>
        <input type="file" ref="coverInputRef" accept="image/*" @change="handleCoverSelect" style="display: none" />
      </div>
      <div class="info">
        <h1 class="playlist-name" @click="isOwner && startEditName()">
          <span v-if="!editingName">{{ playlist?.name || '歌单' }}</span>
          <input v-else ref="nameInputRef" v-model="editName" type="text" class="inline-edit-input" 
            @blur="saveName" @keyup.enter="saveName" @click.stop placeholder="请输入歌单名称" />
          <svg v-if="isOwner && !editingName" class="edit-icon" viewBox="0 0 24 24" width="18" height="18">
            <path fill="currentColor" d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/>
          </svg>
        </h1>
        <div class="creator-info">
          <img :src="creatorAvatar" alt="头像" class="creator-avatar" />
          <span class="creator-name">{{ creatorName }}</span>
          <span class="create-time">{{ formatCreateTime(playlist?.createdAt) }} 创建</span>
        </div>
        <div class="description" @click="isOwner && startEditDescription()">
          <template v-if="!editingDescription">
            <span>{{ playlist?.description || '暂无描述' }}</span>
            <svg v-if="isOwner" class="edit-icon-small" viewBox="0 0 24 24" width="14" height="14">
              <path fill="currentColor" d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/>
            </svg>
          </template>
          <textarea v-else ref="descInputRef" v-model="editDescription" class="inline-edit-textarea"
            @blur="saveDescription" @click.stop rows="2" placeholder="请输入歌单描述"></textarea>
        </div>
        <div class="stats">
          <span class="track-count">歌曲 {{ playlist?.trackCount || 0 }}</span>
        </div>
        <div class="actions">
          <button class="play-all-btn" @click="playAll">
            <svg viewBox="0 0 24 24" width="20" height="20">
              <path fill="currentColor" d="M8 5v14l11-7z"/>
            </svg>
            播放全部
          </button>
          <button v-if="isOwner" class="edit-info-btn" @click="startEditName" title="编辑歌单名称、描述，点击封面可更换">
            <svg viewBox="0 0 24 24" width="18" height="18">
              <path fill="currentColor" d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/>
            </svg>
            编辑信息
          </button>
          <button v-if="isOwner" class="delete-btn" @click="deletePlaylist">
            <svg viewBox="0 0 24 24" width="18" height="18">
              <path fill="currentColor" d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/>
            </svg>
            删除歌单
          </button>
        </div>
      </div>
    </div>
    </div>

    <!-- 仅歌曲列表滚动 -->
    <div class="playlist-detail-scroll">
    <div class="track-list">
      <div 
        v-for="(track, index) in tracks" 
        :key="track.id" 
        class="track-row"
        :class="{ selected: selectedTrackIds.includes(track.id) }"
        @click="handleTrackClick(track, $event)"
      >
        <span class="col-first">
          <input v-if="isBatchMode" type="checkbox" :checked="selectedTrackIds.includes(track.id)" @click.stop="toggleTrackSelection(track.id)" />
          <span v-else class="index">{{ index + 1 }}</span>
        </span>
        <div class="row-cover-wrapper">
          <img :src="track.coverUrl || defaultCover" alt="封面" class="row-cover" />
          <div class="row-play-overlay">
            <div class="row-play-btn">
              <svg viewBox="0 0 24 24" width="18" height="18">
                <path fill="currentColor" d="M8 5v14l11-7z"/>
              </svg>
            </div>
          </div>
        </div>
        <div class="row-info">
          <span class="title">{{ track.title }}</span>
          <span class="artist"><ArtistLink :artist-id="track.artistId" :artist-name="track.artist" /></span>
        </div>
        <span class="duration">{{ formatDuration(track.duration) }}</span>
        <div v-if="!isBatchMode" class="row-controls">
          <button class="ctrl-btn" title="添加到歌单" @click.stop="showAddToPlaylist(track)">
            <svg viewBox="0 0 24 24" width="16" height="16">
              <path fill="currentColor" d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
            </svg>
          </button>
          <button class="ctrl-btn comment-btn" title="查看评论" @click.stop="goToComments(track)">
            <svg viewBox="0 0 24 24" width="16" height="16">
              <path fill="currentColor" d="M21 6h-2v9H6v2c0 .55.45 1 1 1h11l4 4V7c0-.55-.45-1-1-1zm-4 6V3c0-.55-.45-1-1-1H3c-.55 0-1 .45-1 1v14l4-4h10c.55 0 1-.45 1-1z"/>
            </svg>
          </button>
          <button 
            class="ctrl-btn like-btn" 
            :class="{ liked: isFavorite(track.id) }"
            :title="isFavorite(track.id) ? '取消收藏' : '收藏'"
            @click.stop="toggleFavorite(track)"
          >
            <svg viewBox="0 0 24 24" width="16" height="16">
              <path v-if="isFavorite(track.id)" fill="currentColor" d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
              <path v-else fill="currentColor" d="M16.5 3c-1.74 0-3.41.81-4.5 2.09C10.91 3.81 9.24 3 7.5 3 4.42 3 2 5.42 2 8.5c0 3.78 3.4 6.86 8.55 11.54L12 21.35l1.45-1.32C18.6 15.36 22 12.28 22 8.5 22 5.42 19.58 3 16.5 3zm-4.4 15.55l-.1.1-.1-.1C7.14 14.24 4 11.39 4 8.5 4 6.5 5.5 5 7.5 5c1.54 0 3.04.99 3.57 2.36h1.87C13.46 5.99 14.96 5 16.5 5c2 0 3.5 1.5 3.5 3.5 0 2.89-3.14 5.74-7.9 10.05z"/>
            </svg>
          </button>
          <button v-if="isOwner" class="ctrl-btn remove-btn" title="从歌单移除" @click.stop="removeTrack(track.id)">
            <svg viewBox="0 0 24 24" width="16" height="16">
              <path fill="currentColor" d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
            </svg>
          </button>
        </div>
      </div>
      
      <div v-if="tracks.length === 0" class="empty">
        <svg viewBox="0 0 24 24" width="48" height="48">
          <path fill="currentColor" d="M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z"/>
        </svg>
        <p>歌单暂无歌曲</p>
      </div>
    </div>
    </div>

    <!-- 转移到其他歌单弹窗 -->
    <el-dialog
      v-model="showTransferModal"
      title="转移到其他歌单"
      width="400px"
      class="dark-dialog"
      modal-class="dark-modal"
    >
      <div class="transfer-list">
        <div 
          v-for="pl in otherPlaylists" 
          :key="pl.id" 
          class="transfer-item"
          :class="{ selected: targetPlaylistId === pl.id }"
          @click="targetPlaylistId = pl.id"
        >
          <img :src="pl.coverUrl || defaultCover" alt="封面" class="transfer-cover" />
          <div class="transfer-info">
            <span class="transfer-name">{{ pl.name }}</span>
            <span class="transfer-count">{{ pl.trackCount || 0 }} 首歌曲</span>
          </div>
          <svg v-if="targetPlaylistId === pl.id" viewBox="0 0 24 24" width="20" height="20" class="check-icon">
            <path fill="currentColor" d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
          </svg>
        </div>
        <div v-if="otherPlaylists.length === 0" class="no-playlist">
          <p>暂无其他歌单</p>
        </div>
      </div>
      <template #footer>
        <div class="dialog-footer-btns">
          <button class="btn-cancel" @click="showTransferModal = false">取消</button>
          <button class="btn-create" :disabled="!targetPlaylistId" @click="transferTracks">确认转移</button>
        </div>
      </template>
    </el-dialog>

    <!-- 封面裁剪弹窗 -->
    <CoverCropper
      v-model="showCoverCropper"
      :image-url="coverCropperImageUrl"
      @confirm="handleCoverCropConfirm"
    />

    <!-- 添加到歌单弹窗 -->
    <el-dialog
      v-model="showAddToPlaylistDialog"
      title="添加到歌单"
      width="400px"
      :close-on-click-modal="false"
      class="dark-dialog"
      modal-class="dark-modal"
    >
      <div class="add-to-playlist-content">
        <div v-if="selectedTrack" class="selected-track-info">
          <img :src="selectedTrack.coverUrl || defaultCover" alt="封面" class="track-cover-small" />
          <div class="track-text">
            <span class="track-title">{{ selectedTrack.title }}</span>
            <span class="track-artist"><ArtistLink :artist-id="selectedTrack.artistId" :artist-name="selectedTrack.artist" /></span>
          </div>
        </div>
        <div class="playlist-options">
          <div class="playlist-option-header">选择歌单</div>
          <div 
            v-for="pl in addToPlaylistOptions" 
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
          <div v-if="addToPlaylistOptions.length === 0" class="no-playlists">
            暂无其他歌单，请先创建
          </div>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import { usePlayerStore } from '../stores/player'
import { playlistApi, favoriteApi } from '../api'
import { ElMessage } from 'element-plus'
// @ts-ignore
import CoverCropper from '../components/CoverCropper.vue'
import ArtistLink from '../components/ArtistLink.vue'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const playerStore = usePlayerStore()

import { DEFAULT_AVATAR_COVER } from '../constants'
const defaultCover = DEFAULT_AVATAR_COVER
const defaultAvatar = DEFAULT_AVATAR_COVER

// 歌单数据
const playlist = ref<any>(null)
const tracks = ref<any[]>([])
const favorites = ref<number[]>([])

// 批量操作
const isBatchMode = ref(false)
const selectedTrackIds = ref<number[]>([])

// 编辑状态
const editingName = ref(false)
const editingDescription = ref(false)
const editName = ref('')
const editDescription = ref('')
const nameInputRef = ref<HTMLInputElement | null>(null)
const descInputRef = ref<HTMLTextAreaElement | null>(null)

// 封面上传与裁剪
const coverInputRef = ref<HTMLInputElement | null>(null)
const showCoverCropper = ref(false)
const coverCropperImageUrl = ref('')

// 转移弹窗
const showTransferModal = ref(false)
const targetPlaylistId = ref<number | null>(null)

// 添加到歌单弹窗
const showAddToPlaylistDialog = ref(false)
const selectedTrack = ref<any>(null)
const addToPlaylistLoading = ref(false)

// 计算属性
const isOwner = computed(() => playlist.value?.ownerId === userStore.currentUser?.id)

const creatorName = computed(() => {
  if (isOwner.value) {
    const user = userStore.currentUser
    return user?.username || '我'
  }
  return playlist.value?.ownerName || playlist.value?.userName || playlist.value?.userNickname || '未知用户'
})

const creatorAvatar = computed(() => {
  if (isOwner.value) {
    return userStore.currentUser?.avatar || defaultAvatar
  }
  return playlist.value?.userAvatar || defaultAvatar
})

const isAllSelected = computed(() => {
  return tracks.value.length > 0 && selectedTrackIds.value.length === tracks.value.length
})

const otherPlaylists = computed(() => {
  return userStore.myPlaylists.filter((p: any) => p.id !== Number(route.params.id))
})

// 添加到歌单时排除当前歌单
const addToPlaylistOptions = computed(() => {
  return userStore.myPlaylists.filter((p: any) => p.id !== Number(route.params.id))
})

// 监听路由参数变化
watch(() => route.params.id, (newId) => {
  if (newId) {
    loadPlaylist()
    loadTracks()
  }
})

// 方法
const goBack = () => {
  router.back()
}

const formatCreateTime = (date: string) => {
  if (!date) return ''
  const d = new Date(date)
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

const formatDuration = (seconds: number) => {
  if (!seconds) return '-'
  const mins = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

// 加载数据
const loadPlaylist = async () => {
  const id = route.params.id
  if (!id) return
  
  try {
    const res = await playlistApi.getDetail(Number(id))
    if (res.data.code === 200) {
      playlist.value = res.data.data
      editName.value = playlist.value?.name || ''
      editDescription.value = playlist.value?.description || ''
    }
  } catch (e) {
    console.error('Failed to load playlist:', e)
  }
}

const loadTracks = async () => {
  const id = route.params.id
  if (!id) return
  
  try {
    const res = await playlistApi.getTracks(Number(id))
    if (res.data.code === 200) {
      const data = res.data.data
      tracks.value = Array.isArray(data) ? data : data.records || []
    }
  } catch (e) {
    console.error('Failed to load tracks:', e)
  }
}

const loadFavorites = async () => {
  try {
    const res = await favoriteApi.getMyFavorites(1, 1000)
    if (res.data.code === 200) {
      const data = res.data.data
      const list = Array.isArray(data) ? data : data.records || []
      favorites.value = list.map((item: any) => item.id)
    }
  } catch (e) {
    console.error('Failed to load favorites:', e)
  }
}

const isFavorite = (trackId: number) => favorites.value.includes(trackId)

const toggleFavorite = async (track: any) => {
  try {
    if (isFavorite(track.id)) {
      await favoriteApi.remove(track.id)
      favorites.value = favorites.value.filter(id => id !== track.id)
      ElMessage.success('已取消收藏')
    } else {
      await favoriteApi.add(track.id)
      favorites.value.push(track.id)
      ElMessage.success('已添加收藏')
    }
  } catch (e) {
    console.error('Failed to toggle favorite:', e)
  }
}

// 播放
const playAll = () => {
  if (tracks.value.length > 0) {
    playerStore.setPlaylistAndPlay(tracks.value, tracks.value[0])
  }
}

const playTrack = (track: any) => {
  playerStore.setPlaylistAndPlay(tracks.value, track)
}

// 批量操作
const enterBatchMode = () => {
  isBatchMode.value = true
  selectedTrackIds.value = []
}

const exitBatchMode = () => {
  isBatchMode.value = false
  selectedTrackIds.value = []
}

const toggleSelectAll = () => {
  if (isAllSelected.value) {
    selectedTrackIds.value = []
  } else {
    selectedTrackIds.value = tracks.value.map(t => t.id)
  }
}

const toggleTrackSelection = (trackId: number) => {
  const index = selectedTrackIds.value.indexOf(trackId)
  if (index > -1) {
    selectedTrackIds.value.splice(index, 1)
  } else {
    selectedTrackIds.value.push(trackId)
  }
}

const handleTrackClick = (track: any, event: MouseEvent) => {
  if (isBatchMode.value) {
    toggleTrackSelection(track.id)
  } else {
    playTrack(track)
  }
}

// 查看评论 - 跳转到歌曲评论页
const goToComments = (track: any) => {
  router.push(`/track/${track.id}`)
}

// 添加到歌单
const showAddToPlaylist = (track: any) => {
  if (!userStore.currentUser) {
    router.push('/login')
    return
  }
  selectedTrack.value = track
  showAddToPlaylistDialog.value = true
}

const addTrackToPlaylist = async (playlistId: number) => {
  if (!selectedTrack.value) return
  addToPlaylistLoading.value = true
  try {
    await playlistApi.addTrack(playlistId, selectedTrack.value.id)
    ElMessage.success('已添加到歌单')
    showAddToPlaylistDialog.value = false
  } catch (e) {
    console.error('Failed to add track to playlist:', e)
    ElMessage.error('添加失败')
  } finally {
    addToPlaylistLoading.value = false
  }
}

// 移除歌曲
const removeTrack = async (trackId: number) => {
  const id = route.params.id
  if (!id) return
  
  try {
    await playlistApi.removeTrack(Number(id), trackId)
    tracks.value = tracks.value.filter(t => t.id !== trackId)
    if (playlist.value) {
      playlist.value.trackCount = (playlist.value.trackCount || 1) - 1
    }
    ElMessage.success('已从歌单移除')
  } catch (e) {
    console.error('Failed to remove track:', e)
    ElMessage.error('移除失败')
  }
}

// 批量移除
const batchRemove = async () => {
  if (selectedTrackIds.value.length === 0) return
  
  const id = route.params.id
  if (!id) return
  
  try {
    for (const trackId of selectedTrackIds.value) {
      await playlistApi.removeTrack(Number(id), trackId)
    }
    tracks.value = tracks.value.filter(t => !selectedTrackIds.value.includes(t.id))
    if (playlist.value) {
      playlist.value.trackCount = (playlist.value.trackCount || selectedTrackIds.value.length) - selectedTrackIds.value.length
    }
    ElMessage.success(`已移除 ${selectedTrackIds.value.length} 首歌曲`)
    exitBatchMode()
  } catch (e) {
    console.error('Failed to batch remove:', e)
    ElMessage.error('批量移除失败')
  }
}

// 转移歌曲
const transferTracks = async () => {
  if (!targetPlaylistId.value || selectedTrackIds.value.length === 0) return
  
  const id = route.params.id
  if (!id) return
  
  try {
    // 添加到目标歌单
    for (const trackId of selectedTrackIds.value) {
      await playlistApi.addTrack(targetPlaylistId.value, trackId)
    }
    // 从当前歌单移除
    for (const trackId of selectedTrackIds.value) {
      await playlistApi.removeTrack(Number(id), trackId)
    }
    
    tracks.value = tracks.value.filter(t => !selectedTrackIds.value.includes(t.id))
    if (playlist.value) {
      playlist.value.trackCount = (playlist.value.trackCount || selectedTrackIds.value.length) - selectedTrackIds.value.length
    }
    
    ElMessage.success(`已转移 ${selectedTrackIds.value.length} 首歌曲`)
    showTransferModal.value = false
    exitBatchMode()
  } catch (e) {
    console.error('Failed to transfer tracks:', e)
    ElMessage.error('转移失败')
  }
}

// 编辑歌单名称
const startEditName = () => {
  editingName.value = true
  editName.value = playlist.value?.name || ''
  nextTick(() => {
    nameInputRef.value?.focus()
  })
}

const saveName = async () => {
  if (!editName.value.trim()) {
    editingName.value = false
    return
  }
  
  const id = route.params.id
  if (!id) return
  
  try {
    await playlistApi.update(Number(id), { name: editName.value })
    if (playlist.value) {
      playlist.value.name = editName.value
    }
    editingName.value = false
    ElMessage.success('名称已更新')
  } catch (e) {
    console.error('Failed to save name:', e)
    ElMessage.error('保存失败')
  }
}

// 编辑歌单描述
const startEditDescription = () => {
  editingDescription.value = true
  editDescription.value = playlist.value?.description || ''
  nextTick(() => {
    descInputRef.value?.focus()
  })
}

const saveDescription = async () => {
  const id = route.params.id
  if (!id) return
  
  try {
    await playlistApi.update(Number(id), { description: editDescription.value })
    if (playlist.value) {
      playlist.value.description = editDescription.value
    }
    editingDescription.value = false
    ElMessage.success('描述已更新')
  } catch (e) {
    console.error('Failed to save description:', e)
    ElMessage.error('保存失败')
  }
}

// 封面上传与裁剪
const openCoverUpload = () => {
  coverInputRef.value?.click()
}

const handleCoverSelect = (e: Event) => {
  const target = e.target as HTMLInputElement
  if (!target.files || target.files.length === 0) return
  const file = target.files[0]
  const reader = new FileReader()
  reader.onload = (ev) => {
    coverCropperImageUrl.value = ev.target?.result as string
    showCoverCropper.value = true
  }
  reader.readAsDataURL(file)
  target.value = ''
}

const handleCoverCropConfirm = async (blob: Blob) => {
  const id = route.params.id
  if (!id) return
  try {
    const file = new File([blob], 'cover.jpg', { type: 'image/jpeg' })
    await playlistApi.updateCover(Number(id), file)
    await loadPlaylist()
    ElMessage.success('封面已更新')
  } catch (e) {
    console.error('Failed to update cover:', e)
    ElMessage.error('封面上传失败')
  }
  showCoverCropper.value = false
}

// 删除歌单
const deletePlaylist = async () => {
  if (!confirm('确定要删除此歌单吗？')) return
  
  const id = route.params.id
  if (!id) return
  
  try {
    await playlistApi.delete(Number(id))
    userStore.removePlaylist(Number(id))
    ElMessage.success('歌单已删除')
    router.push('/profile')
  } catch (e) {
    console.error('Failed to delete playlist:', e)
    ElMessage.error('删除失败')
  }
}

onMounted(() => {
  loadPlaylist()
  loadTracks()
  loadFavorites()
})
</script>

<style scoped>
/* 与个人主页同宽；顶部固定、仅曲目列表滚动（与 AppLayout flex 配合） */
.playlist-detail-page {
  display: flex;
  flex-direction: column;
  flex: 1;
  min-height: 0;
  max-width: min(1320px, 96vw);
  width: 100%;
  margin: 0 auto;
  padding: var(--sp-6) var(--sp-5);
  box-sizing: border-box;
  min-width: 0;
  overflow: hidden;
}

.playlist-detail-sticky {
  flex-shrink: 0;
  background: var(--bg-primary);
  z-index: 2;
  box-shadow: 0 1px 0 var(--border);
}

.playlist-detail-scroll {
  flex: 1;
  min-height: 0;
  min-width: 0;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
}

/* 顶部导航 */
.top-bar {
  display: flex;
  align-items: center;
  gap: var(--sp-4);
  margin-bottom: var(--sp-6);
  width: 100%;
  min-width: 0;
}

.back-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border: none;
  border-radius: var(--radius-full);
  background: var(--bg-hover);
  color: var(--text-primary);
  cursor: pointer;
  transition: all var(--dur-normal);
}

.back-btn:hover {
  background: var(--bg-card);
}

.page-title {
  font-size: var(--text-md);
  color: var(--text-primary);
}

.batch-actions {
  margin-left: auto;
  display: flex;
  gap: var(--sp-2);
}

.batch-btn {
  display: flex;
  align-items: center;
  gap: var(--sp-2);
  padding: var(--sp-2) var(--sp-3);
  border: none;
  border-radius: var(--radius-full);
  background: var(--bg-hover);
  color: var(--text-primary);
  font-size: var(--text-sm);
  cursor: pointer;
  transition: all var(--dur-normal);
}

.batch-btn:hover {
  background: var(--bg-card);
}

.batch-btn.delete-btn {
  background: rgba(239, 68, 68, 0.2);
  color: var(--red);
}

.batch-btn.delete-btn:hover {
  background: rgba(239, 68, 68, 0.3);
}

.batch-btn.delete-btn:disabled,
.batch-btn.transfer-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.batch-btn.cancel-btn {
  background: transparent;
  border: 1px solid var(--border-hover);
}

/* 歌单头部 */
.playlist-header {
  display: flex;
  gap: var(--sp-6);
  margin-bottom: var(--sp-4);
  width: 100%;
  min-width: 0;
}

.cover-wrapper {
  position: relative;
  flex-shrink: 0;
  cursor: pointer;
}

.cover {
  width: 200px;
  height: 200px;
  border-radius: var(--radius-md);
  object-fit: cover;
}

.cover-edit-mask {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  border-radius: var(--radius-md);
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: var(--sp-2);
  color: var(--text-primary);
  opacity: 0;
  transition: opacity var(--dur-normal);
}

.cover-wrapper:hover .cover-edit-mask {
  opacity: 1;
}

.info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: var(--sp-3);
}

.playlist-name {
  display: flex;
  align-items: center;
  gap: var(--sp-2);
  font-size: 28px;
  font-weight: bold;
  color: var(--text-primary);
  margin: 0;
  cursor: pointer;
}

.edit-icon,
.edit-icon-small {
  opacity: 0.5;
  transition: opacity var(--dur-normal);
}

.playlist-name:hover .edit-icon,
.description:hover .edit-icon-small {
  opacity: 1;
}

.inline-edit-input {
  font-size: 28px;
  font-weight: bold;
  background: var(--bg-hover);
  border: 1px solid var(--border-hover);
  border-radius: var(--radius-sm);
  color: var(--text-primary);
  padding: var(--sp-1) var(--sp-2);
  outline: none;
  width: 100%;
  max-width: 400px;
}

.inline-edit-textarea {
  font-size: var(--text-base);
  background: var(--bg-hover);
  border: 1px solid var(--border-hover);
  border-radius: var(--radius-sm);
  color: var(--text-primary);
  padding: var(--sp-2);
  outline: none;
  width: 100%;
  max-width: 400px;
  resize: vertical;
}

.creator-info {
  display: flex;
  align-items: center;
  gap: var(--sp-2);
}

.creator-avatar {
  width: 24px;
  height: 24px;
  border-radius: var(--radius-full);
  object-fit: cover;
}

.creator-name {
  font-size: var(--text-base);
  color: var(--text-primary);
}

.create-time {
  font-size: var(--text-sm);
  color: var(--text-secondary);
}

.description {
  font-size: var(--text-base);
  color: var(--text-secondary);
  cursor: pointer;
  display: flex;
  align-items: flex-start;
  gap: var(--sp-2);
}

.stats {
  display: flex;
  gap: var(--sp-4);
}

.track-count {
  font-size: var(--text-base);
  color: var(--text-secondary);
}

.actions {
  display: flex;
  gap: var(--sp-3);
  margin-top: var(--sp-2);
}

.play-all-btn {
  display: flex;
  align-items: center;
  gap: var(--sp-2);
  padding: var(--sp-2) var(--sp-6);
  border: none;
  border-radius: var(--radius-full);
  background: var(--accent);
  color: var(--text-primary);
  font-size: var(--text-base);
  font-weight: 500;
  cursor: pointer;
  transition: all var(--dur-normal);
}

.play-all-btn:hover {
  transform: scale(1.02);
  background: var(--accent-hover);
  box-shadow: var(--shadow-md);
}

.edit-info-btn {
  display: flex;
  align-items: center;
  gap: var(--sp-2);
  padding: var(--sp-2) var(--sp-4);
  border: 1px solid var(--border-hover);
  border-radius: var(--radius-full);
  background: transparent;
  color: var(--text-secondary);
  font-size: var(--text-base);
  cursor: pointer;
  transition: all var(--dur-fast);
}

.edit-info-btn:hover {
  background: var(--bg-hover);
  color: var(--text-primary);
  border-color: var(--border);
}

.delete-btn {
  display: flex;
  align-items: center;
  gap: var(--sp-2);
  padding: var(--sp-2) var(--sp-4);
  border: 1px solid rgba(239, 68, 68, 0.3);
  border-radius: var(--radius-full);
  background: transparent;
  color: var(--red);
  font-size: var(--text-base);
  cursor: pointer;
  transition: all var(--dur-normal);
}

.delete-btn:hover {
  background: rgba(239, 68, 68, 0.15);
}

/* 歌曲列表（与主页最新音乐样式一致） */
.track-list {
  margin-top: var(--sp-2);
  width: 100%;
  min-width: 0;
  background: var(--bg-hover);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.track-row {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 14px var(--sp-5);
  cursor: pointer;
  transition: all var(--dur-fast) ease;
  border-bottom: 1px solid var(--border);
}

.track-row:last-child {
  border-bottom: none;
}

.track-row:hover {
  background: var(--accent-muted);
}

.track-row.selected {
  background: var(--accent-muted);
}

.col-first {
  width: 30px;
  text-align: center;
  flex-shrink: 0;
}

.col-first input[type="checkbox"] {
  width: 16px;
  height: 16px;
  cursor: pointer;
}

.track-row .index {
  font-size: var(--text-base);
  font-weight: 500;
  color: var(--text-tertiary);
}

.track-row:hover .index {
  color: var(--accent);
}

.row-cover {
  width: 50px;
  height: 50px;
  border-radius: var(--radius-md);
  object-fit: cover;
  box-shadow: var(--shadow-sm);
  transition: transform var(--dur-fast);
}

.row-cover-wrapper {
  position: relative;
  width: 50px;
  height: 50px;
  flex-shrink: 0;
}

.row-play-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, 0.5);
  border-radius: var(--radius-md);
  opacity: 0;
  transition: opacity var(--dur-fast);
}

.track-row:hover .row-play-overlay {
  opacity: 1;
}

.row-play-btn {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: var(--play-overlay-btn-bg);
  color: var(--play-overlay-btn-color);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: transform var(--dur-fast);
}

.row-play-btn:hover {
  transform: scale(1.1);
}

.track-row:hover .row-cover {
  transform: scale(1.05);
}

.row-info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.row-info .title {
  font-size: var(--text-base);
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  color: var(--text-primary);
}

.row-info .artist {
  font-size: var(--text-xs);
  color: var(--text-secondary);
}

.track-row .duration {
  font-size: var(--text-sm);
  color: var(--text-tertiary);
  min-width: 45px;
  text-align: right;
}

.row-controls {
  display: flex;
  align-items: center;
  gap: 4px;
}

.row-controls .ctrl-btn {
  opacity: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border: none;
  border-radius: var(--radius-sm);
  background: transparent;
  color: var(--text-secondary);
  cursor: pointer;
  transition: all var(--dur-fast);
}

.row-controls .ctrl-btn svg {
  width: 16px;
  height: 16px;
}

.track-row:hover .row-controls .ctrl-btn {
  opacity: 1;
}

.row-controls .ctrl-btn:hover {
  background: var(--bg-active);
  color: var(--text-primary);
}

.row-controls .ctrl-btn.like-btn {
  opacity: 1;
  color: var(--text-tertiary);
}

.row-controls .ctrl-btn.like-btn.liked {
  color: var(--red);
}

.row-controls .ctrl-btn.remove-btn:hover {
  color: var(--red);
}

/* 添加到歌单弹窗 */
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

.add-to-playlist-content .track-text {
  display: flex;
  flex-direction: column;
  gap: 4px;
  overflow: hidden;
}

.add-to-playlist-content .track-title {
  font-size: var(--text-base);
  color: var(--text-primary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.add-to-playlist-content .track-artist {
  font-size: var(--text-xs);
  color: var(--text-secondary);
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
  color: var(--text-primary);
}

.pl-count {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

.no-playlists {
  text-align: center;
  padding: var(--sp-8);
  color: var(--text-tertiary);
  font-size: var(--text-base);
}

/* 空状态 */
.empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: var(--sp-16) var(--sp-5);
  color: var(--text-tertiary);
}

.empty p {
  margin-top: var(--sp-4);
  font-size: var(--text-base);
}

/* 转移弹窗 */
.transfer-list {
  max-height: 400px;
  overflow-y: auto;
}

.transfer-item {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
  padding: var(--sp-3);
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: background var(--dur-fast);
}

.transfer-item:hover {
  background: var(--bg-hover);
}

.transfer-item.selected {
  background: var(--accent-muted);
}

.transfer-cover {
  width: 48px;
  height: 48px;
  border-radius: var(--radius-sm);
  object-fit: cover;
}

.transfer-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: var(--sp-1);
}

.transfer-name {
  font-size: var(--text-base);
  color: var(--text-primary);
}

.transfer-count {
  font-size: var(--text-sm);
  color: var(--text-secondary);
}

.check-icon {
  color: var(--accent);
}

.no-playlist {
  padding: var(--sp-10);
  text-align: center;
  color: var(--text-secondary);
}

.dialog-footer-btns {
  display: flex;
  justify-content: flex-end;
  gap: var(--sp-3);
}

.btn-cancel {
  padding: var(--sp-2) var(--sp-5);
  border: 1px solid var(--border-hover);
  border-radius: var(--radius-full);
  background: transparent;
  color: var(--text-primary);
  font-size: var(--text-base);
  cursor: pointer;
  transition: all var(--dur-normal);
}

.btn-cancel:hover {
  background: var(--bg-hover);
}

.btn-create {
  padding: var(--sp-2) var(--sp-5);
  border: none;
  border-radius: var(--radius-full);
  background: var(--accent);
  color: var(--text-primary);
  font-size: var(--text-base);
  cursor: pointer;
  transition: all var(--dur-normal);
}

.btn-create:hover {
  transform: scale(1.02);
  background: var(--accent-hover);
}

.btn-create:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
}

/* 深色弹窗样式 */
:deep(.dark-dialog) {
  background: var(--bg-card) !important;
  border-radius: var(--radius-md);
}

:deep(.dark-dialog .el-dialog__header) {
  background: var(--bg-card) !important;
  border-bottom: 1px solid var(--border);
}

:deep(.dark-dialog .el-dialog__title) {
  color: var(--text-primary) !important;
}

:deep(.dark-dialog .el-dialog__body) {
  background: var(--bg-card) !important;
  color: var(--text-primary) !important;
}

:deep(.dark-dialog .el-dialog__footer) {
  background: var(--bg-card) !important;
  border-top: 1px solid var(--border);
}

:deep(.dark-modal) {
  background: rgba(0, 0, 0, 0.7) !important;
}
</style>
