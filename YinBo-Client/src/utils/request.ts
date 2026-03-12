import axios from 'axios'
import type { AxiosInstance, AxiosResponse } from 'axios'

// Token 存储键名
export const TOKEN_KEYS = {
  USER: 'user_token',
  ADMIN: 'admin_token'
}

// 判断当前是否为管理员端
function isAdminRoute(): boolean {
  return window.location.pathname.startsWith('/admin')
}

// 获取当前应该使用的token
export function getCurrentToken(): string | null {
  const isAdmin = isAdminRoute()
  return getToken(isAdmin)
}

// 获取指定端的 token（用于 init 等需显式指定场景）
export function getToken(useAdmin: boolean): string | null {
  const key = useAdmin ? TOKEN_KEYS.ADMIN : TOKEN_KEYS.USER
  return localStorage.getItem(key)
}

// 设置token
export function setToken(token: string, isAdmin: boolean) {
  const key = isAdmin ? TOKEN_KEYS.ADMIN : TOKEN_KEYS.USER
  localStorage.setItem(key, token)
}

// 移除token
export function removeToken(isAdmin: boolean) {
  const key = isAdmin ? TOKEN_KEYS.ADMIN : TOKEN_KEYS.USER
  localStorage.removeItem(key)
}

// 获取所有token（用于调试）
export function getAllTokens() {
  return {
    userToken: localStorage.getItem(TOKEN_KEYS.USER),
    adminToken: localStorage.getItem(TOKEN_KEYS.ADMIN)
  }
}

// 创建 axios 实例
const service: AxiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api',
  timeout: 15000,
  responseType: 'json',
  responseEncoding: 'utf8'
})

// 请求拦截器（支持 config.useAdminToken 显式指定使用哪个 token）
service.interceptors.request.use(
  (config: any) => {
    config.headers['Accept-Charset'] = 'utf-8'
    const useAdmin = config.useAdminToken === true ? true : config.useAdminToken === false ? false : isAdminRoute()
    const token = getToken(useAdmin)
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    console.error('请求错误:', error)
    return Promise.reject(error)
  }
)

// 响应拦截器
service.interceptors.response.use(
  (response: AxiosResponse) => {
    return response
  },
  (error) => {
    console.error('Response error:', error)

    // If 401 unauthorized，根据实际使用的 token 移除（支持显式指定 useAdminToken 的请求）
    if (error.response?.status === 401) {
      const config = error.config
      const usedAdmin = config?.useAdminToken === true ? true : config?.useAdminToken === false ? false : isAdminRoute()
      removeToken(usedAdmin)
      if (usedAdmin && !window.location.pathname.includes('/admin-login')) {
        window.location.href = '/admin-login'
      } else if (!usedAdmin && !window.location.pathname.includes('/login')) {
        window.location.href = '/login'
      }
    }

    // 保留原始 error，以便 catch 中能访问 error.response?.data?.message 显示后端返回的具体错误
    return Promise.reject(error)
  }
)

export default service
