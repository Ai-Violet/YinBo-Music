package com.yinbo.dto;

import lombok.Data;

/**
 * 管理端：按用户聚合的评论统计
 */
@Data
public class AdminCommentUserStatDTO {

    private Long userId;
    /** 展示名（昵称或用户名） */
    private String displayName;
    private Long commentCount;
    private String latestAt;
}
