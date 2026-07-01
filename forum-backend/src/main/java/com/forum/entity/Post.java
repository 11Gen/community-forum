package com.forum.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("post")
public class Post {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String title;
    private String content;
    private Long userId;
    private Long categoryId;
    private Integer viewCount;
    private Integer likeCount;
    private Integer commentCount;
    private Integer isPinned;
    private Integer isEssence;
    @TableLogic(value = "0", delval = "1")
    private Integer status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    @TableField(exist = false)
    private String nickname;
    @TableField(exist = false)
    private String avatar;
    @TableField(exist = false)
    private String categoryName;
    @TableField(exist = false)
    private Boolean isLiked;
    @TableField(exist = false)
    private Boolean isFavorited;
    @TableField(exist = false)
    private Integer favCount;
}
