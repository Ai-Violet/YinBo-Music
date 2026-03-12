<template>
  <div class="comment-management admin-page">
    <div class="admin-header">
      <h2 class="admin-page-title">评论管理</h2>
      <div class="toolbar-actions">
        <input v-model="trackIdFilter" type="number" placeholder="歌曲ID筛选" class="admin-input filter-input" @keyup.enter="handleRefresh" />
        <button class="admin-btn admin-btn-primary" @click="handleRefresh" :disabled="loading">刷新</button>
      </div>
    </div>

    <div v-if="loading" class="admin-empty">加载中...</div>

    <div v-else-if="comments.length === 0" class="admin-empty">暂无评论</div>

    <div v-else class="comment-list admin-card">
      <div v-for="item in comments" :key="item.id" class="comment-card">
        <div class="header">
          <span class="user">{{ item.userNickname || item.username || '匿名用户' }}</span>
          <span class="time">{{ item.createdAt }}</span>
        </div>
        <div class="content">{{ item.content }}</div>
        <div class="meta">
          <span v-if="item.trackTitle">《{{ item.trackTitle }}》</span>
          <span v-if="item.trackArtist"> - {{ item.trackArtist }}</span>
          <span> · 歌曲ID: {{ item.trackId }}</span>
          <span> · 点赞: {{ item.likeCount || 0 }}</span>
        </div>
        <div class="actions">
          <a :href="commentUrl(item.trackId)" target="_blank" rel="noopener" class="admin-btn admin-btn-ghost jump-btn">跳转到评论区</a>
          <button class="admin-btn admin-btn-danger" @click="remove(item.id)">删除</button>
        </div>
      </div>
    </div>

    <div v-if="total > pageSize" class="admin-pagination">
      <button :disabled="page <= 1" @click="page--; loadComments()">上一页</button>
      <span>{{ page }} / {{ Math.ceil(total / pageSize) }}</span>
      <button :disabled="page * pageSize >= total" @click="page++; loadComments()">下一页</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { adminApi } from '../../api'

const comments = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(20)
const total = ref(0)
const trackIdFilter = ref('')

const commentUrl = (trackId: number) => {
  const base = window.location.origin
  return `${base}/track/${trackId}`
}

const handleRefresh = () => {
  page.value = 1
  loadComments()
}

const loadComments = async () => {
  loading.value = true
  try {
    const trackId = trackIdFilter.value ? Number(trackIdFilter.value) : undefined
    const res = await adminApi.getAllComments(page.value, pageSize.value, trackId)
    if (res.data.code === 200) {
      const data = res.data.data
      comments.value = data?.records || []
      total.value = data?.total ?? 0
    }
  } finally {
    loading.value = false
  }
}

const remove = async (id: number) => {
  if (!confirm('确定删除该评论？')) return
  try {
    await adminApi.deleteComment(id)
    await loadComments()
  } catch (e) {
    console.error('Delete comment failed:', e)
  }
}

onMounted(loadComments)
</script>

<style scoped>
.toolbar-actions {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
}

.filter-input {
  width: 130px;
}

.comment-list {
  display: grid;
  gap: var(--sp-3);
  padding: var(--sp-4);
}

.comment-card {
  background: var(--bg-secondary);
  border-radius: var(--radius-md);
  padding: var(--sp-4);
  border: 1px solid var(--border);
}

.header {
  display: flex;
  justify-content: space-between;
  margin-bottom: var(--sp-2);
  color: var(--text-primary);
}

.content {
  margin-bottom: var(--sp-2);
  line-height: 1.6;
}

.meta {
  color: var(--text-secondary);
  font-size: var(--text-xs);
  margin-bottom: var(--sp-3);
}

.actions {
  display: flex;
  gap: var(--sp-3);
}

.jump-btn {
  color: var(--accent) !important;
  text-decoration: none;
}
</style>
