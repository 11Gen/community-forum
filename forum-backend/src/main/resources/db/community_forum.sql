/*
 Navicat Premium Dump SQL

 Source Server         : abc
 Source Server Type    : MySQL
 Source Server Version : 80012 (8.0.12)
 Source Host           : localhost:3306
 Source Schema         : community_forum

 Target Server Type    : MySQL
 Target Server Version : 80012 (8.0.12)
 File Encoding         : 65001

 Date: 30/06/2026 20:15:07
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
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '分类表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES (1, '技术交流', '编程技术、软件开发相关话题', 1, '2026-06-29 17:30:54');
INSERT INTO `category` VALUES (2, '生活杂谈', '日常生活、兴趣爱好分享', 2, '2026-06-29 17:30:54');
INSERT INTO `category` VALUES (3, '资源分享', '学习资源、工具软件推荐', 3, '2026-06-29 17:30:54');
INSERT INTO `category` VALUES (4, '问答求助', '问题求助与技术问答', 4, '2026-06-29 17:30:54');
INSERT INTO `category` VALUES (5, '公告通知', '论坛公告与规则说明', 5, '2026-06-29 17:30:54');
INSERT INTO `category` VALUES (7, '游戏专栏', '游戏分享，攻略等', 7, '2026-06-30 16:35:24');
INSERT INTO `category` VALUES (8, '其他', '', 99, '2026-06-30 16:40:37');

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
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_post_id`(`post_id` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  CONSTRAINT `fk_comment_post` FOREIGN KEY (`post_id`) REFERENCES `post` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_comment_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '评论表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of comment
-- ----------------------------
INSERT INTO `comment` VALUES (1, '嗨嗨嗨\n', 3, 1, NULL, 0, '2026-06-30 15:05:46');
INSERT INTO `comment` VALUES (2, '欢迎分享', 1, 1, NULL, 0, '2026-06-30 15:06:24');
INSERT INTO `comment` VALUES (3, '222', 4, 1, NULL, 0, '2026-06-30 15:09:28');
INSERT INTO `comment` VALUES (4, '333', 4, 1, NULL, 0, '2026-06-30 15:13:33');
INSERT INTO `comment` VALUES (5, '444', 4, 1, NULL, 0, '2026-06-30 15:16:44');
INSERT INTO `comment` VALUES (6, '谢谢', 2, 1, 2, 0, '2026-06-30 15:21:40');
INSERT INTO `comment` VALUES (7, '对了，请关注永雏塔菲，谢谢喵', 4, 1, 2, 0, '2026-06-30 15:28:50');

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
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '收藏表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of favorite
-- ----------------------------
INSERT INTO `favorite` VALUES (7, 4, 1, '2026-06-30 15:43:47');
INSERT INTO `favorite` VALUES (8, 3, 1, '2026-06-30 15:49:16');
INSERT INTO `favorite` VALUES (14, 1, 2, '2026-06-30 16:41:22');
INSERT INTO `favorite` VALUES (15, 2, 1, '2026-06-30 19:51:25');
INSERT INTO `favorite` VALUES (16, 2, 2, '2026-06-30 19:51:36');
INSERT INTO `favorite` VALUES (18, 4, 2, '2026-06-30 20:03:06');

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '关注表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of follow
-- ----------------------------
INSERT INTO `follow` VALUES (1, 3, 1, '2026-06-30 16:48:39');
INSERT INTO `follow` VALUES (2, 2, 1, '2026-06-30 19:49:56');
INSERT INTO `follow` VALUES (3, 1, 2, '2026-06-30 19:50:32');
INSERT INTO `follow` VALUES (4, 3, 2, '2026-06-30 19:50:55');

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
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '点赞表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '私信表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 34 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '通知表' ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '帖子表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of post
-- ----------------------------
INSERT INTO `post` VALUES (1, '111', '111', 2, 4, 116, 4, 7, 0, 0, 0, '2026-06-29 17:40:30', '2026-06-29 17:40:30');
INSERT INTO `post` VALUES (2, '欢迎！！！', '欢迎大家积极分享内容，切勿违反社区规定', 1, 5, 19, 3, 0, 0, 1, 0, '2026-06-30 14:51:15', '2026-06-30 14:51:15');

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
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '搜索历史' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of search_history
-- ----------------------------
INSERT INTO `search_history` VALUES (1, 1, '欢迎', '2026-06-30 19:35:03');
INSERT INTO `search_history` VALUES (2, 1, '欢迎', '2026-06-30 19:35:32');
INSERT INTO `search_history` VALUES (3, 2, '欢迎', '2026-06-30 19:37:34');

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
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '搜索日志' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of search_log
-- ----------------------------
INSERT INTO `search_log` VALUES (1, '欢迎', '2026-06-30 19:35:04');
INSERT INTO `search_log` VALUES (2, '欢迎', '2026-06-30 19:35:32');
INSERT INTO `search_log` VALUES (3, '欢迎', '2026-06-30 19:37:34');

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
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '密保问题表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of security_question
-- ----------------------------
INSERT INTO `security_question` VALUES (1, 3, '你是谁', 'AAA', '2026-06-30 14:48:44');
INSERT INTO `security_question` VALUES (2, 3, '你在哪', 'BBB', '2026-06-30 14:48:44');
INSERT INTO `security_question` VALUES (3, 3, '你在干嘛', 'CCC', '2026-06-30 14:48:44');

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'admin', '社区管理员', '$2b$12$Rx/FMK9xKf9v5D/yjRt/ee/jNqIilv2CV24aoHT.tY/epzJrqctHa', 'admin@forum.com', '1595898985', 2, '/uploads/avatars/09d1c8ea-bd87-4f24-807d-a72bf2b428e5.jpg', '嗨嗨嗨', 'ADMIN', 0, '2026-06-29 17:30:54', '2026-06-29 17:30:54');
INSERT INTO `user` VALUES (2, 'testuser', '测试用户', '$2b$12$FT.ZrhgHSMhoOWgflUG3iO9GEp2a4kUjXE4.10J6c.WDL0C6UhWJ2', 'test@forum.com', '', 2, '/uploads/avatars/8f318054-b578-41aa-aa0a-f694bd540384.jpg', '', 'USER', 0, '2026-06-29 17:30:54', '2026-06-29 17:30:54');
INSERT INTO `user` VALUES (3, 'cjl794350', '江雨淋漓月朦胧', '$2a$10$7nardG73bR2ni0swm1BaHOZvOrMHDROj.aPNMUAh5/.vos7c/0WKK', '1985913833@qq.com', '', 0, '/uploads/avatars/2596f45a-7573-4cfd-a0a4-7598b8f996d9.jpg', '越努力，越幸运', 'USER', 0, '2026-06-30 14:29:31', '2026-06-30 14:29:31');
INSERT INTO `user` VALUES (4, 'abcd1234', 'YUN', '$2a$10$YN5O8iPPxdlqzhCCPRNA5usTtX0EROKw9oZSbqnCiAOGaULjIeXCO', '123@163.com', '', 2, '/uploads/avatars/b911b575-ef1b-46dc-936a-f4b881158242.jpg', '', 'USER', 0, '2026-06-30 15:08:57', '2026-06-30 15:08:57');

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
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '浏览历史表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of view_history
-- ----------------------------
INSERT INTO `view_history` VALUES (1, 2, 1, '2026-06-30 19:51:22');
INSERT INTO `view_history` VALUES (2, 1, 1, '2026-06-30 19:57:34');
INSERT INTO `view_history` VALUES (3, 3, 1, '2026-06-30 19:50:52');
INSERT INTO `view_history` VALUES (4, 1, 2, '2026-06-30 16:41:22');
INSERT INTO `view_history` VALUES (5, 3, 2, '2026-06-30 16:49:10');
INSERT INTO `view_history` VALUES (6, 4, 2, '2026-06-30 20:03:04');
INSERT INTO `view_history` VALUES (7, 4, 1, '2026-06-30 17:40:51');
INSERT INTO `view_history` VALUES (8, 2, 2, '2026-06-30 19:55:34');

SET FOREIGN_KEY_CHECKS = 1;
