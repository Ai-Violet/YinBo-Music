<template>
  <div class="singer-page admin-page">
    <div class="admin-header">
      <h2 class="admin-page-title">歌手管理</h2>
      <div class="header-right">
        <input
          v-model="searchKeyword"
          type="text"
          placeholder="搜索歌手名称"
          class="admin-input search-input"
          @input="onSearchInput"
        />
        <button class="admin-btn admin-btn-primary" @click="openAddModal">+ 添加歌手</button>
      </div>
    </div>

    <div class="admin-table-wrap admin-card">
      <table class="admin-table data-table">
        <thead>
          <tr>
            <th>头像</th>
            <th>ID</th>
            <th>歌手名称</th>
            <th>简介</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="s in singers" :key="s.id">
            <td>
              <img :src="s.avatarUrl || defaultAvatar" alt="头像" class="singer-avatar" @error="onAvatarError" />
            </td>
            <td>{{ s.id }}</td>
            <td>
              <a :href="'/singer/' + s.id" target="_blank" class="singer-link">{{ s.name }}</a>
            </td>
            <td class="desc-cell">{{ s.description || '-' }}</td>
            <td>
              <button class="admin-btn admin-btn-ghost" @click="openEditModal(s)">编辑</button>
              <button class="admin-btn admin-btn-danger" @click="handleDelete(s)">删除</button>
            </td>
          </tr>
          <tr v-if="loading">
            <td colspan="5" class="admin-empty-cell">加载中...</td>
          </tr>
          <tr v-else-if="!singers.length">
            <td colspan="5" class="admin-empty-cell">暂无歌手，请点击「添加歌手」</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="admin-pagination" v-if="total > pageSize">
      <button :disabled="page <= 1" @click="page--; loadSingers()">上一页</button>
      <span>{{ page }} / {{ Math.ceil(total / pageSize) }}</span>
      <button :disabled="page * pageSize >= total" @click="page++; loadSingers()">下一页</button>
    </div>

    <!-- 添加/编辑弹窗 -->
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

    <!-- 头像裁剪弹窗 -->
    <AvatarCropper
      v-model="showAvatarCropper"
      :image-url="avatarCropperImageUrl"
      @confirm="handleAvatarCropConfirm"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { adminApi } from '../../api'
import AvatarCropper from '../../components/AvatarCropper.vue'

const defaultAvatar = 'https://via.placeholder.com/60?text=?'

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

const onSearchInput = () => {
  if (searchTimer.value) clearTimeout(searchTimer.value)
  searchTimer.value = setTimeout(() => {
    page.value = 1
    loadSingers()
  }, 300)
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
  if (!confirm(`确定删除歌手「${s.name}」？关联该歌手的歌曲将保留，但歌手主页将不再显示。`)) return
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
.header-right {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
}

.search-input {
  min-width: 200px;
}

.singer-avatar {
  width: 48px;
  height: 48px;
  border-radius: var(--radius-md);
  object-fit: cover;
}
.desc-cell {
  max-width: 200px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.singer-link {
  color: var(--accent);
  text-decoration: none;
}
.singer-link:hover { text-decoration: underline; }
.empty { text-align: center; color: var(--text-tertiary); }
.action-btn {
  padding: var(--sp-2) var(--sp-4);
  margin-right: var(--sp-2);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  background: var(--bg-hover);
  cursor: pointer;
  color: var(--text-primary);
}
.action-btn.danger { border-color: var(--red); color: var(--red); }
.action-btn:hover { opacity: 0.9; }

.pagination {
  display: flex;
  align-items: center;
  gap: var(--sp-4);
  margin-top: var(--sp-5);
}
.pagination button {
  padding: var(--sp-2) var(--sp-4);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  background: var(--bg-hover);
  cursor: pointer;
  color: var(--text-primary);
}
.pagination button:disabled { opacity: 0.5; cursor: not-allowed; }

.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
.modal-content {
  background: var(--bg-card);
  padding: var(--sp-8);
  border-radius: var(--radius-lg);
  width: 420px;
  max-width: 90%;
}
.modal-content h3 { margin: 0 0 var(--sp-5); }
.form-group { margin-bottom: var(--sp-4); }
.form-group label { display: block; margin-bottom: var(--sp-2); }
.form-group input, .form-group textarea {
  width: 100%;
  padding: var(--sp-3);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  background: var(--bg-hover);
  color: var(--text-primary);
}
.form-group textarea { resize: vertical; min-height: 60px; }

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
.avatar-placeholder { text-align: center; font-size: var(--text-xs); color: var(--text-tertiary); }
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
.edit-avatar-btn:hover {
  background: var(--accent-muted);
}
.avatar-hint {
  margin: var(--sp-2) 0 0;
  font-size: var(--text-xs);
  color: var(--text-tertiary);
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

.admin-form-group input,
.admin-form-group textarea {
  width: 100%;
}

.admin-form-group textarea { resize: vertical; min-height: 60px; }
</style>
