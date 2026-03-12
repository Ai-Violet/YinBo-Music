// 音轨数据
export interface Track {
  id: number
  title: string
  artist: string
  artistId?: number
  album?: string
  duration: number
  coverUrl?: string
  audioUrl?: string
  playUrl?: string
  playCount?: number
  lyrics?: string
  likeCount?: number
  isLiked?: boolean
  isFavorited?: boolean
}

// 歌单数据
export interface Playlist {
  id: number
  name: string
  coverUrl?: string
  trackCount: number
  isPublic: boolean
  ownerId: number
  tracks?: Track[]
}

// 用户数据
export interface User {
  id: number
  username: string
  email: string
  avatar?: string
  role: 'USER' | 'ADMIN'
}

// 评论数据
export interface Comment {
  id: number
  userId: number
  trackId: number
  content: string
  likeCount: number
  createdAt: string
  user?: User
}

// 播放历史数据
export interface PlayHistory {
  id: number
  userId: number
  trackId: number
  playedAt: string
  track?: Track
}