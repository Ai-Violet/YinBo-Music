<template>
  <div class="yb-login-page">
    <header class="yb-topbar">
      <router-link to="/" class="yb-back">返回首页</router-link>
      <div class="yb-brand-row">
        <svg class="yb-note-ico" viewBox="0 0 24 24" aria-hidden="true">
          <path fill="currentColor" d="M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z"/>
        </svg>
        <span class="yb-brand-name">音波</span>
        <span class="yb-brand-tag">听见好音乐</span>
      </div>
      <button type="button" class="yb-theme-toggle" @click="toggleTheme">
        {{ theme === 'dark' ? '浅色' : '深色' }}
      </button>
    </header>

    <div class="yb-frame entrance">
      <div class="yb-card">
        <div class="yb-slide" :class="{ 'yb-slide--left': mode === 'register' }">
          <div class="yb-slide-bg" aria-hidden="true">
            <svg class="yb-vinyl" viewBox="0 0 120 120">
              <circle cx="60" cy="60" r="54" fill="none" stroke="currentColor" stroke-width="2" opacity="0.15"/>
              <circle cx="60" cy="60" r="38" fill="none" stroke="currentColor" stroke-width="1.5" opacity="0.12"/>
              <circle cx="60" cy="60" r="8" fill="currentColor" opacity="0.2"/>
            </svg>
            <div class="yb-eq" aria-hidden="true">
              <span v-for="i in 5" :key="i" class="yb-eq-bar" :style="{ animationDelay: `${i * 0.08}s` }" />
            </div>
          </div>
          <div class="yb-slide-body">
            <Transition name="cta-fade" mode="out-in">
              <div v-if="mode === 'login'" key="a" class="yb-cta">
                <div class="yb-cta-music-ico" aria-hidden="true">
                  <svg viewBox="0 0 24 24" width="48" height="48"><path fill="currentColor" d="M12 14c1.66 0 3-1.34 3-3V5c0-1.66-1.34-3-3-3S9 3.34 9 5v6c0 1.66 1.34 3 3 3zm5.3-3c0 3-2.54 5.1-5.3 5.1S6.7 14 6.7 11H5c0 3.41 2.72 6.23 6 6.72V21h2v-3.28c3.28-.48 6-3.3 6-6.72h-1.7z"/></svg>
                </div>
                <h2 class="yb-cta-title">新用户？</h2>
                <p class="yb-cta-line">注册后可收藏歌单、同步播放记录。</p>
                <button type="button" class="yb-btn-outline" @click="setMode('register')">注册账号</button>
              </div>
              <div v-else key="b" class="yb-cta">
                <div class="yb-cta-music-ico" aria-hidden="true">
                  <svg viewBox="0 0 24 24" width="48" height="48"><path fill="currentColor" d="M12 3v9.28c-.47-.17-.97-.28-1.5-.28C8.01 12 6 14.01 6 16.5S8.01 21 10.5 21c2.49 0 4.5-2.01 4.5-4.5V6h4V3h-7z"/></svg>
                </div>
                <h2 class="yb-cta-title">已有账号？</h2>
                <p class="yb-cta-line">登录后继续听歌与管理资料。</p>
                <button type="button" class="yb-btn-outline" @click="setMode('login')">立即登录</button>
              </div>
            </Transition>
          </div>
        </div>

        <div class="yb-half yb-half--login" :class="{ 'is-off-mobile': mode !== 'login' }">
          <form class="yb-form" @submit.prevent="handleLogin">
            <h1 class="yb-h1">登录</h1>
            <div class="yb-wave-line" aria-hidden="true">
              <span v-for="n in 12" :key="n" class="yb-wave-dot" />
            </div>
            <div class="yb-avatar">
              <img :src="previewAvatar" alt="" class="yb-avatar-img" @error="onAvatarError" />
            </div>
            <label class="yb-field">
              <span class="yb-label">账号</span>
              <input
                v-model="loginForm.username"
                class="yb-in"
                type="text"
                placeholder="用户名或邮箱"
                required
                autocomplete="username"
                @input="onUsernameInput"
                @blur="onUsernameBlur"
              />
            </label>
            <label class="yb-field">
              <span class="yb-label">密码</span>
              <input
                v-model="loginForm.password"
                class="yb-in"
                type="password"
                placeholder="请输入密码"
                required
                autocomplete="current-password"
              />
            </label>
            <button type="submit" class="yb-btn-main" :disabled="loading">
              {{ loading ? '正在登录…' : '登录' }}
            </button>
          </form>
        </div>

        <div class="yb-half yb-half--register" :class="{ 'is-off-mobile': mode !== 'register' }">
          <form class="yb-form" @submit.prevent="handleRegister">
            <h1 class="yb-h1">注册</h1>
            <div class="yb-wave-line" aria-hidden="true">
              <span v-for="n in 12" :key="n" class="yb-wave-dot" />
            </div>
            <label class="yb-field"><span class="yb-label">用户名</span><input v-model="registerForm.username" class="yb-in" required minlength="3" autocomplete="username" /></label>
            <label class="yb-field"><span class="yb-label">邮箱</span><input v-model="registerForm.email" class="yb-in" type="email" required autocomplete="email" /></label>
            <div class="yb-inline yb-inline--code">
              <label class="yb-field yb-field--grow">
                <span class="yb-label">验证码</span>
                <input
                  ref="verifyCodeInput"
                  v-model="registerForm.verifyCode"
                  class="yb-in"
                  type="text"
                  maxlength="8"
                  placeholder="请输入邮箱中的验证码"
                  autocomplete="one-time-code"
                  enterkeyhint="done"
                />
              </label>
              <button type="button" class="yb-btn-code" :disabled="codeCooldown > 0 || sendingCode" @click="sendVerificationCode">{{ codeBtnLabel }}</button>
            </div>
            <label class="yb-field"><span class="yb-label">密码</span><input v-model="registerForm.password" class="yb-in" type="password" required minlength="6" autocomplete="new-password" /></label>
            <label class="yb-field"><span class="yb-label">确认密码</span><input v-model="registerForm.confirmPassword" class="yb-in" type="password" required autocomplete="new-password" /></label>
            <button type="submit" class="yb-btn-main" :disabled="loading">{{ loading ? '正在注册…' : '注册' }}</button>
          </form>
        </div>
      </div>
    </div>

    <p v-if="errorMsg" class="yb-toast yb-toast--err">{{ errorMsg }}</p>
    <p v-if="successMsg" class="yb-toast yb-toast--ok">{{ successMsg }}</p>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onUnmounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { userApi } from '../api'
import { useUserStore } from '../stores/user'
import { useTheme } from '../composables/useTheme'
import { DEFAULT_AVATAR_COVER } from '../constants'

const router = useRouter()
const userStore = useUserStore()
const { theme, toggle: toggleTheme } = useTheme()

const mode = ref<'login' | 'register'>('login')

const loading = ref(false)
const errorMsg = ref('')
const successMsg = ref('')
const previewAvatarUrl = ref<string | null>(null)
const verifyCodeInput = ref<HTMLInputElement | null>(null)

const loginForm = ref({ username: '', password: '' })
const registerForm = ref({
  username: '',
  email: '',
  verifyCode: '',
  password: '',
  confirmPassword: ''
})

const sendingCode = ref(false)
const codeCooldown = ref(0)
let cooldownTimer: ReturnType<typeof setInterval> | null = null

const codeBtnLabel = computed(() =>
  codeCooldown.value > 0 ? `${codeCooldown.value} 秒后重试` : '获取验证码'
)

const previewAvatar = computed(() => previewAvatarUrl.value || DEFAULT_AVATAR_COVER)

let checkTimer: ReturnType<typeof setTimeout> | null = null

function clearCooldownTimer() {
  if (cooldownTimer) {
    clearInterval(cooldownTimer)
    cooldownTimer = null
  }
}

function startCooldown(sec: number) {
  clearCooldownTimer()
  codeCooldown.value = sec
  cooldownTimer = setInterval(() => {
    codeCooldown.value--
    if (codeCooldown.value <= 0) clearCooldownTimer()
  }, 1000)
}

onUnmounted(() => {
  clearCooldownTimer()
  if (checkTimer) clearTimeout(checkTimer)
})

function setMode(m: 'login' | 'register') {
  mode.value = m
  errorMsg.value = ''
}

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

const fetchAvatarByUsername = async () => {
  const username = loginForm.value.username.trim()
  if (username.length < 2) {
    previewAvatarUrl.value = null
    return
  }
  try {
    const res = await userApi.checkUsername(username)
    const payload = res.data?.data ?? res.data
    const exists = (payload as { exists?: boolean })?.exists
    const avatar = (payload as { avatar?: string | null })?.avatar
    const ok = res.data?.code === 200 || (res.data?.code == null && payload != null)
    if (ok && exists) {
      previewAvatarUrl.value = (avatar && typeof avatar === 'string') ? avatar : DEFAULT_AVATAR_COVER
    } else {
      previewAvatarUrl.value = null
    }
  } catch {
    previewAvatarUrl.value = null
  }
}

const onUsernameInput = () => {
  previewAvatarUrl.value = null
  if (checkTimer) clearTimeout(checkTimer)
  if (loginForm.value.username.trim().length < 2) return
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
  const el = e.target as HTMLImageElement
  if (el?.src && !el.src.includes('默认头像封面')) {
    previewAvatarUrl.value = DEFAULT_AVATAR_COVER
  }
}

watch(() => loginForm.value.username, (val) => {
  if (!val?.trim()) previewAvatarUrl.value = null
})

const sendVerificationCode = async () => {
  errorMsg.value = ''
  successMsg.value = ''
  const email = registerForm.value.email.trim()
  if (!email) {
    errorMsg.value = '请填写邮箱'
    return
  }
  if (!EMAIL_RE.test(email)) {
    errorMsg.value = '邮箱格式不正确'
    return
  }
  sendingCode.value = true
  try {
    const res = await userApi.sendEmailCode(email)
    if (res.data.code === 200) {
      successMsg.value = '验证码已发送，请查收邮箱'
      startCooldown(60)
      await nextTick()
      verifyCodeInput.value?.focus()
      verifyCodeInput.value?.select()
    } else {
      errorMsg.value = res.data.message || '发送失败'
    }
  } catch (e: unknown) {
    const err = e as { response?: { data?: { message?: string } }; message?: string }
    errorMsg.value = err.response?.data?.message || err.message || '发送失败'
  } finally {
    sendingCode.value = false
  }
}

const handleLogin = async () => {
  if (!loginForm.value.username || !loginForm.value.password) {
    errorMsg.value = '请填写账号与密码'
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
      successMsg.value = '登录成功'
      setTimeout(() => router.push('/home'), 900)
    } else {
      errorMsg.value = res.data.message || '登录失败'
    }
  } catch (e: unknown) {
    const err = e as { response?: { data?: { message?: string } }; message?: string }
    errorMsg.value = err.response?.data?.message || err.message || '登录失败'
  } finally {
    loading.value = false
  }
}

const handleRegister = async () => {
  if (registerForm.value.username.length < 3) {
    errorMsg.value = '用户名至少 3 位'
    return
  }
  if (registerForm.value.password.length < 6) {
    errorMsg.value = '密码至少 6 位'
    return
  }
  if (registerForm.value.password !== registerForm.value.confirmPassword) {
    errorMsg.value = '两次密码不一致'
    return
  }

  if (!EMAIL_RE.test(registerForm.value.email.trim())) {
    errorMsg.value = '请填写有效邮箱'
    return
  }
  if (!registerForm.value.verifyCode.trim()) {
    errorMsg.value = '请填写邮箱验证码'
    return
  }

  loading.value = true
  errorMsg.value = ''
  successMsg.value = ''
  try {
    const payload: Parameters<typeof userApi.register>[0] = {
      username: registerForm.value.username.trim(),
      password: registerForm.value.password,
      email: registerForm.value.email.trim(),
      verifyCode: registerForm.value.verifyCode.trim()
    }
    const res = await userApi.register(payload)
    if (res.data.code === 200) {
      mode.value = 'login'
      loginForm.value.username = registerForm.value.username.trim()
      successMsg.value = '注册成功，请登录'
    } else {
      errorMsg.value = res.data.message || '注册失败'
    }
  } catch (e: unknown) {
    const err = e as { response?: { data?: { message?: string } }; message?: string }
    errorMsg.value = err.response?.data?.message || err.message || '注册失败'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
/* 随 html[data-theme] 继承的全局 token；局部新拟态变量在下方 unscoped 块中按主题定义 */
.yb-login-page {
  --yb-slide-inset: var(--auth-inset, inset 2px 2px 8px rgba(0, 0, 0, 0.25), inset -2px -2px 6px rgba(255, 255, 255, 0.06));
  --yb-raise: var(--auth-raise, var(--shadow-md));

  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 72px 16px 28px;
  background: var(--bg-primary);
  color: var(--text-primary);
  font-family: var(--font-sans);
  box-sizing: border-box;
}

.yb-topbar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 50;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--sp-4) var(--sp-5);
  background: color-mix(in srgb, var(--bg-secondary) 92%, transparent);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid var(--border);
}

.yb-back {
  font-size: var(--text-sm);
  color: var(--text-secondary);
  text-decoration: none;
  transition: color var(--dur-fast);
}

.yb-back:hover {
  color: var(--accent);
}

.yb-brand-row {
  display: flex;
  align-items: center;
  gap: var(--sp-2);
}

.yb-note-ico {
  width: 22px;
  height: 22px;
  color: var(--accent);
}

.yb-brand-name {
  font-weight: 700;
  font-size: var(--text-md);
  letter-spacing: 0.12em;
}

.yb-brand-tag {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  padding-left: var(--sp-2);
  border-left: 1px solid var(--border);
}

.yb-theme-toggle {
  padding: var(--sp-2) var(--sp-4);
  border-radius: var(--radius-full);
  font-size: var(--text-sm);
  color: var(--text-secondary);
  background: var(--bg-elevated);
  border: 1px solid var(--border);
  transition: all var(--dur-fast);
}

.yb-theme-toggle:hover {
  color: var(--text-primary);
  border-color: var(--accent);
}

/* 外框：宽︰高 = 16︰9 */
.yb-frame {
  width: min(96vw, 1080px);
  aspect-ratio: 16 / 9;
  max-height: min(calc(100vh - 100px), calc(min(96vw, 1080px) * 9 / 16));
  flex-shrink: 0;
}

.yb-card {
  position: relative;
  width: 100%;
  height: 100%;
  display: flex;
  border-radius: var(--radius-xl);
  background: var(--bg-card);
  border: 1px solid var(--border);
  box-shadow: var(--shadow-lg);
  overflow: hidden;
}

.entrance {
  animation: yb-in 0.65s var(--ease-out) both;
}

@keyframes yb-in {
  from {
    opacity: 0;
    transform: translateY(16px) scale(0.99);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.yb-half {
  position: relative;
  z-index: 1;
  flex: 1;
  min-width: 0;
  padding: clamp(12px, 2vh, 22px) clamp(18px, 2.5vw, 32px);
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  box-sizing: border-box;
}

@media (max-height: 620px) {
  .yb-half {
    overflow-y: auto;
    align-items: flex-start;
  }
}

.yb-slide {
  position: absolute;
  top: 0;
  left: 50%;
  width: 50%;
  height: 100%;
  z-index: 4;
  background: var(--bg-elevated);
  border-left: 1px solid var(--border);
  border-right: 1px solid var(--border);
  box-shadow: var(--yb-raise);
  transition: transform 0.62s var(--ease-out);
  transform: translateX(0);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: clamp(16px, 2vh, 28px);
  box-sizing: border-box;
}

.yb-slide--left {
  transform: translateX(-100%);
}

.yb-slide-bg {
  position: absolute;
  inset: 0;
  color: var(--accent);
  pointer-events: none;
  overflow: hidden;
}

.yb-vinyl {
  position: absolute;
  right: -20px;
  bottom: -20px;
  width: 140px;
  height: 140px;
  opacity: 0.35;
}

.yb-eq {
  position: absolute;
  left: 16px;
  bottom: 20px;
  display: flex;
  align-items: flex-end;
  gap: 4px;
  height: 28px;
}

.yb-eq-bar {
  width: 4px;
  height: 100%;
  border-radius: 2px;
  background: var(--accent);
  opacity: 0.45;
  animation: yb-eq 0.9s ease-in-out infinite alternate;
  transform-origin: bottom;
}

@keyframes yb-eq {
  from { transform: scaleY(0.35); }
  to { transform: scaleY(1); }
}

.yb-slide-body {
  position: relative;
  z-index: 1;
  text-align: center;
  max-width: 240px;
}

.yb-cta-music-ico {
  margin-bottom: var(--sp-3);
  color: var(--accent);
  opacity: 0.9;
}

.yb-cta-title {
  margin: 0 0 var(--sp-2);
  font-size: clamp(1.15rem, 2vw, 1.35rem);
  font-weight: 700;
  color: var(--text-primary);
}

.yb-cta-line {
  margin: 0 0 var(--sp-5);
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  line-height: 1.5;
}

.yb-btn-outline {
  padding: 10px 32px;
  border-radius: var(--radius-full);
  border: 2px solid var(--accent);
  background: transparent;
  color: var(--accent);
  font-size: var(--text-sm);
  font-weight: 600;
  box-shadow: var(--shadow-sm);
  transition: transform var(--dur-fast), background var(--dur-fast);
}

.yb-btn-outline:hover {
  transform: translateY(-2px);
  background: var(--accent-muted);
}

.cta-fade-enter-active,
.cta-fade-leave-active {
  transition: opacity 0.25s ease, transform 0.25s ease;
}

.cta-fade-enter-from {
  opacity: 0;
  transform: translateX(8px);
}

.cta-fade-leave-to {
  opacity: 0;
  transform: translateX(-8px);
}

.yb-form {
  width: 100%;
  max-width: 300px;
}

.yb-form-tight {
  display: flex;
  flex-direction: column;
  gap: 7px;
}

.yb-form-tight .yb-field {
  margin-bottom: 0;
}

.yb-half--register .yb-wave-line {
  margin-bottom: var(--sp-2);
}

.yb-h1 {
  margin: 0 0 var(--sp-2);
  font-size: clamp(1.2rem, 2.2vw, 1.45rem);
  font-weight: 700;
}

.yb-wave-line {
  display: flex;
  align-items: center;
  gap: 5px;
  margin-bottom: var(--sp-2);
  height: 6px;
}

.yb-wave-dot {
  flex: 1;
  height: 4px;
  border-radius: 2px;
  background: linear-gradient(90deg, transparent, var(--accent), transparent);
  opacity: 0.35;
  animation: yb-pulse 2s ease-in-out infinite;
}

.yb-wave-dot:nth-child(odd) {
  animation-delay: 0.15s;
}

@keyframes yb-pulse {
  0%,
  100% {
    opacity: 0.2;
    transform: scaleY(0.8);
  }
  50% {
    opacity: 0.55;
    transform: scaleY(1.2);
  }
}

.yb-avatar {
  width: 52px;
  height: 52px;
  margin: 0 auto var(--sp-3);
  border-radius: 50%;
  padding: 2px;
  background: var(--bg-secondary);
  box-shadow: var(--yb-slide-inset);
}

.yb-avatar-img {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  object-fit: cover;
  display: block;
}

.yb-field {
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin-bottom: 10px;
}

.yb-field--grow {
  flex: 1;
  min-width: 0;
  margin-bottom: 0;
}

.yb-label {
  font-size: var(--text-xs);
  font-weight: 600;
  color: var(--text-tertiary);
}

.yb-in {
  width: 100%;
  box-sizing: border-box;
  padding: 11px 14px;
  border-radius: var(--radius-md);
  font-size: var(--text-sm);
  color: var(--text-primary);
  background: var(--bg-elevated);
  border: 1px solid var(--border);
  box-shadow: var(--yb-slide-inset);
  transition: border-color var(--dur-fast), box-shadow var(--dur-fast);
}

.yb-in::placeholder {
  color: var(--text-tertiary);
}

.yb-in:focus {
  outline: none;
  border-color: var(--accent);
  box-shadow: 0 0 0 3px var(--accent-muted);
}

.yb-btn-main {
  width: 100%;
  margin-top: var(--sp-2);
  padding: 12px;
  border: none;
  border-radius: var(--radius-full);
  font-size: var(--text-sm);
  font-weight: 600;
  color: #fff;
  background: var(--accent);
  box-shadow: var(--shadow-glow);
  transition: transform var(--dur-fast), opacity var(--dur-fast), background var(--dur-fast);
}

.yb-btn-main:hover:not(:disabled) {
  transform: translateY(-2px);
  background: var(--accent-hover);
}

.yb-btn-main:disabled {
  opacity: 0.55;
  cursor: not-allowed;
  transform: none;
}

.yb-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-bottom: 6px;
}

.yb-chip {
  padding: 6px 12px;
  border-radius: var(--radius-full);
  font-size: var(--text-xs);
  font-weight: 600;
  color: var(--text-secondary);
  background: var(--bg-elevated);
  border: 1px solid var(--border);
  transition: all var(--dur-fast);
}

.yb-chip:hover {
  border-color: var(--border-hover);
}

.yb-chip.active {
  color: #fff;
  background: var(--accent);
  border-color: transparent;
}

.yb-reg-vp {
  overflow: hidden;
  border-radius: var(--radius-md);
}

.yb-reg-track {
  display: flex;
  width: 200%;
  transition: transform 0.42s var(--ease-out);
}

.yb-reg-pane {
  flex: 0 0 50%;
  width: 50%;
  padding-right: 6px;
  box-sizing: border-box;
}

.yb-inline {
  display: flex;
  align-items: flex-end;
  gap: 8px;
  margin-bottom: 0;
}

.yb-inline .yb-field--grow {
  margin-bottom: 0;
}

.yb-inline--code {
  flex-wrap: wrap;
  align-items: stretch;
}

.yb-inline--code .yb-field--grow {
  flex: 1 1 140px;
  min-width: 0;
}

.yb-btn-code {
  flex-shrink: 0;
  padding: 11px 12px;
  border-radius: var(--radius-md);
  font-size: var(--text-xs);
  font-weight: 600;
  color: var(--accent);
  background: var(--bg-elevated);
  border: 1px solid var(--border);
  white-space: nowrap;
  transition: background var(--dur-fast);
}

.yb-btn-code:hover:not(:disabled) {
  background: var(--accent-muted);
}

.yb-btn-code:disabled {
  opacity: 0.45;
  cursor: not-allowed;
}

.yb-toast {
  margin-top: var(--sp-4);
  padding: 10px 18px;
  border-radius: var(--radius-md);
  font-size: var(--text-sm);
  text-align: center;
  max-width: min(400px, 90vw);
}

.yb-toast--err {
  background: color-mix(in srgb, var(--red) 14%, transparent);
  color: var(--red);
  border: 1px solid color-mix(in srgb, var(--red) 28%, transparent);
}

.yb-toast--ok {
  background: color-mix(in srgb, var(--green) 12%, transparent);
  color: var(--green);
  border: 1px solid color-mix(in srgb, var(--green) 28%, transparent);
}

@media (max-width: 820px) {
  .yb-frame {
    aspect-ratio: unset;
    width: 100%;
    max-height: none;
    flex: 1;
    min-height: 0;
  }

  .yb-card {
    flex-direction: column;
    min-height: 480px;
  }

  .yb-slide {
    position: relative;
    left: 0;
    width: 100%;
    height: auto;
    min-height: 180px;
    transform: none !important;
    border-radius: var(--radius-xl) var(--radius-xl) 0 0;
    order: -1;
    border-left: none;
    border-right: none;
    border-bottom: 1px solid var(--border);
  }

  .yb-slide--left {
    transform: none !important;
  }

  .yb-half.is-off-mobile {
    display: none !important;
  }

  .yb-inline--code {
    flex-direction: column;
    align-items: stretch;
    gap: 10px;
  }

  .yb-inline--code .yb-btn-code {
    width: 100%;
    padding: 12px;
  }
}

@media (min-width: 821px) and (max-width: 980px) {
  .yb-inline--code {
    flex-wrap: wrap;
  }

  .yb-inline--code .yb-btn-code {
    flex: 1 1 auto;
    min-width: 108px;
  }
}
</style>

<style>
/* 新拟态阴影随深浅色切换（html 由 useTheme 写入 data-theme） */
html[data-theme="light"] .yb-login-page {
  --auth-inset: inset 3px 3px 8px rgba(0, 0, 0, 0.07), inset -4px -4px 10px rgba(255, 255, 255, 0.95);
  --auth-raise: 10px 10px 24px rgba(0, 0, 0, 0.08), -8px -8px 20px rgba(255, 255, 255, 0.85);
}

html[data-theme="dark"] .yb-login-page {
  --auth-inset: inset 2px 2px 10px rgba(0, 0, 0, 0.5), inset -2px -2px 8px rgba(255, 255, 255, 0.04);
  --auth-raise: 16px 10px 32px rgba(0, 0, 0, 0.45), -4px -4px 16px rgba(255, 255, 255, 0.03);
}
</style>
