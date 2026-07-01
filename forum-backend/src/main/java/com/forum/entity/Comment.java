package com.forum.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
@TableName("comment")
public class Comment {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String content;
    private Long userId;
    private Long postId;
    private Long parentId;
    private Integer isPinned;
    private Integer likeCount;
    @TableLogic(value = "0", delval = "1")
    private Integer status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(exist = false)
    private String nickname;
    @TableField(exist = false)
    private String avatar;
    @TableField(exist = false)
    private List<Comment> children;
    @TableField(exist = false)
    private Boolean isLiked;
    @TableField(exist = false)
    private Integer replyCount;
}
