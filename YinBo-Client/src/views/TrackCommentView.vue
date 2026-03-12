<template>
  <div class="track-comment-view">
    <div class="page-header">
      <button class="back-btn" @click="router.push('/home')">← 返回</button>
    </div>
    <div v-if="loading" class="loading">加载中...</div>
    <div v-else-if="!track" class="error">歌曲不存在</div>
    <div v-else class="content">
      <div class="track-card" @click="playTrack">
        <img :src="track.coverUrl || track.cover || defaultCover" alt="封面" class="cover" />
        <div class="track-info">
          <h2>{{ track.title }}</h2>
          <p>{{ track.artist }}</p>
        </div>
        <div class="play-hint">点击播放</div>
      </div>
      <TrackCommentDrawer v-model="drawerOpen" :track="track" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { trackApi } from '../api'
import { usePlayerStore } from '../stores/player'
import TrackCommentDrawer from '../components/TrackCommentDrawer.vue'

const route = useRoute()
const router = useRouter()
const playerStore = usePlayerStore()
import { DEFAULT_AVATAR_COVER } from '../constants'
const defaultCover = DEFAULT_AVATAR_COVER

const track = ref<any>(null)
const loading = ref(true)
const drawerOpen = ref(false)

const loadTrack = async () => {
  const id = Number(route.params.id)
  if (!id) {
    loading.value = false
    return
  }
  loading.value = true
  try {
    const res = await trackApi.getDetail(id)
    if (res.data.code === 200 && res.data.data) {
      track.value = res.data.data
      drawerOpen.value = true
    }
  } catch (e) {
    console.error('Load track failed:', e)
  } finally {
    loading.value = false
  }
}

const playTrack = () => {
  if (track.value) {
    playerStore.setCurrentTrack(track.value)
    playerStore.play()
  }
}

onMounted(loadTrack)
watch(() => route.params.id, loadTrack)
</script>

<style scoped>
.track-comment-view {
  max-width: 600px;
  margin: 0 auto;
  padding: var(--sp-5);
}

.page-header {
  margin-bottom: var(--sp-5);
}

.back-btn {
  background: none;
  border: none;
  color: var(--text-secondary);
  cursor: pointer;
  font-size: var(--text-base);
}

.back-btn:hover {
  color: var(--accent);
}

.loading, .error {
  text-align: center;
  padding: var(--sp-10);
  color: var(--text-secondary);
}

.track-card {
  display: flex;
  align-items: center;
  gap: var(--sp-5);
  padding: var(--sp-5);
  background: var(--bg-hover);
  border-radius: var(--radius-lg);
  margin-bottom: var(--sp-6);
  cursor: pointer;
}

.track-card:hover {
  background: var(--bg-elevated);
}

.cover {
  width: 100px;
  height: 100px;
  border-radius: var(--radius-md);
  object-fit: cover;
}

.track-info {
  flex: 1;
}

.track-info h2 {
  margin: 0 0 var(--sp-2);
  font-size: var(--text-lg);
  color: var(--text-primary);
}

.track-info p {
  margin: 0;
  color: var(--text-tertiary);
  font-size: var(--text-sm);
}

.play-hint {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

</style>
