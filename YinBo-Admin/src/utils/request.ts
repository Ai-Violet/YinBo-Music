import axios from 'axios'
import type { AxiosInstance, AxiosResponse } from 'axios'

// Token 存储键名（与 Client 共用，便于同源下共享登录状态）
export const TOKEN_KEYS = {
  USER: 'user_token',
  ADMIN: 'admin_token'
}

// 管理员端始终使用 admin token
export function getCurrentToken(): string | null {
  return getToken(true)
}

export function getToken(useAdmin: boolean): string | null {
  const key = useAdmin ? TOKEN_KEYS.ADMIN : TOKEN_KEYS.USER
  return localStorage.getItem(key)
}

export function setToken(token: string, isAdmin: boolean) {
  const key = isAdmin ? TOKEN_KEYS.ADMIN : TOKEN_KEYS.USER
  localStorage.setItem(key, token)
}

export function removeToken(isAdmin: boolean) {
  const key = isAdmin ? TOKEN_KEYS.ADMIN : TOKEN_KEYS.USER
  localStorage.removeItem(key)
}

const service: AxiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api',
  timeout: 15000,
  responseType: 'json',
  responseEncoding: 'utf8'
})

service.interceptors.request.use(
  (config: any) => {
    config.headers['Accept-Charset'] = 'utf-8'
    const token = getToken(true)
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

service.interceptors.response.use(
  (response: AxiosResponse) => response,
  (error) => {
    console.error('Response error:', error)
    const message = error.response?.data?.message || error.message || 'Request failed'
    if (error.response?.status === 401) {
      removeToken(true)
      if (!window.location.pathname.includes('/login')) {
        window.location.href = '/login'
      }
    }
    return Promise.reject(new Error(message))
  }
)

export default service
