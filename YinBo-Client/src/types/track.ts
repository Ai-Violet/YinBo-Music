export interface Track {
  id: number
  title: string
  artist: string
  artistId?: number
  album?: string
  duration: number
  cover?: string
  url?: string
  playUrl?: string
  coverUrl?: string
  isLiked?: boolean
  isFavorited?: boolean
  playCount?: number
  likeCount?: number
  lyrics?: string
}