<template>
  <div class="settings-page">
    <header class="top-bar">
      <button type="button" class="icon-back" @click="goBack" aria-label="返回">
        <svg viewBox="0 0 24 24" width="22" height="22"><path fill="currentColor" d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"/></svg>
      </button>
      <h1 class="page-title">个人设置</h1>
      <span class="top-spacer" />
    </header>

    <div class="page-body">
      <p class="lead">分区管理资料与账号安全，点击标题展开或收起。</p>

      <!-- 形象设计 -->
      <section class="fold" :class="{ open: openKey === 'profile' }">
        <button type="button" class="fold-head" @click="toggle('profile')">
          <span class="fold-title">
            <span class="fold-ico">◇</span>
            形象设计
          </span>
          <svg class="chev" viewBox="0 0 24 24" width="20" height="20"><path fill="currentColor" d="M7.41 8.59L12 13.17l4.59-4.58L18 10l-6 6-6-6 1.41-1.41z"/></svg>
        </button>
        <div class="fold-body">
          <div class="profile-row">
            <div class="avatar-hit" @click="triggerAvatarUpload">
              <img :src="userAvatar" alt="头像" class="avatar-img" />
              <span class="avatar-ring" />
              <input ref="avatarInputRef" type="file" accept="image/*" class="hidden-file" @change="handleAvatarChange" />
            </div>
            <div class="profile-fields">
              <label class="mini-label">昵称</label>
              <input v-model="formData.nickname" type="text" class="line-input" placeholder="展示名称" maxlength="20" />
              <span class="micro-tip">点击左侧头像可裁剪上传</span>
            </div>
          </div>
          <div class="actions-row profile-actions">
            <button type="button" class="btn primary" :disabled="profileSaving" @click="handleSaveProfile">
              {{ profileSaving ? '保存中…' : '保存修改' }}
            </button>
          </div>
        </div>
      </section>

      <!-- 个人详情 -->
      <section class="fold" :class="{ open: openKey === 'details' }">
        <button type="button" class="fold-head" @click="toggle('details')">
          <span class="fold-title">
            <span class="fold-ico">◇</span>
            个人详情
          </span>
          <svg class="chev" viewBox="0 0 24 24" width="20" height="20"><path fill="currentColor" d="M7.41 8.59L12 13.17l4.59-4.58L18 10l-6 6-6-6 1.41-1.41z"/></svg>
        </button>
        <div class="fold-body">
          <label class="mini-label">个性签名</label>
          <textarea v-model="formData.signature" class="area-input" placeholder="一句介绍自己…" maxlength="200" rows="3" />

          <label class="mini-label">性别</label>
          <div class="pill-row">
            <button type="button" class="pill" :class="{ on: formData.gender === 'male' }" @click="formData.gender = 'male'">男</button>
            <button type="button" class="pill" :class="{ on: formData.gender === 'female' }" @click="formData.gender = 'female'">女</button>
            <button type="button" class="pill" :class="{ on: formData.gender === 'other' }" @click="formData.gender = 'other'">保密</button>
          </div>

          <label class="mini-label">生日</label>
          <div class="date-wrap">
            <input v-model="formData.birthday" type="date" class="line-input" />
          </div>

          <label class="mini-label">地区</label>
          <input v-model="formData.region" type="text" class="line-input" placeholder="城市或地区" />

          <div class="actions-row">
            <button type="button" class="btn ghost" @click="goBack">取消</button>
            <button type="button" class="btn primary" :disabled="saving" @click="handleSave">
              {{ saving ? '保存中…' : '保存资料' }}
            </button>
          </div>
        </div>
      </section>

      <!-- 账号安全 -->
      <section class="fold" :class="{ open: openKey === 'security' }">
        <button type="button" class="fold-head" @click="toggle('security')">
          <span class="fold-title">
            <span class="fold-ico">◇</span>
            账号安全 · 修改密码
          </span>
          <svg class="chev" viewBox="0 0 24 24" width="20" height="20"><path fill="currentColor" d="M7.41 8.59L12 13.17l4.59-4.58L18 10l-6 6-6-6 1.41-1.41z"/></svg>
        </button>
        <div class="fold-body">
          <label class="mini-label">当前密码</label>
          <input v-model="pwdForm.oldPassword" type="password" class="line-input" autocomplete="current-password" />

          <label class="mini-label">新密码</label>
          <input v-model="pwdForm.newPassword" type="password" class="line-input" autocomplete="new-password" placeholder="至少 6 位" />

          <label class="mini-label">确认新密码</label>
          <input v-model="pwdForm.confirmPassword" type="password" class="line-input" autocomplete="new-password" />

          <button type="button" class="btn primary block" :disabled="pwdSaving" @click="handleChangePassword">
            {{ pwdSaving ? '提交中…' : '更新密码' }}
          </button>
        </div>
      </section>
    </div>

    <AvatarCropper v-model="showAvatarCropper" :image-url="cropperImageUrl" @confirm="handleAvatarConfirm" />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '../stores/user'
import { userApi } from '../api'
import { DEFAULT_AVATAR_COVER } from '../constants'
// @ts-ignore
import AvatarCropper from '../components/AvatarCropper.vue'

const router = useRouter()
const userStore = useUserStore()
const defaultAvatar = DEFAULT_AVATAR_COVER

type FoldKey = 'profile' | 'details' | 'security'
const openKey = ref<FoldKey | null>('profile')

function toggle(key: FoldKey) {
  openKey.value = openKey.value === key ? null : key
}

const formData = ref({
  nickname: '',
  signature: '',
  gender: '',
  birthday: '',
  region: ''
})

const pwdForm = ref({ oldPassword: '', newPassword: '', confirmPassword: '' })
const saving = ref(false)
const profileSaving = ref(false)
const pwdSaving = ref(false)
const avatarInputRef = ref<HTMLInputElement>()
const showAvatarCropper = ref(false)
const cropperImageUrl = ref('')

const userAvatar = computed(() => {
  const user = userStore.currentUser as { avatar?: string } | null
  return user?.avatar || defaultAvatar
})

const initData = () => {
  const user = userStore.currentUser as Record<string, string | undefined> | null
  if (user) {
    formData.value.nickname = user.nickname || ''
    formData.value.signature = user.signature || ''
    formData.value.gender = user.gender || ''
    formData.value.birthday = user.birthday || ''
    formData.value.region = user.region || ''
  }
}

const triggerAvatarUpload = () => {
  avatarInputRef.value?.click()
}

const handleAvatarChange = (e: Event) => {
  const input = e.target as HTMLInputElement
  const file = input.files?.[0]
  if (file) {
    if (!file.type.startsWith('image/')) {
      ElMessage.error('请选择图片文件')
      return
    }
    if (file.size > 5 * 1024 * 1024) {
      ElMessage.error('图片不能超过 5MB')
      return
    }
    const reader = new FileReader()
    reader.onload = (ev) => {
      cropperImageUrl.value = ev.target?.result as string
      showAvatarCropper.value = true
    }
    reader.readAsDataURL(file)
  }
  input.value = ''
}

const handleAvatarConfirm = async (blob: Blob) => {
  try {
    const file = new File([blob], 'avatar.jpg', { type: 'image/jpeg' })
    const res = await userApi.uploadAvatar(file)
    if (res.data.code === 200) {
      const userRes = await userApi.getUserInfo()
      if (userRes.data.code === 200) userStore.setUser(userRes.data.data)
      ElMessage.success('头像已更新')
    } else {
      ElMessage.error(res.data.message || '上传失败')
    }
  } catch (e: unknown) {
    const err = e as { response?: { data?: { message?: string } } }
    ElMessage.error(err.response?.data?.message || '上传失败')
  }
}

const handleSaveProfile = async () => {
  if (!formData.value.nickname.trim()) {
    ElMessage.warning('请填写昵称')
    return
  }
  profileSaving.value = true
  try {
    const res = await userApi.updateUserInfo({
      nickname: formData.value.nickname.trim()
    })
    if (res.data.code === 200) {
      const userRes = await userApi.getUserInfo()
      if (userRes.data.code === 200) userStore.setUser(userRes.data.data)
      ElMessage.success('形象设计已保存')
    } else {
      ElMessage.error(res.data.message || '保存失败')
    }
  } catch (e: unknown) {
    const err = e as { response?: { data?: { message?: string } } }
    ElMessage.error(err.response?.data?.message || '保存失败')
  } finally {
    profileSaving.value = false
  }
}

const handleChangePassword = async () => {
  if (!pwdForm.value.oldPassword) {
    ElMessage.warning('填写当前密码')
    return
  }
  if (!pwdForm.value.newPassword || pwdForm.value.newPassword.length < 6) {
    ElMessage.warning('新密码至少 6 位')
    return
  }
  if (pwdForm.value.newPassword !== pwdForm.value.confirmPassword) {
    ElMessage.warning('两次新密码不一致')
    return
  }
  pwdSaving.value = true
  try {
    const res = await userApi.changePassword(pwdForm.value.oldPassword, pwdForm.value.newPassword)
    if (res.data.code === 200) {
      ElMessage.success('密码已更新')
      pwdForm.value = { oldPassword: '', newPassword: '', confirmPassword: '' }
    } else {
      ElMessage.error(res.data.message || '修改失败')
    }
  } catch (e: unknown) {
    const err = e as { response?: { data?: { message?: string } } }
    ElMessage.error(err.response?.data?.message || '修改失败')
  } finally {
    pwdSaving.value = false
  }
}

const handleSave = async () => {
  if (!formData.value.nickname.trim()) {
    ElMessage.warning('请填写昵称')
    return
  }
  saving.value = true
  try {
    const updateData: Record<string, string> = {
      nickname: formData.value.nickname.trim(),
      signature: formData.value.signature.trim()
    }
    if (formData.value.gender) updateData.gender = formData.value.gender
    if (formData.value.birthday) updateData.birthday = formData.value.birthday
    if (formData.value.region) updateData.region = formData.value.region

    const res = await userApi.updateUserInfo(updateData)
    if (res.data.code === 200) {
      const userRes = await userApi.getUserInfo()
      if (userRes.data.code === 200) userStore.setUser(userRes.data.data)
      ElMessage.success('已保存')
      goBack()
    } else {
      ElMessage.error(res.data.message || '保存失败')
    }
  } catch (e: unknown) {
    const err = e as { response?: { data?: { message?: string } } }
    ElMessage.error(err.response?.data?.message || '保存失败')
  } finally {
    saving.value = false
  }
}

const goBack = () => {
  router.back()
}

onMounted(() => {
  if (!userStore.currentUser) {
    router.push('/login')
    return
  }
  initData()
})
</script>

<style scoped>
.settings-page {
  min-height: 100vh;
  background: var(--bg-primary);
  color: var(--text-primary);
}

.top-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--sp-4) var(--sp-5);
  position: sticky;
  top: 0;
  z-index: 20;
  background: var(--bg-secondary);
  backdrop-filter: blur(14px);
  border-bottom: 1px solid var(--border);
}

.icon-back {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 12px;
  background: var(--bg-hover);
  color: var(--text-primary);
  cursor: pointer;
  transition: background 0.2s, transform 0.15s;
}

.icon-back:hover {
  background: var(--bg-active);
  transform: translateX(-2px);
}

.page-title {
  margin: 0;
  font-size: 1.05rem;
  font-weight: 600;
}

.top-spacer {
  width: 40px;
}

.page-body {
  max-width: 520px;
  margin: 0 auto;
  padding: var(--sp-5) var(--sp-5) var(--sp-10);
}

.lead {
  margin: 0 0 var(--sp-5);
  font-size: var(--text-sm);
  color: var(--text-secondary);
  line-height: 1.5;
}

.fold {
  margin-bottom: var(--sp-3);
  border-radius: 16px;
  border: 1px solid var(--border);
  background: var(--bg-secondary);
  overflow: hidden;
  transition: box-shadow 0.25s, border-color 0.25s;
}

.fold.open {
  border-color: rgba(194, 12, 12, 0.35);
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.2);
}

.fold-head {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--sp-4) var(--sp-4);
  border: none;
  background: transparent;
  color: var(--text-primary);
  cursor: pointer;
  text-align: left;
  transition: background 0.2s;
}

.fold-head:hover {
  background: var(--bg-hover);
}

.fold-title {
  display: flex;
  align-items: center;
  gap: 10px;
  font-weight: 600;
  font-size: var(--text-base);
}

.fold-ico {
  color: #c20c0c;
  font-size: 10px;
  opacity: 0.9;
}

.chev {
  flex-shrink: 0;
  color: var(--text-tertiary);
  transition: transform 0.35s cubic-bezier(0.22, 1, 0.36, 1);
}

.fold.open .chev {
  transform: rotate(180deg);
}

.fold-body {
  display: none;
  padding: 0 var(--sp-4) var(--sp-5);
  animation: foldIn 0.35s ease both;
}

.fold.open .fold-body {
  display: block;
}

@keyframes foldIn {
  from {
    opacity: 0;
    transform: translateY(-6px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.profile-row {
  display: flex;
  gap: var(--sp-5);
  align-items: center;
  padding-top: var(--sp-2);
}

.avatar-hit {
  position: relative;
  width: 88px;
  height: 88px;
  flex-shrink: 0;
  cursor: pointer;
}

.avatar-img {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  object-fit: cover;
  display: block;
}

.avatar-ring {
  position: absolute;
  inset: -3px;
  border-radius: 50%;
  border: 2px solid rgba(194, 12, 12, 0.45);
  pointer-events: none;
  animation: pulse 2.8s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 0.7; transform: scale(1); }
  50% { opacity: 1; transform: scale(1.03); }
}

.hidden-file {
  display: none;
}

.profile-fields {
  flex: 1;
  min-width: 0;
}

.mini-label {
  display: block;
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.06em;
  color: var(--text-tertiary);
  margin-bottom: 6px;
  margin-top: var(--sp-4);
}

.fold-body .mini-label:first-child {
  margin-top: 0;
}

.micro-tip {
  display: block;
  margin-top: 8px;
  font-size: 11px;
  color: var(--text-tertiary);
}

.line-input,
.area-input {
  width: 100%;
  box-sizing: border-box;
  padding: 12px 14px;
  border-radius: 12px;
  border: 1px solid var(--border);
  background: var(--bg-primary);
  color: var(--text-primary);
  font-size: var(--text-base);
  font-family: inherit;
  transition: border-color 0.2s;
}

.line-input:focus,
.area-input:focus {
  outline: none;
  border-color: rgba(194, 12, 12, 0.5);
}

.area-input {
  resize: vertical;
  min-height: 88px;
}

.pill-row {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.pill {
  padding: 10px 20px;
  border-radius: 999px;
  border: 1px solid var(--border);
  background: var(--bg-primary);
  color: var(--text-secondary);
  font-size: var(--text-sm);
  cursor: pointer;
  transition: all 0.2s;
}

.pill:hover {
  border-color: var(--accent);
}

.pill.on {
  border-color: #c20c0c;
  background: rgba(194, 12, 12, 0.12);
  color: var(--text-primary);
}

.date-wrap .line-input {
  color-scheme: dark;
}

.actions-row {
  display: flex;
  justify-content: flex-end;
  gap: var(--sp-3);
  margin-top: var(--sp-5);
  padding-top: var(--sp-4);
  border-top: 1px solid var(--border);
}

.btn {
  padding: 10px 22px;
  border-radius: 12px;
  font-size: var(--text-sm);
  font-weight: 600;
  cursor: pointer;
  border: none;
  transition: transform 0.15s, opacity 0.15s;
}

.btn:hover:not(:disabled) {
  transform: translateY(-1px);
}

.btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.btn.ghost {
  background: var(--bg-hover);
  color: var(--text-secondary);
  border: 1px solid var(--border);
}

.btn.primary {
  background: linear-gradient(90deg, #c20c0c, #9f0303);
  color: #fff;
  box-shadow: 0 6px 20px rgba(194, 12, 12, 0.25);
}

.btn.block {
  width: 100%;
  margin-top: var(--sp-4);
}

.profile-actions {
  justify-content: flex-end;
  margin-top: var(--sp-4);
}

@media (max-width: 480px) {
  .profile-row {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>
