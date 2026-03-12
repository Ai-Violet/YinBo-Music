<template>
  <div class="notifications-page">
    <div class="page-header">
      <button class="back-btn" @click="router.push('/home')">← 返回</button>
      <h1>消息通知</h1>
    </div>
    <div v-if="!userStore.currentUser" class="login-hint">
      请先 <router-link to="/login">登录</router-link> 查看通知
    </div>
    <div v-else class="content">
      <div v-if="loading" class="loading">加载中...</div>
      <div v-else-if="list.length === 0" class="empty">暂无消息</div>
      <div v-else class="notification-list">
        <div
          v-for="n in list"
          :key="n.id"
          class="notification-item"
          :class="{ unread: n.read === 0 }"
          @click="handleClick(n)"
        >
          <img :src="n.fromUserAvatar || defaultAvatar" class="n-avatar" alt="" />
          <div class="n-content">
            <p class="n-text">{{ formatText(n) }}</p>
            <span class="n-time">{{ formatTime(n.createdAt) }}</span>
          </div>
        </div>
      </div>
      <div v-if="hasMore && list.length > 0" class="load-more">
        <button class="load-more-btn" :disabled="loadingMore" @click="loadMore">
          {{ loadingMore ? '加载中...' : '加载更多' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { notificationApi, type NotificationItem } from '../api'
import { useUserStore } from '../stores/user'
import { DEFAULT_AVATAR_COVER } from '../constants'

const router = useRouter()
const userStore = useUserStore()
const defaultAvatar = DEFAULT_AVATAR_COVER

const list = ref<NotificationItem[]>([])
const loading = ref(true)
const loadingMore = ref(false)
const page = ref(1)
const total = ref(0)
const pageSize = 20

const hasMore = computed(() => list.value.length < total.value)

const load = async (append = false) => {
  if (append) loadingMore.value = true
  else loading.value = true
  try {
    const res = await notificationApi.getList(page.value, pageSize)
    if (res.data?.code === 200 && res.data?.data) {
      const d = res.data.data as any
      const records = d.records || []
      if (append) list.value.push(...records)
      else list.value = records
      total.value = d.total ?? 0
    }
  } catch (e) {
    console.error('Load notifications error:', e)
  } finally {
    loading.value = false
    loadingMore.value = false
  }
}

const loadMore = () => {
  page.value++
  load(true)
}

const handleClick = (n: NotificationItem) => {
  if (n.type === 'FOLLOW' && n.fromUserId) {
    router.push(`/profile/${n.fromUserId}`)
  } else if (n.extra) {
    router.push(`/track/${n.extra}`)
  }
}

const formatText = (n: NotificationItem) => {
  const name = n.fromUserNickname || '某人'
  if (n.type === 'FOLLOW') return `${name} 关注了你`
  if (n.type === 'COMMENT_REPLY') return `${name} 回复了你的评论`
  if (n.type === 'LIKE') return `${name} 赞了你的评论`
  return ''
}

const formatTime = (t: string) => {
  if (!t) return ''
  const d = new Date(t)
  const now = new Date()
  const diff = now.getTime() - d.getTime()
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
  if (diff < 604800000) return `${Math.floor(diff / 86400000)}天前`
  return d.toLocaleDateString('zh-CN')
}

onMounted(() => {
  if (userStore.currentUser) load()
  else loading.value = false
})
</script>

<style scoped>
.notifications-page {
  max-width: 600px;
  margin: 0 auto;
  padding: var(--sp-5);
}

.page-header {
  display: flex;
  align-items: center;
  gap: var(--sp-4);
  margin-bottom: var(--sp-6);
}

.back-btn {
  background: none;
  border: none;
  color: var(--text-secondary);
  cursor: pointer;
  font-size: var(--text-base);
}

.back-btn:hover {
  color: var(--accent);
}

.page-header h1 {
  margin: 0;
  font-size: var(--text-xl);
  color: var(--text-primary);
}

.login-hint {
  padding: var(--sp-10);
  text-align: center;
  color: var(--text-secondary);
}

.login-hint a {
  color: var(--accent);
}

.loading, .empty {
  text-align: center;
  padding: var(--sp-10);
  color: var(--text-secondary);
}

.notification-list {
  display: flex;
  flex-direction: column;
  gap: var(--sp-2);
}

.notification-item {
  display: flex;
  align-items: flex-start;
  gap: var(--sp-4);
  padding: var(--sp-4);
  background: var(--bg-hover);
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: background var(--dur-fast);
}

.notification-item:hover {
  background: var(--bg-elevated);
}

.notification-item.unread {
  background: rgba(var(--accent-rgb, 102, 126, 234), 0.08);
}

.n-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;
}

.n-content {
  flex: 1;
  min-width: 0;
}

.n-text {
  margin: 0 0 var(--sp-1);
  font-size: var(--text-sm);
  color: var(--text-primary);
}

.n-time {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

.load-more {
  display: flex;
  justify-content: center;
  padding: var(--sp-6);
}

.load-more-btn {
  padding: var(--sp-2) var(--sp-6);
  background: var(--bg-elevated);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-md);
  color: var(--text-secondary);
  cursor: pointer;
  font-size: var(--text-sm);
}

.load-more-btn:hover:not(:disabled) {
  color: var(--accent);
  border-color: var(--accent);
}

.load-more-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
</style>
