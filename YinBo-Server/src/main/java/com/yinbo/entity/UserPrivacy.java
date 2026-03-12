package com.yinbo.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

@Data
@TableName("user_privacy")
public class UserPrivacy {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long userId;

    /** 播放历史是否公开: 1=public 0=private */
    private Integer historyVisible;

    /** 收藏列表是否公开 */
    private Integer favoritesVisible;

    /** 关注/粉丝列表是否公开 */
    private Integer followsVisible;
}
