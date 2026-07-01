package com.forum.dto;

import lombok.Data;

@Data
public class MessageSendDTO {
    private Long toUserId;
    private String content;
}
