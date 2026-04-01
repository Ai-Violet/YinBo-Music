<template>
  <div class="search-page">
    <!-- 顶部：返回 + 搜索栏 -->
    <header class="search-header">
      <router-link to="/home" class="back-link">
        <svg viewBox="0 0 24 24" width="20" height="20">
          <path fill="currentColor" d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"/>
        </svg>
        返回
      </router-link>
      <div class="search-bar">
        <el-input
          v-model="searchKeyword"
          placeholder="搜索歌名、歌手、专辑..."
          size="large"
          clearable
          @keyup.enter="performSearch"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
        <el-button type="primary" @click="performSearch">搜索</el-button>
      </div>
    </header>

    <main class="search-main">
      <!-- 未搜索：热门关键词 + 搜索历史 -->
      <div v-if="!hasSearched" class="pre-search">
        <section v-if="hotKeywords.length > 0" class="section">
          <h3>热门搜索</h3>
          <div class="keyword-tags">
            <span
              v-for="kw in hotKeywords"
              :key="kw"
              class="tag"
              @click="searchFromKeyword(kw)"
            >{{ kw }}</span>
          </div>
        </section>
        <section v-if="searchHistory.length > 0" class="section">
          <div class="section-head">
            <h3>搜索历史</h3>
            <button class="clear-btn" @click="clearSearchHistory">清空</button>
          </div>
          <div class="keyword-tags">
            <span
              v-for="kw in searchHistory"
              :key="kw"
              class="tag tag-with-delete"
              @click="searchFromKeyword(kw)"
            >
              {{ kw }}
              <button class="tag-delete-btn" @click.stop="removeSearchHistoryItem(kw)" title="删除">×</button>
            </span>
          </div>
        </section>
      </div>

      <!-- 已搜索：结果列表 -->
      <div v-else class="search-results">
        <div v-if="loading" class="loading-wrap">
          <el-icon class="is-loading"><Loading /></el-icon>
          <span>搜索中...</span>
        </div>

        <template v-else>
          <div class="search-toolbar">
            <el-select
              v-model="selectedCategoryId"
              clearable
              placeholder="全部分类"
              class="category-filter"
              @change="onCategoryChange"
            >
              <el-option
                v-for="c in categories"
                :key="c.id"
                :label="c.name"
                :value="c.id"
              />
            </el-select>
          </div>

          <section v-if="singers.length > 0" class="singer-section">
            <h3 class="block-title">歌手</h3>
            <div class="singer-cards">
              <button
                v-for="s in singers"
                :key="s.id"
                type="button"
                class="singer-card"
                @click="goSinger(s.id)"
              >
                <img :src="s.avatarUrl || defaultCover" alt="" class="singer-av" @error="onImgErr" />
                <span class="singer-name">{{ s.name }}</span>
              </button>
            </div>
          </section>

          <div class="results-header">
            <h3 class="block-title">歌曲</h3>
            <span class="count">共 {{ total }} 首</span>
          </div>

          <!-- 歌曲列表（与 Home 最新音乐样式一致） -->
          <div class="track-list">
            <div
              v-for="(track, index) in tracks"
              :key="track.id"
              class="track-row"
              @click="playTrack(track)"
            >
              <span class="index">{{ (page - 1) * pageSize + index + 1 }}</span>
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
                <ArtistLink :artist-id="track.artistId" :artist-name="track.artist" class="artist" />
              </div>
              <span class="duration">{{ formatDuration(track.duration) }}</span>
              <div class="row-controls">
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
              </div>
            </div>
          </div>

          <!-- 无结果 -->
          <el-empty v-if="total === 0 && !loading" description="没有找到相关歌曲" />

          <!-- 分页 -->
          <div v-if="total > pageSize" class="pagination-wrap">
            <el-pagination
              background
              layout="prev, pager, next"
              :current-page="page"
              :page-size="pageSize"
              :total="total"
              @current-change="onPageChange"
            />
          </div>
        </template>
      </div>
    </main>

    <!-- 添加到歌单弹窗 -->
    <el-dialog
      v-model="showAddDialog"
      title="添加到歌单"
      width="400px"
      :close-on-click-modal="true"
      class="add-dialog"
    >
      <div v-if="myPlaylists.length > 0" class="playlist-choices">
        <div
          v-for="pl in myPlaylists"
          :key="pl.id"
          class="playlist-item"
          @click="addToPlaylist(pl)"
        >
          <img :src="pl.coverUrl || defaultCover" alt="" class="pl-cover" />
          <div class="pl-info">
            <span class="pl-name">{{ pl.name }}</span>
            <span class="pl-count">{{ pl.trackCount || 0 }} 首</span>
          </div>
        </div>
      </div>
      <div v-else class="no-playlists">暂无歌单，请先创建歌单</div>
    </el-dialog>

    <!-- 评论抽屉 -->
    <TrackCommentDrawer v-model="showCommentDrawer" :track="currentCommentTrack" />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Search, Loading } from '@element-plus/icons-vue'
import { usePlayerStore } from '../stores/player'
import { useUserStore } from '../stores/user'
import { trackApi, playlistApi, favoriteApi, commentApi } from '../api'
import TrackCommentDrawer from '../components/TrackCommentDrawer.vue'
import ArtistLink from '../components/ArtistLink.vue'
import type { Track } from '../types/track'

const route = useRoute()
const router = useRouter()
const playerStore = usePlayerStore()
const userStore = useUserStore()

import { DEFAULT_AVATAR_COVER } from '../constants'
const defaultCover = DEFAULT_AVATAR_COVER
const SEARCH_HISTORY_KEY = 'yinbo_search_history'

const searchKeyword = ref('')
const hasSearched = ref(false)
const loading = ref(false)
const tracks = ref<Track[]>([])
const total = ref(0)
const page = ref(1)
const pageSize = 20
const hotKeywords = ref<string[]>([])
const showAddDialog = ref(false)
const addTargetTrack = ref<Track | null>(null)
const myPlaylists = ref<any[]>([])
const showCommentDrawer = ref(false)
const currentCommentTrack = ref<Track | null>(null)
const singers = ref<{ id: number; name: string; avatarUrl?: string }[]>([])
const categories = ref<{ id: number; name: string }[]>([])
const selectedCategoryId = ref<number | undefined>(undefined)

const searchHistoryVersion = ref(0)
const searchHistory = computed(() => {
  searchHistoryVersion.value
  try {
    const saved = localStorage.getItem(SEARCH_HISTORY_KEY)
    return saved ? (JSON.parse(saved) as string[]) : []
  } catch { return [] }
})

const isFavorite = (trackId: number) => {
  return userStore.currentUser ? userStore.favorites.includes(trackId) : false
}

const formatDuration = (s: number) => {
  if (!s) return '0:00'
  const m = Math.floor(s / 60)
  const sec = s % 60
  return `${m}:${sec.toString().padStart(2, '0')}`
}

const addSearchHistory = (kw: string) => {
  const list = searchHistory.value.filter(k => k !== kw)
  list.unshift(kw)
  if (list.length > 15) list.length = 15
  localStorage.setItem(SEARCH_HISTORY_KEY, JSON.stringify(list))
  searchHistoryVersion.value++
}

const clearSearchHistory = () => {
  localStorage.removeItem(SEARCH_HISTORY_KEY)
  searchHistoryVersion.value++
}

const removeSearchHistoryItem = (keyword: string) => {
  const list = searchHistory.value.filter(k => k !== keyword)
  if (list.length > 0) {
    localStorage.setItem(SEARCH_HISTORY_KEY, JSON.stringify(list))
  } else {
    localStorage.removeItem(SEARCH_HISTORY_KEY)
  }
  searchHistoryVersion.value++
}

const searchFromKeyword = (kw: string) => {
  searchKeyword.value = kw
  performSearch()
}

const mapTrack = (t: any) => ({
  ...t,
  coverUrl: t.coverUrl || t.cover,
  playUrl: t.playUrl || t.url
})

const performSearch = async () => {
  const kw = searchKeyword.value.trim()
  if (!kw) return

  addSearchHistory(kw)
  hasSearched.value = true
  loading.value = true
  page.value = 1

  try {
    const res = await trackApi.searchPortal(kw, {
      page: 1,
      size: pageSize,
      singerLimit: 16,
      categoryId: selectedCategoryId.value
    })
    if (res.data.code === 200) {
      const data = res.data.data
      singers.value = data.singers || []
      const tr = data.tracks
      tracks.value = (tr?.records || []).map(mapTrack)
      total.value = tr?.total || 0
    }
  } catch (e) {
    console.error('Search error:', e)
    ElMessage.error('搜索失败，请重试')
  } finally {
    loading.value = false
  }
}

const onCategoryChange = () => {
  if (hasSearched.value && searchKeyword.value.trim()) {
    performSearch()
  }
}

const goSinger = (id: number) => {
  router.push('/singer/' + id)
}

const onImgErr = (e: Event) => {
  const el = e.target as HTMLImageElement
  el.src = defaultCover
}

const onPageChange = async (p: number) => {
  page.value = p
  const kw = searchKeyword.value.trim()
  if (!kw) return
  loading.value = true
  try {
    const res = await trackApi.searchPortal(kw, {
      page: p,
      size: pageSize,
      singerLimit: 16,
      categoryId: selectedCategoryId.value
    })
    if (res.data.code === 200) {
      const data = res.data.data
      if (p === 1) singers.value = data.singers || []
      const tr = data.tracks
      tracks.value = (tr?.records || []).map(mapTrack)
      total.value = tr?.total ?? total.value
    }
  } catch (e) {
    console.error('Search page error:', e)
  } finally {
    loading.value = false
  }
}

const playTrack = (track: Track) => {
  playerStore.setPlaylistAndPlay(tracks.value, track)
}

const toggleFavorite = async (track: Track) => {
  if (!userStore.currentUser) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }
  try {
    if (isFavorite(track.id)) {
      await favoriteApi.remove(track.id)
      userStore.removeFavorite(track.id)
      ElMessage.success('已取消收藏')
    } else {
      await favoriteApi.add(track.id)
      userStore.addFavorite(track.id)
      ElMessage.success('收藏成功')
    }
  } catch (e: any) {
    if (e.response?.status === 401) {
      ElMessage.warning('请先登录')
      router.push('/login')
    } else ElMessage.error('操作失败')
  }
}

const showAddToPlaylist = async (track: Track) => {
  if (!userStore.currentUser) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }
  addTargetTrack.value = track
  showAddDialog.value = true
  try {
    const res = await playlistApi.getMyPlaylists(1, 100)
    if (res.data.code === 200) {
      const d = res.data.data as { records?: any[] }
      myPlaylists.value = d?.records || []
    }
  } catch (e) {
    myPlaylists.value = []
  }
}

const addToPlaylist = async (pl: any) => {
  const track = addTargetTrack.value
  if (!track) return
  try {
    await playlistApi.addTrack(pl.id, track.id)
    ElMessage.success('已添加到歌单')
    showAddDialog.value = false
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '添加失败')
  }
}

const goToComments = (track: Track) => {
  currentCommentTrack.value = track
  showCommentDrawer.value = true
}

watch(() => route.query.keyword || route.query.q, (kw) => {
  if (kw && typeof kw === 'string') {
    searchKeyword.value = decodeURIComponent(kw)
    performSearch()
  }
}, { immediate: true })

onMounted(async () => {
  try {
    const res = await trackApi.getSearchHotKeywords()
    if (res.data.code === 200 && res.data.data) hotKeywords.value = res.data.data
  } catch (e) {
    console.error('Load hot keywords error:', e)
  }
  try {
    const cr = await trackApi.getCategories()
    if (cr.data.code === 200 && cr.data.data) {
      categories.value = (cr.data.data as any[]).map((c: any) => ({ id: c.id, name: c.name }))
    }
  } catch (e) {
    console.error('Load categories error:', e)
  }
})
</script>

<style scoped>
.search-page {
  min-height: 100vh;
  background: var(--bg-primary);
  padding: var(--sp-5);
}

.search-header {
  margin-bottom: var(--sp-6);
  display: flex;
  align-items: center;
  gap: var(--sp-4);
}

.back-link {
  display: flex;
  align-items: center;
  gap: var(--sp-2);
  color: var(--text-secondary);
  text-decoration: none;
  font-size: var(--text-sm);
  transition: color var(--dur-fast);
}
.back-link:hover { color: var(--text-primary); }

.search-bar {
  flex: 1;
  max-width: 500px;
  display: flex;
  gap: var(--sp-3);
}
.search-bar .el-input { flex: 1; }
.search-bar .el-input :deep(.el-input__wrapper) {
  background: var(--bg-secondary);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
}

.pre-search .section {
  margin-bottom: var(--sp-6);
}
.pre-search h3 {
  margin: 0 0 var(--sp-4);
  font-size: var(--text-base);
  color: var(--text-secondary);
}
.section-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--sp-4);
}
.section-head h3 { margin: 0; }
.clear-btn {
  background: none;
  border: none;
  color: var(--text-tertiary);
  font-size: var(--text-xs);
  cursor: pointer;
}
.clear-btn:hover { color: var(--accent); }

.keyword-tags {
  display: flex;
  flex-wrap: wrap;
  gap: var(--sp-2);
}
.tag {
  padding: var(--sp-2) var(--sp-4);
  background: var(--bg-card);
  border: 1px solid var(--border);
  border-radius: var(--radius-full);
  font-size: var(--text-sm);
  color: var(--text-secondary);
  cursor: pointer;
  transition: all var(--dur-fast);
}
.tag:hover {
  border-color: var(--accent);
  color: var(--accent);
}

.tag-with-delete {
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.tag-delete-btn {
  padding: 0 2px;
  margin: 0 -2px 0 2px;
  min-width: 18px;
  height: 18px;
  border: none;
  background: transparent;
  color: var(--text-tertiary);
  font-size: 16px;
  line-height: 1;
  cursor: pointer;
  border-radius: var(--radius-sm);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  transition: color var(--dur-fast), background var(--dur-fast);
}

.tag-delete-btn:hover {
  color: var(--red);
  background: var(--bg-hover);
}

.loading-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: var(--sp-16);
  gap: var(--sp-4);
  color: var(--text-tertiary);
}

.search-toolbar {
  margin-bottom: var(--sp-4);
}
.category-filter { width: 180px; }
.category-filter :deep(.el-input__wrapper) {
  background: var(--bg-secondary);
}

.block-title {
  margin: 0 0 var(--sp-2);
  font-size: var(--text-base);
  font-weight: 600;
  color: var(--text-primary);
}

.singer-section {
  margin-bottom: var(--sp-6);
  padding: var(--sp-4);
  background: var(--bg-card);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
}
.singer-cards {
  display: flex;
  flex-wrap: wrap;
  gap: var(--sp-4);
}
.singer-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--sp-2);
  width: 88px;
  padding: var(--sp-2);
  background: var(--bg-hover);
  border-radius: var(--radius-md);
  cursor: pointer;
  color: var(--text-primary);
  transition: transform var(--dur-fast), border-color var(--dur-fast);
  border: 1px solid var(--border);
}
.singer-card:hover {
  border-color: var(--accent);
  transform: translateY(-2px);
}
.singer-av {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  object-fit: cover;
}
.singer-name {
  font-size: var(--text-xs);
  text-align: center;
  line-height: 1.3;
  max-width: 100%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.results-header {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  margin-bottom: var(--sp-4);
}
.results-header .count {
  font-size: var(--text-sm);
  color: var(--text-secondary);
}

.track-list {
  display: flex;
  flex-direction: column;
  gap: var(--sp-1);
}
.track-row {
  display: flex;
  align-items: center;
  padding: var(--sp-3) var(--sp-4);
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all var(--dur-fast);
  border: 1px solid var(--border);
  background: var(--bg-card);
}
.track-row:hover {
  background: var(--bg-hover);
  border-color: var(--border-hover);
}
.track-row .index {
  width: 28px;
  font-size: var(--text-sm);
  color: var(--text-tertiary);
  text-align: center;
  flex-shrink: 0;
}
.row-cover-wrapper {
  position: relative;
  width: 48px;
  height: 48px;
  flex-shrink: 0;
  border-radius: var(--radius-md);
  overflow: hidden;
}
.row-cover { width: 100%; height: 100%; object-fit: cover; }
.row-play-overlay {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0,0,0,0.4);
  opacity: 0;
  transition: opacity var(--dur-fast);
}
.track-row:hover .row-play-overlay { opacity: 1; }
.row-play-btn {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: var(--play-overlay-btn-bg);
  color: var(--play-overlay-btn-color);
  display: flex;
  align-items: center;
  justify-content: center;
}
.row-info {
  flex: 1;
  min-width: 0;
  padding: 0 var(--sp-4);
}
.row-info .title {
  display: block;
  font-size: var(--text-base);
  color: var(--text-primary);
  font-weight: 500;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.row-info .artist {
  display: block;
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  margin-top: 2px;
}
.duration {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  min-width: 44px;
  text-align: right;
}
.row-controls {
  display: flex;
  align-items: center;
  gap: var(--sp-1);
}
.ctrl-btn {
  width: 32px;
  height: 32px;
  border: none;
  background: transparent;
  color: var(--text-tertiary);
  border-radius: var(--radius-sm);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all var(--dur-fast);
}
.ctrl-btn:hover { color: var(--text-primary); background: var(--bg-hover); }
.ctrl-btn.like-btn.liked { color: var(--red); }
.ctrl-btn.comment-btn:hover { color: var(--accent); }

.pagination-wrap {
  margin-top: var(--sp-6);
  display: flex;
  justify-content: center;
}

.playlist-item {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
  padding: var(--sp-3);
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: background var(--dur-fast);
}
.playlist-item:hover { background: var(--bg-hover); }
.pl-cover { width: 40px; height: 40px; border-radius: var(--radius-sm); object-fit: cover; }
.pl-info { display: flex; flex-direction: column; }
.pl-name { font-weight: 500; color: var(--text-primary); }
.pl-count { font-size: var(--text-xs); color: var(--text-tertiary); }
.no-playlists { padding: var(--sp-6); text-align: center; color: var(--text-tertiary); }
</style>
