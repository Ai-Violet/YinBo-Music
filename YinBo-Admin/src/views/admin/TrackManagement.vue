<template>
  <div class="track-management admin-page page-stack">
    <section class="admin-surface page-intro admin-shrink-0">
      <div class="intro-row">
        <div>
          <h2 class="admin-page-title">音乐管理</h2>
          <p class="admin-muted">全宽表格；筛选区固定，仅列表区域滚动。榜单与用户端热度维度对齐。</p>
        </div>
        <div class="view-toggle">
          <button type="button" class="pill-btn" :class="{ on: !showRanking }" @click="showRanking = false">曲库列表</button>
          <button type="button" class="pill-btn" :class="{ on: showRanking }" @click="openRanking">数据榜单</button>
        </div>
      </div>
    </section>

    <template v-if="!showRanking">
      <section class="admin-surface filters-block admin-shrink-0">
        <div class="filters-grid">
          <el-input
            v-model="searchKeyword"
            placeholder="搜索歌曲名、歌手、专辑…"
            clearable
            class="filter-grow"
            @keyup.enter="handleSearch"
            @clear="handleSearch"
          />
          <el-select
            v-model="categoryFilter"
            placeholder="全部分类"
            clearable
            class="filter-cat"
            @change="handleSearch"
          >
            <el-option v-for="c in categories" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
          <el-select v-model="pageSize" class="filter-pagesize" @change="onPageSizeChange">
            <el-option :value="10" label="每页 10 条" />
            <el-option :value="20" label="每页 20 条" />
            <el-option :value="50" label="每页 50 条" />
          </el-select>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
        </div>
        <div class="status-pills">
          <button type="button" class="mini-pill" :class="{ active: statusFilter === undefined }" @click="setStatus(undefined)">全部</button>
          <button type="button" class="mini-pill" :class="{ active: statusFilter === 0 }" @click="setStatus(0)">待审核</button>
          <button type="button" class="mini-pill" :class="{ active: statusFilter === 1 }" @click="setStatus(1)">已通过</button>
          <button type="button" class="mini-pill" :class="{ active: statusFilter === 2 }" @click="setStatus(2)">已拒绝</button>
        </div>
      </section>

      <section class="admin-surface table-section scroll-fill">
        <div class="table-scroll-inner">
        <el-table :data="tracks" stripe class="data-table" empty-text="暂无歌曲" :row-key="(r: any) => r.id">
          <el-table-column label="封面" width="72" align="center">
            <template #default="{ row }">
              <img :src="row.coverUrl || defaultCover" alt="" class="tbl-cover" />
            </template>
          </el-table-column>
          <el-table-column prop="id" label="ID" width="72" />
          <el-table-column prop="title" label="标题" min-width="140" show-overflow-tooltip />
          <el-table-column prop="artist" label="歌手" min-width="100" show-overflow-tooltip />
          <el-table-column label="专辑" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">{{ row.album || '—' }}</template>
          </el-table-column>
          <el-table-column label="分类" width="100" show-overflow-tooltip>
            <template #default="{ row }">{{ row.categoryName || '—' }}</template>
          </el-table-column>
          <el-table-column label="状态" width="96" align="center">
            <template #default="{ row }">
              <span class="tbl-status" :class="getStatusClass(row.status)">{{ getStatusText(row.status) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="时长" width="80" align="center">
            <template #default="{ row }">{{ formatDuration(row.duration) }}</template>
          </el-table-column>
          <el-table-column label="播放" width="88" align="right">
            <template #default="{ row }">{{ row.playCount ?? 0 }}</template>
          </el-table-column>
          <el-table-column label="点赞" width="88" align="right">
            <template #default="{ row }">{{ row.likeCount ?? 0 }}</template>
          </el-table-column>
          <el-table-column label="上传者" min-width="100" show-overflow-tooltip>
            <template #default="{ row }">{{ row.uploaderName || '—' }}</template>
          </el-table-column>
          <el-table-column label="创建时间" width="118" show-overflow-tooltip>
            <template #default="{ row }">{{ row.createdAt || '—' }}</template>
          </el-table-column>
          <el-table-column label="操作" width="228" fixed="right" align="right">
            <template #default="{ row }">
              <el-button link type="primary" size="small" @click="openEdit(row)">编辑</el-button>
              <template v-if="row.status === 0">
                <el-button link type="success" size="small" @click="auditTrack(row.id, 1)">通过</el-button>
                <el-button link type="warning" size="small" @click="auditTrack(row.id, 2)">拒绝</el-button>
              </template>
              <el-button link type="danger" size="small" @click="deleteTrack(row.id)">删除</el-button>
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
    </template>

    <section v-else class="admin-surface ranking-outer scroll-fill">
      <div class="rank-toolbar admin-shrink-0">
        <h3 class="section-title">榜单中心 <span class="section-hint">TOP 10 · 仅统计已上架歌曲</span></h3>
        <div class="rank-metric-pills">
          <button type="button" class="metric-pill" :class="{ active: rankType === 'play' }" @click="setRankType('play')">播放</button>
          <button type="button" class="metric-pill" :class="{ active: rankType === 'favorite' }" @click="setRankType('favorite')">收藏</button>
          <button type="button" class="metric-pill" :class="{ active: rankType === 'like' }" @click="setRankType('like')">红心热度</button>
          <button type="button" class="metric-pill" :class="{ active: rankType === 'comment' }" @click="setRankType('comment')">评论</button>
        </div>
        <p class="rank-hint">{{ rankHintText }}</p>
      </div>
      <div class="rank-scroll">
        <div class="ranking-list">
          <div v-for="(track, index) in rankingTracks" :key="track.id" class="ranking-item">
            <span class="rank" :class="getRankClass(index)">{{ index + 1 }}</span>
            <img :src="track.coverUrl || defaultCover" alt="" class="ranking-cover" />
            <div class="ranking-info">
              <h4>{{ track.title }}</h4>
              <p>{{ track.artist }}<template v-if="track.album"> · {{ track.album }}</template></p>
            </div>
            <div class="play-count">
              <span class="count">{{ rankMetricValue(track) }}</span>
              <span class="label">{{ rankMetricLabel }}</span>
            </div>
          </div>
        </div>
        <div v-if="rankingTracks.length === 0" class="admin-empty">暂无数据</div>
      </div>
    </section>

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
            <div class="cover-upload-wrap">
              <div class="cover-upload" @click="triggerCoverInput">
                <input ref="coverInput" type="file" accept="image/*" @change="handleCoverSelect" hidden />
                <img v-if="coverPreview" :src="coverPreview" alt="新封面" class="cover-preview" />
                <img v-else-if="editForm.coverUrl" :src="editForm.coverUrl" alt="当前封面" class="cover-preview" />
                <div v-else class="cover-placeholder">
                  <span>点击上传</span>
                </div>
              </div>
              <div v-if="coverPreview || editForm.coverUrl" class="cover-edit-actions">
                <button type="button" class="edit-cover-btn" @click="openCoverCropper" title="裁剪/调整">
                  <span>编辑</span>
                </button>
                <button v-if="coverPreview" type="button" class="clear-cover-btn" @click="clearCover">清除</button>
              </div>
            </div>
            <p class="cover-hint">{{ coverPreview || editForm.coverUrl ? '点击封面可更换，点击「编辑」可裁剪调整' : '' }}</p>
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

    <!-- 封面裁剪弹窗 -->
    <CoverCropper
      v-model="showCoverCropper"
      :image-url="coverCropperImageUrl"
      :aspect-ratio="1"
      @confirm="handleCoverCropConfirm"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { adminApi } from '../../api'
import CoverCropper from '../../components/CoverCropper.vue'

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
const rankType = ref<'play' | 'favorite' | 'like' | 'comment'>('play')

const rankMetricLabel = computed(() => {
  switch (rankType.value) {
    case 'favorite': return '人收藏'
    case 'like': return '心跳值'
    case 'comment': return '条评论'
    default: return '次播放'
  }
})

const rankHintText = computed(() => {
  switch (rankType.value) {
    case 'play':
      return '按全站播放记录汇总，对齐用户端「播放历史」热度。'
    case 'favorite':
      return '按用户收藏人数统计，对齐用户端「红心 / 喜欢」。'
    case 'like':
      return '按曲目心跳字段排序；当前由收藏行为同步累加，与收藏榜通常一致。'
    case 'comment':
      return '按曲目下评论总数（含回复），对齐社区互动。'
    default:
      return ''
  }
})

const rankMetricValue = (row: any) => {
  switch (rankType.value) {
    case 'favorite': return row.favoriteUserCount ?? 0
    case 'like': return row.likeCount ?? 0
    case 'comment': return row.totalCommentCount ?? 0
    default: return row.playCount ?? 0
  }
}

const setRankType = (t: 'play' | 'favorite' | 'like' | 'comment') => {
  rankType.value = t
  if (showRanking.value) void loadRanking()
}
const editVisible = ref(false)
const editForm = ref<any>(null)
const editingId = ref<number | null>(null)
const saving = ref(false)
const coverInput = ref<HTMLInputElement | null>(null)
const coverFile = ref<File | null>(null)
const coverPreview = ref('')
const showCoverCropper = ref(false)
const coverCropperImageUrl = ref('')
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
    const res = await adminApi.getTrackRanking(10, rankType.value)
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

const setStatus = (s: number | undefined) => {
  statusFilter.value = s
  page.value = 1
  loadTracks()
}

const onPageSizeChange = () => {
  page.value = 1
  loadTracks()
}

const onPageChange = (p: number) => {
  page.value = p
  loadTracks()
}

const openRanking = () => {
  showRanking.value = true
  void loadRanking()
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
    const reader = new FileReader()
    reader.onload = () => {
      coverCropperImageUrl.value = reader.result as string
      showCoverCropper.value = true
    }
    reader.readAsDataURL(file)
  }
  ;(e.target as HTMLInputElement).value = ''
}

const openCoverCropper = () => {
  const src = coverPreview.value || editForm.value?.coverUrl
  if (src) {
    coverCropperImageUrl.value = src
    showCoverCropper.value = true
  }
}

const handleCoverCropConfirm = (blob: Blob) => {
  coverFile.value = new File([blob], 'cover.jpg', { type: 'image/jpeg' })
  const reader = new FileReader()
  reader.onload = () => { coverPreview.value = reader.result as string }
  reader.readAsDataURL(blob)
  showCoverCropper.value = false
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
      album: editForm.value.album?.trim() ?? '',
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
.ranking-outer {
  padding: var(--sp-5) var(--sp-6);
}

.rank-toolbar {
  margin-bottom: var(--sp-4);
}

.rank-toolbar .section-title {
  margin: 0 0 var(--sp-3);
  display: flex;
  align-items: baseline;
  gap: var(--sp-3);
  flex-wrap: wrap;
}

.section-hint {
  font-size: var(--text-xs);
  font-weight: 400;
  color: var(--text-tertiary);
}

.rank-metric-pills {
  display: flex;
  flex-wrap: wrap;
  gap: var(--sp-2);
  margin-bottom: var(--sp-2);
}

.metric-pill {
  padding: 6px 14px;
  border-radius: var(--radius-full);
  border: 1px solid rgba(91, 154, 136, 0.25);
  background: transparent;
  color: var(--text-secondary);
  font-size: var(--text-sm);
  cursor: pointer;
  transition: all 0.15s;
}

.metric-pill:hover {
  border-color: rgba(91, 154, 136, 0.45);
  color: var(--text-primary);
}

.metric-pill.active {
  background: color-mix(in srgb, var(--accent) 14%, transparent);
  color: var(--accent);
  border-color: color-mix(in srgb, var(--accent) 40%, transparent);
}

.rank-hint {
  margin: 0;
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  line-height: 1.45;
}

.rank-scroll {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  overflow-x: hidden;
  padding-right: 4px;
}

.page-intro .intro-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: var(--sp-6);
  flex-wrap: wrap;
}

.page-intro .admin-page-title {
  margin-bottom: var(--sp-2);
}

.view-toggle {
  display: flex;
  gap: var(--sp-2);
  flex-shrink: 0;
}

.pill-btn {
  padding: var(--sp-2) var(--sp-5);
  border-radius: var(--radius-full);
  border: 1px solid rgba(91, 154, 136, 0.25);
  background: rgba(255, 255, 255, 0.03);
  color: var(--text-secondary);
  font-size: var(--text-sm);
  cursor: pointer;
  transition: background 0.15s, color 0.15s, border-color 0.15s;
}

.pill-btn:hover {
  color: var(--text-primary);
  border-color: rgba(91, 154, 136, 0.45);
}

.pill-btn.on {
  background: color-mix(in srgb, var(--accent) 18%, transparent);
  color: var(--accent);
  border-color: color-mix(in srgb, var(--accent) 40%, transparent);
}

.filters-grid {
  display: flex;
  flex-wrap: wrap;
  gap: var(--sp-3);
  align-items: center;
  margin-bottom: var(--sp-4);
}

.filter-grow {
  flex: 1 1 220px;
  min-width: 180px;
}

.filter-cat {
  width: 160px;
}

.filter-pagesize {
  width: 140px;
}

.filters-grid :deep(.el-input__wrapper),
.filters-grid :deep(.el-select .el-input__wrapper) {
  border-radius: var(--radius-md);
  box-shadow: none;
  background: var(--bg-hover);
}

.status-pills {
  display: flex;
  flex-wrap: wrap;
  gap: var(--sp-2);
}

.mini-pill {
  padding: 6px 14px;
  border-radius: var(--radius-full);
  border: 1px solid var(--border);
  background: transparent;
  color: var(--text-secondary);
  font-size: var(--text-sm);
  cursor: pointer;
  transition: all 0.15s;
}

.mini-pill:hover {
  color: var(--text-primary);
  border-color: rgba(91, 154, 136, 0.35);
}

.mini-pill.active {
  background: color-mix(in srgb, var(--accent) 15%, transparent);
  color: var(--accent);
  border-color: color-mix(in srgb, var(--accent) 35%, transparent);
}

.table-section {
  padding: 0;
}

.data-table {
  width: 100%;
  --el-table-border-color: color-mix(in srgb, var(--border) 70%, transparent);
}

.data-table :deep(.el-table__header th) {
  font-weight: 600;
  font-size: var(--text-xs);
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: var(--text-secondary);
  background: color-mix(in srgb, var(--bg-hover) 88%, #e8f5ef 12%) !important;
}

.data-table :deep(.el-table__row:hover > td) {
  background: color-mix(in srgb, var(--bg-hover) 95%, #ecf8f3 5%) !important;
}

.tbl-cover {
  width: 44px;
  height: 44px;
  border-radius: var(--radius-sm);
  object-fit: cover;
  vertical-align: middle;
}

.tbl-status {
  display: inline-block;
  padding: 2px 8px;
  border-radius: var(--radius-full);
  font-size: var(--text-xs);
  font-weight: 500;
}

.tbl-status.pending {
  background: rgba(245, 158, 11, 0.18);
  color: var(--amber);
}

.tbl-status.approved {
  background: rgba(34, 197, 94, 0.18);
  color: var(--green);
}

.tbl-status.rejected {
  background: rgba(239, 68, 68, 0.18);
  color: var(--red);
}

.pager-bar {
  display: flex;
  justify-content: flex-end;
  padding: var(--sp-4) var(--sp-5);
  border-top: 1px solid color-mix(in srgb, var(--border) 80%, transparent);
}

.section-title {
  font-size: var(--text-md);
  font-weight: 600;
  color: var(--text-primary);
  letter-spacing: -0.02em;
}

.ranking-list {
  display: flex;
  flex-direction: column;
  gap: var(--sp-3);
}

.ranking-item {
  display: flex;
  align-items: center;
  gap: var(--sp-4);
  padding: var(--sp-4);
  background: color-mix(in srgb, var(--bg-hover) 92%, transparent);
  border-radius: var(--radius-md);
  border: 1px solid rgba(91, 154, 136, 0.1);
}

.rank {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-full);
  font-weight: 700;
  font-size: var(--text-sm);
  background: var(--border-hover);
  flex-shrink: 0;
}

.rank.gold { background: linear-gradient(135deg, #ffd700, #ffed4a); color: #333; }
.rank.silver { background: linear-gradient(135deg, #c0c0c0, #e8e8e8); color: #333; }
.rank.bronze { background: linear-gradient(135deg, #cd7f32, #e8a96a); color: #333; }

.ranking-cover {
  width: 52px;
  height: 52px;
  border-radius: var(--radius-sm);
  object-fit: cover;
  flex-shrink: 0;
}

.ranking-info { flex: 1; min-width: 0; }
.ranking-info h4 { margin: 0 0 4px; font-size: var(--text-base); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.ranking-info p { margin: 0; font-size: var(--text-sm); color: var(--text-secondary); overflow: hidden; text-overflow: ellipsis; }

.play-count { text-align: right; flex-shrink: 0; }
.play-count .count { display: block; font-size: var(--text-md); font-weight: 700; color: var(--accent); }
.play-count .label { font-size: var(--text-xs); color: var(--text-secondary); }

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

.cover-upload-wrap {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: var(--sp-2);
}
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
.cover-edit-actions {
  display: flex;
  gap: var(--sp-2);
}
.edit-cover-btn {
  padding: var(--sp-1) var(--sp-3);
  font-size: var(--text-xs);
  border: 1px solid var(--accent);
  border-radius: var(--radius-sm);
  background: transparent;
  cursor: pointer;
  color: var(--accent);
}
.edit-cover-btn:hover {
  background: var(--accent-muted);
}
.cover-hint {
  margin: var(--sp-2) 0 0;
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}
.clear-cover-btn {
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
