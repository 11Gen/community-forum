package com.forum.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class PostDTO {
    @NotBlank(message = "标题不能为空")
    @Size(max = 200, message = "标题最长200个字符")
    private String title;

    @NotBlank(message = "内容不能为空")
    private String content;

    @NotNull(message = "请选择分类")
    private Long categoryId;
}
