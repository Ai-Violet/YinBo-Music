package com.yinbo.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.yinbo.common.Result;
import com.yinbo.dto.CommentDTO;
import com.yinbo.entity.Comment;
import com.yinbo.security.CurrentUser;
import com.yinbo.service.CommentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Comment API")
@RestController
@RequestMapping("/comments")
@RequiredArgsConstructor
public class CommentController {
    
    private final CommentService commentService;
    
    @Operation(summary = "Get track comments")
    @GetMapping("/track/{trackId}")
    public Result<IPage<CommentDTO>> getTrackComments(
            @PathVariable Long trackId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            @AuthenticationPrincipal CurrentUser user) {
        Long currentUserId = user != null ? user.getUserId() : null;
        return Result.success(commentService.getTrackComments(trackId, page, size, currentUserId));
    }
    
    @Operation(summary = "Get comment replies")
    @GetMapping("/{commentId}/replies")
    public Result<IPage<CommentDTO>> getCommentReplies(
            @PathVariable Long commentId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size) {
        return Result.success(commentService.getReplies(commentId, page, size));
    }
    
    @Operation(summary = "Add comment")
    @PostMapping("/track/{trackId}")
    public Result<Comment> addComment(
            @PathVariable Long trackId,
            @RequestBody CommentRequest request,
            @AuthenticationPrincipal CurrentUser user) {
        return Result.success(commentService.addComment(
                trackId, 
                user.getUserId(), 
                request.getContent(), 
                request.getParentId(),
                request.getReplyToUserId()
        ));
    }
    
    @Operation(summary = "Delete comment")
    @DeleteMapping("/{id}")
    public Result<Void> deleteComment(
            @PathVariable Long id,
            @AuthenticationPrincipal CurrentUser user) {
        commentService.deleteComment(id, user.getUserId());
        return Result.success();
    }
    
    @Operation(summary = "Like comment")
    @PostMapping("/{id}/like")
    public Result<Void> likeComment(
            @PathVariable Long id,
            @AuthenticationPrincipal CurrentUser user) {
        commentService.likeComment(id, user.getUserId());
        return Result.success();
    }
    
    @Operation(summary = "Unlike comment")
    @DeleteMapping("/{id}/like")
    public Result<Void> unlikeComment(
            @PathVariable Long id,
            @AuthenticationPrincipal CurrentUser user) {
        commentService.unlikeComment(id, user.getUserId());
        return Result.success();
    }
    
    @lombok.Data
    public static class CommentRequest {
        private String content;
        private Long parentId;
        /** 直接回复目标用户ID，用于通知（回复楼中楼时通知被回复者而非楼主） */
        private Long replyToUserId;
    }
}