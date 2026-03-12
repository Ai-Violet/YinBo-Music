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
