package com.forum.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("message")
public class Message {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long fromUserId;
    private Long toUserId;
    private String content;
    private Integer isRead;
    private Integer isRecalled;
    private Long deletedBy;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(exist = false)
    private Long senderId;
    @TableField(exist = false)
    private String senderNickname;
    @TableField(exist = false)
    private String senderAvatar;
}
