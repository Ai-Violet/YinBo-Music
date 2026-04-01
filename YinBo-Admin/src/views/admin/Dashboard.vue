<template>
  <div class="dashboard admin-page">
    <!-- 统计卡片 -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon users">
          <svg viewBox="0 0 24 24" width="32" height="32">
            <path fill="currentColor" d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5z"/>
          </svg>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.userCount }}</span>
          <span class="stat-label">用户总数</span>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon tracks">
          <svg viewBox="0 0 24 24" width="32" height="32">
            <path fill="currentColor" d="M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z"/>
          </svg>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.trackCount }}</span>
          <span class="stat-label">歌曲数量</span>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon playlists">
          <svg viewBox="0 0 24 24" width="32" height="32">
            <path fill="currentColor" d="M15 6H3v2h12V6zm0 4H3v2h12v-2zM3 16h8v-2H3v2zM17 6v8.18c-.31-.11-.65-.18-1-.18-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3V8h3V6h-5z"/>
          </svg>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.playlistCount }}</span>
          <span class="stat-label">歌单总数</span>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon plays">
          <svg viewBox="0 0 24 24" width="32" height="32">
            <path fill="currentColor" d="M8 5v14l11-7z"/>
          </svg>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ formatNumber(stats.playCount) }}</span>
          <span class="stat-label">总播放量</span>
        </div>
      </div>
    </div>

    <!-- 待审核区域 -->
    <div class="pending-section">
      <h2>待处理事项</h2>
      <div class="pending-grid">
        <div class="pending-card">
          <h3>待审核歌曲</h3>
          <div class="pending-count">{{ stats.pendingTracks }}</div>
          <router-link to="/tracks?status=0" class="view-link">
            查看详情 
          </router-link>
        </div>
      </div>
    </div>

    <!-- 快捷操作 -->
    <div class="quick-actions">
      <h2>快捷操作</h2>
      <div class="actions-grid">
        <router-link to="/upload" class="action-card">
          <svg viewBox="0 0 24 24" width="24" height="24">
            <path fill="currentColor" d="M9 16h6v-6h4l-7-7-7 7h4v6zm-4 2h14v2H5v-2z"/>
          </svg>
          <span>上传音乐</span>
        </router-link>
        <router-link to="/tracks" class="action-card">
          <svg viewBox="0 0 24 24" width="24" height="24">
            <path fill="currentColor" d="M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z"/>
          </svg>
          <span>歌曲管理</span>
        </router-link>
        <router-link to="/users" class="action-card">
          <svg viewBox="0 0 24 24" width="24" height="24">
            <path fill="currentColor" d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5z"/>
          </svg>
          <span>用户管理</span>
        </router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { adminApi } from '../../api'

const stats = ref({
  userCount: 0,
  trackCount: 0,
  playlistCount: 0,
  playCount: 0,
  pendingTracks: 0
})
let refreshTimer: number | null = null

const formatNumber = (num: number) => {
  if (num >= 10000) {
    return (num / 10000).toFixed(1) + '万'
  }
  return num.toString()
}

const loadStats = async () => {
  try {
    const res = await adminApi.getStats()
    if (res.data.code === 200) {
      stats.value = res.data.data
    }
  } catch (e) {
    console.error('Failed to load stats:', e)
  }
}

onMounted(() => {
  loadStats()
  refreshTimer = window.setInterval(loadStats, 10000)
})

onUnmounted(() => {
  if (refreshTimer !== null) {
    window.clearInterval(refreshTimer)
  }
})
</script>

<style scoped>
.dashboard.admin-page {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  overflow-x: hidden;
  padding: var(--sp-5);
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: var(--sp-5);
  margin-bottom: var(--sp-8);
}

.stat-card {
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  padding: var(--sp-6);
  display: flex;
  align-items: center;
  gap: var(--sp-5);
  border: 1px solid var(--border);
  transition: transform var(--dur-normal), box-shadow var(--dur-normal);
}
.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-icon.users {
  background: linear-gradient(135deg, var(--accent) 0%, var(--accent-hover) 100%);
}

.stat-icon.tracks {
  background: linear-gradient(135deg, var(--accent) 0%, var(--accent-hover) 100%);
  opacity: 0.9;
}

.stat-icon.playlists {
  background: linear-gradient(135deg, var(--accent) 0%, var(--accent-hover) 100%);
  opacity: 0.85;
}

.stat-icon.plays {
  background: var(--green);
}

.stat-info {
  display: flex;
  flex-direction: column;
}

.stat-value {
  font-size: var(--text-xl);
  font-weight: bold;
  color: var(--text-primary);
}

.stat-label {
  font-size: var(--text-base);
  color: var(--text-secondary);
}

.pending-section {
  margin-bottom: var(--sp-8);
}

.pending-section h2 {
  margin: 0 0 var(--sp-5);
  font-size: var(--text-lg);
  color: var(--text-primary);
}

.pending-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: var(--sp-5);
}

.pending-card {
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  padding: var(--sp-6);
  text-align: center;
}

.pending-card h3 {
  margin: 0 0 var(--sp-4);
  font-size: var(--text-base);
  color: var(--text-secondary);
}

.pending-count {
  font-size: 36px;
  font-weight: bold;
  color: var(--amber);
  margin-bottom: var(--sp-4);
}

.view-link {
  color: var(--accent);
  text-decoration: none;
  font-size: var(--text-base);
}

.view-link:hover {
  color: var(--accent-hover);
}

.quick-actions h2 {
  margin: 0 0 var(--sp-5);
  font-size: var(--text-lg);
  color: var(--text-primary);
}

.actions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: var(--sp-4);
}

.action-card {
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  padding: var(--sp-6);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--sp-4);
  text-decoration: none;
  color: var(--text-primary);
  transition: all var(--dur-normal) var(--ease-out);
  border: 1px solid var(--border);
}

.action-card:hover {
  background: var(--bg-elevated);
  transform: translateY(-3px);
  box-shadow: var(--shadow-md);
  border-color: var(--border-hover);
}
.action-card svg {
  opacity: 0.9;
}
</style>