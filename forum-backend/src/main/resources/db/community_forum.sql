/*
 Navicat Premium Dump SQL

 Source Server         : mysql8@localhost
 Source Server Type    : MySQL
 Source Server Version : 80012 (8.0.12)
 Source Host           : localhost:3306
 Source Schema         : community_forum

 Target Server Type    : MySQL
 Target Server Version : 80012 (8.0.12)
 File Encoding         : 65001

 Date: 02/07/2026 20:07:00
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '分类名称',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分类描述',
  `sort_order` int(11) NOT NULL DEFAULT 0 COMMENT '排序顺序',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '分类表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES (1, '技术交流', '编程技术、软件开发相关话题', 1, '2026-06-29 17:30:54');
INSERT INTO `category` VALUES (2, '生活杂谈', '日常生活、兴趣爱好分享', 2, '2026-06-29 17:30:54');
INSERT INTO `category` VALUES (3, '资源分享', '学习资源、工具软件推荐', 3, '2026-06-29 17:30:54');
INSERT INTO `category` VALUES (4, '问答求助', '问题求助与技术问答', 4, '2026-06-29 17:30:54');
INSERT INTO `category` VALUES (5, '公告通知', '论坛公告与规则说明', 5, '2026-06-29 17:30:54');
INSERT INTO `category` VALUES (11, '游戏', '', 99, '2026-07-02 19:58:26');

-- ----------------------------
-- Table structure for comment
-- ----------------------------
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '评论ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '评论内容',
  `user_id` bigint(20) NOT NULL COMMENT '评论用户ID',
  `post_id` bigint(20) NOT NULL COMMENT '帖子ID',
  `parent_id` bigint(20) NULL DEFAULT NULL COMMENT '父评论ID(楼中楼)',
  `status` int(11) NOT NULL DEFAULT 0 COMMENT '状态: 0正常/1删除',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评论时间',
  `is_pinned` tinyint(4) NULL DEFAULT 0,
  `like_count` int(11) NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_post_id`(`post_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  CONSTRAINT `fk_comment_post` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_comment_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 66 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '评论表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of comment
-- ----------------------------
INSERT INTO `comment` VALUES (1, '嗨嗨嗨\n', 3, 1, NULL, 0, '2026-06-30 15:05:46', 0, 0);
INSERT INTO `comment` VALUES (2, '欢迎分享', 1, 1, NULL, 0, '2026-06-30 15:06:24', 0, 2);
INSERT INTO `comment` VALUES (3, '222', 4, 1, NULL, 0, '2026-06-30 15:09:28', 1, 0);
INSERT INTO `comment` VALUES (4, '333', 4, 1, NULL, 0, '2026-06-30 15:13:33', 0, 0);
INSERT INTO `comment` VALUES (5, '444', 4, 1, NULL, 0, '2026-06-30 15:16:44', 0, 0);
INSERT INTO `comment` VALUES (6, '谢谢', 2, 1, 2, 0, '2026-06-30 15:21:40', 0, 0);
INSERT INTO `comment` VALUES (7, '对了，请关注永雏塔菲，谢谢喵', 4, 1, 2, 0, '2026-06-30 15:28:50', 0, 0);
INSERT INTO `comment` VALUES (9, '666', 5, 1, NULL, 0, '2026-07-01 11:08:38', 0, 0);
INSERT INTO `comment` VALUES (10, '666', 5, 1, NULL, 0, '2026-07-01 11:08:41', 0, 0);
INSERT INTO `comment` VALUES (11, '666', 5, 1, NULL, 0, '2026-07-01 11:08:42', 0, 0);
INSERT INTO `comment` VALUES (12, '666', 5, 1, NULL, 0, '2026-07-01 11:08:44', 0, 0);
INSERT INTO `comment` VALUES (13, '66', 5, 1, NULL, 0, '2026-07-01 11:08:45', 0, 0);
INSERT INTO `comment` VALUES (14, '6', 5, 1, NULL, 0, '2026-07-01 11:08:46', 0, 0);
INSERT INTO `comment` VALUES (15, '6', 5, 1, NULL, 0, '2026-07-01 11:08:47', 0, 0);
INSERT INTO `comment` VALUES (16, '6', 5, 1, NULL, 0, '2026-07-01 11:08:50', 0, 0);
INSERT INTO `comment` VALUES (17, '6', 5, 1, NULL, 0, '2026-07-01 11:08:51', 0, 0);
INSERT INTO `comment` VALUES (18, '333', 5, 1, NULL, 0, '2026-07-01 11:09:09', 0, 0);
INSERT INTO `comment` VALUES (19, '333', 5, 1, NULL, 0, '2026-07-01 11:09:11', 0, 0);
INSERT INTO `comment` VALUES (20, '3', 5, 1, NULL, 0, '2026-07-01 11:09:12', 0, 0);
INSERT INTO `comment` VALUES (21, '3', 5, 1, NULL, 0, '2026-07-01 11:09:14', 0, 0);
INSERT INTO `comment` VALUES (22, '37537375', 5, 1, NULL, 0, '2026-07-01 11:09:21', 0, 0);
INSERT INTO `comment` VALUES (23, '375375', 5, 1, NULL, 0, '2026-07-01 11:09:22', 0, 0);
INSERT INTO `comment` VALUES (24, '375357', 5, 1, NULL, 0, '2026-07-01 11:09:24', 0, 0);
INSERT INTO `comment` VALUES (25, '453543', 5, 1, NULL, 0, '2026-07-01 11:09:32', 0, 0);
INSERT INTO `comment` VALUES (26, '333753987654', 5, 1, NULL, 0, '2026-07-01 11:09:40', 0, 0);
INSERT INTO `comment` VALUES (27, '1', 5, 1, NULL, 0, '2026-07-01 11:09:45', 0, 0);
INSERT INTO `comment` VALUES (28, '1', 5, 1, NULL, 0, '2026-07-01 11:09:46', 0, 0);
INSERT INTO `comment` VALUES (29, '1', 5, 1, NULL, 0, '2026-07-01 11:09:47', 0, 0);
INSERT INTO `comment` VALUES (30, '1', 5, 1, NULL, 0, '2026-07-01 11:09:48', 0, 0);
INSERT INTO `comment` VALUES (31, '1', 5, 1, NULL, 0, '2026-07-01 11:09:49', 0, 0);
INSERT INTO `comment` VALUES (32, '1', 5, 1, NULL, 0, '2026-07-01 11:09:51', 0, 0);
INSERT INTO `comment` VALUES (33, '1', 5, 1, NULL, 0, '2026-07-01 11:09:52', 0, 0);
INSERT INTO `comment` VALUES (34, '1', 5, 1, NULL, 0, '2026-07-01 11:09:53', 0, 0);
INSERT INTO `comment` VALUES (35, '1', 5, 1, NULL, 0, '2026-07-01 11:09:55', 0, 0);
INSERT INTO `comment` VALUES (37, '1', 6, 1, NULL, 0, '2026-07-01 11:16:48', 0, 0);
INSERT INTO `comment` VALUES (38, '1', 6, 1, NULL, 0, '2026-07-01 11:16:49', 0, 0);
INSERT INTO `comment` VALUES (39, '1', 6, 1, NULL, 0, '2026-07-01 11:16:50', 0, 0);
INSERT INTO `comment` VALUES (40, '1', 6, 1, NULL, 0, '2026-07-01 11:16:52', 0, 0);
INSERT INTO `comment` VALUES (41, '1', 6, 1, NULL, 0, '2026-07-01 11:16:53', 0, 0);
INSERT INTO `comment` VALUES (42, '1', 6, 1, NULL, 0, '2026-07-01 11:16:54', 0, 0);
INSERT INTO `comment` VALUES (43, '1', 6, 1, NULL, 0, '2026-07-01 11:16:55', 0, 0);
INSERT INTO `comment` VALUES (44, '1', 6, 1, NULL, 0, '2026-07-01 11:16:55', 0, 0);
INSERT INTO `comment` VALUES (45, '1', 6, 1, NULL, 0, '2026-07-01 11:16:57', 0, 0);
INSERT INTO `comment` VALUES (46, '1', 6, 1, NULL, 0, '2026-07-01 11:16:58', 0, 0);
INSERT INTO `comment` VALUES (47, '1', 6, 1, NULL, 0, '2026-07-01 11:16:59', 0, 0);
INSERT INTO `comment` VALUES (48, '1', 6, 1, NULL, 0, '2026-07-01 11:17:00', 0, 0);
INSERT INTO `comment` VALUES (49, '1', 6, 1, NULL, 0, '2026-07-01 11:17:01', 0, 0);
INSERT INTO `comment` VALUES (50, '1', 6, 1, NULL, 0, '2026-07-01 11:17:02', 0, 0);
INSERT INTO `comment` VALUES (51, '1', 6, 1, NULL, 0, '2026-07-01 11:17:03', 0, 0);
INSERT INTO `comment` VALUES (52, '1', 6, 1, NULL, 0, '2026-07-01 11:17:05', 0, 0);
INSERT INTO `comment` VALUES (53, '1', 6, 1, NULL, 0, '2026-07-01 11:17:05', 0, 0);
INSERT INTO `comment` VALUES (54, '1', 6, 1, NULL, 0, '2026-07-01 11:17:06', 0, 0);
INSERT INTO `comment` VALUES (55, '1', 6, 1, NULL, 0, '2026-07-01 11:17:07', 0, 0);
INSERT INTO `comment` VALUES (56, '222', 7, 10, NULL, 0, '2026-07-01 21:39:11', 0, 0);
INSERT INTO `comment` VALUES (57, '333', 6, 10, 56, 0, '2026-07-01 21:39:42', 0, 0);
INSERT INTO `comment` VALUES (58, '444', 6, 10, 56, 0, '2026-07-01 21:39:59', 0, 0);
INSERT INTO `comment` VALUES (59, '555', 6, 10, 56, 0, '2026-07-01 21:40:03', 0, 0);
INSERT INTO `comment` VALUES (60, '666', 6, 10, 56, 0, '2026-07-01 21:40:09', 0, 0);
INSERT INTO `comment` VALUES (61, '323123131\n', 10, 2, NULL, 0, '2026-07-02 14:33:27', 0, 0);
INSERT INTO `comment` VALUES (62, '666', 9, 12, NULL, 0, '2026-07-02 19:50:10', 1, 1);
INSERT INTO `comment` VALUES (63, '32321', 10, 12, 62, 0, '2026-07-02 19:50:40', 0, 0);
INSERT INTO `comment` VALUES (64, '321321', 10, 12, 63, 0, '2026-07-02 19:50:44', 0, 0);
INSERT INTO `comment` VALUES (65, '1321321321', 9, 12, NULL, 0, '2026-07-02 19:55:04', 0, 0);

-- ----------------------------
-- Table structure for comment_likes
-- ----------------------------
DROP TABLE IF EXISTS `comment_likes`;
CREATE TABLE `comment_likes`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `comment_id` bigint(20) NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_comment`(`user_id` ASC, `comment_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '评论点赞表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of comment_likes
-- ----------------------------
INSERT INTO `comment_likes` VALUES (1, 2, 2, '2026-06-30 22:25:34');
INSERT INTO `comment_likes` VALUES (2, 3, 2, '2026-06-30 22:28:13');
INSERT INTO `comment_likes` VALUES (3, 3, 8, '2026-06-30 22:51:53');
INSERT INTO `comment_likes` VALUES (4, 10, 62, '2026-07-02 19:50:33');

-- ----------------------------
-- Table structure for favorite
-- ----------------------------
DROP TABLE IF EXISTS `favorite`;
CREATE TABLE `favorite`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `post_id` bigint(20) NOT NULL COMMENT '帖子ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_post`(`user_id` ASC, `post_id` ASC) USING BTREE,
  INDEX `fk_fav_post`(`post_id` ASC) USING BTREE,
  CONSTRAINT `fk_fav_post` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_fav_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 27 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '收藏表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of favorite
-- ----------------------------
INSERT INTO `favorite` VALUES (7, 4, 1, '2026-06-30 15:43:47');
INSERT INTO `favorite` VALUES (8, 3, 1, '2026-06-30 15:49:16');
INSERT INTO `favorite` VALUES (14, 1, 2, '2026-06-30 16:41:22');
INSERT INTO `favorite` VALUES (15, 2, 1, '2026-06-30 19:51:25');
INSERT INTO `favorite` VALUES (16, 2, 2, '2026-06-30 19:51:36');
INSERT INTO `favorite` VALUES (18, 4, 2, '2026-06-30 20:03:06');
INSERT INTO `favorite` VALUES (21, 8, 11, '2026-07-01 21:38:22');
INSERT INTO `favorite` VALUES (22, 6, 10, '2026-07-01 21:40:30');
INSERT INTO `favorite` VALUES (23, 7, 10, '2026-07-01 21:40:50');
INSERT INTO `favorite` VALUES (24, 8, 10, '2026-07-01 21:45:25');
INSERT INTO `favorite` VALUES (25, 9, 12, '2026-07-02 19:51:30');
INSERT INTO `favorite` VALUES (26, 10, 12, '2026-07-02 19:51:44');

-- ----------------------------
-- Table structure for follow
-- ----------------------------
DROP TABLE IF EXISTS `follow`;
CREATE TABLE `follow`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT '关注者ID',
  `follow_user_id` bigint(20) NOT NULL COMMENT '被关注者ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_follow`(`user_id` ASC, `follow_user_id` ASC) USING BTREE,
  INDEX `idx_follow_user`(`follow_user_id` ASC) USING BTREE,
  CONSTRAINT `fk_follow_follow_user` FOREIGN KEY (`follow_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_follow_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '关注表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of follow
-- ----------------------------
INSERT INTO `follow` VALUES (1, 3, 1, '2026-06-30 16:48:39');
INSERT INTO `follow` VALUES (2, 2, 1, '2026-06-30 19:49:56');
INSERT INTO `follow` VALUES (3, 1, 2, '2026-06-30 19:50:32');
INSERT INTO `follow` VALUES (4, 3, 2, '2026-06-30 19:50:55');
INSERT INTO `follow` VALUES (5, 6, 2, '2026-07-01 21:41:28');
INSERT INTO `follow` VALUES (6, 8, 7, '2026-07-01 21:44:12');
INSERT INTO `follow` VALUES (7, 7, 8, '2026-07-01 21:44:28');
INSERT INTO `follow` VALUES (8, 9, 10, '2026-07-02 19:52:41');
INSERT INTO `follow` VALUES (9, 10, 9, '2026-07-02 19:52:58');

-- ----------------------------
-- Table structure for likes
-- ----------------------------
DROP TABLE IF EXISTS `likes`;
CREATE TABLE `likes`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '点赞ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `post_id` bigint(20) NOT NULL COMMENT '帖子ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_post`(`user_id` ASC, `post_id` ASC) USING BTREE,
  INDEX `idx_post_id`(`post_id` ASC) USING BTREE,
  CONSTRAINT `fk_like_post` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_like_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 26 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '点赞表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of likes
-- ----------------------------
INSERT INTO `likes` VALUES (2, 1, 2, '2026-06-30 14:51:17');
INSERT INTO `likes` VALUES (7, 4, 1, '2026-06-30 15:10:44');
INSERT INTO `likes` VALUES (8, 3, 1, '2026-06-30 15:49:46');
INSERT INTO `likes` VALUES (9, 1, 1, '2026-06-30 15:56:09');
INSERT INTO `likes` VALUES (10, 3, 2, '2026-06-30 16:48:34');
INSERT INTO `likes` VALUES (11, 2, 1, '2026-06-30 19:51:24');
INSERT INTO `likes` VALUES (13, 4, 2, '2026-06-30 20:03:06');
INSERT INTO `likes` VALUES (15, 6, 5, '2026-07-01 11:14:52');
INSERT INTO `likes` VALUES (16, 5, 5, '2026-07-01 11:21:22');
INSERT INTO `likes` VALUES (17, 5, 6, '2026-07-01 11:35:14');
INSERT INTO `likes` VALUES (20, 8, 11, '2026-07-01 21:38:21');
INSERT INTO `likes` VALUES (21, 6, 10, '2026-07-01 21:40:28');
INSERT INTO `likes` VALUES (22, 7, 10, '2026-07-01 21:40:50');
INSERT INTO `likes` VALUES (23, 8, 10, '2026-07-01 21:45:25');
INSERT INTO `likes` VALUES (24, 9, 12, '2026-07-02 19:51:29');
INSERT INTO `likes` VALUES (25, 10, 12, '2026-07-02 19:51:44');

-- ----------------------------
-- Table structure for message
-- ----------------------------
DROP TABLE IF EXISTS `message`;
CREATE TABLE `message`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `from_user_id` bigint(20) NOT NULL COMMENT '发送者ID',
  `to_user_id` bigint(20) NOT NULL COMMENT '接收者ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '消息内容',
  `is_read` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否已读: 0未读/1已读',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
  `is_recalled` tinyint(4) NULL DEFAULT 0,
  `deleted_by` bigint(20) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_from_user`(`from_user_id` ASC) USING BTREE,
  INDEX `idx_to_user`(`to_user_id` ASC) USING BTREE,
  INDEX `idx_conversation`(`from_user_id` ASC, `to_user_id` ASC) USING BTREE,
  CONSTRAINT `fk_msg_from` FOREIGN KEY (`from_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_msg_to` FOREIGN KEY (`to_user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 26 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '私信表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of message
-- ----------------------------
INSERT INTO `message` VALUES (1, 3, 2, '在吗', 1, '2026-06-30 14:34:35', 0, NULL);
INSERT INTO `message` VALUES (2, 2, 3, '不在', 1, '2026-06-30 14:34:46', 0, NULL);
INSERT INTO `message` VALUES (3, 3, 2, '滚滚滚', 1, '2026-06-30 14:35:01', 0, NULL);
INSERT INTO `message` VALUES (4, 3, 1, '你好，管理员', 1, '2026-06-30 16:49:22', 0, NULL);
INSERT INTO `message` VALUES (5, 1, 3, '有事吗', 1, '2026-06-30 17:18:55', 0, NULL);
INSERT INTO `message` VALUES (6, 1, 3, '1', 1, '2026-06-30 17:19:15', 0, NULL);
INSERT INTO `message` VALUES (7, 3, 1, '2', 1, '2026-06-30 17:24:10', 0, NULL);
INSERT INTO `message` VALUES (8, 3, 1, 'emmm', 1, '2026-06-30 17:27:06', 1, NULL);
INSERT INTO `message` VALUES (9, 3, 1, '3', 1, '2026-06-30 17:31:15', 0, 3);
INSERT INTO `message` VALUES (10, 3, 2, '？', 1, '2026-06-30 17:35:40', 1, NULL);
INSERT INTO `message` VALUES (11, 2, 3, '？', 1, '2026-06-30 17:36:17', 0, NULL);
INSERT INTO `message` VALUES (12, 4, 2, 'hello', 1, '2026-06-30 17:38:56', 0, NULL);
INSERT INTO `message` VALUES (13, 1, 2, '你好', 1, '2026-06-30 19:57:45', 0, NULL);
INSERT INTO `message` VALUES (14, 3, 2, '在吗', 1, '2026-06-30 19:57:58', 0, NULL);
INSERT INTO `message` VALUES (15, 2, 1, '你好', 1, '2026-06-30 21:05:09', 0, 2);
INSERT INTO `message` VALUES (16, 2, 1, '在吗', 1, '2026-06-30 21:05:22', 1, NULL);
INSERT INTO `message` VALUES (17, 2, 4, '111', 1, '2026-06-30 21:09:48', 0, NULL);
INSERT INTO `message` VALUES (18, 6, 5, 'sb', 1, '2026-07-01 11:18:25', 0, NULL);
INSERT INTO `message` VALUES (19, 5, 6, 'sb', 0, '2026-07-01 11:19:03', 0, NULL);
INSERT INTO `message` VALUES (20, 8, 2, '123456', 0, '2026-07-01 21:42:59', 1, NULL);
INSERT INTO `message` VALUES (21, 6, 2, '123214', 0, '2026-07-01 21:43:55', 0, NULL);
INSERT INTO `message` VALUES (22, 8, 7, '2113321', 1, '2026-07-01 21:45:05', 0, NULL);
INSERT INTO `message` VALUES (23, 10, 9, '123', 1, '2026-07-02 19:53:48', 0, 10);
INSERT INTO `message` VALUES (24, 10, 9, '321', 1, '2026-07-02 19:53:51', 1, NULL);
INSERT INTO `message` VALUES (25, 10, 2, '321321', 0, '2026-07-02 19:54:29', 0, NULL);

-- ----------------------------
-- Table structure for notification
-- ----------------------------
DROP TABLE IF EXISTS `notification`;
CREATE TABLE `notification`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '通知ID',
  `user_id` bigint(20) NOT NULL COMMENT '接收用户ID',
  `content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '通知内容',
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类型: COMMENT/LIKE/FOLLOW/SYSTEM',
  `target_id` bigint(20) NULL DEFAULT NULL COMMENT '目标ID',
  `is_read` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否已读: 0未读/1已读',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '通知时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_is_read`(`is_read` ASC) USING BTREE,
  CONSTRAINT `fk_notification_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 105 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '通知表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of notification
-- ----------------------------
INSERT INTO `notification` VALUES (1, 2, '社区管理员赞了你的帖子', 'LIKE', 1, 1, '2026-06-30 14:54:04');
INSERT INTO `notification` VALUES (2, 2, '社区管理员赞了你的帖子', 'LIKE', 1, 1, '2026-06-30 15:02:54');
INSERT INTO `notification` VALUES (3, 2, '评论了你的帖子', 'COMMENT', 1, 1, '2026-06-30 15:05:47');
INSERT INTO `notification` VALUES (4, 2, '评论了你的帖子', 'COMMENT', 1, 1, '2026-06-30 15:06:24');
INSERT INTO `notification` VALUES (5, 2, '评论了你的帖子', 'COMMENT', 1, 1, '2026-06-30 15:09:28');
INSERT INTO `notification` VALUES (6, 2, '江雨淋漓月朦胧赞了你的帖子', 'LIKE', 1, 1, '2026-06-30 15:09:41');
INSERT INTO `notification` VALUES (7, 2, 'YUN 收藏了你的帖子', 'FAVORITE', 1, 1, '2026-06-30 15:10:24');
INSERT INTO `notification` VALUES (8, 2, 'YUN赞了你的帖子', 'LIKE', 1, 1, '2026-06-30 15:10:34');
INSERT INTO `notification` VALUES (9, 2, 'YUN 收藏了你的帖子', 'FAVORITE', 1, 1, '2026-06-30 15:10:36');
INSERT INTO `notification` VALUES (10, 2, 'YUN赞了你的帖子', 'LIKE', 1, 1, '2026-06-30 15:10:44');
INSERT INTO `notification` VALUES (11, 2, 'YUN 评论了你的帖子', 'COMMENT', 1, 1, '2026-06-30 15:13:33');
INSERT INTO `notification` VALUES (12, 2, 'YUN 评论了你的帖子: 444', 'COMMENT', 1, 1, '2026-06-30 15:16:44');
INSERT INTO `notification` VALUES (13, 1, '测试用户 回复了你的评论: 谢谢', 'COMMENT', 1, 1, '2026-06-30 15:21:40');
INSERT INTO `notification` VALUES (14, 2, 'YUN 评论了你的帖子: 对了，请关注永雏塔菲，谢谢喵', 'COMMENT', 1, 1, '2026-06-30 15:28:50');
INSERT INTO `notification` VALUES (15, 1, 'YUN 回复了你的评论: 对了，请关注永雏塔菲，谢谢喵', 'COMMENT', 1, 1, '2026-06-30 15:28:50');
INSERT INTO `notification` VALUES (16, 2, 'YUN 收藏了你的帖子', 'FAVORITE', 1, 1, '2026-06-30 15:32:13');
INSERT INTO `notification` VALUES (17, 2, 'YUN 收藏了你的帖子', 'FAVORITE', 1, 1, '2026-06-30 15:32:16');
INSERT INTO `notification` VALUES (18, 2, 'YUN 收藏了你的帖子', 'FAVORITE', 1, 1, '2026-06-30 15:37:00');
INSERT INTO `notification` VALUES (19, 2, 'YUN 收藏了你的帖子', 'FAVORITE', 1, 1, '2026-06-30 15:43:47');
INSERT INTO `notification` VALUES (20, 2, '江雨淋漓月朦胧 收藏了你的帖子', 'FAVORITE', 1, 1, '2026-06-30 15:49:16');
INSERT INTO `notification` VALUES (21, 2, '江雨淋漓月朦胧赞了你的帖子', 'LIKE', 1, 1, '2026-06-30 15:49:46');
INSERT INTO `notification` VALUES (22, 2, '社区管理员 收藏了你的帖子', 'FAVORITE', 1, 1, '2026-06-30 15:55:51');
INSERT INTO `notification` VALUES (23, 2, '社区管理员赞了你的帖子', 'LIKE', 1, 1, '2026-06-30 15:56:09');
INSERT INTO `notification` VALUES (24, 2, '社区管理员 收藏了你的帖子', 'FAVORITE', 1, 1, '2026-06-30 15:56:53');
INSERT INTO `notification` VALUES (25, 2, '社区管理员 收藏了你的帖子', 'FAVORITE', 1, 1, '2026-06-30 16:05:21');
INSERT INTO `notification` VALUES (26, 2, '社区管理员 收藏了你的帖子', 'FAVORITE', 1, 1, '2026-06-30 16:06:51');
INSERT INTO `notification` VALUES (27, 2, '社区管理员 收藏了你的帖子', 'FAVORITE', 1, 1, '2026-06-30 16:08:46');
INSERT INTO `notification` VALUES (28, 1, '江雨淋漓月朦胧赞了你的帖子', 'LIKE', 2, 1, '2026-06-30 16:48:34');
INSERT INTO `notification` VALUES (29, 1, '测试用户 收藏了你的帖子', 'FAVORITE', 2, 1, '2026-06-30 19:51:36');
INSERT INTO `notification` VALUES (30, 1, 'YUN赞了你的帖子', 'LIKE', 2, 1, '2026-06-30 20:02:27');
INSERT INTO `notification` VALUES (31, 1, 'YUN 收藏了你的帖子', 'FAVORITE', 2, 1, '2026-06-30 20:02:28');
INSERT INTO `notification` VALUES (32, 1, 'YUN赞了你的帖子', 'LIKE', 2, 1, '2026-06-30 20:03:06');
INSERT INTO `notification` VALUES (33, 1, 'YUN 收藏了你的帖子', 'FAVORITE', 2, 1, '2026-06-30 20:03:06');
INSERT INTO `notification` VALUES (34, 2, '社区管理员 收藏了你的帖子', 'FAVORITE', 1, 1, '2026-06-30 20:58:50');
INSERT INTO `notification` VALUES (35, 1, '江雨淋漓月朦胧 赞了你的评论', 'COMMENT_LIKE', 1, 1, '2026-06-30 22:28:13');
INSERT INTO `notification` VALUES (36, 3, '测试用户 评论了你的帖子: 玩原神的这辈子有了', 'COMMENT', 3, 0, '2026-06-30 22:51:44');
INSERT INTO `notification` VALUES (37, 2, '江雨淋漓月朦胧 赞了你的评论', 'COMMENT_LIKE', 3, 1, '2026-06-30 22:51:53');
INSERT INTO `notification` VALUES (38, 2, '123321 评论了你的帖子: 666', 'COMMENT', 1, 0, '2026-07-01 11:08:38');
INSERT INTO `notification` VALUES (39, 2, '123321 评论了你的帖子: 666', 'COMMENT', 1, 0, '2026-07-01 11:08:41');
INSERT INTO `notification` VALUES (40, 2, '123321 评论了你的帖子: 666', 'COMMENT', 1, 0, '2026-07-01 11:08:42');
INSERT INTO `notification` VALUES (41, 2, '123321 评论了你的帖子: 666', 'COMMENT', 1, 0, '2026-07-01 11:08:44');
INSERT INTO `notification` VALUES (42, 2, '123321 评论了你的帖子: 66', 'COMMENT', 1, 0, '2026-07-01 11:08:45');
INSERT INTO `notification` VALUES (43, 2, '123321 评论了你的帖子: 6', 'COMMENT', 1, 0, '2026-07-01 11:08:46');
INSERT INTO `notification` VALUES (44, 2, '123321 评论了你的帖子: 6', 'COMMENT', 1, 0, '2026-07-01 11:08:47');
INSERT INTO `notification` VALUES (45, 2, '123321 评论了你的帖子: 6', 'COMMENT', 1, 0, '2026-07-01 11:08:50');
INSERT INTO `notification` VALUES (46, 2, '123321 评论了你的帖子: 6', 'COMMENT', 1, 0, '2026-07-01 11:08:51');
INSERT INTO `notification` VALUES (47, 2, '123321 评论了你的帖子: 333', 'COMMENT', 1, 0, '2026-07-01 11:09:09');
INSERT INTO `notification` VALUES (48, 2, '123321 评论了你的帖子: 333', 'COMMENT', 1, 0, '2026-07-01 11:09:11');
INSERT INTO `notification` VALUES (49, 2, '123321 评论了你的帖子: 3', 'COMMENT', 1, 0, '2026-07-01 11:09:12');
INSERT INTO `notification` VALUES (50, 2, '123321 评论了你的帖子: 3', 'COMMENT', 1, 0, '2026-07-01 11:09:14');
INSERT INTO `notification` VALUES (51, 2, '123321 评论了你的帖子: 37537375', 'COMMENT', 1, 0, '2026-07-01 11:09:21');
INSERT INTO `notification` VALUES (52, 2, '123321 评论了你的帖子: 375375', 'COMMENT', 1, 0, '2026-07-01 11:09:22');
INSERT INTO `notification` VALUES (53, 2, '123321 评论了你的帖子: 375357', 'COMMENT', 1, 0, '2026-07-01 11:09:24');
INSERT INTO `notification` VALUES (54, 2, '123321 评论了你的帖子: 453543', 'COMMENT', 1, 0, '2026-07-01 11:09:32');
INSERT INTO `notification` VALUES (55, 2, '123321 评论了你的帖子: 333753987654', 'COMMENT', 1, 0, '2026-07-01 11:09:40');
INSERT INTO `notification` VALUES (56, 2, '123321 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:09:45');
INSERT INTO `notification` VALUES (57, 2, '123321 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:09:46');
INSERT INTO `notification` VALUES (58, 2, '123321 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:09:47');
INSERT INTO `notification` VALUES (59, 2, '123321 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:09:48');
INSERT INTO `notification` VALUES (60, 2, '123321 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:09:49');
INSERT INTO `notification` VALUES (61, 2, '123321 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:09:51');
INSERT INTO `notification` VALUES (62, 2, '123321 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:09:52');
INSERT INTO `notification` VALUES (63, 2, '123321 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:09:53');
INSERT INTO `notification` VALUES (64, 2, '123321 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:09:55');
INSERT INTO `notification` VALUES (65, 2, '456654 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:16:48');
INSERT INTO `notification` VALUES (66, 2, '456654 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:16:49');
INSERT INTO `notification` VALUES (67, 2, '456654 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:16:50');
INSERT INTO `notification` VALUES (68, 2, '456654 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:16:52');
INSERT INTO `notification` VALUES (69, 2, '456654 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:16:53');
INSERT INTO `notification` VALUES (70, 2, '456654 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:16:54');
INSERT INTO `notification` VALUES (71, 2, '456654 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:16:55');
INSERT INTO `notification` VALUES (72, 2, '456654 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:16:55');
INSERT INTO `notification` VALUES (73, 2, '456654 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:16:58');
INSERT INTO `notification` VALUES (74, 2, '456654 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:16:58');
INSERT INTO `notification` VALUES (75, 2, '456654 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:16:59');
INSERT INTO `notification` VALUES (76, 2, '456654 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:17:00');
INSERT INTO `notification` VALUES (77, 2, '456654 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:17:01');
INSERT INTO `notification` VALUES (78, 2, '456654 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:17:02');
INSERT INTO `notification` VALUES (79, 2, '456654 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:17:03');
INSERT INTO `notification` VALUES (80, 2, '456654 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:17:05');
INSERT INTO `notification` VALUES (81, 2, '456654 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:17:05');
INSERT INTO `notification` VALUES (82, 2, '456654 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:17:06');
INSERT INTO `notification` VALUES (83, 2, '456654 评论了你的帖子: 1', 'COMMENT', 1, 0, '2026-07-01 11:17:07');
INSERT INTO `notification` VALUES (84, 6, '123321赞了你的帖子', 'LIKE', 5, 1, '2026-07-01 11:21:22');
INSERT INTO `notification` VALUES (85, 6, '123321赞了你的帖子', 'LIKE', 6, 1, '2026-07-01 11:35:14');
INSERT INTO `notification` VALUES (86, 7, '456654 评论了你的帖子: 333', 'COMMENT', 10, 1, '2026-07-01 21:39:42');
INSERT INTO `notification` VALUES (87, 7, '456654 回复了你的评论: 333', 'COMMENT', 10, 1, '2026-07-01 21:39:42');
INSERT INTO `notification` VALUES (88, 7, '456654 评论了你的帖子: 444', 'COMMENT', 10, 1, '2026-07-01 21:39:59');
INSERT INTO `notification` VALUES (89, 7, '456654 回复了你的评论: 444', 'COMMENT', 10, 1, '2026-07-01 21:39:59');
INSERT INTO `notification` VALUES (90, 7, '456654 评论了你的帖子: 555', 'COMMENT', 10, 1, '2026-07-01 21:40:03');
INSERT INTO `notification` VALUES (91, 7, '456654 回复了你的评论: 555', 'COMMENT', 10, 1, '2026-07-01 21:40:03');
INSERT INTO `notification` VALUES (92, 7, '456654 评论了你的帖子: 666', 'COMMENT', 10, 1, '2026-07-01 21:40:09');
INSERT INTO `notification` VALUES (93, 7, '456654 回复了你的评论: 666', 'COMMENT', 10, 1, '2026-07-01 21:40:09');
INSERT INTO `notification` VALUES (94, 7, '456654赞了你的帖子', 'LIKE', 10, 1, '2026-07-01 21:40:28');
INSERT INTO `notification` VALUES (95, 7, '456654 收藏了你的帖子', 'FAVORITE', 10, 1, '2026-07-01 21:40:30');
INSERT INTO `notification` VALUES (96, 7, 'sss赞了你的帖子', 'LIKE', 10, 1, '2026-07-01 21:45:25');
INSERT INTO `notification` VALUES (97, 7, 'sss 收藏了你的帖子', 'FAVORITE', 10, 1, '2026-07-01 21:45:25');
INSERT INTO `notification` VALUES (98, 1, '22222 评论了你的帖子: 323123131\n', 'COMMENT', 2, 1, '2026-07-02 14:33:27');
INSERT INTO `notification` VALUES (99, 10, '11111 评论了你的帖子: 666', 'COMMENT', 12, 1, '2026-07-02 19:50:11');
INSERT INTO `notification` VALUES (100, 9, '22222 赞了你的评论', 'COMMENT_LIKE', 12, 0, '2026-07-02 19:50:34');
INSERT INTO `notification` VALUES (101, 9, '22222 回复了你的评论: 32321', 'COMMENT', 12, 0, '2026-07-02 19:50:41');
INSERT INTO `notification` VALUES (102, 10, '11111赞了你的帖子', 'LIKE', 12, 1, '2026-07-02 19:51:29');
INSERT INTO `notification` VALUES (103, 10, '11111 收藏了你的帖子', 'FAVORITE', 12, 1, '2026-07-02 19:51:30');
INSERT INTO `notification` VALUES (104, 10, '11111 评论了你的帖子: 1321321321', 'COMMENT', 12, 1, '2026-07-02 19:55:04');

-- ----------------------------
-- Table structure for post
-- ----------------------------
DROP TABLE IF EXISTS `post`;
CREATE TABLE `post`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '帖子ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '帖子标题',
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '帖子内容',
  `user_id` bigint(20) NOT NULL COMMENT '发帖用户ID',
  `category_id` bigint(20) NOT NULL COMMENT '分类ID',
  `view_count` int(11) NOT NULL DEFAULT 0 COMMENT '浏览量',
  `like_count` int(11) NOT NULL DEFAULT 0 COMMENT '点赞数',
  `comment_count` int(11) NOT NULL DEFAULT 0 COMMENT '评论数',
  `is_pinned` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否置顶: 0否/1是',
  `is_essence` tinyint(4) NOT NULL DEFAULT 0 COMMENT '是否精华: 0否/1是',
  `status` int(11) NOT NULL DEFAULT 0 COMMENT '状态: 0正常/1删除',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_category_id`(`category_id` ASC) USING BTREE,
  INDEX `idx_title`(`title` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE,
  CONSTRAINT `fk_post_category` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_post_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '帖子表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of post
-- ----------------------------
INSERT INTO `post` VALUES (1, '111', '111', 2, 4, 202, 4, 53, 0, 0, 0, '2026-06-29 17:40:30', '2026-06-29 17:40:30');
INSERT INTO `post` VALUES (2, '欢迎！！！', '欢迎大家积极分享内容，切勿违反社区规定', 1, 5, 28, 3, 1, 0, 1, 0, '2026-06-30 14:51:15', '2026-06-30 14:51:15');
INSERT INTO `post` VALUES (5, '1', '看到不点赞的是给', 6, 2, 9, 2, 0, 0, 0, 0, '2026-07-01 11:14:31', '2026-07-01 11:14:31');
INSERT INTO `post` VALUES (6, '技术交流测试', '121212122121212', 6, 1, 5, 1, 0, 0, 0, 0, '2026-07-01 11:16:31', '2026-07-01 11:16:31');
INSERT INTO `post` VALUES (7, '资源分享测试', 'www.baidu.com', 5, 3, 2, 0, 0, 0, 0, 0, '2026-07-01 11:33:30', '2026-07-01 11:33:30');
INSERT INTO `post` VALUES (8, '技术交流测试', '123', 5, 1, 1, 0, 0, 0, 0, 0, '2026-07-01 11:34:22', '2026-07-01 11:34:22');
INSERT INTO `post` VALUES (9, '技术测试1', '123456', 5, 1, 6, 0, 0, 0, 0, 0, '2026-07-01 11:35:43', '2026-07-01 11:35:43');
INSERT INTO `post` VALUES (10, '关于互联网技术的讨论', '11111', 7, 1, 15, 3, 5, 0, 0, 0, '2026-07-01 21:28:59', '2026-07-01 21:28:59');
INSERT INTO `post` VALUES (11, '关于互联网发展的讨论', '111', 8, 1, 2, 1, 0, 0, 0, 0, '2026-07-01 21:38:06', '2026-07-01 21:38:06');
INSERT INTO `post` VALUES (12, '22222', '22222', 10, 1, 20, 2, 3, 0, 1, 0, '2026-07-02 14:37:22', '2026-07-02 14:37:22');
INSERT INTO `post` VALUES (13, '11111', '111111', 9, 1, 1, 0, 0, 0, 0, 0, '2026-07-02 14:37:30', '2026-07-02 14:37:30');
INSERT INTO `post` VALUES (14, '33333', '32321441233', 11, 1, 1, 0, 0, 0, 0, 0, '2026-07-02 19:49:06', '2026-07-02 19:49:06');

-- ----------------------------
-- Table structure for search_history
-- ----------------------------
DROP TABLE IF EXISTS `search_history`;
CREATE TABLE `search_history`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `keyword` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE,
  CONSTRAINT `fk_sh_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '搜索历史' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of search_history
-- ----------------------------
INSERT INTO `search_history` VALUES (1, 1, '欢迎', '2026-06-30 19:35:03');
INSERT INTO `search_history` VALUES (2, 1, '欢迎', '2026-06-30 19:35:32');
INSERT INTO `search_history` VALUES (4, 2, '111', '2026-06-30 21:01:16');
INSERT INTO `search_history` VALUES (5, 11, '欢迎', '2026-07-02 19:47:29');

-- ----------------------------
-- Table structure for search_log
-- ----------------------------
DROP TABLE IF EXISTS `search_log`;
CREATE TABLE `search_log`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `keyword` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_keyword`(`keyword` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '搜索日志' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of search_log
-- ----------------------------
INSERT INTO `search_log` VALUES (1, '欢迎', '2026-06-30 19:35:04');
INSERT INTO `search_log` VALUES (2, '欢迎', '2026-06-30 19:35:32');
INSERT INTO `search_log` VALUES (3, '欢迎', '2026-06-30 19:37:34');
INSERT INTO `search_log` VALUES (4, '111', '2026-06-30 21:01:16');
INSERT INTO `search_log` VALUES (5, '欢迎', '2026-07-02 19:47:29');

-- ----------------------------
-- Table structure for security_question
-- ----------------------------
DROP TABLE IF EXISTS `security_question`;
CREATE TABLE `security_question`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `question` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密保问题',
  `answer` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密保答案',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `fk_sq_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '密保问题表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of security_question
-- ----------------------------
INSERT INTO `security_question` VALUES (1, 3, '你是谁', 'AAA', '2026-06-30 14:48:44');
INSERT INTO `security_question` VALUES (2, 3, '你在哪', 'BBB', '2026-06-30 14:48:44');
INSERT INTO `security_question` VALUES (3, 3, '你在干嘛', 'CCC', '2026-06-30 14:48:44');
INSERT INTO `security_question` VALUES (4, 5, '123', '123', '2026-07-01 11:08:02');
INSERT INTO `security_question` VALUES (5, 5, '321', '321', '2026-07-01 11:08:02');
INSERT INTO `security_question` VALUES (6, 5, '147', '147', '2026-07-01 11:08:02');
INSERT INTO `security_question` VALUES (7, 8, '1加1', '2', '2026-07-01 21:47:22');
INSERT INTO `security_question` VALUES (8, 8, '1加2', '3', '2026-07-01 21:47:22');
INSERT INTO `security_question` VALUES (9, 8, '1加3', '4', '2026-07-01 21:47:22');
INSERT INTO `security_question` VALUES (10, 10, '1', '1', '2026-07-02 19:55:48');
INSERT INTO `security_question` VALUES (11, 10, '2', '2', '2026-07-02 19:55:48');
INSERT INTO `security_question` VALUES (12, 10, '3', '3', '2026-07-02 19:55:48');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录账号(仅管理员和本人可见)',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '昵称(公开展示)',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码(BCrypt加密)',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '邮箱(仅本人可见)',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号(仅本人可见)',
  `gender` int(11) NULL DEFAULT 2 COMMENT '性别: 0男/1女/2私密',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像URL',
  `signature` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '个性签名',
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'USER' COMMENT '角色: USER/ADMIN',
  `status` int(11) NOT NULL DEFAULT 0 COMMENT '状态: 0正常/1禁用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_nickname`(`nickname` ASC) USING BTREE,
  UNIQUE INDEX `uk_email`(`email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'admin', '社区管理员', '$2b$12$Rx/FMK9xKf9v5D/yjRt/ee/jNqIilv2CV24aoHT.tY/epzJrqctHa', 'admin@forum.com', '1595898985', 2, '/uploads/avatars/09d1c8ea-bd87-4f24-807d-a72bf2b428e5.jpg', '嗨嗨嗨', 'ADMIN', 0, '2026-06-29 17:30:54', '2026-06-29 17:30:54');
INSERT INTO `user` VALUES (2, 'testuser', '测试用户', '$2b$12$FT.ZrhgHSMhoOWgflUG3iO9GEp2a4kUjXE4.10J6c.WDL0C6UhWJ2', 'test@forum.com', '', 2, '/uploads/avatars/8f318054-b578-41aa-aa0a-f694bd540384.jpg', '111', 'USER', 0, '2026-06-29 17:30:54', '2026-06-29 17:30:54');
INSERT INTO `user` VALUES (3, 'cjl794350', '江雨淋漓月朦胧', '$2a$10$gVlH2kVT.kGtKJPExxKg.eNTakMte.U4UFZ2TCxGfyFXM8QdudeEW', '1985913833@qq.com', '', 0, '/uploads/avatars/2596f45a-7573-4cfd-a0a4-7598b8f996d9.jpg', '越努力，越幸运', 'USER', 0, '2026-06-30 14:29:31', '2026-06-30 14:29:31');
INSERT INTO `user` VALUES (4, 'abcd1234', 'YUN', '$2a$10$Qj49LFNLtfj8VbXrXoscy.xDmCWc.XSSUJNhMkmVp9OBoZVHX67C.', '123@163.com', '', 2, '/uploads/avatars/b911b575-ef1b-46dc-936a-f4b881158242.jpg', '', 'USER', 0, '2026-06-30 15:08:57', '2026-06-30 15:08:57');
INSERT INTO `user` VALUES (5, '123123', '123321', '$2a$10$5Q8Z5ia/B/XF6in2SO1Igu9WfKleR3/Z7RiOs5IQMF55DBA88qUoK', '123123@123.com', '1888888888', 2, '/uploads/avatars/d8320c61-7bae-4d38-937d-c7e856911ee4.png', '小心被飞升', 'USER', 0, '2026-07-01 11:06:01', '2026-07-01 11:06:01');
INSERT INTO `user` VALUES (6, '456654', '456654', '$2a$10$PApO35gImtd9mBhTga.OuuKk4NXlRIPWUzLIyxzDaG8bKSkuIR5G2', '12341234@1234.com', NULL, 2, NULL, NULL, 'USER', 0, '2026-07-01 11:13:05', '2026-07-01 11:13:05');
INSERT INTO `user` VALUES (7, '123456', '123', '$2a$10$Wo4/e6izj0vI7cXPhb31W.tI/X3r/.2O.scyPYERvK1MaThQedTi6', '123456@666.com', NULL, 2, NULL, NULL, 'USER', 2, '2026-07-01 21:26:27', '2026-07-01 21:26:27');
INSERT INTO `user` VALUES (8, '654321', 'sss', '$2a$10$pezknyAfeAr5yRQLt349J.veppgORhGemxA8rt4mG2Ud0Wk9VNTTi', '654321@sss.com', NULL, 2, NULL, NULL, 'USER', 0, '2026-07-01 21:34:41', '2026-07-01 21:34:41');
INSERT INTO `user` VALUES (9, '11111', '11111', '$2a$10$OLL6AJEwDpta3ZRnZexyLOv4DJ7oF/n8fAPNtVSfA8f2LjvcRDwLu', '11111@11111.com', NULL, 2, NULL, NULL, 'USER', 0, '2026-07-02 14:27:40', '2026-07-02 14:27:40');
INSERT INTO `user` VALUES (10, '22222', '22222', '$2a$10$V2Qh/x3wWe02nCt/j2Zdc.BHszdbqh0JkXsLutylJDkJ0PYyP3fm6', '22222@22222.com', '', 2, '/uploads/avatars/2c5651b2-b3d9-4f10-b277-3fbe0a666c0d.png', '', 'USER', 2, '2026-07-02 14:28:17', '2026-07-02 14:28:17');
INSERT INTO `user` VALUES (11, '33333', '33333', '$2a$10$1OagmunBbGBbWnwz/MvFj.a8oCy6IsgqEE0YKNADHZaP/kwLi08PG', '33333@333.com', NULL, 2, NULL, NULL, 'USER', 0, '2026-07-02 19:46:23', '2026-07-02 19:46:23');

-- ----------------------------
-- Table structure for view_history
-- ----------------------------
DROP TABLE IF EXISTS `view_history`;
CREATE TABLE `view_history`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `post_id` bigint(20) NOT NULL COMMENT '帖子ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '浏览时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_post`(`user_id` ASC, `post_id` ASC) USING BTREE,
  INDEX `idx_user_time`(`user_id` ASC, `create_time` ASC) USING BTREE,
  CONSTRAINT `fk_vh_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 37 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '浏览历史表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of view_history
-- ----------------------------
INSERT INTO `view_history` VALUES (1, 2, 1, '2026-06-30 22:55:00');
INSERT INTO `view_history` VALUES (2, 1, 1, '2026-07-02 19:59:43');
INSERT INTO `view_history` VALUES (3, 3, 1, '2026-06-30 22:28:08');
INSERT INTO `view_history` VALUES (4, 1, 2, '2026-07-02 14:33:32');
INSERT INTO `view_history` VALUES (5, 3, 2, '2026-06-30 16:49:10');
INSERT INTO `view_history` VALUES (6, 4, 2, '2026-06-30 20:03:04');
INSERT INTO `view_history` VALUES (7, 4, 1, '2026-06-30 17:40:51');
INSERT INTO `view_history` VALUES (8, 2, 2, '2026-06-30 21:04:45');
INSERT INTO `view_history` VALUES (9, 3, 3, '2026-06-30 22:51:51');
INSERT INTO `view_history` VALUES (10, 1, 3, '2026-06-30 22:51:17');
INSERT INTO `view_history` VALUES (11, 2, 3, '2026-06-30 22:51:44');
INSERT INTO `view_history` VALUES (12, 5, 1, '2026-07-01 11:36:24');
INSERT INTO `view_history` VALUES (13, 5, 4, '2026-07-01 11:12:14');
INSERT INTO `view_history` VALUES (14, 6, 4, '2026-07-01 11:18:19');
INSERT INTO `view_history` VALUES (15, 6, 5, '2026-07-01 21:22:53');
INSERT INTO `view_history` VALUES (16, 6, 2, '2026-07-01 11:17:46');
INSERT INTO `view_history` VALUES (17, 6, 6, '2026-07-01 21:22:50');
INSERT INTO `view_history` VALUES (18, 6, 1, '2026-07-01 21:41:25');
INSERT INTO `view_history` VALUES (19, 6, 3, '2026-07-01 11:17:53');
INSERT INTO `view_history` VALUES (20, 5, 5, '2026-07-01 11:21:21');
INSERT INTO `view_history` VALUES (21, 5, 7, '2026-07-01 11:33:30');
INSERT INTO `view_history` VALUES (22, 5, 8, '2026-07-01 11:34:22');
INSERT INTO `view_history` VALUES (23, 5, 6, '2026-07-01 11:35:13');
INSERT INTO `view_history` VALUES (24, 5, 9, '2026-07-01 11:36:12');
INSERT INTO `view_history` VALUES (25, 7, 10, '2026-07-01 21:45:48');
INSERT INTO `view_history` VALUES (26, 8, 11, '2026-07-01 21:38:07');
INSERT INTO `view_history` VALUES (27, 6, 10, '2026-07-01 21:40:09');
INSERT INTO `view_history` VALUES (28, 8, 1, '2026-07-01 21:42:46');
INSERT INTO `view_history` VALUES (29, 8, 10, '2026-07-01 21:45:24');
INSERT INTO `view_history` VALUES (30, 7, 11, '2026-07-01 21:44:24');
INSERT INTO `view_history` VALUES (31, 10, 2, '2026-07-02 14:33:27');
INSERT INTO `view_history` VALUES (32, 10, 12, '2026-07-02 19:55:24');
INSERT INTO `view_history` VALUES (33, 9, 13, '2026-07-02 14:37:30');
INSERT INTO `view_history` VALUES (34, 11, 14, '2026-07-02 19:49:06');
INSERT INTO `view_history` VALUES (35, 9, 12, '2026-07-02 19:59:25');
INSERT INTO `view_history` VALUES (36, 10, 1, '2026-07-02 19:57:28');

SET FOREIGN_KEY_CHECKS = 1;
