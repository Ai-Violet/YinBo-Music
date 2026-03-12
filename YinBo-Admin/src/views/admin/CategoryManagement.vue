<template>
  <div class="category-page admin-page">
    <div class="admin-header">
      <h2 class="admin-page-title">分类管理</h2>
      <button class="admin-btn admin-btn-primary" @click="openAddModal">+ 添加分类</button>
    </div>
    <div class="admin-card admin-table-wrap">
      <table class="admin-table data-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>名称</th>
            <th>图标</th>
            <th>排序</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="c in categories" :key="c.id">
            <td>{{ c.id }}</td>
            <td>{{ c.name }}</td>
            <td>{{ c.icon || '-' }}</td>
            <td>{{ c.sort }}</td>
            <td>
              <button class="admin-btn admin-btn-ghost" @click="openEditModal(c)">编辑</button>
              <button class="admin-btn admin-btn-danger" @click="handleDelete(c)">删除</button>
            </td>
          </tr>
          <tr v-if="!categories.length">
            <td colspan="5" class="admin-empty">暂无分类，请点击「添加分类」</td>
          </tr>
        </tbody>
      </table>
    </div>

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
.data-table th, .data-table td { padding: var(--sp-4) var(--sp-5); }
.admin-btn { margin-right: var(--sp-2); }
.admin-btn:last-child { margin-right: 0; }
</style>
