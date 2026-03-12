import request from '../utils/request'
import type { Track, Playlist, Comment } from '../types'

// 统一响应类型
interface ApiResponse<T> {
  code: number
  message: string
  data: T
  timestamp: number
}

// 分页响应类型
interface PageResponse<T> {
  records: T[]
  total: number
  size: number
  current: number
  pages: number
}

// 歌手 API
export interface SingerDetail {
  id: number
  name: string
  avatarUrl?: string
  description?: string
}

export const singerApi = {
  getDetail(id: number) {
    return request.get<ApiResponse<SingerDetail>>(`/singers/public/${id}`)
  }
}

// 音频 API
export const trackApi = {
  // 获取音频列表
  getList(params?: { page?: number; size?: number; keyword?: string; categoryId?: number; singerId?: number; artist?: string }) {
    return request.get<ApiResponse<PageResponse<Track>>>('/tracks/public/list', { params })
  },

  // 获取音频详情
  getDetail(id: number) {
    return request.get<ApiResponse<Track>>(`/tracks/public/${id}`)
  },

  // 搜索音频（按歌名/歌手/专辑）
  search(keyword: string, page?: number, size?: number) {
    return request.get<ApiResponse<PageResponse<Track>>>('/tracks/public/search', { 
      params: { keyword: keyword || '', page, size } 
    })
  },

  // 获取热门搜索关键词（分类+热门艺术家）
  getSearchHotKeywords() {
    return request.get<ApiResponse<string[]>>('/tracks/public/search/hot-keywords')
  },

  // 获取热门音频（random=true 时返回随机 8 首）
  getHot(page?: number, size?: number, random?: boolean) {
    return request.get<ApiResponse<PageResponse<Track>>>('/tracks/public/hot', { 
      params: { page, size, random } 
    })
  },

  // 获取最新音频
  getNew(page?: number, size?: number) {
    return request.get<ApiResponse<PageResponse<Track>>>('/tracks/public/new', { 
      params: { page, size } 
    })
  },

  // 获取最多收藏音频
  getMostLiked(page?: number, size?: number) {
    return request.get<ApiResponse<PageResponse<Track>>>('/tracks/public/most-liked', { 
      params: { page, size } 
    })
  },

  // 获取最多评论音频
  getMostCommented(page?: number, size?: number) {
    return request.get<ApiResponse<PageResponse<Track>>>('/tracks/public/most-commented', { 
      params: { page, size } 
    })
  },

  // 获取公开分类列表
  getCategories() {
    return request.get<ApiResponse<any[]>>('/tracks/public/categories')
  },

  // 按分类获取歌曲
  getByCategory(categoryId: number, page?: number, size?: number) {
    return request.get<ApiResponse<PageResponse<Track>>>('/tracks/public/list', {
      params: { categoryId, page, size }
    })
  },

  // 记录播放
  recordPlay(id: number, durationPlayed: number) {
    return request.post<ApiResponse<void>>(`/tracks/${id}/play`, { durationPlayed })
  }
}

// 歌单 API
export const playlistApi = {
  // 获取公开歌单列表
  getPublicList(page?: number, size?: number) {
    return request.get<ApiResponse<PageResponse<Playlist>>>('/playlists/public', { 
      params: { page, size } 
    })
  },

  // 获取指定用户的公开歌单
  getUserPlaylists(userId: number, page?: number, size?: number) {
    return request.get<ApiResponse<PageResponse<Playlist>>>(`/playlists/public/user/${userId}`, { 
      params: { page, size } 
    })
  },

  // 获取我的歌单
  getMyPlaylists(page?: number, size?: number) {
    return request.get<ApiResponse<PageResponse<Playlist>>>('/playlists/mine', { 
      params: { page, size } 
    })
  },

  // 获取歌单详情
  getDetail(id: number) {
    return request.get<ApiResponse<Playlist>>(`/playlists/public/${id}`)
  },

  // 获取歌单中的歌曲
  getTracks(id: number, page?: number, size?: number) {
    return request.get<ApiResponse<PageResponse<Track>>>(`/playlists/${id}/tracks`, { 
      params: { page, size } 
    })
  },

  // 创建歌单
  create(data: { name: string; description?: string }) {
    return request.post<ApiResponse<Playlist>>('/playlists', data)
  },

  // 创建带封面的歌单
  createWithCover(data: { name: string; description?: string }, coverFile?: File) {
    const formData = new FormData()
    formData.append('name', data.name)
    if (data.description) {
      formData.append('description', data.description)
    }
    if (coverFile) {
      formData.append('cover', coverFile)
    }
    return request.post<ApiResponse<Playlist>>('/playlists/with-cover', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  },

  // 更新歌单封面
  updateCover(id: number, coverFile: File) {
    const formData = new FormData()
    formData.append('cover', coverFile)
    return request.put<ApiResponse<Playlist>>(`/playlists/${id}/cover`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
  },

  // 更新歌单
  update(id: number, data: { name?: string; description?: string }) {
    return request.put<ApiResponse<Playlist>>(`/playlists/${id}`, data)
  },

  // 删除歌单
  delete(id: number) {
    return request.delete<ApiResponse<void>>(`/playlists/${id}`)
  },

  // 添加歌曲到歌单
  addTrack(playlistId: number, trackId: number) {
    return request.post<ApiResponse<void>>(`/playlists/${playlistId}/tracks`, { trackId })
  },

  // 从歌单移除歌曲
  removeTrack(playlistId: number, trackId: number) {
    return request.delete<ApiResponse<void>>(`/playlists/${playlistId}/tracks/${trackId}`)
  }
}

// 用户相关 API
export const userApi = {
  // 检查用户名是否存在并获取头像（登录页预览用）
  checkUsername(username: string) {
    return request.get<ApiResponse<{ exists: boolean; avatar: string | null }>>('/auth/check-username', {
      params: { username }
    })
  },

  // 登录
  login(data: { username: string; password: string }) {
    return request.post<ApiResponse<{ token: string; user: any }>>('/auth/login', data)
  },

  // 注册
  register(data: { username: string; email: string; password: string; adminKey?: string }) {
    return request.post<ApiResponse<any>>('/auth/register', data)
  },

  // 获取当前用户信息（可选 useAdminToken: true 表示用管理员 token 请求）
  getUserInfo(config?: { useAdminToken?: boolean }) {
    return request.get<ApiResponse<any>>('/users/me', config as any)
  },

  // 更新用户信息
  updateUserInfo(data: { nickname?: string; signature?: string; gender?: string; birthday?: string; region?: string }) {
    return request.put<ApiResponse<any>>('/users/me', data)
  },

  // 上传头像
  uploadAvatar(avatar: File) {
    const formData = new FormData()
    formData.append('avatar', avatar)
    return request.post<ApiResponse<string>>('/users/me/avatar', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })
  },

  // 修改密码
  changePassword(oldPassword: string, newPassword: string) {
    return request.put<ApiResponse<void>>('/users/me/password', { oldPassword, newPassword })
  },

  // 获取用户公开信息
  getUserPublicInfo(userId: number) {
    return request.get<ApiResponse<any>>(`/users/${userId}`)
  },

  // 获取我的评论
  getMyComments(page?: number, size?: number) {
    return request.get<ApiResponse<PageResponse<any>>>('/users/me/comments', { 
      params: { page, size } 
    })
  },

  // 删除我的评论
  deleteComment(commentId: number) {
    return request.delete<ApiResponse<void>>(`/comments/${commentId}`)
  },

  // 获取播放记录
  getPlayHistory(page?: number, size?: number) {
    return request.get<ApiResponse<PageResponse<any>>>('/users/me/play-history', { 
      params: { page, size } 
    })
  },

  // 获取指定用户公开播放记录
  getUserPlayHistory(userId: number, page?: number, size?: number) {
    return request.get<ApiResponse<PageResponse<any>>>(`/users/${userId}/play-history`, {
      params: { page, size }
    })
  },

  // 清空播放记录
  clearPlayHistory() {
    return request.delete<ApiResponse<void>>('/users/me/play-history')
  },

  // 删除单条播放记录
  deletePlayHistoryItem(historyId: number) {
    return request.delete<ApiResponse<void>>(`/users/me/play-history/${historyId}`)
  },

  // 注销账号
  deleteAccount(data: { username: string; password: string }) {
    return request.delete<ApiResponse<void>>('/users/me', { data })
  }
}

// 收藏相关 API
export const favoriteApi = {
  // 获取我的收藏
  getMyFavorites(page?: number, size?: number) {
    return request.get<ApiResponse<PageResponse<Track>>>('/favorites/list', { 
      params: { page, size } 
    })
  },

  // 收藏歌曲
  add(trackId: number) {
    return request.post<ApiResponse<void>>(`/favorites/${trackId}`)
  },

  // 取消收藏
  remove(trackId: number) {
    return request.delete<ApiResponse<void>>(`/favorites/${trackId}`)
  },

  // 检查是否收藏
  check(trackId: number) {
    return request.get<ApiResponse<boolean>>(`/favorites/check/${trackId}`)
  },

  // 获取指定用户的收藏列表（公开）
  getUserFavorites(userId: number, page?: number, size?: number) {
    return request.get<ApiResponse<PageResponse<Track>>>('/favorites/user/' + userId, { 
      params: { page, size } 
    })
  }
}

// 评论相关 API
export const commentApi = {
  // 获取歌曲评论列表
  getList(trackId: number, page?: number, size?: number) {
    return request.get<ApiResponse<PageResponse<Comment>>>(`/comments/track/${trackId}`, { 
      params: { page, size } 
    })
  },

  // 获取评论回复
  getReplies(commentId: number, page?: number, size?: number) {
    return request.get<ApiResponse<PageResponse<Comment>>>(`/comments/${commentId}/replies`, { 
      params: { page, size } 
    })
  },

  // 发表评论
  create(data: { trackId: number; content: string; parentId?: number; replyToUserId?: number }) {
    const body: Record<string, unknown> = { content: data.content, parentId: data.parentId }
    if (data.replyToUserId != null) body.replyToUserId = data.replyToUserId
    return request.post<ApiResponse<Comment>>(`/comments/track/${data.trackId}`, body)
  },

  // 删除评论
  delete(commentId: number) {
    return request.delete<ApiResponse<void>>(`/comments/${commentId}`)
  },

  // 点赞评论
  like(commentId: number) {
    return request.post<ApiResponse<void>>(`/comments/${commentId}/like`)
  },

  // 取消点赞（使用同一个接口，后端会根据状态切换）
  unlike(commentId: number) {
    return request.delete<ApiResponse<void>>(`/comments/${commentId}/like`)
  }
}

// 关注 API
export const followApi = {
  follow(userId: number) {
    return request.post<ApiResponse<void>>(`/follows/${userId}`)
  },
  unfollow(userId: number) {
    return request.delete<ApiResponse<void>>(`/follows/${userId}`)
  },
  isFollowing(userId: number) {
    return request.get<ApiResponse<boolean>>(`/follows/check/${userId}`)
  },
  getCounts(userId: number) {
    return request.get<ApiResponse<{ following: number; followers: number }>>(`/follows/counts/${userId}`)
  },
  getFollowing(userId: number, page?: number, size?: number) {
    return request.get<ApiResponse<PageResponse<any>>>(`/follows/${userId}/following`, { params: { page, size } })
  },
  getFollowers(userId: number, page?: number, size?: number) {
    return request.get<ApiResponse<PageResponse<any>>>(`/follows/${userId}/followers`, { params: { page, size } })
  }
}

// 消息通知 API
export interface NotificationItem {
  id: number
  userId: number
  fromUserId: number | null
  fromUserNickname: string | null
  fromUserAvatar: string | null
  type: 'FOLLOW' | 'COMMENT_REPLY' | 'LIKE'
  refId: number | null
  refType: string | null
  extra: string | null
  read: number
  createdAt: string
}

export const notificationApi = {
  getList(page?: number, size?: number) {
    return request.get<ApiResponse<{ records: NotificationItem[]; total: number; unreadCount: number }>>('/notifications/me', {
      params: { page, size }
    })
  },
  getUnreadCount() {
    return request.get<ApiResponse<number>>('/notifications/me/unread-count')
  },
  markAllRead() {
    return request.put<ApiResponse<void>>('/notifications/me/read')
  },
  deleteOne(id: number) {
    return request.delete<ApiResponse<void>>(`/notifications/me/${id}`)
  },
  clearAll() {
    return request.delete<ApiResponse<void>>('/notifications/me')
  }
}

// 公告 API
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
