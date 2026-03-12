import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import { TOKEN_KEYS } from '../utils/request'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'AdminLogin',
    component: () => import('../views/AdminLogin.vue')
  },
  {
    path: '/',
    component: () => import('../views/admin/AdminLayout.vue'),
    meta: { requiresAdmin: true },
    children: [
      { path: '', name: 'AdminDashboard', component: () => import('../views/admin/Dashboard.vue') },
      { path: 'users', name: 'AdminUsers', component: () => import('../views/admin/UserManagement.vue') },
      { path: 'tracks', name: 'AdminTracks', component: () => import('../views/admin/TrackManagement.vue') },
      { path: 'upload', name: 'AdminUpload', component: () => import('../views/admin/UploadMusic.vue') },
      { path: 'categories', name: 'AdminCategories', component: () => import('../views/admin/CategoryManagement.vue') },
      { path: 'singers', name: 'AdminSingers', component: () => import('../views/admin/SingerManagement.vue') },
      { path: 'comments', name: 'AdminComments', component: () => import('../views/admin/CommentManagement.vue') },
      { path: 'announcements', name: 'AdminAnnouncements', component: () => import('../views/admin/AnnouncementManagement.vue') }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to, from, next) => {
  const adminToken = localStorage.getItem(TOKEN_KEYS.ADMIN)
  if (to.meta.requiresAdmin && !adminToken) {
    next('/login')
    return
  }
  next()
})

export default router
