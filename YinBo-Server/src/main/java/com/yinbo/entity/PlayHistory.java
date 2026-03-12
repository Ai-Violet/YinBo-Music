package com.yinbo.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("play_history")
public class PlayHistory {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long userId;
    private Long trackId;
    private Integer durationPlayed;
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime playedAt;
}