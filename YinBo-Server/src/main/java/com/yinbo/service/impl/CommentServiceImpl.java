package com.yinbo.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.yinbo.dto.CommentDTO;
import com.yinbo.entity.Comment;
import com.yinbo.entity.CommentLike;
import com.yinbo.entity.Track;
import com.yinbo.entity.User;
import com.yinbo.mapper.CommentLikeMapper;
import com.yinbo.mapper.CommentMapper;
import com.yinbo.mapper.TrackMapper;
import com.yinbo.mapper.UserMapper;
import com.yinbo.service.CommentService;
import com.yinbo.service.MinioService;
import com.yinbo.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class CommentServiceImpl extends ServiceImpl<CommentMapper, Comment> implements CommentService {
    
    private final CommentMapper commentMapper;
    private final CommentLikeMapper commentLikeMapper;
    private final UserMapper userMapper;
    private final TrackMapper trackMapper;
    private final MinioService minioService;
    private final NotificationService notificationService;
    
    @Override
    @Transactional
    public Comment addComment(Long trackId, Long userId, String content, Long parentId, Long replyToUserId) {
        Track track = trackMapper.selectById(trackId);
        if (track == null || track.getStatus() != 1) {
            throw new RuntimeException("Track not found or not published");
        }
        
        if (parentId != null) {
            Comment parentComment = commentMapper.selectById(parentId);
            if (parentComment == null) {
                throw new RuntimeException("Parent comment not found");
            }
        }
        
        // Calculate floor number for main comments
        int floor = 0;
        if (parentId == null) {
            LambdaQueryWrapper<Comment> countWrapper = new LambdaQueryWrapper<>();
            countWrapper.eq(Comment::getTrackId, trackId)
                        .isNull(Comment::getParentId)
                        .eq(Comment::getDeleted, 0);
            floor = Math.toIntExact(commentMapper.selectCount(countWrapper)) + 1;
        }
        
        Comment comment = new Comment();
        comment.setTrackId(trackId);
        comment.setUserId(userId);
        comment.setContent(content);
        comment.setParentId(parentId);
        comment.setFloor(floor);
        comment.setLikeCount(0);
        // Publish immediately.
        comment.setStatus(1);
        comment.setDeleted(0);
        
        commentMapper.insert(comment);
        log.info("User {} added comment to track {}", userId, trackId);

        if (parentId != null) {
            // 回复评论：通知被回复者
            Comment parent = commentMapper.selectById(parentId);
            if (parent != null) {
                Long notifyUserId = (replyToUserId != null && !replyToUserId.equals(userId))
                    ? replyToUserId
                    : parent.getUserId();
                if (!notifyUserId.equals(userId)) {
                    notificationService.create(notifyUserId, userId, "COMMENT_REPLY", comment.getId(), "comment", String.valueOf(trackId));
                }
            }
        } else {
            // 一级评论：通知歌曲上传者
            Long uploaderId = track.getUploaderId();
            if (uploaderId != null && !uploaderId.equals(userId)) {
                notificationService.create(uploaderId, userId, "COMMENT", comment.getId(), "comment", String.valueOf(trackId));
            }
        }
        
        return comment;
    }
    
    @Override
    @Transactional
    public void deleteComment(Long commentId, Long userId) {
        Comment comment = commentMapper.selectById(commentId);
        if (comment == null || comment.getDeleted() == 1) {
            throw new RuntimeException("Comment not found");
        }
        
        if (!comment.getUserId().equals(userId)) {
            throw new RuntimeException("Access denied");
        }
        
        comment.setDeleted(1);
        commentMapper.updateById(comment);
        log.info("User {} deleted comment {}", userId, commentId);
    }
    
    @Override
    public IPage<CommentDTO> getTrackComments(Long trackId, int page, int size) {
        LambdaQueryWrapper<Comment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Comment::getTrackId, trackId)
               .isNull(Comment::getParentId)
               .eq(Comment::getStatus, 1)
               .eq(Comment::getDeleted, 0)
               .orderByDesc(Comment::getFloor);
        
        IPage<Comment> commentPage = commentMapper.selectPage(new Page<>(page, size), wrapper);
        
        return convertToDTOPage(commentPage, null);
    }
    
    @Override
    public IPage<CommentDTO> getTrackComments(Long trackId, int page, int size, Long currentUserId) {
        LambdaQueryWrapper<Comment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Comment::getTrackId, trackId)
               .isNull(Comment::getParentId)
               .eq(Comment::getStatus, 1)
               .eq(Comment::getDeleted, 0)
               .orderByDesc(Comment::getFloor);
        
        IPage<Comment> commentPage = commentMapper.selectPage(new Page<>(page, size), wrapper);
        
        return convertToDTOPage(commentPage, currentUserId);
    }
    
    @Override
    public IPage<CommentDTO> getReplies(Long commentId, int page, int size) {
        LambdaQueryWrapper<Comment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Comment::getParentId, commentId)
               .eq(Comment::getStatus, 1)
               .eq(Comment::getDeleted, 0)
               .orderByAsc(Comment::getCreatedAt);
        
        IPage<Comment> commentPage = commentMapper.selectPage(new Page<>(page, size), wrapper);
        
        return convertToDTOPage(commentPage, null);
    }
    
    @Override
    @Transactional
    public void likeComment(Long commentId, Long userId) {
        Comment comment = commentMapper.selectById(commentId);
        if (comment == null || comment.getDeleted() == 1) {
            throw new RuntimeException("Comment not found");
        }
        
        // Check if already liked
        if (commentLikeMapper.checkUserLiked(userId, commentId) > 0) {
            throw new RuntimeException("Already liked this comment");
        }
        
        // Add like record
        CommentLike like = new CommentLike();
        like.setUserId(userId);
        like.setCommentId(commentId);
        commentLikeMapper.insert(like);
        
        // Update like count
        comment.setLikeCount(comment.getLikeCount() + 1);
        commentMapper.updateById(comment);

        if (!comment.getUserId().equals(userId)) {
            notificationService.create(comment.getUserId(), userId, "LIKE", commentId, "comment", String.valueOf(comment.getTrackId()));
        }
        
        log.info("User {} liked comment {}", userId, commentId);
    }
    
    @Override
    @Transactional
    public void unlikeComment(Long commentId, Long userId) {
        Comment comment = commentMapper.selectById(commentId);
        if (comment == null) {
            throw new RuntimeException("Comment not found");
        }
        
        // Check if liked
        if (commentLikeMapper.checkUserLiked(userId, commentId) == 0) {
            throw new RuntimeException("Haven't liked this comment");
        }
        
        // Remove like record
        LambdaQueryWrapper<CommentLike> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CommentLike::getUserId, userId)
               .eq(CommentLike::getCommentId, commentId);
        commentLikeMapper.delete(wrapper);
        
        // Update like count
        comment.setLikeCount(Math.max(0, comment.getLikeCount() - 1));
        commentMapper.updateById(comment);
        
        log.info("User {} unliked comment {}", userId, commentId);
    }
    
    @Override
    @Transactional
    public void auditComment(Long commentId, int status, Long operatorId) {
        Comment comment = commentMapper.selectById(commentId);
        if (comment == null) {
            throw new RuntimeException("Comment not found");
        }
        
        comment.setStatus(status);
        commentMapper.updateById(comment);
        log.info("Admin {} audited comment {} with status {}", operatorId, commentId, status);
    }

    @Override
    public IPage<CommentDTO> getPendingComments(int page, int size) {
        LambdaQueryWrapper<Comment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Comment::getStatus, 0)
               .eq(Comment::getDeleted, 0)
               .orderByDesc(Comment::getCreatedAt);

        IPage<Comment> commentPage = commentMapper.selectPage(new Page<>(page, size), wrapper);
        return convertToDTOPage(commentPage, null);
    }

    @Override
    public IPage<CommentDTO> getAllComments(int page, int size, Long trackId) {
        LambdaQueryWrapper<Comment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Comment::getDeleted, 0)
               .orderByDesc(Comment::getCreatedAt);
        if (trackId != null) {
            wrapper.eq(Comment::getTrackId, trackId);
        }
        IPage<Comment> commentPage = commentMapper.selectPage(new Page<>(page, size), wrapper);
        return convertToDTOPageForAdmin(commentPage);
    }

    @Override
    @Transactional
    public void adminDeleteComment(Long commentId, Long operatorId) {
        Comment comment = commentMapper.selectById(commentId);
        if (comment == null || comment.getDeleted() == 1) {
            throw new RuntimeException("Comment not found");
        }
        commentMapper.logicalDeleteById(commentId);
        log.info("Admin {} deleted comment {}", operatorId, commentId);
    }
    
    private CommentDTO toDTO(Comment comment, Long currentUserId, boolean loadReplies) {
        CommentDTO dto = new CommentDTO();
        dto.setId(comment.getId());
        dto.setTrackId(comment.getTrackId());
        dto.setUserId(comment.getUserId());
        dto.setContent(comment.getContent());
        dto.setParentId(comment.getParentId());
        dto.setFloor(comment.getFloor());
        dto.setLikeCount(comment.getLikeCount());
        
        // Check if current user has liked this comment
        if (currentUserId != null) {
            dto.setIsLiked(commentLikeMapper.checkUserLiked(currentUserId, comment.getId()) > 0);
        } else {
            dto.setIsLiked(false);
        }
        
        // Count replies and load first few replies for main comments
        if (comment.getParentId() == null) {
            LambdaQueryWrapper<Comment> replyWrapper = new LambdaQueryWrapper<>();
            replyWrapper.eq(Comment::getParentId, comment.getId())
                       .eq(Comment::getStatus, 1)
                       .eq(Comment::getDeleted, 0)
                       .orderByAsc(Comment::getCreatedAt);
            
            int replyCount = Math.toIntExact(commentMapper.selectCount(replyWrapper));
            dto.setReplyCount(replyCount);
            
            // Auto-load first 3 replies
            if (loadReplies && replyCount > 0) {
                replyWrapper.last("LIMIT 3");
                List<Comment> replies = commentMapper.selectList(replyWrapper);
                List<CommentDTO> replyDTOs = replies.stream()
                    .map(reply -> toDTO(reply, currentUserId, false))
                    .collect(Collectors.toList());
                dto.setReplies(replyDTOs);
            }
        }
        
        User user = userMapper.selectById(comment.getUserId());
        if (user != null) {
            dto.setUsername(user.getUsername());
            dto.setUserNickname(user.getNickname());
            if (user.getAvatar() != null && !user.getAvatar().isEmpty()) {
                dto.setUserAvatar(minioService.getAvatarUrl(user.getAvatar()));
            }
        }
        
        if (comment.getCreatedAt() != null) {
            dto.setCreatedAt(comment.getCreatedAt().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        }
        
        return dto;
    }
    
    private IPage<CommentDTO> convertToDTOPage(IPage<Comment> commentPage, Long currentUserId) {
        List<CommentDTO> dtoList = commentPage.getRecords().stream()
                .map(comment -> toDTO(comment, currentUserId, true))
                .collect(Collectors.toList());
        
        Page<CommentDTO> dtoPage = new Page<>(commentPage.getCurrent(), commentPage.getSize(), commentPage.getTotal());
        dtoPage.setRecords(dtoList);
        return dtoPage;
    }

    private IPage<CommentDTO> convertToDTOPageForAdmin(IPage<Comment> commentPage) {
        List<CommentDTO> dtoList = commentPage.getRecords().stream()
                .map(this::toDTOForAdmin)
                .collect(Collectors.toList());
        Page<CommentDTO> dtoPage = new Page<>(commentPage.getCurrent(), commentPage.getSize(), commentPage.getTotal());
        dtoPage.setRecords(dtoList);
        return dtoPage;
    }

    private CommentDTO toDTOForAdmin(Comment comment) {
        CommentDTO dto = toDTO(comment, null, false);
        Track track = trackMapper.selectById(comment.getTrackId());
        if (track != null) {
            dto.setTrackTitle(track.getTitle());
            dto.setTrackArtist(track.getArtist());
        }
        return dto;
    }
}
