<template>
  <div class="play-history-page">
    <div class="page-header">
      <h2>播放记录</h2>
      <button class="clear-btn" @click="clearHistory" v-if="history.length > 0">
        清空记录
      </button>
    </div>

    <div class="profile-track-list" v-if="history.length > 0">
      <div 
        v-for="(item, index) in history" 
        :key="item.historyId || item.id + '-' + index" 
        class="track-row slide-in-left"
        :style="{ animationDelay: `${index * 0.03}s` }"
        @click="playTrack(item)"
      >
        <span class="index">{{ index + 1 }}</span>
        <div class="row-cover-wrapper">
          <img :src="item.coverUrl || defaultCover" alt="封面" class="row-cover" @error="onCoverError" />
          <div class="row-play-overlay">
            <div class="row-play-btn">
              <svg viewBox="0 0 24 24" width="18" height="18">
                <path fill="currentColor" d="M8 5v14l11-7z"/>
              </svg>
            </div>
          </div>
        </div>
        <div class="row-info">
          <span class="title">{{ item.title }}</span>
          <span class="artist"><ArtistLink :artist-id="item.artistId" :artist-name="item.artist" /></span>
        </div>
        <span class="duration">{{ formatDuration(item.duration) }}</span>
        <span class="play-time">{{ formatTime(item.playedAt) }}</span>
        <div class="row-controls">
          <button class="ctrl-btn delete-btn" title="删除记录" @click.stop="deleteHistoryItem(item.historyId)">
            <svg viewBox="0 0 24 24" width="16" height="16">
              <path fill="currentColor" d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12 19 6.41z"/>
            </svg>
          </button>
        </div>
      </div>
    </div>

    <div v-else class="empty">
      <p>暂无播放记录</p>
      <p class="sub">快去发现好音乐吧~</p>
    </div>

    <!-- 分页 -->
    <div class="pagination" v-if="total > pageSize">
      <button :disabled="page === 1" @click="page--; loadHistory()">上一页</button>
      <span>{{ page }} / {{ Math.ceil(total / pageSize) }}</span>
      <button :disabled="page * pageSize >= total" @click="page++; loadHistory()">下一页</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { userApi } from '../api'
import ArtistLink from '../components/ArtistLink.vue'
import { usePlayerStore } from '../stores/player'

const router = useRouter()
const playerStore = usePlayerStore()
import { DEFAULT_AVATAR_COVER } from '../constants'
const defaultCover = DEFAULT_AVATAR_COVER

const history = ref<any[]>([])
const page = ref(1)
const pageSize = ref(20)
const total = ref(0)

const formatTime = (time: string) => {
  if (!time) return ''
  const date = new Date(time)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
  if (diff < 604800000) return `${Math.floor(diff / 86400000)}天前`
  
  return date.toLocaleDateString('zh-CN')
}

const loadHistory = async () => {
  try {
    const res = await userApi.getPlayHistory(page.value, pageSize.value)
    if (res.data.code === 200) {
      const data = res.data.data
      const raw = Array.isArray(data) ? data : (data?.records || [])
      history.value = raw.map((t: any) => ({
        ...t,
        coverUrl: t.coverUrl || t.cover,
        playUrl: t.playUrl || t.url,
        url: t.playUrl || t.url,
        artistId: t.artistId ?? t.singerId
      }))
      total.value = data?.total ?? (Array.isArray(data) ? data.length : 0)
    }
  } catch (e) {
    console.error('Failed to load history:', e)
  }
}

const formatDuration = (seconds?: number) => {
  if (!seconds) return '-'
  const mins = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

const onCoverError = (e: Event) => {
  const el = e.target as HTMLImageElement
  if (el) el.src = defaultCover
}

const playTrack = (track: any) => {
  playerStore.setPlaylistAndPlay(history.value, track)
}

const clearHistory = async () => {
  if (!confirm('确定要清空所有播放记录吗？')) return
  
  try {
    await userApi.clearPlayHistory()
    history.value = []
    total.value = 0
  } catch (e) {
    console.error('Failed to clear history:', e)
  }
}

// 删除单条记录
const deleteHistoryItem = async (historyId: number) => {
  try {
    await userApi.deletePlayHistoryItem(historyId)
    history.value = history.value.filter(item => item.historyId !== historyId)
    total.value--
  } catch (e) {
    console.error('Failed to delete history item:', e)
    alert('删除失败，请重试')
  }
}

onMounted(() => {
  loadHistory()
})
</script>

<style scoped>
.play-history-page {
  max-width: 900px;
  margin: 0 auto;
  padding: var(--sp-8);
  color: var(--text-primary);
  min-height: calc(100vh - 120px);
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--sp-8);
}

.page-header h2 {
  margin: 0;
  font-size: var(--text-lg);
}

.clear-btn {
  padding: var(--sp-2) var(--sp-5);
  background: rgba(239, 68, 68, 0.2);
  border: 1px solid rgba(239, 68, 68, 0.3);
  color: var(--red);
  border-radius: var(--radius-full);
  cursor: pointer;
  transition: all var(--dur-normal) var(--ease-out);
}

.clear-btn:hover {
  background: rgba(239, 68, 68, 0.3);
}

@keyframes slideInLeft {
  from {
    opacity: 0;
    transform: translateX(-20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.slide-in-left {
  animation: slideInLeft 0.4s var(--ease-out) forwards;
  opacity: 0;
}

.profile-track-list {
  background: var(--bg-hover);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.profile-track-list .track-row {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 14px var(--sp-5);
  cursor: pointer;
  transition: all var(--dur-fast) ease;
  border-bottom: 1px solid var(--border);
}

.profile-track-list .track-row:last-child {
  border-bottom: none;
}

.profile-track-list .track-row:hover {
  background: var(--accent-muted);
}

.profile-track-list .track-row .index {
  width: 30px;
  text-align: center;
  font-size: var(--text-base);
  font-weight: 500;
  color: var(--text-tertiary);
}

.profile-track-list .track-row:hover .index {
  color: var(--accent);
}

.profile-track-list .row-cover {
  width: 50px;
  height: 50px;
  border-radius: var(--radius-md);
  object-fit: cover;
  box-shadow: var(--shadow-sm);
  transition: transform var(--dur-fast);
}

.profile-track-list .row-cover-wrapper {
  position: relative;
  width: 50px;
  height: 50px;
}

.profile-track-list .row-play-overlay {
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

.profile-track-list .track-row:hover .row-play-overlay {
  opacity: 1;
}

.profile-track-list .row-play-btn {
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

.profile-track-list .row-play-btn:hover {
  transform: scale(1.1);
}

.profile-track-list .row-play-btn svg {
  margin-left: 2px;
}

.profile-track-list .track-row:hover .row-cover {
  transform: scale(1.05);
}

.profile-track-list .row-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.profile-track-list .row-info .title {
  font-size: var(--text-base);
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.profile-track-list .row-info .artist {
  font-size: var(--text-xs);
  color: var(--text-secondary);
}

.profile-track-list .duration {
  font-size: var(--text-sm);
  color: var(--text-tertiary);
  min-width: 45px;
  text-align: right;
}

.profile-track-list .play-time {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  min-width: 70px;
  text-align: right;
}

.profile-track-list .row-controls {
  display: flex;
  align-items: center;
  gap: 4px;
}

.profile-track-list .row-controls .ctrl-btn {
  background: transparent;
  border: none;
  color: var(--text-tertiary);
  cursor: pointer;
  padding: var(--sp-2);
  border-radius: 50%;
  transition: all var(--dur-fast);
  opacity: 0;
}

.profile-track-list .track-row:hover .row-controls .ctrl-btn {
  opacity: 1;
}

.profile-track-list .row-controls .ctrl-btn:hover {
  color: var(--accent);
}

.profile-track-list .row-controls .ctrl-btn.delete-btn:hover {
  color: var(--red);
  background: rgba(239, 68, 68, 0.1);
}

.empty {
  text-align: center;
  padding: var(--sp-16) var(--sp-5);
  color: var(--text-tertiary);
}

.empty .sub {
  font-size: var(--text-base);
  margin-top: var(--sp-3);
}

.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--sp-4);
  margin-top: var(--sp-8);
}

.pagination button {
  padding: var(--sp-2) var(--sp-4);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  background: transparent;
  color: var(--text-primary);
  cursor: pointer;
}

.pagination button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
