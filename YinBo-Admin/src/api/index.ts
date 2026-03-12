import request from '../utils/request'
import type { Track, Comment } from '../types'

interface ApiResponse<T> {
  code: number
  message: string
  data: T
  timestamp: number
}

interface PageResponse<T> {
  records: T[]
  total: number
  size: number
  current: number
  pages: number
}

export const userApi = {
  login(data: { username: string; password: string }) {
    return request.post<ApiResponse<{ token: string; user: any }>>('/auth/login', data)
  },
  register(data: { username: string; email: string; password: string; adminKey?: string }) {
    return request.post<ApiResponse<any>>('/auth/register', data)
  },
  getUserInfo() {
    return request.get<ApiResponse<any>>('/users/me')
  },
  updateUserInfo(data: { nickname?: string; signature?: string; gender?: string; birthday?: string; region?: string }) {
    return request.put<ApiResponse<any>>('/users/me', data)
  },
  uploadAvatar(avatar: File) {
    const formData = new FormData()
    formData.append('avatar', avatar)
    return request.post<ApiResponse<string>>('/users/me/avatar', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  }
}

export const announcementApi = {
  getActive() {
    return request.get<ApiResponse<any[]>>('/announcements/active')
  },
  getAll(page?: number, size?: number) {
    return request.get<ApiResponse<PageResponse<any>>>('/announcements/all', { params: { page, size } })
  },
  create(data: { title: string; content: string }) {
    return request.post<ApiResponse<any>>('/announcements', data)
  },
  toggleStatus(id: number, status: number) {
    return request.put<ApiResponse<void>>(`/announcements/${id}/status`, null, { params: { status } })
  },
  delete(id: number) {
    return request.delete<ApiResponse<void>>(`/announcements/${id}`)
  }
}

export const adminApi = {
  getStats() {
    return request.get<ApiResponse<any>>('/admin/stats')
  },
  getUsers(page?: number, size?: number, keyword?: string) {
    return request.get<ApiResponse<PageResponse<any>>>('/admin/users', { params: { page, size, keyword } })
  },
  updateUserStatus(userId: number, status: number, adminKey?: string) {
    return request.put<ApiResponse<void>>(`/admin/users/${userId}/status`, null, { params: { status, adminKey } })
  },
  batchUpdateUserStatus(ids: number[], status: number) {
    return request.put<ApiResponse<void>>('/admin/users/batch-status', { ids, status })
  },
  deleteUser(userId: number, adminKey: string) {
    return request.delete<ApiResponse<void>>(`/admin/users/${userId}`, { params: { adminKey } })
  },
  getPendingTracks(page?: number, size?: number) {
    return request.get<ApiResponse<PageResponse<Track>>>('/admin/tracks/pending', { params: { page, size } })
  },
  getAllTracks(page?: number, size?: number, status?: number, keyword?: string, categoryId?: number) {
    return request.get<ApiResponse<PageResponse<Track>>>('/admin/tracks', { params: { page, size, status, keyword, categoryId } })
  },
  getTrackRanking(limit?: number) {
    return request.get<ApiResponse<PageResponse<Track>>>('/admin/tracks/ranking', { params: { limit } })
  },
  getCategories() {
    return request.get<ApiResponse<any[]>>('/admin/categories')
  },
  createCategory(data: { name: string; icon?: string; sort?: number }) {
    return request.post<ApiResponse<any>>('/admin/categories', data)
  },
  updateCategory(id: number, data: { name?: string; icon?: string; sort?: number }) {
    return request.put<ApiResponse<void>>(`/admin/categories/${id}`, data)
  },
  deleteCategory(id: number) {
    return request.delete<ApiResponse<void>>(`/admin/categories/${id}`)
  },
  listSingers(page?: number, size?: number, keyword?: string) {
    return request.get<ApiResponse<PageResponse<any>>>('/admin/singers', { params: { page, size, keyword } })
  },
  createSinger(formData: FormData) {
    return request.post<ApiResponse<any>>('/admin/singers', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  },
  updateSinger(id: number, formData: FormData) {
    return request.put<ApiResponse<any>>(`/admin/singers/${id}`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  },
  deleteSinger(id: number) {
    return request.delete<ApiResponse<void>>(`/admin/singers/${id}`)
  },
  getTrackForEdit(trackId: number) {
    return request.get<ApiResponse<any>>(`/admin/tracks/${trackId}`)
  },
  updateTrack(trackId: number, data: { title?: string; artist?: string; album?: string; categoryId?: number | null; lyrics?: string; artistId?: number | null }) {
    return request.put<ApiResponse<void>>(`/admin/tracks/${trackId}`, data)
  },
  updateTrackCover(trackId: number, coverFile: File) {
    const formData = new FormData()
    formData.append('cover', coverFile)
    return request.put<ApiResponse<void>>(`/admin/tracks/${trackId}/cover`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  },
  approveTrack(trackId: number) {
    return request.put<ApiResponse<void>>(`/admin/tracks/${trackId}/approve`)
  },
  rejectTrack(trackId: number) {
    return request.put<ApiResponse<void>>(`/admin/tracks/${trackId}/reject`)
  },
  deleteTrack(trackId: number) {
    return request.delete<ApiResponse<void>>(`/admin/tracks/${trackId}`)
  },
  getAllComments(page?: number, size?: number, trackId?: number) {
    return request.get<ApiResponse<PageResponse<Comment>>>('/admin/comments', { params: { page, size, trackId } })
  },
  auditComment(commentId: number, status: number) {
    return request.put<ApiResponse<void>>(`/admin/comments/${commentId}/audit`, null, { params: { status } })
  },
  deleteComment(commentId: number) {
    return request.delete<ApiResponse<void>>(`/admin/comments/${commentId}`)
  },
  uploadTrack(formData: FormData) {
    return request.post<ApiResponse<any>>('/admin/tracks/upload', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  }
}
