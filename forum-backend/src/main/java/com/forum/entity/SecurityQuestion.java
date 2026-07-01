package com.forum.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("security_question")
public class SecurityQuestion {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private String question;
    private String answer;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}
