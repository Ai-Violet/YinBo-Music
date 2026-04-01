<template>
  <div class="category-page admin-page page-stack">
    <section class="admin-surface page-intro admin-shrink-0">
      <div class="intro-row">
        <div>
          <h2 class="admin-page-title">分类管理</h2>
          <p class="admin-muted">与用户端首页分类、筛选项对应；下方列表区域单独滚动。</p>
        </div>
        <el-button type="primary" @click="openAddModal">+ 添加分类</el-button>
      </div>
    </section>

    <section class="admin-surface scroll-fill table-wrap">
      <div class="table-scroll-inner">
        <el-table :data="categories" stripe class="data-table" empty-text="暂无分类" row-key="id">
          <el-table-column prop="id" label="ID" width="72" />
          <el-table-column prop="name" label="名称" min-width="140" show-overflow-tooltip />
          <el-table-column label="图标" min-width="120" show-overflow-tooltip>
            <template #default="{ row }">{{ row.icon || '—' }}</template>
          </el-table-column>
          <el-table-column prop="sort" label="排序" width="88" align="center" />
          <el-table-column label="操作" width="160" fixed="right" align="right">
            <template #default="{ row }">
              <el-button link type="primary" size="small" @click="openEditModal(row)">编辑</el-button>
              <el-button link type="danger" size="small" @click="handleDelete(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </section>

    <div v-if="showModal" class="admin-modal-overlay" @click.self="closeModal">
      <div class="admin-modal">
        <h3>{{ editId ? '编辑分类' : '添加分类' }}</h3>
        <div class="admin-form-group">
          <label>名称</label>
          <input v-model="form.name" class="admin-input" placeholder="如：流行" />
        </div>
        <div class="admin-form-group">
          <label>图标（可选）</label>
          <input v-model="form.icon" class="admin-input" placeholder="如：icon-pop" />
        </div>
        <div class="admin-form-group">
          <label>排序（数字越小越靠前）</label>
          <input v-model.number="form.sort" type="number" class="admin-input" placeholder="0" />
        </div>
        <div class="admin-modal-actions">
          <button class="admin-btn admin-btn-ghost" @click="closeModal">取消</button>
          <button class="admin-btn admin-btn-primary" @click="handleSave" :disabled="!form.name.trim()">保存</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { adminApi } from '../../api'

const categories = ref<any[]>([])
const showModal = ref(false)
const editId = ref<number | null>(null)
const form = ref({ name: '', icon: '', sort: 0 })

const loadCategories = async () => {
  try {
    const res = await adminApi.getCategories()
    categories.value = res.data?.data ?? []
  } catch (e) {
    console.error(e)
  }
}

const openAddModal = () => {
  editId.value = null
  form.value = { name: '', icon: '', sort: 0 }
  showModal.value = true
}

const openEditModal = (c: any) => {
  editId.value = c.id
  form.value = { name: c.name, icon: c.icon || '', sort: c.sort ?? 0 }
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
}

const handleSave = async () => {
  try {
    if (editId.value) {
      await adminApi.updateCategory(editId.value, form.value)
      alert('更新成功')
    } else {
      await adminApi.createCategory(form.value)
      alert('添加成功')
    }
    closeModal()
    loadCategories()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '操作失败')
  }
}

const handleDelete = async (c: any) => {
  if (!confirm(`确定删除分类「${c.name}」？`)) return
  try {
    await adminApi.deleteCategory(c.id)
    loadCategories()
  } catch (e: any) {
    alert(e?.response?.data?.message ?? '删除失败')
  }
}

onMounted(loadCategories)
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
</style>
