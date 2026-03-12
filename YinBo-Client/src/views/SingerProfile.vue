<template>
  <div class="singer-profile-page">
    <!-- 头部信息 -->
    <div class="singer-header">
      <div class="avatar-section">
        <img :src="displayAvatar" alt="歌手头像" class="avatar" @error="onAvatarError" />
      </div>
      <div class="singer-info">
        <h1>{{ singerName }}</h1>
        <p v-if="singerDescription" class="description">{{ singerDescription }}</p>
        <div class="quick-actions">
          <button class="quick-btn" @click="router.back()">返回上页</button>
          <button class="quick-btn primary" v-if="tracks.length > 0" @click="playAll">播放全部</button>
        </div>
      </div>
    </div>

    <!-- 标签页 -->
    <div class="profile-tabs">
      <button :class="['tab', { active: activeTab === 'songs' }]" @click="activeTab = 'songs'">
        歌曲
      </button>
      <button :class="['tab', { active: activeTab === 'albums' }]" @click="activeTab = 'albums'">
        专辑
      </button>
    </div>

    <!-- 歌曲列表 -->
    <div v-if="activeTab === 'songs'" class="content-section">
      <div class="section-header">
        <h3>Ta 的歌曲</h3>
        <div class="filter-bar">
          <input
            v-model="searchKeyword"
            type="text"
            placeholder="搜索歌名、专辑..."
            class="search-input"
            @input="onSearchInput"
          />
          <select v-model="selectedCategoryId" class="category-select" @change="loadTracks">
            <option value="">全部分类</option>
            <option v-for="c in categories" :key="c.id" :value="c.id">{{ c.name }}</option>
          </select>
        </div>
      </div>
      <div class="track-list">
        <div
          v-for="(track, index) in tracks"
          :key="track.id"
          class="track-item slide-in-left"
          :style="{ animationDelay: `${index * 0.03}s` }"
          @click="playTrack(track)"
        >
          <img :src="track.coverUrl || defaultCover" alt="封面" class="track-cover" @error="onCoverError" />
          <div class="track-info">
            <h4>{{ track.title }}</h4>
            <p>{{ track.artist }}</p>
            <span class="album-name">{{ track.album || '-' }}</span>
          </div>
          <span class="duration">{{ formatDuration(track.duration) }}</span>
          <button class="play-btn" @click.stop="playTrack(track)">
            <svg viewBox="0 0 24 24" width="20" height="20">
              <path fill="currentColor" d="M8 5v14l11-7z"/>
            </svg>
          </button>
          <button
            v-if="isLoggedIn"
            class="like-btn"
            :class="{ liked: track.isFavorited }"
            @click.stop="toggleFavorite(track)"
            :title="track.isFavorited ? '取消收藏' : '收藏'"
          >
            <svg viewBox="0 0 24 24" width="18" height="18">
              <path fill="currentColor" d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
            </svg>
          </button>
        </div>
      </div>
      <div v-if="loading" class="loading-state">加载中...</div>
      <div v-if="!loading && tracks.length === 0" class="empty">
        <svg viewBox="0 0 24 24" width="64" height="64" style="opacity: 0.3;">
          <path fill="currentColor" d="M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z"/>
        </svg>
        <p>暂无歌曲</p>
      </div>
      <div v-if="total > tracks.length && !loading" class="load-more">
        <button class="load-more-btn" @click="loadMore">加载更多</button>
      </div>
    </div>

    <!-- 专辑列表（占位） -->
    <div v-if="activeTab === 'albums'" class="content-section">
      <div class="empty">
        <svg viewBox="0 0 24 24" width="64" height="64" style="opacity: 0.3;">
          <path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
        </svg>
        <p>专辑功能敬请期待</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import { usePlayerStore } from '../stores/player'
import { singerApi, trackApi, favoriteApi } from '../api'
import type { Track } from '../types'
import { ElMessage } from 'element-plus'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const playerStore = usePlayerStore()
import { DEFAULT_AVATAR_COVER } from '../constants'
const defaultCover = DEFAULT_AVATAR_COVER

const singerId = computed(() => route.params.id ? Number(route.params.id) : null)
const artistNameFromQuery = computed(() => (route.query.name as string) || '')
const isSingerById = computed(() => !!singerId.value)

const singerInfo = ref<{ id: number; name: string; avatarUrl?: string; description?: string } | null>(null)
const tracks = ref<Track[]>([])
const categories = ref<{ id: number; name: string }[]>([])
const loading = ref(false)
const total = ref(0)
const page = ref(1)
const pageSize = 20
const searchKeyword = ref('')
const selectedCategoryId = ref<number | ''>('')
const activeTab = ref('songs')
const searchTimer = ref<ReturnType<typeof setTimeout> | null>(null)
const avatarLoadFailed = ref(false)

const singerName = computed(() => singerInfo.value?.name || artistNameFromQuery.value || '歌手')
const singerDescription = computed(() => singerInfo.value?.description || '')
const displayAvatar = computed(() => {
  if (avatarLoadFailed.value) return defaultCover
  return singerInfo.value?.avatarUrl || defaultCover
})
const isLoggedIn = computed(() => !!userStore.currentUser)

const onAvatarError = () => { avatarLoadFailed.value = true }
const onCoverError = (e: Event) => {
  const el = e.target as HTMLImageElement
  if (el) el.src = defaultCover
}

function formatDuration(sec?: number) {
  if (!sec) return '0:00'
  const m = Math.floor(sec / 60)
  const s = sec % 60
  return `${m}:${String(s).padStart(2, '0')}`
}

function normalizeTrack(t: any): Track {
  const playUrl = t.playUrl || t.audioUrl || t.url
  const apiFavorited = t.isFavorited ?? t.isLiked
  const storeFavorited = userStore.favorites.includes(t.id)
  return {
    id: t.id,
    title: t.title,
    artist: t.artist,
    artistId: t.artistId,
    album: t.album,
    duration: t.duration ?? 0,
    coverUrl: t.coverUrl,
    playUrl,
    audioUrl: playUrl,
    playCount: t.playCount,
    likeCount: t.likeCount,
    isFavorited: apiFavorited ?? storeFavorited,
    isLiked: apiFavorited ?? storeFavorited
  }
}

async function loadSingerDetail() {
  if (!singerId.value) return
  try {
    const res = await singerApi.getDetail(singerId.value)
    if (res.data.code === 200 && res.data.data) {
      singerInfo.value = res.data.data
    }
  } catch (e) {
    console.error('Failed to load singer:', e)
    ElMessage.error('加载歌手信息失败')
  }
}

async function loadTracks(reset = true) {
  if (reset) page.value = 1
  if (!singerId.value && !artistNameFromQuery.value) {
    tracks.value = []
    total.value = 0
    return
  }
  loading.value = true
  try {
    const params: any = { page: page.value, size: pageSize }
    if (singerId.value) params.singerId = singerId.value
    else params.artist = artistNameFromQuery.value
    if (searchKeyword.value.trim()) params.keyword = searchKeyword.value.trim()
    if (selectedCategoryId.value) params.categoryId = Number(selectedCategoryId.value)

    const res = await trackApi.getList(params)
    if (res.data.code === 200 && res.data.data) {
      const data = res.data.data
      const list = data.records || []
      const totalCount = data.total ?? 0
      if (reset) {
        tracks.value = list.map(normalizeTrack)
      } else {
        tracks.value = [...tracks.value, ...list.map(normalizeTrack)]
      }
      total.value = totalCount
    }
  } catch (e) {
    console.error('Failed to load tracks:', e)
    if (reset) tracks.value = []
  } finally {
    loading.value = false
  }
}

async function loadCategories() {
  try {
    const res = await trackApi.getCategories()
    if (res.data.code === 200 && res.data.data) {
      categories.value = res.data.data
    }
  } catch (_) {}
}

function onSearchInput() {
  if (searchTimer.value) clearTimeout(searchTimer.value)
  searchTimer.value = setTimeout(() => loadTracks(true), 300)
}

function loadMore() {
  page.value++
  loadTracks(false)
}

const playTrack = async (track: Track) => {
  let targetTrack = track
  const needUrl = !track.playUrl && !track.audioUrl
  if (needUrl && track.id) {
    try {
      const res = await trackApi.getDetail(track.id)
      if (res.data.code === 200 && res.data.data) {
        const fresh = res.data.data as any
        targetTrack = normalizeTrack({ ...track, playUrl: fresh.playUrl, coverUrl: fresh.coverUrl || track.coverUrl })
      }
    } catch (_) {}
  }
  playerStore.setPlaylistAndPlay(tracks.value, targetTrack)
}

function playAll() {
  if (tracks.value.length === 0) return
  playTrack(tracks.value[0])
}

async function toggleFavorite(track: Track) {
  if (!userStore.currentUser) {
    ElMessage.warning('请先登录')
    return
  }
  try {
    if (track.isFavorited) {
      await favoriteApi.remove(track.id)
      track.isFavorited = false
      userStore.removeFavorite(track.id)
      ElMessage.success('已取消收藏')
    } else {
      await favoriteApi.add(track.id)
      track.isFavorited = true
      userStore.addFavorite(track.id)
      ElMessage.success('已添加收藏')
    }
  } catch (e) {
    ElMessage.error('操作失败')
  }
}

onMounted(async () => {
  if (isSingerById.value) {
    await loadSingerDetail()
  }
  await loadCategories()
  await loadTracks(true)
})

watch([() => route.params.id, () => route.query.name], async () => {
  singerInfo.value = null
  if (isSingerById.value) await loadSingerDetail()
  await loadTracks(true)
})
</script>

<style scoped>
.singer-profile-page {
  max-width: 900px;
  margin: 0 auto;
  padding: var(--sp-6);
}

.singer-header {
  display: flex;
  gap: var(--sp-6);
  align-items: flex-start;
  margin-bottom: var(--sp-6);
  padding: var(--sp-6);
  background: var(--bg-secondary);
  border-radius: var(--radius-lg);
  border: 1px solid var(--border);
}

.avatar-section .avatar {
  width: 160px;
  height: 160px;
  border-radius: var(--radius-lg);
  object-fit: cover;
}

.singer-info {
  flex: 1;
  min-width: 0;
}

.singer-info h1 {
  margin: 0 0 var(--sp-2);
  font-size: 1.75rem;
  font-weight: 700;
  color: var(--text-primary);
}

.singer-info .description {
  margin: 0 0 var(--sp-4);
  font-size: var(--text-sm);
  color: var(--text-secondary);
  line-height: 1.5;
}

.quick-actions {
  display: flex;
  gap: var(--sp-3);
}

.quick-btn {
  padding: var(--sp-2) var(--sp-4);
  border-radius: var(--radius-md);
  border: 1px solid var(--border);
  background: var(--bg-elevated);
  color: var(--text-primary);
  cursor: pointer;
  font-size: var(--text-sm);
  transition: all 0.2s;
}

.quick-btn:hover {
  border-color: var(--border-hover);
  background: var(--bg-primary);
}

.quick-btn.primary {
  background: var(--accent, #7c3aed);
  border-color: var(--accent);
  color: white;
}

.quick-btn.primary:hover {
  background: var(--accent-hover);
}

.profile-tabs {
  display: flex;
  gap: var(--sp-2);
  margin-bottom: var(--sp-5);
  border-bottom: 1px solid var(--border);
}

.profile-tabs .tab {
  padding: var(--sp-3) var(--sp-5);
  border: none;
  background: none;
  color: var(--text-secondary);
  cursor: pointer;
  font-size: var(--text-base);
  border-bottom: 2px solid transparent;
  margin-bottom: -1px;
  transition: all 0.2s;
}

.profile-tabs .tab:hover { color: var(--text-primary); }
.profile-tabs .tab.active {
  color: var(--accent);
  border-bottom-color: var(--accent);
}

.content-section { margin-top: var(--sp-4); }

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: var(--sp-4);
  margin-bottom: var(--sp-4);
}

.section-header h3 { margin: 0; font-size: 1.1rem; color: var(--text-primary); }

.filter-bar {
  display: flex;
  gap: var(--sp-3);
  align-items: center;
}

.search-input {
  padding: var(--sp-2) var(--sp-4);
  border-radius: var(--radius-md);
  border: 1px solid var(--border);
  background: var(--bg-secondary);
  color: var(--text-primary);
  min-width: 180px;
}

.category-select {
  padding: var(--sp-2) var(--sp-4);
  border-radius: var(--radius-md);
  border: 1px solid var(--border);
  background: var(--bg-secondary);
  color: var(--text-primary);
  cursor: pointer;
}

.track-list {
  display: flex;
  flex-direction: column;
  gap: var(--sp-3);
}

@keyframes slideInLeft {
  from { opacity: 0; transform: translateX(-10px); }
  to { opacity: 1; transform: translateX(0); }
}

.slide-in-left {
  animation: slideInLeft 0.4s ease-out forwards;
  opacity: 0;
}

.track-item {
  display: flex;
  align-items: center;
  gap: var(--sp-4);
  padding: var(--sp-4) var(--sp-5);
  background: var(--bg-secondary);
  border-radius: var(--radius-lg);
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid var(--border);
}

.track-item:hover {
  background: var(--bg-elevated);
  border-color: var(--border-hover);
  transform: translateX(4px);
}

.track-cover {
  width: 50px;
  height: 50px;
  border-radius: var(--radius-md);
  object-fit: cover;
}

.track-info {
  flex: 1;
  min-width: 0;
}

.track-info h4 {
  margin: 0 0 var(--sp-1);
  font-size: var(--text-base);
  font-weight: 500;
  color: var(--text-primary);
}

.track-info p {
  margin: 0;
  font-size: var(--text-sm);
  color: var(--text-secondary);
}

.album-name {
  font-size: var(--text-xs);
  color: var(--text-muted);
  margin-left: var(--sp-2);
}

.duration {
  font-size: var(--text-sm);
  color: var(--text-muted);
  min-width: 45px;
}

.play-btn, .like-btn {
  width: 36px;
  height: 36px;
  padding: 0;
  border: none;
  background: var(--bg-elevated);
  color: var(--text-primary);
  cursor: pointer;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.play-btn:hover, .like-btn:hover {
  background: var(--accent-muted);
  color: var(--accent);
}

.like-btn.liked { color: var(--red, #ef4444); }

.loading-state, .empty {
  text-align: center;
  padding: var(--sp-8);
  color: var(--text-secondary);
}

.load-more {
  text-align: center;
  margin-top: var(--sp-4);
}

.load-more-btn {
  padding: var(--sp-3) var(--sp-6);
  border-radius: var(--radius-md);
  border: 1px solid var(--border);
  background: var(--bg-secondary);
  color: var(--text-primary);
  cursor: pointer;
  transition: all 0.2s;
}

.load-more-btn:hover {
  border-color: var(--accent);
  color: var(--accent);
}
</style>
