package com.forum.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("user")
public class User {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String username;
    private String password;
    private String email;
    private String avatar;
    private String signature;
    private String role;
    private Integer status;
    private String nickname;  // 昵称(公开展示)
    private String phone;     // 手机号(仅本人可见)
    private Integer gender;   // 性别: 0男/1女/2私密
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
