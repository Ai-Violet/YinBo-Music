<template>
  <div class="admin-login-page">
    <div class="login-container">
      <div class="logo-section">
        <div class="logo">
          <span class="logo-text">音波</span>
          <span class="logo-sub">管理员登录</span>
        </div>
      </div>

      <div class="auth-tabs">
        <button :class="['tab-btn', { active: mode === 'login' }]" @click="mode = 'login'">登录</button>
        <button :class="['tab-btn', { active: mode === 'register' }]" @click="mode = 'register'">注册</button>
      </div>

      <form v-if="mode === 'login'" @submit.prevent="handleLogin" class="auth-form">
        <div class="form-group">
          <input v-model="loginForm.username" type="text" placeholder="管理员账号" required />
        </div>
        <div class="form-group">
          <input v-model="loginForm.password" type="password" placeholder="密码" required />
        </div>
        <div class="form-group">
          <input v-model="loginForm.adminKey" type="password" placeholder="管理员密钥" required />
        </div>
        <button type="submit" class="submit-btn" :disabled="loading">
          {{ loading ? '登录中...' : '管理员登录' }}
        </button>
      </form>

      <form v-else @submit.prevent="handleRegister" class="auth-form">
        <div class="form-group">
          <input v-model="registerForm.username" type="text" placeholder="管理员账号" required />
        </div>
        <div class="form-group">
          <input v-model="registerForm.email" type="email" placeholder="邮箱" required />
        </div>
        <div class="form-group">
          <input v-model="registerForm.password" type="password" placeholder="密码" required />
        </div>
        <div class="form-group">
          <input v-model="registerForm.confirmPassword" type="password" placeholder="确认密码" required />
        </div>
        <div class="form-group">
          <input v-model="registerForm.adminKey" type="password" placeholder="管理员注册密钥" required />
        </div>
        <button type="submit" class="submit-btn" :disabled="loading">
          {{ loading ? '注册中...' : '注册管理员' }}
        </button>
      </form>

      <div v-if="errorMsg" class="error-msg">{{ errorMsg }}</div>
      <div v-if="successMsg" class="success-msg">{{ successMsg }}</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { userApi } from '../api'
import { useUserStore } from '../stores/user'
import { setToken } from '../utils/request'

const router = useRouter()
const userStore = useUserStore()

const mode = ref<'login' | 'register'>('login')
const loading = ref(false)
const errorMsg = ref('')
const successMsg = ref('')

const ADMIN_SECRET_KEY = 'yinbo'

const loginForm = ref({ username: '', password: '', adminKey: '' })
const registerForm = ref({ username: '', email: '', password: '', confirmPassword: '', adminKey: '' })

const handleLogin = async () => {
  if (!loginForm.value.username || !loginForm.value.password) {
    errorMsg.value = '请填写管理员账号和密码'
    return
  }
  if (!loginForm.value.adminKey) {
    errorMsg.value = '请输入管理员密钥'
    return
  }
  if (loginForm.value.adminKey !== ADMIN_SECRET_KEY) {
    errorMsg.value = '管理员密钥错误'
    return
  }

  loading.value = true
  errorMsg.value = ''
  successMsg.value = ''

  try {
    const res = await userApi.login({
      username: loginForm.value.username,
      password: loginForm.value.password
    })

    if (res.data.code === 200) {
      const user = res.data.data.user
      if (user.role !== 'ADMIN') {
        errorMsg.value = '该账户不是管理员账户'
        return
      }

      setToken(res.data.data.token, true)
      userStore.setAdmin(user)
      successMsg.value = '登录成功，正在跳转...'
      setTimeout(() => router.push('/'), 1000)
    } else {
      errorMsg.value = res.data.message || '登录失败'
    }
  } catch (e: any) {
    errorMsg.value = e.message || '登录失败，请稍后重试'
  } finally {
    loading.value = false
  }
}

const handleRegister = async () => {
  if (!registerForm.value.username) {
    errorMsg.value = '请输入管理员账号'
    return
  }
  if (registerForm.value.username.length < 3) {
    errorMsg.value = '账号至少需要3个字符'
    return
  }
  if (!registerForm.value.email) {
    errorMsg.value = '请输入邮箱'
    return
  }
  if (!registerForm.value.password) {
    errorMsg.value = '请输入密码'
    return
  }
  if (registerForm.value.password.length < 6) {
    errorMsg.value = '密码至少需要6个字符'
    return
  }
  if (registerForm.value.password !== registerForm.value.confirmPassword) {
    errorMsg.value = '两次密码不一致'
    return
  }
  if (!registerForm.value.adminKey) {
    errorMsg.value = '请输入管理员注册密钥'
    return
  }
  if (registerForm.value.adminKey !== ADMIN_SECRET_KEY) {
    errorMsg.value = '管理员注册密钥错误'
    return
  }

  loading.value = true
  errorMsg.value = ''
  successMsg.value = ''

  try {
    const res = await userApi.register({
      username: registerForm.value.username,
      email: registerForm.value.email,
      password: registerForm.value.password,
      adminKey: registerForm.value.adminKey
    })

    if (res.data.code === 200) {
      successMsg.value = '注册成功！请登录管理员账号'
      mode.value = 'login'
      loginForm.value.username = registerForm.value.username
    } else {
      errorMsg.value = res.data.message || '注册失败'
    }
  } catch (e: any) {
    errorMsg.value = e.message || '注册失败，请稍后重试'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.admin-login-page { min-height: 100vh; display: flex; align-items: center; justify-content: center; background: var(--bg-primary); }
.login-container { width: 100%; max-width: 400px; padding: var(--sp-10); background: var(--bg-card); border-radius: var(--radius-xl); backdrop-filter: blur(10px); border: 1px solid var(--border); }
.logo-section { text-align: center; margin-bottom: var(--sp-8); }
.logo { display: flex; flex-direction: column; align-items: center; gap: var(--sp-1); }
.logo-text { font-size: var(--text-2xl); font-weight: bold; background: linear-gradient(90deg, var(--accent) 0%, var(--accent-hover) 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; }
.logo-sub { font-size: var(--text-base); color: var(--text-secondary); letter-spacing: 2px; }
.auth-tabs { display: flex; gap: var(--sp-3); margin-bottom: var(--sp-8); }
.tab-btn { flex: 1; padding: var(--sp-3); border: none; background: transparent; color: var(--text-secondary); font-size: var(--text-md); cursor: pointer; border-bottom: 2px solid transparent; transition: all var(--dur-normal) var(--ease-out); }
.tab-btn.active { color: var(--accent); border-bottom-color: var(--accent); }
.auth-form { display: flex; flex-direction: column; gap: var(--sp-5); }
.form-group input { width: 100%; padding: var(--sp-4); border: 1px solid var(--border-hover); border-radius: var(--radius-md); background: var(--bg-hover); color: var(--text-primary); font-size: var(--text-md); transition: all var(--dur-normal) var(--ease-out); }
.form-group input:focus { outline: none; border-color: var(--accent); background: var(--bg-secondary); }
.form-group input::placeholder { color: var(--text-tertiary); }
.submit-btn { padding: var(--sp-4); border: none; border-radius: var(--radius-md); background: var(--accent); color: var(--text-primary); font-size: var(--text-md); font-weight: bold; cursor: pointer; transition: all var(--dur-normal) var(--ease-out); }
.submit-btn:hover:not(:disabled) { background: var(--accent-hover); transform: translateY(-2px); box-shadow: 0 10px 20px var(--accent-glow); }
.submit-btn:disabled { opacity: 0.6; cursor: not-allowed; }
.error-msg { margin-top: var(--sp-4); padding: var(--sp-3); background: rgba(239, 68, 68, 0.2); border-radius: var(--radius-sm); color: var(--red); text-align: center; font-size: var(--text-base); }
.success-msg { margin-top: var(--sp-4); padding: var(--sp-3); background: rgba(34, 197, 94, 0.2); border-radius: var(--radius-sm); color: var(--green); text-align: center; font-size: var(--text-base); }
</style>
