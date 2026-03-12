<template>
  <div class="play-history-page">
    <div class="page-header">
      <h2>播放记录</h2>
      <button class="clear-btn" @click="clearHistory" v-if="history.length > 0">
        清空记录
      </button>
    </div>

    <div class="history-list" v-if="history.length > 0">
      <div 
        v-for="item in history" 
        :key="item.id" 
        class="history-item"
        @click="playTrack(item.track)"
      >
        <img :src="item.track.coverUrl || defaultCover" alt="封面" class="track-cover" />
        <div class="track-info">
          <h4>{{ item.track.title }}</h4>
          <p><ArtistLink :artist-id="item.track.artistId" :artist-name="item.track.artist" /></p>
        </div>
        <div class="play-info">
          <span class="play-time">播放 {{ item.playCount || 1 }} 次</span>
          <span class="last-play">最近: {{ formatTime(item.lastPlayedAt) }}</span>
        </div>
        <div class="item-actions">
          <button class="play-btn" @click.stop="playTrack(item.track)" title="播放">
            <svg viewBox="0 0 24 24" width="24" height="24">
              <path fill="currentColor" d="M8 5v14l11-7z"/>
            </svg>
          </button>
          <button class="delete-btn" @click.stop="deleteHistoryItem(item.id)" title="删除记录">
            <svg viewBox="0 0 24 24" width="18" height="18">
              <path fill="currentColor" d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/>
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
      history.value = res.data.data.records || []
      total.value = res.data.data.total || 0
    }
  } catch (e) {
    console.error('Failed to load history:', e)
  }
}

const playTrack = (track: any) => {
  playerStore.setCurrentTrack(track)
  playerStore.play()
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
    // 从列表中移除
    history.value = history.value.filter(item => item.id !== historyId)
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

.history-list {
  display: flex;
  flex-direction: column;
  gap: var(--sp-3);
}

.history-item {
  display: flex;
  align-items: center;
  gap: var(--sp-4);
  padding: var(--sp-4) var(--sp-5);
  background: var(--bg-hover);
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all var(--dur-normal) var(--ease-out);
}

.history-item:hover {
  background: var(--border-hover);
  transform: translateX(5px);
}

.track-cover {
  width: 50px;
  height: 50px;
  border-radius: var(--radius-sm);
  object-fit: cover;
  flex-shrink: 0;
}

.track-info {
  flex: 1;
}

.track-info h4 {
  margin: 0 0 var(--sp-1);
  font-size: var(--text-base);
}

.track-info p {
  margin: 0;
  font-size: var(--text-sm);
  color: var(--text-secondary);
}

.play-info {
  text-align: right;
  flex-shrink: 0;
}

.play-time {
  display: block;
  font-size: var(--text-sm);
  color: var(--accent);
  margin-bottom: var(--sp-1);
}

.last-play {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

.play-btn {
  width: 40px;
  height: 40px;
  border: none;
  background: var(--accent);
  color: var(--text-primary);
  border-radius: var(--radius-full);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: all var(--dur-normal) var(--ease-out);
}

.play-btn:hover {
  background: var(--accent-hover);
  transform: scale(1.1);
}

.item-actions {
  display: flex;
  align-items: center;
  gap: var(--sp-2);
}

.delete-btn {
  width: 32px;
  height: 32px;
  border: none;
  background: rgba(239, 68, 68, 0.15);
  color: var(--red);
  border-radius: var(--radius-full);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: all var(--dur-normal) var(--ease-out);
  opacity: 0;
}

.history-item:hover .delete-btn {
  opacity: 1;
}

.delete-btn:hover {
  background: rgba(239, 68, 68, 0.25);
  transform: scale(1.1);
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
