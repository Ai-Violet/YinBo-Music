<template>
  <div class="simple-home">
    <!-- 顶部导航栏 -->
    <header class="top-header">
      <div class="logo">
        <svg viewBox="0 0 24 24" width="32" height="32" fill="currentColor">
          <path d="M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z"/>
        </svg>
        <span class="logo-text">音波音乐</span>
      </div>
      <div class="search-box">
        <input 
          v-model="searchKeyword" 
          type="text" 
          placeholder="搜索音乐、歌手..."
          @keyup.enter="handleSearch"
        />
        <button @click="handleSearch">
          <svg viewBox="0 0 24 24" width="18" height="18">
            <path fill="currentColor" d="M15.5 14h-.79l-.28-.27a6.5 6.5 0 0 0 1.48-5.34c-.47-2.78-2.79-5-5.59-5.34a6.505 6.505 0 0 0-7.27 7.27c.34 2.8 2.56 5.12 5.34 5.59a6.5 6.5 0 0 0 5.34-1.48l.27.28v.79l4.25 4.25c.41.41 1.08.41 1.49 0 .41-.41.41-1.08 0-1.49L15.5 14zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
          </svg>
        </button>
      </div>
      <div class="user-area">
        <router-link to="/login" class="login-btn">登录</router-link>
      </div>
    </header>

    <!-- 主内容区 -->
    <main class="main-content">
      <!-- 热门推荐 -->
      <section class="section">
        <div class="section-header">
          <h2>热门推荐</h2>
          <button class="refresh-btn" @click="loadHotTracks">
            <svg viewBox="0 0 24 24" width="16" height="16">
              <path fill="currentColor" d="M17.65 6.35C16.2 4.9 14.21 4 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08c-.82 2.33-3.04 4-5.65 4-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z"/>
            </svg>
            换一批
          </button>
        </div>
        <div class="track-grid">
          <div 
            v-for="track in hotTracks" 
            :key="track.id" 
            class="track-card"
            @click="playTrack(track)"
          >
            <div class="cover-wrapper">
              <img :src="track.coverUrl || defaultCover" alt="封面" class="cover" />
              <div class="play-overlay">
                <div class="play-btn-circle">
                  <svg viewBox="0 0 24 24" width="24" height="24">
                    <path fill="currentColor" d="M8 5v14l11-7z"/>
                  </svg>
                </div>
              </div>
            </div>
            <div class="track-info">
              <h4 class="title">{{ track.title }}</h4>
              <p class="artist">{{ track.artist }}</p>
            </div>
          </div>
        </div>
      </section>

      <!-- 登录提示 -->
      <section class="login-prompt">
        <div class="prompt-content">
          <h3>登录解锁更多功能</h3>
          <div class="features">
            <div class="feature-item">
              <svg viewBox="0 0 24 24" width="24" height="24">
                <path fill="currentColor" d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
              </svg>
              <span>收藏喜欢的音乐</span>
            </div>
            <div class="feature-item">
              <svg viewBox="0 0 24 24" width="24" height="24">
                <path fill="currentColor" d="M15 6H3v2h12V6zm0 4H3v2h12v-2zM3 16h8v-2H3v2zM17 6v8.18c-.31-.11-.65-.18-1-.18-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3V8h3V6h-5z"/>
              </svg>
              <span>创建个人歌单</span>
            </div>
            <div class="feature-item">
              <svg viewBox="0 0 24 24" width="24" height="24">
                <path fill="currentColor" d="M21 6h-2v9H6v2c0 .55.45 1 1 1h11l4 4V7c0-.55-.45-1-1-1zm-4 6V3c0-.55-.45-1-1-1H3c-.55 0-1 .45-1 1v14l4-4h10c.55 0 1-.45 1-1z"/>
              </svg>
              <span>发表音乐评论</span>
            </div>
            <div class="feature-item">
              <svg viewBox="0 0 24 24" width="24" height="24">
                <path fill="currentColor" d="M13 3c-4.97 0-9 4.03-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42C8.27 19.99 10.51 21 13 21c4.97 0 9-4.03 9-9s-4.03-9-9-9zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z"/>
              </svg>
              <span>播放历史记录</span>
            </div>
          </div>
          <router-link to="/login" class="login-btn-large">登录 / 注册</router-link>
        </div>
      </section>
    </main>

    <!-- 底部播放器 -->
    <Player />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { usePlayerStore } from '../stores/player'
import { trackApi } from '../api'
// @ts-ignore
import Player from '../components/Player.vue'

const router = useRouter()
const playerStore = usePlayerStore()

const HOT_SIZE = 8  // 与已登录首页一致，一排展示
import { DEFAULT_AVATAR_COVER } from '../constants'
const defaultCover = DEFAULT_AVATAR_COVER
const searchKeyword = ref('')
const hotTracks = ref<any[]>([])

// 加载热门音乐
const loadHotTracks = async () => {
  try {
    const res = await trackApi.getHot(1, HOT_SIZE)
    if (res.data.code === 200) {
      hotTracks.value = res.data.data.records || []
    }
  } catch (e) {
    // 使用模拟数据
    hotTracks.value = generateMockTracks(HOT_SIZE)
  }
}

// 生成模拟数据
const generateMockTracks = (count: number) => {
  const titles = ['晴天', '稻香', '夜曲', '青花瓷', '告白气球', '七里香', '简单爱', '双截棍']
  const artists = ['周杰伦', '薛之谦', '毛不易', '朴树', '邓紫棋', '林俊杰']
  return Array.from({ length: count }, (_, i) => ({
    id: i + 1,
    title: titles[i % titles.length],
    artist: artists[i % artists.length],
    album: '专辑名',
    duration: 180 + Math.floor(Math.random() * 120),
    coverUrl: defaultCover,
    url: ''
  }))
}

// 播放音乐
const playTrack = (track: any) => {
  playerStore.setCurrentTrack(track)
  playerStore.play()
}

// 搜索
const handleSearch = () => {
  if (searchKeyword.value.trim()) {
    router.push(`/search?q=${encodeURIComponent(searchKeyword.value.trim())}`)
  }
}

onMounted(() => {
  loadHotTracks()
})
</script>

<style scoped>
.simple-home {
  min-height: 100vh;
  background: var(--bg-primary);
  color: var(--text-primary);
  display: flex;
  flex-direction: column;
}

/* 顶部导航 */
.top-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--sp-3) var(--sp-8);
  background: var(--bg-secondary);
  backdrop-filter: blur(10px);
  position: sticky;
  top: 0;
  z-index: 100;
}

.logo {
  display: flex;
  align-items: center;
  gap: var(--sp-2);
  color: var(--red);
}

.logo-text {
  font-size: var(--text-lg);
  font-weight: bold;
  background: var(--accent);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
}

.search-box {
  display: flex;
  align-items: center;
  background: var(--bg-hover);
  border-radius: var(--radius-full);
  padding: 0 var(--sp-4);
  width: 300px;
}

.search-box input {
  flex: 1;
  background: transparent;
  border: none;
  padding: var(--sp-2) 0;
  color: var(--text-primary);
  font-size: var(--text-base);
}

.search-box input::placeholder {
  color: var(--text-secondary);
}

.search-box button {
  background: transparent;
  border: none;
  color: var(--text-secondary);
  cursor: pointer;
  padding: var(--sp-1);
}

.user-area {
  display: flex;
  align-items: center;
  gap: var(--sp-4);
}

.login-btn {
  padding: var(--sp-2) var(--sp-5);
  background: var(--accent);
  border-radius: var(--radius-full);
  color: var(--text-primary);
  text-decoration: none;
  font-size: var(--text-base);
  transition: all var(--dur-normal) var(--ease-out);
}

.login-btn:hover {
  transform: scale(1.05);
  background: var(--accent-hover);
  box-shadow: var(--shadow-md);
}

/* 主内容 */
.main-content {
  flex: 1;
  padding: var(--sp-5) var(--sp-8);
  overflow-y: auto;
  padding-bottom: 100px;
}

/* 区块 */
.section {
  margin-bottom: var(--sp-10);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--sp-5);
}

.section-header h2 {
  font-size: var(--text-lg);
  font-weight: 600;
}

.refresh-btn {
  display: flex;
  align-items: center;
  gap: var(--sp-1);
  background: transparent;
  border: 1px solid var(--border-hover);
  border-radius: var(--radius-md);
  padding: var(--sp-2) var(--sp-4);
  color: var(--text-secondary);
  font-size: var(--text-sm);
  cursor: pointer;
}

.refresh-btn:hover {
  border-color: var(--accent);
  color: var(--accent);
}

/* 音乐网格 - 与已登录首页一致，固定一排展示不换行 */
.track-grid {
  display: grid;
  grid-template-columns: repeat(8, minmax(0, 1fr));
  gap: var(--sp-6);
}

.track-card {
  background: var(--bg-hover);
  border-radius: var(--radius-md);
  overflow: hidden;
  cursor: pointer;
  transition: transform var(--dur-fast), background var(--dur-fast);
}

.track-card:hover {
  transform: translateY(-5px);
  background: var(--bg-card);
}

.cover-wrapper {
  position: relative;
  aspect-ratio: 1;
}

.cover {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.play-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity var(--dur-fast);
}

.track-card:hover .play-overlay {
  opacity: 1;
}

.play-overlay .play-btn-circle {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  background: var(--play-overlay-btn-bg);
  color: var(--play-overlay-btn-color);
  display: flex;
  align-items: center;
  justify-content: center;
}

.track-info {
  padding: var(--sp-3);
}

.title {
  font-size: var(--text-base);
  font-weight: 500;
  margin: 0 0 var(--sp-1);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.artist {
  font-size: var(--text-sm);
  color: var(--text-secondary);
  margin: 0;
}

/* 登录提示 */
.login-prompt {
  background: var(--bg-card);
  border-radius: var(--radius-xl);
  padding: var(--sp-10);
  text-align: center;
}

.prompt-content h3 {
  font-size: var(--text-lg);
  margin: 0 0 var(--sp-8);
}

.features {
  display: flex;
  justify-content: center;
  gap: var(--sp-10);
  margin-bottom: var(--sp-8);
  flex-wrap: wrap;
}

.feature-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--sp-2);
  color: var(--text-secondary);
}

.feature-item svg {
  color: var(--accent);
}

.feature-item span {
  font-size: var(--text-base);
}

.login-btn-large {
  display: inline-block;
  padding: var(--sp-4) var(--sp-10);
  background: var(--accent);
  border-radius: var(--radius-full);
  color: var(--text-primary);
  text-decoration: none;
  font-size: var(--text-md);
  transition: all var(--dur-normal) var(--ease-out);
}

.login-btn-large:hover {
  transform: scale(1.05);
  background: var(--accent-hover);
  box-shadow: var(--shadow-md);
}

/* 响应式 */
@media (max-width: 1200px) {
  .track-grid {
    grid-template-columns: repeat(4, minmax(0, 1fr));
  }
}

@media (max-width: 768px) {
  .search-box {
    width: 200px;
  }
  
  .track-grid {
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: var(--sp-4);
  }
  
  .features {
    gap: var(--sp-5);
  }
}
</style>
