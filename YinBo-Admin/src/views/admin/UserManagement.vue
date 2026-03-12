<template>
  <div class="user-management admin-page">
    <!-- Toolbar -->
    <div class="admin-header toolbar">
      <div class="toolbar-left">
        <h2 class="admin-page-title" style="margin:0;flex-shrink:0">用户管理</h2>
        <input v-model="searchKeyword" class="admin-input search-input" type="text" placeholder="搜索用户名或邮箱..." @keyup.enter="searchUsers" />
        <button class="admin-btn admin-btn-primary" @click="searchUsers">搜索</button>
      </div>
      <div class="toolbar-right">
        <template v-if="selectedIds.length > 0">
          <span class="selected-count">已选 {{ selectedIds.length }} 人</span>
          <button class="admin-btn admin-btn-ghost" @click="batchAction(1)">批量封禁</button>
          <button class="admin-btn admin-btn-ghost" @click="batchAction(0)">批量解封</button>
        </template>
        <button class="admin-btn admin-btn-ghost" @click="exportCSV">导出 CSV</button>
      </div>
    </div>

    <!-- Table -->
    <div class="admin-table-wrap admin-card">
      <table class="admin-table">
        <thead>
          <tr>
            <th class="col-check"><input type="checkbox" :checked="isAllSelected" @change="toggleSelectAll" /></th>
            <th>用户</th>
            <th>邮箱</th>
            <th>角色</th>
            <th>状态</th>
            <th>注册时间</th>
            <th class="col-action">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="user in users" :key="user.id" :class="{ 'row-selected': selectedIds.includes(user.id) }">
            <td class="col-check"><input type="checkbox" :checked="selectedIds.includes(user.id)" @change="toggleSelect(user.id)" /></td>
            <td>
              <div class="user-cell">
                <img :src="user.avatar || '/花君.png'" alt="" class="avatar" @error="handleAvatarError" />
                <span>{{ user.nickname || user.username }}</span>
              </div>
            </td>
            <td class="text-secondary">{{ user.email }}</td>
            <td><span class="badge" :class="user.role?.toLowerCase()">{{ user.role }}</span></td>
            <td><span class="badge" :class="user.status === 0 ? 'ok' : 'ban'">{{ user.status === 0 ? '正常' : '封禁' }}</span></td>
            <td class="text-tertiary">{{ formatDate(user.createdAt) }}</td>
            <td>
              <div class="actions">
                <button class="act-btn" @click="viewProfile(user.id)">查看主页</button>
                <button v-if="user.status === 0" class="act-btn warn" @click="handleDisable(user)">封禁</button>
                <button v-else class="act-btn ok" @click="updateStatus(user.id, 0)">解封</button>
                <button class="act-btn danger" @click="handleDelete(user)">注销</button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="users.length === 0" class="admin-empty"><p>暂无用户数据</p></div>

    <!-- Pagination -->
    <div v-if="users.length > 0" class="admin-pagination">
      <button :disabled="page === 1" @click="page--; loadUsers()">上一页</button>
      <span class="page-info">第 {{ page }} 页</span>
      <button :disabled="users.length < size" @click="page++; loadUsers()">下一页</button>
    </div>

    <!-- Admin key modal -->
    <div v-if="showKeyModal" class="admin-modal-overlay" @click.self="closeKeyModal">
      <div class="admin-modal">
        <h3>{{ modalTitle }}</h3>
        <p class="modal-desc">此操作需要管理员密钥验证</p>
        <input v-model="adminKeyInput" class="admin-input" type="password" placeholder="请输入管理员密钥" @keyup.enter="confirmAction" />
        <p v-if="keyError" class="key-error">{{ keyError }}</p>
        <div class="admin-modal-actions">
          <button class="admin-btn admin-btn-ghost" @click="closeKeyModal">取消</button>
          <button class="admin-btn admin-btn-primary" @click="confirmAction">确认</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { adminApi } from '../../api'
import { ElMessage } from 'element-plus'

const users = ref<any[]>([])
const page = ref(1)
const size = ref(20)
const searchKeyword = ref('')
const selectedIds = ref<number[]>([])

const showKeyModal = ref(false)
const modalTitle = ref('')
const adminKeyInput = ref('')
const keyError = ref('')
const pendingAction = ref<any>(null)

const isAllSelected = computed(() => users.value.length > 0 && selectedIds.value.length === users.value.length)

const toggleSelectAll = () => {
  selectedIds.value = isAllSelected.value ? [] : users.value.map(u => u.id)
}

const toggleSelect = (id: number) => {
  const i = selectedIds.value.indexOf(id)
  i >= 0 ? selectedIds.value.splice(i, 1) : selectedIds.value.push(id)
}

const formatDate = (d: string) => d ? new Date(d).toLocaleDateString('zh-CN') : '-'

const loadUsers = async () => {
  try {
    const res = await adminApi.getUsers(page.value, size.value, searchKeyword.value)
    if (res.data.code === 200) { users.value = res.data.data.records || []; selectedIds.value = [] }
  } catch (e) { console.error(e) }
}

const searchUsers = () => { page.value = 1; loadUsers() }

const batchAction = async (status: number) => {
  if (selectedIds.value.length === 0) return
  const label = status === 1 ? '封禁' : '解封'
  if (!confirm(`确定${label}选中的 ${selectedIds.value.length} 个用户？`)) return
  try {
    await adminApi.batchUpdateUserStatus(selectedIds.value, status)
    ElMessage.success(`已${label} ${selectedIds.value.length} 个用户`)
    loadUsers()
  } catch (e) { ElMessage.error('操作失败') }
}

const exportCSV = () => {
  if (users.value.length === 0) { ElMessage.warning('无数据可导出'); return }
  const header = 'ID,用户名,昵称,邮箱,角色,状态,注册时间\n'
  const rows = users.value.map(u =>
    `${u.id},"${u.username || ''}","${u.nickname || ''}","${u.email || ''}",${u.role},${u.status === 0 ? '正常' : '封禁'},"${formatDate(u.createdAt)}"`
  ).join('\n')
  const blob = new Blob(['\uFEFF' + header + rows], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url; a.download = `users_${new Date().toISOString().slice(0,10)}.csv`; a.click()
  URL.revokeObjectURL(url)
  ElMessage.success('导出成功')
}

const handleDisable = (user: any) => {
  if (user.role === 'ADMIN') {
    modalTitle.value = '封禁管理员'; pendingAction.value = { type: 'disable', userId: user.id, status: 1 }
    showKeyModal.value = true; adminKeyInput.value = ''; keyError.value = ''
  } else { updateStatus(user.id, 1) }
}

const handleDelete = (user: any) => {
  modalTitle.value = '注销用户'; pendingAction.value = { type: 'delete', userId: user.id }
  showKeyModal.value = true; adminKeyInput.value = ''; keyError.value = ''
}

const closeKeyModal = () => { showKeyModal.value = false; pendingAction.value = null }

const confirmAction = async () => {
  if (!adminKeyInput.value) { keyError.value = '请输入密钥'; return }
  if (!pendingAction.value) return
  try {
    if (pendingAction.value.type === 'delete') {
      await adminApi.deleteUser(pendingAction.value.userId, adminKeyInput.value)
    } else {
      await adminApi.updateUserStatus(pendingAction.value.userId, pendingAction.value.status, adminKeyInput.value)
    }
    closeKeyModal(); loadUsers()
  } catch (e: any) { keyError.value = e?.response?.data?.message || '操作失败' }
}

const updateStatus = async (userId: number, status: number) => {
  try { await adminApi.updateUserStatus(userId, status); loadUsers() } catch (e) { console.error(e) }
}

const handleAvatarError = (e: Event) => {
  const img = e.target as HTMLImageElement
  img.onerror = null
  img.src = '/花君.png'
}

const clientUrl = import.meta.env.VITE_CLIENT_URL || 'http://localhost:8081'
const viewProfile = (id: number) => window.open(`${clientUrl}/profile/${id}`, '_blank')

onMounted(loadUsers)
</script>

<style scoped>
.toolbar-left { display: flex; gap: var(--sp-3); flex: 1; min-width: 240px; }
.toolbar-right { display: flex; gap: var(--sp-2); align-items: center; }
.search-input { max-width: 300px; }
.selected-count { font-size: var(--text-sm); color: var(--accent); font-weight: 600; }

.col-check { width: 40px; text-align: center; }
.col-action { text-align: center; }

tr:hover { background: var(--bg-hover); }
.row-selected { background: var(--accent-muted) !important; }

.user-cell { display: flex; align-items: center; gap: var(--sp-3); }
.avatar { width: 32px; height: 32px; border-radius: var(--radius-full); object-fit: cover; }
.text-secondary { color: var(--text-secondary); }
.text-tertiary { color: var(--text-tertiary); font-size: var(--text-sm); }

.badge {
  display: inline-block;
  padding: 2px var(--sp-2);
  border-radius: var(--radius-full);
  font-size: var(--text-xs);
  font-weight: 500;
}
.badge.admin { background: var(--accent-muted); color: var(--accent); }
.badge.user { background: var(--bg-elevated); color: var(--text-secondary); }
.badge.ok { background: rgba(34,197,94,0.15); color: var(--green); }
.badge.ban { background: rgba(239,68,68,0.12); color: var(--red); }

.actions { display: flex; gap: var(--sp-1); justify-content: center; }
.act-btn {
  padding: var(--sp-1) var(--sp-3);
  border-radius: var(--radius-sm);
  font-size: var(--text-xs);
  background: var(--bg-elevated);
  color: var(--text-secondary);
  transition: all var(--dur-fast);
  cursor: pointer;
  border: none;
}
.toolbar { margin-bottom: var(--sp-6); }
.act-btn:hover { background: var(--bg-active); color: var(--text-primary); }
.act-btn.warn { color: var(--amber); }
.act-btn.warn:hover { background: rgba(245,158,11,0.12); }
.act-btn.ok { color: var(--green); }
.act-btn.ok:hover { background: rgba(34,197,94,0.12); }
.act-btn.danger { color: var(--red); }
.act-btn.danger:hover { background: rgba(239,68,68,0.12); }

input[type="checkbox"] { accent-color: var(--accent); width: 16px; height: 16px; cursor: pointer; }

.toolbar-left { display: flex; gap: var(--sp-4); align-items: center; flex-wrap: wrap; flex: 1; min-width: 240px; }
.toolbar-right { display: flex; gap: var(--sp-3); align-items: center; flex-wrap: wrap; }
.modal-desc { color: var(--text-secondary); font-size: var(--text-sm); margin-bottom: var(--sp-4); }
.key-error { color: var(--red); font-size: var(--text-sm); margin-bottom: var(--sp-3); text-align: center; }
.admin-modal .admin-input { margin-bottom: var(--sp-4); width: 100%; }
</style>
