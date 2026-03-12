<template>
  <div class="profile-page">
    <!-- 头部信息 -->
    <div class="profile-header">
      <div class="avatar-section" v-if="isMe" @click="triggerAvatarUpload">
        <img :src="displayAvatar" alt="头像" class="avatar" @error="onAvatarError" />
        <div class="avatar-hover-mask">
          <svg viewBox="0 0 24 24" width="28" height="28">
            <path fill="white" d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
          </svg>
          <span>更换头像</span>
        </div>
        <input 
          ref="avatarInputRef"
          type="file" 
          accept="image/*" 
          style="display: none" 
          @change="handleAvatarUpload"
        />
      </div>
      <div class="avatar-section" v-else>
        <img :src="displayAvatar" alt="头像" class="avatar" @error="onAvatarError" />
      </div>
      <div class="user-info">
        <!-- 昵称（可编辑） -->
        <div class="nickname-row" v-if="isMe" @click="startEditNickname">
          <h2 v-if="!editingNickname">{{ userInfo?.nickname || userInfo?.username || '用户' }}</h2>
          <input 
            v-else
            ref="nicknameInputRef"
            v-model="editNickname" 
            type="text" 
            class="edit-input nickname-input"
            placeholder="请输入昵称"
            @blur="saveNickname"
            @keyup.enter="saveNickname"
            @click.stop
          />
          <svg v-if="!editingNickname" class="edit-icon" viewBox="0 0 24 24" width="18" height="18">
            <path fill="currentColor" d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/>
          </svg>
        </div>
        <h2 v-else>{{ userInfo?.nickname || userInfo?.username || '用户' }}</h2>
        <div v-if="!isMe" class="visitor-actions">
          <button
            class="follow-btn"
            :class="{ following: isFollowing }"
            :disabled="followLoading"
            @click="toggleFollow"
          >
            {{ isFollowing ? '已关注' : '+ 关注' }}
          </button>
          <span class="visitor-tip">公开主页</span>
        </div>
        
        <!-- 个性签名（可编辑） -->
        <div class="signature-row" v-if="isMe" @click="startEditSignature">
          <p v-if="!editingSignature" class="signature">{{ userInfo?.signature || '点击添加个性签名~' }}</p>
          <input 
            v-else
            ref="signatureInputRef"
            v-model="editSignature" 
            type="text" 
            class="edit-input signature-input"
            placeholder="写点什么吧~"
            @blur="saveSignature"
            @keyup.enter="saveSignature"
            @click.stop
          />
          <svg v-if="!editingSignature" class="edit-icon-small" viewBox="0 0 24 24" width="14" height="14">
            <path fill="currentColor" d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/>
          </svg>
        </div>
        <p v-else class="signature">{{ userInfo?.signature || '这个人很懒，什么都没写~' }}</p>
        
        <!-- 用户详细信息 -->
        <div class="user-details" v-if="isMe">
          <span class="detail-item" @click="showEditDialog = true">
            <svg viewBox="0 0 24 24" width="16" height="16">
              <path v-if="userInfo?.gender === 'male'" fill="currentColor" d="M9.5 11c1.93 0 3.5 1.57 3.5 3.5S11.43 18 9.5 18 6 16.43 6 14.5 7.57 11 9.5 11zm0-2C6.46 9 4 11.46 4 14.5S6.46 20 9.5 20c1.16 0 2.23-.36 3.11-.97l3.19 3.19 1.41-1.41-3.19-3.19c.61-.88.97-1.95.97-3.11C15 11.46 12.54 9 9.5 9zm6.5-6h5v5h-2V5.41l-2.79 2.79c.97 1.18 1.54 2.68 1.54 4.3 0 3.04-2.19 5.58-5.08 6.09-.11-.72-.32-1.4-.62-2.03 1.73-.37 3.02-1.91 3.02-3.74 0-2.1-1.71-3.82-3.82-3.82-1.83 0-3.37 1.29-3.74 3.02-.63-.3-1.31-.51-2.03-.62C8.08 8.19 10.62 6 13.66 6c1.62 0 3.12.57 4.3 1.54L20.59 5H18V3z"/>
              <path v-else-if="userInfo?.gender === 'female'" fill="currentColor" d="M12 4c2.76 0 5 2.24 5 5s-2.24 5-5 5-5-2.24-5-5 2.24-5 5-5zm0 2c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3zm-1 10h2v3h3v2h-3v3h-2v-3H8v-2h3v-3z"/>
              <path v-else fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 3c1.66 0 3 1.34 3 3s-1.34 3-3 3-3-1.34-3-3 1.34-3 3-3zm0 14.2c-2.5 0-4.71-1.28-6-3.22.03-1.99 4-3.08 6-3.08 1.99 0 5.97 1.09 6 3.08-1.29 1.94-3.5 3.22-6 3.22z"/>
            </svg>
            <span>{{ userInfo?.gender ? (userInfo.gender === 'male' ? '男' : userInfo.gender === 'female' ? '女' : '保密') : '未设置性别' }}</span>
          </span>
          <span class="detail-item" @click="showEditDialog = true">
            <svg viewBox="0 0 24 24" width="16" height="16">
              <path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67V7z"/>
            </svg>
            <span>{{ userInfo?.birthday ? calculateAge(userInfo.birthday) + '岁' : '未设置年龄' }}</span>
          </span>
          <span class="detail-item" @click="showEditDialog = true">
            <svg viewBox="0 0 24 24" width="16" height="16">
              <path fill="currentColor" d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
            </svg>
            <span>{{ userInfo?.region || '未设置地区' }}</span>
          </span>
        </div>
        <div class="user-details" v-else>
          <span v-if="userInfo?.gender" class="detail-item">
            <svg viewBox="0 0 24 24" width="16" height="16">
              <path v-if="userInfo.gender === 'male'" fill="currentColor" d="M9.5 11c1.93 0 3.5 1.57 3.5 3.5S11.43 18 9.5 18 6 16.43 6 14.5 7.57 11 9.5 11zm0-2C6.46 9 4 11.46 4 14.5S6.46 20 9.5 20c1.16 0 2.23-.36 3.11-.97l3.19 3.19 1.41-1.41-3.19-3.19c.61-.88.97-1.95.97-3.11C15 11.46 12.54 9 9.5 9zm6.5-6h5v5h-2V5.41l-2.79 2.79c.97 1.18 1.54 2.68 1.54 4.3 0 3.04-2.19 5.58-5.08 6.09-.11-.72-.32-1.4-.62-2.03 1.73-.37 3.02-1.91 3.02-3.74 0-2.1-1.71-3.82-3.82-3.82-1.83 0-3.37 1.29-3.74 3.02-.63-.3-1.31-.51-2.03-.62C8.08 8.19 10.62 6 13.66 6c1.62 0 3.12.57 4.3 1.54L20.59 5H18V3z"/>
              <path v-else-if="userInfo.gender === 'female'" fill="currentColor" d="M12 4c2.76 0 5 2.24 5 5s-2.24 5-5 5-5-2.24-5-5 2.24-5 5-5zm0 2c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3zm-1 10h2v3h3v2h-3v3h-2v-3H8v-2h3v-3z"/>
              <path v-else fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 3c1.66 0 3 1.34 3 3s-1.34 3-3 3-3-1.34-3-3 1.34-3 3-3zm0 14.2c-2.5 0-4.71-1.28-6-3.22.03-1.99 4-3.08 6-3.08 1.99 0 5.97 1.09 6 3.08-1.29 1.94-3.5 3.22-6 3.22z"/>
            </svg>
            <span>{{ userInfo.gender === 'male' ? '男' : userInfo.gender === 'female' ? '女' : '保密' }}</span>
          </span>
          <span v-if="userInfo?.birthday" class="detail-item">
            <svg viewBox="0 0 24 24" width="16" height="16">
              <path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67V7z"/>
            </svg>
            <span>{{ calculateAge(userInfo.birthday) }}岁</span>
          </span>
          <span v-if="userInfo?.region" class="detail-item">
            <svg viewBox="0 0 24 24" width="16" height="16">
              <path fill="currentColor" d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
            </svg>
            <span>{{ userInfo.region }}</span>
          </span>
        </div>
        <div class="stats">
          <div class="stat-item clickable" @click="goToFollowTab('followers')">
            <span class="count">{{ followCounts.followers }}</span>
            <span class="label">粉丝</span>
          </div>
          <div class="stat-item clickable" @click="goToFollowTab('following')">
            <span class="count">{{ followCounts.following }}</span>
            <span class="label">关注</span>
          </div>
          <div class="stat-item" v-if="isMe">
            <span class="count">{{ myPlaylists.length }}</span>
            <span class="label">歌单</span>
          </div>
          <div class="stat-item" v-if="isMe">
            <span class="count">{{ favoriteTracks.length }}</span>
            <span class="label">收藏</span>
          </div>
          <div class="stat-item" v-if="isMe">
            <span class="count">{{ playHistory.length }}</span>
            <span class="label">播放记录</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 标签页 -->
    <div class="profile-tabs">
      <button 
        :class="['tab', { active: activeTab === 'playlists' }]" 
        @click="activeTab = 'playlists'"
      >
        {{ isMe ? '我的歌单' : 'TA的歌单' }}
      </button>
      <button 
        :class="['tab', { active: activeTab === 'favorites' }]" 
        @click="activeTab = 'favorites'"
      >
        {{ isMe ? '我的收藏' : 'TA的收藏' }}
      </button>
      <button 
        v-if="isMe"
        :class="['tab', { active: activeTab === 'history' }]" 
        @click="activeTab = 'history'"
      >
        播放历史
      </button>
      <button 
        v-if="isMe"
        :class="['tab', { active: activeTab === 'comments' }]" 
        @click="activeTab = 'comments'"
      >
        我的评论
      </button>
      <button 
        :class="['tab', { active: activeTab === 'followers' }]" 
        @click="activeTab = 'followers'"
      >
        {{ isMe ? '粉丝' : 'TA的粉丝' }}
      </button>
      <button 
        :class="['tab', { active: activeTab === 'following' }]" 
        @click="activeTab = 'following'"
      >
        {{ isMe ? '关注' : 'TA的关注' }}
      </button>
    </div>

    <div class="quick-actions">
      <button class="quick-btn" @click="router.push('/home')">回到首页</button>
      <button class="quick-btn" @click="router.back()">返回上页</button>
      <button class="quick-btn primary" :disabled="playHistory.length === 0" @click="playLatestHistory">
        快速播放最近一首
      </button>
    </div>

    <!-- 歌单列表 -->
    <div v-if="activeTab === 'playlists'" class="content-section">
      <div class="section-header">
        <h3>{{ isMe ? '我创建的歌单' : 'TA的歌单' }}</h3>
        <button v-if="isMe" class="create-btn" @click="showCreatePlaylist = true">
          <svg viewBox="0 0 24 24" width="16" height="16" style="margin-right: 6px;">
            <path fill="currentColor" d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
          </svg>
          新建歌单
        </button>
      </div>
      <div class="playlist-grid">
        <div 
          v-for="(playlist, index) in myPlaylists" 
          :key="playlist.id" 
          class="playlist-card fade-in-up"
          :style="{ animationDelay: `${index * 0.05}s` }"
        >
          <div class="cover-wrapper" @click="goToPlaylist(playlist.id)">
            <img :src="playlist.coverUrl || defaultCover" alt="封面" class="cover" />
            <div class="play-overlay">
              <div class="play-btn-circle">
                <svg viewBox="0 0 24 24" width="24" height="24">
                  <path fill="currentColor" d="M8 5v14l11-7z"/>
                </svg>
              </div>
            </div>
          </div>
          <div class="info">
            <h4 @click="goToPlaylist(playlist.id)">{{ playlist.name }}</h4>
            <p>{{ playlist.trackCount || 0 }} 首</p>
            <button v-if="isMe" class="playlist-delete-btn" @click.stop="deletePlaylistFromProfile(playlist)" title="删除歌单">
              <svg viewBox="0 0 24 24" width="16" height="16"><path fill="currentColor" d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/></svg>
            </button>
          </div>
        </div>
      </div>
      <div v-if="myPlaylists.length === 0" class="empty">
        <svg viewBox="0 0 24 24" width="64" height="64" style="opacity: 0.3; margin-bottom: 15px;">
          <path fill="currentColor" d="M15 6H3v2h12V6zm0 4H3v2h12v-2zM3 16h8v-2H3v2zM17 6v8.18c-.31-.11-.65-.18-1-.18-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3V8h3V6h-5z"/>
        </svg>
        <p>{{ isMe ? '暂无歌单，点击上方按钮创建吧~' : 'TA暂无歌单' }}</p>
      </div>
    </div>

    <!-- 收藏列表 -->
    <div v-if="activeTab === 'favorites'" class="content-section">
      <div class="section-header">
        <h3>{{ isMe ? '我收藏的音乐' : 'TA的收藏' }}</h3>
      </div>
      <div class="track-list">
        <div 
          v-for="(track, index) in favoriteTracks" 
          :key="track.id" 
          class="track-item slide-in-left"
          :style="{ animationDelay: `${index * 0.03}s` }"
          @click="playTrack(track)"
        >
          <img :src="track.coverUrl || defaultCover" alt="封面" class="track-cover" @error="onCoverError" />
          <div class="track-info">
            <h4>{{ track.title }}</h4>
            <p><ArtistLink :artist-id="track.artistId" :artist-name="track.artist" /></p>
          </div>
          <button class="play-btn" @click.stop="playTrack(track)">
            <svg viewBox="0 0 24 24" width="20" height="20">
              <path fill="currentColor" d="M8 5v14l11-7z"/>
            </svg>
          </button>
          <button v-if="isMe" class="remove-btn liked" @click.stop="removeFavorite(track.id)" title="取消收藏">
            <svg viewBox="0 0 24 24" width="18" height="18">
              <path fill="currentColor" d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
            </svg>
          </button>
        </div>
      </div>
      <div v-if="favoriteTracks.length === 0" class="empty">
        <svg viewBox="0 0 24 24" width="64" height="64" style="opacity: 0.3; margin-bottom: 15px;">
          <path fill="currentColor" d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
        </svg>
        <p>{{ isMe ? '暂无收藏，去发现好音乐吧~' : 'TA暂无收藏' }}</p>
      </div>
    </div>

    <!-- 播放历史 -->
    <div v-if="activeTab === 'history'" class="content-section">
      <div class="section-header">
        <h3>{{ isMe ? '播放历史' : 'TA的播放历史' }}</h3>
        <button v-if="isMe && playHistory.length > 0" class="clear-btn" @click="clearPlayHistory">
          <svg viewBox="0 0 24 24" width="16" height="16" style="margin-right: 6px;">
            <path fill="currentColor" d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/>
          </svg>
          清空历史
        </button>
      </div>
      <div class="track-list">
        <div 
          v-for="(track, index) in playHistory" 
          :key="track.historyId || track.id + '-' + index" 
          class="track-item slide-in-left"
          :style="{ animationDelay: `${index * 0.03}s` }"
          @click="playTrack(track)"
        >
          <img :src="track.coverUrl || defaultCover" alt="封面" class="track-cover" @error="onCoverError" />
          <div class="track-info">
            <h4>{{ track.title }}</h4>
            <p><ArtistLink :artist-id="track.artistId" :artist-name="track.artist" /></p>
          </div>
          <span class="play-time">{{ formatPlayTime(track.playedAt) }}</span>
          <button class="play-btn" @click.stop="playTrack(track)">
            <svg viewBox="0 0 24 24" width="20" height="20">
              <path fill="currentColor" d="M8 5v14l11-7z"/>
            </svg>
          </button>
        </div>
      </div>
      <div v-if="playHistory.length === 0" class="empty">
        <svg viewBox="0 0 24 24" width="64" height="64" style="opacity: 0.3; margin-bottom: 15px;">
          <path fill="currentColor" d="M13 3c-4.97 0-9 4.03-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42C8.27 19.99 10.51 21 13 21c4.97 0 9-4.03 9-9s-4.03-9-9-9zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z"/>
        </svg>
        <p>{{ isMe ? '暂无播放记录，去听些音乐吧~' : 'TA 暂无公开播放记录' }}</p>
      </div>
    </div>

    <!-- 粉丝列表 -->
    <div v-if="activeTab === 'followers'" class="content-section">
      <div class="section-header">
        <h3>{{ isMe ? '我的粉丝' : 'TA的粉丝' }}</h3>
      </div>
      <div class="follow-list">
        <div 
          v-for="(user, index) in followersList" 
          :key="user.id" 
          class="follow-item slide-in-left"
          :style="{ animationDelay: `${index * 0.03}s` }"
          @click="goToUserProfile(user.id)"
        >
          <img :src="user.avatar || defaultAvatar" alt="头像" class="user-avatar" @error="onFollowAvatarError" />
          <div class="user-info-mini">
            <h4>{{ user.nickname || user.username || '用户' }}</h4>
            <p v-if="user.signature" class="user-signature">{{ user.signature }}</p>
          </div>
          <span class="go-arrow">→</span>
        </div>
      </div>
      <div v-if="followersList.length === 0" class="empty">
        <p>{{ isMe ? '暂无粉丝' : 'TA暂无粉丝' }}</p>
      </div>
    </div>

    <!-- 关注列表 -->
    <div v-if="activeTab === 'following'" class="content-section">
      <div class="section-header">
        <h3>{{ isMe ? '我的关注' : 'TA的关注' }}</h3>
      </div>
      <div class="follow-list">
        <div 
          v-for="(user, index) in followingList" 
          :key="user.id" 
          class="follow-item slide-in-left"
          :style="{ animationDelay: `${index * 0.03}s` }"
          @click="goToUserProfile(user.id)"
        >
          <img :src="user.avatar || defaultAvatar" alt="头像" class="user-avatar" @error="onFollowAvatarError" />
          <div class="user-info-mini">
            <h4>{{ user.nickname || user.username || '用户' }}</h4>
            <p v-if="user.signature" class="user-signature">{{ user.signature }}</p>
          </div>
          <span class="go-arrow">→</span>
        </div>
      </div>
      <div v-if="followingList.length === 0" class="empty">
        <p>{{ isMe ? '暂无关注' : 'TA暂无关注' }}</p>
      </div>
    </div>

    <!-- 我的评论 -->
    <div v-if="activeTab === 'comments'" class="content-section">
      <div class="section-header">
        <h3>我的评论</h3>
      </div>
      <div class="comment-list">
        <div 
          v-for="(comment, index) in myComments" 
          :key="comment.id" 
          class="my-comment-item slide-in-left"
          :style="{ animationDelay: `${index * 0.03}s` }"
          @click="openCommentDrawer(comment)"
        >
          <div class="comment-track">
            <img :src="comment.trackCover || defaultCover" alt="封面" class="track-cover-small" />
            <div class="track-info-small">
              <h4>{{ comment.trackTitle }}</h4>
              <p>{{ comment.trackArtist }}</p>
            </div>
          </div>
          <div class="comment-content-area">
            <p>{{ comment.content }}</p>
            <div class="comment-meta">
              <span class="time">{{ formatPlayTime(comment.createdAt) }}</span>
              <button class="delete-btn" @click.stop="deleteComment(comment.id)">删除</button>
            </div>
          </div>
        </div>
      </div>
      <div v-if="myComments.length === 0" class="empty">
        <svg viewBox="0 0 24 24" width="64" height="64" style="opacity: 0.3; margin-bottom: 15px;">
          <path fill="currentColor" d="M21 6h-2v9H6v2c0 .55.45 1 1 1h11l4 4V7c0-.55-.45-1-1-1zm-4 6V3c0-.55-.45-1-1-1H3c-.55 0-1 .45-1 1v14l4-4h10c.55 0 1-.45 1-1z"/>
        </svg>
        <p>暂无评论，去发表你的想法吧~</p>
      </div>
    </div>

    <!-- 新建歌单弹窗 -->
    <div v-if="showCreatePlaylist" class="modal" @click.self="showCreatePlaylist = false">
      <div class="modal-content create-playlist-modal" @click.stop>
        <div class="modal-header">
          <h3>新建歌单</h3>
          <button class="close-btn" @click="showCreatePlaylist = false">&times;</button>
        </div>
        <div class="modal-body">
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
            <label>歌单名称 *</label>
            <input v-model="newPlaylistName" type="text" placeholder="请输入歌单名称" class="form-input" />
          </div>
          <div class="form-group">
            <label>歌单描述</label>
            <textarea v-model="newPlaylistDesc" placeholder="请输入歌单描述（可选）" class="form-textarea"></textarea>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-cancel" @click="showCreatePlaylist = false">取消</button>
          <button class="btn-confirm" @click="createPlaylist">创建</button>
        </div>
      </div>
    </div>

    <!-- 封面裁剪弹窗 -->
    <CoverCropper
      v-model="showCoverCropper"
      :image-url="coverCropperImageUrl"
      @confirm="handleCoverCropConfirm"
    />

    <!-- 编辑个人信息弹窗 -->
    <div v-if="showEditDialog" class="modal-overlay" @click="showEditDialog = false">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>编辑个人信息</h3>
          <button class="close-btn" @click="showEditDialog = false">&times;</button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label>性别</label>
            <div class="gender-options">
              <label class="gender-option" :class="{ selected: editGender === 'male' }">
                <input type="radio" v-model="editGender" value="male" />
                <span>男</span>
              </label>
              <label class="gender-option" :class="{ selected: editGender === 'female' }">
                <input type="radio" v-model="editGender" value="female" />
                <span>女</span>
              </label>
              <label class="gender-option" :class="{ selected: editGender === 'other' }">
                <input type="radio" v-model="editGender" value="other" />
                <span>保密</span>
              </label>
            </div>
          </div>
          <div class="form-group">
            <label>生日</label>
            <input type="date" v-model="editBirthday" class="form-input" />
          </div>
          <div class="form-group">
            <label>地区</label>
            <input type="text" v-model="editRegion" placeholder="请输入地区" class="form-input" />
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-cancel" @click="showEditDialog = false">取消</button>
          <button class="btn-confirm" @click="saveUserInfo">保存</button>
        </div>
      </div>
    </div>

    <!-- 评论区抽屉 -->
    <TrackCommentDrawer v-model="showCommentDrawer" :track="currentCommentTrack" />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, nextTick, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import { usePlayerStore } from '../stores/player'
import { userApi, playlistApi, favoriteApi, followApi, trackApi } from '../api'
import { ElMessage } from 'element-plus'
// @ts-ignore
import CoverCropper from '../components/CoverCropper.vue'
import TrackCommentDrawer from '../components/TrackCommentDrawer.vue'
import ArtistLink from '../components/ArtistLink.vue'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const playerStore = usePlayerStore()

import { DEFAULT_AVATAR_COVER } from '../constants'
const defaultAvatar = DEFAULT_AVATAR_COVER
const defaultCover = DEFAULT_AVATAR_COVER

const onCoverError = (e: Event) => {
  const el = e.target as HTMLImageElement
  if (el) el.src = defaultCover
}

const activeTab = ref('playlists')
const userInfo = ref<any>(null)
const myPlaylists = ref<any[]>([])
const favoriteTracks = ref<any[]>([])
const favorites = ref<number[]>([])
const playHistory = ref<any[]>([])
const myComments = ref<any[]>([])

const showCreatePlaylist = ref(false)
const newPlaylistName = ref('')
const newPlaylistDesc = ref('')
const newPlaylistCover = ref('')
const newPlaylistCoverFile = ref<File | null>(null)
const coverInputRef = ref<HTMLInputElement>()
const showCoverCropper = ref(false)
const coverCropperImageUrl = ref('')
const showCommentDrawer = ref(false)
const currentCommentTrack = ref<{ id: number; title?: string; artist?: string; coverUrl?: string } | null>(null)

// 头像上传
const avatarInputRef = ref<HTMLInputElement>()

// 昵称编辑
const nicknameInputRef = ref<HTMLInputElement>()
const editingNickname = ref(false)
const editNickname = ref('')
const showEditDialog = ref(false)
const editGender = ref('')
const editBirthday = ref('')
const editRegion = ref('')

// 签名编辑
const signatureInputRef = ref<HTMLInputElement>()
const editingSignature = ref(false)
const editSignature = ref('')
const avatarLoadFailed = ref(false)
const isFollowing = ref(false)
const followCounts = ref({ following: 0, followers: 0 })
const followLoading = ref(false)
const followersList = ref<any[]>([])
const followingList = ref<any[]>([])

const isMe = computed(() => {
  return !route.params.id || route.params.id === String(userStore.currentUser?.id)
})

const displayAvatar = computed(() => {
  if (avatarLoadFailed.value) return defaultAvatar
  return userInfo.value?.avatar || defaultAvatar
})

const onAvatarError = () => {
  avatarLoadFailed.value = true
}

const onFollowAvatarError = (e: Event) => {
  const el = e.target as HTMLImageElement
  if (el) el.src = defaultAvatar
}

// 根据URL参数切换标签页
watch(() => route.query.tab, (newTab) => {
  const validTabs = ['playlists', 'favorites', 'history', 'comments', 'followers', 'following']
  if (newTab && validTabs.includes(newTab as string)) {
    activeTab.value = newTab as string
  }
  if (!isMe.value && !['playlists', 'favorites', 'followers', 'following'].includes(activeTab.value)) {
    activeTab.value = 'playlists'
  }
}, { immediate: true })

// 切换标签页时刷新对应数据
watch(activeTab, (newTab) => {
  if (!isMe.value && !['playlists', 'favorites', 'followers', 'following'].includes(newTab)) {
    activeTab.value = 'playlists'
    return
  }
  if (newTab === 'favorites') {
    // 切换到收藏时重新加载，确保数据同步
    loadFavorites()
  } else if (newTab === 'playlists') {
    loadPlaylists()
  } else if (newTab === 'history') {
    loadPlayHistory()
  } else if (newTab === 'comments') {
    loadMyComments()
  } else if (newTab === 'followers') {
    loadFollowers()
  } else if (newTab === 'following') {
    loadFollowing()
  }
})

// 触发头像上传
const triggerAvatarUpload = () => {
  avatarInputRef.value?.click()
}

// 开始编辑昵称
const startEditNickname = () => {
  editNickname.value = userInfo.value?.nickname || userInfo.value?.username || ''
  editingNickname.value = true
  nextTick(() => {
    nicknameInputRef.value?.focus()
  })
}

// 保存昵称
const saveNickname = async () => {
  if (!editNickname.value.trim()) {
    editingNickname.value = false
    return
  }
  
  try {
    const res = await userApi.updateUserInfo({ nickname: editNickname.value })
    if (res.data.code === 200 && userInfo.value) {
      userInfo.value.nickname = editNickname.value
      ElMessage.success('昵称修改成功')
    }
  } catch (e) {
    console.error('Failed to save nickname:', e)
    ElMessage.error('修改失败')
  } finally {
    editingNickname.value = false
  }
}

// 开始编辑签名
const startEditSignature = () => {
  editSignature.value = userInfo.value?.signature || ''
  editingSignature.value = true
  nextTick(() => {
    signatureInputRef.value?.focus()
  })
}

// 保存签名
const saveSignature = async () => {
  try {
    const res = await userApi.updateUserInfo({ signature: editSignature.value })
    if (res.data.code === 200 && userInfo.value) {
      userInfo.value.signature = editSignature.value
      ElMessage.success('签名修改成功')
    }
  } catch (e) {
    console.error('Failed to save signature:', e)
    ElMessage.error('修改失败')
  } finally {
    editingSignature.value = false
  }
}

const goToFollowTab = (tab: 'followers' | 'following') => {
  activeTab.value = tab
  router.replace({ query: { ...route.query, tab } })
  if (tab === 'followers') loadFollowers()
  else loadFollowing()
}

const goToUserProfile = (userId: number) => {
  router.push(`/profile/${userId}`)
}

const loadFollowers = async () => {
  const targetId = route.params.id ? Number(route.params.id) : userStore.currentUser?.id
  if (!targetId) return
  try {
    const res = await followApi.getFollowers(targetId, 1, 100)
    if (res.data.code === 200) {
      const data = res.data.data
      followersList.value = data?.records || []
    }
  } catch (e) {
    console.error('Failed to load followers:', e)
    followersList.value = []
  }
}

const loadFollowing = async () => {
  const targetId = route.params.id ? Number(route.params.id) : userStore.currentUser?.id
  if (!targetId) return
  try {
    const res = await followApi.getFollowing(targetId, 1, 100)
    if (res.data.code === 200) {
      const data = res.data.data
      followingList.value = data?.records || []
    }
  } catch (e) {
    console.error('Failed to load following:', e)
    followingList.value = []
  }
}

const loadPlaylists = async () => {
  const targetId = route.params.id ? Number(route.params.id) : userStore.currentUser?.id
  if (!targetId && !userStore.currentUser) return
  try {
    if (isMe.value) {
      const res = await playlistApi.getMyPlaylists(1, 100)
      if (res.data.code === 200) {
        const data = res.data.data
        myPlaylists.value = Array.isArray(data) ? data : (data?.records || [])
        userStore.setMyPlaylists(myPlaylists.value)
      }
    } else {
      const res = await playlistApi.getUserPlaylists(targetId!, 1, 100)
      if (res.data.code === 200) {
        const data = res.data.data
        myPlaylists.value = Array.isArray(data) ? data : (data?.records || [])
      }
    }
  } catch (e) {
    console.error('Failed to load playlists:', e)
    myPlaylists.value = []
  }
}

const loadFollowData = async () => {
  const targetId = route.params.id ? Number(route.params.id) : userStore.currentUser?.id
  if (!targetId) return
  try {
    const countsRes = await followApi.getCounts(targetId)
    if (countsRes.data.code === 200) {
      followCounts.value = countsRes.data.data
    }
    if (!isMe.value && userStore.currentUser) {
      const checkRes = await followApi.isFollowing(targetId)
      if (checkRes.data.code === 200) {
        isFollowing.value = checkRes.data.data
      }
    }
  } catch (e) {
    console.error('Failed to load follow data:', e)
  }
}

const toggleFollow = async () => {
  const targetId = Number(route.params.id)
  if (!targetId || !userStore.currentUser) {
    ElMessage.warning('Please login first')
    return
  }
  followLoading.value = true
  try {
    if (isFollowing.value) {
      await followApi.unfollow(targetId)
      isFollowing.value = false
      followCounts.value.followers = Math.max(0, followCounts.value.followers - 1)
      ElMessage.success('已取消关注')
    } else {
      await followApi.follow(targetId)
      isFollowing.value = true
      followCounts.value.followers += 1
      ElMessage.success('关注成功')
    }
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || 'Operation failed')
  } finally {
    followLoading.value = false
  }
}

const loadUserInfo = async () => {
  try {
    avatarLoadFailed.value = false
    const userId = route.params.id
    if (userId) {
      // 查看其他用户的公开信息
      const res = await userApi.getUserPublicInfo(Number(userId))
      if (res.data.code === 200) {
        userInfo.value = res.data.data
      }
    } else if (userStore.currentUser) {
      // 查看自己的主页，从后端获取最新数据
      const res = await userApi.getUserInfo()
      if (res.data.code === 200) {
        userInfo.value = res.data.data
        // 同步更新 userStore
        userStore.setUser(res.data.data)
      }
    }
  } catch (e) {
    console.error('Failed to load user info:', e)
  }
}


const normalizeTrack = (t: any) => {
  const playUrl = t.playUrl || t.url
  return {
    ...t,
    coverUrl: t.coverUrl || t.cover,
    playUrl,
    url: playUrl
  }
}

const loadFavorites = async () => {
  const targetId = route.params.id ? Number(route.params.id) : userStore.currentUser?.id
  if (!targetId && !userStore.currentUser) return
  try {
    const res = isMe.value
      ? await favoriteApi.getMyFavorites(1, 1000)
      : await favoriteApi.getUserFavorites(targetId!, 1, 1000)
    if (res.data.code === 200) {
      const data = res.data.data
      const raw = Array.isArray(data) ? data : (data?.records || [])
      favoriteTracks.value = raw.map((t: any) => normalizeTrack(t))
      favorites.value = isMe.value ? favoriteTracks.value.map((t: any) => t.id) : []
      if (isMe.value) userStore.favorites = [...favorites.value]
    }
  } catch (e) {
    console.error('Failed to load favorites:', e)
    favoriteTracks.value = []
  }
}

const handleAvatarUpload = async (e: Event) => {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  
  try {
    const res = await userApi.uploadAvatar(file)
    if (res.data.code === 200 && userInfo.value) {
      (userInfo.value as any).avatar = res.data.data
    }
  } catch (e) {
    console.error('Failed to upload avatar:', e)
  }
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

const goToPlaylist = (id: number) => {
  router.push(`/playlist/${id}`)
}

const deletePlaylistFromProfile = async (playlist: any) => {
  if (!confirm(`确定删除歌单「${playlist.name}」？`)) return
  try {
    await playlistApi.delete(playlist.id)
    userStore.removePlaylist(playlist.id)
    myPlaylists.value = myPlaylists.value.filter(p => p.id !== playlist.id)
    ElMessage.success('歌单已删除')
  } catch (e: any) {
    console.error('Delete playlist failed:', e)
    ElMessage.error(e?.response?.data?.message || '删除失败')
  }
}

// 格式化生日显示
const formatBirthday = (birthday: string) => {
  if (!birthday) return ''
  const parts = birthday.split('-')
  if (parts.length === 3) {
    return `${parts[0]}年${parseInt(parts[1])}月${parseInt(parts[2])}日`
  }
  return birthday
}

// 计算年龄
const calculateAge = (birthday: string) => {
  if (!birthday) return ''
  const birthDate = new Date(birthday)
  const today = new Date()
  let age = today.getFullYear() - birthDate.getFullYear()
  const monthDiff = today.getMonth() - birthDate.getMonth()
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--
  }
  return age
}

// 监听弹窗打开，填充当前值
watch(showEditDialog, (val) => {
  if (val && userInfo.value) {
    editGender.value = userInfo.value.gender || ''
    editBirthday.value = userInfo.value.birthday || ''
    editRegion.value = userInfo.value.region || ''
  }
})

// 保存用户信息
const saveUserInfo = async () => {
  try {
    const updateData: any = {}
    if (editGender.value) updateData.gender = editGender.value
    if (editBirthday.value) updateData.birthday = editBirthday.value
    if (editRegion.value) updateData.region = editRegion.value

    await userApi.updateUserInfo(updateData)
    
    // 更新本地状态
    if (userInfo.value) {
      userInfo.value.gender = editGender.value
      userInfo.value.birthday = editBirthday.value
      userInfo.value.region = editRegion.value
    }
    
    ElMessage.success('保存成功')
    showEditDialog.value = false
  } catch (error) {
    console.error('保存用户信息失败:', error)
    ElMessage.error('保存失败')
  }
}

const playTrack = async (track: any) => {
  let targetTrack = track
  const needUrl = !track.playUrl && !track.url
  if (needUrl && track.id) {
    try {
      const res = await trackApi.getDetail(track.id)
      if (res.data.code === 200 && res.data.data) {
        const fresh = res.data.data as any
        targetTrack = normalizeTrack({ ...track, playUrl: fresh.playUrl, coverUrl: fresh.coverUrl || track.coverUrl })
        if (activeTab.value === 'favorites') {
          const idx = favoriteTracks.value.findIndex((t: any) => t.id === track.id)
          if (idx >= 0) {
            favoriteTracks.value[idx] = targetTrack
          }
        } else if (activeTab.value === 'history') {
          const idx = playHistory.value.findIndex((t: any) => t.id === track.id)
          if (idx >= 0) {
            playHistory.value[idx] = targetTrack
          }
        }
      }
    } catch (e) {
      console.error('Failed to fetch track detail:', e)
    }
  }
  if (activeTab.value === 'favorites') {
    playerStore.setPlaylistAndPlay(favoriteTracks.value, targetTrack)
  } else if (activeTab.value === 'history') {
    playerStore.setPlaylistAndPlay(playHistory.value, targetTrack)
  } else {
    playerStore.setCurrentTrack(targetTrack)
  }
}

const playLatestHistory = () => {
  if (playHistory.value.length === 0) return
  playTrack(playHistory.value[0])
}

const removeFavorite = async (trackId: number) => {
  try {
    await favoriteApi.remove(trackId)
    favoriteTracks.value = favoriteTracks.value.filter(t => t.id !== trackId)
    favorites.value = favorites.value.filter(id => id !== trackId)
    userStore.removeFavorite(trackId)
    ElMessage.success('已取消收藏')
  } catch (e) {
    console.error('Failed to remove favorite:', e)
    ElMessage.error('操作失败')
  }
}

// 加载播放历史
const loadPlayHistory = async () => {
  try {
    const targetUserId = route.params.id
    const res = targetUserId
      ? await userApi.getUserPlayHistory(Number(targetUserId), 1, 100)
      : await userApi.getPlayHistory(1, 100)
    if (res.data.code === 200) {
      const data = res.data.data
      const raw = Array.isArray(data) ? data : (data?.records || [])
      playHistory.value = raw.map((t: any) => normalizeTrack(t))
    }
  } catch (e) {
    console.error('Failed to load play history:', e)
  }
}

// 清空播放历史
const clearPlayHistory = async () => {
  try {
    await userApi.clearPlayHistory()
    playHistory.value = []
    ElMessage.success('播放历史已清空')
  } catch (e) {
    console.error('Failed to clear play history:', e)
    ElMessage.error('清空失败')
  }
}

// 加载我的评论
const loadMyComments = async () => {
  try {
    const res = await userApi.getMyComments(1, 100)
    if (res.data.code === 200) {
      const data = res.data.data
      // 处理分页数据或直接数组
      myComments.value = Array.isArray(data) ? data : (data.records || [])
    }
  } catch (e) {
    console.error('Failed to load my comments:', e)
  }
}

// 打开该歌曲的评论区
const openCommentDrawer = (comment: any) => {
  currentCommentTrack.value = {
    id: comment.trackId,
    title: comment.trackTitle,
    artist: comment.trackArtist,
    coverUrl: comment.trackCover
  }
  showCommentDrawer.value = true
}

// 删除评论
const deleteComment = async (commentId: number) => {
  try {
    await userApi.deleteComment(commentId)
    myComments.value = myComments.value.filter(c => c.id !== commentId)
    ElMessage.success('评论已删除')
  } catch (e) {
    console.error('Failed to delete comment:', e)
    ElMessage.error('删除失败')
  }
}

// 格式化播放时间
const formatPlayTime = (time: string) => {
  if (!time) return ''
  const date = new Date(time)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
  if (diff < 604800000) return `${Math.floor(diff / 86400000)}天前`
  
  return `${date.getMonth() + 1}月${date.getDate()}日`
}

// 播放评论相关的歌曲
const playTrackFromComment = (comment: any) => {
  const track = {
    id: comment.trackId,
    title: comment.trackTitle,
    artist: comment.trackArtist,
    coverUrl: comment.trackCover,
    cover: comment.trackCover,
    album: '',
    duration: 0,
    url: ''
  }
  // 从评论列表构建播放列表
  const tracksFromComments = myComments.value.map(c => ({
    id: c.trackId,
    title: c.trackTitle,
    artist: c.trackArtist,
    coverUrl: c.trackCover,
    cover: c.trackCover,
    album: '',
    duration: 0,
    url: ''
  }))
  playerStore.setPlaylistAndPlay(tracksFromComments, track as any)
}

onMounted(() => {
  if (!userStore.currentUser && !route.params.id) {
    router.push('/login')
    return
  }
  
  loadUserInfo()
  loadFollowData()
  if (isMe.value) {
    loadPlaylists()
    loadFavorites()
    loadPlayHistory()
    loadMyComments()
  } else {
    activeTab.value = 'playlists'
    loadPlaylists()
    loadFavorites()
  }
  
  // 监听页面可见性变化，当用户从其他页面返回时刷新数据
  document.addEventListener('visibilitychange', handleVisibilityChange)
})

// 监听路由参数变化，当访问不同用户主页时重新加载
watch(() => route.params.id, (newId, oldId) => {
  if (newId !== oldId) {
    loadUserInfo()
    if (isMe.value) {
      loadPlaylists()
      loadFavorites()
      loadPlayHistory()
      loadMyComments()
    } else {
      activeTab.value = 'playlists'
      loadPlaylists()
      loadFavorites()
      myPlaylists.value = []
      favoriteTracks.value = []
      myComments.value = []
    }
  }
})

// 页面可见性变化处理
const handleVisibilityChange = () => {
  if (document.visibilityState === 'visible' && isMe.value) {
    // 页面变为可见时，刷新当前标签页的数据
    if (activeTab.value === 'favorites') {
      loadFavorites()
    } else if (activeTab.value === 'playlists') {
      loadPlaylists()
    } else if (activeTab.value === 'history') {
      loadPlayHistory()
    } else if (activeTab.value === 'comments') {
      loadMyComments()
    }
  }
}

onUnmounted(() => {
  document.removeEventListener('visibilitychange', handleVisibilityChange)
})
</script>

<style scoped>
.profile-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: var(--sp-6);
  color: var(--text-primary);
  min-height: 100vh;
}

/* 头部区域 */
.profile-header {
  display: flex;
  gap: var(--sp-8);
  padding: var(--sp-6) 0;
  margin-bottom: var(--sp-6);
  position: relative;
  animation: fadeIn var(--dur-slow) var(--ease-out);
  border-bottom: 1px solid var(--border);
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.avatar-section {
  position: relative;
  flex-shrink: 0;
  cursor: pointer;
}

.avatar {
  width: 120px;
  height: 120px;
  border-radius: var(--radius-full);
  object-fit: cover;
  transition: all var(--dur-normal) var(--ease-out);
  animation: avatarPop var(--dur-slow) var(--ease-out);
}

@keyframes avatarPop {
  0% {
    transform: scale(0.8);
    opacity: 0;
  }
  50% {
    transform: scale(1.05);
  }
  100% {
    transform: scale(1);
    opacity: 1;
  }
}

.avatar-section:hover .avatar {
  transform: scale(1.03);
}

.avatar-hover-mask {
  position: absolute;
  top: 0;
  left: 0;
  width: 120px;
  height: 120px;
  border-radius: var(--radius-full);
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: var(--sp-1);
  opacity: 0;
  transition: opacity var(--dur-normal);
}

.avatar-section:hover .avatar-hover-mask {
  opacity: 1;
}

.avatar-hover-mask span {
  color: var(--text-primary);
  font-size: var(--text-sm);
  font-weight: 500;
}

.user-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

/* 昵称行样式 */
.nickname-row {
  display: flex;
  align-items: center;
  gap: var(--sp-2);
  cursor: pointer;
  padding: var(--sp-1) var(--sp-2);
  margin-left: calc(var(--sp-2) * -1);
  border-radius: var(--radius-md);
  transition: background var(--dur-fast);
}

.nickname-row:hover {
  background: var(--bg-active);
}

.nickname-row:hover .edit-icon {
  opacity: 1;
}

.edit-icon {
  opacity: 0;
  color: var(--text-secondary);
  transition: opacity var(--dur-fast);
}

.user-info h2 {
  margin: 0;
  font-size: var(--text-xl);
  font-weight: 600;
  color: var(--text-primary);
  animation: slideInLeft var(--dur-slow) var(--ease-out) 0.2s both;
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

/* 签名行样式 */
.signature-row {
  display: flex;
  align-items: center;
  gap: var(--sp-2);
  cursor: pointer;
  padding: var(--sp-1) var(--sp-2);
  margin-left: calc(var(--sp-2) * -1);
  border-radius: var(--radius-md);
  transition: background var(--dur-fast);
}

.signature-row:hover {
  background: var(--bg-active);
}

.signature-row:hover .edit-icon-small {
  opacity: 1;
}

.edit-icon-small {
  opacity: 0;
  color: var(--text-secondary);
  transition: opacity var(--dur-fast);
}

.signature {
  color: var(--text-primary);
  margin: 0 0 var(--sp-4);
  font-size: var(--text-base);
}

.visitor-actions {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
  margin: var(--sp-2) 0 var(--sp-3);
}

.follow-btn {
  padding: var(--sp-2) var(--sp-5);
  border: none;
  border-radius: var(--radius-sm);
  font-size: var(--text-sm);
  font-weight: 500;
  cursor: pointer;
  transition: all var(--dur-fast);
  background: var(--accent);
  color: var(--text-primary);
}

.follow-btn:hover:not(:disabled) {
  background: var(--accent-hover);
}

.follow-btn.following {
  background: transparent;
  color: var(--text-secondary);
}

.follow-btn.following:hover:not(:disabled) {
  color: var(--red);
}

.follow-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.visitor-tip {
  font-size: var(--text-sm);
  color: var(--text-accent);
}

/* 编辑输入框 */
.edit-input {
  background: var(--accent-muted);
  border: 2px solid var(--accent);
  border-radius: var(--radius-md);
  color: var(--text-primary);
  font-size: inherit;
  padding: var(--sp-2) var(--sp-3);
  outline: none;
  transition: all var(--dur-fast);
}

.edit-input:focus {
  background: var(--accent-muted);
  border-color: var(--accent-hover);
  box-shadow: 0 0 var(--sp-5) var(--accent-glow);
}

.nickname-input {
  font-size: var(--text-xl);
  font-weight: 700;
  min-width: 200px;
}

.signature-input {
  font-size: var(--text-base);
  min-width: 250px;
}

.user-details {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: var(--sp-2) var(--sp-4);
  margin-bottom: var(--sp-4);
  animation: slideInLeft var(--dur-slow) var(--ease-out) 0.4s both;
}

.detail-item {
  display: inline-flex;
  align-items: center;
  gap: var(--sp-1);
  font-size: var(--text-sm);
  color: var(--text-secondary);
  padding: var(--sp-1) 0;
  transition: color var(--dur-fast);
}

.detail-item:hover {
  color: var(--text-primary);
}

.detail-item svg {
  flex-shrink: 0;
  opacity: 0.7;
  color: var(--text-tertiary);
}

.stats {
  display: flex;
  align-items: baseline;
  gap: var(--sp-5);
  flex-wrap: wrap;
  animation: slideInLeft var(--dur-slow) var(--ease-out) 0.5s both;
}

.stat-item {
  display: flex;
  align-items: baseline;
  gap: var(--sp-1);
  cursor: pointer;
  transition: color var(--dur-fast);
}

.stat-item:not(.clickable) {
  cursor: default;
}

.stat-item .count {
  font-size: var(--text-lg);
  font-weight: 600;
  color: var(--text-primary);
}

.stat-item .label {
  font-size: var(--text-sm);
  color: var(--text-secondary);
  margin: 0;
}

.stat-item.clickable:hover .count,
.stat-item.clickable:hover .label {
  color: var(--accent);
}

.stat-item:not(:last-child)::after {
  content: '·';
  margin-left: var(--sp-4);
  color: var(--text-tertiary);
  font-weight: 400;
}

/* 标签页 */
.profile-tabs {
  display: flex;
  gap: var(--sp-1);
  margin-bottom: var(--sp-5);
  padding-bottom: var(--sp-2);
  border-bottom: 1px solid var(--border);
  animation: fadeIn var(--dur-slow) var(--ease-out) 0.3s both;
}

.tab {
  padding: var(--sp-2) var(--sp-4);
  border: none;
  background: transparent;
  color: var(--text-secondary);
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: all var(--dur-fast);
  font-size: var(--text-sm);
  font-weight: 500;
}

.tab:hover {
  color: var(--text-primary);
  background: var(--bg-hover);
}

.tab.active {
  color: var(--accent);
  background: transparent;
}

.quick-actions {
  display: flex;
  gap: var(--sp-3);
  margin-bottom: var(--sp-5);
  flex-wrap: wrap;
}

.quick-btn {
  border: none;
  background: transparent;
  color: var(--text-secondary);
  padding: var(--sp-1) var(--sp-3);
  font-size: var(--text-sm);
  cursor: pointer;
  transition: color var(--dur-fast);
}

.quick-btn:hover:not(:disabled) {
  color: var(--accent);
}

.quick-btn.primary {
  color: var(--accent);
}

.quick-btn.primary:hover:not(:disabled) {
  color: var(--accent-hover);
}

.quick-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* 内容区域 */
.content-section {
  padding: var(--sp-6) 0;
  animation: fadeIn var(--dur-slow) var(--ease-out) 0.4s both;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--sp-5);
}

.section-header h3 {
  margin: 0;
  font-size: var(--text-base);
  font-weight: 600;
  color: var(--text-primary);
}

.create-btn {
  padding: var(--sp-2) var(--sp-4);
  border: none;
  background: var(--accent);
  color: var(--text-primary);
  border-radius: var(--radius-sm);
  cursor: pointer;
  font-size: var(--text-sm);
  font-weight: 500;
  transition: all var(--dur-fast);
  display: flex;
  align-items: center;
}

.create-btn:hover {
  background: var(--accent-hover);
}

/* 歌单网格 */
.playlist-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: var(--sp-4);
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
  animation: fadeInUp var(--dur-slow) var(--ease-out) forwards;
  opacity: 0;
}

.playlist-card {
  background: transparent;
  border-radius: var(--radius-md);
  overflow: hidden;
  cursor: pointer;
  transition: all var(--dur-normal) var(--ease-out);
}

.playlist-card:hover {
  transform: translateY(-4px);
}

.cover-wrapper {
  position: relative;
  aspect-ratio: 1;
  overflow: hidden;
}

.playlist-card .cover {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform var(--dur-slow) var(--ease-out);
}

.playlist-card:hover .cover {
  transform: scale(1.1);
}

.play-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(180deg, rgba(0,0,0,0) 0%, rgba(0,0,0,0.7) 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity var(--dur-normal);
}

.playlist-card:hover .play-overlay {
  opacity: 1;
}

.play-btn-circle {
  width: 50px;
  height: 50px;
  border-radius: var(--radius-full);
  background: rgba(255, 255, 255, 0.95);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--accent);
  transform: scale(0.8);
  transition: all var(--dur-normal);
  box-shadow: var(--shadow-sm);
}

.playlist-card:hover .play-btn-circle {
  transform: scale(1);
}

.play-btn-circle:hover {
  transform: scale(1.1);
  background: var(--text-primary);
}

.playlist-card .info {
  padding: var(--sp-3);
  position: relative;
}

.playlist-delete-btn {
  position: absolute;
  top: var(--sp-1);
  right: var(--sp-1);
  width: 24px;
  height: 24px;
  padding: 0;
  border: none;
  border-radius: var(--radius-sm);
  background: transparent;
  color: var(--text-tertiary);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0.7;
  transition: all var(--dur-fast);
}

.playlist-delete-btn:hover {
  opacity: 1;
  color: var(--red);
}

.playlist-card h4 {
  margin: 0 0 var(--sp-1);
  font-size: var(--text-base);
  font-weight: 600;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  color: var(--text-primary);
}

.playlist-card p {
  margin: 0;
  font-size: var(--text-xs);
  color: var(--text-secondary);
}

/* 音乐列表美化 */
.track-list {
  display: flex;
  flex-direction: column;
  gap: var(--sp-3);
}

.slide-in-left {
  animation: slideInLeft 0.4s var(--ease-out) forwards;
  opacity: 0;
}

.track-item {
  display: flex;
  align-items: center;
  gap: var(--sp-4);
  padding: var(--sp-3) var(--sp-4);
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all var(--dur-fast);
}

.track-item:hover {
  background: var(--bg-hover);
}

.track-cover {
  width: 48px;
  height: 48px;
  border-radius: var(--radius-sm);
  object-fit: cover;
  transition: transform var(--dur-fast);
}

.track-item:hover .track-cover {
  transform: scale(1.02);
}

.track-info {
  flex: 1;
}

.track-info h4 {
  margin: 0 0 var(--sp-1);
  font-size: var(--text-base);
  font-weight: 500;
  color: var(--text-primary);
}

.track-info p {
  margin: 0;
  font-size: var(--text-sm);
  color: var(--text-secondary);
}

.play-btn {
  width: 40px;
  height: 40px;
  padding: 0;
  border: none;
  background: var(--accent-muted);
  color: var(--text-primary);
  cursor: pointer;
  border-radius: var(--radius-full);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all var(--dur-normal);
}

.play-btn:hover {
  background: var(--accent);
  color: var(--text-primary);
  transform: scale(1.1);
}

.remove-btn {
  width: 36px;
  height: 36px;
  padding: 0;
  border: none;
  background: transparent;
  color: var(--text-tertiary);
  cursor: pointer;
  border-radius: var(--radius-full);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all var(--dur-normal);
}

.remove-btn:hover {
  color: var(--red);
  background: rgba(239, 68, 68, 0.15);
}

/* 收藏列表中的爱心：已收藏状态显示为红色 */
.remove-btn.liked {
  color: var(--red);
}

.empty {
  text-align: center;
  padding: var(--sp-12);
  color: var(--text-tertiary);
  font-size: var(--text-sm);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.empty svg {
  color: var(--accent-muted);
}

/* 粉丝/关注列表 */
.follow-list {
  display: flex;
  flex-direction: column;
  gap: var(--sp-3);
}

.follow-item {
  display: flex;
  align-items: center;
  gap: var(--sp-4);
  padding: var(--sp-3) var(--sp-4);
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all var(--dur-fast);
}

.follow-item:hover {
  background: var(--bg-hover);
}

.follow-item .user-avatar {
  width: 48px;
  height: 48px;
  border-radius: var(--radius-full);
  object-fit: cover;
}

.follow-item .user-info-mini {
  flex: 1;
  min-width: 0;
}

.follow-item .user-info-mini h4 {
  font-size: var(--text-base);
  margin: 0;
  color: var(--text-primary);
}

.follow-item .user-signature {
  font-size: var(--text-sm);
  color: var(--text-secondary);
  margin: var(--sp-1) 0 0;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.follow-item .go-arrow {
  color: var(--text-tertiary);
  font-size: var(--text-lg);
}

/* 弹窗美化 */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.85);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  animation: modalFadeIn var(--dur-normal) var(--ease-out);
}

@keyframes modalFadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.modal-content {
  background: var(--bg-elevated);
  padding: var(--sp-9);
  border-radius: var(--radius-xl);
  width: 90%;
  max-width: 420px;
  border: 1px solid var(--border-accent);
  box-shadow: var(--shadow-lg);
  animation: modalSlideIn var(--dur-normal) var(--ease-out);
}

@keyframes modalSlideIn {
  from {
    opacity: 0;
    transform: translateY(-30px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.modal-content h3 {
  margin: 0 0 var(--sp-6);
  font-size: var(--text-lg);
  font-weight: 600;
  color: var(--text-primary);
}

.modal-content input,
.modal-content textarea {
  width: 100%;
  padding: var(--sp-3) var(--sp-4);
  margin-bottom: var(--sp-4);
  border: 1px solid var(--border-accent);
  border-radius: var(--radius-md);
  background: var(--bg-card);
  color: var(--text-primary);
  font-size: var(--text-base);
  transition: all var(--dur-normal);
}

.modal-content input:focus,
.modal-content textarea:focus {
  outline: none;
  border-color: var(--accent);
  background: var(--bg-elevated);
  box-shadow: 0 0 var(--sp-5) var(--accent-glow);
}

.modal-content input::placeholder,
.modal-content textarea::placeholder {
  color: var(--text-tertiary);
}

.modal-actions {
  display: flex;
  gap: var(--sp-3);
  justify-content: flex-end;
}

.modal-actions button {
  padding: var(--sp-3) var(--sp-6);
  border: none;
  border-radius: var(--radius-md);
  cursor: pointer;
  font-size: var(--text-base);
  font-weight: 500;
  transition: all var(--dur-normal);
}

.modal-actions button:not(.primary) {
  background: var(--bg-hover);
  color: var(--text-primary);
}

.modal-actions button:not(.primary):hover {
  background: var(--bg-active);
}

.modal-actions button.primary {
  background: var(--accent);
  color: var(--text-primary);
  box-shadow: 0 var(--sp-1) var(--sp-4) var(--accent-glow);
}

.modal-actions button.primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 var(--sp-2) var(--sp-5) var(--accent-glow);
}

/* 响应式 */
@media (max-width: 768px) {
  .profile-header {
    flex-direction: column;
    align-items: center;
    text-align: center;
    padding: var(--sp-8) var(--sp-5);
  }
  
  .user-details {
    justify-content: center;
  }
  
  .stats {
    justify-content: center;
  }
  
  .playlist-grid {
    grid-template-columns: repeat(4, 1fr);
    gap: var(--sp-4);
  }
}

@media (max-width: 900px) {
  .playlist-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 600px) {
  .playlist-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

/* 播放历史样式 */
.clear-btn {
  padding: var(--sp-2) var(--sp-3);
  border: none;
  background: transparent;
  color: var(--red);
  border-radius: var(--radius-sm);
  cursor: pointer;
  font-size: var(--text-sm);
  display: flex;
  align-items: center;
  transition: color var(--dur-fast);
}

.clear-btn:hover {
  color: var(--red);
  opacity: 0.9;
}

.play-time {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
  margin-right: var(--sp-3);
}

/* 我的评论样式 */
.my-comment-item {
  display: flex;
  flex-direction: column;
  gap: var(--sp-2);
  padding: var(--sp-3) var(--sp-4);
  border-radius: var(--radius-md);
  margin-bottom: var(--sp-2);
  transition: all var(--dur-fast);
  cursor: pointer;
}

.my-comment-item:hover {
  background: var(--bg-hover);
}

.comment-track {
  display: flex;
  align-items: center;
  gap: var(--sp-3);
  cursor: pointer;
  padding: var(--sp-2);
  border-radius: var(--radius-sm);
  transition: all var(--dur-fast);
}

.track-cover-small {
  width: 45px;
  height: 45px;
  border-radius: var(--radius-sm);
  object-fit: cover;
}

.track-info-small {
  flex: 1;
}

.track-info-small h4 {
  margin: 0;
  font-size: var(--text-base);
  color: var(--text-primary);
}

.track-info-small p {
  margin: var(--sp-1) 0 0;
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

.comment-content-area {
  padding-left: var(--sp-2);
}

.comment-content-area p {
  margin: 0 0 var(--sp-2);
  font-size: var(--text-base);
  color: var(--text-primary);
  line-height: 1.6;
}

.comment-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.comment-meta .time {
  font-size: var(--text-xs);
  color: var(--text-tertiary);
}

.delete-btn {
  background: none;
  border: none;
  color: var(--text-tertiary);
  font-size: var(--text-xs);
  cursor: pointer;
  padding: var(--sp-1) var(--sp-2);
  border-radius: var(--radius-sm);
  transition: all var(--dur-fast);
}

.delete-btn:hover {
  color: var(--red);
  background: rgba(239, 68, 68, 0.15);
}

/* 编辑信息弹窗样式 */
.modal-overlay {
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
  animation: fadeIn var(--dur-normal) var(--ease-out);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--sp-5) var(--sp-6);
  border-bottom: 1px solid var(--border);
}

.modal-header h3 {
  margin: 0;
  color: var(--text-primary);
  font-size: var(--text-md);
  font-weight: 600;
}

.close-btn {
  background: none;
  border: none;
  color: var(--text-tertiary);
  font-size: var(--text-xl);
  cursor: pointer;
  padding: 0;
  line-height: 1;
  transition: color var(--dur-fast);
}

.close-btn:hover {
  color: var(--text-primary);
}

.modal-body {
  padding: var(--sp-6);
}

.modal-body .form-group {
  margin-bottom: var(--sp-5);
}

.modal-body .form-group:last-child {
  margin-bottom: 0;
}

.modal-body label {
  display: block;
  color: var(--text-accent);
  font-size: var(--text-base);
  margin-bottom: var(--sp-2);
  font-weight: 500;
}

.gender-options {
  display: flex;
  gap: var(--sp-3);
}

.gender-option {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--sp-3);
  background: var(--bg-hover);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all var(--dur-normal);
}

.gender-option input {
  display: none;
}

.gender-option span {
  color: var(--text-tertiary);
  font-size: var(--text-base);
}

.gender-option:hover {
  border-color: var(--border-accent);
  background: var(--accent-muted);
}

.gender-option.selected {
  border-color: var(--accent);
  background: var(--accent-muted);
}

.gender-option.selected span {
  color: var(--text-primary);
}

.form-input {
  width: 100%;
  padding: var(--sp-3) var(--sp-4);
  background: var(--bg-hover);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  color: var(--text-primary);
  font-size: var(--text-base);
  transition: all var(--dur-normal);
  box-sizing: border-box;
}

.form-input:focus {
  outline: none;
  border-color: var(--accent);
  background: var(--accent-muted);
}

.form-input::placeholder {
  color: var(--text-tertiary);
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: var(--sp-3);
  padding: var(--sp-4) var(--sp-6);
  border-top: 1px solid var(--border);
}

.btn-cancel,
.btn-confirm {
  padding: var(--sp-2) var(--sp-5);
  border-radius: var(--radius-sm);
  font-size: var(--text-base);
  font-weight: 500;
  cursor: pointer;
  transition: all var(--dur-normal);
}

.btn-cancel {
  background: var(--bg-hover);
  border: 1px solid var(--border);
  color: var(--text-tertiary);
}

.btn-cancel:hover {
  background: var(--bg-active);
  color: var(--text-primary);
}

.btn-confirm {
  background: var(--accent);
  border: none;
  color: var(--text-primary);
}

.btn-confirm:hover {
  transform: translateY(-2px);
  box-shadow: 0 var(--sp-1) var(--sp-4) var(--accent-glow);
}

/* 新建歌单弹窗样式 */
.create-playlist-modal {
  max-width: 480px;
}

.cover-upload-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--sp-3);
  margin-bottom: var(--sp-5);
}

.edit-cover-btn {
  display: flex;
  align-items: center;
  gap: var(--sp-1);
  padding: var(--sp-2) var(--sp-4);
  background: var(--accent-muted);
  border: 1px solid var(--border-accent);
  border-radius: var(--radius-sm);
  color: var(--text-accent);
  font-size: var(--text-sm);
  cursor: pointer;
  transition: all var(--dur-normal);
}

.edit-cover-btn:hover {
  background: var(--accent-muted);
  border-color: var(--accent);
}

.cover-preview {
  width: 160px;
  height: 160px;
  border-radius: var(--radius-md);
  overflow: hidden;
  cursor: pointer;
  background: var(--bg-hover);
  border: 2px dashed var(--border-hover);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all var(--dur-normal);
}

.cover-preview:hover {
  border-color: var(--accent);
  background: var(--accent-muted);
}

.cover-preview img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.cover-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--sp-2);
  color: var(--text-tertiary);
}

.cover-placeholder svg {
  opacity: 0.5;
}

.cover-placeholder span {
  font-size: var(--text-sm);
}

.form-textarea {
  width: 100%;
  min-height: 80px;
  padding: var(--sp-3) var(--sp-4);
  background: var(--bg-hover);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  color: var(--text-primary);
  font-size: var(--text-base);
  resize: vertical;
  transition: all var(--dur-normal);
  box-sizing: border-box;
}

.form-textarea:focus {
  outline: none;
  border-color: var(--accent);
  background: var(--accent-muted);
}

.form-textarea::placeholder {
  color: var(--text-tertiary);
}
</style>