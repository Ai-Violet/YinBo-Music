<template>
  <div class="settings-page">
    <!-- 顶部导航栏 -->
    <header class="top-header">
      <div class="logo">
        <svg viewBox="0 0 24 24" width="28" height="28" fill="currentColor" style="color: #C20C0C">
          <path d="M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z"/>
        </svg>
        <span class="logo-text">音波音乐</span>
      </div>
      <div class="header-title">个人设置</div>
      <div class="header-actions">
        <button class="back-btn" @click="goBack">
          <svg viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"/>
          </svg>
          <span>返回</span>
        </button>
      </div>
    </header>

    <div class="settings-container">
      <div class="settings-card">
        <div class="card-header">
          <h3>编辑个人信息</h3>
        </div>
        
        <div class="card-body">
          <!-- 头像 -->
          <div class="form-group">
            <label>头像</label>
            <div class="avatar-section">
              <div class="avatar-wrapper" @click="triggerAvatarUpload">
                <img :src="userAvatar" alt="头像" class="user-avatar" />
                <div class="avatar-overlay">
                  <svg viewBox="0 0 24 24" width="24" height="24">
                    <path fill="white" d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
                  </svg>
                </div>
                <input 
                  ref="avatarInputRef"
                  type="file" 
                  accept="image/*" 
                  style="display: none" 
                  @change="handleAvatarChange"
                />
              </div>
              <span class="avatar-tip">点击更换头像</span>
            </div>
          </div>

          <!-- 昵称 -->
          <div class="form-group">
            <label>昵称</label>
            <input 
              type="text" 
              v-model="formData.nickname" 
              class="form-input"
              placeholder="请输入昵称"
              maxlength="20"
            />
          </div>

          <!-- 个性签名 -->
          <div class="form-group">
            <label>个性签名</label>
            <textarea 
              v-model="formData.signature" 
              class="form-textarea"
              placeholder="写点什么介绍自己吧..."
              maxlength="200"
              rows="3"
            ></textarea>
          </div>

          <!-- 性别 -->
          <div class="form-group">
            <label>性别</label>
            <div class="gender-options">
              <button 
                class="gender-btn" 
                :class="{ active: formData.gender === 'male' }"
                @click="formData.gender = 'male'"
              >
                男
              </button>
              <button 
                class="gender-btn" 
                :class="{ active: formData.gender === 'female' }"
                @click="formData.gender = 'female'"
              >
                女
              </button>
              <button 
                class="gender-btn" 
                :class="{ active: formData.gender === 'other' }"
                @click="formData.gender = 'other'"
              >
                保密
              </button>
            </div>
          </div>

          <!-- 生日 -->
          <div class="form-group">
            <label>生日</label>
            <div class="date-input-wrapper">
              <input 
                type="date" 
                v-model="formData.birthday" 
                class="form-input date-input"
              />
              <svg class="calendar-icon" viewBox="0 0 24 24" width="20" height="20">
                <path fill="currentColor" d="M19 4h-1V2h-2v2H8V2H6v2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 16H5V10h14v10zm0-12H5V6h14v2z"/>
              </svg>
            </div>
          </div>

          <!-- 地区 -->
          <div class="form-group">
            <label>地区</label>
            <input 
              type="text" 
              v-model="formData.region" 
              class="form-input"
              placeholder="请输入地区"
            />
          </div>
        </div>

        <div class="card-footer">
          <button class="btn-cancel" @click="goBack">取消</button>
          <button class="btn-save" @click="handleSave" :disabled="saving">
            {{ saving ? '保存中...' : '保存' }}
          </button>
        </div>
      </div>
    </div>

    <!-- 头像裁剪对话框 -->
    <AvatarCropper
      v-model="showAvatarCropper"
      :image-url="cropperImageUrl"
      @confirm="handleAvatarConfirm"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '../stores/user'
import { userApi } from '../api'
// @ts-ignore
import AvatarCropper from '../components/AvatarCropper.vue'

const router = useRouter()
const userStore = useUserStore()

import { DEFAULT_AVATAR_COVER } from '../constants'
const defaultAvatar = DEFAULT_AVATAR_COVER

const formData = ref({
  nickname: '',
  signature: '',
  gender: '',
  birthday: '',
  region: ''
})

const saving = ref(false)
const avatarInputRef = ref<HTMLInputElement>()
const showAvatarCropper = ref(false)
const cropperImageUrl = ref('')

const userAvatar = computed(() => {
  const user = userStore.currentUser as any
  return user?.avatar || defaultAvatar
})

const initData = () => {
  const user = userStore.currentUser as any
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
      ElMessage.error('图片大小不能超过5MB')
      return
    }
    const reader = new FileReader()
    reader.onload = (e) => {
      cropperImageUrl.value = e.target?.result as string
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
      if (userRes.data.code === 200) {
        userStore.setUser(userRes.data.data)
      }
      ElMessage.success('头像更新成功')
    } else {
      ElMessage.error(res.data.message || '头像更新失败')
    }
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '头像上传失败')
  }
}

const handleSave = async () => {
  if (!formData.value.nickname.trim()) {
    ElMessage.warning('请输入昵称')
    return
  }
  
  try {
    saving.value = true
    const updateData: any = {
      nickname: formData.value.nickname.trim(),
      signature: formData.value.signature.trim()
    }
    
    if (formData.value.gender) updateData.gender = formData.value.gender
    if (formData.value.birthday) updateData.birthday = formData.value.birthday
    if (formData.value.region) updateData.region = formData.value.region
    
    const res = await userApi.updateUserInfo(updateData)
    
    if (res.data.code === 200) {
      const userRes = await userApi.getUserInfo()
      if (userRes.data.code === 200) {
        userStore.setUser(userRes.data.data)
      }
      ElMessage.success('保存成功')
      goBack()
    } else {
      ElMessage.error(res.data.message || '保存失败')
    }
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '保存失败')
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

.top-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--sp-4) var(--sp-8);
  background: var(--bg-secondary);
  backdrop-filter: blur(10px);
  position: sticky;
  top: 0;
  z-index: 100;
}

.logo {
  display: flex;
  align-items: center;
  gap: var(--sp-2);
}

.logo-text {
  font-size: var(--text-lg);
  font-weight: 600;
  background: var(--accent);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.header-title {
  font-size: var(--text-md);
  font-weight: 500;
  color: var(--text-primary);
}

.back-btn {
  display: flex;
  align-items: center;
  gap: var(--sp-1);
  background: none;
  border: none;
  color: var(--text-secondary);
  cursor: pointer;
  padding: var(--sp-2) var(--sp-3);
  border-radius: var(--radius-sm);
  transition: all var(--dur-fast);
  font-size: var(--text-base);
}

.back-btn:hover {
  background: var(--bg-hover);
  color: var(--text-primary);
}

.settings-container {
  display: flex;
  justify-content: center;
  padding: var(--sp-10) var(--sp-5);
}

.settings-card {
  width: 100%;
  max-width: 480px;
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  border: 1px solid var(--border);
  box-shadow: var(--shadow-md);
  overflow: hidden;
}

.card-header {
  padding: var(--sp-5) var(--sp-6);
  border-bottom: 1px solid var(--border);
}

.card-header h3 {
  margin: 0;
  font-size: var(--text-md);
  font-weight: 600;
  color: var(--text-primary);
}

.card-body {
  padding: var(--sp-6);
}

.form-group {
  margin-bottom: var(--sp-6);
}

.form-group:last-child {
  margin-bottom: 0;
}

.form-group label {
  display: block;
  font-size: var(--text-base);
  font-weight: 500;
  color: var(--text-secondary);
  margin-bottom: var(--sp-3);
}

.avatar-section {
  display: flex;
  align-items: center;
  gap: var(--sp-4);
}

.avatar-wrapper {
  width: 80px;
  height: 80px;
  border-radius: var(--radius-full);
  overflow: hidden;
  position: relative;
  cursor: pointer;
  border: 3px solid var(--accent-muted);
  transition: all var(--dur-normal) var(--ease-out);
}

.avatar-wrapper:hover {
  border-color: var(--accent);
  transform: scale(1.05);
}

.avatar-wrapper:hover .avatar-overlay {
  opacity: 1;
}

.user-avatar {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity var(--dur-normal);
}

.avatar-tip {
  font-size: var(--text-sm);
  color: var(--text-tertiary);
}

.gender-options {
  display: flex;
  gap: var(--sp-3);
}

.gender-btn {
  flex: 1;
  padding: var(--sp-3);
  background: var(--bg-hover);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  color: var(--text-tertiary);
  font-size: var(--text-base);
  cursor: pointer;
  transition: all var(--dur-normal);
}

.gender-btn:hover {
  border-color: var(--accent);
  background: var(--accent-muted);
}

.gender-btn.active {
  border-color: var(--accent);
  background: var(--accent-muted);
  color: var(--text-primary);
}

.form-input {
  width: 100%;
  padding: var(--sp-3) var(--sp-4);
  background: var(--bg-hover);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  color: var(--text-primary);
  font-size: var(--text-base);
  transition: all var(--dur-normal);
  box-sizing: border-box;
}

.form-input:focus {
  outline: none;
  border-color: var(--accent);
  background: var(--accent-muted);
}

.form-input::placeholder {
  color: var(--text-tertiary);
}

.form-textarea {
  width: 100%;
  padding: var(--sp-3) var(--sp-4);
  background: var(--bg-hover);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  color: var(--text-primary);
  font-size: var(--text-base);
  transition: all var(--dur-normal);
  box-sizing: border-box;
  resize: vertical;
  min-height: 80px;
  font-family: inherit;
}

.form-textarea:focus {
  outline: none;
  border-color: var(--accent);
  background: var(--accent-muted);
}

.form-textarea::placeholder {
  color: var(--text-tertiary);
}

.date-input-wrapper {
  position: relative;
}

.date-input-wrapper .date-input {
  padding-right: 44px;
}

.date-input-wrapper .date-input::-webkit-calendar-picker-indicator {
  opacity: 0;
  position: absolute;
  right: var(--sp-3);
  width: 20px;
  height: 20px;
  cursor: pointer;
}

.date-input-wrapper .calendar-icon {
  position: absolute;
  right: var(--sp-3);
  top: 50%;
  transform: translateY(-50%);
  color: var(--text-tertiary);
  pointer-events: none;
}

.card-footer {
  display: flex;
  justify-content: flex-end;
  gap: var(--sp-3);
  padding: var(--sp-4) var(--sp-6);
  border-top: 1px solid var(--border);
}

.btn-cancel,
.btn-save {
  padding: var(--sp-2) var(--sp-5);
  border-radius: var(--radius-sm);
  font-size: var(--text-base);
  font-weight: 500;
  cursor: pointer;
  transition: all var(--dur-normal);
}

.btn-cancel {
  background: var(--bg-hover);
  border: 1px solid var(--border);
  color: var(--text-tertiary);
}

.btn-cancel:hover {
  background: var(--bg-card);
  color: var(--text-primary);
}

.btn-save {
  background: var(--accent);
  border: none;
  color: var(--text-primary);
}

.btn-save:hover:not(:disabled) {
  transform: translateY(-2px);
  background: var(--accent-hover);
  box-shadow: var(--shadow-md);
}

.btn-save:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* 日期选择器深色主题 */
input[type="date"] {
  color-scheme: dark;
}

/* 响应式 */
@media (max-width: 600px) {
  .top-header {
    padding: var(--sp-3) var(--sp-4);
  }
  
  .logo-text {
    font-size: var(--text-md);
  }
  
  .header-title {
    font-size: var(--text-md);
  }
  
  .settings-container {
    padding: var(--sp-5) var(--sp-4);
  }
  
  .card-body {
    padding: var(--sp-5);
  }
  
  .gender-options {
    flex-direction: column;
  }
}
</style>
