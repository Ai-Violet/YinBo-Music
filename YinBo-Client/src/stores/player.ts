import { defineStore } from 'pinia'
import type { Track } from '../types/track'

// 本地存储键名
const STORAGE_KEYS = {
  CURRENT_TRACK: 'yinbo_current_track',
  PLAY_PROGRESS: 'yinbo_play_progress',
  VOLUME: 'yinbo_volume',
  PLAY_MODE: 'yinbo_play_mode',
  PLAYLIST: 'yinbo_playlist',
  IS_PLAYING: 'yinbo_is_playing'
}

interface PlayerState {
  currentTrack: Track | null
  playlist: Track[]
  isPlaying: boolean
  volume: number
  currentTime: number
  duration: number
  playMode: 'order' | 'single' | 'random'
  sleepTimer: number | null
  sleepMode: 'off' | '15' | '30' | '60' | 'end'
}

// 从本地存储加载状态
const loadFromStorage = () => {
  try {
    const savedTrack = localStorage.getItem(STORAGE_KEYS.CURRENT_TRACK)
    const savedProgress = localStorage.getItem(STORAGE_KEYS.PLAY_PROGRESS)
    const savedVolume = localStorage.getItem(STORAGE_KEYS.VOLUME)
    const savedMode = localStorage.getItem(STORAGE_KEYS.PLAY_MODE)
    const savedPlaylist = localStorage.getItem(STORAGE_KEYS.PLAYLIST)
    
    return {
      track: savedTrack ? JSON.parse(savedTrack) : null,
      progress: savedProgress ? parseFloat(savedProgress) : 0,
      volume: savedVolume ? parseFloat(savedVolume) : 0.6,
      mode: (savedMode as 'order' | 'single' | 'random') || 'order',
      playlist: savedPlaylist ? JSON.parse(savedPlaylist) : [],
      isPlaying: localStorage.getItem(STORAGE_KEYS.IS_PLAYING) === 'true'
    }
  } catch (e) {
    console.error('Failed to load player state from storage:', e)
    return {
      track: null,
      progress: 0,
      volume: 0.6,
      mode: 'order' as const,
      playlist: [],
      isPlaying: false
    }
  }
}

// 保存状态到本地存储
const saveToStorage = (key: string, value: any) => {
  try {
    if (value === null || value === undefined) {
      localStorage.removeItem(key)
    } else if (typeof value === 'object') {
      localStorage.setItem(key, JSON.stringify(value))
    } else {
      localStorage.setItem(key, String(value))
    }
  } catch (e) {
    console.error('Failed to save player state to storage:', e)
  }
}

export const usePlayerStore = defineStore('player', {
  state: (): PlayerState => {
    const saved = loadFromStorage()
    return {
      currentTrack: saved.track,
      playlist: saved.playlist,
      isPlaying: saved.isPlaying,
      volume: saved.volume,
      currentTime: saved.progress,
      duration: 0,
      playMode: saved.mode,
      sleepTimer: null,
      sleepMode: 'off'
    }
  },

  actions: {
    setCurrentTrack(track: Track) {
      this.currentTrack = track
      this.currentTime = 0
      this.isPlaying = true
      
      // 保存当前歌曲到本地存储
      saveToStorage(STORAGE_KEYS.CURRENT_TRACK, track)
      saveToStorage(STORAGE_KEYS.PLAY_PROGRESS, 0)
      saveToStorage(STORAGE_KEYS.IS_PLAYING, true)
      
      // 自动添加到播放列表
      this.addToPlaylist(track)
      
      // 记录播放历史
      this.recordPlayHistory(track)
    },

    // 设置播放列表并播放指定歌曲
    setPlaylistAndPlay(tracks: Track[], trackToPlay: Track) {
      this.playlist = tracks
      saveToStorage(STORAGE_KEYS.PLAYLIST, tracks)
      this.setCurrentTrack(trackToPlay)
    },

    play() {
      this.isPlaying = true
      saveToStorage(STORAGE_KEYS.IS_PLAYING, true)
    },

    pause() {
      this.isPlaying = false
      saveToStorage(STORAGE_KEYS.IS_PLAYING, false)
    },

    togglePlay() {
      this.isPlaying = !this.isPlaying
      saveToStorage(STORAGE_KEYS.IS_PLAYING, this.isPlaying)
    },

    setVolume(volume: number) {
      this.volume = Math.max(0, Math.min(1, volume))
      saveToStorage(STORAGE_KEYS.VOLUME, this.volume)
    },

    setCurrentTime(time: number) {
      this.currentTime = time
      // 定期保存播放进度（避免频繁写入）
      if (Math.floor(time) % 5 === 0) {
        saveToStorage(STORAGE_KEYS.PLAY_PROGRESS, time)
      }
    },

    setDuration(duration: number) {
      this.duration = duration
    },

    addToPlaylist(track: Track) {
      // 避免重复添加
      const exists = this.playlist.find(t => t.id === track.id)
      if (!exists) {
        this.playlist.push(track)
        saveToStorage(STORAGE_KEYS.PLAYLIST, this.playlist)
      }
    },

    removeFromPlaylist(index: number) {
      this.playlist.splice(index, 1)
      saveToStorage(STORAGE_KEYS.PLAYLIST, this.playlist)
    },

    clearPlaylist() {
      this.playlist = []
      saveToStorage(STORAGE_KEYS.PLAYLIST, [])
    },

    setPlayMode(mode: 'order' | 'single' | 'random') {
      this.playMode = mode
      saveToStorage(STORAGE_KEYS.PLAY_MODE, mode)
    },

    playNext() {
      if (this.playlist.length === 0) return
      
      const currentIndex = this.playlist.findIndex(t => t.id === this.currentTrack?.id)
      let nextIndex: number
      
      if (this.playMode === 'random') {
        // 随机播放
        nextIndex = Math.floor(Math.random() * this.playlist.length)
      } else {
        // 顺序播放
        nextIndex = (currentIndex + 1) % this.playlist.length
      }
      
      this.setCurrentTrack(this.playlist[nextIndex])
    },

    playPrevious() {
      if (this.playlist.length === 0) return
      
      const currentIndex = this.playlist.findIndex(t => t.id === this.currentTrack?.id)
      let prevIndex: number
      
      if (this.playMode === 'random') {
        // 随机播放
        prevIndex = Math.floor(Math.random() * this.playlist.length)
      } else {
        // 顺序播放
        prevIndex = currentIndex <= 0 ? this.playlist.length - 1 : currentIndex - 1
      }
      
      this.setCurrentTrack(this.playlist[prevIndex])
    },

    // 恢复上次的播放进度
    restoreProgress() {
      const saved = loadFromStorage()
      if (this.currentTrack && saved.progress > 0) {
        this.currentTime = saved.progress
      }
    },

    // 记录播放历史
    recordPlayHistory(track: Track) {
      try {
        const key = 'yinbo_play_history'
        let history: { trackId: number; playedAt: string; count: number }[] = []
        
        const saved = localStorage.getItem(key)
        if (saved) {
          history = JSON.parse(saved)
        }
        
        // 查找是否已有记录
        const existingIndex = history.findIndex(h => h.trackId === track.id)
        if (existingIndex >= 0) {
          // 更新现有记录
          history[existingIndex].playedAt = new Date().toISOString()
          history[existingIndex].count += 1
          // 移到最前面
          const item = history.splice(existingIndex, 1)[0]
          history.unshift(item)
        } else {
          // 添加新记录
          history.unshift({
            trackId: track.id,
            playedAt: new Date().toISOString(),
            count: 1
          })
        }
        
        // 限制历史记录数量
        if (history.length > 100) {
          history = history.slice(0, 100)
        }
        
        localStorage.setItem(key, JSON.stringify(history))
      } catch (e) {
        console.error('Failed to record play history:', e)
      }
    },

    // 保存当前播放进度
    saveCurrentProgress() {
      if (this.currentTrack) {
        saveToStorage(STORAGE_KEYS.PLAY_PROGRESS, this.currentTime)
      }
    },

    syncFromStorage() {
      const saved = loadFromStorage()
      this.currentTrack = saved.track
      this.playlist = saved.playlist
      this.volume = saved.volume
      this.playMode = saved.mode
      this.currentTime = saved.progress
      this.isPlaying = saved.isPlaying
    },

    setSleepTimer(mode: 'off' | '15' | '30' | '60' | 'end') {
      if (this.sleepTimer !== null) {
        window.clearTimeout(this.sleepTimer)
        this.sleepTimer = null
      }
      this.sleepMode = mode
      if (mode === 'off' || mode === 'end') return

      const minutes = parseInt(mode)
      this.sleepTimer = window.setTimeout(() => {
        this.pause()
        this.sleepMode = 'off'
        this.sleepTimer = null
      }, minutes * 60 * 1000)
    },

    handleTrackEnd() {
      if (this.sleepMode === 'end') {
        this.pause()
        this.sleepMode = 'off'
        return
      }
      if (this.playMode === 'single') {
        this.currentTime = 0
        this.isPlaying = true
      } else {
        this.playNext()
      }
    }
  }
})
