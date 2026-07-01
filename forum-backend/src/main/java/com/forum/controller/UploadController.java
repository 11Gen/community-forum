package com.forum.controller;

import com.forum.common.Result;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/upload")
public class UploadController {

    @PostMapping("/image")
    public Result<?> uploadImage(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return Result.fail("文件不能为空");
        }
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            return Result.fail("只能上传图片文件");
        }
        if (file.getSize() > 5 * 1024 * 1024) {
            return Result.fail("图片大小不能超过5MB");
        }

        try {
            String originalFilename = file.getOriginalFilename();
            String ext = ".png";
            if (originalFilename != null && originalFilename.contains(".")) {
                ext = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String filename = UUID.randomUUID() + ext;

            String basePath = System.getProperty("user.dir");
            File uploadDir = new File(basePath, "uploads/images/");
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            File dest = new File(uploadDir, filename);
            file.transferTo(dest);

            String url = "/uploads/images/" + filename;
            Map<String, String> data = new HashMap<>();
            data.put("url", url);
            return Result.ok(data);
        } catch (IOException e) {
            return Result.fail("上传失败: " + e.getMessage());
        }
    }
}
