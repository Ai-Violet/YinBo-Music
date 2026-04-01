<template>
  <div class="comment-management admin-page page-stack">
    <section class="admin-surface page-intro admin-shrink-0">
      <h2 class="admin-page-title">评论管理</h2>
      <p class="admin-muted">
        分区浏览：全部列表支持按歌曲 / 用户筛选与排序；「按用户汇总」合并同一用户的所有评论。
        评论暂无独立收藏字段时，「综合热度」按点赞与楼中楼回复加权，与单曲详情里的互动量一致。
      </p>
      <div class="main-tabs" role="tablist">
        <button
          type="button"
          class="main-tab"
          :class="{ active: mainTab === 'all' }"
          role="tab"
          @click="switchTab('all')"
        >
          全部评论
        </button>
        <button
          type="button"
          class="main-tab"
          :class="{ active: mainTab === 'users' }"
          role="tab"
          @click="switchTab('users')"
        >
          按用户汇总
        </button>
      </div>
    </section>

    <template v-if="mainTab === 'all'">
      <section class="admin-surface filters-block admin-shrink-0">
        <div class="filters-row">
          <el-input
            v-model="trackIdStr"
            placeholder="歌曲 ID（留空为全部）"
            clearable
            class="filter-id"
            @clear="applyListFilters"
            @keyup.enter="applyListFilters"
          />
          <el-input
            v-model="userIdStr"
            placeholder="用户 ID（留空为全部）"
            clearable
            class="filter-id"
            @clear="applyListFilters"
            @keyup.enter="applyListFilters"
          />
          <el-select v-model="sortKey" class="filter-sort" @change="applyListFilters">
            <el-option label="最新" value="newest" />
            <el-option label="最热（赞 + 回复）" value="hot" />
            <el-option label="最多点赞" value="likes" />
            <el-option label="最多回复" value="replies" />
            <el-option label="综合热度（同最热）" value="favorite" />
          </el-select>
          <el-select v-model="pageSize" class="filter-pagesize" @change="onPageSizeChange">
            <el-option :value="10" label="每页 10" />
            <el-option :value="20" label="每页 20" />
            <el-option :value="50" label="每页 50" />
          </el-select>
          <el-button type="primary" @click="applyListFilters">应用筛选</el-button>
          <el-button v-if="filterUserId != null" plain @click="clearUserFilter">清除用户筛选</el-button>
        </div>
      </section>

      <section v-if="loading" class="admin-surface admin-shrink-0"><div class="admin-empty">加载中…</div></section>

      <section v-else-if="comments.length === 0" class="admin-surface admin-shrink-0">
        <div class="admin-empty">暂无评论</div>
      </section>

      <section v-else class="admin-surface scroll-fill table-section">
        <div class="table-scroll-inner">
        <el-table :data="comments" stripe class="data-table" empty-text="暂无" :row-key="(r: any) => r.id">
          <el-table-column prop="id" label="ID" width="72" />
          <el-table-column label="用户" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">
              {{ row.userNickname || row.username || '—' }}
            </template>
          </el-table-column>
          <el-table-column prop="userId" label="用户ID" width="88" />
          <el-table-column label="内容" min-width="200" show-overflow-tooltip>
            <template #default="{ row }">{{ row.content }}</template>
          </el-table-column>
          <el-table-column label="歌曲" min-width="160" show-overflow-tooltip>
            <template #default="{ row }">
              <span v-if="row.trackTitle">《{{ row.trackTitle }}》</span>
              <span v-else>—</span>
            </template>
          </el-table-column>
          <el-table-column label="歌手" width="100" show-overflow-tooltip>
            <template #default="{ row }">{{ row.trackArtist || '—' }}</template>
          </el-table-column>
          <el-table-column prop="trackId" label="歌曲ID" width="88" />
          <el-table-column label="点赞" width="72" align="right">
            <template #default="{ row }">{{ row.likeCount ?? 0 }}</template>
          </el-table-column>
          <el-table-column label="回复" width="72" align="right">
            <template #default="{ row }">{{ row.replyCount ?? 0 }}</template>
          </el-table-column>
          <el-table-column prop="createdAt" label="时间" width="160" show-overflow-tooltip />
          <el-table-column label="操作" width="200" fixed="right" align="right">
            <template #default="{ row }">
              <el-button link type="primary" size="small" tag="a" :href="commentUrl(row.trackId)" target="_blank" rel="noopener">
                前台评论区
              </el-button>
              <el-button link type="danger" size="small" @click="remove(row.id)">删除</el-button>
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

    <template v-else>
      <section class="admin-surface filters-block admin-shrink-0">
        <div class="filters-row">
          <el-input
            v-model="userStatsKeyword"
            placeholder="按用户昵称 / 用户名搜索"
            clearable
            class="filter-grow"
            @keyup.enter="loadUserStats"
            @clear="loadUserStats"
          />
          <el-select v-model="userStatsPageSize" class="filter-pagesize" @change="onUserStatsPageSizeChange">
            <el-option :value="10" label="每页 10" />
            <el-option :value="20" label="每页 20" />
          </el-select>
          <el-button type="primary" @click="loadUserStats">搜索</el-button>
        </div>
      </section>

      <section v-if="userStatsLoading" class="admin-surface admin-shrink-0"><div class="admin-empty">加载中…</div></section>

      <section v-else class="admin-surface scroll-fill table-section">
        <div class="table-scroll-inner">
        <el-table :data="userStats" stripe class="data-table" empty-text="暂无用户评论数据">
          <el-table-column prop="userId" label="用户ID" width="96" />
          <el-table-column prop="displayName" label="用户" min-width="140" show-overflow-tooltip />
          <el-table-column prop="commentCount" label="评论条数" width="100" align="right" />
          <el-table-column prop="latestAt" label="最近评论" width="170" show-overflow-tooltip />
          <el-table-column label="操作" width="140" fixed="right" align="right">
            <template #default="{ row }">
              <el-button link type="primary" size="small" @click="viewUserComments(row.userId)">查看全部</el-button>
            </template>
          </el-table-column>
        </el-table>
        </div>
        <div v-if="userStatsTotal > 0" class="pager-bar admin-shrink-0">
          <el-pagination
            :current-page="userStatsPage"
            :page-size="userStatsPageSize"
            :total="userStatsTotal"
            layout="total, prev, pager, next"
            background
            @current-change="onUserStatsPageChange"
          />
        </div>
      </section>
    </template>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { adminApi } from '../../api'

const clientBase = (import.meta.env.VITE_CLIENT_URL || '').replace(/\/$/, '')

const commentUrl = (trackId: number) => `${clientBase}/track/${trackId}`

const mainTab = ref<'all' | 'users'>('all')

const comments = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(20)
const total = ref(0)
const trackIdStr = ref('')
const userIdStr = ref('')
const filterUserId = ref<number | undefined>(undefined)
const sortKey = ref<'newest' | 'hot' | 'likes' | 'replies' | 'favorite'>('newest')

const userStats = ref<any[]>([])
const userStatsLoading = ref(false)
const userStatsPage = ref(1)
const userStatsPageSize = ref(20)
const userStatsTotal = ref(0)
const userStatsKeyword = ref('')

const parseOptionalLong = (s: string): number | undefined => {
  const t = s.trim()
  if (!t) return undefined
  const n = Number(t)
  return Number.isFinite(n) && n > 0 ? n : undefined
}

const loadComments = async () => {
  loading.value = true
  try {
    const trackId = parseOptionalLong(trackIdStr.value)
    const userId = filterUserId.value ?? parseOptionalLong(userIdStr.value)
    const res = await adminApi.getAllComments(page.value, pageSize.value, trackId, userId, sortKey.value)
    if (res.data.code === 200) {
      const data = res.data.data
      comments.value = data?.records || []
      total.value = data?.total ?? 0
    }
  } finally {
    loading.value = false
  }
}

const applyListFilters = () => {
  filterUserId.value = undefined
  page.value = 1
  loadComments()
}

const clearUserFilter = () => {
  filterUserId.value = undefined
  userIdStr.value = ''
  page.value = 1
  loadComments()
}

const onPageSizeChange = () => {
  page.value = 1
  loadComments()
}

const onPageChange = (p: number) => {
  page.value = p
  loadComments()
}

const loadUserStats = async () => {
  userStatsLoading.value = true
  try {
    const res = await adminApi.getCommentUserStats(
      userStatsPage.value,
      userStatsPageSize.value,
      userStatsKeyword.value || undefined
    )
    if (res.data.code === 200) {
      const data = res.data.data
      userStats.value = data?.records || []
      userStatsTotal.value = data?.total ?? 0
    }
  } finally {
    userStatsLoading.value = false
  }
}

const onUserStatsPageSizeChange = () => {
  userStatsPage.value = 1
  loadUserStats()
}

const onUserStatsPageChange = (p: number) => {
  userStatsPage.value = p
  loadUserStats()
}

const viewUserComments = (userId: number) => {
  mainTab.value = 'all'
  filterUserId.value = userId
  userIdStr.value = String(userId)
  page.value = 1
  loadComments()
}

const switchTab = (tab: 'all' | 'users') => {
  mainTab.value = tab
  if (tab === 'users') {
    userStatsPage.value = 1
    loadUserStats()
  } else {
    loadComments()
  }
}

const remove = async (id: number) => {
  if (!confirm('确定删除该评论？')) return
  try {
    await adminApi.deleteComment(id)
    await loadComments()
    if (mainTab.value === 'users') await loadUserStats()
  } catch (e) {
    console.error('Delete comment failed:', e)
  }
}

onMounted(() => {
  loadComments()
})
</script>

<style scoped>
.page-intro .admin-page-title {
  margin-bottom: var(--sp-2);
}

.main-tabs {
  display: flex;
  flex-wrap: wrap;
  gap: var(--sp-2);
  margin-top: var(--sp-5);
}

.main-tab {
  padding: var(--sp-2) var(--sp-5);
  border-radius: var(--radius-full);
  border: 1px solid rgba(91, 154, 136, 0.25);
  background: transparent;
  color: var(--text-secondary);
  font-size: var(--text-sm);
  cursor: pointer;
  transition: all 0.15s;
}

.main-tab:hover {
  color: var(--text-primary);
  border-color: rgba(91, 154, 136, 0.45);
}

.main-tab.active {
  background: color-mix(in srgb, var(--accent) 16%, transparent);
  color: var(--accent);
  border-color: color-mix(in srgb, var(--accent) 40%, transparent);
}

.filters-row {
  display: flex;
  flex-wrap: wrap;
  gap: var(--sp-3);
  align-items: center;
}

.filter-id {
  width: 160px;
}

.filter-sort {
  width: 200px;
}

.filter-pagesize {
  width: 120px;
}

.filter-grow {
  flex: 1 1 220px;
  min-width: 180px;
}

.filters-row :deep(.el-input__wrapper),
.filters-row :deep(.el-select .el-input__wrapper) {
  border-radius: var(--radius-md);
  box-shadow: none;
  background: var(--bg-hover);
}

.table-section {
  padding: 0;
  overflow: hidden;
}

.data-table {
  width: 100%;
  --el-table-border-color: color-mix(in srgb, var(--border) 70%, transparent);
}

.data-table :deep(.el-table__header th) {
  font-weight: 600;
  font-size: var(--text-xs);
  letter-spacing: 0.04em;
  color: var(--text-secondary);
  background: color-mix(in srgb, var(--bg-hover) 88%, #e8f5ef 12%) !important;
}

.data-table :deep(.el-table__row:hover > td) {
  background: color-mix(in srgb, var(--bg-hover) 95%, #ecf8f3 5%) !important;
}

.pager-bar {
  display: flex;
  justify-content: flex-end;
  padding: var(--sp-4) var(--sp-5);
  border-top: 1px solid color-mix(in srgb, var(--border) 80%, transparent);
}
</style>
