<template>
  <div class="admin-layout" :class="{ 'admin-layout--collapsed': sidebarCollapsed }">
    <!-- 侧边栏 -->
    <aside class="sidebar">
      <div class="logo">
        <span class="logo-text">音波</span>
        <span class="logo-sub">管理后台</span>
      </div>
      
      <nav id="admin-sidebar-nav" class="nav-menu">
        <router-link to="/" class="nav-item" exact-active-class="active">
          <svg viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M3 13h8V3H3v10zm0 8h8v-6H3v6zm10 0h8V11h-8v10zm0-18v6h8V3h-8z"/>
          </svg>
          <span>数据概览</span>
        </router-link>
        <router-link to="/users" class="nav-item" active-class="active">
          <svg viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/>
          </svg>
          <span>用户管理</span>
        </router-link>
        <router-link to="/tracks" class="nav-item" active-class="active">
          <svg viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z"/>
          </svg>
          <span>音乐管理</span>
        </router-link>
        <router-link to="/upload" class="nav-item" active-class="active">
          <svg viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M9 16h6v-6h4l-7-7-7 7h4zm-4 2h14v2H5z"/>
          </svg>
          <span>上传音乐</span>
        </router-link>
        <router-link to="/categories" class="nav-item" active-class="active">
          <svg viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M4 6H2v14c0 1.1.9 2 2 2h14v-2H4V6zm16-4H8c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-1 9H9V9h10v2zm-4 4H9v-2h6v2zm4-8H9V5h10v2z"/>
          </svg>
          <span>分类管理</span>
        </router-link>
        <router-link to="/singers" class="nav-item" active-class="active">
          <svg viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
          </svg>
          <span>歌手管理</span>
        </router-link>
        <router-link to="/comments" class="nav-item" active-class="active">
          <svg viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M21 6h-2v9H6v2c0 .55.45 1 1 1h11l4 4V7c0-.55-.45-1-1-1zM17 3v9c0 .55-.45 1-1 1H6l-4 4V3c0-.55.45-1 1-1h13c.55 0 1 .45 1 1z"/>
          </svg>
          <span>评论管理</span>
        </router-link>
        <router-link to="/announcements" class="nav-item" active-class="active">
          <svg viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M18 11v2h4v-2h-4zm-2 6.61c.96.71 2.21 1.65 3.2 2.39.4-.53.8-1.07 1.2-1.6-.99-.74-2.24-1.68-3.2-2.4-.4.54-.8 1.08-1.2 1.61zM20.4 5.6c-.4-.53-.8-1.07-1.2-1.6-.99.74-2.24 1.68-3.2 2.4.4.53.8 1.07 1.2 1.6.96-.72 2.21-1.65 3.2-2.4zM4 9c-1.1 0-2 .9-2 2v2c0 1.1.9 2 2 2h1l5 3V6L5 9H4zm11.5 3c0-1.33-.58-2.53-1.5-3.35v6.69c.92-.81 1.5-2.01 1.5-3.34z"/>
          </svg>
          <span>公告管理</span>
        </router-link>
      </nav>
      
      <div class="bottom-section">
        <a :href="clientUrl" class="back-link">
          <svg viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"/>
          </svg>
          <span>返回前台</span>
        </a>
      </div>
    </aside>

    <!-- 主内容区 -->
    <main class="main-content">
      <header class="top-bar">
        <div class="top-bar-left">
          <button
            type="button"
            class="sidebar-toggle"
            :title="sidebarCollapsed ? '展开侧边栏' : '收起侧边栏'"
            :aria-expanded="!sidebarCollapsed"
            aria-controls="admin-sidebar-nav"
            @click="toggleSidebar"
          >
            <svg viewBox="0 0 24 24" width="22" height="22" aria-hidden="true">
              <path fill="currentColor" d="M3 18h12v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z" />
            </svg>
          </button>
          <h1>{{ pageTitle }}</h1>
        </div>
        <div class="user-section">
          <!-- 头像 -->
          <div class="avatar-wrapper" @click="triggerAvatarUpload">
            <img :src="userAvatar" alt="头像" class="user-avatar" />
            <div class="avatar-overlay">
              <svg viewBox="0 0 24 24" width="16" height="16">
                <path fill="currentColor" d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
              </svg>
            </div>
            <input 
              ref="avatarInput" 
              type="file" 
              accept="image/*" 
              hidden 
              @change="handleAvatarSelect"
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
                <div class="dropdown-item" @click.stop="openNicknameModal">
                  <svg viewBox="0 0 24 24" width="16" height="16">
                    <path fill="currentColor" d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/>
                  </svg>
                  修改昵称
                </div>
                <div class="dropdown-item" @click.stop="triggerAvatarUpload">
                  <svg viewBox="0 0 24 24" width="16" height="16">
                    <path fill="currentColor" d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
                  </svg>
                  更换头像
                </div>
                <div class="dropdown-item" @click.stop="handleThemeToggle">
                  <svg viewBox="0 0 24 24" width="16" height="16">
                    <path fill="currentColor" d="M12 3c-4.97 0-9 4.03-9 9s4.03 9 9 9 9-4.03 9-9c0-.46-.04-.92-.1-1.36-.98 1.37-2.58 2.26-4.4 2.26-2.98 0-5.4-2.42-5.4-5.4 0-1.81.89-3.42 2.26-4.4-.44-.06-.9-.1-1.36-.1z"/>
                  </svg>
                  {{ themeLabel }}
                </div>
                <div class="dropdown-divider"></div>
                <div class="dropdown-item logout-item" @click.stop="logout">
                  <svg viewBox="0 0 24 24" width="16" height="16">
                    <path fill="currentColor" d="M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5z"/>
                  </svg>
                  退出登录
                </div>
              </div>
            </transition>
          </div>
          
          <span class="role-badge">管理员</span>
        </div>
      </header>
      
      <div class="content">
        <div class="router-view-host">
          <router-view />
        </div>
      </div>
    </main>
    
    <!-- 昵称修改弹窗 -->
    <div v-if="showNicknameModal" class="modal-overlay" @click.self="closeNicknameModal">
      <div class="modal-content">
        <h3>修改昵称</h3>
        <input 
          v-model="newNickname" 
          type="text" 
          placeholder="请输入新昵称"
          maxlength="20"
        />
        <div class="modal-actions">
          <button class="cancel-btn" @click="closeNicknameModal">取消</button>
          <button class="confirm-btn" @click="saveNickname" :disabled="!newNickname.trim()">保存</button>
        </div>
      </div>
    </div>
    
    <!-- 头像裁剪组件 -->
    <AvatarCropper
      v-model="showCropper"
      :image-url="cropperImageUrl"
      @confirm="handleCropConfirm"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '../../stores/user'
import { useTheme } from '../../composables/useTheme'
import { userApi } from '../../api'
import AvatarCropper from '../../components/AvatarCropper.vue'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const { toggle: toggleTheme, isDark } = useTheme()
const themeLabel = computed(() => isDark() ? '浅色模式' : '深色模式')
const handleThemeToggle = () => {
  toggleTheme()
  showDropdown.value = false
}

const clientUrl = import.meta.env.VITE_CLIENT_URL || 'http://localhost:8081'
const defaultAvatar = 'https://via.placeholder.com/80?text=Admin'

const SIDEBAR_LS = 'yinbo-admin-sidebar-collapsed'
const sidebarCollapsed = ref(
  typeof localStorage !== 'undefined' && localStorage.getItem(SIDEBAR_LS) === '1'
)
const toggleSidebar = () => {
  sidebarCollapsed.value = !sidebarCollapsed.value
  try {
    localStorage.setItem(SIDEBAR_LS, sidebarCollapsed.value ? '1' : '0')
  } catch {
    /* ignore */
  }
}

// 状态
const showDropdown = ref(false)
const showNicknameModal = ref(false)
const newNickname = ref('')
const avatarInput = ref<HTMLInputElement | null>(null)
const showCropper = ref(false)
const cropperImageUrl = ref('')

// 计算属性
const userAvatar = computed(() => {
  const admin = userStore.currentAdmin as any
  return admin?.avatar || defaultAvatar
})

const displayName = computed(() => {
  const admin = userStore.currentAdmin as any
  return admin?.nickname || admin?.username || '管理员'
})

const pageTitle = computed(() => {
  const path = route.path
  if (path === '/') return '数据概览'
  if (path.includes('/users')) return '用户管理'
  if (path.includes('/tracks')) return '音乐管理'
  if (path.includes('/upload')) return '上传音乐'
  if (path.includes('/categories')) return '分类管理'
  if (path.includes('/singers')) return '歌手管理'
  if (path.includes('/comments')) return '评论管理'
  if (path.includes('/announcements')) return '公告管理'
  return '管理后台'
})

// 下拉菜单
const toggleDropdown = () => {
  showDropdown.value = !showDropdown.value
}

const closeDropdown = () => {
  showDropdown.value = false
}

// 昵称修改
const openNicknameModal = () => {
  newNickname.value = displayName.value
  showNicknameModal.value = true
  showDropdown.value = false
}

const closeNicknameModal = () => {
  showNicknameModal.value = false
  newNickname.value = ''
}

const saveNickname = async () => {
  if (!newNickname.value.trim()) return
  
  try {
    const res = await userApi.updateUserInfo({ nickname: newNickname.value.trim() })
    if (res.data.code === 200) {
      // 更新本地管理员信息
      const admin = { ...userStore.currentAdmin } as any
      admin.nickname = newNickname.value.trim()
      userStore.setAdmin(admin)
      closeNicknameModal()
    }
  } catch (e) {
    console.error('Failed to update nickname:', e)
    alert('修改昵称失败')
  }
}

// 头像上传
const triggerAvatarUpload = () => {
  showDropdown.value = false
  avatarInput.value?.click()
}

const handleAvatarSelect = (e: Event) => {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (file) {
    // 读取图片并显示裁剪器
    const reader = new FileReader()
    reader.onload = (e) => {
      cropperImageUrl.value = e.target?.result as string
      showCropper.value = true
    }
    reader.readAsDataURL(file)
  }
  // 重置input
  ;(e.target as HTMLInputElement).value = ''
}

const handleCropConfirm = async (blob: Blob) => {
  try {
    const file = new File([blob], 'avatar.jpg', { type: 'image/jpeg' })
    const res = await userApi.uploadAvatar(file)
    if (res.data.code === 200) {
      const avatarUrl = res.data.data
      // 更新本地管理员信息
      const admin = { ...userStore.currentAdmin } as any
      admin.avatar = avatarUrl
      userStore.setAdmin(admin)
    }
  } catch (e) {
    console.error('Failed to upload avatar:', e)
    alert('上传头像失败')
  }
}

// 退出登录
const logout = () => {
  userStore.adminLogout()
  router.push('/login')
}

// 点击外部关闭下拉菜单
const handleClickOutside = (e: MouseEvent) => {
  const target = e.target as HTMLElement
  if (!target.closest('.nickname-section')) {
    showDropdown.value = false
  }
}

// 从后端获取最新管理员信息
const fetchAdminInfo = async () => {
  try {
    const res = await userApi.getUserInfo()
    if (res.data.code === 200) {
      userStore.setAdmin(res.data.data)
    }
  } catch (e) {
    console.error('Failed to fetch admin info:', e)
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
  // 页面加载时获取最新管理员信息
  fetchAdminInfo()
})

onBeforeUnmount(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style>
@import './admin-common.css';
</style>
<style scoped>
.admin-layout {
  display: flex;
  min-height: 100vh;
  background: var(--bg-primary);
  color: var(--text-primary);
}

.sidebar {
  width: 240px;
  flex-shrink: 0;
  background: color-mix(in srgb, var(--bg-secondary) 94%, #e8f5ef 6%);
  border-right: 1px solid rgba(91, 154, 136, 0.1);
  display: flex;
  flex-direction: column;
  padding: var(--sp-5) 0;
  transition: width 0.22s ease, padding 0.22s ease;
}

.admin-layout--collapsed .sidebar {
  width: 76px;
}

.admin-layout--collapsed .logo {
  padding-left: var(--sp-3);
  padding-right: var(--sp-3);
}

.admin-layout--collapsed .logo-sub {
  display: none;
}

.admin-layout--collapsed .nav-item {
  justify-content: center;
  padding-left: var(--sp-3);
  padding-right: var(--sp-3);
  gap: 0;
}

.admin-layout--collapsed .nav-item span {
  display: none;
}

.admin-layout--collapsed .nav-item.active {
  border-left-width: 0;
  border-radius: var(--radius-md);
}

.admin-layout--collapsed .bottom-section {
  padding: var(--sp-3);
}

.admin-layout--collapsed .back-link {
  justify-content: center;
}

.admin-layout--collapsed .back-link span {
  display: none;
}

.logo {
  padding: 0 var(--sp-5) var(--sp-8);
  text-align: center;
  border-bottom: 1px solid var(--border);
}

.logo-text {
  font-size: var(--text-xl);
  font-weight: bold;
  background: linear-gradient(90deg, var(--accent) 0%, var(--accent-hover) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.logo-sub {
  display: block;
  font-size: var(--text-xs);
  color: var(--text-secondary);
  margin-top: var(--sp-1);
}

.nav-menu {
  flex: 1;
  padding: var(--sp-5) 0;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
  padding: var(--sp-3) var(--sp-5);
  color: var(--text-secondary);
  text-decoration: none;
  transition: all var(--dur-normal) var(--ease-out);
}

.nav-item:hover {
  background: var(--bg-hover);
  color: var(--text-primary);
}

.nav-item.active {
  background: var(--accent-muted);
  color: var(--accent);
  border-left: 3px solid var(--accent);
}

.bottom-section {
  padding: var(--sp-5);
  border-top: 1px solid var(--border);
}

.back-link {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
  color: var(--text-secondary);
  text-decoration: none;
  font-size: var(--text-base);
}

.back-link:hover {
  color: var(--text-primary);
}

.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  height: 100vh;
  overflow: hidden;
}

.top-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--sp-4) var(--sp-8);
  background: color-mix(in srgb, var(--bg-secondary) 92%, #f0faf6 8%);
  border-bottom: 1px solid rgba(91, 154, 136, 0.1);
  flex-shrink: 0;
}

.top-bar-left {
  display: flex;
  align-items: center;
  gap: var(--sp-4);
  min-width: 0;
}

.sidebar-toggle {
  flex-shrink: 0;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid rgba(91, 154, 136, 0.2);
  border-radius: var(--radius-md);
  background: rgba(255, 255, 255, 0.04);
  color: var(--text-secondary);
  cursor: pointer;
  transition: background var(--dur-fast), color var(--dur-fast), border-color var(--dur-fast);
}

.sidebar-toggle:hover {
  color: var(--accent);
  border-color: color-mix(in srgb, var(--accent) 35%, transparent);
  background: var(--bg-hover);
}

.top-bar h1 {
  margin: 0;
  font-size: var(--text-lg);
  font-weight: 600;
  letter-spacing: -0.02em;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.user-section {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
}

.avatar-wrapper {
  position: relative;
  width: 40px;
  height: 40px;
  border-radius: var(--radius-full);
  overflow: hidden;
  cursor: pointer;
  border: 2px solid var(--border-hover);
  transition: all var(--dur-normal) var(--ease-out);
}

.avatar-wrapper:hover {
  border-color: var(--accent);
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
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity var(--dur-normal) var(--ease-out);
}

.nickname-section {
  position: relative;
  display: flex;
  align-items: center;
  gap: var(--sp-1);
  padding: var(--sp-2) var(--sp-3);
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: background var(--dur-normal) var(--ease-out);
}

.nickname-section:hover {
  background: var(--bg-hover);
}

.nickname-text {
  font-size: var(--text-base);
  max-width: 100px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.dropdown-arrow {
  transition: transform var(--dur-normal) var(--ease-out);
}

.dropdown-arrow.rotated {
  transform: rotate(180deg);
}

.dropdown-menu {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: var(--sp-2);
  min-width: 160px;
  background: var(--bg-elevated);
  border-radius: var(--radius-md);
  padding: var(--sp-2) 0;
  box-shadow: var(--shadow-lg);
  z-index: 100;
}

.dropdown-item {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
  padding: var(--sp-3) var(--sp-4);
  font-size: var(--text-base);
  cursor: pointer;
  transition: background var(--dur-fast) var(--ease-out);
}

.dropdown-item:hover {
  background: var(--bg-hover);
}

.dropdown-divider {
  height: 1px;
  background: var(--border-hover);
  margin: var(--sp-1) 0;
}

.logout-item {
  color: var(--red);
}

.dropdown-enter-active,
.dropdown-leave-active {
  transition: all var(--dur-fast) var(--ease-out);
}

.dropdown-enter-from,
.dropdown-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

.role-badge {
  padding: var(--sp-1) var(--sp-3);
  background: var(--accent-muted);
  color: var(--accent);
  border-radius: var(--radius-md);
  font-size: var(--text-xs);
}

.content {
  flex: 1;
  min-height: 0;
  padding: var(--sp-5) var(--sp-8) var(--sp-8);
  overflow: hidden;
  display: flex;
  flex-direction: column;
  background: linear-gradient(
    180deg,
    color-mix(in srgb, var(--bg-primary) 92%, #ecf8f3 8%) 0%,
    var(--bg-primary) 48%
  );
}

.router-view-host {
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.router-view-host > * {
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: var(--bg-card);
  padding: var(--sp-8);
  border-radius: var(--radius-lg);
  width: 400px;
  max-width: 90%;
}

.modal-content h3 {
  margin: 0 0 var(--sp-5);
  font-size: var(--text-md);
}

.modal-content input {
  width: 100%;
  padding: var(--sp-3);
  border: 1px solid var(--border-hover);
  border-radius: var(--radius-sm);
  background: var(--bg-hover);
  color: var(--text-primary);
  font-size: var(--text-base);
  margin-bottom: var(--sp-5);
}

.modal-content input:focus {
  outline: none;
  border-color: var(--accent);
}

.modal-actions {
  display: flex;
  gap: var(--sp-3);
  justify-content: flex-end;
}

.cancel-btn {
  padding: var(--sp-3) var(--sp-5);
  border: 1px solid var(--border-hover);
  border-radius: var(--radius-sm);
  background: transparent;
  color: var(--text-primary);
  cursor: pointer;
  transition: all var(--dur-normal) var(--ease-out);
}

.confirm-btn {
  padding: var(--sp-3) var(--sp-5);
  border: none;
  border-radius: var(--radius-sm);
  background: var(--accent);
  color: var(--text-primary);
  cursor: pointer;
  transition: all var(--dur-normal) var(--ease-out);
}

.confirm-btn:hover:not(:disabled) {
  background: var(--accent-hover);
}

.confirm-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
