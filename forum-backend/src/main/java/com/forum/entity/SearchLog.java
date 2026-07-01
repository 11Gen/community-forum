package com.forum.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("search_log")
public class SearchLog {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String keyword;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}
