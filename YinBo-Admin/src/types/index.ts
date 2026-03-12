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
  status?: number
}

export interface Playlist {
  id: number
  name: string
  coverUrl?: string
  trackCount: number
  isPublic: boolean
  ownerId: number
  tracks?: Track[]
}

export interface User {
  id: number
  username: string
  email: string
  nickname?: string
  avatar?: string
  role: 'USER' | 'ADMIN'
}

export interface Comment {
  id: number
  userId: number
  trackId: number
  content: string
  likeCount: number
  createdAt: string
  status?: number
  user?: User
}
