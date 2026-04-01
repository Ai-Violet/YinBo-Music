package com.yinbo.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.yinbo.dto.AdminCommentUserStatDTO;
import com.yinbo.dto.CommentDTO;
import com.yinbo.entity.Comment;

/**
 * Comment service interface
 */
public interface CommentService extends IService<Comment> {
    
    /**
     * Add comment
     * @param replyToUserId 直接回复目标用户ID，用于通知（回复楼中楼时通知被回复者）；为 null 时通知 parent 作者
     */
    Comment addComment(Long trackId, Long userId, String content, Long parentId, Long replyToUserId);
    
    /**
     * Delete comment
     */
    void deleteComment(Long commentId, Long userId);
    
    /**
     * Get track comments
     */
    IPage<CommentDTO> getTrackComments(Long trackId, int page, int size);
    
    /**
     * Get track comments with user like status
     */
    IPage<CommentDTO> getTrackComments(Long trackId, int page, int size, Long currentUserId);
    
    /**
     * Get comment replies
     */
    IPage<CommentDTO> getReplies(Long rootCommentId, int page, int size, Long currentUserId);
    
    /**
     * Like comment
     */
    void likeComment(Long commentId, Long userId);
    
    /**
     * Unlike comment
     */
    void unlikeComment(Long commentId, Long userId);
    
    /**
     * Audit comment (admin)
     */
    void auditComment(Long commentId, int status, Long operatorId);

    /**
     * Get pending comments (admin)
     */
    IPage<CommentDTO> getPendingComments(int page, int size);

    /**
     * Get all comments (admin) - 全部评论，含歌曲信息
     *
     * @param sort newest | likes | hot | replies
     */
    IPage<CommentDTO> getAllComments(int page, int size, Long trackId, Long userId, String sort);

    /**
     * 按用户聚合评论统计（管理端「按用户」分区）
     */
    IPage<AdminCommentUserStatDTO> getCommentUserStats(int page, int size, String keyword);

    /**
     * Delete comment (admin)
     */
    void adminDeleteComment(Long commentId, Long operatorId);
}