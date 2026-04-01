<template>
  <div class="announce-page admin-page page-stack">
    <section class="admin-surface page-intro admin-shrink-0">
      <div class="intro-row">
        <div>
          <h2 class="admin-page-title">公告管理</h2>
          <p class="admin-muted">用户端首页/弹窗展示的公告；列表单独滚动，及时开关展示状态。</p>
        </div>
        <el-button type="primary" @click="openCreate">发布公告</el-button>
      </div>
    </section>

    <section class="admin-surface scroll-fill table-wrap">
      <div class="table-scroll-inner">
        <el-table :data="announcements" stripe class="data-table" empty-text="暂无公告" row-key="id">
          <el-table-column prop="title" label="标题" min-width="160" show-overflow-tooltip />
          <el-table-column label="内容摘要" min-width="240" show-overflow-tooltip>
            <template #default="{ row }">{{ row.content }}</template>
          </el-table-column>
          <el-table-column label="状态" width="100" align="center">
            <template #default="{ row }">
              <span class="status-badge" :class="row.status === 1 ? 'active' : 'off'">
                {{ row.status === 1 ? '展示中' : '已关闭' }}
              </span>
            </template>
          </el-table-column>
          <el-table-column label="时间" width="120" show-overflow-tooltip>
            <template #default="{ row }">{{ formatTime(row.createdAt) }}</template>
          </el-table-column>
          <el-table-column label="操作" width="200" fixed="right" align="right">
            <template #default="{ row }">
              <el-button link type="primary" size="small" @click="toggleStatus(row)">
                {{ row.status === 1 ? '关闭' : '启用' }}
              </el-button>
              <el-button link type="danger" size="small" @click="deleteAnnounce(row.id)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </section>

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
    const res = await announcementApi.getAll(1, 100)
    if (res.data.code === 200) {
      announcements.value = res.data.data.records || []
    }
  } catch (e) {
    console.error('Failed to load announcements:', e)
  }
}

const openCreate = () => {
  form.value = { title: '', content: '' }
  showCreate.value = true
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
    announcements.value = announcements.value.filter((a) => a.id !== id)
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
.intro-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: var(--sp-5);
  flex-wrap: wrap;
}

.page-intro .admin-page-title {
  margin-bottom: var(--sp-2);
}

.table-wrap {
  padding: 0;
}

.data-table :deep(.el-table__header th) {
  font-weight: 600;
  font-size: var(--text-xs);
  letter-spacing: 0.04em;
  color: var(--text-secondary);
  background: color-mix(in srgb, var(--bg-hover) 88%, #e8f5ef 12%) !important;
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

.status-badge.off {
  background: rgba(255, 255, 255, 0.06);
  color: var(--text-tertiary);
}

.admin-form-group textarea.textarea {
  resize: vertical;
  min-height: 80px;
}
</style>
