<template>
  <div class="home-page">
    <!-- 顶部导航栏 -->
    <header class="top-header">
      <div class="logo">
        <svg viewBox="0 0 24 24" width="28" height="28" fill="currentColor" style="color: var(--accent)">
          <path d="M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z"/>
        </svg>
        <span class="logo-text">音波音乐</span>
      </div>
      <div class="search-box" ref="searchBoxRef">
        <input 
          v-model="searchKeyword" 
          type="text" 
          placeholder="搜索音乐、歌手..."
          @keyup.enter="handleSearch"
          @focus="showSearchHistory = true"
        />
        <button @click="handleSearch">
          <svg viewBox="0 0 24 24" width="18" height="18">
            <path fill="currentColor" d="M15.5 14h-.79l-.28-.27a6.5 6.5 0 0 0 1.48-5.34c-.47-2.78-2.79-5-5.59-5.34a6.505 6.505 0 0 0-7.27 7.27c.34 2.8 2.56 5.12 5.34 5.59a6.5 6.5 0 0 0 5.34-1.48l.27.28v.79l4.25 4.25c.41.41 1.08.41 1.49 0 .41-.41.41-1.08 0-1.49L15.5 14zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
          </svg>
        </button>
        <!-- 搜索历史下拉 -->
        <div class="search-dropdown" v-if="showSearchHistory && searchHistoryList.length > 0 && !searchKeyword">
          <div class="search-dropdown-header">
            <span>搜索历史</span>
            <button class="clear-history-btn" @click.stop="clearSearchHistory">清空</button>
          </div>
          <div
            v-for="(item, i) in searchHistoryList"
            :key="i"
            class="search-history-item"
            @click="searchFromHistory(item)"
          >
            <svg viewBox="0 0 24 24" width="14" height="14" style="flex-shrink:0;opacity:0.4">
              <path fill="currentColor" d="M13 3c-4.97 0-9 4.03-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42C8.27 19.99 10.51 21 13 21c4.97 0 9-4.03 9-9s-4.03-9-9-9z"/>
            </svg>
            <span>{{ item }}</span>
            <button class="history-delete-btn" @click.stop="removeSearchHistoryItem(item)" title="删除">×</button>
          </div>
        </div>
      </div>
      <div class="user-area">
        <!-- 未登录状态 -->
        <template v-if="!userStore.currentUser">
          <router-link to="/login" class="login-btn">登录</router-link>
        </template>
        
        <!-- 已登录状态 -->
        <div v-else class="user-section">
          <!-- 消息通知铃铛（头像左侧） -->
          <div class="notification-bell-wrap" ref="notificationRef">
            <button class="notification-bell" @click="toggleNotificationPanel" title="消息通知">
              <svg viewBox="0 0 24 24" width="22" height="22">
                <path fill="currentColor" d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.89 2 2 2zm6-6v-5c0-3.07-1.64-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.63 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2zm-2 1H8v-6c0-2.48 1.51-4.5 4-4.5s4 2.02 4 4.5v6z"/>
              </svg>
              <span v-if="notificationUnreadCount > 0" class="notification-dot">{{ notificationUnreadCount > 99 ? '99+' : notificationUnreadCount }}</span>
            </button>
            <div v-show="showNotificationPanel" class="notification-panel" @click.stop>
              <div class="notification-panel-header">
                <span>消息通知</span>
                <div class="panel-header-actions">
                  <router-link v-if="userStore.currentUser" to="/notifications" class="view-all-btn" @click="showNotificationPanel = false">查看全部</router-link>
                  <button v-if="notifications.length > 0 && notificationUnreadCount > 0" class="mark-read-btn" @click="markNotificationsRead">全部已读</button>
                </div>
              </div>
              <div class="notification-list">
                <template v-if="notifications.length > 0">
                  <div
                    v-for="n in notifications"
                    :key="n.id"
                    class="notification-item"
                    :class="{ unread: n.read === 0 }"
                    @click="handleNotificationClick(n)"
                  >
                    <img :src="n.fromUserAvatar || defaultAvatar" class="n-avatar" alt="" />
                    <div class="n-content">
                      <p class="n-text">{{ formatNotificationText(n) }}</p>
                      <span class="n-time">{{ formatNotificationTime(n.createdAt) }}</span>
                    </div>
                  </div>
                </template>
                <div v-else class="notification-empty">暂无消息</div>
              </div>
            </div>
          </div>
          <!-- 头像（可点击上传） -->
          <div class="avatar-wrapper" @click="triggerAvatarUpload">
            <img :src="userAvatar" alt="头像" class="user-avatar" />
            <div class="avatar-overlay">
              <svg viewBox="0 0 24 24" width="16" height="16">
                <path fill="white" d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
              </svg>
            </div>
            <input 
              ref="avatarInputRef"
              type="file" 
              accept="image/*" 
              style="display: none" 
              @change="handleAvatarChange"
            />
          </div>
          
          <!-- 昵称和下拉 -->
          <div class="nickname-section" @click="toggleDropdown">
            <span class="nickname-text">{{ displayName }}</span>
            <svg 
              class="dropdown-arrow" 
              :class="{ 'rotated': showDropdown }"
              viewBox="0 0 24 24" 
              width="16" 
              height="16"
            >
              <path fill="currentColor" d="M7 10l5 5 5-5z"/>
            </svg>
            
            <!-- 下拉菜单 -->
            <transition name="dropdown">
              <div v-if="showDropdown" class="dropdown-menu">
                <div class="dropdown-item" @click.stop="handleMenuClick('profile')">
                  <svg viewBox="0 0 24 24" width="16" height="16">
                    <path fill="currentColor" d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
                  </svg>
                  我的主页
                </div>
                <div class="dropdown-item" @click.stop="handleMenuClick('history')">
                  <svg viewBox="0 0 24 24" width="16" height="16">
                    <path fill="currentColor" d="M13 3c-4.97 0-9 4.03-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42C8.27 19.99 10.51 21 13 21c4.97 0 9-4.03 9-9s-4.03-9-9-9zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z"/>
                  </svg>
                  播放历史
                </div>
                <div class="dropdown-item" @click.stop="handleMenuClick('comments')">
                  <svg viewBox="0 0 24 24" width="16" height="16">
                    <path fill="currentColor" d="M21 6h-2v9H6v2c0 .55.45 1 1 1h11l4 4V7c0-.55-.45-1-1-1zm-4 6V3c0-.55-.45-1-1-1H3c-.55 0-1 .45-1 1v14l4-4h10c.55 0 1-.45 1-1z"/>
                  </svg>
                  我的评论
                </div>
                <div class="dropdown-item" @click.stop="handleMenuClick('settings')">
                  <svg viewBox="0 0 24 24" width="16" height="16">
                    <path fill="currentColor" d="M19.14 12.94c.04-.31.06-.63.06-.94 0-.31-.02-.63-.06-.94l2.03-1.58c.18-.14.23-.41.12-.61l-1.92-3.32c-.12-.22-.37-.29-.59-.22l-2.39.96c-.5-.38-1.03-.7-1.62-.94l-.36-2.54c-.04-.24-.24-.41-.48-.41h-3.84c-.24 0-.43.17-.47.41l-.36 2.54c-.59.24-1.13.57-1.62.94l-2.39-.96c-.22-.08-.47 0-.59.22L2.74 8.87c-.12.21-.08.47.12.61l2.03 1.58c-.04.31-.06.63-.06.94s.02.63.06.94l-2.03 1.58c-.18.14-.23.41-.12.61l1.92 3.32c.12.22.37.29.59.22l2.39-.96c.5.38 1.03.7 1.62.94l.36 2.54c.05.24.24.41.48.41h3.84c.24 0 .44-.17.47-.41l.36-2.54c.59-.24 1.13-.56 1.62-.94l2.39.96c.22.08.47 0 .59-.22l1.92-3.32c.12-.22.07-.47-.12-.61l-2.01-1.58zM12 15.6c-1.98 0-3.6-1.62-3.6-3.6s1.62-3.6 3.6-3.6 3.6 1.62 3.6 3.6-1.62 3.6-3.6 3.6z"/>
                  </svg>
                  个人设置
                </div>
                <div class="dropdown-item" @click.stop="handleMenuClick('theme')">
                  <svg viewBox="0 0 24 24" width="16" height="16">
                    <path fill="currentColor" d="M12 3c-4.97 0-9 4.03-9 9s4.03 9 9 9 9-4.03 9-9c0-.46-.04-.92-.1-1.36-.98 1.37-2.58 2.26-4.4 2.26-2.98 0-5.4-2.42-5.4-5.4 0-1.81.89-3.42 2.26-4.4-.44-.06-.9-.1-1.36-.1z"/>
                  </svg>
                  {{ themeLabel }}
                </div>
                <div class="dropdown-divider"></div>
                <div class="dropdown-item" @click.stop="handleMenuClick('switch')">
                  <svg viewBox="0 0 24 24" width="16" height="16">
                    <path fill="currentColor" d="M12 5V1L7 6l5 5V7c3.31 0 6 2.69 6 6s-2.69 6-6 6-6-2.69-6-6H4c0 4.42 3.58 8 8 8s8-3.58 8-8-3.58-8-8-8z"/>
                  </svg>
                  切换账号
                </div>
                <div class="dropdown-item danger-item" @click.stop="handleMenuClick('delete')">
                  <svg viewBox="0 0 24 24" width="16" height="16">
                    <path fill="currentColor" d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/>
                  </svg>
                  注销账号
                </div>
              </div>
            </transition>
          </div>
          
          <span class="role-badge">用户</span>
        </div>
      </div>
    </header>

    <!-- 主内容区 -->
    <main class="main-content">
      <!-- 侧边栏开关按钮（移动端和窄屏幕显示） -->
      <button class="sidebar-toggle" @click="toggleSidebar">
        <span class="bar"></span>
        <span class="bar"></span>
        <span class="bar"></span>
      </button>

      <!-- 左侧边栏 - 我的音乐 -->
      <aside class="sidebar" :class="{ 'sidebar-collapsed': !isSidebarOpen }">
        <nav class="nav-menu">
          <router-link to="/home" class="nav-item" :class="{ active: $route.path === '/home' }">
            <svg viewBox="0 0 24 24" width="20" height="20">
              <path fill="currentColor" d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/>
            </svg>
            <span>首页</span>
          </router-link>
          <router-link :to="{ path: '/profile', query: { tab: 'favorites' } }" class="nav-item">
            <svg viewBox="0 0 24 24" width="20" height="20">
              <path fill="currentColor" d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
            </svg>
            <span>我的收藏</span>
          </router-link>
          <router-link :to="{ path: '/profile', query: { tab: 'playlists' } }" class="nav-item">
            <svg viewBox="0 0 24 24" width="20" height="20">
              <path fill="currentColor" d="M15 6H3v2h12V6zm0 4H3v2h12v-2zM3 16h8v-2H3v2zM17 6v8.18c-.31-.11-.65-.18-1-.18-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3V8h3V6h-5z"/>
            </svg>
            <span>我的歌单</span>
          </router-link>
        </nav>
        
        <!-- 创建的歌单 -->
        <div class="playlist-section" v-if="userStore.currentUser">
          <div class="section-header">
            <span>创建的歌单</span>
            <button class="create-btn" @click="showCreatePlaylist = true">+</button>
          </div>
          <div class="playlist-list">
            <div 
              v-for="playlist in myPlaylists" 
              :key="playlist.id" 
              class="playlist-item"
              @click="goToPlaylist(playlist.id)"
            >
              <img 
                :src="playlist.coverUrl || defaultCover" 
                alt="封面" 
                class="playlist-cover"
              />
              <div class="playlist-info">
                <span class="playlist-name">{{ playlist.name }}</span>
                <span class="count">{{ playlist.trackCount || 0 }} 首</span>
              </div>
            </div>
          </div>
        </div>
      </aside>

      <!-- 右侧内容 -->
      <div class="content-area">
        <!-- 系统公告 -->
        <div class="announcement-bar" v-if="activeAnnouncement">
          <svg viewBox="0 0 24 24" width="16" height="16" style="flex-shrink:0">
            <path fill="currentColor" d="M18 11v2h4v-2h-4zm-2 6.61c.96.71 2.21 1.65 3.2 2.39.4-.53.8-1.07 1.2-1.6-.99-.74-2.24-1.68-3.2-2.4-.4.54-.8 1.08-1.2 1.61zM20.4 5.6c-.4-.53-.8-1.07-1.2-1.6-.99.74-2.24 1.68-3.2 2.4.4.53.8 1.07 1.2 1.6.96-.72 2.21-1.65 3.2-2.4zM4 9c-1.1 0-2 .9-2 2v2c0 1.1.9 2 2 2h1l5 3V6L5 9H4zm11.5 3c0-1.33-.58-2.53-1.5-3.35v6.69c.92-.81 1.5-2.01 1.5-3.34z"/>
          </svg>
          <span class="announce-text">{{ activeAnnouncement.title }}：{{ activeAnnouncement.content }}</span>
          <button class="announce-close" @click="activeAnnouncement = null">&times;</button>
        </div>

        <!-- 热门推荐 -->
        <section class="section">
          <div class="section-header">
            <h2>热门推荐</h2>
            <button class="refresh-btn" @click="refreshHotTracks">
              <svg viewBox="0 0 24 24" width="16" height="16">
                <path fill="currentColor" d="M17.65 6.35C16.2 4.9 14.21 4 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08c-.82 2.33-3.04 4-5.65 4-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z"/>
              </svg>
              换一批
            </button>
          </div>
          <div class="track-grid">
            <div 
              v-for="(track, index) in hotTracks" 
              :key="track.id" 
              class="track-card fade-in-up"
              :style="{ animationDelay: `${index * 0.05}s` }"
            >
              <div class="cover-wrapper" @click="playFromHotTracks(track)">
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
                <p class="artist"><ArtistLink :artist-id="track.artistId" :artist-name="track.artist" /></p>
                <div class="track-controls">
                  <span class="track-duration">{{ formatDuration(track.duration) }}</span>
                  <div class="control-btns">
                    <button class="ctrl-btn" title="添加到歌单" @click.stop="showAddToPlaylist(track)">
                      <svg viewBox="0 0 24 24" width="16" height="16">
                        <path fill="currentColor" d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
                      </svg>
                    </button>
                    <button class="ctrl-btn comment-btn" title="查看评论" @click.stop="goToComments(track)">
                      <svg viewBox="0 0 24 24" width="16" height="16">
                        <path fill="currentColor" d="M21 6h-2v9H6v2c0 .55.45 1 1 1h11l4 4V7c0-.55-.45-1-1-1zm-4 6V3c0-.55-.45-1-1-1H3c-.55 0-1 .45-1 1v14l4-4h10c.55 0 1-.45 1-1z"/>
                      </svg>
                    </button>
                    <button 
                      class="ctrl-btn like-btn" 
                      :class="{ liked: isFavorite(track.id) }" 
                      :title="isFavorite(track.id) ? '取消收藏' : '收藏'" 
                      @click.stop="toggleFavorite(track)"
                    >
                      <svg viewBox="0 0 24 24" width="16" height="16">
                        <path v-if="isFavorite(track.id)" fill="currentColor" d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                        <path v-else fill="currentColor" d="M16.5 3c-1.74 0-3.41.81-4.5 2.09C10.91 3.81 9.24 3 7.5 3 4.42 3 2 5.42 2 8.5c0 3.78 3.4 6.86 8.55 11.54L12 21.35l1.45-1.32C18.6 15.36 22 12.28 22 8.5 22 5.42 19.58 3 16.5 3zm-4.4 15.55l-.1.1-.1-.1C7.14 14.24 4 11.39 4 8.5 4 6.5 5.5 5 7.5 5c1.54 0 3.04.99 3.57 2.36h1.87C13.46 5.99 14.96 5 16.5 5c2 0 3.5 1.5 3.5 3.5 0 2.89-3.14 5.74-7.9 10.05z"/>
                      </svg>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

        </section>

        <!-- 榜单选择栏 -->
        <div class="category-nav">
          <button
            class="cat-chip"
            :class="{ active: activeListTab === 'ranking' }"
            @click="switchListTab('ranking')"
          >排行榜</button>
          <button
            class="cat-chip"
            :class="{ active: activeListTab === 'new' }"
            @click="switchListTab('new')"
          >最新音乐</button>
          <button
            class="cat-chip"
            :class="{ active: activeListTab === 'liked' }"
            @click="switchListTab('liked')"
          >最多收藏</button>
          <button
            class="cat-chip"
            :class="{ active: activeListTab === 'comments' }"
            @click="switchListTab('comments')"
          >最多评论</button>
        </div>

        <!-- 排行榜 -->
        <section class="section ranking-section" v-if="activeListTab === 'ranking'">
          <div class="section-header">
            <h2>排行榜</h2>
          </div>
          <div class="ranking-list">
            <div
              v-for="(track, index) in rankingTracks"
              :key="track.id"
              class="ranking-item"
              @click="playFromList(rankingTracks, track)"
            >
              <span class="rank-num" :class="{ top3: index < 3 }">{{ index + 1 }}</span>
              <div class="rank-cover-wrapper">
                <img :src="track.coverUrl || defaultCover" alt="封面" class="rank-cover" />
                <div class="rank-play-overlay">
                  <div class="rank-play-btn">
                    <svg viewBox="0 0 24 24" width="18" height="18">
                      <path fill="currentColor" d="M8 5v14l11-7z"/>
                    </svg>
                  </div>
                </div>
              </div>
              <div class="rank-info">
                <span class="rank-title">{{ track.title }}</span>
                <span class="rank-artist"><ArtistLink :artist-id="track.artistId" :artist-name="track.artist" /></span>
              </div>
              <span class="rank-duration">{{ formatDuration(track.duration) }}</span>
              <div class="rank-controls">
                <button class="ctrl-btn" title="添加到歌单" @click.stop="showAddToPlaylist(track)">
                  <svg viewBox="0 0 24 24" width="16" height="16">
                    <path fill="currentColor" d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
                  </svg>
                </button>
                <button class="ctrl-btn comment-btn" title="查看评论" @click.stop="goToComments(track)">
                  <svg viewBox="0 0 24 24" width="16" height="16">
                    <path fill="currentColor" d="M21 6h-2v9H6v2c0 .55.45 1 1 1h11l4 4V7c0-.55-.45-1-1-1zm-4 6V3c0-.55-.45-1-1-1H3c-.55 0-1 .45-1 1v14l4-4h10c.55 0 1-.45 1-1z"/>
                  </svg>
                </button>
                <button 
                  class="ctrl-btn like-btn" 
                  :class="{ liked: isFavorite(track.id) }"
                  :title="isFavorite(track.id) ? '取消收藏' : '收藏'"
                  @click.stop="toggleFavorite(track)"
                >
                  <svg viewBox="0 0 24 24" width="16" height="16">
                    <path v-if="isFavorite(track.id)" fill="currentColor" d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                    <path v-else fill="currentColor" d="M16.5 3c-1.74 0-3.41.81-4.5 2.09C10.91 3.81 9.24 3 7.5 3 4.42 3 2 5.42 2 8.5c0 3.78 3.4 6.86 8.55 11.54L12 21.35l1.45-1.32C18.6 15.36 22 12.28 22 8.5 22 5.42 19.58 3 16.5 3zm-4.4 15.55l-.1.1-.1-.1C7.14 14.24 4 11.39 4 8.5 4 6.5 5.5 5 7.5 5c1.54 0 3.04.99 3.57 2.36h1.87C13.46 5.99 14.96 5 16.5 5c2 0 3.5 1.5 3.5 3.5 0 2.89-3.14 5.74-7.9 10.05z"/>
                  </svg>
                </button>
              </div>
              <span class="rank-plays">{{ formatPlayCount(track.playCount) }} 次播放</span>
            </div>
          </div>
        </section>

        <!-- 最新音乐 / 最多收藏 / 最多评论 -->
        <section class="section" v-if="['new', 'liked', 'comments'].includes(activeListTab)">
          <div class="section-header">
            <h2>{{ listTabTitle }}</h2>
          </div>
          <div class="track-list">
            <div 
              v-for="(track, index) in currentListTracks" 
              :key="track.id" 
              class="track-row slide-in-left"
              :style="{ animationDelay: `${index * 0.03}s` }"
              @click="playFromList(currentListTracks, track)"
            >
              <span class="index">{{ index + 1 }}</span>
              <div class="row-cover-wrapper">
                <img :src="track.coverUrl || defaultCover" alt="封面" class="row-cover" />
                <div class="row-play-overlay">
                  <div class="row-play-btn">
                    <svg viewBox="0 0 24 24" width="18" height="18">
                      <path fill="currentColor" d="M8 5v14l11-7z"/>
                    </svg>
                  </div>
                </div>
              </div>
              <div class="row-info">
                <span class="title">{{ track.title }}</span>
                <span class="artist"><ArtistLink :artist-id="track.artistId" :artist-name="track.artist" /></span>
              </div>
              <span class="duration">{{ formatDuration(track.duration) }}</span>
              <div class="row-controls">
                <button class="ctrl-btn" title="添加到歌单" @click.stop="showAddToPlaylist(track)">
                  <svg viewBox="0 0 24 24" width="16" height="16">
                    <path fill="currentColor" d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
                  </svg>
                </button>
                <button class="ctrl-btn comment-btn" title="查看评论" @click.stop="goToComments(track)">
                  <svg viewBox="0 0 24 24" width="16" height="16">
                    <path fill="currentColor" d="M21 6h-2v9H6v2c0 .55.45 1 1 1h11l4 4V7c0-.55-.45-1-1-1zm-4 6V3c0-.55-.45-1-1-1H3c-.55 0-1 .45-1 1v14l4-4h10c.55 0 1-.45 1-1z"/>
                  </svg>
                </button>
                <button 
                  class="ctrl-btn like-btn" 
                  :class="{ liked: isFavorite(track.id) }" 
                  :title="isFavorite(track.id) ? '取消收藏' : '收藏'" 
                  @click.stop="toggleFavorite(track)"
                >
                  <svg viewBox="0 0 24 24" width="16" height="16">
                    <path v-if="isFavorite(track.id)" fill="currentColor" d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                    <path v-else fill="currentColor" d="M16.5 3c-1.74 0-3.41.81-4.5 2.09C10.91 3.81 9.24 3 7.5 3 4.42 3 2 5.42 2 8.5c0 3.78 3.4 6.86 8.55 11.54L12 21.35l1.45-1.32C18.6 15.36 22 12.28 22 8.5 22 5.42 19.58 3 16.5 3zm-4.4 15.55l-.1.1-.1-.1C7.14 14.24 4 11.39 4 8.5 4 6.5 5.5 5 7.5 5c1.54 0 3.04.99 3.57 2.36h1.87C13.46 5.99 14.96 5 16.5 5c2 0 3.5 1.5 3.5 3.5 0 2.89-3.14 5.74-7.9 10.05z"/>
                  </svg>
                </button>
              </div>
            </div>
          </div>
          <div class="pagination-wrapper" v-if="currentListTotal > 0">
            <el-pagination
              background
              layout="prev, pager, next"
              :pager-count="7"
              :current-page="currentListPage"
              :page-size="listPageSize"
              :total="currentListTotal"
              :hide-on-single-page="false"
              @current-change="handleListPageChange"
            />
            <button class="last-page-btn" @click="goListLastPage" :disabled="currentListTotal === 0">
              末页
            </button>
          </div>
        </section>
      </div>
    </main>

    <!-- 创建歌单弹窗 -->
    <div v-if="showCreatePlaylist" class="modal" @click.self="showCreatePlaylist = false">
      <div class="modal-content">
        <h3>新建歌单</h3>
        <input v-model="newPlaylistName" type="text" placeholder="歌单名称" />
        <textarea v-model="newPlaylistDesc" placeholder="歌单描述（可选）"></textarea>
        <div class="modal-actions">
          <button @click="showCreatePlaylist = false">取消</button>
          <button class="primary" @click="createPlaylist">创建</button>
        </div>
      </div>
    </div>

    <!-- 头像裁剪对话框 -->
    <AvatarCropper
      v-model="showAvatarCropper"
      :image-url="cropperImageUrl"
      @confirm="handleAvatarConfirm"
    />

    <!-- 注销账号对话框 -->
    <el-dialog
      v-model="showDeleteDialog"
      title="注销账号"
      width="400px"
      :close-on-click-modal="false"
    >
      <div class="delete-warning">
        <svg viewBox="0 0 24 24" width="48" height="48" style="color: #f56c6c">
          <path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/>
        </svg>
        <p class="warning-text">警告：注销账号将永久删除您的所有数据，此操作不可恢复！</p>
      </div>
      <el-form :model="deleteForm" label-width="80px">
        <el-form-item label="账号">
          <el-input v-model="deleteForm.username" placeholder="请输入当前账号" />
        </el-form-item>
        <el-form-item label="密码">
          <el-input v-model="deleteForm.password" type="password" placeholder="请输入密码确认" show-password />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showDeleteDialog = false">取消</el-button>
        <el-button type="danger" @click="handleDeleteAccount" :loading="deleteLoading">确认注销</el-button>
      </template>
    </el-dialog>

    <!-- 新建歌单弹窗 -->
    <el-dialog
      v-model="showCreatePlaylist"
      title="新建歌单"
      width="450px"
      :close-on-click-modal="false"
      class="dark-dialog"
      modal-class="dark-modal"
    >
      <div class="create-playlist-form">
        <!-- 封面上传区域 -->
        <div class="cover-upload-section">
          <div class="cover-preview" @click="triggerCoverUpload">
            <img v-if="newPlaylistCover" :src="newPlaylistCover" alt="封面预览" />
            <img v-else :src="defaultCover" alt="默认封面" class="cover-default" />
          </div>
          <button v-if="newPlaylistCover" class="edit-cover-btn" @click="showCoverCropper = true">
            <svg viewBox="0 0 24 24" width="16" height="16">
              <path fill="currentColor" d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/>
            </svg>
            编辑照片
          </button>
          <input 
            ref="coverInputRef"
            type="file" 
            accept="image/*" 
            style="display: none" 
            @change="handleCoverSelect"
          />
        </div>
        <div class="form-group">
          <label>歌单名称 <span class="required">*</span></label>
          <input v-model="newPlaylistName" type="text" placeholder="请输入歌单名称" class="form-input" />
        </div>
        <div class="form-group">
          <label>歌单描述 <span class="optional">（可选）</span></label>
          <textarea v-model="newPlaylistDesc" placeholder="请输入歌单描述（可选）" class="form-textarea" rows="3"></textarea>
        </div>
      </div>
      <template #footer>
        <div class="dialog-footer-btns">
          <button class="btn-cancel" @click="showCreatePlaylist = false">取消</button>
          <button class="btn-create" @click="createPlaylist">创建</button>
        </div>
      </template>
    </el-dialog>

    <!-- 封面裁剪弹窗 -->
    <CoverCropper
      v-model="showCoverCropper"
      :image-url="coverCropperImageUrl"
      @confirm="handleCoverCropConfirm"
    />

    <!-- 添加到歌单弹窗 -->
    <el-dialog
      v-model="showAddToPlaylistDialog"
      title="添加到歌单"
      width="400px"
      :close-on-click-modal="false"
      class="dark-dialog"
      modal-class="dark-modal"
    >
      <div class="add-to-playlist-content">
        <div v-if="selectedTrack" class="selected-track-info">
          <img :src="selectedTrack.coverUrl || defaultCover" alt="封面" class="track-cover-small" />
          <div class="track-text">
            <span class="track-title">{{ selectedTrack.title }}</span>
            <span class="track-artist"><ArtistLink :artist-id="selectedTrack.artistId" :artist-name="selectedTrack.artist" /></span>
          </div>
        </div>
        <div class="playlist-options">
          <div class="playlist-option-header">选择歌单</div>
          <div 
            v-for="pl in myPlaylists" 
            :key="pl.id" 
            class="playlist-option-item"
            @click="addTrackToPlaylist(pl.id)"
          >
            <img :src="pl.coverUrl || defaultCover" alt="封面" class="pl-cover" />
            <div class="pl-info">
              <span class="pl-name">{{ pl.name }}</span>
              <span class="pl-count">{{ pl.trackCount || 0 }} 首</span>
            </div>
          </div>
          <div v-if="myPlaylists.length === 0" class="no-playlists">
            暂无歌单，请先创建歌单
          </div>
        </div>
      </div>
    </el-dialog>

    <!-- 评论弹窗 -->
    <el-drawer
      v-model="showCommentDrawer"
      :title="currentCommentTrack?.title + ' - 评论'"
      direction="rtl"
      size="450px"
      class="comment-drawer"
    >
      <div class="comment-container">
        <!-- 评论输入框 -->
        <div class="comment-input-area">
          <el-input
            v-model="newCommentContent"
            type="textarea"
            :rows="3"
            placeholder="发表你的想法..."
            maxlength="500"
            show-word-limit
          />
          <el-button 
            type="primary" 
            :disabled="!newCommentContent.trim()"
            :loading="submittingComment"
            @click="submitComment"
          >
            发表评论
          </el-button>
        </div>

        <!-- 评论列表 -->
        <div class="comment-list">
          <div class="comment-header">
            <span>全部评论 ({{ commentTotal }})</span>
          </div>

          <div v-if="loadingComments" class="loading-area">
            <el-icon class="is-loading"><Loading /></el-icon>
            <span>加载中...</span>
          </div>

          <template v-else>
            <div 
              v-for="comment in comments" 
              :key="comment.id" 
              class="comment-item"
            >
              <div class="comment-avatar" @click="goToUserProfile(comment.userId)">
                <img
                  :src="comment.userAvatar || defaultAvatar"
                  alt="头像"
                  @error="handleAvatarLoadError"
                />
              </div>
              <div class="comment-body">
                <div class="comment-header-row">
                  <span class="username" @click="goToUserProfile(comment.userId)">{{ comment.userNickname || comment.username || '用户' }}</span>
                  <span class="floor">#{{ comment.floor }}</span>
                </div>
                <p class="comment-content">{{ comment.content }}</p>
                <div class="comment-footer">
                  <span class="time">{{ formatCommentTime(comment.createdAt) }}</span>
                  <div class="actions">
                    <button class="action-btn" @click="likeComment(comment)">
                      <svg viewBox="0 0 24 24" width="14" height="14" :class="{ liked: comment.isLiked }">
                        <path fill="currentColor" d="M1 21h4V9H1v12zm22-11c0-1.1-.9-2-2-2h-6.31l.95-4.57.03-.32c0-.41-.17-.79-.44-1.06L14.17 1 7.59 7.59C7.22 7.95 7 8.45 7 9v10c0 1.1.9 2 2 2h9c.83 0 1.54-.5 1.84-1.22l3.02-7.05c.09-.23.14-.47.14-.73v-2z"/>
                      </svg>
                      <span v-if="comment.likeCount">{{ comment.likeCount }}</span>
                    </button>
                    <button class="action-btn" @click="replyToComment(comment)">
                      <svg viewBox="0 0 24 24" width="14" height="14">
                        <path fill="currentColor" d="M10 9V5l-7 7 7 7v-4.1c5 0 8.5 1.6 11 5.1-1-5-4-10-11-11z"/>
                      </svg>
                      回复
                    </button>
                    <button 
                      v-if="comment.userId === currentUserId" 
                      class="action-btn delete" 
                      @click="deleteMyComment(comment.id)"
                    >
                      删除
                    </button>
                  </div>
                </div>

                <!-- 回复列表 -->
                <div v-if="comment.replies && comment.replies.length > 0" class="replies-list">
                  <div 
                    v-for="reply in comment.replies" 
                    :key="reply.id" 
                    class="reply-item"
                  >
                    <div class="reply-avatar" @click="goToUserProfile(reply.userId)">
                      <img
                        :src="reply.userAvatar || defaultAvatar"
                        alt="头像"
                        @error="handleAvatarLoadError"
                      />
                    </div>
                    <div class="reply-content">
                      <div class="reply-header">
                        <span class="reply-user" @click="goToUserProfile(reply.userId)">{{ reply.userNickname || '用户' }}</span>
                        <span class="reply-text">{{ reply.content }}</span>
                      </div>
                      <div class="reply-meta">
                        <span class="reply-time">{{ formatCommentTime(reply.createdAt) }}</span>
                        <button 
                          v-if="reply.userId === currentUserId" 
                          class="delete-reply-btn"
                          @click="deleteReply(comment, reply.id)"
                        >
                          删除
                        </button>
                      </div>
                    </div>
                  </div>
                  <button 
                    v-if="comment.replyCount > (comment.replies?.length || 0)" 
                    class="more-replies"
                    @click="loadMoreReplies(comment)"
                  >
                    查看更多 {{ comment.replyCount - (comment.replies?.length || 0) }} 条回复
                  </button>
                </div>
              </div>
            </div>

            <div v-if="comments.length === 0" class="empty-comments">
              <svg viewBox="0 0 24 24" width="48" height="48">
                <path fill="currentColor" d="M21 6h-2v9H6v2c0 .55.45 1 1 1h11l4 4V7c0-.55-.45-1-1-1zm-4 6V3c0-.55-.45-1-1-1H3c-.55 0-1 .45-1 1v14l4-4h10c.55 0 1-.45 1-1z"/>
              </svg>
              <p>暂无评论，快来抢沙发吧~</p>
            </div>
          </template>
        </div>
      </div>

      <!-- 回复弹窗 -->
      <template v-if="replyingTo">
        <div class="reply-input-area">
          <div class="reply-header">
            <span>回复 @{{ replyingTo.userNickname || '用户' }}</span>
            <button class="cancel-reply" @click="cancelReply">取消</button>
          </div>
          <el-input
            v-model="replyContent"
            type="textarea"
            :rows="2"
            placeholder="写下你的回复..."
          />
          <el-button 
            type="primary" 
            size="small"
            :disabled="!replyContent.trim()"
            :loading="submittingReply"
            @click="submitReply"
          >
            发送
          </el-button>
        </div>
      </template>
    </el-drawer>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, onBeforeUnmount, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Loading } from '@element-plus/icons-vue'
import { useUserStore } from '../stores/user'
import { usePlayerStore } from '../stores/player'
import { trackApi, playlistApi, favoriteApi, userApi, commentApi, announcementApi, notificationApi, type NotificationItem } from '../api'
import { useTheme } from '../composables/useTheme'
// @ts-ignore
import AvatarCropper from '../components/AvatarCropper.vue'
// @ts-ignore
import CoverCropper from '../components/CoverCropper.vue'
import ArtistLink from '../components/ArtistLink.vue'

const router = useRouter()
const userStore = useUserStore()
const playerStore = usePlayerStore()
const { theme, toggle: toggleTheme, isDark } = useTheme()
const themeLabel = computed(() => isDark() ? '浅色模式' : '深色模式')

// 榜单列表计算属性
const currentListTracks = computed(() => {
  if (activeListTab.value === 'new') return newTracks.value
  if (activeListTab.value === 'liked') return mostLikedTracks.value
  if (activeListTab.value === 'comments') return mostCommentedTracks.value
  return []
})
const currentListTotal = computed(() => {
  if (activeListTab.value === 'new') return newTotal.value
  if (activeListTab.value === 'liked') return likedTotal.value
  if (activeListTab.value === 'comments') return commentedTotal.value
  return 0
})
const currentListPage = computed(() => listPage.value)
const listTabTitle = computed(() => {
  const m: Record<string, string> = { new: '最新音乐', liked: '最多收藏', comments: '最多评论' }
  return m[activeListTab.value] || ''
})

// 默认头像URL
import { DEFAULT_AVATAR_COVER } from '../constants'
const defaultAvatar = DEFAULT_AVATAR_COVER
const defaultCover = DEFAULT_AVATAR_COVER

// 下拉菜单状态
const showDropdown = ref(false)

// 消息通知
const notificationRef = ref<HTMLElement>()
const showNotificationPanel = ref(false)
const notifications = ref<NotificationItem[]>([])
const notificationUnreadCount = ref(0)

const fetchNotifications = async () => {
  try {
    const res = await notificationApi.getList(1, 20)
    if (res.data?.code === 200 && res.data?.data) {
      const d = res.data.data as any
      notifications.value = d.records || []
      notificationUnreadCount.value = d.unreadCount ?? 0
    }
  } catch (e) {
    console.error('Fetch notifications error:', e)
  }
}

const fetchUnreadCount = async () => {
  try {
    const res = await notificationApi.getUnreadCount()
    if (res.data?.code === 200) notificationUnreadCount.value = res.data.data ?? 0
  } catch (_) {}
}

const toggleNotificationPanel = () => {
  showNotificationPanel.value = !showNotificationPanel.value
  if (showNotificationPanel.value) fetchNotifications()
}

const markNotificationsRead = async () => {
  try {
    await notificationApi.markAllRead()
    notificationUnreadCount.value = 0
    fetchNotifications()
  } catch (e) {
    console.error('Mark read error:', e)
  }
}

const handleNotificationClick = (n: NotificationItem) => {
  showNotificationPanel.value = false
  if (notificationUnreadCount.value > 0) markNotificationsRead()
  if (n.type === 'FOLLOW' && n.fromUserId) {
    router.push(`/profile/${n.fromUserId}`)
  } else if (n.extra) {
    router.push(`/track/${n.extra}`)
  }
}

const formatNotificationText = (n: NotificationItem) => {
  const name = n.fromUserNickname || '某人'
  if (n.type === 'FOLLOW') return `${name} 关注了你`
  if (n.type === 'COMMENT_REPLY') return `${name} 回复了你的评论`
  if (n.type === 'LIKE') return `${name} 赞了你的评论`
  return ''
}

const formatNotificationTime = (t: string) => {
  if (!t) return ''
  const d = new Date(t)
  const now = new Date()
  const diff = now.getTime() - d.getTime()
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
  if (diff < 604800000) return `${Math.floor(diff / 86400000)}天前`
  return d.toLocaleDateString('zh-CN')
}

// 头像上传相关
const avatarInputRef = ref<HTMLInputElement>()
const showAvatarCropper = ref(false)
const cropperImageUrl = ref('')

// 注销账号相关
const showDeleteDialog = ref(false)
const deleteLoading = ref(false)
const deleteForm = ref({
  username: '',
  password: ''
})

// 用户信息计算属性
const displayName = computed(() => {
  const user = userStore.currentUser as any
  return user?.nickname || user?.username || '用户'
})

// 用户头像
const userAvatar = computed(() => {
  const user = userStore.currentUser as any
  return user?.avatar || defaultAvatar
})

const searchKeyword = ref('')
const showSearchHistory = ref(false)
const searchBoxRef = ref<HTMLElement>()
const SEARCH_HISTORY_KEY = 'yinbo_search_history'
const searchHistoryVersion = ref(0)

const searchHistoryList = computed(() => {
  searchHistoryVersion.value // 依赖，删除单条后触发更新
  try {
    const saved = localStorage.getItem(SEARCH_HISTORY_KEY)
    return saved ? JSON.parse(saved) as string[] : []
  } catch { return [] }
})

const addSearchHistory = (keyword: string) => {
  const list = searchHistoryList.value.filter(k => k !== keyword)
  list.unshift(keyword)
  if (list.length > 15) list.length = 15
  localStorage.setItem(SEARCH_HISTORY_KEY, JSON.stringify(list))
  searchHistoryVersion.value++
}

const clearSearchHistory = () => {
  localStorage.removeItem(SEARCH_HISTORY_KEY)
  searchHistoryVersion.value++
  showSearchHistory.value = false
}

const removeSearchHistoryItem = (keyword: string) => {
  const list = searchHistoryList.value.filter(k => k !== keyword)
  if (list.length > 0) {
    localStorage.setItem(SEARCH_HISTORY_KEY, JSON.stringify(list))
  } else {
    localStorage.removeItem(SEARCH_HISTORY_KEY)
    showSearchHistory.value = false
  }
  searchHistoryVersion.value++
}

const searchFromHistory = (keyword: string) => {
  searchKeyword.value = keyword
  showSearchHistory.value = false
  handleSearch()
}

// 侧边栏开关
const isSidebarOpen = ref(true)
const activeAnnouncement = ref<any>(null)
const activeListTab = ref<'ranking' | 'new' | 'liked' | 'comments'>('ranking')
const rankingTracks = ref<any[]>([])
// 热门推荐：每次随机 8 首
const HOT_SIZE = 8
const hotTracks = ref<any[]>([])
const newTracks = ref<any[]>([])
const mostLikedTracks = ref<any[]>([])
const mostCommentedTracks = ref<any[]>([])
// 榜单列表分页
const listPage = ref(1)
const listPageSize = ref(10)
const newTotal = ref(0)
const likedTotal = ref(0)
const commentedTotal = ref(0)
const myPlaylists = ref<any[]>([])
const favorites = ref<number[]>([])

const showCreatePlaylist = ref(false)
const newPlaylistName = ref('')
const newPlaylistDesc = ref('')
const newPlaylistCover = ref('')
const newPlaylistCoverFile = ref<File | null>(null)
const coverInputRef = ref<HTMLInputElement>()
const showCoverCropper = ref(false)
const coverCropperImageUrl = ref('')

// 侧边栏切换
const toggleSidebar = () => {
  isSidebarOpen.value = !isSidebarOpen.value
}

// 下拉菜单切换
const toggleDropdown = () => {
  showDropdown.value = !showDropdown.value
}

// 点击外部关闭下拉菜单与通知面板
const handleClickOutside = (e: MouseEvent) => {
  const target = e.target as HTMLElement
  if (!target.closest('.nickname-section') && !target.closest('.avatar-wrapper')) {
    showDropdown.value = false
  }
  if (!target.closest('.notification-bell-wrap')) {
    showNotificationPanel.value = false
  }
  if (searchBoxRef.value && !searchBoxRef.value.contains(target)) {
    showSearchHistory.value = false
  }
}

// 触发头像上传
const triggerAvatarUpload = () => {
  avatarInputRef.value?.click()
}

// 触发封面选择
const triggerCoverUpload = () => {
  coverInputRef.value?.click()
}

// 处理封面选择
const handleCoverSelect = (e: Event) => {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  
  // 预览并打开裁剪
  const reader = new FileReader()
  reader.onload = (event) => {
    coverCropperImageUrl.value = event.target?.result as string
    showCoverCropper.value = true
  }
  reader.readAsDataURL(file)
  // 清空input以便重复选择同一文件
  ;(e.target as HTMLInputElement).value = ''
}

// 处理封面裁剪确认
const handleCoverCropConfirm = (blob: Blob) => {
  newPlaylistCoverFile.value = new File([blob], 'cover.jpg', { type: 'image/jpeg' })
  // 创建预览URL
  const reader = new FileReader()
  reader.onload = (event) => {
    newPlaylistCover.value = event.target?.result as string
  }
  reader.readAsDataURL(blob)
  showCoverCropper.value = false
}

// 处理头像文件选择
const handleAvatarChange = (e: Event) => {
  const input = e.target as HTMLInputElement
  const file = input.files?.[0]
  if (file) {
    if (!file.type.startsWith('image/')) {
      ElMessage.error('请选择图片文件')
      return
    }
    if (file.size > 5 * 1024 * 1024) {
      ElMessage.error('图片大小不能超过5MB')
      return
    }
    const reader = new FileReader()
    reader.onload = (e) => {
      cropperImageUrl.value = e.target?.result as string
      showAvatarCropper.value = true
    }
    reader.readAsDataURL(file)
  }
  input.value = ''
}

// 处理头像裁剪确认
const handleAvatarConfirm = async (blob: Blob) => {
  try {
    const file = new File([blob], 'avatar.jpg', { type: 'image/jpeg' })
    
    const res = await userApi.uploadAvatar(file)
    if (res.data.code === 200) {
      const userRes = await userApi.getUserInfo()
      if (userRes.data.code === 200) {
        userStore.setUser(userRes.data.data)
      }
      ElMessage.success('头像更新成功')
    } else {
      ElMessage.error(res.data.message || '头像更新失败')
    }
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '头像上传失败')
  }
}

// 处理菜单点击
const handleMenuClick = (action: string) => {
  showDropdown.value = false
  
  switch (action) {
    case 'profile':
      router.push('/profile')
      break
    case 'history':
      router.push({ path: '/profile', query: { tab: 'history' } })
      break
    case 'comments':
      router.push('/profile?tab=comments')
      break
    case 'settings':
      router.push('/settings')
      break
    case 'theme':
      toggleTheme()
      break
    case 'switch':
      userStore.logout()
      router.push('/login')
      break
    case 'delete':
      // 打开注销对话框
      const currentUser = userStore.currentUser as any
      deleteForm.value.username = currentUser?.username || ''
      deleteForm.value.password = ''
      showDeleteDialog.value = true
      break
  }
}

// 注销账号
const handleDeleteAccount = async () => {
  // 验证输入
  if (!deleteForm.value.username.trim()) {
    ElMessage.warning('请输入账号')
    return
  }
  if (!deleteForm.value.password) {
    ElMessage.warning('请输入密码')
    return
  }
  
  // 验证账号是否匹配当前用户
  const currentUser = userStore.currentUser as any
  if (deleteForm.value.username !== currentUser?.username) {
    ElMessage.error('账号输入错误，请输入当前登录的账号')
    return
  }
  
  try {
    deleteLoading.value = true
    const res = await userApi.deleteAccount({
      username: deleteForm.value.username,
      password: deleteForm.value.password
    })
    
    if (res.data.code === 200) {
      ElMessage.success('账号已成功注销')
      showDeleteDialog.value = false
      // 清除用户状态并跳转到登录页
      userStore.logout()
      router.push('/')
    } else {
      ElMessage.error(res.data.message || '注销失败')
    }
  } catch (e: any) {
    const errorMsg = e.response?.data?.message || '注销失败，请稍后重试'
    ElMessage.error(errorMsg)
  } finally {
    deleteLoading.value = false
  }
}

// 加载热门音乐
const loadAnnouncements = async () => {
  try {
    const res = await announcementApi.getActive()
    if (res.data.code === 200 && res.data.data?.length > 0) {
      activeAnnouncement.value = res.data.data[0]
    }
  } catch (e) {
    console.error('Failed to load announcements:', e)
  }
}

const loadRanking = async () => {
  try {
    const res = await trackApi.getHot(1, 10)
    if (res.data.code === 200) {
      rankingTracks.value = res.data.data.records || []
    }
  } catch (e) {
    console.error('Failed to load ranking:', e)
  }
}

const playFromList = (list: any[], track: any) => {
  playerStore.setPlaylistAndPlay(list, track)
}

const formatPlayCount = (count: number) => {
  if (!count) return '0'
  if (count >= 10000) return (count / 10000).toFixed(1) + '万'
  return String(count)
}

// 榜单切换
const switchListTab = (tab: 'ranking' | 'new' | 'liked' | 'comments') => {
  activeListTab.value = tab
  listPage.value = 1
  if (tab === 'new') loadNewTracks(1)
  else if (tab === 'liked') loadMostLikedTracks(1)
  else if (tab === 'comments') loadMostCommentedTracks(1)
}

const loadMostLikedTracks = async (page = 1) => {
  try {
    listPage.value = page
    const res = await trackApi.getMostLiked(page, listPageSize.value)
    if (res.data.code === 200) {
      mostLikedTracks.value = res.data.data?.records || []
      likedTotal.value = res.data.data?.total || 0
    }
  } catch (e) {
    console.error('Failed to load most liked tracks:', e)
    mostLikedTracks.value = []
  }
}

const loadMostCommentedTracks = async (page = 1) => {
  try {
    listPage.value = page
    const res = await trackApi.getMostCommented(page, listPageSize.value)
    if (res.data.code === 200) {
      mostCommentedTracks.value = res.data.data?.records || []
      commentedTotal.value = res.data.data?.total || 0
    }
  } catch (e) {
    console.error('Failed to load most commented tracks:', e)
    mostCommentedTracks.value = []
  }
}

// 加载热门推荐：随机 8 首
const loadHotTracks = async () => {
  try {
    const res = await trackApi.getHot(1, HOT_SIZE, true)
    if (res.data.code === 200) {
      const records = res.data.data?.records || []
      hotTracks.value = records
    }
  } catch (e) {
    console.error('Failed to load hot tracks:', e)
    hotTracks.value = []
  }
}

// 换一批：重新随机 8 首
const refreshHotTracks = () => {
  loadHotTracks()
}

// 加载最新音乐
const loadNewTracks = async (page = 1) => {
  try {
    listPage.value = page
    const res = await trackApi.getNew(page, listPageSize.value)
    if (res.data.code === 200) {
      const data = res.data.data
      newTracks.value = data?.records || []
      newTotal.value = data?.total || 0
    }
  } catch (e) {
    console.error('Failed to load new tracks:', e)
    newTracks.value = []
  }
}

// 榜单列表分页切换
const handleListPageChange = (page: number) => {
  if (activeListTab.value === 'new') loadNewTracks(page)
  else if (activeListTab.value === 'liked') loadMostLikedTracks(page)
  else if (activeListTab.value === 'comments') loadMostCommentedTracks(page)
}

const goListLastPage = () => {
  const total = currentListTotal.value
  if (total <= 0) return
  const last = Math.max(1, Math.ceil(total / listPageSize.value))
  handleListPageChange(last)
}

// 加载我的歌单
const loadMyPlaylists = async () => {
  if (!userStore.currentUser) return
  try {
    const res = await playlistApi.getMyPlaylists()
    if (res.data.code === 200) {
      myPlaylists.value = res.data.data.records || []
    }
  } catch (e) {
    console.error('Failed to load playlists:', e)
  }
}

// 加载收藏
const loadFavorites = async () => {
  if (!userStore.currentUser) return
  try {
    const res = await favoriteApi.getMyFavorites()
    if (res.data.code === 200) {
      const trackIds = (res.data.data.records || []).map((t: any) => t.id)
      // 同步到 userStore
      trackIds.forEach((id: number) => userStore.addFavorite(id))
    }
  } catch (e) {
    console.error('Failed to load favorites:', e)
  }
}

// 播放音乐
const playTrack = (track: any) => {
  playerStore.setCurrentTrack(track)
  playerStore.play()
}

// 从热门歌曲列表播放（设置整个播放列表）
const playFromHotTracks = (track: any) => {
  playerStore.setPlaylistAndPlay(hotTracks.value, track)
}

// 从最新歌曲列表播放（设置整个播放列表）
const playFromNewTracks = (track: any) => {
  playerStore.setPlaylistAndPlay(newTracks.value, track)
}

// 搜索
const handleSearch = () => {
  if (searchKeyword.value.trim()) {
    addSearchHistory(searchKeyword.value.trim())
    showSearchHistory.value = false
    router.push(`/search?keyword=${encodeURIComponent(searchKeyword.value)}`)
  }
}

// 跳转歌单
const goToPlaylist = (id: number) => {
  router.push(`/playlist/${id}`)
}

// 创建歌单
const createPlaylist = async () => {
  if (!newPlaylistName.value.trim()) return
  try {
    let res
    if (newPlaylistCoverFile.value) {
      // 有封面，使用带封面的创建接口
      res = await playlistApi.createWithCover(
        { name: newPlaylistName.value, description: newPlaylistDesc.value },
        newPlaylistCoverFile.value
      )
    } else {
      // 无封面
      res = await playlistApi.create({ 
        name: newPlaylistName.value,
        description: newPlaylistDesc.value 
      })
    }
    if (res.data.code === 200) {
      myPlaylists.value.unshift(res.data.data)
      showCreatePlaylist.value = false
      newPlaylistName.value = ''
      newPlaylistDesc.value = ''
      newPlaylistCover.value = ''
      newPlaylistCoverFile.value = null
      ElMessage.success('歌单创建成功')
    }
  } catch (e) {
    console.error('Failed to create playlist:', e)
    ElMessage.error('创建失败，请重试')
  }
}

// 收藏/取消收藏
const toggleFavorite = async (track: any) => {
  if (!userStore.currentUser) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }
  
  if (!track || !track.id) {
    ElMessage.error('歌曲信息无效')
    return
  }
  
  try {
    console.log('Toggle favorite for track:', track.id)
    if (userStore.favorites.includes(track.id)) {
      await favoriteApi.remove(track.id)
      userStore.removeFavorite(track.id)
      ElMessage.success('已取消收藏')
    } else {
      await favoriteApi.add(track.id)
      userStore.addFavorite(track.id)
      ElMessage.success('收藏成功')
    }
  } catch (e: any) {
    console.error('Failed to toggle favorite:', e)
    const errorMsg = e.response?.data?.message || e.message || '操作失败'
    ElMessage.error(errorMsg)
  }
}

// 是否收藏 - 使用 userStore 同步
const isFavorite = (trackId: number) => {
  return userStore.favorites.includes(trackId)
}

// 添加到歌单相关
const showAddToPlaylistDialog = ref(false)
const selectedTrack = ref<any>(null)
const addToPlaylistLoading = ref(false)

const showAddToPlaylist = (track: any) => {
  if (!userStore.currentUser) {
    router.push('/login')
    return
  }
  selectedTrack.value = track
  showAddToPlaylistDialog.value = true
}

const addTrackToPlaylist = async (playlistId: number) => {
  if (!selectedTrack.value) return
  
  addToPlaylistLoading.value = true
  try {
    await playlistApi.addTrack(playlistId, selectedTrack.value.id)
    ElMessage.success('已添加到歌单')
    showAddToPlaylistDialog.value = false
  } catch (e) {
    console.error('Failed to add track to playlist:', e)
    ElMessage.error('添加失败')
  } finally {
    addToPlaylistLoading.value = false
  }
}

// 评论相关
const showCommentDrawer = ref(false)
const comments = ref<any[]>([])
const commentTotal = ref(0)
const loadingComments = ref(false)
const currentCommentTrack = ref<any>(null)
const newCommentContent = ref('')
const submittingComment = ref(false)
const replyingTo = ref<any>(null)
const replyContent = ref('')
const submittingReply = ref(false)
const currentUserId = computed(() => userStore.currentUser?.id)
const commentTimer = ref<number | null>(null)

const normalizeReply = (reply: any) => {
  const user = reply?.user || {}
  return {
    ...reply,
    userId: reply?.userId ?? user?.id ?? 0,
    userAvatar: reply?.userAvatar || reply?.avatar || user?.avatar || defaultAvatar,
    userNickname:
      reply?.userNickname ||
      reply?.nickname ||
      reply?.userName ||
      reply?.username ||
      user?.nickname ||
      user?.username ||
      '用户'
  }
}

const normalizeComment = (comment: any, index: number) => {
  const user = comment?.user || {}
  const replies = Array.isArray(comment?.replies) ? comment.replies.map((reply: any) => normalizeReply(reply)) : []
  return {
    ...comment,
    userId: comment?.userId ?? user?.id ?? 0,
    userAvatar: comment?.userAvatar || comment?.avatar || user?.avatar || defaultAvatar,
    userNickname:
      comment?.userNickname ||
      comment?.nickname ||
      comment?.userName ||
      comment?.username ||
      user?.nickname ||
      user?.username ||
      '用户',
    floor: comment?.floor ?? comment?.floorNumber ?? index + 1,
    replies
  }
}

const handleAvatarLoadError = (event: Event) => {
  const target = event.target as HTMLImageElement
  target.onerror = null
  target.src = defaultAvatar
}

// 打开评论弹窗 - 仅查看评论，不播放歌曲
const goToComments = async (track: any) => {
  currentCommentTrack.value = track
  showCommentDrawer.value = true
  await loadCommentsForTrack(track.id)
}

// 打开评论弹窗
const openCommentDrawer = async (track: any) => {
  currentCommentTrack.value = track
  showCommentDrawer.value = true
  await loadCommentsForTrack(track.id)
}

// 加载指定歌曲的评论
const loadCommentsForTrack = async (trackId: number) => {
  loadingComments.value = true
  try {
    const res = await commentApi.getList(trackId)
    if (res.data.code === 200) {
      const records = res.data.data.records || []
      comments.value = records.map((item: any, index: number) => normalizeComment(item, index))
      commentTotal.value = res.data.data.total || 0
    }
  } catch (e) {
    console.error('Load comments error:', e)
  } finally {
    loadingComments.value = false
  }
}

// 格式化评论时间
const formatCommentTime = (time: string) => {
  if (!time) return ''
  const date = new Date(time)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
  if (diff < 2592000000) return `${Math.floor(diff / 86400000)}天前`
  
  return `${date.getMonth() + 1}月${date.getDate()}日`
}

// 发表评论
const submitComment = async () => {
  if (!userStore.currentUser) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }
  
  if (!currentCommentTrack.value || !newCommentContent.value.trim()) return
  
  submittingComment.value = true
  try {
    const res = await commentApi.create({
      trackId: currentCommentTrack.value.id,
      content: newCommentContent.value.trim()
    })
    if (res.data.code === 200) {
      ElMessage.success('评论发布成功')
      newCommentContent.value = ''
      await loadCommentsForTrack(currentCommentTrack.value.id)
    }
  } catch (e: any) {
    console.error('Submit comment error:', e)
    ElMessage.error(e.response?.data?.message || '评论失败')
  } finally {
    submittingComment.value = false
  }
}

// 点赞评论
const likeComment = async (comment: any) => {
  if (!userStore.currentUser) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }

  const oldLiked = !!comment.isLiked
  const oldCount = comment.likeCount || 0

  try {
    if (oldLiked) {
      await commentApi.unlike(comment.id)
      comment.isLiked = false
      comment.likeCount = Math.max(0, oldCount - 1)
    } else {
      await commentApi.like(comment.id)
      comment.isLiked = true
      comment.likeCount = oldCount + 1
    }
  } catch (e: any) {
    comment.isLiked = oldLiked
    comment.likeCount = oldCount
    console.error('Like comment error:', e)
    const msg = e?.response?.data?.message || e?.message
    ElMessage.error(msg || '操作失败，请稍后重试')
  }
}

// 回复评论
const replyToComment = (comment: any) => {
  replyingTo.value = comment
  replyContent.value = ''
}

// 取消回复
const cancelReply = () => {
  replyingTo.value = null
  replyContent.value = ''
}

// 提交回复（统一回复到楼层，避免无限嵌套）
const submitReply = async () => {
  if (!replyingTo.value || !replyContent.value.trim()) return
  if (!currentCommentTrack.value) return
  
  const rootId = replyingTo.value.parentId ?? replyingTo.value.id
  const isReplyToReply = replyingTo.value.parentId != null
  const nickname = replyingTo.value.userNickname || replyingTo.value.nickname || replyingTo.value.username || '用户'
  const content = isReplyToReply
    ? `回复 @${nickname}: ${replyContent.value.trim()}`
    : replyContent.value.trim()
  
  submittingReply.value = true
  try {
    const res = await commentApi.create({
      trackId: currentCommentTrack.value.id,
      content,
      parentId: rootId,
      replyToUserId: isReplyToReply ? replyingTo.value.userId : undefined
    })
    if (res.data.code === 200) {
      ElMessage.success('回复发布成功')
      cancelReply()
      await loadCommentsForTrack(currentCommentTrack.value.id)
    }
  } catch (e: any) {
    console.error('Submit reply error:', e)
    const msg = e?.response?.data?.message || e?.message
    ElMessage.error(msg || '回复失败')
  } finally {
    submittingReply.value = false
  }
}

// 删除评论
const deleteMyComment = async (commentId: number) => {
  try {
    await commentApi.delete(commentId)
    comments.value = comments.value.filter(c => c.id !== commentId)
    commentTotal.value--
    ElMessage.success('评论已删除')
  } catch (e) {
    console.error('Delete comment error:', e)
    ElMessage.error('删除失败')
  }
}

// 删除回复
const deleteReply = async (comment: any, replyId: number) => {
  try {
    await commentApi.delete(replyId)
    if (comment.replies) {
      comment.replies = comment.replies.filter((r: any) => r.id !== replyId)
    }
    comment.replyCount = Math.max(0, (comment.replyCount || 0) - 1)
    ElMessage.success('回复已删除')
  } catch (e) {
    console.error('Delete reply error:', e)
    ElMessage.error('删除失败')
  }
}

// 加载更多回复
const loadMoreReplies = async (comment: any) => {
  try {
    const res = await commentApi.getReplies(comment.id)
    if (res.data.code === 200) {
      comment.replies = (res.data.data.records || []).map((reply: any) => normalizeReply(reply))
    }
  } catch (e) {
    console.error('Load replies error:', e)
  }
}

// 跳转到用户主页
const goToUserProfile = (userId: number) => {
  if (userId === userStore.currentUser?.id) {
    router.push('/profile')
  } else {
    router.push(`/profile/${userId}`)
  }
}

const startCommentAutoRefresh = () => {
  stopCommentAutoRefresh()
  commentTimer.value = window.setInterval(() => {
    if (showCommentDrawer.value && currentCommentTrack.value) {
      loadCommentsForTrack(currentCommentTrack.value.id)
    }
  }, 10000)
}

const stopCommentAutoRefresh = () => {
  if (commentTimer.value !== null) {
    window.clearInterval(commentTimer.value)
    commentTimer.value = null
  }
}

// 格式化时长
const formatDuration = (seconds: number) => {
  if (!seconds) return '0:00'
  const mins = Math.floor(seconds / 60)
  const secs = seconds % 60
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

let notificationPollTimer: ReturnType<typeof setInterval> | null = null

const onVisibilityChange = () => {
  if (document.visibilityState === 'visible' && userStore.currentUser) fetchUnreadCount()
}

onMounted(() => {
  loadAnnouncements()
  loadRanking()
  loadHotTracks()
  if (userStore.currentUser) {
    loadMyPlaylists()
    loadFavorites()
    fetchUnreadCount()
    notificationPollTimer = setInterval(fetchUnreadCount, 30000)
  }
  document.addEventListener('click', handleClickOutside)
  document.addEventListener('visibilitychange', onVisibilityChange)
})

watch(() => userStore.currentUser, (user) => {
  if (user) {
    fetchUnreadCount()
    if (notificationPollTimer) clearInterval(notificationPollTimer)
    notificationPollTimer = setInterval(fetchUnreadCount, 30000)
  } else {
    notificationUnreadCount.value = 0
    if (notificationPollTimer) {
      clearInterval(notificationPollTimer)
      notificationPollTimer = null
    }
  }
})

onBeforeUnmount(() => {
  document.removeEventListener('click', handleClickOutside)
  document.removeEventListener('visibilitychange', onVisibilityChange)
  stopCommentAutoRefresh()
  if (notificationPollTimer) {
    clearInterval(notificationPollTimer)
    notificationPollTimer = null
  }
})
</script>


<style scoped>
.home-page {
  min-height: 100vh;
  background: var(--bg-primary);
  color: var(--text-primary);
  display: flex;
  flex-direction: column;
}

.top-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--sp-3) var(--sp-8);
  background: var(--bg-secondary);
  backdrop-filter: blur(10px);
  position: sticky;
  top: 0;
  z-index: var(--z-dropdown);
  border-bottom: 1px solid var(--border);
}

.logo {
  display: flex;
  align-items: center;
  gap: var(--sp-2);
}

.logo-text {
  font-size: var(--text-xl);
  font-weight: bold;
  color: var(--accent);
}

.search-box {
  display: flex;
  align-items: center;
  background: var(--bg-hover);
  border-radius: var(--radius-full);
  padding: 0 var(--sp-4);
  width: 300px;
  position: relative;
}

.search-box input {
  flex: 1;
  background: transparent;
  border: none;
  padding: 10px 0;
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
  padding: 5px;
}

.search-dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  margin-top: 6px;
  background: var(--bg-elevated);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  padding: var(--sp-2) 0;
  z-index: var(--z-sticky);
  max-height: 340px;
  overflow-y: auto;
  border: 1px solid var(--border);
}

.search-dropdown-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--sp-2) var(--sp-4);
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

.clear-history-btn {
  background: none;
  border: none;
  color: var(--text-tertiary);
  font-size: var(--text-xs);
  cursor: pointer;
  padding: 2px 6px;
  border-radius: var(--radius-sm);
}

.clear-history-btn:hover {
  color: var(--red);
  background: rgba(239, 68, 68, 0.1);
}

.search-history-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px var(--sp-4);
  font-size: var(--text-base);
  color: var(--text-primary);
  cursor: pointer;
  transition: background var(--dur-fast);
}

.search-history-item span {
  flex: 1;
  min-width: 0;
}

.search-history-item:hover {
  background: var(--bg-hover);
}

.history-delete-btn {
  flex-shrink: 0;
  width: 22px;
  height: 22px;
  padding: 0;
  border: none;
  background: transparent;
  color: var(--text-tertiary);
  font-size: 18px;
  line-height: 1;
  cursor: pointer;
  border-radius: var(--radius-sm);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: color var(--dur-fast), background var(--dur-fast);
}

.history-delete-btn:hover {
  color: var(--red);
  background: var(--bg-hover);
}

.user-area {
  display: flex;
  align-items: center;
  gap: 15px;
}

.login-btn {
  padding: var(--sp-2) var(--sp-5);
  background: var(--accent);
  border-radius: var(--radius-full);
  color: var(--text-primary);
  text-decoration: none;
  font-size: var(--text-base);
  transition: all var(--dur-normal);
}

.login-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 4px 12px var(--accent-glow);
}

.user-section {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
}

/* 消息通知铃铛 */
.notification-bell-wrap {
  position: relative;
}

.notification-bell {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  background: transparent;
  color: var(--text-secondary);
  cursor: pointer;
  border-radius: 50%;
  transition: all var(--dur-normal);
}
.notification-bell:hover {
  color: var(--text-primary);
  background: var(--bg-hover);
}

.notification-dot {
  position: absolute;
  top: 2px;
  right: 2px;
  min-width: 16px;
  height: 16px;
  padding: 0 4px;
  font-size: 10px;
  line-height: 16px;
  text-align: center;
  background: #ef4444;
  color: #fff;
  border-radius: 8px;
}

.notification-panel {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: 8px;
  width: 360px;
  max-height: 400px;
  background: var(--bg-elevated);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  border: 1px solid var(--border);
  z-index: 1000;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.notification-panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  border-bottom: 1px solid var(--border);
  font-weight: 600;
  font-size: 14px;
  color: var(--text-primary);
}

.panel-header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.view-all-btn {
  font-size: 12px;
  color: var(--accent);
  text-decoration: none;
}

.view-all-btn:hover {
  text-decoration: underline;
}

.mark-read-btn {
  font-size: 12px;
  color: var(--accent);
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px 8px;
}
.mark-read-btn:hover {
  text-decoration: underline;
}

.notification-list {
  flex: 1;
  overflow-y: auto;
  max-height: 320px;
}

.notification-item {
  display: flex;
  gap: 12px;
  padding: 12px 16px;
  cursor: pointer;
  transition: background var(--dur-fast);
  border-bottom: 1px solid var(--border);
}
.notification-item.unread {
  background: var(--bg-hover);
}
.notification-item:hover {
  background: var(--bg-hover);
}

.n-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  flex-shrink: 0;
}

.n-content {
  flex: 1;
  min-width: 0;
}

.n-text {
  margin: 0 0 4px;
  font-size: 14px;
  color: var(--text-primary);
  line-height: 1.4;
}

.n-time {
  font-size: 12px;
  color: var(--text-secondary);
}

.notification-empty {
  padding: 32px 16px;
  text-align: center;
  color: var(--text-secondary);
  font-size: 14px;
}

.avatar-wrapper {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  overflow: hidden;
  flex-shrink: 0;
  position: relative;
  cursor: pointer;
  border: 2px solid var(--border-hover);
  transition: all var(--dur-normal);
}

.avatar-wrapper:hover {
  border-color: var(--accent);
  transform: scale(1.05);
}

.avatar-wrapper:hover .avatar-overlay {
  opacity: 1;
}

.user-avatar {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity var(--dur-normal);
}

.nickname-section {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 6px 10px;
  border-radius: var(--radius-md);
  cursor: pointer;
  position: relative;
  transition: background var(--dur-normal);
}

.nickname-section:hover {
  background: var(--bg-hover);
}

.nickname-text {
  font-size: var(--text-base);
  color: var(--text-primary);
  font-weight: 500;
  max-width: 100px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.role-badge {
  padding: 4px 10px;
  background: var(--accent);
  border-radius: var(--radius-md);
  font-size: var(--text-xs);
  color: var(--text-primary);
  flex-shrink: 0;
}

.dropdown-arrow {
  color: var(--text-secondary);
  transition: transform var(--dur-normal);
}

.dropdown-arrow.rotated {
  transform: rotate(180deg);
}

.dropdown-menu {
  position: absolute;
  top: 100%;
  right: 0;
  margin-top: var(--sp-2);
  background: var(--bg-elevated);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg);
  min-width: 160px;
  padding: var(--sp-2) 0;
  overflow: hidden;
  z-index: 1000;
  border: 1px solid var(--border);
}

.dropdown-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px var(--sp-4);
  color: var(--text-primary);
  font-size: var(--text-base);
  cursor: pointer;
  transition: background var(--dur-fast);
}

.dropdown-item:hover {
  background: var(--bg-hover);
}

.dropdown-item svg {
  flex-shrink: 0;
  opacity: 0.7;
}

.dropdown-divider {
  height: 1px;
  background: var(--border);
  margin: 4px 0;
}

.danger-item {
  color: var(--red) !important;
}

.danger-item:hover {
  background: rgba(239, 68, 68, 0.1) !important;
}

.danger-item svg {
  color: var(--red);
}

.dropdown-enter-active,
.dropdown-leave-active {
  transition: all var(--dur-fast) ease;
}

.dropdown-enter-from,
.dropdown-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

.main-content {
  flex: 1;
  display: flex;
  position: relative;
}

.sidebar {
  width: 220px;
  background: var(--bg-secondary);
  padding: var(--sp-5) var(--sp-4);
  overflow-y: auto;
  transition: transform var(--dur-normal) var(--ease-out);
  border-right: 1px solid var(--border);
}

.sidebar.sidebar-collapsed {
  transform: translateX(-100%);
}

.nav-menu {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
  padding: var(--sp-3) var(--sp-4);
  border-radius: var(--radius-md);
  color: var(--text-secondary);
  text-decoration: none;
  cursor: pointer;
  transition: all var(--dur-fast);
}

.nav-item:hover,
.nav-item.active {
  background: var(--bg-active);
  color: var(--text-primary);
}

.nav-item.active {
  background: var(--accent);
}

.playlist-section {
  margin-top: var(--sp-8);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--sp-3);
}

.section-header span {
  font-size: var(--text-sm);
  color: var(--text-secondary);
}

.create-btn {
  width: 24px;
  height: 24px;
  border: none;
  border-radius: 50%;
  background: var(--bg-hover);
  color: var(--text-primary);
  cursor: pointer;
}

.playlist-list {
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.playlist-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: var(--sp-2) var(--sp-4);
  border-radius: var(--radius-md);
  color: var(--text-secondary);
  cursor: pointer;
  font-size: var(--text-base);
  transition: background var(--dur-normal);
}

.playlist-item:hover {
  background: var(--bg-hover);
}

.playlist-cover {
  width: 36px;
  height: 36px;
  border-radius: var(--radius-sm);
  object-fit: cover;
  flex-shrink: 0;
}

.playlist-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
  overflow: hidden;
  flex: 1;
}

.playlist-name {
  font-size: var(--text-sm);
  color: var(--text-primary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.playlist-info .count {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

.count {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

.content-area {
  flex: 1;
  padding: var(--sp-5) var(--sp-8);
  padding-bottom: 120px;
}

.announcement-bar {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px var(--sp-4);
  margin-bottom: var(--sp-4);
  background: var(--accent-muted);
  border: 1px solid var(--border-accent);
  border-radius: var(--radius-lg);
  color: var(--text-accent);
  font-size: var(--text-sm);
  animation: slideDown var(--dur-slow) ease;
}

@keyframes slideDown {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}

.announce-text {
  flex: 1;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
}

.announce-close {
  background: none;
  border: none;
  color: var(--text-secondary);
  font-size: 18px;
  cursor: pointer;
  padding: 0 4px;
  line-height: 1;
}

.announce-close:hover {
  color: var(--text-primary);
}

.category-nav {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: var(--sp-6);
  padding-bottom: var(--sp-4);
  border-bottom: 1px solid var(--border);
}

.cat-chip {
  padding: 7px 18px;
  border-radius: var(--radius-full);
  border: 1px solid var(--border-hover);
  background: var(--bg-hover);
  color: var(--text-secondary);
  font-size: var(--text-sm);
  cursor: pointer;
  transition: all var(--dur-normal);
  white-space: nowrap;
}

.cat-chip:hover {
  border-color: var(--border-accent);
  color: var(--text-primary);
  background: var(--accent-muted);
}

.cat-chip.active {
  background: var(--accent);
  border-color: transparent;
  color: var(--text-primary);
  box-shadow: 0 2px 12px var(--accent-glow);
}

.ranking-section .ranking-list {
  display: flex;
  flex-direction: column;
  background: var(--bg-hover);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.ranking-item {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: var(--sp-3) var(--sp-5);
  cursor: pointer;
  transition: background var(--dur-fast);
  border-bottom: 1px solid var(--border);
}

.ranking-item:last-child {
  border-bottom: none;
}

.ranking-item:hover {
  background: var(--accent-muted);
}

.rank-num {
  width: 26px;
  text-align: center;
  font-size: var(--text-md);
  font-weight: 700;
  color: var(--text-tertiary);
}

.rank-num.top3 {
  background: linear-gradient(135deg, #ffd700, #ff8c00);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  font-size: var(--text-lg);
}

.rank-cover-wrapper {
  position: relative;
  width: 44px;
  height: 44px;
  flex-shrink: 0;
  border-radius: var(--radius-md);
  overflow: hidden;
}

.rank-cover {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.rank-play-overlay {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0,0,0,0.4);
  opacity: 0;
  transition: opacity var(--dur-fast);
}

.ranking-item:hover .rank-play-overlay {
  opacity: 1;
}

.rank-play-btn {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: var(--play-overlay-btn-bg);
  color: var(--play-overlay-btn-color);
  display: flex;
  align-items: center;
  justify-content: center;
}

.rank-info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.rank-title {
  font-size: var(--text-base);
  color: var(--text-primary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.rank-artist {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

.rank-duration {
  font-size: var(--text-sm);
  color: var(--text-tertiary);
  flex-shrink: 0;
  min-width: 45px;
  text-align: right;
}

.rank-plays {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  flex-shrink: 0;
  white-space: nowrap;
}

.rank-controls {
  display: flex;
  align-items: center;
  gap: 4px;
}

.rank-controls .ctrl-btn {
  opacity: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border: none;
  border-radius: var(--radius-sm);
  background: transparent;
  color: var(--text-secondary);
  cursor: pointer;
  transition: all var(--dur-fast);
}

.rank-controls .ctrl-btn svg {
  width: 16px;
  height: 16px;
}

.ranking-item:hover .rank-controls .ctrl-btn {
  opacity: 1;
}

.rank-controls .ctrl-btn:hover {
  background: var(--bg-active);
  color: var(--text-primary);
}

.rank-controls .ctrl-btn.like-btn {
  opacity: 1;
  color: var(--text-tertiary);
}

.rank-controls .ctrl-btn.like-btn.liked {
  color: var(--red);
}

.sidebar-toggle {
  position: absolute;
  left: 12px;
  top: 16px;
  width: 34px;
  height: 34px;
  border-radius: 50%;
  border: none;
  background: rgba(0, 0, 0, 0.35);
  display: none;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  gap: 4px;
  cursor: pointer;
  z-index: 120;
  padding: 0;
}

.sidebar-toggle .bar {
  width: 18px;
  height: 2px;
  background: var(--text-primary);
  border-radius: var(--radius-full);
}

.section {
  margin-bottom: var(--sp-10);
}

.section .section-header {
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
  gap: 5px;
  background: transparent;
  border: 1px solid var(--border-hover);
  border-radius: var(--radius-full);
  padding: 6px 15px;
  color: var(--text-secondary);
  font-size: var(--text-sm);
  cursor: pointer;
}

.refresh-btn:hover {
  border-color: var(--accent);
  color: var(--accent);
}

.track-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
  gap: var(--sp-6);
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.fade-in-up {
  animation: fadeInUp 0.5s ease forwards;
  opacity: 0;
}

@keyframes slideInLeft {
  from {
    opacity: 0;
    transform: translateX(-20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.slide-in-left {
  animation: slideInLeft var(--dur-slow) ease forwards;
  opacity: 0;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.track-card {
  background: var(--bg-card);
  border-radius: var(--radius-lg);
  overflow: hidden;
  cursor: pointer;
  transition: all var(--dur-normal) var(--ease-out);
  box-shadow: var(--shadow-sm);
}

.track-card:hover {
  transform: translateY(-6px) scale(1.02);
  background: var(--bg-elevated);
  box-shadow: var(--shadow-md);
}

.cover-wrapper {
  position: relative;
  aspect-ratio: 1;
  overflow: hidden;
}

.cover {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.5s ease;
}

.track-card:hover .cover {
  transform: scale(1.08);
}

.play-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(180deg, transparent 0%, rgba(0, 0, 0, 0.6) 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity var(--dur-normal);
}

.track-card:hover .play-overlay {
  opacity: 1;
}

.play-btn-circle {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: var(--play-overlay-btn-bg);
  color: var(--play-overlay-btn-color);
  display: flex;
  align-items: center;
  justify-content: center;
  transform: scale(0.8);
  transition: all var(--dur-normal);
  box-shadow: var(--shadow-md);
}

.track-card:hover .play-btn-circle {
  transform: scale(1);
}

.play-btn-circle:hover {
  transform: scale(1.1);
  opacity: 1;
}

.track-info {
  padding: var(--sp-3);
}

.title {
  font-size: var(--text-base);
  font-weight: 500;
  margin: 0 0 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.artist {
  font-size: var(--text-xs);
  color: var(--text-secondary);
  margin: 0;
}

.track-controls {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 6px;
  min-height: 24px;
}

.track-duration {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

.control-btns {
  display: flex;
  align-items: center;
  gap: 4px;
}

.ctrl-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border: none;
  border-radius: var(--radius-sm);
  background: transparent;
  color: var(--text-secondary);
  cursor: pointer;
  transition: all var(--dur-fast);
  opacity: 0;
}

.ctrl-btn svg {
  width: 18px;
  height: 18px;
}

.ctrl-btn.like-btn svg {
  width: 20px;
  height: 20px;
}

.track-card:hover .ctrl-btn {
  opacity: 1;
}

.ctrl-btn:hover {
  background: var(--bg-active);
  color: var(--text-primary);
}

.ctrl-btn.like-btn {
  opacity: 1;
  color: var(--text-tertiary);
}

.ctrl-btn.like-btn:hover {
  color: var(--text-secondary);
}

.ctrl-btn.like-btn.liked {
  color: var(--red);
}

.ctrl-btn.like-btn.liked:hover {
  color: var(--red);
}

.track-list {
  background: var(--bg-hover);
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.track-row {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 14px var(--sp-5);
  cursor: pointer;
  transition: all var(--dur-fast) ease;
  border-bottom: 1px solid var(--border);
}

.track-row:last-child {
  border-bottom: none;
}

.track-row:hover {
  background: var(--accent-muted);
}

.index {
  width: 30px;
  text-align: center;
  font-size: var(--text-base);
  font-weight: 500;
  color: var(--text-tertiary);
}

.track-row:hover .index {
  color: var(--accent);
}

.row-cover {
  width: 50px;
  height: 50px;
  border-radius: var(--radius-md);
  object-fit: cover;
  box-shadow: var(--shadow-sm);
  transition: transform var(--dur-fast);
}

.row-cover-wrapper {
  position: relative;
  width: 50px;
  height: 50px;
}

.row-play-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, 0.5);
  border-radius: var(--radius-md);
  opacity: 0;
  transition: opacity var(--dur-fast);
}

.track-row:hover .row-play-overlay {
  opacity: 1;
}

.row-play-btn {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: var(--play-overlay-btn-bg);
  color: var(--play-overlay-btn-color);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: transform var(--dur-fast);
}

.row-play-btn:hover {
  transform: scale(1.1);
}

.row-play-btn svg {
  margin-left: 2px;
}

.track-row:hover .row-cover {
  transform: scale(1.05);
}

.row-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.row-info .title {
  font-size: var(--text-base);
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.row-info .artist {
  font-size: var(--text-xs);
  color: var(--text-secondary);
}

.duration {
  font-size: var(--text-sm);
  color: var(--text-tertiary);
  min-width: 45px;
  text-align: right;
}

.row-controls {
  display: flex;
  align-items: center;
  gap: 4px;
}

.row-controls .ctrl-btn {
  opacity: 0;
}

.track-row:hover .row-controls .ctrl-btn {
  opacity: 1;
}

.row-controls .ctrl-btn.like-btn {
  opacity: 1;
}

.like-btn {
  background: transparent;
  border: none;
  color: var(--text-tertiary);
  cursor: pointer;
  padding: var(--sp-2);
  border-radius: 50%;
  transition: all var(--dur-fast);
}

.like-btn:hover {
  color: var(--text-secondary);
  background: transparent;
  transform: scale(1.1);
}

.like-btn.liked {
  color: var(--red);
}

.like-btn.liked:hover {
  color: var(--red);
  background: rgba(239, 68, 68, 0.1);
}

.pagination-wrapper {
  margin-top: var(--sp-4);
  display: flex;
  justify-content: center;
  align-items: center;
  gap: var(--sp-2);
}

.last-page-btn {
  padding: 6px 14px;
  border-radius: var(--radius-full);
  border: 1px solid var(--border-hover);
  background: transparent;
  color: var(--text-primary);
  font-size: var(--text-xs);
  cursor: pointer;
  transition: all var(--dur-fast);
}

.last-page-btn:hover:not(:disabled) {
  background: var(--bg-active);
}

.last-page-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

@keyframes heartBeat {
  0% { transform: scale(1); }
  25% { transform: scale(1.3); }
  50% { transform: scale(1); }
  75% { transform: scale(1.3); }
  100% { transform: scale(1); }
}

.like-btn:active {
  animation: heartBeat 0.3s ease-in-out;
}

.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: var(--bg-secondary);
  padding: var(--sp-6);
  border-radius: var(--radius-lg);
  width: 90%;
  max-width: 350px;
  border: 1px solid var(--border);
}

.modal-content h3 {
  margin: 0 0 var(--sp-5);
}

.modal-content input {
  width: 100%;
  padding: var(--sp-3);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  background: var(--bg-hover);
  color: var(--text-primary);
  font-size: var(--text-base);
}

.modal-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
  margin-top: var(--sp-5);
}

.modal-actions button {
  padding: 10px var(--sp-5);
  border: none;
  border-radius: var(--radius-md);
  cursor: pointer;
  font-size: var(--text-base);
}

.modal-actions button.primary {
  background: var(--accent);
  color: var(--text-primary);
}

@media (max-width: 768px) {
  .sidebar {
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    z-index: 110;
  }

  .sidebar-toggle {
    display: flex;
  }

  .search-box {
    width: 200px;
  }

  .track-grid {
    grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
    gap: 15px;
  }
}

.delete-warning {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: var(--sp-5) 0;
  margin-bottom: var(--sp-5);
}

.delete-warning svg {
  margin-bottom: var(--sp-4);
}

.delete-warning .warning-text {
  color: var(--red);
  font-size: var(--text-base);
  text-align: center;
  line-height: 1.6;
  margin: 0;
}

.create-playlist-form {
  padding: 10px 0;
}

.create-playlist-form .cover-upload-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--sp-3);
  margin-bottom: var(--sp-6);
}

.create-playlist-form .cover-preview {
  width: 140px;
  height: 140px;
  border-radius: var(--radius-lg);
  overflow: hidden;
  cursor: pointer;
  border: 2px dashed var(--border-hover);
  transition: border-color var(--dur-normal);
  background: var(--bg-hover);
}

.create-playlist-form .cover-preview:hover {
  border-color: var(--accent);
}

.create-playlist-form .cover-preview img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.create-playlist-form .cover-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 10px;
  color: var(--text-tertiary);
}

.create-playlist-form .cover-placeholder span {
  font-size: var(--text-sm);
}

.create-playlist-form .edit-cover-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: var(--sp-2) var(--sp-4);
  background: var(--accent-muted);
  border: 1px solid var(--border-accent);
  border-radius: var(--radius-md);
  color: var(--text-accent);
  font-size: var(--text-sm);
  cursor: pointer;
  transition: all var(--dur-normal);
}

.create-playlist-form .edit-cover-btn:hover {
  background: var(--accent-glow);
  border-color: var(--accent);
}

.create-playlist-form .form-group {
  margin-bottom: var(--sp-5);
}

.create-playlist-form .form-group label {
  display: block;
  font-size: var(--text-base);
  color: var(--text-primary);
  margin-bottom: var(--sp-2);
}

.create-playlist-form .form-group .required {
  color: var(--red);
}

.create-playlist-form .form-group .optional {
  color: var(--text-tertiary);
  font-size: var(--text-xs);
}

.create-playlist-form .form-input,
.create-playlist-form .form-textarea {
  width: 100%;
  padding: var(--sp-3) 14px;
  background: var(--bg-hover);
  border: 1px solid var(--border-hover);
  border-radius: var(--radius-md);
  color: var(--text-primary);
  font-size: var(--text-base);
  transition: border-color var(--dur-normal);
  box-sizing: border-box;
}

.create-playlist-form .form-input::placeholder,
.create-playlist-form .form-textarea::placeholder {
  color: var(--text-tertiary);
}

.create-playlist-form .form-input:focus,
.create-playlist-form .form-textarea:focus {
  outline: none;
  border-color: var(--accent);
}

.create-playlist-form .form-textarea {
  resize: none;
  font-family: inherit;
}

.dialog-footer-btns {
  display: flex;
  justify-content: flex-end;
  gap: var(--sp-3);
}

.dialog-footer-btns .btn-cancel {
  padding: 10px var(--sp-6);
  background: var(--bg-active);
  border: none;
  border-radius: var(--radius-md);
  color: var(--text-secondary);
  font-size: var(--text-base);
  cursor: pointer;
  transition: all var(--dur-normal);
}

.dialog-footer-btns .btn-cancel:hover {
  background: var(--bg-hover);
}

.dialog-footer-btns .btn-create {
  padding: 10px var(--sp-6);
  background: var(--accent);
  border: none;
  border-radius: var(--radius-md);
  color: var(--text-primary);
  font-size: var(--text-base);
  cursor: pointer;
  transition: all var(--dur-normal);
}

.dialog-footer-btns .btn-create:hover {
  opacity: 0.9;
  transform: translateY(-1px);
}

.add-to-playlist-content {
  padding: 10px 0;
}

.selected-track-info {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
  padding: var(--sp-3);
  background: var(--bg-hover);
  border-radius: var(--radius-md);
  margin-bottom: var(--sp-4);
}

.track-cover-small {
  width: 48px;
  height: 48px;
  border-radius: var(--radius-sm);
  object-fit: cover;
}

.track-text {
  display: flex;
  flex-direction: column;
  gap: 4px;
  overflow: hidden;
}

.track-text .track-title {
  font-size: var(--text-base);
  color: var(--text-primary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.track-text .track-artist {
  font-size: var(--text-xs);
  color: var(--text-secondary);
}

.playlist-options {
  max-height: 300px;
  overflow-y: auto;
}

.playlist-option-header {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  padding: var(--sp-2) 0;
  border-bottom: 1px solid var(--border);
  margin-bottom: var(--sp-2);
}

.playlist-option-item {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
  padding: 10px;
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: background var(--dur-fast);
}

.playlist-option-item:hover {
  background: var(--bg-active);
}

.pl-cover {
  width: 40px;
  height: 40px;
  border-radius: var(--radius-sm);
  object-fit: cover;
}

.pl-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.pl-name {
  font-size: var(--text-base);
  color: var(--text-primary);
}

.pl-count {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

.no-playlists {
  text-align: center;
  padding: var(--sp-8);
  color: var(--text-tertiary);
  font-size: var(--text-base);
}

.comment-drawer :deep(.el-drawer) {
  background: var(--bg-secondary) !important;
}

.comment-drawer :deep(.el-drawer__header) {
  color: var(--text-primary) !important;
  background: var(--bg-secondary) !important;
  border-bottom: 1px solid var(--border);
  padding: var(--sp-4) var(--sp-5);
  margin-bottom: 0;
}

.comment-drawer :deep(.el-drawer__body) {
  background: var(--bg-secondary) !important;
  padding: 0;
  color: var(--text-primary) !important;
}

.comment-drawer :deep(.el-input__inner) {
  background: var(--bg-hover) !important;
  border-color: var(--border-hover) !important;
  color: var(--text-primary) !important;
}

.comment-drawer :deep(.el-textarea__inner) {
  background: var(--bg-hover) !important;
  border-color: var(--border-hover) !important;
  color: var(--text-primary) !important;
}

.comment-drawer :deep(.el-textarea__inner)::placeholder {
  color: var(--text-tertiary) !important;
}

.comment-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: var(--bg-primary);
}

.comment-input-area {
  padding: var(--sp-4);
  border-bottom: 1px solid var(--border);
}

.comment-input-area .el-textarea {
  margin-bottom: var(--sp-3);
}

.comment-list {
  flex: 1;
  overflow-y: auto;
  padding: var(--sp-4);
}

.comment-header {
  font-size: var(--text-base);
  color: var(--text-secondary);
  margin-bottom: var(--sp-4);
}

.loading-area {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px var(--sp-5);
  color: var(--text-secondary);
  gap: var(--sp-4);
}

.loading-area .el-icon {
  font-size: 32px;
  color: var(--accent);
}

.loading-area span {
  font-size: var(--text-base);
  color: var(--text-secondary);
}

.comment-item {
  display: flex;
  gap: var(--sp-3);
  margin-bottom: var(--sp-5);
  padding: var(--sp-3);
  border-radius: var(--radius-lg);
  background: var(--bg-hover);
  border: 1px solid var(--border);
}

.comment-avatar {
  width: 42px;
  height: 42px;
  border-radius: 50%;
  overflow: hidden;
  cursor: pointer;
  flex-shrink: 0;
  background: var(--accent);
  border: 2px solid var(--border-hover);
  box-shadow: var(--shadow-sm);
  display: flex;
  align-items: center;
  justify-content: center;
}

.comment-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  background: var(--bg-card);
}

.comment-avatar:hover {
  border-color: var(--accent);
  transform: scale(1.05);
  transition: all var(--dur-fast);
}

.comment-body {
  flex: 1;
  min-width: 0;
}

.comment-header-row {
  display: flex;
  align-items: center;
  gap: var(--sp-2);
  margin-bottom: var(--sp-2);
}

.comment-header-row .username {
  font-size: 15px;
  font-weight: 600;
  color: var(--text-accent);
  cursor: pointer;
}

.comment-header-row .username:hover {
  color: var(--accent);
}

.comment-header-row .floor {
  font-size: var(--text-xs);
  color: var(--text-accent);
  background: var(--accent-muted);
  padding: 2px var(--sp-2);
  border-radius: var(--radius-full);
  border: 1px solid var(--border-accent);
}

.comment-content {
  font-size: var(--text-base);
  color: var(--text-primary);
  line-height: 1.7;
  margin-bottom: 10px;
  word-break: break-word;
}

.comment-footer {
  display: flex;
  align-items: center;
  gap: var(--sp-4);
}

.comment-footer .time {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

.actions {
  display: flex;
  gap: var(--sp-3);
}

.action-btn {
  display: flex;
  align-items: center;
  gap: 4px;
  background: none;
  border: none;
  color: var(--text-secondary);
  font-size: var(--text-xs);
  cursor: pointer;
  padding: 4px var(--sp-2);
  border-radius: var(--radius-sm);
  transition: all var(--dur-fast);
}

.action-btn:hover {
  color: var(--text-primary);
  background: var(--bg-active);
}

.action-btn.delete {
  color: var(--text-tertiary);
}

.action-btn.delete:hover {
  color: var(--red);
}

.action-btn svg.liked {
  color: var(--accent);
}

.replies-list {
  margin-top: var(--sp-3);
  padding: var(--sp-3);
  background: var(--bg-active);
  border-radius: var(--radius-md);
}

.reply-item {
  display: flex;
  gap: 10px;
  margin-bottom: var(--sp-3);
}

.reply-item:last-child {
  margin-bottom: 0;
}

.reply-avatar {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  overflow: hidden;
  cursor: pointer;
  flex-shrink: 0;
  background: var(--accent);
  border: 1px solid var(--border-hover);
  display: flex;
  align-items: center;
  justify-content: center;
}

.reply-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  background: var(--bg-card);
}

.reply-content {
  flex: 1;
  min-width: 0;
}

.reply-header {
  margin-bottom: 4px;
}

.reply-user {
  font-size: var(--text-sm);
  font-weight: 600;
  color: var(--text-primary);
  cursor: pointer;
}

.reply-user:hover {
  color: var(--accent);
}

.reply-text {
  font-size: var(--text-sm);
  color: var(--text-primary);
  margin-left: var(--sp-2);
}

.reply-meta {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
}

.reply-time {
  font-size: var(--text-xs);
  color: var(--text-secondary);
}

.delete-reply-btn {
  background: none;
  border: none;
  color: var(--text-tertiary);
  font-size: var(--text-xs);
  cursor: pointer;
  padding: 2px 6px;
  border-radius: 3px;
}

.delete-reply-btn:hover {
  color: var(--red);
  background: rgba(239, 68, 68, 0.1);
}

.more-replies {
  display: block;
  width: 100%;
  background: none;
  border: none;
  color: var(--accent-hover);
  font-size: var(--text-xs);
  cursor: pointer;
  padding: var(--sp-2);
  text-align: left;
  margin-top: var(--sp-2);
}

.more-replies:hover {
  color: var(--accent);
}

.empty-comments {
  text-align: center;
  padding: var(--sp-10);
  color: var(--text-tertiary);
}

.empty-comments svg {
  margin-bottom: var(--sp-3);
  opacity: 0.5;
}

.empty-comments p {
  font-size: var(--text-base);
}

.reply-input-area {
  padding: var(--sp-4);
  background: var(--bg-secondary);
  border-top: 1px solid var(--border);
}

.reply-input-area .reply-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--sp-3);
  font-size: var(--text-base);
  color: var(--text-secondary);
}

.reply-input-area .cancel-reply {
  background: none;
  border: none;
  color: var(--text-secondary);
  cursor: pointer;
  font-size: var(--text-sm);
}

.reply-input-area .cancel-reply:hover {
  color: var(--text-primary);
}

.reply-input-area .el-textarea {
  margin-bottom: var(--sp-3);
}
</style>

<style>
.dark-modal .el-dialog {
  background: var(--bg-secondary) !important;
  border-radius: var(--radius-lg) !important;
  border: 1px solid var(--border) !important;
}

.dark-modal .el-dialog__header {
  padding: var(--sp-4) var(--sp-5) !important;
  border-bottom: 1px solid var(--border) !important;
}

.dark-modal .el-dialog__title {
  color: var(--text-primary) !important;
  font-size: var(--text-md) !important;
  font-weight: 500 !important;
}

.dark-modal .el-dialog__headerbtn .el-dialog__close {
  color: var(--text-secondary) !important;
}

.dark-modal .el-dialog__headerbtn:hover .el-dialog__close {
  color: var(--text-primary) !important;
}

.dark-modal .el-dialog__body {
  padding: var(--sp-5) !important;
  color: var(--text-primary) !important;
}

.dark-modal .el-dialog__footer {
  padding: var(--sp-4) var(--sp-5) !important;
  border-top: 1px solid var(--border) !important;
}
</style>
