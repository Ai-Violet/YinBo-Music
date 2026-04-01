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
      <div class="track-list-wrap">
        <div
          v-for="(track, index) in tracks"
          :key="track.id"
          class="track-row slide-in-left"
          :style="{ animationDelay: `${index * 0.03}s` }"
          @click="playTrack(track)"
        >
          <span class="index">{{ index + 1 }}</span>
          <div class="row-cover-wrapper">
            <img :src="track.coverUrl || defaultCover" alt="封面" class="row-cover" @error="onCoverError" />
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
            <span class="subline"><ArtistLink :artist-id="track.artistId" :artist-name="track.artist" /></span>
            <span class="album-line">{{ track.album || '-' }}</span>
          </div>
          <span class="duration">{{ formatDuration(track.duration) }}</span>
          <div class="row-controls">
            <button v-if="isLoggedIn" class="ctrl-btn" title="添加到歌单" @click.stop="showAddToPlaylist(track)">
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
              v-if="isLoggedIn"
              class="ctrl-btn like-btn"
              :class="{ liked: track.isFavorited }"
              :title="track.isFavorited ? '取消收藏' : '收藏'"
              @click.stop="toggleFavorite(track)"
            >
              <svg viewBox="0 0 24 24" width="16" height="16">
                <path v-if="track.isFavorited" fill="currentColor" d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                <path v-else fill="currentColor" d="M16.5 3c-1.74 0-3.41.81-4.5 2.09C10.91 3.81 9.24 3 7.5 3 4.42 3 2 5.42 2 8.5c0 3.78 3.4 6.86 8.55 11.54L12 21.35l1.45-1.32C18.6 15.36 22 12.28 22 8.5 22 5.42 19.58 3 16.5 3zm-4.4 15.55l-.1.1-.1-.1C7.14 14.24 4 11.39 4 8.5 4 6.5 5.5 5 7.5 5c1.54 0 3.04.99 3.57 2.36h1.87C13.46 5.99 14.96 5 16.5 5c2 0 3.5 1.5 3.5 3.5 0 2.89-3.14 5.74-7.9 10.05z"/>
              </svg>
            </button>
          </div>
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

    <el-dialog
      v-model="showAddToPlaylistDialog"
      title="添加到歌单"
      width="400px"
      :close-on-click-modal="false"
      class="pl-dialog"
    >
      <div v-if="selectedTrackForPl" class="add-to-playlist-body">
        <div class="selected-track-line">
          <img :src="selectedTrackForPl.coverUrl || defaultCover" alt="" class="pl-thumb" />
          <div class="pl-meta">
            <span class="pl-t">{{ selectedTrackForPl.title }}</span>
            <span class="pl-a"><ArtistLink :artist-id="selectedTrackForPl.artistId" :artist-name="selectedTrackForPl.artist" /></span>
          </div>
        </div>
        <div class="pl-list">
          <div class="pl-list-h">选择歌单</div>
          <div
            v-for="pl in myPlaylists"
            :key="pl.id"
            class="pl-row"
            @click="addTrackToPlaylist(pl.id)"
          >
            <img :src="pl.coverUrl || defaultCover" alt="" class="pl-row-cover" />
            <div>
              <div class="pl-row-name">{{ pl.name }}</div>
              <div class="pl-row-sub">{{ pl.trackCount || 0 }} 首</div>
            </div>
          </div>
          <div v-if="myPlaylists.length === 0" class="pl-empty">暂无歌单，请先创建</div>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import { usePlayerStore } from '../stores/player'
import { singerApi, trackApi, favoriteApi, playlistApi } from '../api'
import type { Track } from '../types'
import { ElMessage } from 'element-plus'
import ArtistLink from '../components/ArtistLink.vue'
import { DEFAULT_AVATAR_COVER } from '../constants'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const playerStore = usePlayerStore()
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
const showAddToPlaylistDialog = ref(false)
const selectedTrackForPl = ref<Track | null>(null)
const myPlaylists = ref<any[]>([])

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

async function loadMyPlaylists() {
  if (!userStore.currentUser) {
    myPlaylists.value = []
    return
  }
  try {
    const res = await playlistApi.getMyPlaylists(1, 200)
    if (res.data.code === 200 && res.data.data) {
      const d = res.data.data as any
      myPlaylists.value = Array.isArray(d) ? d : (d.records || [])
    }
  } catch (_) {
    myPlaylists.value = []
  }
}

function showAddToPlaylist(track: Track) {
  if (!userStore.currentUser) {
    router.push('/login')
    return
  }
  selectedTrackForPl.value = track
  showAddToPlaylistDialog.value = true
  loadMyPlaylists()
}

function goToComments(track: Track) {
  router.push(`/track/${track.id}`)
}

async function addTrackToPlaylist(playlistId: number) {
  if (!selectedTrackForPl.value) return
  try {
    await playlistApi.addTrack(playlistId, selectedTrackForPl.value.id)
    ElMessage.success('已添加到歌单')
    showAddToPlaylistDialog.value = false
    selectedTrackForPl.value = null
  } catch (_) {
    ElMessage.error('添加失败')
  }
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
  if (userStore.currentUser) loadMyPlaylists()
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

@keyframes slideInLeft {
  from { opacity: 0; transform: translateX(-10px); }
  to { opacity: 1; transform: translateX(0); }
}

.slide-in-left {
  animation: slideInLeft 0.4s ease-out forwards;
  opacity: 0;
}

/* 与主页「最新音乐」一致 */
.track-list-wrap {
  background: var(--bg-hover);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.track-list-wrap .track-row {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 14px var(--sp-5);
  cursor: pointer;
  transition: background var(--dur-fast) ease;
  border-bottom: 1px solid var(--border);
}

.track-list-wrap .track-row:last-child {
  border-bottom: none;
}

.track-list-wrap .track-row:hover {
  background: var(--accent-muted);
}

.track-list-wrap .index {
  width: 30px;
  text-align: center;
  font-size: var(--text-base);
  font-weight: 500;
  color: var(--text-tertiary);
}

.track-list-wrap .track-row:hover .index {
  color: var(--accent);
}

.track-list-wrap .row-cover {
  width: 50px;
  height: 50px;
  border-radius: var(--radius-md);
  object-fit: cover;
  box-shadow: var(--shadow-sm);
  transition: transform var(--dur-fast);
}

.track-list-wrap .row-cover-wrapper {
  position: relative;
  width: 50px;
  height: 50px;
}

.track-list-wrap .row-play-overlay {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, 0.5);
  border-radius: var(--radius-md);
  opacity: 0;
  transition: opacity var(--dur-fast);
}

.track-list-wrap .track-row:hover .row-play-overlay {
  opacity: 1;
}

.track-list-wrap .row-play-btn {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: var(--play-overlay-btn-bg);
  color: var(--play-overlay-btn-color);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform var(--dur-fast);
}

.track-list-wrap .row-play-btn:hover {
  transform: scale(1.1);
}

.track-list-wrap .row-play-btn svg {
  margin-left: 2px;
}

.track-list-wrap .track-row:hover .row-cover {
  transform: scale(1.05);
}

.track-list-wrap .row-info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.track-list-wrap .row-info .title {
  font-size: var(--text-base);
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.track-list-wrap .row-info .subline {
  font-size: var(--text-xs);
  color: var(--text-secondary);
}

.track-list-wrap .row-info .album-line {
  font-size: var(--text-xs);
  color: var(--text-muted);
}

.track-list-wrap .duration {
  font-size: var(--text-sm);
  color: var(--text-tertiary);
  min-width: 45px;
  text-align: right;
}

.track-list-wrap .row-controls {
  display: flex;
  align-items: center;
  gap: 4px;
}

.track-list-wrap .ctrl-btn {
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
  opacity: 0;
}

.track-list-wrap .ctrl-btn svg {
  width: 16px;
  height: 16px;
}

.track-list-wrap .track-row:hover .row-controls .ctrl-btn {
  opacity: 1;
}

.track-list-wrap .ctrl-btn.like-btn {
  opacity: 1;
}

.track-list-wrap .ctrl-btn:hover {
  background: var(--bg-active);
  color: var(--text-primary);
}

.track-list-wrap .ctrl-btn.like-btn.liked {
  color: var(--red);
}

.pl-dialog :deep(.el-dialog__close) {
  color: var(--text-tertiary);
}

.add-to-playlist-body {
  padding: 8px 0;
}

.selected-track-line {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
  padding: var(--sp-3);
  background: var(--bg-hover);
  border-radius: var(--radius-md);
  margin-bottom: var(--sp-4);
}

.pl-thumb {
  width: 48px;
  height: 48px;
  border-radius: var(--radius-sm);
  object-fit: cover;
}

.pl-meta {
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 0;
}

.pl-t {
  font-weight: 500;
  color: var(--text-primary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.pl-a {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

.pl-list {
  max-height: 280px;
  overflow-y: auto;
}

.pl-list-h {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  padding-bottom: var(--sp-2);
  margin-bottom: var(--sp-2);
  border-bottom: 1px solid var(--border);
}

.pl-row {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
  padding: 10px;
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: background var(--dur-fast);
}

.pl-row:hover {
  background: var(--bg-active);
}

.pl-row-cover {
  width: 40px;
  height: 40px;
  border-radius: var(--radius-sm);
  object-fit: cover;
}

.pl-row-name {
  font-weight: 500;
  color: var(--text-primary);
}

.pl-row-sub {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

.pl-empty {
  text-align: center;
  padding: var(--sp-6);
  color: var(--text-tertiary);
  font-size: var(--text-sm);
}

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
