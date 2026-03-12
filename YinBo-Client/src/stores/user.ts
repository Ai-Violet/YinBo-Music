import { defineStore } from 'pinia'
import type { User, Playlist } from '../types'
import { removeToken, TOKEN_KEYS, getCurrentToken } from '../utils/request'
import { userApi } from '../api'

// 用户信息持久化key
const USER_INFO_KEY = 'user_info'
const ADMIN_INFO_KEY = 'admin_info'

interface UserState {
  // 用户端状态
  currentUser: User | null
  myPlaylists: Playlist[]
  favorites: number[]
  
  // 管理员端状态
  currentAdmin: User | null
  
  // 初始化状态
  initialized: boolean
}

export const useUserStore = defineStore('user', {
  state: (): UserState => ({
    currentUser: null,
    myPlaylists: [],
    favorites: [],
    currentAdmin: null,
    initialized: false
  }),

  actions: {
    // 初始化用户状态（从localStorage恢复）
    async initUserState() {
      if (this.initialized) return
      
      try {
        // 恢复用户信息（显式使用 user token，避免路由影响）
        const userToken = localStorage.getItem(TOKEN_KEYS.USER)
        if (userToken) {
          const cachedUserInfo = localStorage.getItem(USER_INFO_KEY)
          if (cachedUserInfo) {
            this.currentUser = JSON.parse(cachedUserInfo)
          }
          try {
            const res = await userApi.getUserInfo({ useAdminToken: false })
            if (res.data.code === 200) {
              this.currentUser = res.data.data
              localStorage.setItem(USER_INFO_KEY, JSON.stringify(res.data.data))
            }
          } catch {
            removeToken(false)
            this.currentUser = null
          }
        }
        
        // 恢复管理员信息（显式使用 admin token，与用户端互不干扰）
        const adminToken = localStorage.getItem(TOKEN_KEYS.ADMIN)
        if (adminToken) {
          const cachedAdminInfo = localStorage.getItem(ADMIN_INFO_KEY)
          if (cachedAdminInfo) {
            this.currentAdmin = JSON.parse(cachedAdminInfo)
          }
          try {
            const res = await userApi.getUserInfo({ useAdminToken: true })
            if (res.data.code === 200) {
              this.currentAdmin = res.data.data
              localStorage.setItem(ADMIN_INFO_KEY, JSON.stringify(res.data.data))
            }
          } catch {
            removeToken(true)
            this.currentAdmin = null
          }
        }
        
        this.initialized = true
      } catch (e) {
        console.error('Failed to init user state:', e)
        // 如果获取用户信息失败，可能是token过期，清除状态
        // 但不自动跳转，让路由守卫处理
      }
    },
    
    // 用户端操作
    setUser(user: User) {
      this.currentUser = user
      // 持久化用户信息
      localStorage.setItem(USER_INFO_KEY, JSON.stringify(user))
    },
    
    logout() {
      this.currentUser = null
      this.myPlaylists = []
      this.favorites = []
      removeToken(false) // 移除用户token
      localStorage.removeItem(USER_INFO_KEY) // 清除用户信息缓存
    },
    
    // 管理员端操作
    setAdmin(admin: User) {
      this.currentAdmin = admin
      localStorage.setItem(ADMIN_INFO_KEY, JSON.stringify(admin))
    },
    
    adminLogout() {
      this.currentAdmin = null
      removeToken(true) // 移除管理员token
      localStorage.removeItem(ADMIN_INFO_KEY)
    },
    
    // 清除所有状态
    clearAll() {
      this.currentUser = null
      this.currentAdmin = null
      this.myPlaylists = []
      this.favorites = []
      localStorage.removeItem(TOKEN_KEYS.USER)
      localStorage.removeItem(TOKEN_KEYS.ADMIN)
      localStorage.removeItem(USER_INFO_KEY)
      localStorage.removeItem(ADMIN_INFO_KEY)
    },
    
    setMyPlaylists(playlists: Playlist[]) {
      this.myPlaylists = playlists
    },
    
    addPlaylist(playlist: Playlist) {
      this.myPlaylists.push(playlist)
    },
    
    removePlaylist(id: number) {
      this.myPlaylists = this.myPlaylists.filter(p => p.id !== id)
    },
    
    addFavorite(trackId: number) {
      if (!this.favorites.includes(trackId)) {
        this.favorites.push(trackId)
      }
    },
    
    removeFavorite(trackId: number) {
      this.favorites = this.favorites.filter(id => id !== trackId)
    },
    
    // 检查是否已登录
    isLoggedIn() {
      return !!this.currentUser && !!localStorage.getItem(TOKEN_KEYS.USER)
    },
    
    isAdminLoggedIn() {
      return !!this.currentAdmin && !!localStorage.getItem(TOKEN_KEYS.ADMIN)
    }
  }
})
