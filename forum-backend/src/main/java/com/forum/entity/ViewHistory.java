package com.forum.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("view_history")
public class ViewHistory {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private Long postId;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(exist = false)
    private String postTitle;
    @TableField(exist = false)
    private Integer postStatus;
}
