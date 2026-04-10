import { ElMessage } from 'element-plus'
import { trackApi } from '../api'

type TrackLike = {
  id: number
  title?: string
  playUrl?: string
  audioUrl?: string
}

export async function downloadTrackFile(track: TrackLike) {
  let url = track.playUrl || track.audioUrl
  if (!url) {
    try {
      const res = await trackApi.getDetail(track.id)
      if (res.data.code === 200 && res.data.data) {
        const d = res.data.data as unknown as { playUrl?: string; audioUrl?: string; url?: string }
        url = d.playUrl || d.audioUrl || d.url
      }
    } catch (_) {
      /* ignore */
    }
  }
  if (!url) {
    ElMessage.warning('暂无音频地址')
    return
  }
  const safeName = (track.title || 'track').replace(/[/\\?%*:|"<>]/g, '_')
  try {
    const a = document.createElement('a')
    a.href = url
    a.download = `${safeName}.mp3`
    a.target = '_blank'
    a.rel = 'noopener noreferrer'
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
  } catch (_) {
    window.open(url, '_blank', 'noopener,noreferrer')
  }
}
