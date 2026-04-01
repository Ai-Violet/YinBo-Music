<template>
  <div class="singer-page admin-page page-stack">
    <section class="admin-surface page-intro admin-shrink-0">
      <div class="intro-row">
        <div>
          <h2 class="admin-page-title">歌手管理</h2>
          <p class="admin-muted">维护歌手资料；预览链接跳转用户端（新标签打开）。</p>
        </div>
        <div class="intro-actions">
          <el-input
            v-model="searchKeyword"
            placeholder="搜索歌手名称"
            clearable
            class="search-field"
            @clear="doSearch"
            @keyup.enter="doSearch"
            @input="scheduleSearch"
          />
          <el-button type="primary" @click="openAddModal">+ 添加歌手</el-button>
        </div>
      </div>
    </section>

    <section class="admin-surface scroll-fill table-wrap">
      <div class="table-scroll-inner">
        <el-table v-loading="loading" :data="singers" stripe class="data-table" empty-text="暂无歌手" row-key="id">
          <el-table-column label="头像" width="76" align="center">
            <template #default="{ row }">
              <img :src="row.avatarUrl || defaultAvatar" alt="" class="singer-avatar" @error="onAvatarError" />
            </template>
          </el-table-column>
          <el-table-column prop="id" label="ID" width="72" />
          <el-table-column label="名称" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              <a :href="singerPublicUrl(row.id)" target="_blank" rel="noopener" class="singer-link">{{ row.name }}</a>
            </template>
          </el-table-column>
          <el-table-column label="简介" min-width="200" show-overflow-tooltip>
            <template #default="{ row }">{{ row.description || '—' }}</template>
          </el-table-column>
          <el-table-column label="操作" width="160" fixed="right" align="right">
            <template #default="{ row }">
              <el-button link type="primary" size="small" @click="openEditModal(row)">编辑</el-button>
              <el-button link type="danger" size="small" @click="handleDelete(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
      <div v-if="total > 0" class="pager-bar admin-shrink-0">
        <el-pagination
          :current-page="page"
          :page-size="pageSize"
          :total="total"
          layout="total, prev, pager, next, jumper"
          background
          @current-change="onPageChange"
        />
      </div>
    </section>

    <div v-if="showModal" class="admin-modal-overlay" @click.self="closeModal">
      <div class="admin-modal singer-modal">
        <h3>{{ editId ? '编辑歌手' : '添加歌手' }}</h3>
        <div class="admin-form-group">
          <label>歌手名称 *</label>
          <input v-model="form.name" placeholder="请输入歌手名称" />
        </div>
        <div class="admin-form-group">
          <label>歌手头像</label>
          <div class="avatar-upload-wrap">
            <div class="avatar-upload" @click="triggerAvatarInput">
              <input ref="avatarInput" type="file" accept="image/*" @change="handleAvatarSelect" hidden />
              <img v-if="avatarPreview" :src="avatarPreview" alt="预览" class="avatar-preview" />
              <img v-else-if="editId && currentAvatar" :src="currentAvatar" alt="当前头像" class="avatar-preview" />
              <div v-else class="avatar-placeholder">
                <span>点击上传</span>
              </div>
            </div>
            <div v-if="avatarPreview || (editId && currentAvatar)" class="avatar-edit-actions">
              <button type="button" class="edit-avatar-btn" @click="openAvatarCropper" title="裁剪/调整">
                <span>编辑</span>
              </button>
              <button v-if="avatarPreview" type="button" class="clear-avatar-btn" @click="clearAvatar">清除</button>
            </div>
          </div>
          <p class="avatar-hint">{{ editId && (currentAvatar || avatarPreview) ? '点击头像可更换，点击「编辑」可裁剪调整' : '' }}</p>
        </div>
        <div class="admin-form-group">
          <label>简介（可选）</label>
          <textarea v-model="form.description" placeholder="歌手简介" rows="3"></textarea>
        </div>
        <div class="admin-modal-actions">
          <button class="admin-btn admin-btn-ghost" @click="closeModal">取消</button>
          <button class="admin-btn admin-btn-primary" @click="handleSave" :disabled="saving || !form.name.trim()">
            {{ saving ? '保存中...' : '保存' }}
          </button>
        </div>
      </div>
    </div>

    <AvatarCropper v-model="showAvatarCropper" :image-url="avatarCropperImageUrl" @confirm="handleAvatarCropConfirm" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { adminApi } from '../../api'
import AvatarCropper from '../../components/AvatarCropper.vue'

const clientBase = (import.meta.env.VITE_CLIENT_URL || '').replace(/\/$/, '')
const defaultAvatar = 'https://via.placeholder.com/60?text=?'

const singerPublicUrl = (id: number) => `${clientBase}/singer/${id}`

const singers = ref<any[]>([])
const loading = ref(false)
const total = ref(0)
const page = ref(1)
const pageSize = ref(20)
const searchKeyword = ref('')
const searchTimer = ref<ReturnType<typeof setTimeout> | null>(null)

const showModal = ref(false)
const editId = ref<number | null>(null)
const form = ref({ name: '', description: '' })
const avatarFile = ref<File | null>(null)
const avatarPreview = ref('')
const currentAvatar = ref('')
const avatarInput = ref<HTMLInputElement | null>(null)
const showAvatarCropper = ref(false)
const avatarCropperImageUrl = ref('')
const saving = ref(false)

const loadSingers = async () => {
  loading.value = true
  try {
    const res = await adminApi.listSingers(page.value, pageSize.value, searchKeyword.value.trim() || undefined)
    if (res.data.code === 200 && res.data.data) {
      const d = res.data.data
      singers.value = d.records || []
      total.value = d.total ?? 0
    }
  } catch (e) {
    console.error(e)
    singers.value = []
  } finally {
    loading.value = false
  }
}

const doSearch = () => {
  page.value = 1
  loadSingers()
}

const scheduleSearch = () => {
  if (searchTimer.value) clearTimeout(searchTimer.value)
  searchTimer.value = setTimeout(() => {
    page.value = 1
    loadSingers()
  }, 320)
}

const onPageChange = (p: number) => {
  page.value = p
  loadSingers()
}

const onAvatarError = (e: Event) => {
  const el = e.target as HTMLImageElement
  if (el) el.src = defaultAvatar
}

const triggerAvatarInput = () => avatarInput.value?.click()

const handleAvatarSelect = (e: Event) => {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (file) {
    const reader = new FileReader()
    reader.onload = () => {
      avatarCropperImageUrl.value = reader.result as string
      showAvatarCropper.value = true
    }
    reader.readAsDataURL(file)
  }
  ;(e.target as HTMLInputElement).value = ''
}

const openAvatarCropper = () => {
  const src = avatarPreview.value || currentAvatar.value
  if (src) {
    avatarCropperImageUrl.value = src
    showAvatarCropper.value = true
  }
}

const handleAvatarCropConfirm = (blob: Blob) => {
  avatarFile.value = new File([blob], 'avatar.jpg', { type: 'image/jpeg' })
  const reader = new FileReader()
  reader.onload = () => { avatarPreview.value = reader.result as string }
  reader.readAsDataURL(blob)
  showAvatarCropper.value = false
}

const clearAvatar = () => {
  avatarFile.value = null
  avatarPreview.value = ''
}

const openAddModal = () => {
  editId.value = null
  form.value = { name: '', description: '' }
  avatarFile.value = null
  avatarPreview.value = ''
  currentAvatar.value = ''
  showModal.value = true
}

const openEditModal = (s: any) => {
  editId.value = s.id
  form.value = { name: s.name, description: s.description || '' }
  avatarFile.value = null
  avatarPreview.value = ''
  currentAvatar.value = s.avatarUrl || ''
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
}

const handleSave = async () => {
  if (!form.value.name.trim()) return
  saving.value = true
  try {
    const fd = new FormData()
    fd.append('name', form.value.name.trim())
    if (form.value.description.trim()) {
      fd.append('description', form.value.description.trim())
    }
    if (avatarFile.value) {
      fd.append('avatar', avatarFile.value)
    }

    if (editId.value) {
      await adminApi.updateSinger(editId.value, fd)
      alert('更新成功')
    } else {
      await adminApi.createSinger(fd)
      alert('添加成功')
    }
    closeModal()
    loadSingers()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '操作失败')
  } finally {
    saving.value = false
  }
}

const handleDelete = async (s: any) => {
  if (!confirm(`确定删除歌手「${s.name}」？关联该歌手的歌曲将保留，但歌手将不可用。`)) return
  try {
    await adminApi.deleteSinger(s.id)
    loadSingers()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '删除失败')
  }
}

onMounted(loadSingers)
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

.intro-actions {
  display: flex;
  flex-wrap: wrap;
  gap: var(--sp-3);
  align-items: center;
}

.search-field {
  width: 220px;
}

.table-wrap {
  padding: 0;
}

.pager-bar {
  display: flex;
  justify-content: flex-end;
  padding: var(--sp-4) var(--sp-5);
  border-top: 1px solid color-mix(in srgb, var(--border) 80%, transparent);
}

.singer-avatar {
  width: 44px;
  height: 44px;
  border-radius: var(--radius-md);
  object-fit: cover;
}

.singer-link {
  color: var(--accent);
  text-decoration: none;
}

.singer-link:hover {
  text-decoration: underline;
}

.data-table :deep(.el-table__header th) {
  font-weight: 600;
  font-size: var(--text-xs);
  letter-spacing: 0.04em;
  color: var(--text-secondary);
  background: color-mix(in srgb, var(--bg-hover) 88%, #e8f5ef 12%) !important;
}

.avatar-upload-wrap {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: var(--sp-2);
}

.avatar-upload {
  width: 100px;
  height: 100px;
  border: 1px dashed var(--border);
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  overflow: hidden;
}

.avatar-placeholder {
  text-align: center;
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

.avatar-preview {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-edit-actions {
  display: flex;
  gap: var(--sp-2);
}

.edit-avatar-btn {
  padding: var(--sp-1) var(--sp-3);
  font-size: var(--text-xs);
  border: 1px solid var(--accent);
  border-radius: var(--radius-sm);
  background: transparent;
  cursor: pointer;
  color: var(--accent);
}

.clear-avatar-btn {
  padding: var(--sp-1) var(--sp-3);
  font-size: var(--text-xs);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  background: transparent;
  cursor: pointer;
  color: var(--text-secondary);
}

.avatar-hint {
  margin: var(--sp-2) 0 0;
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

.admin-form-group input,
.admin-form-group textarea {
  width: 100%;
  padding: var(--sp-3);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  background: var(--bg-hover);
  color: var(--text-primary);
}

.admin-form-group textarea {
  resize: vertical;
  min-height: 60px;
}
</style>
