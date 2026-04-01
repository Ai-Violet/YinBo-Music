package com.yinbo.entity;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("singers")
public class Singer {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private String name;
    private String avatarKey;
    private String description;
    /** 拼音检索；见 tracks.search_norm 说明，列存在后可去掉 exist = false */
    @TableField(exist = false)
    private String searchNorm;

    @TableLogic
    private Integer deleted;
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
    
    @TableField(exist = false)
    @JsonInclude(JsonInclude.Include.NON_NULL)
    private String avatarUrl;
}
