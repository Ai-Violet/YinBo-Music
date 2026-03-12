<template>
  <div class="login-page">
    <!-- Ambient background -->
    <div class="ambient"></div>

    <div class="login-card scale-in">
      <!-- Brand -->
      <div class="brand">
        <div class="brand-icon">
          <svg viewBox="0 0 24 24" width="32" height="32">
            <path fill="currentColor" d="M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z"/>
          </svg>
        </div>
        <h1 class="brand-name">音波</h1>
        <p class="brand-sub">YinBo Music</p>
      </div>

      <!-- Tabs -->
      <div class="tabs">
        <button :class="['tab', { active: mode === 'login' }]" @click="mode = 'login'">登录</button>
        <button :class="['tab', { active: mode === 'register' }]" @click="mode = 'register'">注册</button>
      </div>

      <!-- Login form -->
      <form v-if="mode === 'login'" @submit.prevent="handleLogin" class="form">
        <div class="avatar-preview-top">
          <img :src="previewAvatar" alt="" class="preview-img" @error="onAvatarError" />
        </div>
        <input v-model="loginForm.username" class="yb-input" type="text" placeholder="用户名" required @input="onUsernameInput" @blur="onUsernameBlur" />
        <input v-model="loginForm.password" class="yb-input" type="password" placeholder="密码" required />
        <button type="submit" class="yb-btn-primary submit" :disabled="loading">
          {{ loading ? '登录中...' : '登 录' }}
        </button>
      </form>

      <!-- Register form -->
      <form v-else @submit.prevent="handleRegister" class="form">
        <input v-model="registerForm.username" class="yb-input" type="text" placeholder="用户名（至少3位）" required />
        <input v-model="registerForm.email" class="yb-input" type="email" placeholder="邮箱" required />
        <input v-model="registerForm.password" class="yb-input" type="password" placeholder="密码（至少6位）" required />
        <input v-model="registerForm.confirmPassword" class="yb-input" type="password" placeholder="确认密码" required />
        <button type="submit" class="yb-btn-primary submit" :disabled="loading">
          {{ loading ? '注册中...' : '注 册' }}
        </button>
      </form>

      <!-- Error -->
      <div v-if="errorMsg" class="error">{{ errorMsg }}</div>
      <!-- Success -->
      <div v-if="successMsg" class="success-msg">{{ successMsg }}</div>

      <!-- Footer links -->
      <div class="footer-links">
        <router-link to="/" class="link">返回首页</router-link>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import { userApi } from '../api'
import { useUserStore } from '../stores/user'
import { DEFAULT_AVATAR_COVER } from '../constants'

const router = useRouter()
const userStore = useUserStore()

const mode = ref<'login' | 'register'>('login')
const loading = ref(false)
const errorMsg = ref('')
const successMsg = ref('')
const previewAvatarUrl = ref<string | null>(null)

const loginForm = ref({ username: '', password: '' })
const registerForm = ref({ username: '', email: '', password: '', confirmPassword: '' })

const previewAvatar = computed(() => previewAvatarUrl.value || DEFAULT_AVATAR_COVER)

let checkTimer: ReturnType<typeof setTimeout> | null = null

const fetchAvatarByUsername = async () => {
  const username = loginForm.value.username.trim()
  if (username.length < 2) {
    previewAvatarUrl.value = null
    return
  }
  try {
    const res = await userApi.checkUsername(username)
    if (import.meta.env.DEV) {
      console.log('[登录] check-username 响应:', { code: res.data?.code, payload: res.data?.data ?? res.data })
    }
    const payload = res.data?.data ?? res.data
    const exists = payload?.exists
    const avatar = payload?.avatar
    const ok = res.data?.code === 200 || (res.data?.code == null && payload != null)
    if (ok && exists) {
      previewAvatarUrl.value = (avatar && typeof avatar === 'string') ? avatar : DEFAULT_AVATAR_COVER
    } else {
      previewAvatarUrl.value = null
    }
  } catch (e) {
    if (import.meta.env.DEV) {
      console.warn('[登录] 获取头像失败:', e)
    }
    previewAvatarUrl.value = null
  }
}

const onUsernameInput = () => {
  previewAvatarUrl.value = null
  if (checkTimer) clearTimeout(checkTimer)
  const username = loginForm.value.username.trim()
  if (username.length < 2) return
  checkTimer = setTimeout(fetchAvatarByUsername, 200)
}

const onUsernameBlur = () => {
  if (checkTimer) {
    clearTimeout(checkTimer)
    checkTimer = null
  }
  fetchAvatarByUsername()
}

const onAvatarError = (e: Event) => {
  // 用户头像 URL 加载失败时回退到默认图（避免重复触发）
  const el = e.target as HTMLImageElement
  if (el?.src && !el.src.includes('默认头像封面')) {
    previewAvatarUrl.value = DEFAULT_AVATAR_COVER
  }
}

watch(() => loginForm.value.username, (val) => {
  if (!val?.trim()) previewAvatarUrl.value = null
})

const handleLogin = async () => {
  if (!loginForm.value.username || !loginForm.value.password) {
    errorMsg.value = '请填写用户名和密码'
    return
  }
  loading.value = true
  errorMsg.value = ''
  successMsg.value = ''
  try {
    const res = await userApi.login(loginForm.value)
    if (res.data.code === 200) {
      const { setToken } = await import('../utils/request')
      setToken(res.data.data.token, false)
      if (res.data.data.user) userStore.setUser(res.data.data.user)
      successMsg.value = '登录成功，正在跳转...'
      setTimeout(() => router.push('/home'), 1000)
    } else {
      errorMsg.value = res.data.message || '登录失败'
    }
  } catch (e: any) {
    errorMsg.value = e.response?.data?.message || e.message || '登录失败'
  } finally {
    loading.value = false
  }
}

const handleRegister = async () => {
  if (!registerForm.value.username || registerForm.value.username.length < 3) {
    errorMsg.value = '用户名至少3个字符'; return
  }
  if (!registerForm.value.email) { errorMsg.value = '请输入邮箱'; return }
  if (!registerForm.value.password || registerForm.value.password.length < 6) {
    errorMsg.value = '密码至少6个字符'; return
  }
  if (registerForm.value.password !== registerForm.value.confirmPassword) {
    errorMsg.value = '两次密码不一致'; return
  }
  loading.value = true
  errorMsg.value = ''
  try {
    const res = await userApi.register({
      username: registerForm.value.username,
      email: registerForm.value.email,
      password: registerForm.value.password
    })
    if (res.data.code === 200) {
      mode.value = 'login'
      loginForm.value.username = registerForm.value.username
      errorMsg.value = ''
      successMsg.value = '注册成功，请登录'
    } else {
      errorMsg.value = res.data.message || '注册失败'
    }
  } catch (e: any) {
    errorMsg.value = e.response?.data?.message || e.message || '注册失败'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg-primary);
  position: relative;
  overflow: hidden;
}

.ambient {
  position: absolute;
  width: 500px;
  height: 500px;
  border-radius: 50%;
  background: radial-gradient(circle, var(--accent-glow) 0%, transparent 70%);
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  pointer-events: none;
  opacity: 0.4;
  filter: blur(80px);
}

.login-card {
  position: relative;
  width: 100%;
  max-width: 380px;
  padding: var(--sp-10);
  background: var(--bg-card);
  border: 1px solid var(--border);
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-lg);
}

/* Brand */
.brand {
  text-align: center;
  margin-bottom: var(--sp-8);
}

.brand-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 56px;
  height: 56px;
  border-radius: var(--radius-lg);
  background: var(--accent-muted);
  color: var(--accent);
  margin-bottom: var(--sp-3);
}

.brand-name {
  font-size: var(--text-2xl);
  font-weight: 700;
  color: var(--text-primary);
  letter-spacing: 0.05em;
}

.brand-sub {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  letter-spacing: 0.15em;
  text-transform: uppercase;
  margin-top: var(--sp-1);
}

/* Tabs */
.tabs {
  display: flex;
  gap: var(--sp-1);
  background: var(--bg-elevated);
  border-radius: var(--radius-md);
  padding: 3px;
  margin-bottom: var(--sp-6);
}

.tab {
  flex: 1;
  padding: var(--sp-2) 0;
  border-radius: calc(var(--radius-md) - 2px);
  font-size: var(--text-sm);
  font-weight: 500;
  color: var(--text-secondary);
  transition: all var(--dur-fast);
}

.tab.active {
  background: var(--accent);
  color: #fff;
  box-shadow: 0 2px 8px var(--accent-glow);
}

/* Form */
.form {
  display: flex;
  flex-direction: column;
  gap: var(--sp-3);
}

.form .yb-input {
  padding: var(--sp-3) var(--sp-4);
}

.submit {
  width: 100%;
  padding: var(--sp-3) 0;
  margin-top: var(--sp-2);
  font-size: var(--text-md);
  letter-spacing: 0.1em;
}

/* Error / Success */
.error {
  margin-top: var(--sp-4);
  padding: var(--sp-3) var(--sp-4);
  border-radius: var(--radius-md);
  font-size: var(--text-sm);
  text-align: center;
  background: rgba(239, 68, 68, 0.12);
  color: var(--red);
  border: 1px solid rgba(239, 68, 68, 0.2);
}

.success-msg {
  margin-top: var(--sp-4);
  padding: var(--sp-3) var(--sp-4);
  border-radius: var(--radius-md);
  font-size: var(--text-sm);
  text-align: center;
  background: rgba(34, 197, 94, 0.12);
  color: var(--green);
  border: 1px solid rgba(34, 197, 94, 0.2);
}

.avatar-preview-top {
  width: 64px;
  height: 64px;
  margin: 0 auto var(--sp-4);
  border-radius: 50%;
  overflow: hidden;
  background: var(--bg-hover);
}

.avatar-preview-top .preview-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

/* Footer */
.footer-links {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--sp-3);
  margin-top: var(--sp-6);
  font-size: var(--text-sm);
}

.footer-links .link {
  color: var(--text-tertiary);
  transition: color var(--dur-fast);
}

.footer-links .link:hover {
  color: var(--accent);
}
</style>
