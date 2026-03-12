<template>
  <el-drawer
    :model-value="modelValue"
    @update:model-value="$emit('update:modelValue', $event)"
    :title="(track?.title || '歌曲') + ' - 评论'"
    direction="rtl"
    size="450px"
    class="comment-drawer"
  >
    <div v-if="track" class="drawer-body">
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

    <!-- 回复输入区 -->
    <div v-if="replyingTo" class="reply-input-area">
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
    </div>
  </el-drawer>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Loading } from '@element-plus/icons-vue'
import { useUserStore } from '../stores/user'
import { commentApi } from '../api'

const props = defineProps<{
  modelValue: boolean
  track: { id: number; title?: string } | null
}>()

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
}>()

const router = useRouter()
const userStore = useUserStore()
import { DEFAULT_AVATAR_COVER } from '../constants'
const defaultAvatar = DEFAULT_AVATAR_COVER

const comments = ref<any[]>([])
const commentTotal = ref(0)
const loadingComments = ref(false)
const newCommentContent = ref('')
const submittingComment = ref(false)
const replyingTo = ref<any>(null)
const replyContent = ref('')
const submittingReply = ref(false)
const currentUserId = computed(() => userStore.currentUser?.id)

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
  const replies = Array.isArray(comment?.replies) ? comment.replies.map((r: any) => normalizeReply(r)) : []
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

const handleAvatarLoadError = (e: Event) => {
  const target = e.target as HTMLImageElement
  target.onerror = null
  target.src = defaultAvatar
}

const loadComments = async () => {
  if (!props.track) return
  loadingComments.value = true
  try {
    const res = await commentApi.getList(props.track.id)
    if (res.data.code === 200) {
      const records = res.data.data.records || []
      comments.value = records.map((item: any, i: number) => normalizeComment(item, i))
      commentTotal.value = res.data.data.total || 0
    }
  } catch (e) {
    console.error('Load comments error:', e)
  } finally {
    loadingComments.value = false
  }
}

watch(
  () => [props.modelValue, props.track] as const,
  ([visible, track]) => {
    if (visible && track) {
      loadComments()
    }
  },
  { immediate: true }
)

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

const submitComment = async () => {
  if (!userStore.currentUser) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }
  if (!props.track || !newCommentContent.value.trim()) return
  submittingComment.value = true
  try {
    const res = await commentApi.create({ trackId: props.track.id, content: newCommentContent.value.trim() })
    if (res.data.code === 200) {
      ElMessage.success('评论发布成功')
      newCommentContent.value = ''
      await loadComments()
    }
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || '评论失败')
  } finally {
    submittingComment.value = false
  }
}

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
  } catch (e) {
    comment.isLiked = oldLiked
    comment.likeCount = oldCount
    ElMessage.error('操作失败')
  }
}

const replyToComment = (comment: any) => {
  replyingTo.value = comment
  replyContent.value = ''
}

const cancelReply = () => {
  replyingTo.value = null
  replyContent.value = ''
}

const submitReply = async () => {
  if (!replyingTo.value || !replyContent.value.trim() || !props.track) return
  const rootId = replyingTo.value.parentId ?? replyingTo.value.id
  const isReplyToReply = replyingTo.value.parentId != null
  const nickname = replyingTo.value.userNickname || replyingTo.value.nickname || replyingTo.value.username || '用户'
  const content = isReplyToReply
    ? `回复 @${nickname}: ${replyContent.value.trim()}`
    : replyContent.value.trim()
  submittingReply.value = true
  try {
    const res = await commentApi.create({
      trackId: props.track.id,
      content,
      parentId: rootId,
      replyToUserId: isReplyToReply ? replyingTo.value.userId : undefined
    })
    if (res.data.code === 200) {
      ElMessage.success('回复发布成功')
      cancelReply()
      await loadComments()
    }
  } catch (e: any) {
    ElMessage.error('回复失败')
  } finally {
    submittingReply.value = false
  }
}

const deleteMyComment = async (id: number) => {
  try {
    await commentApi.delete(id)
    comments.value = comments.value.filter(c => c.id !== id)
    commentTotal.value--
    ElMessage.success('评论已删除')
  } catch (e) {
    ElMessage.error('删除失败')
  }
}

const deleteReply = async (comment: any, replyId: number) => {
  try {
    await commentApi.delete(replyId)
    if (comment.replies) comment.replies = comment.replies.filter((r: any) => r.id !== replyId)
    comment.replyCount = Math.max(0, (comment.replyCount || 0) - 1)
    ElMessage.success('回复已删除')
  } catch (e) {
    ElMessage.error('删除失败')
  }
}

const loadMoreReplies = async (comment: any) => {
  try {
    const res = await commentApi.getReplies(comment.id)
    if (res.data.code === 200) {
      comment.replies = (res.data.data.records || []).map((r: any) => normalizeReply(r))
    }
  } catch (e) {
    console.error('Load replies error:', e)
  }
}

const goToUserProfile = (userId: number) => {
  if (userId === userStore.currentUser?.id) {
    router.push('/profile')
  } else {
    router.push(`/profile/${userId}`)
  }
}
</script>

<style scoped>
.drawer-body {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.comment-container {
  display: flex;
  flex-direction: column;
  flex: 1;
  min-height: 0;
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
}

.comment-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.comment-body { flex: 1; min-width: 0; }

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

.comment-header-row .username:hover { color: var(--accent); }

.comment-header-row .floor {
  font-size: var(--text-xs);
  color: var(--text-accent);
  background: var(--accent-muted);
  padding: 2px var(--sp-2);
  border-radius: var(--radius-full);
}

.comment-content {
  font-size: var(--text-base);
  color: var(--text-primary);
  line-height: 1.7;
  margin-bottom: 10px;
}

.comment-footer {
  display: flex;
  align-items: center;
  gap: var(--sp-4);
}

.comment-footer .time { font-size: var(--text-xs); color: var(--text-tertiary); }

.actions { display: flex; gap: var(--sp-3); }

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
}

.action-btn:hover { background: var(--bg-active); }
.action-btn.delete { color: var(--text-tertiary); }
.action-btn.delete:hover { color: var(--red); }
.action-btn svg.liked { color: var(--accent); }

.replies-list {
  margin-top: var(--sp-3);
  padding: var(--sp-3);
  background: var(--bg-active);
  border-radius: var(--radius-md);
}

.reply-item { display: flex; gap: 10px; margin-bottom: var(--sp-3); }
.reply-item:last-child { margin-bottom: 0; }

.reply-avatar {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  overflow: hidden;
  cursor: pointer;
  flex-shrink: 0;
}

.reply-avatar img { width: 100%; height: 100%; object-fit: cover; }

.reply-content { flex: 1; min-width: 0; }
.reply-header { margin-bottom: 4px; }
.reply-user {
  font-size: var(--text-sm);
  font-weight: 600;
  color: var(--text-primary);
  cursor: pointer;
}
.reply-user:hover { color: var(--accent); }
.reply-text { font-size: var(--text-sm); color: var(--text-primary); margin-left: var(--sp-2); }
.reply-meta { display: flex; align-items: center; gap: var(--sp-3); }
.reply-time { font-size: var(--text-xs); color: var(--text-secondary); }
.delete-reply-btn {
  background: none;
  border: none;
  color: var(--text-tertiary);
  font-size: var(--text-xs);
  cursor: pointer;
}
.delete-reply-btn:hover { color: var(--red); }

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

.empty-comments {
  text-align: center;
  padding: var(--sp-10);
  color: var(--text-tertiary);
}

.empty-comments svg { margin-bottom: var(--sp-3); opacity: 0.5; }

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
}

.cancel-reply {
  background: none;
  border: none;
  color: var(--accent);
  cursor: pointer;
  font-size: var(--text-sm);
}
</style>

<style>
.comment-drawer .el-drawer { background: var(--bg-secondary) !important; }
.comment-drawer .el-drawer__header {
  color: var(--text-primary) !important;
  background: var(--bg-secondary) !important;
  border-bottom: 1px solid var(--border);
}
.comment-drawer .el-drawer__body { background: var(--bg-secondary) !important; padding: 0; }
.comment-drawer .el-textarea__inner {
  background: var(--bg-hover) !important;
  border-color: var(--border-hover) !important;
  color: var(--text-primary) !important;
}
</style>
