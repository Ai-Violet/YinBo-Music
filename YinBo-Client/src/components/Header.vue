<template>
  <div class="header-container">
    
    
    <!-- 返回按钮 -->
    <div class="nav-buttons">
      <el-button circle @click="goBack">
        <el-icon><ArrowLeft /></el-icon>
      </el-button>
    </div>

    <!-- 搜索框 -->
    <div class="search-box">
      <el-input
        v-model="searchQuery"
        placeholder="搜索歌曲、歌手、专辑"
        :prefix-icon="Search"
        clearable
        @keyup.enter="handleSearch"
      />
    </div>

    <!-- 用户操作区域 -->
    <div class="user-area">
      <!-- 未登录状态 -->
      <div v-if="!isLoggedIn" class="login-btn" @click="router.push('/login')">
        登录
      </div>
      
      <!-- 已登录状态 -->
      <div v-else class="user-section">
        <!-- 消息通知铃铛（头像左侧） -->
        <div class="notification-bell-wrap" ref="notificationRef">
          <button class="notification-bell" @click="toggleNotificationPanel" title="消息通知">
            <svg viewBox="0 0 24 24" width="22" height="22">
              <path fill="currentColor" d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.89 2 2 2zm6-6v-5c0-3.07-1.64-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.63 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2zm-2 1H8v-6c0-2.48 1.51-4.5 4-4.5s4 2.02 4 4.5v6z"/>
            </svg>
            <span v-if="notificationUnreadCount > 0" class="notification-dot">{{ notificationUnreadCount > 99 ? '99+' : notificationUnreadCount }}</span>
          </button>
          <div v-show="showNotificationPanel" class="notification-panel" @click.stop>
            <div class="notification-panel-header">
              <span>消息通知</span>
              <button v-if="notifications.length > 0 && notificationUnreadCount > 0" class="mark-read-btn" @click="markNotificationsRead">全部已读</button>
            </div>
            <div class="notification-list">
              <template v-if="notifications.length > 0">
                <div
                  v-for="n in notifications"
                  :key="n.id"
                  class="notification-item"
                  :class="{ unread: n.read === 0 }"
                  @click="handleNotificationClick(n)"
                >
                  <img :src="n.fromUserAvatar || defaultAvatar" class="n-avatar" alt="" />
                  <div class="n-content">
                    <p class="n-text">{{ formatNotificationText(n) }}</p>
                    <span class="n-time">{{ formatNotificationTime(n.createdAt) }}</span>
                  </div>
                </div>
              </template>
              <div v-else class="notification-empty">暂无消息</div>
            </div>
          </div>
        </div>
        <!-- 头像（可点击上传） -->
        <div class="avatar-wrapper" @click="triggerAvatarUpload">
          <img :src="userAvatar" alt="头像" class="user-avatar" />
          <div class="avatar-overlay">
            <svg viewBox="0 0 24 24" width="16" height="16">
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
        
        <!-- 昵称和下拉 -->
        <div class="nickname-section" @click="toggleDropdown">
          <span class="nickname-text">{{ displayName }}</span>
          <svg 
            class="dropdown-arrow" 
            :class="{ 'rotated': showDropdown }"
            viewBox="0 0 24 24" 
            width="16" 
            height="16"
          >
            <path fill="currentColor" d="M7 10l5 5 5-5z"/>
          </svg>
          
          <!-- 下拉菜单 -->
          <transition name="dropdown">
            <div v-if="showDropdown" class="dropdown-menu">
              <div class="dropdown-item" @click.stop="handleMenuClick('profile')">
                <svg viewBox="0 0 24 24" width="16" height="16">
                  <path fill="currentColor" d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
                </svg>
                我的主页
              </div>
              <div class="dropdown-item" @click.stop="handleMenuClick('nickname')">
                <svg viewBox="0 0 24 24" width="16" height="16">
                  <path fill="currentColor" d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/>
                </svg>
                修改昵称
              </div>
              <div class="dropdown-item" @click.stop="handleMenuClick('avatar')">
                <svg viewBox="0 0 24 24" width="16" height="16">
                  <path fill="currentColor" d="M21 19V5c0-1.1-.9-2-2-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2zM8.5 13.5l2.5 3.01L14.5 12l4.5 6H5l3.5-4.5z"/>
                </svg>
                更换头像
              </div>
              <div class="dropdown-item" @click.stop="handleMenuClick('history')">
                <svg viewBox="0 0 24 24" width="16" height="16">
                  <path fill="currentColor" d="M13 3c-4.97 0-9 4.03-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42C8.27 19.99 10.51 21 13 21c4.97 0 9-4.03 9-9s-4.03-9-9-9zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z"/>
                </svg>
                播放历史
              </div>
              <div class="dropdown-item" @click.stop="handleMenuClick('comments')">
                <svg viewBox="0 0 24 24" width="16" height="16">
                  <path fill="currentColor" d="M21 6h-2v9H6v2c0 .55.45 1 1 1h11l4 4V7c0-.55-.45-1-1-1zm-4 6V3c0-.55-.45-1-1-1H3c-.55 0-1 .45-1 1v14l4-4h10c.55 0 1-.45 1-1z"/>
                </svg>
                我的评论
              </div>
              <div class="dropdown-item" @click.stop="handleMenuClick('signature')">
                <svg viewBox="0 0 24 24" width="16" height="16">
                  <path fill="currentColor" d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/>
                </svg>
                个性签名更新
              </div>
              <div class="dropdown-divider"></div>
              <div class="dropdown-item" @click.stop="handleMenuClick('switch')">
                <svg viewBox="0 0 24 24" width="16" height="16">
                  <path fill="currentColor" d="M12 5V1L7 6l5 5V7c3.31 0 6 2.69 6 6s-2.69 6-6 6-6-2.69-6-6H4c0 4.42 3.58 8 8 8s8-3.58 8-8-3.58-8-8-8z"/>
                </svg>
                切换账号
              </div>
            </div>
          </transition>
        </div>
      </div>

      <!-- 操作按钮 -->
      <div class="action-buttons">
        <el-button circle size="small" @click="handleMinimize">
          <el-icon><Minus /></el-icon>
        </el-button>
        <el-button circle size="small" @click="handleClose">
          <el-icon><Close /></el-icon>
        </el-button>
      </div>
    </div>

    <!-- 头像裁剪对话框 -->
    <AvatarCropper
      v-model="showAvatarCropper"
      :image-url="cropperImageUrl"
      @confirm="handleAvatarConfirm"
    />

    <!-- 修改昵称对话框 -->
    <el-dialog
      v-model="showNicknameDialog"
      title="修改昵称"
      width="400px"
      :close-on-click-modal="false"
    >
      <el-input
        v-model="newNickname"
        placeholder="请输入新昵称"
        maxlength="20"
        show-word-limit
      />
      <template #footer>
        <el-button @click="showNicknameDialog = false">取消</el-button>
        <el-button type="primary" @click="handleUpdateNickname" :loading="updateLoading">确定</el-button>
      </template>
    </el-dialog>

    <!-- 个性签名对话框 -->
    <el-dialog
      v-model="showSignatureDialog"
      title="个性签名更新"
      width="400px"
      :close-on-click-modal="false"
    >
      <el-input
        v-model="newSignature"
        type="textarea"
        :rows="3"
        placeholder="请输入个性签名"
        maxlength="100"
        show-word-limit
      />
      <template #footer>
        <el-button @click="showSignatureDialog = false">取消</el-button>
        <el-button type="primary" @click="handleUpdateSignature" :loading="updateLoading">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onBeforeUnmount, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  Search,
  ArrowLeft,
  Close,
  Minus
} from '@element-plus/icons-vue'
import { userApi, notificationApi, type NotificationItem } from '../api'
import { useUserStore } from '../stores/user'
// @ts-ignore
import AvatarCropper from './AvatarCropper.vue'

const router = useRouter()
const userStore = useUserStore()
const searchQuery = ref('')

// 默认头像URL
import { DEFAULT_AVATAR_COVER } from '../constants'
const defaultAvatar = DEFAULT_AVATAR_COVER

// 下拉菜单状态
const showDropdown = ref(false)

// 头像上传相关
const avatarInputRef = ref<HTMLInputElement>()
const showAvatarCropper = ref(false)
const cropperImageUrl = ref('')

// 修改昵称相关
const showNicknameDialog = ref(false)
const newNickname = ref('')

// 个性签名相关
const showSignatureDialog = ref(false)
const newSignature = ref('')

// 更新加载状态
const updateLoading = ref(false)

// 消息通知
const notificationRef = ref<HTMLElement>()
const showNotificationPanel = ref(false)
const notifications = ref<NotificationItem[]>([])
const notificationUnreadCount = ref(0)

const fetchNotifications = async () => {
  try {
    const res = await notificationApi.getList(1, 20)
    if (res.data?.code === 200 && res.data?.data) {
      const d = res.data.data as any
      notifications.value = d.records || []
      notificationUnreadCount.value = d.unreadCount ?? 0
    }
  } catch (e) {
    console.error('Fetch notifications error:', e)
  }
}

const fetchUnreadCount = async () => {
  try {
    const res = await notificationApi.getUnreadCount()
    if (res.data?.code === 200) notificationUnreadCount.value = res.data.data ?? 0
  } catch (_) {}
}

const toggleNotificationPanel = () => {
  showNotificationPanel.value = !showNotificationPanel.value
  if (showNotificationPanel.value) {
    fetchNotifications()
  }
}

const markNotificationsRead = async () => {
  try {
    await notificationApi.markAllRead()
    notificationUnreadCount.value = 0
    fetchNotifications()
  } catch (e) {
    console.error('Mark read error:', e)
  }
}

const handleNotificationClick = (n: NotificationItem) => {
  showNotificationPanel.value = false
  if (n.read === 0) {
    markNotificationsRead()
  }
  if (n.type === 'FOLLOW' && n.fromUserId) {
    router.push(`/profile/${n.fromUserId}`)
  } else if (n.extra) {
    router.push(`/track/${n.extra}`)
  }
}

const formatNotificationText = (n: NotificationItem) => {
  const name = n.fromUserNickname || '某人'
  if (n.type === 'FOLLOW') return `${name} 关注了你`
  if (n.type === 'COMMENT_REPLY') return `${name} 回复了你的评论`
  if (n.type === 'LIKE') return `${name} 赞了你的评论`
  return ''
}

const formatNotificationTime = (t: string) => {
  if (!t) return ''
  const d = new Date(t)
  const now = new Date()
  const diff = now.getTime() - d.getTime()
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
  if (diff < 604800000) return `${Math.floor(diff / 86400000)}天前`
  return d.toLocaleDateString('zh-CN')
}

// 登录状态
const isLoggedIn = computed(() => !!userStore.currentUser)

// 用户头像
const userAvatar = computed(() => {
  const user = userStore.currentUser as any
  return user?.avatar || defaultAvatar
})

// 显示名称
const displayName = computed(() => {
  const user = userStore.currentUser as any
  return user?.nickname || user?.username || '用户'
})

const goBack = () => {
  router.back()
}

const handleSearch = () => {
  if (searchQuery.value.trim()) {
    router.push(`/search?q=${encodeURIComponent(searchQuery.value.trim())}`)
  }
}

// 下拉菜单切换
const toggleDropdown = () => {
  showDropdown.value = !showDropdown.value
}

// 点击外部关闭下拉菜单和通知面板
const handleClickOutside = (e: MouseEvent) => {
  const target = e.target as HTMLElement
  if (!target.closest('.nickname-section') && !target.closest('.avatar-wrapper')) {
    showDropdown.value = false
  }
  if (!target.closest('.notification-bell-wrap')) {
    showNotificationPanel.value = false
  }
}

// 触发头像上传
const triggerAvatarUpload = () => {
  avatarInputRef.value?.click()
}

// 处理头像文件选择
const handleAvatarChange = (e: Event) => {
  const input = e.target as HTMLInputElement
  const file = input.files?.[0]
  if (file) {
    // 验证文件类型
    if (!file.type.startsWith('image/')) {
      ElMessage.error('请选择图片文件')
      return
    }
    // 验证文件大小（最大5MB）
    if (file.size > 5 * 1024 * 1024) {
      ElMessage.error('图片大小不能超过5MB')
      return
    }
    // 读取图片并显示裁剪器
    const reader = new FileReader()
    reader.onload = (e) => {
      cropperImageUrl.value = e.target?.result as string
      showAvatarCropper.value = true
    }
    reader.readAsDataURL(file)
  }
  // 清空input，允许重复选择同一文件
  input.value = ''
}

// 处理头像裁剪确认
const handleAvatarConfirm = async (blob: Blob) => {
  try {
    updateLoading.value = true
    const file = new File([blob], 'avatar.jpg', { type: 'image/jpeg' })
    
    const res = await userApi.uploadAvatar(file)
    if (res.data.code === 200) {
      // 更新用户信息
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
  } finally {
    updateLoading.value = false
  }
}

// 处理菜单点击
const handleMenuClick = (action: string) => {
  showDropdown.value = false
  
  switch (action) {
    case 'profile':
      router.push('/profile')
      break
    case 'nickname':
      newNickname.value = displayName.value
      showNicknameDialog.value = true
      break
    case 'avatar':
      triggerAvatarUpload()
      break
    case 'history':
      router.push({ path: '/profile', query: { tab: 'history' } })
      break
    case 'comments':
      router.push('/profile?tab=comments')
      break
    case 'signature':
      const user = userStore.currentUser as any
      newSignature.value = user?.signature || ''
      showSignatureDialog.value = true
      break
    case 'switch':
      userStore.logout()
      router.push('/login')
      break
  }
}

// 更新昵称
const handleUpdateNickname = async () => {
  if (!newNickname.value.trim()) {
    ElMessage.warning('请输入昵称')
    return
  }
  
  try {
    updateLoading.value = true
    const res = await userApi.updateUserInfo({ nickname: newNickname.value.trim() })
    if (res.data.code === 200) {
      // 更新本地用户信息
      const userRes = await userApi.getUserInfo()
      if (userRes.data.code === 200) {
        userStore.setUser(userRes.data.data)
      }
      showNicknameDialog.value = false
      ElMessage.success('昵称更新成功')
    } else {
      ElMessage.error(res.data.message || '昵称更新失败')
    }
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '昵称更新失败')
  } finally {
    updateLoading.value = false
  }
}

// 更新个性签名
const handleUpdateSignature = async () => {
  try {
    updateLoading.value = true
    const res = await userApi.updateUserInfo({ signature: newSignature.value.trim() })
    if (res.data.code === 200) {
      // 更新本地用户信息
      const userRes = await userApi.getUserInfo()
      if (userRes.data.code === 200) {
        userStore.setUser(userRes.data.data)
      }
      showSignatureDialog.value = false
      ElMessage.success('个性签名更新成功')
    } else {
      ElMessage.error(res.data.message || '个性签名更新失败')
    }
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '个性签名更新失败')
  } finally {
    updateLoading.value = false
  }
}

// 缩小按钮
const handleMinimize = () => {
  console.log('缩小窗口')
}

// 关闭按钮
const handleClose = () => {
  console.log('关闭窗口')
}

// 获取用户信息
const fetchUserInfo = async () => {
  if (!userStore.currentUser) return
  try {
    const res = await userApi.getUserInfo()
    if (res.data.code === 200) {
      userStore.setUser(res.data.data)
    }
  } catch (e) {
    console.error('Failed to fetch user info:', e)
  }
}

watch(isLoggedIn, (v) => {
  if (v) fetchUnreadCount()
})

onMounted(() => {
  fetchUserInfo()
  if (isLoggedIn.value) fetchUnreadCount()
  document.addEventListener('click', handleClickOutside)
})

onBeforeUnmount(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped lang="scss">
.header-container {
  display: flex;
  align-items: center;
  gap: 20px;
  height: 60px;
  padding: 0 20px;
  border-bottom: 1px solid #e0e0e0;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.nav-buttons {
  flex-shrink: 0;

  :deep(.el-button) {
    border: none;
    background: #f5f5f5;
    color: #666;
    transition: all 0.2s;

    &:hover {
      background: #e0e0e0;
      color: #333;
    }
  }
}

.search-box {
  flex: 1;
  max-width: 400px;

  :deep(.el-input__wrapper) {
    border-radius: 20px;
    background: #f5f5f5;
    border: none;
    box-shadow: none;
    padding: 8px 15px;
    border: 1px solid #d0d0d0;
    border-radius: 20px;

    &:hover {
      background: #f0f0f0;
    }

    &.is-focus {
      background: #fff;
      box-shadow: 0 0 0 1px #C20C0C;
    }
  }

  :deep(.el-input__inner) {
    color: #333;
    &::placeholder {
      color: #999;
    }
  }
}

.user-area {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-left: auto;
  flex-shrink: 0;
}

.login-btn {
  padding: 8px 20px;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 20px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s;
  
  &:hover {
    transform: scale(1.05);
    box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
  }
}

// 用户区域样式（模仿管理端深色主题）
.user-section {
  display: flex;
  align-items: center;
  gap: 12px;
}

.notification-bell-wrap {
  position: relative;
}

.notification-bell {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  background: transparent;
  color: #666;
  cursor: pointer;
  border-radius: 50%;
  transition: all 0.2s;
  &:hover {
    color: #333;
    background: rgba(0, 0, 0, 0.05);
  }
}

.notification-dot {
  position: absolute;
  top: 2px;
  right: 2px;
  min-width: 16px;
  height: 16px;
  padding: 0 4px;
  font-size: 10px;
  line-height: 16px;
  text-align: center;
  background: #ef4444;
  color: #fff;
  border-radius: 8px;
}

.notification-panel {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: 8px;
  width: 360px;
  max-height: 400px;
  background: #fff;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
  border: 1px solid #e5e7eb;
  z-index: 1000;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.notification-panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  border-bottom: 1px solid #e5e7eb;
  font-weight: 600;
  font-size: 14px;
}

.mark-read-btn {
  font-size: 12px;
  color: #667eea;
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px 8px;
  &:hover {
    text-decoration: underline;
  }
}

.notification-list {
  flex: 1;
  overflow-y: auto;
  max-height: 320px;
}

.notification-item {
  display: flex;
  gap: 12px;
  padding: 12px 16px;
  cursor: pointer;
  transition: background 0.2s;
  border-bottom: 1px solid #f3f4f6;
  &.unread {
    background: #f8fafc;
  }
  &:hover {
    background: #f1f5f9;
  }
}

.n-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;
}

.n-content {
  flex: 1;
  min-width: 0;
}

.n-text {
  margin: 0 0 4px;
  font-size: 14px;
  color: #333;
  line-height: 1.4;
}

.n-time {
  font-size: 12px;
  color: #9ca3af;
}

.notification-empty {
  padding: 32px 16px;
  text-align: center;
  color: #9ca3af;
  font-size: 14px;
}

.avatar-wrapper {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  overflow: hidden;
  flex-shrink: 0;
  position: relative;
  cursor: pointer;
  border: 2px solid rgba(255, 255, 255, 0.2);
  transition: all 0.3s;
  
  &:hover {
    border-color: #667eea;
    transform: scale(1.05);
    
    .avatar-overlay {
      opacity: 1;
    }
  }
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
  transition: opacity 0.3s;
}

.nickname-section {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 6px 10px;
  border-radius: 8px;
  cursor: pointer;
  position: relative;
  transition: background 0.3s;
  
  &:hover {
    background: rgba(255, 255, 255, 0.05);
  }
}

.nickname-text {
  font-size: 14px;
  color: #333;
  font-weight: 500;
  max-width: 100px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.dropdown-arrow {
  color: #666;
  transition: transform 0.3s;
  
  &.rotated {
    transform: rotate(180deg);
  }
}

// 下拉菜单样式（深色主题）
.dropdown-menu {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: 8px;
  background: #2a2a4e;
  border-radius: 12px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
  min-width: 160px;
  padding: 8px 0;
  overflow: hidden;
  z-index: 1000;
}

.dropdown-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 16px;
  color: rgba(255, 255, 255, 0.8);
  font-size: 14px;
  cursor: pointer;
  transition: background 0.2s;
  
  &:hover {
    background: rgba(255, 255, 255, 0.05);
  }
  
  svg {
    flex-shrink: 0;
    opacity: 0.7;
  }
}

.dropdown-divider {
  height: 1px;
  background: rgba(255, 255, 255, 0.1);
  margin: 4px 0;
}

// 下拉动画
.dropdown-enter-active,
.dropdown-leave-active {
  transition: all 0.2s ease;
}

.dropdown-enter-from,
.dropdown-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

.action-buttons {
  display: flex;
  gap: 4px;

  :deep(.el-button) {
    width: 32px;
    height: 32px;
    border: none;
    background: transparent;
    color: #666;
    transition: all 0.2s;

    &:hover {
      background: #f5f5f5;
      color: #C20C0C;
    }
  }
}
</style>