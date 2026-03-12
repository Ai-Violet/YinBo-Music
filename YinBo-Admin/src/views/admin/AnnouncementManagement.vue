<template>
  <div class="announce-page admin-page">
    <div class="admin-header">
      <h2 class="admin-page-title">公告管理</h2>
      <button class="admin-btn admin-btn-primary" @click="showCreate = true">发布公告</button>
    </div>

    <div class="announce-list">
      <div v-for="item in announcements" :key="item.id" class="announce-card admin-card">
        <div class="card-header">
          <span class="card-title">{{ item.title }}</span>
          <span class="status-badge" :class="item.status === 1 ? 'active' : 'disabled'">
            {{ item.status === 1 ? '展示中' : '已关闭' }}
          </span>
        </div>
        <p class="card-content">{{ item.content }}</p>
        <div class="card-footer">
          <span class="card-time">{{ formatTime(item.createdAt) }}</span>
          <div class="card-actions">
            <button class="admin-btn admin-btn-ghost" @click="toggleStatus(item)">
              {{ item.status === 1 ? '关闭' : '启用' }}
            </button>
            <button class="admin-btn admin-btn-danger" @click="deleteAnnounce(item.id)">删除</button>
          </div>
        </div>
      </div>

      <div v-if="announcements.length === 0" class="admin-empty">
        <p>暂无公告</p>
      </div>
    </div>

    <!-- Create dialog -->
    <div v-if="showCreate" class="admin-modal-overlay" @click.self="showCreate = false">
      <div class="admin-modal">
        <h3>发布新公告</h3>
        <div class="admin-form-group">
          <label>标题</label>
          <input v-model="form.title" class="admin-input" placeholder="公告标题" />
        </div>
        <div class="admin-form-group">
          <label>内容</label>
          <textarea v-model="form.content" class="admin-input textarea" rows="4" placeholder="公告内容"></textarea>
        </div>
        <div class="admin-modal-actions">
          <button class="admin-btn admin-btn-ghost" @click="showCreate = false">取消</button>
          <button class="admin-btn admin-btn-primary" :disabled="!form.title.trim()" @click="createAnnounce">发布</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { announcementApi } from '../../api'
import { ElMessage } from 'element-plus'

const announcements = ref<any[]>([])
const showCreate = ref(false)
const form = ref({ title: '', content: '' })

const loadAnnouncements = async () => {
  try {
    const res = await announcementApi.getAll(1, 50)
    if (res.data.code === 200) {
      announcements.value = res.data.data.records || []
    }
  } catch (e) {
    console.error('Failed to load announcements:', e)
  }
}

const createAnnounce = async () => {
  if (!form.value.title.trim()) return
  try {
    await announcementApi.create(form.value)
    ElMessage.success('公告已发布')
    showCreate.value = false
    form.value = { title: '', content: '' }
    await loadAnnouncements()
  } catch (e) {
    ElMessage.error('发布失败')
  }
}

const toggleStatus = async (item: any) => {
  try {
    await announcementApi.toggleStatus(item.id, item.status === 1 ? 0 : 1)
    item.status = item.status === 1 ? 0 : 1
    ElMessage.success(item.status === 1 ? '已启用' : '已关闭')
  } catch (e) {
    ElMessage.error('操作失败')
  }
}

const deleteAnnounce = async (id: number) => {
  if (!confirm('确定删除此公告？')) return
  try {
    await announcementApi.delete(id)
    announcements.value = announcements.value.filter(a => a.id !== id)
    ElMessage.success('已删除')
  } catch (e) {
    ElMessage.error('删除失败')
  }
}

const formatTime = (t: string) => {
  if (!t) return ''
  return new Date(t).toLocaleDateString('zh-CN', { year: 'numeric', month: '2-digit', day: '2-digit' })
}

onMounted(loadAnnouncements)
</script>

<style scoped>

.announce-list {
  display: flex;
  flex-direction: column;
  gap: var(--sp-4);
}

.announce-card {
  display: flex;
  flex-direction: column;
  gap: var(--sp-3);
  padding: var(--sp-5);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-title {
  font-size: var(--text-md);
  font-weight: 600;
  color: var(--text-primary);
}

.status-badge {
  font-size: var(--text-xs);
  padding: 2px 10px;
  border-radius: var(--radius-full);
  font-weight: 500;
}

.status-badge.active {
  background: rgba(34, 197, 94, 0.15);
  color: var(--green);
}

.status-badge.disabled {
  background: rgba(255, 255, 255, 0.06);
  color: var(--text-tertiary);
}

.card-content {
  font-size: var(--text-base);
  color: var(--text-secondary);
  line-height: 1.6;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-time {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

.card-actions {
  display: flex;
  gap: var(--sp-2);
}

.card-actions .danger {
  color: var(--red);
  border-color: rgba(239, 68, 68, 0.2);
}

.card-actions .danger:hover {
  background: rgba(239, 68, 68, 0.1);
}

.admin-form-group textarea {
  resize: vertical;
  min-height: 80px;
}
</style>
