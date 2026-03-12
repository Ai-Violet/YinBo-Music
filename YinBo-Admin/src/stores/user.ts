import { defineStore } from 'pinia'
import type { User } from '../types'
import { removeToken, TOKEN_KEYS } from '../utils/request'
import { userApi } from '../api'

const ADMIN_INFO_KEY = 'admin_info'

interface UserState {
  currentAdmin: User | null
  initialized: boolean
}

export const useUserStore = defineStore('user', {
  state: (): UserState => ({
    currentAdmin: null,
    initialized: false
  }),
  actions: {
    async initAdminState() {
      if (this.initialized) return
      try {
        const adminToken = localStorage.getItem(TOKEN_KEYS.ADMIN)
        if (adminToken) {
          const cachedAdminInfo = localStorage.getItem(ADMIN_INFO_KEY)
          if (cachedAdminInfo) {
            this.currentAdmin = JSON.parse(cachedAdminInfo)
          }
          try {
            const res = await userApi.getUserInfo()
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
        console.error('Failed to init admin state:', e)
      }
    },
    setAdmin(admin: User) {
      this.currentAdmin = admin
      localStorage.setItem(ADMIN_INFO_KEY, JSON.stringify(admin))
    },
    adminLogout() {
      this.currentAdmin = null
      removeToken(true)
      localStorage.removeItem(ADMIN_INFO_KEY)
    },
    isAdminLoggedIn() {
      return !!this.currentAdmin && !!localStorage.getItem(TOKEN_KEYS.ADMIN)
    }
  }
})
