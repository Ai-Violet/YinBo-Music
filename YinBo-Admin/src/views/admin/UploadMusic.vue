<template>
  <div class="upload-page admin-page page-stack">
    <section class="admin-surface upload-hero admin-shrink-0">
      <h2 class="admin-page-title">上传音乐</h2>
      <p class="admin-muted">与曲库页风格一致的分步表单：先确认歌手，再上传音频与封面。下方步骤内容单独滚动。</p>

      <!-- 步骤指示 -->
      <div class="steps">
        <div class="step" :class="{ active: step === 1, done: step > 1 }" @click="step = 1">
          <span class="step-num">1</span>
          <span>歌手</span>
        </div>
        <div class="step-line" :class="{ done: step > 1 }"></div>
        <div class="step" :class="{ active: step === 2 }" @click="step >= 2 && (step = 2)">
          <span class="step-num">2</span>
          <span>上传歌曲</span>
        </div>
      </div>
    </section>

    <div class="scroll-fill upload-steps-scroll">
      <div class="table-scroll-inner upload-steps-inner">
        <section v-show="step === 1" class="admin-surface step-panel-wrap">
      <h3 class="panel-title">选择歌手方式</h3>
      <div class="mode-cards" role="tablist">
        <button
          type="button"
          role="tab"
          class="mode-card"
          :class="{ active: singerMode === 'select' }"
          :aria-selected="singerMode === 'select'"
          @click="singerMode = 'select'"
        >
          <span class="mode-card-title">选择已有歌手</span>
          <span class="mode-card-desc">从资料库中挑选，支持搜索与刷新列表</span>
        </button>
        <button
          type="button"
          role="tab"
          class="mode-card"
          :class="{ active: singerMode === 'create' }"
          :aria-selected="singerMode === 'create'"
          @click="singerMode = 'create'"
        >
          <span class="mode-card-title">新建歌手</span>
          <span class="mode-card-desc">填写名称与简介，可上传头像后入库</span>
        </button>
      </div>

      <div v-if="singerMode === 'select'" class="mode-body">
        <div class="singer-toolbar">
          <el-select
            v-model="selectedSingerId"
            placeholder="搜索或选择歌手"
            filterable
            class="enhanced-select singer-select-field"
            popper-class="admin-select-dropdown"
          >
            <el-option v-for="s in singers" :key="s.id" :label="s.name" :value="s.id" />
          </el-select>
          <el-button type="default" plain @click="loadSingers">
            <el-icon><Refresh /></el-icon>
            刷新列表
          </el-button>
        </div>
        <div class="submit-section">
          <button type="button" class="submit-btn" @click="goToStep2">下一步：上传歌曲</button>
        </div>
      </div>

      <template v-if="singerMode === 'create'">
          <div class="form-row">
            <div class="form-group">
              <label>歌手名称 *</label>
              <input v-model="singerForm.name" type="text" placeholder="请输入歌手名称" />
            </div>
          </div>
          <div class="form-group">
            <label>歌手头像</label>
            <div class="cover-section">
              <div class="cover-drop-zone" @click="triggerSingerAvatarInput">
                <input ref="singerAvatarInput" type="file" accept="image/*" @change="handleSingerAvatarSelect" hidden />
                <img v-if="singerAvatarPreview" :src="singerAvatarPreview" alt="头像" class="cover-preview" />
                <div v-else class="placeholder">
                  <span>点击上传头像</span>
                </div>
              </div>
              <div v-if="singerAvatarPreview" class="cover-actions">
                <button type="button" class="edit-btn" @click="showSingerCropper = true">编辑</button>
                <button type="button" class="remove-btn" @click="removeSingerAvatar">移除</button>
              </div>
            </div>
          </div>
          <div class="form-group">
            <label>歌手简介</label>
            <textarea v-model="singerForm.description" placeholder="简介（可选）" rows="3"></textarea>
          </div>
          <div class="submit-section">
            <button type="button" class="submit-btn" @click="handleCreateSinger" :disabled="singerCreating">
              {{ singerCreating ? '创建中...' : '创建歌手并下一步' }}
            </button>
          </div>
      </template>
        </section>

        <section v-show="step === 2" class="admin-surface step-panel-wrap">
        <form @submit.prevent="handleSubmit" class="upload-form">
          <div class="form-group">
            <label>音乐文件 *</label>
            <div class="file-drop-zone" :class="{ 'drag-over': isDragging }" @dragover.prevent="isDragging = true"
              @dragleave="isDragging = false" @drop.prevent="handleFileDrop" @click="triggerMusicInput">
              <input ref="musicInput" type="file" accept="audio/*" @change="handleMusicSelect" hidden />
              <div v-if="!musicFile" class="placeholder">
                <p>拖拽或点击上传</p>
                <span>支持 MP3、WAV、FLAC</span>
              </div>
              <div v-else class="file-selected">
                <span>{{ musicFile.name }}</span>
                <button type="button" class="remove-btn" @click.stop="musicFile = null">移除</button>
              </div>
            </div>
          </div>

          <div class="form-group">
            <label>封面图片（支持裁剪，避免中文乱码）</label>
            <div class="cover-section">
              <div class="cover-drop-zone" @click="triggerCoverInput">
                <input ref="coverInput" type="file" accept="image/*" @change="handleCoverSelect" hidden />
                <img v-if="coverPreview" :src="coverPreview" alt="封面" class="cover-preview" />
                <div v-else class="placeholder"><span>点击上传封面</span></div>
              </div>
              <div v-if="coverPreview" class="cover-actions">
                <button type="button" class="edit-btn" @click="showCropper = true">编辑</button>
                <button type="button" class="remove-btn" @click="removeCover">移除</button>
              </div>
            </div>
          </div>

          <div class="form-group">
            <label>歌词文件（.lrc，可选）</label>
            <div class="file-drop-zone lyric-zone" @click="triggerLyricInput">
              <input ref="lyricInput" type="file" accept=".lrc,text/plain" @change="handleLyricSelect" hidden />
              <div v-if="!lyricFile" class="placeholder">
                <span>点击上传 .lrc 歌词文件</span>
              </div>
              <div v-else class="file-selected">
                <span>{{ lyricFile.name }}</span>
                <button type="button" class="remove-btn" @click.stop="lyricFile = null">移除</button>
              </div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>歌曲名称 *</label>
              <input v-model="form.title" type="text" placeholder="请输入歌曲名称" required />
            </div>
            <div class="form-group">
              <label>歌手 *</label>
              <input v-model="form.artist" type="text" placeholder="歌手名" required :readonly="!!currentSingerName" />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>专辑名称</label>
              <input v-model="form.album" type="text" placeholder="专辑（可选）" />
            </div>
            <div class="form-group">
              <label>分类</label>
              <el-select
                v-model="form.categoryId"
                placeholder="请选择分类"
                class="enhanced-select category-select"
                popper-class="admin-select-dropdown"
              >
                <el-option v-for="cat in categories" :key="cat.id" :label="cat.name" :value="cat.id" />
              </el-select>
            </div>
          </div>

          <div class="form-group">
            <label>歌词文本（若无 .lrc 文件可在此填写）</label>
            <textarea v-model="form.lyrics" placeholder="歌词（可选）"></textarea>
          </div>

          <div class="submit-section">
            <button type="button" class="secondary-btn" @click="step = 1">上一步</button>
            <button type="submit" class="submit-btn" :disabled="uploading">
              {{ uploading ? '上传中...' : '上传音乐' }}
            </button>
          </div>
        </form>
      <div v-if="uploadSuccess" class="success-msg">上传成功！歌曲已提交审核。</div>
        </section>
      </div>
    </div>

    <CoverCropper v-model="showCropper" :image-url="originalImageUrl" @confirm="handleCoverConfirm" />
    <CoverCropper v-model="showSingerCropper" :image-url="singerOriginalUrl" @confirm="handleSingerAvatarConfirm" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { Refresh } from '@element-plus/icons-vue'
import { adminApi } from '../../api'
// @ts-ignore
import CoverCropper from '../../components/CoverCropper.vue'

const step = ref(1)
const singerMode = ref<'select' | 'create'>('select')
const singers = ref<any[]>([])
const selectedSingerId = ref<number | ''>('')
const singerForm = ref({ name: '', description: '' })
const singerAvatarFile = ref<File | null>(null)
const singerAvatarPreview = ref<string | null>(null)
const singerOriginalUrl = ref('')
const showSingerCropper = ref(false)
const singerCreating = ref(false)

const musicInput = ref<HTMLInputElement | null>(null)
const coverInput = ref<HTMLInputElement | null>(null)
const lyricInput = ref<HTMLInputElement | null>(null)
const singerAvatarInput = ref<HTMLInputElement | null>(null)

const musicFile = ref<File | null>(null)
const coverFile = ref<File | null>(null)
const lyricFile = ref<File | null>(null)
const coverPreview = ref<string | null>(null)
const originalImageUrl = ref('')
const showCropper = ref(false)

const isDragging = ref(false)
const uploading = ref(false)
const uploadSuccess = ref(false)

const form = ref({ title: '', artist: '', album: '', categoryId: '', lyrics: '' })
const categories = ref<any[]>([])

const currentSingerName = ref('')

watch(selectedSingerId, (id) => {
  if (id) {
    const s = singers.value.find((x) => x.id === Number(id))
    if (s) {
      form.value.artist = s.name
      currentSingerName.value = s.name
    }
  } else {
    currentSingerName.value = ''
  }
})

const triggerMusicInput = () => musicInput.value?.click()
const triggerCoverInput = () => coverInput.value?.click()
const triggerLyricInput = () => lyricInput.value?.click()
const triggerSingerAvatarInput = () => singerAvatarInput.value?.click()

const handleMusicSelect = (e: Event) => {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (file) {
    musicFile.value = file
    if (!form.value.title) form.value.title = file.name.replace(/\.[^/.]+$/, '')
  }
}

const handleFileDrop = (e: DragEvent) => {
  isDragging.value = false
  const file = e.dataTransfer?.files?.[0]
  if (file && file.type.startsWith('audio/')) {
    musicFile.value = file
    if (!form.value.title) form.value.title = file.name.replace(/\.[^/.]+$/, '')
  }
}

const handleLyricSelect = (e: Event) => {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (file) lyricFile.value = file
}

const handleCoverSelect = (e: Event) => {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (file && file.type.startsWith('image/')) {
    const reader = new FileReader()
    reader.onload = (ev) => {
      coverPreview.value = ev.target?.result as string
      originalImageUrl.value = ev.target?.result as string
      showCropper.value = true
    }
    reader.readAsDataURL(file)
  }
}

const handleCoverConfirm = (blob: Blob) => {
  coverFile.value = new File([blob], 'cover.jpg', { type: 'image/jpeg' })
  const reader = new FileReader()
  reader.onload = (e) => { coverPreview.value = e.target?.result as string }
  reader.readAsDataURL(coverFile.value)
}

const removeCover = () => {
  coverFile.value = null
  coverPreview.value = null
  originalImageUrl.value = ''
}

const handleSingerAvatarSelect = (e: Event) => {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (file && file.type.startsWith('image/')) {
    const reader = new FileReader()
    reader.onload = (ev) => {
      singerOriginalUrl.value = ev.target?.result as string
      showSingerCropper.value = true
    }
    reader.readAsDataURL(file)
  }
}

const handleSingerAvatarConfirm = (blob: Blob) => {
  singerAvatarFile.value = new File([blob], 'avatar.jpg', { type: 'image/jpeg' })
  const reader = new FileReader()
  reader.onload = (e) => { singerAvatarPreview.value = e.target?.result as string }
  reader.readAsDataURL(singerAvatarFile.value)
}

const removeSingerAvatar = () => {
  singerAvatarFile.value = null
  singerAvatarPreview.value = null
  singerOriginalUrl.value = ''
}

const loadCategories = async () => {
  try {
    const res = await adminApi.getCategories()
    categories.value = res.data?.data ?? []
  } catch (e) {
    console.error('loadCategories:', e)
  }
}

const loadSingers = async () => {
  try {
    const res = await adminApi.listSingers(1, 200)
    singers.value = res.data?.data?.records ?? []
  } catch (e) {
    console.error('loadSingers:', e)
  }
}

const handleCreateSinger = async () => {
  if (!singerForm.value.name?.trim()) {
    alert('请输入歌手名称')
    return
  }
  singerCreating.value = true
  try {
    const fd = new FormData()
    fd.append('name', singerForm.value.name.trim())
    if (singerForm.value.description) fd.append('description', singerForm.value.description)
    if (singerAvatarFile.value) fd.append('avatar', singerAvatarFile.value)
    const res = await adminApi.createSinger(fd)
    const singer = res.data?.data
    if (singer) {
      singers.value.unshift(singer)
      selectedSingerId.value = singer.id
      singerMode.value = 'select'
      form.value.artist = singer.name
      currentSingerName.value = singer.name
      singerForm.value = { name: '', description: '' }
      removeSingerAvatar()
      step.value = 2
    }
  } catch (e: any) {
    const msg = e?.response?.data?.message ?? e?.message ?? '创建失败'
    alert(msg)
  } finally {
    singerCreating.value = false
  }
}

const goToStep2 = () => {
  if (singerMode.value === 'select' && !selectedSingerId.value) {
    alert('请先选择歌手，或创建新歌手')
    return
  }
  step.value = 2
}

const handleSubmit = async () => {
  if (!musicFile.value) {
    alert('请选择音乐文件')
    return
  }
  if (!form.value.title?.trim() || !form.value.artist?.trim()) {
    alert('请填写歌曲名称和歌手名称')
    return
  }
  uploading.value = true
  uploadSuccess.value = false
  try {
    const fd = new FormData()
    fd.append('music', musicFile.value)
    if (coverFile.value) fd.append('cover', coverFile.value)
    if (lyricFile.value) fd.append('lyric', lyricFile.value)
    fd.append('title', form.value.title.trim())
    fd.append('artist', form.value.artist.trim())
    if (form.value.album) fd.append('album', form.value.album)
    if (form.value.categoryId) fd.append('categoryId', String(form.value.categoryId))
    if (form.value.lyrics) fd.append('lyrics', form.value.lyrics)
    if (selectedSingerId.value) fd.append('artistId', String(selectedSingerId.value))

    await adminApi.uploadTrack(fd)
    uploadSuccess.value = true
    musicFile.value = null
    coverFile.value = null
    lyricFile.value = null
    coverPreview.value = null
    originalImageUrl.value = ''
    form.value = { title: '', artist: currentSingerName.value || '', album: '', categoryId: '', lyrics: '' }
  } catch (e: any) {
    const msg = e?.response?.data?.message ?? e?.message ?? '上传失败'
    alert(msg)
  } finally {
    uploading.value = false
  }
}

onMounted(() => {
  loadCategories()
  loadSingers()
})
</script>

<style scoped>
.upload-steps-scroll {
  min-height: 0;
}
.upload-steps-inner {
  display: flex;
  flex-direction: column;
  gap: var(--sp-5);
  padding-bottom: var(--sp-6);
}

.upload-hero .admin-page-title {
  margin-bottom: var(--sp-2);
}

.upload-hero .steps {
  margin-top: var(--sp-6);
  margin-bottom: 0;
}

.step-panel-wrap {
  padding: var(--sp-6);
}

.panel-title {
  margin: 0 0 var(--sp-4);
  font-size: var(--text-md);
  font-weight: 600;
  color: var(--text-primary);
  letter-spacing: -0.02em;
}

.mode-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: var(--sp-4);
  margin-bottom: var(--sp-6);
}

.mode-card {
  text-align: left;
  padding: var(--sp-5);
  border-radius: var(--radius-lg);
  border: 1px solid rgba(91, 154, 136, 0.22);
  background: color-mix(in srgb, var(--bg-hover) 94%, #ecf8f3 6%);
  cursor: pointer;
  transition: border-color 0.15s, box-shadow 0.15s, background 0.15s;
  display: flex;
  flex-direction: column;
  gap: var(--sp-2);
}

.mode-card:hover {
  border-color: color-mix(in srgb, var(--accent) 40%, transparent);
  box-shadow: 0 4px 14px rgba(61, 107, 94, 0.08);
}

.mode-card.active {
  border-color: color-mix(in srgb, var(--accent) 55%, transparent);
  background: color-mix(in srgb, var(--accent) 12%, var(--bg-hover) 88%);
  box-shadow: 0 0 0 1px color-mix(in srgb, var(--accent) 25%, transparent);
}

.mode-card-title {
  font-weight: 600;
  font-size: var(--text-base);
  color: var(--text-primary);
}

.mode-card-desc {
  font-size: var(--text-sm);
  color: var(--text-secondary);
  line-height: 1.45;
}

.singer-toolbar {
  display: flex;
  flex-wrap: wrap;
  gap: var(--sp-3);
  align-items: center;
  margin-bottom: var(--sp-5);
}

.singer-select-field {
  flex: 1 1 260px;
  min-width: 200px;
}

.mode-body {
  margin-top: var(--sp-2);
}

.steps { display: flex; align-items: center; gap: 0; margin-bottom: var(--sp-6); }
.step { display: flex; align-items: center; gap: var(--sp-2); cursor: pointer; color: var(--text-tertiary); }
.step.active { color: var(--accent); }
.step.done { color: var(--text-secondary); }
.step-num { width: 28px; height: 28px; border-radius: 50%; background: var(--border); display: flex; align-items: center; justify-content: center; font-size: var(--text-sm); }
.step.active .step-num { background: var(--accent); color: white; }
.step-line { flex: 1; max-width: 60px; height: 2px; background: var(--border); }
.step-line.done { background: var(--accent); }
.step-panel { margin-top: var(--sp-4); }

.upload-form, .form-group { display: flex; flex-direction: column; gap: var(--sp-3); }
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: var(--sp-5); }
.form-group label { font-size: var(--text-base); color: var(--text-primary); }

.file-drop-zone, .cover-drop-zone { border: 2px dashed var(--border-hover); border-radius: var(--radius-md); padding: var(--sp-6); text-align: center; cursor: pointer; }
.file-drop-zone:hover, .file-drop-zone.drag-over { border-color: var(--accent); background: var(--accent-muted); }
.lyric-zone { padding: var(--sp-4); }
.placeholder { color: var(--text-secondary); }
.placeholder p { margin: var(--sp-2) 0; }
.placeholder span { font-size: var(--text-xs); color: var(--text-tertiary); }
.file-selected { display: flex; align-items: center; justify-content: center; gap: var(--sp-4); }
.remove-btn { padding: var(--sp-2) var(--sp-3); border: none; border-radius: var(--radius-sm); background: rgba(239,68,68,0.2); color: var(--red); cursor: pointer; }

.cover-section { display: flex; align-items: flex-start; gap: var(--sp-5); }
.cover-drop-zone { width: 200px; height: 200px; display: flex; align-items: center; justify-content: center; }
.cover-preview { max-width: 100%; max-height: 100%; border-radius: var(--radius-sm); object-fit: cover; }
.cover-actions { display: flex; flex-direction: column; gap: var(--sp-3); }
.edit-btn, .remove-btn { display: flex; align-items: center; gap: var(--sp-2); padding: var(--sp-2) var(--sp-4); border: none; border-radius: var(--radius-sm); cursor: pointer; }
.edit-btn { background: var(--accent-muted); color: var(--accent); }
.edit-btn:hover { background: rgba(99,102,241,0.25); }
.remove-btn:hover { background: rgba(239,68,68,0.3); }

.category-select { width: 100%; }
.enhanced-select { font-size: 15px !important; }
.enhanced-select :deep(.el-input__wrapper) {
  padding: var(--sp-3) var(--sp-4);
  min-height: 44px;
  background: var(--bg-hover);
  border: 1px solid var(--border-hover);
  box-shadow: none;
}
.enhanced-select :deep(.el-input__wrapper:hover) { border-color: var(--accent); }
.enhanced-select :deep(.el-input__inner) { font-size: 15px; color: var(--text-primary); }
.enhanced-select :deep(.el-input__placeholder) { color: var(--text-tertiary); font-size: 14px; }

input, select, textarea { padding: var(--sp-3); border: 1px solid var(--border); border-radius: var(--radius-sm); background: var(--bg-hover); color: var(--text-primary); }
textarea { min-height: 80px; resize: vertical; }

.submit-section { display: flex; gap: var(--sp-4); justify-content: center; margin-top: var(--sp-6); }
.submit-btn { padding: var(--sp-4) var(--sp-12); border: none; border-radius: var(--radius-md); background: var(--accent); color: var(--text-primary); cursor: pointer; }
.submit-btn:hover:not(:disabled) { background: var(--accent-hover); }
.submit-btn:disabled { opacity: 0.6; cursor: not-allowed; }
.secondary-btn { padding: var(--sp-4) var(--sp-8); border: 1px solid var(--border); border-radius: var(--radius-md); background: var(--bg-hover); cursor: pointer; }
.success-msg { margin-top: var(--sp-5); padding: var(--sp-4); background: rgba(34,197,94,0.2); border-radius: var(--radius-sm); color: var(--green); text-align: center; }
</style>

<style>
/* 管理员上传页下拉样式（popper-class="admin-select-dropdown"） */
.admin-select-dropdown.el-select-dropdown {
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif !important;
  background: #1c1c26 !important;
  border: 1px solid rgba(255,255,255,0.1) !important;
  box-shadow: 0 8px 32px rgba(0,0,0,0.4) !important;
}
.admin-select-dropdown .el-select-dropdown__wrap { max-height: 280px !important; }
.admin-select-dropdown .el-select-dropdown__list { padding: 6px 0 !important; }
.admin-select-dropdown .el-select-dropdown__item {
  font-size: 15px !important;
  padding: 12px 16px !important;
  line-height: 1.4 !important;
  color: rgba(255,255,255,0.9) !important;
}
.admin-select-dropdown .el-select-dropdown__item:hover { background: rgba(99,102,241,0.2) !important; color: #fff !important; }
.admin-select-dropdown .el-select-dropdown__item.is-selected { color: #818cf8 !important; font-weight: 500; }
</style>
