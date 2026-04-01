<template>
  <div class="yb-login-page yb-admin-auth">
    <header class="yb-topbar">
      <a :href="clientPublicUrl" class="yb-back" target="_blank" rel="noopener noreferrer">返回音乐站</a>
      <div class="yb-brand-row">
        <svg class="yb-note-ico" viewBox="0 0 24 24" aria-hidden="true">
          <path
            fill="currentColor"
            d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm-2 16l-4-4 1.41-1.41L10 14.17l6.59-6.59L18 9l-8 8z"
          />
        </svg>
        <span class="yb-brand-name">音波</span>
        <span class="yb-brand-tag">管理控制台</span>
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
                  <svg viewBox="0 0 24 24" width="48" height="48"><path fill="currentColor" d="M19 3H5a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2V5a2 2 0 00-2-2zm-8 12H9.5v-2h1.5v2zm0-4H9.5V9h1.5v2zm0-4H9.5V5h1.5v2zm3 8h-1.5v-2H14v2zm0-4h-1.5V9H14v2zm0-4h-1.5V5H14v2zm3 8h-1.5v-2h1.5v2zm0-4h-1.5V9h1.5v2zm0-4h-1.5V5h1.5v2z"/></svg>
                </div>
                <h2 class="yb-cta-title">需要后台账号？</h2>
                <p class="yb-cta-line">使用与用户端相同的邮箱验证注册；须填写部署方提供的管理员密钥以获得后台权限。</p>
                <button type="button" class="yb-btn-outline" @click="setMode('register')">注册管理员</button>
              </div>
              <div v-else key="b" class="yb-cta">
                <div class="yb-cta-music-ico" aria-hidden="true">
                  <svg viewBox="0 0 24 24" width="48" height="48"><path fill="currentColor" d="M10 17l-3.5-3.5 1.41-1.42L10 14.17l6.59-6.59L18 9m-8 8c-2.21 0-4-1.79-4-4 0-1.43.75-2.68 1.88-3.39l1.43 1.43A2.99 2.99 0 008 15c0 1.66 1.34 3 3 3s3-1.34 3-3c0-.94-.44-1.78-1.13-2.33l1.43-1.43A4.98 4.98 0 0118 11c0 2.76-2.24 5-5 5z"/></svg>
                </div>
                <h2 class="yb-cta-title">已有管理员账号？</h2>
                <p class="yb-cta-line">使用用户名或邮箱登录，无需额外密钥；系统将校验您的管理员角色。</p>
                <button type="button" class="yb-btn-outline" @click="setMode('login')">去登录</button>
              </div>
            </Transition>
          </div>
        </div>

        <div class="yb-half yb-half--login" :class="{ 'is-off-mobile': mode !== 'login' }">
          <form class="yb-form" @submit.prevent="handleLogin">
            <h1 class="yb-h1">控制台登录</h1>
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
              {{ loading ? '正在登录…' : '进入控制台' }}
            </button>
          </form>
        </div>

        <div class="yb-half yb-half--register" :class="{ 'is-off-mobile': mode !== 'register' }">
          <form class="yb-form yb-form-admin-reg" @submit.prevent="handleRegister">
            <h1 class="yb-h1">注册管理员</h1>
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
            <label class="yb-field">
              <span class="yb-label">管理员注册密钥</span>
              <input
                v-model="registerForm.adminKey"
                class="yb-in"
                type="password"
                autocomplete="off"
                placeholder="由服务端配置，与注册接口一致"
                required
              />
            </label>
            <p class="yb-hint">密钥用于创建 <strong>ADMIN</strong> 角色；与普通用户注册流程一致（邮箱验证码）。</p>
            <button type="submit" class="yb-btn-main" :disabled="loading">{{ loading ? '正在注册…' : '注册管理员账号' }}</button>
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
import { setToken } from '../utils/request'

const router = useRouter()
const userStore = useUserStore()
const { theme, toggle: toggleTheme } = useTheme()

const clientPublicUrl = import.meta.env.VITE_CLIENT_URL || 'http://localhost:5173'

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
  confirmPassword: '',
  adminKey: ''
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
  if (el?.src && !el.src.startsWith('data:image/svg+xml')) {
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
      const user = res.data.data.user
      if (!user || user.role !== 'ADMIN') {
        errorMsg.value = '该账号不是管理员，无法进入控制台'
        return
      }
      setToken(res.data.data.token, true)
      userStore.setAdmin(user)
      successMsg.value = '登录成功'
      setTimeout(() => router.push('/'), 900)
      return
    }
    errorMsg.value = res.data.message || '登录失败'
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
  if (!registerForm.value.adminKey.trim()) {
    errorMsg.value = '请填写管理员注册密钥'
    return
  }

  loading.value = true
  errorMsg.value = ''
  successMsg.value = ''
  try {
    const payload = {
      username: registerForm.value.username.trim(),
      password: registerForm.value.password,
      email: registerForm.value.email.trim(),
      verifyCode: registerForm.value.verifyCode.trim(),
      adminKey: registerForm.value.adminKey.trim()
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

.yb-admin-auth {
  background:
    radial-gradient(ellipse 100% 70% at 50% -15%, color-mix(in srgb, var(--accent) 14%, transparent), transparent 55%),
    var(--bg-primary);
}

.yb-admin-auth .yb-topbar {
  background: color-mix(in srgb, var(--bg-secondary) 88%, var(--accent));
  border-bottom: 1px solid color-mix(in srgb, var(--accent) 22%, var(--border));
}

.yb-admin-auth .yb-card {
  border-color: color-mix(in srgb, var(--accent) 20%, var(--border));
  box-shadow:
    var(--shadow-lg),
    0 0 40px color-mix(in srgb, var(--accent-glow) 35%, transparent);
}

.yb-admin-auth .yb-slide {
  background: linear-gradient(145deg, var(--bg-elevated) 0%, color-mix(in srgb, var(--bg-card) 85%, var(--accent)) 100%);
}

.yb-hint {
  margin: -2px 0 10px;
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  line-height: 1.5;
}

.yb-form-admin-reg .yb-field {
  margin-bottom: 8px;
}

.yb-form-admin-reg .yb-h1 {
  margin-bottom: var(--sp-1);
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
