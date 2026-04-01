package com.yinbo.dto;

import lombok.Data;

import java.util.List;

/**
 * Comment DTO
 */
@Data
public class CommentDTO {
    
    private Long id;
    private Long trackId;
    private Long userId;
    private String username;
    private String userNickname;
    private String userAvatar;
    private String content;
    private Long parentId;
    private Long rootCommentId;
    private Long replyToUserId;
    private String replyToNickname;
    private Integer floor;
    private Integer likeCount;
    private Boolean isLiked;
    private Integer replyCount;
    private String createdAt;
    private List<CommentDTO> replies;
    /** 歌曲名称（管理端展示用） */
    private String trackTitle;
    /** 歌手名称（管理端展示用） */
    private String trackArtist;
}
