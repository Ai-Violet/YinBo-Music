import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import { TOKEN_KEYS } from '../utils/request'

const routes: RouteRecordRaw[] = [
  // 公开首页（未登录）
  {
    path: '/',
    name: 'SimpleHome',
    component: () => import('../views/SimpleHome.vue')
  },
  // 用户主页（需登录）
  {
    path: '/home',
    name: 'Home',
    component: () => import('../views/Home.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/search',
    name: 'Search',
    component: () => import('../views/Search.vue')
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue')
  },
  {
    path: '/profile',
    name: 'Profile',
    component: () => import('../views/Profile.vue')
  },
  {
    path: '/profile/:id',
    name: 'UserProfile',
    component: () => import('../views/Profile.vue')
  },
  {
    path: '/my-comments',
    redirect: '/profile?tab=comments'
  },
  {
    path: '/play-history',
    name: 'PlayHistory',
    component: () => import('../views/PlayHistory.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/settings',
    name: 'Settings',
    component: () => import('../views/Settings.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/playlist/:id',
    name: 'PlaylistDetail',
    component: () => import('../views/PlaylistDetail.vue')
  },
  {
    path: '/track/:id',
    name: 'TrackCommentView',
    component: () => import('../views/TrackCommentView.vue')
  },
  {
    path: '/singer/:id',
    name: 'SingerProfile',
    component: () => import('../views/SingerProfile.vue')
  },
  {
    path: '/artist',
    name: 'ArtistProfile',
    component: () => import('../views/SingerProfile.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Route guard
router.beforeEach(async (to, from, next) => {
  const userToken = localStorage.getItem(TOKEN_KEYS.USER)
  
  // 如果已登录用户访问根路径，重定向到用户主页
  if (to.path === '/' && userToken) {
    next('/home')
    return
  }
  
  // Pages requiring user login
  if (to.meta.requiresAuth && !userToken) {
    next('/login')
    return
  }
  
  next()
})

export default router