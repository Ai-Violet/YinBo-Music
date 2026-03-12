<template>
  <div class="track-management admin-page">
    <!-- 搜索和筛选栏 -->
    <div class="admin-header search-bar">
      <h2 class="admin-page-title">音乐管理</h2>
      <div class="search-actions">
      <input v-model="searchKeyword" class="admin-input" type="text" placeholder="搜索歌曲名、歌手、专辑..." @keyup.enter="handleSearch" />
      <el-select v-model="categoryFilter" placeholder="全部分类" clearable class="category-filter" @change="loadTracks">
        <el-option v-for="c in categories" :key="c.id" :label="c.name" :value="c.id" />
      </el-select>
      <button class="admin-btn admin-btn-primary" @click="handleSearch">搜索</button>
      <button class="admin-btn admin-btn-ghost" @click="showRanking = !showRanking">
        {{ showRanking ? '返回列表' : '播放排行榜' }}
      </button>
      </div>
    </div>

    <!-- 排行榜视图 -->
    <div v-if="showRanking" class="ranking-section admin-card">
      <h3 class="section-title">🏆 播放次数排行榜 TOP 10</h3>
      <div class="ranking-list">
        <div v-for="(track, index) in rankingTracks" :key="track.id" class="ranking-item">
          <span class="rank" :class="getRankClass(index)">{{ index + 1 }}</span>
          <img :src="track.coverUrl || defaultCover" alt="封面" class="ranking-cover" />
          <div class="ranking-info">
            <h4>{{ track.title }}</h4>
            <p>{{ track.artist }}</p>
          </div>
          <div class="play-count">
            <span class="count">{{ track.playCount || 0 }}</span>
            <span class="label">次播放</span>
          </div>
        </div>
      </div>
      <div v-if="rankingTracks.length === 0" class="admin-empty">暂无播放数据</div>
    </div>

    <!-- 正常列表视图 -->
    <template v-else>
      <div class="filter-bar">
        <div class="tabs">
          <button :class="['tab', { active: statusFilter === undefined }]" @click="statusFilter = undefined; loadTracks()">全部</button>
          <button :class="['tab', { active: statusFilter === 0 }]" @click="statusFilter = 0; loadTracks()">待审核</button>
          <button :class="['tab', { active: statusFilter === 1 }]" @click="statusFilter = 1; loadTracks()">已通过</button>
          <button :class="['tab', { active: statusFilter === 2 }]" @click="statusFilter = 2; loadTracks()">已拒绝</button>
        </div>
      </div>

      <div class="track-list admin-card">
        <div v-for="track in tracks" :key="track.id" class="track-card">
          <img :src="track.coverUrl || defaultCover" alt="封面" class="cover" />
          <div class="info">
            <h4>{{ track.title }}</h4>
            <p>{{ track.artist }} · {{ track.album || '-' }}</p>
            <div class="meta">
              <span class="status-badge" :class="getStatusClass(track.status)">{{ getStatusText(track.status) }}</span>
              <span>{{ formatDuration(track.duration) }}</span>
              <span>{{ track.playCount || 0 }} 次</span>
              <span v-if="track.categoryName" class="cat-tag">{{ track.categoryName }}</span>
            </div>
          </div>
          <div class="actions">
            <button class="edit-btn" @click="openEdit(track)">编辑</button>
            <template v-if="track.status === 0">
              <button class="approve-btn" @click="auditTrack(track.id, 1)">通过</button>
              <button class="reject-btn" @click="auditTrack(track.id, 2)">拒绝</button>
            </template>
            <button class="delete-btn" @click="deleteTrack(track.id)">删除</button>
          </div>
        </div>
      </div>

      <div v-if="tracks.length === 0" class="admin-empty">暂无歌曲数据</div>

      <div class="admin-pagination" v-if="total > pageSize">
        <button :disabled="page === 1" @click="page--; loadTracks()">上一页</button>
        <span>{{ page }} / {{ Math.ceil(total / pageSize) }}</span>
        <button :disabled="page * pageSize >= total" @click="page++; loadTracks()">下一页</button>
      </div>
    </template>

    <!-- 编辑弹窗 -->
    <div v-if="editVisible" class="admin-modal-overlay" @click.self="closeEdit">
      <div class="edit-modal">
        <div class="modal-header">
          <h3>编辑歌曲</h3>
          <button class="close-btn" @click="closeEdit">×</button>
        </div>
        <div class="modal-body" v-if="editForm">
          <div class="form-group">
            <label>歌曲封面</label>
            <div class="cover-upload" @click="triggerCoverInput">
              <input ref="coverInput" type="file" accept="image/*" @change="handleCoverSelect" hidden />
              <img v-if="coverPreview" :src="coverPreview" alt="新封面" class="cover-preview" />
              <img v-else-if="editForm.coverUrl" :src="editForm.coverUrl" alt="当前封面" class="cover-preview" />
              <div v-else class="cover-placeholder">
                <span>点击上传</span>
              </div>
            </div>
            <p class="cover-hint">{{ coverPreview || editForm.coverUrl ? '点击上方封面可更换' : '' }}</p>
            <button v-if="coverPreview" type="button" class="clear-cover-btn" @click="clearCover">清除新选</button>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>歌曲名 *</label>
              <input v-model="editForm.title" placeholder="歌曲名称" />
            </div>
            <div class="form-group">
              <label>歌手 *</label>
              <div class="singer-select-row">
                <el-select v-model="editForm.artistId" placeholder="选择歌手" clearable filterable class="singer-select" popper-class="admin-select-dropdown" @change="onSingerChange">
                  <el-option v-for="s in singers" :key="s.id" :label="s.name" :value="s.id" />
                </el-select>
                <span class="or-text">或</span>
                <input v-model="editForm.artist" placeholder="手动输入歌手名" class="artist-input" />
              </div>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>专辑</label>
              <input v-model="editForm.album" placeholder="专辑名称" />
            </div>
            <div class="form-group">
              <label>分类</label>
              <el-select v-model="editForm.categoryId" placeholder="选择分类" clearable class="category-select" popper-class="admin-select-dropdown">
                <el-option v-for="c in categories" :key="c.id" :label="c.name" :value="c.id" />
              </el-select>
            </div>
          </div>
          <div class="form-group">
            <label>歌词</label>
            <textarea v-model="editForm.lyrics" placeholder="歌词内容（可选）" rows="8"></textarea>
          </div>
        </div>
        <div class="modal-footer">
          <button class="admin-btn admin-btn-ghost" @click="closeEdit">取消</button>
          <button class="admin-btn admin-btn-primary" @click="saveEdit" :disabled="saving">{{ saving ? '保存中...' : '保存' }}</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { adminApi } from '../../api'

const defaultCover = 'https://via.placeholder.com/80?text=Music'

const tracks = ref<any[]>([])
const rankingTracks = ref<any[]>([])
const categories = ref<any[]>([])
const singers = ref<any[]>([])

const page = ref(1)
const pageSize = ref(20)
const total = ref(0)
const statusFilter = ref<number | undefined>(undefined)
const searchKeyword = ref('')
const categoryFilter = ref<number | undefined>(undefined)

const showRanking = ref(false)
const editVisible = ref(false)
const editForm = ref<any>(null)
const editingId = ref<number | null>(null)
const saving = ref(false)
const coverInput = ref<HTMLInputElement | null>(null)
const coverFile = ref<File | null>(null)
const coverPreview = ref('')
let refreshTimer: number | null = null

const getStatusClass = (status: number) => {
  switch (status) {
    case 0: return 'pending'
    case 1: return 'approved'
    case 2: return 'rejected'
    default: return ''
  }
}

const getStatusText = (status: number) => {
  switch (status) {
    case 0: return '待审核'
    case 1: return '已通过'
    case 2: return '已拒绝'
    default: return '未知'
  }
}

const getRankClass = (index: number) => {
  if (index === 0) return 'gold'
  if (index === 1) return 'silver'
  if (index === 2) return 'bronze'
  return ''
}

const formatDuration = (seconds: number) => {
  if (!seconds) return '-'
  const min = Math.floor(seconds / 60)
  const sec = seconds % 60
  return `${min}:${sec.toString().padStart(2, '0')}`
}

const loadTracks = async () => {
  try {
    const res = await adminApi.getAllTracks(
      page.value,
      pageSize.value,
      statusFilter.value,
      searchKeyword.value || undefined,
      categoryFilter.value
    )
    if (res.data.code === 200) {
      tracks.value = res.data.data.records || []
      total.value = res.data.data.total || 0
    }
  } catch (e) {
    console.error('Failed to load tracks:', e)
  }
}

const loadRanking = async () => {
  try {
    const res = await adminApi.getTrackRanking(10)
    if (res.data.code === 200) {
      rankingTracks.value = res.data.data.records || []
    }
  } catch (e) {
    console.error('Failed to load ranking:', e)
  }
}

const loadCategories = async () => {
  try {
    const res = await adminApi.getCategories()
    categories.value = res.data?.data ?? []
  } catch (e) {
    console.error('Failed to load categories:', e)
  }
}

const loadSingers = async () => {
  try {
    const res = await adminApi.listSingers(1, 200)
    singers.value = res.data?.data?.records ?? []
  } catch (e) {
    console.error('Failed to load singers:', e)
  }
}

const handleSearch = () => {
  page.value = 1
  loadTracks()
}

const onSingerChange = (id: number | null) => {
  if (id) {
    const s = singers.value.find((x) => x.id === id)
    if (s) editForm.value!.artist = s.name
  }
}

const openEdit = async (track: any) => {
  try {
    const res = await adminApi.getTrackForEdit(track.id)
    const data = res.data?.data
    if (data) {
      editForm.value = {
        id: data.id,
        title: data.title ?? '',
        artist: data.artist ?? '',
        album: data.album ?? '',
        categoryId: data.categoryId ?? null,
        lyrics: data.lyrics ?? '',
        artistId: data.artistId ?? null,
        coverUrl: data.coverUrl ?? ''
      }
      editingId.value = data.id
      coverFile.value = null
      coverPreview.value = ''
      editVisible.value = true
    }
  } catch (e) {
    console.error('Failed to load track:', e)
  }
}

const closeEdit = () => {
  editVisible.value = false
  editForm.value = null
  editingId.value = null
  coverFile.value = null
  coverPreview.value = ''
}

const triggerCoverInput = () => coverInput.value?.click()

const handleCoverSelect = (e: Event) => {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (file) {
    coverFile.value = file
    const reader = new FileReader()
    reader.onload = () => { coverPreview.value = reader.result as string }
    reader.readAsDataURL(file)
  }
  ;(e.target as HTMLInputElement).value = ''
}

const clearCover = () => {
  coverFile.value = null
  coverPreview.value = ''
}

const saveEdit = async () => {
  if (!editForm.value || !editingId.value) return
  if (!editForm.value.title?.trim() || !editForm.value.artist?.trim()) {
    alert('请填写歌曲名和歌手')
    return
  }
  saving.value = true
  try {
    await adminApi.updateTrack(editingId.value, {
      title: editForm.value.title.trim(),
      artist: editForm.value.artist.trim(),
      album: editForm.value.album?.trim() || '',
      categoryId: editForm.value.categoryId,
      lyrics: editForm.value.lyrics ?? '',
      artistId: editForm.value.artistId
    })
    if (coverFile.value) {
      await adminApi.updateTrackCover(editingId.value, coverFile.value)
    }
    closeEdit()
    loadTracks()
    if (showRanking.value) loadRanking()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '保存失败')
  } finally {
    saving.value = false
  }
}

const auditTrack = async (trackId: number, status: number) => {
  try {
    status === 1 ? await adminApi.approveTrack(trackId) : await adminApi.rejectTrack(trackId)
    loadTracks()
  } catch (e) {
    console.error('Failed to audit:', e)
  }
}

const deleteTrack = async (trackId: number) => {
  if (!confirm('确定要删除这首歌曲吗？')) return
  try {
    await adminApi.deleteTrack(trackId)
    loadTracks()
    if (showRanking.value) loadRanking()
    if (editVisible.value && editingId.value === trackId) closeEdit()
  } catch (e) {
    console.error('Failed to delete:', e)
  }
}

onMounted(() => {
  loadCategories()
  loadSingers()
  loadTracks()
  loadRanking()
  refreshTimer = window.setInterval(() => {
    if (showRanking.value) loadRanking()
    else loadTracks()
  }, 15000)
})

watch(showRanking, (value) => {
  value ? loadRanking() : loadTracks()
})

onUnmounted(() => {
  if (refreshTimer !== null) clearInterval(refreshTimer)
})
</script>

<style scoped>
.track-management { padding: var(--sp-5); }

.search-bar { margin-bottom: var(--sp-6); }
.search-actions { display: flex; gap: var(--sp-3); flex-wrap: wrap; align-items: center; flex: 1; }
.search-actions input { flex: 1; min-width: 200px; }
.category-filter { width: 140px; }
.category-filter :deep(.el-input__wrapper) {
  background: var(--bg-hover);
  border: 1px solid var(--border);
  box-shadow: none;
  min-height: 40px;
}
.category-filter :deep(.el-input__inner) { color: var(--text-primary); }


.filter-bar { margin-bottom: var(--sp-5); }
.tabs { display: flex; gap: var(--sp-3); flex-wrap: wrap; }
.tab {
  padding: var(--sp-2) var(--sp-5);
  border: none;
  border-radius: var(--radius-full);
  background: var(--bg-hover);
  color: var(--text-secondary);
  cursor: pointer;
  transition: all var(--dur-normal) var(--ease-out);
}
.tab.active { background: var(--accent); color: var(--text-primary); }

.ranking-section { margin-top: var(--sp-4); padding: var(--sp-6); }
.section-title { font-size: var(--text-lg); margin-bottom: var(--sp-5); color: var(--accent); }
.ranking-list { display: flex; flex-direction: column; gap: var(--sp-3); }
.ranking-item {
  display: flex;
  align-items: center;
  gap: var(--sp-4);
  padding: var(--sp-4);
  background: var(--bg-hover);
  border-radius: var(--radius-md);
}
.rank {
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-full);
  font-weight: bold;
  font-size: var(--text-base);
  background: var(--border-hover);
}
.rank.gold { background: linear-gradient(135deg, #ffd700, #ffed4a); color: #333; }
.rank.silver { background: linear-gradient(135deg, #c0c0c0, #e8e8e8); color: #333; }
.rank.bronze { background: linear-gradient(135deg, #cd7f32, #e8a96a); color: #333; }
.ranking-cover { width: 50px; height: 50px; border-radius: var(--radius-sm); object-fit: cover; }
.ranking-info { flex: 1; }
.ranking-info h4 { margin: 0 0 var(--sp-1); font-size: var(--text-base); }
.ranking-info p { margin: 0; font-size: var(--text-sm); color: var(--text-secondary); }
.play-count { text-align: right; }
.play-count .count { display: block; font-size: var(--text-md); font-weight: bold; color: var(--accent); }
.play-count .label { font-size: var(--text-xs); color: var(--text-secondary); }

.track-list { display: flex; flex-direction: column; gap: var(--sp-4); padding: var(--sp-5); }
.track-card {
  display: flex;
  align-items: center;
  gap: var(--sp-5);
  padding: var(--sp-4);
  background: var(--bg-hover);
  border-radius: var(--radius-md);
  transition: background var(--dur-fast);
}
.track-card:hover { background: var(--bg-active); }
.cover { width: 80px; height: 80px; border-radius: var(--radius-sm); object-fit: cover; }
.info { flex: 1; min-width: 0; }
.info h4 { margin: 0 0 var(--sp-2); font-size: var(--text-md); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.info p { margin: 0 0 var(--sp-3); font-size: var(--text-base); color: var(--text-secondary); overflow: hidden; text-overflow: ellipsis; }
.meta {
  display: flex;
  gap: var(--sp-4);
  font-size: var(--text-xs);
  color: var(--text-secondary);
  flex-wrap: wrap;
  align-items: center;
}
.cat-tag { padding: 2px 8px; background: var(--accent-muted); color: var(--accent); border-radius: var(--radius-sm); }
.status-badge { padding: var(--sp-1) var(--sp-3); border-radius: var(--radius-md); font-size: var(--text-xs); }
.status-badge.pending { background: rgba(245, 158, 11, 0.2); color: var(--amber); }
.status-badge.approved { background: rgba(34, 197, 94, 0.2); color: var(--green); }
.status-badge.rejected { background: rgba(239, 68, 68, 0.2); color: var(--red); }

.actions { display: flex; gap: var(--sp-3); flex-wrap: wrap; }
.edit-btn, .approve-btn, .reject-btn, .delete-btn {
  padding: var(--sp-2) var(--sp-4);
  border: none;
  border-radius: var(--radius-sm);
  font-size: var(--text-sm);
  cursor: pointer;
  transition: all var(--dur-fast);
}
.edit-btn {
  background: var(--accent-muted);
  color: var(--accent);
}
.edit-btn:hover { background: rgba(99, 102, 241, 0.3); }
.approve-btn { background: rgba(34, 197, 94, 0.2); color: var(--green); }
.approve-btn:hover { background: rgba(34, 197, 94, 0.35); }
.reject-btn { background: rgba(245, 158, 11, 0.2); color: var(--amber); }
.reject-btn:hover { background: rgba(245, 158, 11, 0.35); }
.delete-btn { background: rgba(239, 68, 68, 0.2); color: var(--red); }
.delete-btn:hover { background: rgba(239, 68, 68, 0.35); }

/* 编辑弹窗 */

.edit-modal {
  width: 100%;
  max-width: 560px;
  max-height: 90vh;
  overflow-y: auto;
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  border: 1px solid var(--border-hover);
  box-shadow: var(--shadow-lg);
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--sp-5);
  border-bottom: 1px solid var(--border);
}
.modal-header h3 { margin: 0; font-size: var(--text-md); }
.close-btn {
  width: 32px;
  height: 32px;
  border: none;
  background: transparent;
  color: var(--text-secondary);
  font-size: 24px;
  cursor: pointer;
  border-radius: var(--radius-sm);
  line-height: 1;
}
.close-btn:hover { background: var(--bg-hover); color: var(--text-primary); }

.modal-body {
  padding: var(--sp-5);
}

.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: var(--sp-5); margin-bottom: var(--sp-4); }
.form-group { display: flex; flex-direction: column; gap: var(--sp-2); margin-bottom: var(--sp-4); }
.form-group:last-child { margin-bottom: 0; }
.form-group label { font-size: var(--text-sm); color: var(--text-secondary); }
.form-group input, .form-group textarea {
  padding: var(--sp-3);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  background: var(--bg-hover);
  color: var(--text-primary);
  font-size: var(--text-base);
}
.form-group textarea { min-height: 160px; resize: vertical; }

.cover-upload {
  width: 120px;
  height: 120px;
  border: 1px dashed var(--border);
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  overflow: hidden;
}
.cover-placeholder { text-align: center; font-size: var(--text-xs); color: var(--text-tertiary); }
.cover-preview {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.cover-hint {
  margin: var(--sp-2) 0 0;
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}
.clear-cover-btn {
  margin-top: var(--sp-2);
  padding: var(--sp-1) var(--sp-3);
  font-size: var(--text-xs);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  background: transparent;
  cursor: pointer;
  color: var(--text-secondary);
}

.singer-select-row {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
  flex-wrap: wrap;
}
.singer-select { flex: 1; min-width: 140px; }
.singer-select :deep(.el-input__wrapper) {
  background: var(--bg-hover);
  border: 1px solid var(--border);
  box-shadow: none;
}
.or-text { font-size: var(--text-xs); color: var(--text-tertiary); }
.artist-input { flex: 1; min-width: 120px; }
.category-select { width: 100%; }
.category-select :deep(.el-input__wrapper) {
  background: var(--bg-hover);
  border: 1px solid var(--border);
  box-shadow: none;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: var(--sp-3);
  padding: var(--sp-5);
  border-top: 1px solid var(--border);
}
.cancel-btn {
  padding: var(--sp-3) var(--sp-6);
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  background: transparent;
  color: var(--text-primary);
  cursor: pointer;
}
.cancel-btn:hover { background: var(--bg-hover); }
.save-btn {
  padding: var(--sp-3) var(--sp-6);
  border: none;
  border-radius: var(--radius-sm);
  background: var(--accent);
  color: var(--text-primary);
  cursor: pointer;
}
.save-btn:hover:not(:disabled) { background: var(--accent-hover); }
.save-btn:disabled { opacity: 0.6; cursor: not-allowed; }
</style>
