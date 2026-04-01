/*
 Navicat Premium Dump SQL

 Source Server         : AXC
 Source Server Type    : MySQL
 Source Server Version : 80043 (8.0.43)
 Source Host           : localhost:3306
 Source Schema         : yinbo_music

 Target Server Type    : MySQL
 Target Server Version : 80043 (8.0.43)
 File Encoding         : 65001

 Date: 17/03/2026 00:29:42

 导入说明
 --------
 1. 本文件已包含 CREATE DATABASE + USE，整文件执行即可避免 1046（No database selected）。
 2. 命令行示例：mysql -u root -p < yinbo_music.sql
    或：mysql -u root -p -e "source /绝对路径/yinbo_music.sql"
 3. Navicat / DataGrip：也可不依赖 USE，先在左侧选中数据库 yinbo_music 再运行脚本。
 4. 与 application.yml 保持一致：库名 yinbo_music，字符集 utf8mb4_unicode_ci。
*/

CREATE DATABASE IF NOT EXISTS `yinbo_music` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `yinbo_music`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for announcements
-- ----------------------------
DROP TABLE IF EXISTS `announcements`;
CREATE TABLE `announcements`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `status` tinyint NULL DEFAULT 1,
  `created_by` bigint NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of announcements
-- ----------------------------
INSERT INTO `announcements` VALUES (2, '欢迎来到音波音乐！！', '我是管理员小艾！', 1, 14, '2026-03-14 20:38:07');

-- ----------------------------
-- Table structure for audit_logs
-- ----------------------------
DROP TABLE IF EXISTS `audit_logs`;
CREATE TABLE `audit_logs`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `operator_id` bigint NULL DEFAULT NULL,
  `action` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `target_id` bigint NULL DEFAULT NULL,
  `details` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_operator`(`operator_id` ASC) USING BTREE,
  INDEX `idx_action`(`action` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of audit_logs
-- ----------------------------

-- ----------------------------
-- Table structure for categories
-- ----------------------------
DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `icon` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sort` int NOT NULL DEFAULT 0,
  `deleted` tinyint NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_sort`(`sort` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of categories
-- ----------------------------
INSERT INTO `categories` VALUES (1, 'Pop', 'icon-pop', 1, 1, '2026-03-06 19:41:38');
INSERT INTO `categories` VALUES (2, 'Rock', 'icon-rock', 2, 1, '2026-03-06 19:41:38');
INSERT INTO `categories` VALUES (3, 'Folk', 'icon-folk', 3, 1, '2026-03-06 19:41:38');
INSERT INTO `categories` VALUES (4, 'Electronic', 'icon-electronic', 4, 1, '2026-03-06 19:41:38');
INSERT INTO `categories` VALUES (5, 'Classical', 'icon-classical', 5, 1, '2026-03-06 19:41:38');
INSERT INTO `categories` VALUES (6, 'Jazz', 'icon-jazz', 6, 1, '2026-03-06 19:41:38');
INSERT INTO `categories` VALUES (7, 'Hip-Hop', 'icon-hiphop', 7, 1, '2026-03-06 19:41:38');
INSERT INTO `categories` VALUES (8, 'R&B', 'icon-rnb', 8, 1, '2026-03-06 19:41:38');
INSERT INTO `categories` VALUES (9, '日语', '', 5, 0, '2026-03-11 15:42:46');
INSERT INTO `categories` VALUES (10, '纯音乐', '', 2, 0, '2026-03-11 20:25:46');
INSERT INTO `categories` VALUES (11, '国语', '', 0, 0, '2026-03-11 20:25:59');
INSERT INTO `categories` VALUES (12, '流行', '', 0, 0, '2026-03-11 20:26:13');
INSERT INTO `categories` VALUES (13, '说唱', '', 5, 0, '2026-03-11 20:26:56');
INSERT INTO `categories` VALUES (14, '民谣', '', 0, 0, '2026-03-11 20:27:13');
INSERT INTO `categories` VALUES (15, '古风', '', 0, 0, '2026-03-11 20:28:12');
INSERT INTO `categories` VALUES (16, '欧美', '', 0, 0, '2026-03-11 20:30:42');

-- ----------------------------
-- Table structure for comment_likes
-- ----------------------------
DROP TABLE IF EXISTS `comment_likes`;
CREATE TABLE `comment_likes`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `comment_id` bigint NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_comment`(`user_id` ASC, `comment_id` ASC) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_comment`(`comment_id` ASC) USING BTREE,
  CONSTRAINT `fk_comment_likes_comment` FOREIGN KEY (`comment_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_comment_likes_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 22 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of comment_likes
-- ----------------------------
INSERT INTO `comment_likes` VALUES (6, 13, 15, '2026-03-12 01:13:41');
INSERT INTO `comment_likes` VALUES (7, 13, 18, '2026-03-12 01:31:28');
INSERT INTO `comment_likes` VALUES (8, 16, 15, '2026-03-12 03:17:45');
INSERT INTO `comment_likes` VALUES (18, 15, 18, '2026-03-12 15:23:30');
INSERT INTO `comment_likes` VALUES (19, 13, 27, '2026-03-12 16:03:12');
INSERT INTO `comment_likes` VALUES (20, 13, 17, '2026-03-14 21:06:20');
INSERT INTO `comment_likes` VALUES (21, 13, 29, '2026-03-14 21:56:55');

-- ----------------------------
-- Table structure for comments
-- ----------------------------
DROP TABLE IF EXISTS `comments`;
CREATE TABLE `comments`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `track_id` bigint NOT NULL,
  `content` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_id` bigint NULL DEFAULT NULL,
  `floor` int NOT NULL DEFAULT 0 COMMENT 'Floor number',
  `like_count` int NOT NULL DEFAULT 0,
  `status` tinyint NOT NULL DEFAULT 1,
  `deleted` tinyint NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_track`(`track_id` ASC) USING BTREE,
  INDEX `idx_parent`(`parent_id` ASC) USING BTREE,
  INDEX `idx_floor`(`track_id` ASC, `floor` ASC) USING BTREE,
  CONSTRAINT `fk_comments_parent` FOREIGN KEY (`parent_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_comments_track` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_comments_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 31 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of comments
-- ----------------------------
INSERT INTO `comments` VALUES (13, 13, 31, '好听！！', NULL, 3, 0, 1, 0, '2026-03-11 18:33:09', '2026-03-11 18:33:09');
INSERT INTO `comments` VALUES (14, 13, 31, '+1', 13, 0, 0, 1, 0, '2026-03-11 18:33:19', '2026-03-11 18:33:19');
INSERT INTO `comments` VALUES (15, 13, 32, '烟花', NULL, 1, 2, 1, 0, '2026-03-12 01:13:39', '2026-03-12 01:13:39');
INSERT INTO `comments` VALUES (16, 13, 39, '心之痛', NULL, 1, 0, 1, 0, '2026-03-12 01:14:01', '2026-03-12 01:14:01');
INSERT INTO `comments` VALUES (17, 13, 41, '纯音乐好听', NULL, 1, 1, 1, 0, '2026-03-12 01:14:18', '2026-03-12 01:14:18');
INSERT INTO `comments` VALUES (18, 13, 64, '路人女主 惠', NULL, 1, 2, 1, 0, '2026-03-12 01:31:26', '2026-03-12 01:31:26');
INSERT INTO `comments` VALUES (19, 16, 32, '好听！', 15, 0, 0, 1, 0, '2026-03-12 03:27:33', '2026-03-12 03:27:33');
INSERT INTO `comments` VALUES (26, 15, 64, '先有圣人后有天，我惠美如画中仙！', 18, 0, 0, 1, 0, '2026-03-12 15:23:34', '2026-03-12 15:23:34');
INSERT INTO `comments` VALUES (27, 15, 91, '偏爱！', NULL, 1, 1, 1, 0, '2026-03-12 16:02:41', '2026-03-12 16:02:41');
INSERT INTO `comments` VALUES (28, 13, 91, '我不闪躲', 27, 0, 0, 1, 0, '2026-03-12 16:03:11', '2026-03-12 16:03:11');
INSERT INTO `comments` VALUES (29, 15, 93, '温文尔雅！', NULL, 1, 1, 1, 0, '2026-03-14 21:56:17', '2026-03-14 21:56:17');
INSERT INTO `comments` VALUES (30, 13, 93, '冬眠-非常好听的歌曲！', 29, 0, 0, 1, 0, '2026-03-14 21:56:53', '2026-03-14 21:56:53');

-- ----------------------------
-- Table structure for favorites
-- ----------------------------
DROP TABLE IF EXISTS `favorites`;
CREATE TABLE `favorites`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `track_id` bigint NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_track`(`user_id` ASC, `track_id` ASC) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_track`(`track_id` ASC) USING BTREE,
  CONSTRAINT `fk_favorites_track` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_favorites_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 93 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of favorites
-- ----------------------------
INSERT INTO `favorites` VALUES (54, 13, 25, '2026-03-09 18:07:55');
INSERT INTO `favorites` VALUES (58, 13, 26, '2026-03-09 18:39:34');
INSERT INTO `favorites` VALUES (59, 13, 27, '2026-03-09 18:39:38');
INSERT INTO `favorites` VALUES (60, 13, 28, '2026-03-09 18:39:39');
INSERT INTO `favorites` VALUES (61, 13, 29, '2026-03-09 18:44:36');
INSERT INTO `favorites` VALUES (62, 13, 31, '2026-03-09 18:45:04');
INSERT INTO `favorites` VALUES (64, 13, 3, '2026-03-10 22:35:36');
INSERT INTO `favorites` VALUES (66, 13, 30, '2026-03-10 22:41:06');
INSERT INTO `favorites` VALUES (69, 15, 3, '2026-03-11 01:22:55');
INSERT INTO `favorites` VALUES (71, 15, 27, '2026-03-11 01:37:00');
INSERT INTO `favorites` VALUES (72, 15, 29, '2026-03-11 01:37:01');
INSERT INTO `favorites` VALUES (74, 13, 32, '2026-03-11 21:37:22');
INSERT INTO `favorites` VALUES (75, 13, 43, '2026-03-11 23:26:58');
INSERT INTO `favorites` VALUES (76, 13, 34, '2026-03-12 01:19:43');
INSERT INTO `favorites` VALUES (78, 13, 64, '2026-03-12 01:29:38');
INSERT INTO `favorites` VALUES (79, 13, 65, '2026-03-12 01:34:46');
INSERT INTO `favorites` VALUES (80, 13, 66, '2026-03-12 01:34:47');
INSERT INTO `favorites` VALUES (81, 16, 40, '2026-03-12 03:17:32');
INSERT INTO `favorites` VALUES (82, 16, 64, '2026-03-12 03:31:13');
INSERT INTO `favorites` VALUES (83, 13, 60, '2026-03-12 14:07:22');
INSERT INTO `favorites` VALUES (86, 13, 49, '2026-03-12 14:54:11');
INSERT INTO `favorites` VALUES (87, 15, 44, '2026-03-12 15:25:25');
INSERT INTO `favorites` VALUES (88, 15, 91, '2026-03-12 15:25:26');
INSERT INTO `favorites` VALUES (89, 15, 64, '2026-03-12 15:50:41');
INSERT INTO `favorites` VALUES (90, 15, 32, '2026-03-12 15:59:06');
INSERT INTO `favorites` VALUES (91, 13, 92, '2026-03-13 15:24:58');
INSERT INTO `favorites` VALUES (92, 13, 41, '2026-03-14 20:47:06');

-- ----------------------------
-- Table structure for notifications
-- ----------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '接收者',
  `from_user_id` bigint NULL DEFAULT NULL COMMENT '触发者',
  `type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'FOLLOW/COMMENT_REPLY/LIKE',
  `ref_id` bigint NULL DEFAULT NULL COMMENT '关联ID(comment_id/track_id等)',
  `ref_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `extra` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '额外信息JSON',
  `read` tinyint NOT NULL DEFAULT 0 COMMENT '0未读 1已读',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_read`(`user_id` ASC, `read` ASC) USING BTREE,
  INDEX `idx_user_created`(`user_id` ASC, `created_at` DESC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of notifications
-- ----------------------------
INSERT INTO `notifications` VALUES (3, 15, 13, 'COMMENT_REPLY', 28, 'comment', '91', 1, '2026-03-12 16:03:11');
INSERT INTO `notifications` VALUES (4, 15, 13, 'LIKE', 27, 'comment', '91', 1, '2026-03-12 16:03:12');
INSERT INTO `notifications` VALUES (5, 15, 13, 'FOLLOW', 15, 'user', NULL, 1, '2026-03-12 16:05:15');
INSERT INTO `notifications` VALUES (6, 14, 13, 'FAVORITE', 92, 'track', '92', 0, '2026-03-13 15:24:58');
INSERT INTO `notifications` VALUES (7, 14, 13, 'FAVORITE', 41, 'track', '41', 0, '2026-03-14 20:47:05');
INSERT INTO `notifications` VALUES (8, 15, 13, 'FOLLOW', 15, 'user', NULL, 0, '2026-03-14 21:54:16');
INSERT INTO `notifications` VALUES (9, 14, 15, 'COMMENT', 29, 'comment', '93', 0, '2026-03-14 21:56:17');
INSERT INTO `notifications` VALUES (10, 15, 13, 'COMMENT_REPLY', 30, 'comment', '93', 0, '2026-03-14 21:56:53');
INSERT INTO `notifications` VALUES (11, 15, 13, 'LIKE', 29, 'comment', '93', 0, '2026-03-14 21:56:54');

-- ----------------------------
-- Table structure for play_history
-- ----------------------------
DROP TABLE IF EXISTS `play_history`;
CREATE TABLE `play_history`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `track_id` bigint NOT NULL,
  `duration_played` int NULL DEFAULT 0,
  `played_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_played_at`(`played_at` ASC) USING BTREE,
  INDEX `fk_play_history_track`(`track_id` ASC) USING BTREE,
  CONSTRAINT `fk_play_history_track` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_play_history_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 290 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of play_history
-- ----------------------------
INSERT INTO `play_history` VALUES (62, 14, 31, 174, '2026-03-11 14:31:20');
INSERT INTO `play_history` VALUES (64, 14, 26, 363, '2026-03-11 14:37:24');
INSERT INTO `play_history` VALUES (65, 14, 27, 184, '2026-03-11 14:40:27');
INSERT INTO `play_history` VALUES (67, 14, 29, 181, '2026-03-11 14:43:29');
INSERT INTO `play_history` VALUES (70, 14, 31, 174, '2026-03-11 14:50:10');
INSERT INTO `play_history` VALUES (72, 14, 28, 182, '2026-03-11 14:53:12');
INSERT INTO `play_history` VALUES (75, 14, 3, 350, '2026-03-11 14:59:02');
INSERT INTO `play_history` VALUES (76, 14, 25, 195, '2026-03-11 15:02:17');
INSERT INTO `play_history` VALUES (78, 14, 31, 174, '2026-03-11 15:05:11');
INSERT INTO `play_history` VALUES (81, 14, 28, 182, '2026-03-11 15:08:13');
INSERT INTO `play_history` VALUES (82, 14, 3, 350, '2026-03-11 15:14:03');
INSERT INTO `play_history` VALUES (85, 14, 25, 195, '2026-03-11 15:17:18');
INSERT INTO `play_history` VALUES (86, 14, 31, 174, '2026-03-11 15:20:12');
INSERT INTO `play_history` VALUES (88, 14, 28, 182, '2026-03-11 15:23:14');
INSERT INTO `play_history` VALUES (91, 14, 29, 181, '2026-03-11 15:32:06');
INSERT INTO `play_history` VALUES (93, 14, 30, 227, '2026-03-11 15:35:53');
INSERT INTO `play_history` VALUES (96, 14, 30, 227, '2026-03-11 15:50:01');
INSERT INTO `play_history` VALUES (97, 14, 26, 363, '2026-03-11 15:57:53');
INSERT INTO `play_history` VALUES (98, 14, 3, 350, '2026-03-11 16:03:43');
INSERT INTO `play_history` VALUES (101, 14, 31, 174, '2026-03-11 16:09:39');
INSERT INTO `play_history` VALUES (102, 14, 25, 195, '2026-03-11 16:12:53');
INSERT INTO `play_history` VALUES (104, 14, 28, 182, '2026-03-11 16:15:55');
INSERT INTO `play_history` VALUES (105, 14, 26, 363, '2026-03-11 16:21:58');
INSERT INTO `play_history` VALUES (108, 14, 27, 184, '2026-03-11 16:30:52');
INSERT INTO `play_history` VALUES (109, 14, 31, 174, '2026-03-11 16:33:46');
INSERT INTO `play_history` VALUES (111, 14, 28, 182, '2026-03-11 16:36:48');
INSERT INTO `play_history` VALUES (113, 14, 26, 363, '2026-03-11 16:42:51');
INSERT INTO `play_history` VALUES (116, 14, 27, 184, '2026-03-11 16:45:55');
INSERT INTO `play_history` VALUES (117, 14, 31, 174, '2026-03-11 16:48:49');
INSERT INTO `play_history` VALUES (118, 14, 25, 195, '2026-03-11 16:52:04');
INSERT INTO `play_history` VALUES (120, 14, 28, 182, '2026-03-11 16:55:05');
INSERT INTO `play_history` VALUES (122, 14, 26, 363, '2026-03-11 17:01:09');
INSERT INTO `play_history` VALUES (123, 14, 27, 184, '2026-03-11 17:04:12');
INSERT INTO `play_history` VALUES (125, 14, 31, 174, '2026-03-11 17:07:06');
INSERT INTO `play_history` VALUES (126, 14, 25, 195, '2026-03-11 17:10:21');
INSERT INTO `play_history` VALUES (128, 14, 28, 182, '2026-03-11 17:13:23');
INSERT INTO `play_history` VALUES (129, 14, 26, 363, '2026-03-11 17:19:26');
INSERT INTO `play_history` VALUES (131, 14, 27, 184, '2026-03-11 17:22:30');
INSERT INTO `play_history` VALUES (133, 14, 31, 174, '2026-03-11 17:25:24');
INSERT INTO `play_history` VALUES (134, 14, 25, 195, '2026-03-11 17:28:39');
INSERT INTO `play_history` VALUES (136, 14, 30, 227, '2026-03-11 17:32:26');
INSERT INTO `play_history` VALUES (139, 14, 3, 350, '2026-03-11 17:38:16');
INSERT INTO `play_history` VALUES (140, 14, 29, 181, '2026-03-11 17:41:17');
INSERT INTO `play_history` VALUES (141, 14, 31, 174, '2026-03-11 17:44:12');
INSERT INTO `play_history` VALUES (142, 14, 25, 195, '2026-03-11 17:47:26');
INSERT INTO `play_history` VALUES (144, 14, 30, 227, '2026-03-11 17:51:13');
INSERT INTO `play_history` VALUES (146, 14, 3, 350, '2026-03-11 17:57:04');
INSERT INTO `play_history` VALUES (149, 14, 31, 174, '2026-03-11 18:02:59');
INSERT INTO `play_history` VALUES (150, 14, 25, 195, '2026-03-11 18:06:14');
INSERT INTO `play_history` VALUES (152, 14, 28, 182, '2026-03-11 18:09:16');
INSERT INTO `play_history` VALUES (153, 14, 26, 363, '2026-03-11 18:15:19');
INSERT INTO `play_history` VALUES (155, 14, 29, 181, '2026-03-11 18:26:19');
INSERT INTO `play_history` VALUES (157, 14, 29, 181, '2026-03-11 18:29:21');
INSERT INTO `play_history` VALUES (159, 14, 32, 290, '2026-03-11 21:08:32');
INSERT INTO `play_history` VALUES (160, 14, 32, 290, '2026-03-11 21:50:32');
INSERT INTO `play_history` VALUES (161, 13, 32, 290, '2026-03-11 21:51:21');
INSERT INTO `play_history` VALUES (162, 14, 37, 253, '2026-03-11 22:06:50');
INSERT INTO `play_history` VALUES (163, 14, 38, 208, '2026-03-11 22:10:18');
INSERT INTO `play_history` VALUES (164, 14, 39, 273, '2026-03-11 22:14:51');
INSERT INTO `play_history` VALUES (165, 13, 39, 273, '2026-03-11 22:14:51');
INSERT INTO `play_history` VALUES (166, 13, 32, 290, '2026-03-11 22:19:41');
INSERT INTO `play_history` VALUES (167, 14, 32, 290, '2026-03-11 22:19:41');
INSERT INTO `play_history` VALUES (168, 14, 34, 251, '2026-03-11 22:23:52');
INSERT INTO `play_history` VALUES (169, 14, 41, 182, '2026-03-12 01:17:08');
INSERT INTO `play_history` VALUES (170, 13, 41, 182, '2026-03-12 01:17:51');
INSERT INTO `play_history` VALUES (171, 13, 64, 320, '2026-03-12 01:34:56');
INSERT INTO `play_history` VALUES (172, 13, 64, 320, '2026-03-12 01:34:56');
INSERT INTO `play_history` VALUES (173, 14, 64, 320, '2026-03-12 01:34:56');
INSERT INTO `play_history` VALUES (174, 13, 64, 320, '2026-03-12 01:36:59');
INSERT INTO `play_history` VALUES (175, 14, 32, 290, '2026-03-12 01:46:10');
INSERT INTO `play_history` VALUES (176, 13, 64, 320, '2026-03-12 01:48:12');
INSERT INTO `play_history` VALUES (177, 14, 41, 182, '2026-03-12 01:54:54');
INSERT INTO `play_history` VALUES (178, 13, 39, 273, '2026-03-12 01:59:27');
INSERT INTO `play_history` VALUES (179, 14, 64, 320, '2026-03-12 02:07:41');
INSERT INTO `play_history` VALUES (180, 13, 64, 320, '2026-03-12 02:07:41');
INSERT INTO `play_history` VALUES (181, 13, 39, 273, '2026-03-12 02:12:14');
INSERT INTO `play_history` VALUES (182, 14, 39, 273, '2026-03-12 02:12:14');
INSERT INTO `play_history` VALUES (183, 16, 87, 220, '2026-03-12 03:13:40');
INSERT INTO `play_history` VALUES (184, 13, 65, 222, '2026-03-12 14:13:50');
INSERT INTO `play_history` VALUES (185, 13, 65, 222, '2026-03-12 14:17:32');
INSERT INTO `play_history` VALUES (186, 13, 65, 222, '2026-03-12 14:21:14');
INSERT INTO `play_history` VALUES (187, 13, 65, 222, '2026-03-12 14:21:32');
INSERT INTO `play_history` VALUES (188, 13, 64, 320, '2026-03-12 14:26:44');
INSERT INTO `play_history` VALUES (189, 13, 66, 273, '2026-03-12 14:31:17');
INSERT INTO `play_history` VALUES (190, 13, 65, 222, '2026-03-12 14:34:59');
INSERT INTO `play_history` VALUES (191, 13, 64, 320, '2026-03-12 14:40:19');
INSERT INTO `play_history` VALUES (192, 13, 66, 273, '2026-03-12 14:45:14');
INSERT INTO `play_history` VALUES (193, 13, 92, 241, '2026-03-12 14:52:25');
INSERT INTO `play_history` VALUES (194, 13, 41, 182, '2026-03-12 14:58:28');
INSERT INTO `play_history` VALUES (195, 13, 37, 253, '2026-03-12 15:03:44');
INSERT INTO `play_history` VALUES (196, 13, 41, 182, '2026-03-12 15:06:45');
INSERT INTO `play_history` VALUES (202, 13, 64, 320, '2026-03-13 15:08:19');
INSERT INTO `play_history` VALUES (203, 13, 50, 342, '2026-03-13 15:16:24');
INSERT INTO `play_history` VALUES (204, 13, 50, 342, '2026-03-13 15:22:06');
INSERT INTO `play_history` VALUES (205, 13, 57, 201, '2026-03-13 15:32:46');
INSERT INTO `play_history` VALUES (206, 13, 88, 250, '2026-03-13 15:39:40');
INSERT INTO `play_history` VALUES (207, 13, 41, 182, '2026-03-13 15:44:38');
INSERT INTO `play_history` VALUES (208, 13, 64, 320, '2026-03-13 15:49:59');
INSERT INTO `play_history` VALUES (209, 13, 64, 320, '2026-03-14 21:11:47');
INSERT INTO `play_history` VALUES (210, 13, 32, 290, '2026-03-14 21:16:37');
INSERT INTO `play_history` VALUES (211, 13, 41, 182, '2026-03-14 21:19:39');
INSERT INTO `play_history` VALUES (212, 13, 39, 273, '2026-03-14 21:24:11');
INSERT INTO `play_history` VALUES (213, 13, 65, 222, '2026-03-14 21:27:53');
INSERT INTO `play_history` VALUES (214, 13, 37, 253, '2026-03-14 21:32:07');
INSERT INTO `play_history` VALUES (215, 13, 50, 342, '2026-03-14 21:37:49');
INSERT INTO `play_history` VALUES (216, 13, 32, 290, '2026-03-14 21:43:18');
INSERT INTO `play_history` VALUES (217, 13, 41, 182, '2026-03-14 21:46:20');
INSERT INTO `play_history` VALUES (218, 13, 39, 273, '2026-03-14 21:50:52');
INSERT INTO `play_history` VALUES (219, 15, 90, 178, '2026-03-14 21:58:20');
INSERT INTO `play_history` VALUES (220, 15, 90, 178, '2026-03-14 22:01:19');
INSERT INTO `play_history` VALUES (221, 15, 56, 151, '2026-03-14 22:06:37');
INSERT INTO `play_history` VALUES (222, 15, 56, 151, '2026-03-14 22:09:08');
INSERT INTO `play_history` VALUES (223, 15, 56, 151, '2026-03-14 22:11:39');
INSERT INTO `play_history` VALUES (224, 15, 56, 151, '2026-03-14 22:14:09');
INSERT INTO `play_history` VALUES (225, 15, 56, 151, '2026-03-14 22:16:40');
INSERT INTO `play_history` VALUES (226, 15, 56, 151, '2026-03-14 22:19:11');
INSERT INTO `play_history` VALUES (227, 15, 56, 151, '2026-03-14 22:21:42');
INSERT INTO `play_history` VALUES (228, 15, 56, 151, '2026-03-14 22:24:12');
INSERT INTO `play_history` VALUES (229, 15, 56, 151, '2026-03-14 22:26:43');
INSERT INTO `play_history` VALUES (230, 15, 56, 151, '2026-03-14 22:29:14');
INSERT INTO `play_history` VALUES (231, 15, 56, 151, '2026-03-14 22:31:44');
INSERT INTO `play_history` VALUES (232, 15, 56, 151, '2026-03-14 22:34:15');
INSERT INTO `play_history` VALUES (233, 15, 56, 151, '2026-03-14 22:36:46');
INSERT INTO `play_history` VALUES (234, 15, 56, 151, '2026-03-14 22:39:17');
INSERT INTO `play_history` VALUES (235, 15, 56, 151, '2026-03-14 22:41:47');
INSERT INTO `play_history` VALUES (236, 15, 56, 151, '2026-03-14 22:44:18');
INSERT INTO `play_history` VALUES (237, 15, 56, 151, '2026-03-14 22:46:49');
INSERT INTO `play_history` VALUES (238, 15, 56, 151, '2026-03-14 22:49:20');
INSERT INTO `play_history` VALUES (239, 15, 56, 151, '2026-03-14 22:51:50');
INSERT INTO `play_history` VALUES (240, 15, 56, 151, '2026-03-14 22:54:21');
INSERT INTO `play_history` VALUES (241, 15, 56, 151, '2026-03-14 22:56:52');
INSERT INTO `play_history` VALUES (242, 15, 56, 151, '2026-03-14 22:59:22');
INSERT INTO `play_history` VALUES (243, 15, 56, 151, '2026-03-14 23:01:53');
INSERT INTO `play_history` VALUES (244, 15, 56, 151, '2026-03-14 23:04:24');
INSERT INTO `play_history` VALUES (245, 15, 56, 151, '2026-03-14 23:06:55');
INSERT INTO `play_history` VALUES (246, 15, 56, 151, '2026-03-14 23:09:25');
INSERT INTO `play_history` VALUES (247, 15, 56, 151, '2026-03-14 23:11:56');
INSERT INTO `play_history` VALUES (248, 15, 56, 151, '2026-03-14 23:14:27');
INSERT INTO `play_history` VALUES (249, 15, 56, 151, '2026-03-14 23:16:57');
INSERT INTO `play_history` VALUES (250, 15, 56, 151, '2026-03-14 23:19:28');
INSERT INTO `play_history` VALUES (251, 15, 56, 151, '2026-03-14 23:21:59');
INSERT INTO `play_history` VALUES (252, 15, 56, 151, '2026-03-14 23:24:30');
INSERT INTO `play_history` VALUES (253, 15, 56, 151, '2026-03-14 23:27:00');
INSERT INTO `play_history` VALUES (254, 15, 56, 151, '2026-03-14 23:29:31');
INSERT INTO `play_history` VALUES (255, 15, 56, 151, '2026-03-14 23:32:02');
INSERT INTO `play_history` VALUES (256, 15, 56, 151, '2026-03-14 23:34:32');
INSERT INTO `play_history` VALUES (257, 15, 56, 151, '2026-03-14 23:37:03');
INSERT INTO `play_history` VALUES (258, 15, 56, 151, '2026-03-14 23:39:34');
INSERT INTO `play_history` VALUES (259, 15, 53, 239, '2026-03-14 23:44:38');
INSERT INTO `play_history` VALUES (260, 15, 53, 239, '2026-03-14 23:48:37');
INSERT INTO `play_history` VALUES (261, 15, 53, 239, '2026-03-14 23:52:35');
INSERT INTO `play_history` VALUES (262, 15, 53, 239, '2026-03-14 23:56:34');
INSERT INTO `play_history` VALUES (263, 15, 53, 239, '2026-03-15 00:00:33');
INSERT INTO `play_history` VALUES (264, 15, 53, 239, '2026-03-15 00:04:31');
INSERT INTO `play_history` VALUES (265, 15, 53, 239, '2026-03-15 00:08:30');
INSERT INTO `play_history` VALUES (266, 15, 53, 239, '2026-03-15 00:12:29');
INSERT INTO `play_history` VALUES (267, 15, 53, 239, '2026-03-15 00:16:27');
INSERT INTO `play_history` VALUES (268, 15, 53, 239, '2026-03-15 00:20:26');
INSERT INTO `play_history` VALUES (269, 15, 53, 239, '2026-03-15 00:24:25');
INSERT INTO `play_history` VALUES (270, 15, 53, 239, '2026-03-15 00:28:23');
INSERT INTO `play_history` VALUES (271, 15, 53, 239, '2026-03-15 00:32:22');
INSERT INTO `play_history` VALUES (272, 15, 53, 239, '2026-03-15 00:36:20');
INSERT INTO `play_history` VALUES (273, 15, 53, 239, '2026-03-15 00:40:19');
INSERT INTO `play_history` VALUES (274, 15, 53, 239, '2026-03-15 00:44:18');
INSERT INTO `play_history` VALUES (275, 15, 53, 239, '2026-03-15 00:48:16');
INSERT INTO `play_history` VALUES (276, 15, 53, 239, '2026-03-15 00:52:15');
INSERT INTO `play_history` VALUES (277, 15, 53, 239, '2026-03-15 00:56:14');
INSERT INTO `play_history` VALUES (278, 15, 53, 239, '2026-03-15 01:00:12');
INSERT INTO `play_history` VALUES (279, 15, 53, 239, '2026-03-15 01:04:11');
INSERT INTO `play_history` VALUES (280, 15, 53, 239, '2026-03-15 01:08:10');
INSERT INTO `play_history` VALUES (281, 15, 53, 239, '2026-03-15 01:12:08');
INSERT INTO `play_history` VALUES (282, 15, 53, 239, '2026-03-15 01:16:07');
INSERT INTO `play_history` VALUES (283, 15, 53, 239, '2026-03-15 01:20:05');
INSERT INTO `play_history` VALUES (284, 15, 53, 239, '2026-03-15 01:24:04');
INSERT INTO `play_history` VALUES (285, 15, 53, 239, '2026-03-15 01:28:03');
INSERT INTO `play_history` VALUES (286, 15, 53, 239, '2026-03-15 01:32:01');
INSERT INTO `play_history` VALUES (287, 15, 53, 239, '2026-03-15 01:36:00');
INSERT INTO `play_history` VALUES (288, 15, 53, 239, '2026-03-15 01:39:59');
INSERT INTO `play_history` VALUES (289, 15, 53, 239, '2026-03-15 01:43:57');

-- ----------------------------
-- Table structure for playlist_items
-- ----------------------------
DROP TABLE IF EXISTS `playlist_items`;
CREATE TABLE `playlist_items`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `playlist_id` bigint NOT NULL,
  `track_id` bigint NOT NULL,
  `position` int NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_playlist_track`(`playlist_id` ASC, `track_id` ASC) USING BTREE,
  INDEX `idx_playlist`(`playlist_id` ASC) USING BTREE,
  INDEX `idx_track`(`track_id` ASC) USING BTREE,
  CONSTRAINT `fk_playlist_items_playlist` FOREIGN KEY (`playlist_id`) REFERENCES `playlists` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_playlist_items_track` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of playlist_items
-- ----------------------------
INSERT INTO `playlist_items` VALUES (6, 4, 62, 1, '2026-03-12 03:15:00');
INSERT INTO `playlist_items` VALUES (7, 4, 74, 2, '2026-03-12 03:15:02');
INSERT INTO `playlist_items` VALUES (8, 4, 40, 3, '2026-03-12 03:15:06');
INSERT INTO `playlist_items` VALUES (9, 5, 49, 1, '2026-03-12 14:55:15');
INSERT INTO `playlist_items` VALUES (10, 5, 39, 2, '2026-03-12 14:55:18');
INSERT INTO `playlist_items` VALUES (11, 6, 58, 1, '2026-03-12 14:58:17');
INSERT INTO `playlist_items` VALUES (12, 7, 91, 1, '2026-03-12 15:25:19');
INSERT INTO `playlist_items` VALUES (13, 7, 44, 2, '2026-03-12 15:25:22');

-- ----------------------------
-- Table structure for playlists
-- ----------------------------
DROP TABLE IF EXISTS `playlists`;
CREATE TABLE `playlists`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cover_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cover_key` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `owner_id` bigint NOT NULL,
  `is_public` tinyint NOT NULL DEFAULT 1,
  `play_count` bigint NOT NULL DEFAULT 0,
  `track_count` int NOT NULL DEFAULT 0,
  `deleted` tinyint NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_owner`(`owner_id` ASC) USING BTREE,
  INDEX `idx_public`(`is_public` ASC) USING BTREE,
  CONSTRAINT `fk_playlists_owner` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of playlists
-- ----------------------------
INSERT INTO `playlists` VALUES (3, '治愈', '温文尔雅', 'http://127.0.0.1:9000/yinbomusic/cover/4073dc63-9a5c-4dc5-8443-d8f3935967c7.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T172735Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=e7e5c9649ccf79d19b37153b7b8c8069deea14f7d7dd88c29c37d81a9c93c0d2', 'cover/4073dc63-9a5c-4dc5-8443-d8f3935967c7.jpg', 13, 1, 0, 1, 1, '2026-03-12 01:27:35', '2026-03-12 01:45:41');
INSERT INTO `playlists` VALUES (4, '夏目贵志爱听', '夏目贵志！', 'http://127.0.0.1:9000/yinbomusic/cover/9be0e47c-a7a8-4113-bf11-877629a1e23d.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T191454Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=213b8a48defbfb4b406014f9fa31685e53d427cc2b2d9f7402512c4ba5e2189e', 'cover/9be0e47c-a7a8-4113-bf11-877629a1e23d.jpg', 16, 1, 0, 3, 0, '2026-03-12 03:14:55', '2026-03-12 03:14:55');
INSERT INTO `playlists` VALUES (5, '神威难藏泪', '我已经不在乎了', 'http://127.0.0.1:9000/yinbomusic/cover/c737b839-0262-4bad-8e40-85928185daa8.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260312%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260312T065512Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=f55c7e2ab044f2ec50e731af23d459f0e8c9c842160de267366c89a3b66017c3', 'cover/c737b839-0262-4bad-8e40-85928185daa8.jpg', 13, 1, 0, 2, 0, '2026-03-12 14:55:12', '2026-03-12 14:55:12');
INSERT INTO `playlists` VALUES (6, '羁绊', '这双眼睛', 'http://127.0.0.1:9000/yinbomusic/cover/dcd8f459-3858-4f8a-96f5-86d661835ba5.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260312%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260312T065809Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=63251ee83a6dfd874cf845a5400358feadee1a12dae9337308a767f4fa60402f', 'cover/dcd8f459-3858-4f8a-96f5-86d661835ba5.jpg', 13, 1, 0, 1, 0, '2026-03-12 14:58:09', '2026-03-12 14:58:09');
INSERT INTO `playlists` VALUES (7, '蜡笔小新的音乐屋', '团结 友善 真诚', 'http://127.0.0.1:9000/yinbomusic/cover/a5f20a63-7d73-443d-ab9e-32f3b8f8b988.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260312%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260312T072508Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=fb7263166ee92b93ddc2ff1d423bfa50de5f1eaee7f2035dd90b268c2f8aa9ee', 'cover/a5f20a63-7d73-443d-ab9e-32f3b8f8b988.jpg', 15, 1, 0, 2, 0, '2026-03-12 15:25:09', '2026-03-12 15:25:09');

-- ----------------------------
-- Table structure for search_hot_words
-- ----------------------------
DROP TABLE IF EXISTS `search_hot_words`;
CREATE TABLE `search_hot_words`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `keyword` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `search_count` int NULL DEFAULT 0,
  `updated_at` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_keyword`(`keyword` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of search_hot_words
-- ----------------------------

-- ----------------------------
-- Table structure for singers
-- ----------------------------
DROP TABLE IF EXISTS `singers`;
CREATE TABLE `singers`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '歌手名',
  `avatar_key` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'MinIO 头像 key',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '简介',
  `deleted` tinyint NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 47 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of singers
-- ----------------------------
INSERT INTO `singers` VALUES (1, '花君', 'singer/60c03bdc-41cf-4d11-bf69-423ae25a59e8.jpg', '温文尔雅', 0, '2026-03-11 14:46:44', '2026-03-11 14:46:44');
INSERT INTO `singers` VALUES (2, 'Lisa', NULL, NULL, 1, '2026-03-11 18:31:57', '2026-03-11 20:28:45');
INSERT INTO `singers` VALUES (3, '米津玄師', 'singer/f384229d-629a-4390-b08c-3d0de91914bd.jpg', '米津玄师（Yonezu Kenshi），1991年3月10日出生于日本德岛县德岛市，日本流行乐男歌手、词曲作者、音乐制作人、插画家、舞者。', 0, '2026-03-11 21:00:19', '2026-03-11 21:00:19');
INSERT INTO `singers` VALUES (4, 'HENRY刘宪华', 'singer/553d9120-7ca2-4ed5-8173-4e783e5c1616.jpg', '刘宪华（Henry Lau、헨리），1989年10月11日出生于加拿大多伦多北约克区 ，毕业于伯克利音乐学院，加拿大籍华裔流行乐男歌手、影视演员、主持人，前韩国男子演唱组合Super Junior-M成员。', 0, '2026-03-11 21:07:58', '2026-03-11 21:07:58');
INSERT INTO `singers` VALUES (5, 'LiSA', 'singer/761e190e-ff0a-4b89-8cc0-409360ff31e5.webp', 'LiSA，本名织部里沙，1987年6月24日出生于日本岐阜县，日本女歌手。', 0, '2026-03-11 21:09:59', '2026-03-11 21:09:59');
INSERT INTO `singers` VALUES (6, '澤野弘之', 'singer/f580d8fd-1730-46a7-8111-3f1cbce1cdd0.webp', '泽野弘之（さわの ひろゆき、Sawano Hiroyuki），男，1980年9月12日出生于日本东京都，是日本作曲家、编曲家。  所属事务所是VV-ALKLINE。', 0, '2026-03-11 21:17:37', '2026-03-11 21:17:37');
INSERT INTO `singers` VALUES (7, 'RADWIMPS', 'singer/6bbbca6d-738c-47a7-ab40-076a7fd7780e.png', '拉德温普斯（RADWIMPS，ラッドウインプス），日本摇滚乐队 ，简称RAD，由主唱及吉他手野田洋次郎、吉他手桑原彰、贝斯手武田祐介和鼓手山口智史组成。隶属于环球音乐旗下的Muzinto Records和百代唱片公司  。', 0, '2026-03-11 21:18:35', '2026-03-11 21:18:35');
INSERT INTO `singers` VALUES (8, 'ReoNa', 'singer/ed24a5eb-2cf1-428b-869c-4d9a261c85bc.png', 'ReoNa，1998年10月20日出生于日本 ，日本女歌手，隶属唱片公司是日本索尼音乐娱乐公司旗下的SACRA MUSIC。2018年8月29日，通过发行单曲《SWEET HURT》从而正式出道。代表曲有《SWEET HURT》《forget-me-not》《Null》《ANIMA》。', 0, '2026-03-11 21:19:10', '2026-03-11 21:19:10');
INSERT INTO `singers` VALUES (9, 'majiko', 'singer/0753f6c0-a380-46de-8bec-85cf1dbe8d83.png', 'majiko（别名：まじ娘），1992年10月28日出生于日本东京，天蝎座，日本女歌手。她以网络投稿翻唱作品出道，凭借富有感情穿透力的歌声获得关注，并涉及作词、作曲、编曲及专辑封面设计等多领域创作。2010年以“まじ娘”名义投稿翻唱视频开启音乐活动 。2013年12月23日首次参加Exit Tunes Academy现场演出 [2]。2017年2月改艺名为majiko并发行首张迷你专辑《CLOUD 7》。2018年3月转会后推出第二张迷你专辑《AUBE》，同年7月发行电视剧《限界団地》主题曲《ひび割れた世界》 [4-5]。2019年6月发布首张完整专辑《寂しい人が一番伟いんだ》，同年10月在中国上海、北京、广州举行巡回演唱会。2021年8月18日发行以蝉为主题的夏季单曲《白い蝉》。', 0, '2026-03-11 21:19:53', '2026-03-11 21:19:53');
INSERT INTO `singers` VALUES (10, '4円', 'singer/6758de37-f246-4a1f-879e-2271bfac6b27.png', '4円（4 yen），本名不详，1989年7月23日出生于日本，Niconico动画平台知名男性唱见。艺名源于钱包中仅剩4日元时投稿出道，以慵懒声线与吉他弹唱为特色，音乐风格涵盖叙事曲、电子乐及摇滚。2010年8月通过翻唱《RAINBOW GIRL》开启活动，中学曾担任乐队主唱，2012年正式结束学生生涯。', 0, '2026-03-11 21:20:20', '2026-03-11 21:20:20');
INSERT INTO `singers` VALUES (11, 'Sou', 'singer/d4afe153-132b-426b-83ea-e952ab55d9f2.jpg', 'Sou（ソウ），1998年8月19日出生，日本歌手 。\r\nSou以网络为中心展开活动。2018年，发行的与Eve合作的专辑《苍》大受欢迎，2019年3月，发布首张自作曲《愚者のパレード》；同年7月，带着发售的第二张专辑《深层から》举行的首次东名阪个人巡回演唱会《深层から见た景色》。2020年1月，发布了电视动画片《ID:INVADED》的片头曲《ミスターフィクサー》。 [2]2022年5月，发表了由かいりきベアが作词作曲的歌曲《スパークバグ》 。2023年4月10日，发行歌曲《尼禄》，为动画《亡骸游戏》的片头曲 。', 0, '2026-03-11 21:20:59', '2026-03-11 21:20:59');
INSERT INTO `singers` VALUES (12, 'Aimer', 'singer/fbae58c9-acc1-4089-92e3-da2ba61bd6af.png', 'Aimer（エメ），本名、生日等个人信息未公开，日本女歌手、歌词作者。2011年6月至2015年9月，隶属于日本索尼音乐娱乐旗下的DefSTAR Records，2015年9月，移籍至SME Records，并在2021年9月，再次移籍至SACRA MUSIC旗下。其艺名“Aimer”在法语中意为“爱”，在作词填词活动中使用的署名是aimerrhythm。其所属事务所是agehasprings。', 0, '2026-03-11 21:21:30', '2026-03-11 21:21:30');
INSERT INTO `singers` VALUES (13, 'YOASOBI', 'singer/4925cb2b-34c5-4050-907d-580ae4609a2f.webp', 'YOASOBI（ヨアソビ、夜遊び），日本音乐组合，由词曲创作者Ayase、主唱几田莉拉（ikura）组成。2019年10月1日，VOCALOID音乐制作人Ayase与创作歌手几田莉拉（ikura）正式组建了将小说音乐化的组合YOASOBI；11月，发布组合第一首单曲《向夜晚奔去》，从而正式出道。', 0, '2026-03-11 21:22:07', '2026-03-11 21:22:07');
INSERT INTO `singers` VALUES (14, '夏婉安', 'singer/70f59621-6584-4c91-b7e0-8885084a0a8f.webp', '夏婉安，中国华语女歌手，集词曲唱于一身的音乐人，代表作《一个人》《越爱越难过》《忘川》《泡沫》《后来》《别，爱》等。', 1, '2026-03-11 21:22:42', '2026-03-12 00:35:33');
INSERT INTO `singers` VALUES (15, '徐良', 'singer/211e8b81-a5e6-4321-83bc-f73ace978bac.png', '徐良，外文名L，1987年2月8日生于山东省青岛市，中国内地男歌手、音乐人，代表作品《坏女孩》。', 0, '2026-03-11 21:23:06', '2026-03-11 21:23:06');
INSERT INTO `singers` VALUES (16, '许嵩', 'singer/69de9d72-c7df-4c56-8be9-7272a6b555d4.webp', '中国内地男歌手、词曲作者、音乐制作人。\r\n许嵩，1986年5月14日出生于安徽省合肥市，毕业于安徽医科大学，中国内地流行乐男歌手、词曲作者、音乐制作人。2006年，以笔名“Vae”开始发表原创单曲。', 0, '2026-03-11 21:23:38', '2026-03-11 21:23:38');
INSERT INTO `singers` VALUES (17, '徐秉龙', 'singer/4391a7c8-6fc4-4580-b074-c576e77d8e02.webp', '徐秉龙，2000年4月2日出生于浙江省台州市，中国内地流行乐男歌手。', 0, '2026-03-11 21:24:00', '2026-03-11 21:24:00');
INSERT INTO `singers` VALUES (18, '周深', 'singer/11af73f0-bf20-40e8-a9c6-dbfd7a04dee4.png', '中国内地男歌手、音乐制作人、青年歌唱家。\r\n周深（Charlie），1992年9月29日出生于湖南省邵阳市，成长于贵州省贵阳市，中国内地男歌手、音乐制作人、青年歌唱家，毕业于乌克兰利沃夫国立立谢科音乐科学院声乐歌剧专业。2014年，参加节目《中国好声音第三季》正式出道。', 0, '2026-03-11 21:24:41', '2026-03-11 21:24:41');
INSERT INTO `singers` VALUES (19, 'TRUE (唐沢美帆)', 'singer/f8cdd2a9-093e-4fac-b29c-1f248c03bfbe.png', '唐沢美帆，1983年7月15日出生于日本东京都，是一名日本女歌手、作词家。她于2000年出道并发行首张单曲《anytime, anywhere》。2001年，其歌曲《Way To Love》被用作电视剧插入歌 。她随后发行了《ライヴ》、《Endless Harmony》等单曲，以及《sparkle》、《ID.》等专辑。2014年起，她以“TRUE”为艺名开展活动，为《Buddy Complex》、《吹响吧！上低音号》、《Violet Evergarden》等多部动画演唱主题曲 。', 0, '2026-03-11 21:25:57', '2026-03-11 21:25:57');
INSERT INTO `singers` VALUES (20, '花澤香菜', 'singer/7613d974-a885-42bd-9fcc-2c617884dc0d.webp', '花泽香菜（日文名：はなざわ かな），1989年2月25日出生于日本东京都，日本女性配音演员、演员、歌手，配音事务隶属于大泽事务所，唱片公司为波丽佳音。', 0, '2026-03-11 21:28:25', '2026-03-11 21:28:25');
INSERT INTO `singers` VALUES (21, '中島美嘉', 'singer/c2f2517e-7dd8-4f23-8fee-1c47b9020022.png', '中岛美嘉（なかしまみか、Mika Nakashima ），1983年2月19日出生于日本鹿儿岛县，日本女歌手、演员', 0, '2026-03-11 21:29:06', '2026-03-11 21:29:06');
INSERT INTO `singers` VALUES (22, '张芸京', 'singer/6237db5c-3a62-41fd-93d6-df572b0acfea.png', '张芸京（Jing chang），1983年9月6日出生于台湾省台北市，中国台湾流行乐女歌手，毕业于台北市立松山高级商业家事职业学校广告设计科。', 0, '2026-03-11 21:29:32', '2026-03-11 21:29:32');
INSERT INTO `singers` VALUES (23, 'RSP', 'singer/85ad3f86-286b-417e-b22c-28df49cbcab1.png', '日本偶像演唱舞蹈组合\r\nRSP（外文名：Real Street Performance）是日本关西地区出道的偶像演唱舞蹈组合，由主唱Ai、Saki及舞者Yui、Eri、Hiromu、Tomo组成，隶属于Sony音乐旗下 [1] [3-4]。该组合2006年12月发行首张单曲《A Street Story》进入关西销售榜前十，主演同名电视剧获得高收视率；2007年8月发行第二张单曲《Lifetime Respect -女编-》后开展全国性活动。代表作包括专辑《ii》、单曲《さくら 〜あなたに出会えてよかった〜》及《感谢。》《旅立つキミへ》等多首《死神》动画片尾曲 。', 0, '2026-03-11 21:31:04', '2026-03-11 21:31:04');
INSERT INTO `singers` VALUES (24, '张紫豪', 'singer/bedd5aec-825f-4d5d-a1fe-6f5d744c3ab5.png', '中国内地男歌手，代表作《可不可以》', 0, '2026-03-11 21:32:52', '2026-03-11 21:32:52');
INSERT INTO `singers` VALUES (25, 'UnicornPhantom', 'singer/fcf25900-9073-434e-bd2d-067b54fb333b.jpg', '独立音乐人', 0, '2026-03-11 21:50:41', '2026-03-14 19:34:23');
INSERT INTO `singers` VALUES (26, 'HOYO-MiX', 'singer/769e1164-8a9e-4a8f-9549-a894308d9c15.jpg', '原神动画', 0, '2026-03-11 21:53:44', '2026-03-11 21:53:44');
INSERT INTO `singers` VALUES (27, '泠鸢yousa', 'singer/4b98c60c-9f14-49e7-af8e-9c87d1247c02.png', '泠鸢yousa.\r\n虚拟艺人、哔哩哔哩虚拟歌手、虚拟UP主。', 0, '2026-03-11 22:16:27', '2026-03-11 22:16:27');
INSERT INTO `singers` VALUES (28, '當山みれい', 'singer/4ae27334-ae18-42c3-8422-9fbe32852969.jpg', '當山 みれい (とうやま みれい，女，1998年7月27日出生）是日本创作歌手和舞蹈家。其父亲为冲绳人， “當山”（当山）这一姓氏也是冲绳特有的姓氏之一。附属唱片公司是MASTERSIX FOUNDATION，附属经纪公司是YARD。', 0, '2026-03-11 22:23:20', '2026-03-11 22:23:20');
INSERT INTO `singers` VALUES (29, '塞西尔·科贝尔（Cécile Corbel）', 'singer/ab24a32d-7743-4421-aa40-96f32233cb02.jpg', '塞西尔·科贝尔（Cécile Corbel），1980年3月28日出生于法国菲尼斯泰尔省蓬克鲁瓦市，法国歌手、竖琴演奏家。创作有专辑《Harpe Celtique et Chants du Monde》、《SongBook 1》、《Songbook Vol. 2》、《Songbook Vol. 3 Renaissance》、《Songbook Vol. 4 Roses》等', 0, '2026-03-11 23:39:30', '2026-03-11 23:39:30');
INSERT INTO `singers` VALUES (30, 'CORSAK胡梦周', 'singer/fc8e2a32-3741-4cc5-a8c8-4224110b40a7.jpg', '个人介绍：代表作品《溯》、《芽》、《归》、《DIFFERENT WORLD》、《Sad Sometimes》 来自上海的CORSAK，是一位唱作词曲编全能的音乐才子、DJ和制作人，他将自身所受到的古典音乐教育与创新的EDM完美地相结合在一起。 2017年发行首张单曲《溯Reverse》，截止目前获得14亿次播放量。 2018年与国际知名DJ Alan Walker共同制作其首张个人专辑主打歌《Different World》。 这位来自Liquid State厂牌的正能量励志偶像，展示他特有的能够将中国传统文化和现代化完美结合的混合曲风, 蕴藏着巨大的商业潜能。这样独特的音乐天赋，让人不容错过。', 0, '2026-03-11 23:42:43', '2026-03-11 23:42:43');
INSERT INTO `singers` VALUES (31, 'Muyoi&Pezzi', 'singer/b9561242-f165-4287-aba9-01e35af94771.jpg', 'Muyoi莫悠，中国内地抖音音乐人，IP属地广西，认证为“抖音音乐人”。', 0, '2026-03-12 00:03:53', '2026-03-12 00:03:53');
INSERT INTO `singers` VALUES (32, 'TK', 'singer/55abc3d7-d0bd-4812-b449-010f3a69e3c1.jpg', 'TK（1982年12月23日—），即TK from凛として时雨，本名北嶋彻（きたじま とおる，Kitajima Toru），出生于日本埼玉县 ，日本歌手、音乐人，在乐队凛として时雨（凛冽时雨）中担任主唱（ボーカル）、吉他手（ギター） [2]。其音乐流派涵盖摇滚、独立摇滚、后摇滚等，擅长吉他、贝斯、钢琴等多种乐器 。代表作品包括《film A moment》、《flowering》、《unravel》、《Secret Sensation》 ，以及《white silence》、《first death》、《P.S. RED I》等 。', 0, '2026-03-12 00:06:48', '2026-03-12 00:06:48');
INSERT INTO `singers` VALUES (33, '安野希世乃', 'singer/8b04a146-24e0-4959-b787-6b5cd19f22bf.jpg', '安野希世乃（やすの きよの），1989年7月9日出生于日本宫城县 ，日本女性配音演员、歌手，所属事务所为Avex Planning&Development，唱片公司为Flying Dog。', 0, '2026-03-12 00:14:49', '2026-03-12 00:14:49');
INSERT INTO `singers` VALUES (34, '白挺', 'singer/df81f61b-4f1d-422e-a98d-cdace26fff5e.jpg', '白挺（Mr.Write），中国内地男歌手，汉族，出生于广东深圳，毕业于星海音乐学院，是国产动漫《熊出没》御用歌手及华强数字动漫公司音频部部长。', 0, '2026-03-12 00:18:43', '2026-03-12 00:18:43');
INSERT INTO `singers` VALUES (35, '蔡健雅', 'singer/dbdd16d7-1528-4266-91dc-d517bdec1ae2.jpg', '蔡健雅（Tanya Chua），1975年1月28日出生于新加坡，华语流行乐女歌手、词曲作者、音乐制作人。', 0, '2026-03-12 00:20:15', '2026-03-12 00:20:15');
INSERT INTO `singers` VALUES (36, '出羽良彰', 'singer/1adc931b-2557-4a5b-9c4d-cfec862800de.jpg', '出羽良彰（1984年2月26日—），日本作曲家、编曲家，出生于大阪府松原市，现以音乐组合树海成员及影视配乐作曲家身份活跃。', 0, '2026-03-12 00:22:20', '2026-03-12 00:22:20');
INSERT INTO `singers` VALUES (37, '焦迈奇', 'singer/22c2831d-40cd-47e4-a9ed-30b24a6ec940.jpg', '焦迈奇，1996年10月4日出生于山东省潍坊市，中国内地流行乐男歌手、词曲作者、演员，毕业于沈阳音乐学院。', 0, '2026-03-12 00:24:15', '2026-03-12 00:24:15');
INSERT INTO `singers` VALUES (38, '乐柠组合', 'singer/5bf6fca9-0584-4a97-9d6c-8bf768db1b01.jpg', '乐柠组合（任金勇、杨清柠）', 0, '2026-03-12 00:26:35', '2026-03-12 00:26:35');
INSERT INTO `singers` VALUES (39, '泠鸢yousa', 'singer/f2c109b6-0eba-40e3-aef6-5a1b02af1483.jpg', '泠鸢yousa，女，生日5月19日，居于成都，脱胎于三次元真人的虚拟艺人，中国本土原创最具人气的虚拟偶像之一。品种不详的一只鸟，人类语言的发音掌握得不太好，但非常喜欢与人说话，也经常怀疑自己就是人。', 0, '2026-03-12 00:28:18', '2026-03-12 00:28:18');
INSERT INTO `singers` VALUES (40, '钱润玉Runyu', 'singer/8b60d054-b31b-4640-bff2-8c8e6dcc7a3b.jpg', '钱润玉，1998年04月26日出生于北京市，中国内地新生代原创音乐人。毕业于中国音乐学院附中主修琵琶，曾获中国音乐小金钟奖，后以吉他为主乐器入学伯克利，主修电子音乐制作与音色设计专业。在校期间，两首歌录入伯克利年度专辑，同时拿到6万美金伯克利奖学金，音乐作品在全网拥有近2000万播放量。', 0, '2026-03-12 00:30:01', '2026-03-12 00:30:01');
INSERT INTO `singers` VALUES (41, '苏星婕', 'singer/43a61c24-eba7-41f3-9a3c-15bc5c22b1b0.jpg', '苏星婕，中国内地女歌手，现为莫非音乐旗下艺人。2021年1月与王忻辰合作单曲《清空》，该曲于同年12月获第三届TMEA腾讯音乐娱乐盛典年度十大热歌奖。', 0, '2026-03-12 00:31:38', '2026-03-12 00:31:38');
INSERT INTO `singers` VALUES (42, '王俊凯', 'singer/cb0505e6-9597-4266-a959-72eeaa0d64c4.jpg', '王俊凯，1999年9月21日出生于重庆市，中国内地影视男演员、流行乐歌手，男子演唱组合TFBOYS队长，毕业于北京电影学院表演系本科班。', 0, '2026-03-12 00:33:19', '2026-03-12 00:33:19');
INSERT INTO `singers` VALUES (43, '夏婉安', 'singer/54e1dd48-10ca-480d-b218-c2fff63cde4d.jpg', '夏婉安，中国华语女歌手，集词曲唱于一身的音乐人，代表作《一个人》《越爱越难过》《忘川》《泡沫》《后来》《别，爱》等。', 0, '2026-03-12 00:35:04', '2026-03-12 00:35:04');
INSERT INTO `singers` VALUES (44, '向井太一', 'singer/42f5ff83-e2eb-437d-9113-1a7d4e7cfd63.jpg', '向井太一（むかい たいち，MUKAI TAICHI），1992年3月13日出生于日本福冈县，日本男歌手、词曲作者，所属经纪公司为Toy’s Factory/MIYA TERRACE，代表作品包括《POOL》《SLOW DOWN》《リセット》。', 0, '2026-03-12 00:39:06', '2026-03-12 00:39:06');
INSERT INTO `singers` VALUES (45, '司南', 'singer/775c322e-db64-44d0-b0ce-e1b7407f2ed5.jpg', '司南，00后创作歌手，靠着极具辨识度的声线，空灵治愈又有力量，以及流行、民谣、古风等多变的风格，从最初音乐平台翻唱时期就迅速收获了无数听众的喜爱。如今，这个00后女孩也拥有了超亿次播放量及千万收藏的金曲，以及超百万的音乐平台歌迷朋友。 代表作《冬眠》《春三月》《吹灭小山河》翻唱代表作《烟雨行舟》《星河万里》。', 0, '2026-03-14 20:13:42', '2026-03-14 20:13:42');
INSERT INTO `singers` VALUES (46, '王铮亮', 'singer/cf1d215a-6b8a-4929-a9ee-3e75e555ec88.jpg', '王铮亮，1977年11月30日出生于四川省成都市，毕业于四川音乐学院，中国内地男歌手、音乐制作人、四川音乐学院通俗音乐学院副教授。 2007年，参加湖南卫视选秀节目《快乐男声》，获得成都赛区四强、全国总决赛第十名的成绩，赛后发行首支个人单曲《肩上的翅膀》，从而正式出道。', 0, '2026-03-14 20:33:36', '2026-03-14 20:33:36');

-- ----------------------------
-- Table structure for track_tags
-- ----------------------------
DROP TABLE IF EXISTS `track_tags`;
CREATE TABLE `track_tags`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `track_id` bigint NOT NULL,
  `category_id` bigint NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_track_tag`(`track_id` ASC, `category_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of track_tags
-- ----------------------------

-- ----------------------------
-- Table structure for tracks
-- ----------------------------
DROP TABLE IF EXISTS `tracks`;
CREATE TABLE `tracks`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `artist` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `album` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `duration` int NULL DEFAULT 0,
  `bitrate` int NULL DEFAULT 0,
  `mime` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `minio_key` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cover_key` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cover_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `file_size` bigint NULL DEFAULT 0,
  `lyrics` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `lyric_key` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'MinIO 歌词文件 key',
  `artist_id` bigint NULL DEFAULT NULL COMMENT '关联歌手ID',
  `play_count` bigint NOT NULL DEFAULT 0,
  `like_count` bigint NOT NULL DEFAULT 0,
  `status` tinyint NOT NULL DEFAULT 0,
  `uploader_id` bigint NOT NULL,
  `category_id` bigint NULL DEFAULT NULL,
  `deleted` tinyint NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_title`(`title` ASC) USING BTREE,
  INDEX `idx_artist`(`artist` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_uploader`(`uploader_id` ASC) USING BTREE,
  INDEX `idx_play_count`(`play_count` ASC) USING BTREE,
  INDEX `idx_artist_id`(`artist_id` ASC) USING BTREE,
  INDEX `fk_tracks_category`(`category_id` ASC) USING BTREE,
  FULLTEXT INDEX `ft_title_artist`(`title`, `artist`),
  CONSTRAINT `fk_tracks_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_tracks_uploader` FOREIGN KEY (`uploader_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 94 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of tracks
-- ----------------------------
INSERT INTO `tracks` VALUES (3, 'secret base ~君がくれたもの', '花君', '花', 350, 0, 'audio/flac', 'music/73913142-3164-4e7e-9c38-a02b5f83950d.flac', 'cover/386c8eac-3d40-4bcd-b513-37416306bc84.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/386c8eac-3d40-4bcd-b513-37416306bc84.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260307%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260307T162357Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=cba1305720348066da28102263a3e78eff03a2698707713451731ce81924a70d', 69248081, '1', NULL, NULL, 23, 2, 1, 14, 1, 1, '2026-03-08 00:23:57', '2026-03-11 20:25:28');
INSERT INTO `tracks` VALUES (25, 'Rubia', '周深', '星', 286, 0, 'audio/flac', 'music/f7883cc2-8e0d-49d0-b5ce-d0f07be0882d.flac', 'cover/64b5b168-12c6-4823-a280-0bad7ebbd977.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/64b5b168-12c6-4823-a280-0bad7ebbd977.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260308%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260308T065248Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=4806cf71afb1d3cd300e69d3f5e341e16703eda5233cc1e6f9db7421bb1c254b', 38585275, '滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴滴地对地导弹', NULL, NULL, 19, 1, 1, 14, 3, 1, '2026-03-08 14:52:49', '2026-03-11 20:25:27');
INSERT INTO `tracks` VALUES (26, ' やわらかな光', 'やまだ豊', ' やわらかな光', 363, 0, 'audio/mpeg', 'music/11b559cc-94cb-4eee-9aa5-62b7dc82c786.mp3', 'cover/b9297e03-94d3-4c27-9839-9a994d7ef088.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/b9297e03-94d3-4c27-9839-9a994d7ef088.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260309%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260309T103236Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=d3f8d7c9cfcb49ba3ab7ac6c4532e982e52d65b87a9ca5f875e31734a35015fc', 14840336, '柔和之光', NULL, NULL, 15, 1, 1, 14, 5, 1, '2026-03-09 18:32:37', '2026-03-11 20:25:25');
INSERT INTO `tracks` VALUES (27, '勾指起誓（翻自 ilem）', '泠鸢yousa', '勾指起誓', 184, 0, 'audio/mpeg', 'music/f9170e49-6d4b-44d4-947c-ccdeda204e07.mp3', 'cover/7eaf549d-82f5-4e12-aaa1-39b3326ec070.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/7eaf549d-82f5-4e12-aaa1-39b3326ec070.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260309%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260309T103450Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=feb83c933d7e60940ebc2319fcbd49ff168ca868da917d761b855c1121b3dd7b', 7753977, '作词: ilem\r\n作曲: ilem\r\n编曲: ilem\r\n编曲：ilem\r\n洛天依调校：ilem\r\nP V：PinoEliza(明暗像素)\r\n原唱：洛天依\r\n翻唱：泠鸢yousa\r\n你是信的开头诗的内容\r\n童话的结尾\r\n你是理所当然的奇迹\r\n你是月色真美\r\n你是圣诞老人送给我\r\n好孩子的礼物\r\n你是三千美丽世界里\r\n我的一瓢水\r\n所以让我再靠近一点点\r\n因为你太温暖\r\n我会再变得坚强一点点\r\n因为你太柔软\r\n交换无名指金色的契约\r\n给彼此岁月\r\n说好从今以后都牵着手\r\n因为要走很远\r\n你是我万水千山的冒险\r\n要找的标记点\r\n你是我分割人生的线\r\n又将它们相连\r\n你是前世千次的回眸\r\n虔诚牵的手\r\n你是其余所有的一切\r\n是我的世界\r\n所以请你再闪亮一点点\r\n尽管我太平凡\r\n我会再变得柔软一点点\r\n因为你太敏感\r\n交换无名指金色的契约\r\n给彼此岁月\r\n说好从今以后都牵着手\r\n不管要走多远\r\n所以让我再靠近一点点\r\n因为你太温暖\r\n我会再变得坚强一点点\r\n因为你太柔软\r\n交换无名指金色的契约\r\n给彼此岁月\r\n说好从今以后都牵着手\r\n因为要走很远\r\n', NULL, NULL, 22, 2, 1, 14, 1, 1, '2026-03-09 18:34:51', '2026-03-11 20:25:24');
INSERT INTO `tracks` VALUES (28, '独角', 'UnicornPhantom', '独角', 182, 0, 'audio/mpeg', 'music/641641e8-2d89-4997-9c76-4fc94b79b5ec.mp3', 'cover/88a53545-ce39-4551-b7a1-dccc390f65ae.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/88a53545-ce39-4551-b7a1-dccc390f65ae.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260309%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260309T103615Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=8055ec5806bfedda0f7ba33382414820679c54fe945346f2b4ae719cc7c2ea64', 7769569, '纯音乐', NULL, NULL, 20, 1, 1, 14, 4, 1, '2026-03-09 18:36:15', '2026-03-11 20:25:23');
INSERT INTO `tracks` VALUES (29, '大喜', '泠鸢yousa、音阙诗听', '大喜', 0, 0, 'audio/flac', 'music/77ad0250-7367-4b3e-b317-cf5c0b98505a.flac', 'cover/d6d1cceb-df1c-40bf-805a-973054879e3b.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/d6d1cceb-df1c-40bf-805a-973054879e3b.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260309%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260309T103919Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=dd249c7fdaaeebb7cdedb282875af62e345ceec6deee6e1c6f37884441260c32', 39248376, '作词: 假寐\r\n作曲: 殇小谨\r\n编曲: 于瑾\r\n制作人: 殇小谨\r\n喜鹊叫闹\r\n来添红烛\r\n春风良宵\r\n碎玉铺路\r\n只此刻都心慌\r\n像是小鹿撞\r\n来人来客匆忙\r\n也快忘礼让\r\n我才攥住一颗喜糖\r\n分些喜气给红娘\r\n金钗摇\r\n摆摆摆摆~\r\n花轿摇\r\n摆摆摆摆~\r\n招摇\r\n摆摆摆摆~\r\n铃铛摇\r\n摆摆摆摆~\r\n一拜同心邀 山水迢迢\r\n二拜永结好 欢欢笑笑\r\n三拜共垂老 暮暮朝朝\r\n南来飞燕终归巢\r\n恰君子天骄 淑女窈窕\r\n有情相会七夕桥\r\n天官凡尘也落俗套\r\n赠红包\r\n许你我此生不辜负\r\n同甘~~~~\r\n共苦~~~~\r\n惜福~~~~\r\n许你我此生不辜负\r\n良辰~~~~\r\n共度~~~~\r\n无数~~~~\r\n只此刻都心慌\r\n像是小鹿撞\r\n来人来客匆忙\r\n也快忘礼让\r\n我才攥住一颗喜糖\r\n分些喜气给红娘\r\n金钗摇\r\n摆摆摆摆~\r\n花轿摇\r\n摆摆摆摆~\r\n招摇\r\n摆摆摆摆~\r\n铃铛摇\r\n摆摆摆摆~\r\n摆摆摆摆~\r\n摆摆摆摆~\r\n摆摆摆摆~\r\n摆摆摆摆~\r\n沾了粉黛\r\n张灯结彩\r\n看新人羞涩相对拜\r\n', NULL, NULL, 21, 2, 1, 14, 1, 1, '2026-03-09 18:39:19', '2026-03-11 20:25:21');
INSERT INTO `tracks` VALUES (30, '願い~あの頃のキミへ~', '當山みれい', '願い~あの頃のキミへ~', 227, 0, 'audio/mpeg', 'music/446ea4d1-f564-4954-baf2-aa2708e2dba9.MP3', 'cover/f50806ec-e84a-44fc-a4db-0961450d551e.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/f50806ec-e84a-44fc-a4db-0961450d551e.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260309%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260309T104150Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=76ef0713c171ec41d37d59c4711957ca3b009e38163f3d7e0e5887068fb35d69', 9081368, 'ふたりの思い出\r\n那段你我相恋的岁月\r\nかき集めたなら\r\n一点一滴凝聚脑海\r\nまた泣けてきちゃう\r\n泪流往心的方向\r\n寂しさ溢れて\r\n只剩寂寞与我\r\n最後の恋だと信じて願った\r\n曾经那么深信 能陪彼此走到最后\r\nあの日々にウソはなかった\r\n回望那时 我们都手捧着真心\r\n希望夢明るい未来\r\n希望 梦想 未来可盼\r\n東京に持った大きな期待\r\n对东京怀抱憧憬无限期待\r\nだけど現実は甘くなくて\r\n可现实永远无情冷笑着\r\n落ち葉見つめ深く思いつめてた\r\n目光滞于落叶 陷入忧郁沼泽\r\nそんな時にあなたと出会って\r\n就在那时你降临到我身边\r\nいつもあなたに助けられて\r\n从此总是受到你的关照\r\nバイトが楽しみになって\r\n爱上和你一起打工的分秒\r\n実はシフト被るように狙ってた\r\n其实我每次排班都挑你也在的时候\r\nスタンプ使いが妙に上手くて\r\n越来越会用表情包\r\nお化けも虫も受け付けなくて\r\n受不了鬼怪和虫子\r\nくしゃくしゃの笑顔が可愛くて\r\n笑到扭曲怎么都那么可爱\r\n眠れない夜は君のせいで\r\n难眠之夜怪你让我思恋\r\nこの気持ち今すぐに伝えたい\r\n这份心动好想现在告诉你\r\nけどバレたくない\r\n但又不想让你知道\r\nどうしたらいいの\r\n到底该怎么办啊\r\n迷ってるうちに\r\n辗转反侧时\r\n夜明けが来て\r\n夜已远走天光拂晓\r\n馬鹿みたいに後悔して\r\n开始傻傻的后悔\r\nふたりの想い出\r\n那段你我相恋的岁月\r\nかき集めたなら\r\n一点一滴凝聚脑海\r\nまた泣けてきちゃう\r\n泪像潮水袭来\r\n寂しさ溢れて\r\n只剩寂寞与我\r\n最後の恋だと信じて願った\r\n曾经那么深信 我们就是彼此的最后\r\nあの日々にウソはなかった\r\n回首那时 爱意不含半分虚假\r\n帰り道の公園で受けた告白\r\n在归途的公园接受了你的告白\r\nベタすぎるセリフ笑っちゃった\r\n老套过头的台词让我笑出声\r\n一生忘れられない思い出\r\n这陪我到记忆终点的回忆\r\nあなたがプレゼントしてくれた\r\n是你予我一生的礼物\r\n一日中ゲームやりこんで\r\n打一整天游戏\r\n夜ご飯は一緒に作って\r\n牵着手做晚饭\r\n贅沢なんてしなくたって\r\n不要金玉其外的物质\r\n２人いればそれだけでよくて\r\n你在我身边就是幸福本身\r\n口下手２人が本気で喧嘩\r\n不过脑的话让两人大吵了一架\r\nお互いブロック通じない電話\r\n互相拉黑不接对方电话\r\n本気でぶつかり合えることが\r\n而那时谁都没能先发觉\r\nどんな愛しいが気づけなかった\r\n躲藏在伤人话语背后的爱\r\nあなたが教えてくれたこと\r\n但那些你教会我的\r\nくれたもの\r\n给过我的\r\n胸に刻み過ごしてる今日も\r\n全部刻在心脏直到今天\r\nだから伝えたいありがとう\r\n所以这声谢谢 想讲给你听\r\nふたりの想い出\r\n那段你我相恋的岁月\r\nかき集めたなら\r\n一点一滴凝聚脑海\r\nまた泣けてきちゃう\r\n落泪断开线\r\n寂しさ溢れて\r\n只剩寂寞与我\r\n最後の恋だと信じて願った\r\n曾经那么深信 能陪彼此走到最后\r\nあの日々にウソはなかった\r\n回望那时 我们都手捧着真心\r\n子供のままでいられたなら\r\n如果能一直像个孩子\r\n何も怖がらず歩いて行けたかな\r\n是不是当初 可以无所顾虑地走下去\r\nもっと早く大人になっていたなら\r\n如果能再早点成为大人\r\n２人で乗り越えられたかな\r\n是不是 能执手 跨越当初\r\n今も君の夢夜空へ願う\r\n现在也做着你的梦 祈愿以夜空\r\n今でも君は\r\n愿你时至今日\r\nあの頃と同じ笑顔で\r\n得以笑如旧时\r\n今でも君は\r\n愿你时至今日\r\nあの頃のようにまっすぐで\r\n不减一腔热忱\r\n今でも君は\r\n愿你时至今日\r\nあの頃と変わらない優しさで\r\n满目温柔依然\r\n今でも君は\r\n愿你时至今日\r\n君のままでいてほしいそう願うよ\r\n随心做你自己 我真心愿你\r\nふたりの想い出\r\n那段你我相恋的岁月\r\nかき集めたなら\r\n一点一滴凝聚脑海\r\nまた泣けてきちゃう\r\n泪像潮水袭来\r\n寂しさ溢れて\r\n只剩寂寞与我\r\n最後の恋だと信じて願った\r\n曾经那么深信 我们就是彼此的最后\r\nあの日々にウソはなかった\r\n回首那时 爱意不含半分虚假\r\nふたりの想い出集めたら\r\n一点一点拼好两人的回忆\r\n泣き出しそうになる今夜も\r\n抵挡不住泪的海洋 今晚仍旧\r\n寂しさ溢れて苦しくなる\r\n寂寞 侵袭 心还会这么痛\r\n最後の恋と信じ願った\r\n曾经深信 能陪彼此走到最后\r\nあの日々に嘘はなかった\r\n回首那时 爱意不含半分虚假\r\n離れてもあなたの幸せ願う\r\n分开之后 也希望你继续幸福\r\nふたりの想い出集めたら\r\n一点一点拼好两人的回忆\r\n泣き出しそうになる今夜も\r\n抵挡不住泪的海洋 今晚仍旧\r\n寂しさ溢れて苦しくなる\r\n寂寞 侵袭 心还会这么痛\r\n最後の恋と信じ願った\r\n曾经深信 我们就是彼此的最后\r\nあの日々に嘘はなかった\r\n回望那时 我们都手捧着真心\r\n離れてもあなたの幸せ願う\r\n爱过所以 分开后也希望你幸福\r\n', NULL, NULL, 14, 1, 1, 14, NULL, 1, '2026-03-09 18:41:50', '2026-03-11 20:25:20');
INSERT INTO `tracks` VALUES (31, '夜に駆ける', 'YoASOBI', '夜に駆ける', 174, 0, 'audio/mpeg', 'music/5c72d32d-4aad-4e0d-9408-c123347a1fdc.MP3', 'cover/4dbf3e8e-3483-470c-8091-e9607dd40ef8.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/4dbf3e8e-3483-470c-8091-e9607dd40ef8.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260309%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260309T104320Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=48d3ff1e1b1d3a8ce2e17e3b59cf936b8d96d13ccbc3127626a1c77933fe4b68', 6963344, '沈むように溶けてゆくように\r\n像是沉溺溶化一般\r\n二人だけの空が広がる夜に\r\n在只有你我二人的广阔夜空之下\r\n「さよなら」だけだった\r\n你只留下了一句「再见了」\r\nその一言で全てが分かった\r\n但仅仅这一句话我就明白了一切\r\n日が沈み出した空と君の姿\r\n日落时分的天空与你的身影\r\nフェンス越しに重なっていた\r\n在围栏的外侧重叠在一起\r\n初めて会った日から\r\n从相遇的那天开始\r\n僕の心の全てを奪った\r\n我的内心全部都被你夺去\r\nどこか儚い空気を纏う君は\r\n缠绕着飘渺氤氲的你\r\n寂しい目をしてたんだ\r\n眼神却显得如此寂寞\r\nいつだってチックタックと\r\n在这时针不停转动的世界里\r\n鳴る世界で何度だってさ\r\n无论多少次\r\n触れる心無い言葉うるさい声に\r\n去触碰那残酷之言刺耳之声\r\n涙が零れそうでも\r\n都会泫然欲泣\r\nありきたりな喜びきっと二人なら見つけられる\r\n但若是两个人的话  一定能寻找到属于我们的平凡的喜悦\r\n騒がしい日々に笑えない君に\r\n为在喧嚣的日子里失去笑容的你\r\n思い付く限り眩しい明日を\r\n献上所能想象到的一切耀眼的明天\r\n明けない夜に落ちてゆく前に\r\n在坠入永不破晓的黑夜之前\r\n僕の手を掴んでほら\r\n来 抓住我的手吧\r\n忘れてしまいたくて閉じ込めた日々も\r\n即使是那些想要尽数忘却的封闭的日子\r\n抱きしめた温もりで溶かすから\r\n我也会用相拥时的温暖将其融化\r\n怖くないよいつか日が昇るまで\r\n没有什么害怕的哦 直到黎明再次降临\r\n二人でいよう\r\n两人紧紧相依吧\r\n君にしか見えない\r\n讨厌总是注视着\r\n何かを見つめる君が嫌いだ\r\n盯着别人看的你\r\n見惚れているかのような恋するような\r\n讨厌你那看得入迷一般\r\nそんな顔が嫌いだ\r\n坠入爱河一般的表情啊\r\n信じていたいけど信じれないこと\r\n虽然曾想要去相信却无法相信\r\nそんなのどうしたってきっと\r\n那种事情不论如何\r\nこれからだっていくつもあって\r\n今后定会重蹈覆辙\r\nそのたんび怒って泣いていくの\r\n那时一定会生气地哭出来吧\r\nそれでもきっといつかはきっと僕らはきっと\r\n即便如此我仍然相信着  终有一天我们一定能够\r\n分かり合えるさ信じてるよ\r\n心意相通\r\nもう嫌だって疲れたんだって\r\n你说着「已经受够了啊」「已经疲惫了啊」\r\nがむしゃらに差し伸べた僕の手を振り払う君\r\n将我不顾一切向你伸出的手甩开\r\nもう嫌だって疲れたよなんて\r\n「已经受够了啊」「已经疲惫了啊」\r\n本当は僕も言いたいんだ\r\n其实我也想这样说啊\r\nほらまたチックタックと\r\n看啊  在这时针仍然不停转动的世界里\r\n鳴る世界で何度だってさ\r\n无论多少次\r\n君の為に用意した言葉どれも届かない\r\n为了你而准备的话语一句都不能传达给你\r\n「終わりにしたい」だなんてさ\r\n「想要结束了啊」\r\n釣られて言葉にした時\r\n当我不由说出这句话的时候\r\n君は初めて笑った\r\n你第一次绽放了笑容\r\n騒がしい日々に笑えなくなっていた\r\n在喧嚣的日子里失去笑容的你\r\n僕の目に映る君は綺麗だ\r\n在我的眼中却无比动人\r\n明けない夜に溢(こぼ)れた涙も\r\n于永不破晓的黑夜里夺眶而出的眼泪\r\n君の笑顔に溶けていく\r\n也会因为你的笑容而消散\r\n変わらない日々に泣いていた僕を\r\n对于这样一成不变的日子里哭泣的我\r\n君は優しく終わりへと誘う\r\n你温柔地指引向终结\r\n沈むように溶けてゆくように\r\n像是沉溺溶化一般\r\n染み付いた霧が晴れる\r\n染上的氤氲终于散开\r\n忘れてしまいたくて閉じ込めた日々に\r\n在想要尽数忘却的封闭的日子中\r\n差し伸べてくれた君の手を取る\r\n紧握住你向我伸出的双手\r\n涼しい風が空を泳ぐように今吹き抜けていく\r\n凉爽的风如同泳于夜空一般吹拂而过\r\n繋いだ手を離さないでよ\r\n不要松开紧紧牵住的双手哦\r\n二人今、夜に駆け出していく\r\n两人现在，向夜晚飞奔而去\r\n', NULL, NULL, 23, 1, 1, 14, 9, 1, '2026-03-09 18:43:20', '2026-03-11 20:25:19');
INSERT INTO `tracks` VALUES (32, '打上花火', '米津玄師', '烟花', 290, 0, 'audio/mpeg', 'music/36a42d1a-970d-4d85-a637-d45b71d64bdf.mp3', 'cover/683b33fc-1db2-4aed-833e-ddbd55670a83.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/683b33fc-1db2-4aed-833e-ddbd55670a83.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T130332Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=766d88429e3f3ccb0ba01f24b4284473f766612c5c1538166c23628e7efb1902', 11646465, '{\"t\":0,\"c\":[{\"tx\":\"作词: \"},{\"tx\":\"米津玄師\",\"li\":\"http://p1.music.126.net/z94au0B70eCV7GGJTmKc8w==/109951172132874686.jpg\",\"or\":\"orpheus://nm/artist/home?id=159300&type=artist\"}]}\n{\"t\":1000,\"c\":[{\"tx\":\"作曲: \"},{\"tx\":\"米津玄師\",\"li\":\"http://p1.music.126.net/z94au0B70eCV7GGJTmKc8w==/109951172132874686.jpg\",\"or\":\"orpheus://nm/artist/home?id=159300&type=artist\"}]}\n{\"t\":2000,\"c\":[{\"tx\":\"编曲: \"},{\"tx\":\"米津玄師\",\"li\":\"http://p1.music.126.net/z94au0B70eCV7GGJTmKc8w==/109951172132874686.jpg\",\"or\":\"orpheus://nm/artist/home?id=159300&type=artist\"},{\"tx\":\"/\"},{\"tx\":\"田中隼人\",\"li\":\"http://p1.music.126.net/-nFi76W-JFwqPoS6LDvVaA==/109951169424503812.jpg\",\"or\":\"orpheus://nm/artist/home?id=30346855&type=artist\"}]}\n[00:19.64]あの日見渡した渚を\n[00:24.50]今も思い出すんだ\n[00:29.50]砂の上に刻んだ言葉\n[00:34.60]君の後ろ姿\n[00:39.64]寄り返す波が\n[00:42.86]足元をよぎり何かを攫う\n[00:49.58]夕凪のなが\n[00:53.00]日暮れだけが通り過ぎて行く\n[00:59.33]パッと光って咲いた\n[01:02.30]花火を見ていた\n[01:04.54]きっとまだ 終わらない夏が\n[01:09.56]曖昧な心を 解かして繋いだ\n[01:14.50]この夜が 続いて欲しかった\n[01:19.86]\n[01:30.10]「あと何度君と同じ花火を\n[01:32.95]見られるかな」って\n[01:34.62]笑う顔に何ができるだろうか\n[01:39.89]傷つくこと 喜ぶこと\n[01:42.47]繰り返す波と情動\n[01:44.70]焦燥 最終列車の音\n[01:50.19]何度でも 言葉にして君を呼ぶよ\n[01:54.71]波間を選び もう一度...\n[02:00.26]もう二度と悲しまずに済むように\n[02:08.74]\n[02:17.17]はっと息を飲めば\n[02:19.43]消えちゃいそうな光が\n[02:22.10]きっとまだ 胸に住んでいた\n[02:27.30]手を伸ばせば触れた\n[02:29.47]あったかい未来は\n[02:31.99]ひそかに二人を見ていた\n[02:38.12]パッと花火が（パッと花火が）\n[02:40.56]夜に咲いた（夜に咲いた）\n[02:43.11]夜に咲いて（夜に咲いて）\n[02:45.62]静かに消えた（静かに消えた）\n[02:48.15]離さないで（離れないで）\n[02:50.70]もう少しだけ（もう少しだけ）\n[02:53.18]もう少しだけ\n[02:54.48]このままで\n[02:57.45]\n[03:07.18]あの日見渡した渚を\n[03:11.99]今も思い出すんだ\n[03:17.40]砂の上に刻んだ言葉\n[03:21.98]君の後ろ姿\n[03:27.15]パッと光って咲いた\n[03:29.43]花火を見ていた\n[03:32.27]きっとまだ 終わらない夏が\n[03:37.30]曖昧な心を 解かして繋いだ\n[03:41.94]この夜が 続いて欲しかった\n', 'lyrics/504df00c-9917-426f-b2f1-4a0e0f503836.lrc', 3, 10, 2, 1, 14, 9, 0, '2026-03-11 21:03:32', '2026-03-14 21:43:17');
INSERT INTO `tracks` VALUES (33, '独角', 'UnicornPhantom', NULL, 182, 0, 'audio/mpeg', 'music/9940da6e-7e74-476d-9945-2cb73a093abd.mp3', NULL, NULL, 7769569, NULL, NULL, 25, 0, 0, 1, 14, 10, 1, '2026-03-11 21:51:05', '2026-03-11 22:02:53');
INSERT INTO `tracks` VALUES (34, 'アイロニ', '4円', NULL, 251, 0, 'audio/flac', 'music/42d94a93-455b-4237-bdba-7a564d6377cf.flac', 'cover/3b0813f8-126a-40d7-a44c-894e137a4988.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/3b0813f8-126a-40d7-a44c-894e137a4988.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T135230Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=900d174c19bfb49873506e1cbef9a2ca28d51d2ef87968e1d7321ac40a25510e', 94456669, '作词: すこっぷ\r\n作曲: すこっぷ\r\n少し歩き疲れたんだ\r\n有点走累了\r\n少し歩き疲れたんだ\r\n有点走累了\r\n月並みな表現(ひょうげん)だけど\r\n虽然平庸的表达\r\n人生(じんせい)とかいう長い道を\r\n来形容人生漫长的道路\r\n少し休みたいんだ\r\n想稍稍休息下呢\r\n少し休みたいんだけど\r\n虽然想稍稍休息一下\r\n時間は刻一刻(こくいっこく)残酷と\r\n可是时间每时每刻都这样残酷\r\n私を    引っぱっていくんだ\r\n将我    紧拖着前行\r\nYeah——\r\nYeah——Yeah——\r\nうまくいきそうなんだけど\r\n虽然看似顺利地进行着\r\nうまくいかないことばかりで\r\n但其实全是不顺利的事\r\n迂闊(うかつ)にも泣いてしまいそうになる\r\n因此一塌糊涂地哭起来\r\n情(なさ)けない本当にな\r\n真是丟人呢\r\n惨(みじ)めな気持なんか\r\n这样悲惨的感受\r\n嫌というほど味わってきたし\r\n已经不想再次体验到了\r\nとっくに悔しさなんてものは\r\n明明应该将悔恨之类的\r\n捨ててきたはずなのに\r\n早早丢掉\r\n絶望抱くほど  悪いわけじゃないけど\r\n虽然也不是感到绝望般    那样差劲\r\n欲しいものは  いつも少し手には届かない\r\n但是想要的东西    却永远得不到手\r\nそんな半端(はんぱ)だとね\r\n对这样没用的家伙\r\nなんか期待してしまうから\r\n为何会有所期待呢\r\nそれならもういっそのこと\r\n既然如此不如干脆\r\nドン底まで突き落としてよ\r\n就将它推入谷底吧\r\n答えなんて言われたって\r\n即使要说出些什么答案\r\n人によってすり替(か)わってって\r\n因人不同也会有所改变\r\nだから絶対(ぜったい)なんて絶対\r\n所以绝对之类的绝对\r\n信じらんないよ  ねぇ\r\n是不能相信的    对吧\r\n苦しみって誰にもあるって\r\n谁都会有苦楚\r\nそんなのわかってるから何だって\r\n说着那些什么都明白\r\nなら笑って済ませばいいの？\r\n那就笑着应对过去就好了吧？\r\nもうわかんないよ　バカ！\r\n我不知道该怎么办啦    笨蛋！\r\n散々言われてきたくせに\r\n明明是被狠狠说了一番\r\nなんだ  まんざらでもないんだ\r\n但却未必就是这样\r\n簡単に考えたら楽なことも\r\n将简单思考起来很容易的事\r\n難関(なんかん)に考えてたんだ\r\n也当做难题考虑了\r\n段々(だんだん)と色々めんどくなって\r\n种种事都越发麻烦\r\nもう淡々と終わらせちゃおうか\r\n让一切都淡泊结束吧\r\n「病んだ？」とかもう  嫌になったから\r\n「病了吗？」之类的已经受够了\r\nやんわりと終わればもういいじゃんか\r\n能温和地结束不就好了吗\r\n夢だとか希望だとか  生きてる意味とか\r\n梦也好希望也好    亦或是生存意义\r\n別にそんなものはさして  必要ないから\r\n那些东西也并不是    没有必要存在\r\n具体的(ぐたいてき)でわかりやすい\r\n请给我具体易懂的\r\n機会(きかい)をください\r\n这样的机会啊\r\n泣き場所探すうちに\r\n在寻找哭泣的地方时\r\nもう泣き疲れちゃったよ\r\n就已经哭累了啊\r\nきれいごとって嫌い  だって\r\n讨厌华而不实的话\r\n期待しちゃっても形になんなくて\r\n期待着却捉不到蛛丝马迹\r\n「星が僕ら見守って」って\r\n要说「星星守护着我们」\r\n夜しかいないじゃん　ねぇ\r\n那也就只有晚上    对吧\r\n君のその優しいとこ\r\n你的那份温柔\r\n不覚(ふかく)にも求めちゃうから\r\n我在不知不觉中寻求着\r\nこの心やらかいとこ\r\n这颗心的柔软\r\nもう触んないで  ヤダ！\r\n请别再触碰了   不要了啊！\r\nもうほっといて\r\n不要再管我了啊\r\nもう置いてって\r\n就这样丟下我吧\r\n汚れきったこの道は\r\n弄脏了的这条路\r\nもう変わんないよ嗚呼\r\n已无法改变了啊\r\n疲れちゃって弱気(よわき)になって\r\n因疲倦而变得懦弱了\r\n逃げ出したって無駄なんだって\r\n想要逃也是白费力气\r\nだから内面(ないめん)耳塞いで\r\n所以内心捂着耳朵\r\nもう最低(さいてい)だって泣いて\r\n已是最糟了而哭着\r\n人生って何なのって\r\n人生又是什么呢\r\nわかんなくても生きてるだけで\r\n只是不明不白地活着\r\n幸せって思えばいいの？\r\n认为这即是幸福就可以了吗？\r\nもうわかんないよ　バカ！\r\n我不明白了啊     笨蛋！\r\n', NULL, 10, 1, 1, 1, 14, 9, 0, '2026-03-11 21:52:31', '2026-03-12 01:19:43');
INSERT INTO `tracks` VALUES (35, '轻涟 La vaguelette', 'HOYO-MiX', NULL, 150, 0, 'audio/mpeg', 'music/c4af289f-e3ce-4ed9-b3d7-1038d7da5ffe.mp3', NULL, NULL, 6721381, NULL, 'lyrics/b1f7b8d4-a860-4bb1-81fe-c8205f9d948d.lrc', 26, 0, 0, 1, 14, 14, 1, '2026-03-11 21:54:13', '2026-03-11 22:00:32');
INSERT INTO `tracks` VALUES (36, '命に嫌われている', 'Sou', '', 278, 0, 'audio/mpeg', 'music/b70999b0-37c6-43a8-8757-2eabb55ce361.mp3', 'cover/aca6d016-0874-4da7-bdba-a83a369d9062.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/aca6d016-0874-4da7-bdba-a83a369d9062.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T135602Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=0a5c5f822be6bc9b5687f5cf7c1929abb2d6f6307ed2f848f5d17df05e579838', 11285653, '{\"t\":0,\"c\":[{\"tx\":\"作词: \"},{\"tx\":\"カンザキイオリ\"}]}\n{\"t\":1000,\"c\":[{\"tx\":\"作曲: \"},{\"tx\":\"カンザキイオリ\"}]}\n[00:20.31]「死にたいなんて言うなよ。\n[00:22.62]諦めないで生きろよ。」\n[00:24.77]そんな歌が正しいなんて 馬鹿げてるよな。\n[00:29.18]実際自分は死んでもよくて 周りが死んだら悲しくて\n[00:34.33]「それが嫌だから」っていう エゴなんです。\n[00:39.42]他人が生きてもどうでもよくて\n[00:41.77]誰かを嫌うこともファッションで\n[00:44.28]それでも「平和に生きよう」\n[00:46.08]なんて素敵なことでしょう。\n[00:49.03]画面の先では誰かが死んで\n[00:51.41]それを嘆いて誰かが歌って\n[00:53.81]それに感化された少年が\n[00:56.16]ナイフを持って走った。\n[00:57.99]僕らは命に嫌われている。\n[01:00.60]価値観もエゴも押し付けて いつも誰かを殺したい歌を\n[01:05.47]簡単に電波で流した。\n[01:07.54]僕らは命に嫌われている。\n[01:10.25]軽々しく死にたいだとか\n[01:12.55]軽々しく命を見てる僕らは命に嫌われている。\n[01:27.45]お金がないので今日も一日中惰眠を謳歌する\n[01:32.26]生きる意味なんて見出せず、無駄を自覚して息をする。\n[01:37.08]寂しいなんて言葉でこの傷が表せていいものか\n[01:41.78]そんな意地ばかり抱え今日も一人ベッドに眠る\n[01:46.55]少年だった僕たちはいつか青年に変わってく。\n[01:51.34]年老いていつか 枯れ葉のように 誰にも知られず朽ちていく。\n[01:56.14]不死身の身体を手に入れて、一生死なずに生きていく。\n[02:00.97]そんなSFを妄想してる\n[02:05.83]自分が死んでもどうでもよくて\n[02:08.18]それでも周りに生きて欲しくて\n[02:10.54]矛盾を抱えて生きてくなんて怒られてしまう。\n[02:15.50]「正しいものは正しくいなさい。」\n[02:17.77]「死にたくないなら生きていなさい。」\n[02:20.14]悲しくなるならそれでもいいなら\n[02:22.60]ずっと一人で笑えよ。\n[02:24.42]僕らは命に嫌われている。\n[02:27.17]幸福の意味すらわからず、産まれた環境ばかり憎んで\n[02:31.97]簡単に過去ばかり呪う。\n[02:34.07]僕らは命に嫌われている。\n[02:36.69]さよならばかりが好きすぎて 本当の別れなど知らない僕らは命に嫌われている。\n[02:53.52]幸福も別れも愛情も友情も\n[02:58.19]滑稽な夢の戯れで全部カネで買える代物。\n[03:03.32]明日死んでしまうかもしれない。\n[03:05.53]すべて無駄になるかもしれない。\n[03:08.11]朝も夜も春も秋も\n[03:10.42]変わらず誰かがどこかで死ぬ。\n[03:12.67]夢も明日も何もいらない。\n[03:15.26]君が生きていたならそれでいい。\n[03:17.55]そうだ。本当はそういうことが歌いたい。\n[03:22.62]命に嫌われている。\n[03:24.83]結局いつかは死んでいく。\n[03:27.13]君だって僕だっていつかは枯れ葉にように朽ちてく。\n[03:31.63]それでも僕らは必死に生きて\n[03:33.98]命を必死に抱えて生きて\n[03:36.57]殺してあがいて笑って抱えて\n[03:39.00]生きて、生きて、生きて、生きて、生きろ。\n', 'lyrics/afd92dec-9583-42c4-a76a-bb3e71e84c2c.lrc', 11, 0, 0, 1, 14, 9, 0, '2026-03-11 21:56:02', '2026-03-11 21:56:02');
INSERT INTO `tracks` VALUES (37, 'Sou,いすぼくろ - 命ばっかり', 'Sou', NULL, 253, 0, 'audio/mpeg', 'music/f93f7b46-be62-494d-9037-07f0d4ff9ed6.mp3', 'cover/75d2b20c-d2a7-4e66-a57a-f5894d52bfcd.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/75d2b20c-d2a7-4e66-a57a-f5894d52bfcd.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T135707Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=bf47f0f524a692a5ac2828e8542abf52456eed8f75eece904a1845befbc5a784', 10312739, '作词: ぬゆり\r\n作曲: ぬゆり\r\n日々を磨り潰していく貴方との時間は\r\n一天一天消磨 与你的时光\r\n簡単なことじゃ許せないくらいに\r\n若耗在简单的事上 便无法原谅\r\nおかしくなってしまった 安心したいだけの\r\n彻底变得奇怪了 只为求心安的\r\n口先だけじゃ いや\r\n嘴上敷衍 就不必了\r\nどこまでも単純だ ここまでと悟った\r\n到哪都是单纯的 明白就到此为止了\r\n座り込んでもう歩けなくなる\r\n深坐原地便再也走不动\r\n最初だけじゃないなら 際限もないならば\r\n如果不只是一开始 又如果也没有终点\r\nどこへだって行けるはずさ\r\n便应该是哪都能去的啊\r\n遠くへ 遠くへ 水の味を覚え\r\n往远方去 往远方去 记住水的味道吧\r\n街路に目が眩み夜を越えてしまう\r\n街道上目眩着跨过黑夜\r\n遠くへ 遠くへ 動けない僕のことを忘れて\r\n往远方去 往远方去 忘记动弹不得的我吧\r\n知らないを知りたかった\r\n想知道不知道的事\r\n知り得ることはなかった\r\n却无法得知\r\n水圧で動けなくなっていく また蝶の夢を見る\r\n因水压而逐渐动弹不得 又做了个成蝶的梦\r\n好きになりたかったんだ 好きになれなかったんだ\r\n曾经想喜欢 却没有办法\r\n「正しい」を理想としていたら\r\n若将「正确」视为理想\r\n置いて行かれた\r\n便会被丢下\r\n追いつけなくなったんだ\r\n再也追不上\r\n当たり前に過ぎていくはずだった時間は\r\n应该理所当然 流逝的时间\r\n何十年とも感じるほど長く\r\n感觉起来 却有数十年那般长\r\n眠りすぎた頭痛で這い出してきた僕は\r\n睡太久而头痛 匍匐而出的我\r\nどこにももう行けやしないから\r\n已经是哪也去不了\r\nどこまでも純情だ それでしかなかった\r\n到哪都是纯真的 除此之外一无所有\r\n飾らないで 分かち合いたいから\r\n别掩饰了 我想与你分享\r\n貴方の影が眩む 見失ってしまった\r\n为你的影子目眩 看丢了它\r\nまた眠れない夜になっていく\r\n睡不着的夜晚再次来访\r\n「どうしたいの」なんて問えば「どうもしない」なんて返す\r\n若问「你想做什么」 便回答「没想做什么」\r\n貴方はもう何も教えてくれないの\r\n你已经不会告诉我任何事了\r\n今日食べた食事も 行きたい場所さえもう\r\n今天吃了什么 想去哪里这些事\r\n何にも どれをとってもわからないだけだ\r\n连无论 该问哪一个 都不知道了\r\n遠くへ 遠くへ 水の味を覚え\r\n往远方去 往远方去 记住水的味道吧\r\n街路に目が眩み夜を越えてしまう\r\n街道上目眩着跨过黑夜\r\n遠くへ 遠くへ 動けない僕のことを忘れて\r\n往远方去 往远方去 忘记动弹不得的我吧\r\n貴方の横顔を見て引け目を感じてしまった\r\n望着你的侧脸 我便感到自卑\r\n救われたいとだけ喚く僕はきっともう我楽多だ\r\n只能喊着想被拯救的我 一定已经是垃圾了\r\n思想犯はもう止めた\r\n不再当思想犯了\r\n「分かれない」を悟っていた\r\n领悟到「分不开的」\r\nとりとめのない言葉だけでは\r\n只用不得要领的话语\r\n薄紙を剥がせない\r\n是撕不下那张薄纸的\r\n普通に固執することが\r\n普通地固守己见\r\n怖くてもう泣きそうだ\r\n也太过害怕就要哭出来\r\n自堕落を鏡で見ていたら\r\n看着镜子里的堕落自我\r\n薄っぺらだ\r\n便见浅薄一片的\r\n薄っぺらな僕だった\r\n浅薄一片的我啊\r\nぼくだ\r\n的我啊\r\n僕だけだったんだ\r\n一直都只有我啊\r\n', NULL, 11, 3, 0, 1, 14, 9, 0, '2026-03-11 21:57:08', '2026-03-14 21:32:06');
INSERT INTO `tracks` VALUES (38, 'ハレハレヤ（翻自 Flower）', 'Sou', NULL, 208, 0, 'audio/mpeg', 'music/0d3db89e-1880-471b-8728-cfb49c4c7955.mp3', 'cover/f5e13702-4c07-4e95-8dde-5e75675ff07d.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/f5e13702-4c07-4e95-8dde-5e75675ff07d.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T135830Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=d9c34a38bed14915e44c5ed3f5714f16ef6f1d796c14051f35de457d855b1182', 8900670, '作词: 羽生迷子\r\n作曲: 羽生迷子\r\n夜の街迷いし穢れの乱歩\r\n夜间街上 踌躇不定 不净地游走\r\n何処から来たのよ見窄らしいね\r\n你从哪里来 为何衣衫褴褛\r\nねぇうちにおいで温めてあげるよ\r\n呐 去我家吧 我家暖和\r\n今までよく頑張ったよね\r\n坚持到现在真不容易\r\nここらで休んでみませんか\r\n就在这里稍事休息吧\r\nゆっくり話をしませんか\r\n不慌不忙地聊几句吧\r\nとりあえず今夜は安心さ\r\n今晚姑且算是有了着落\r\n足跡は雪が消していた\r\n雪把足迹掩埋在纯白中\r\n声はひどく痛んだ\r\n说话声中饱含沧桑\r\n乾いた乾いた\r\n干渴难耐 干渴难耐\r\n遠くの狐がこんこんと\r\n远方传来清脆的狐鸣\r\n僕たちを探しているようだ\r\n狐狸也许是在寻找我们吧\r\nそっと息を潜めた\r\n悄悄地屏住呼吸\r\nこのままこのまま行こう\r\n如此这般 如此这般 走下去吧\r\n凍てつく雪の中で\r\n凝冻如石的雪地中\r\n確かな熱を帯びた\r\n含着一股真切的温热\r\n呼吸をして声を焼いて\r\n呼吸交错 舌敝唇焦\r\n燃えた燃えた禊の火\r\n燃起了燃起了 净罪之火\r\nさぁ縁の垣根を超えて\r\n来吧 跨过因缘的篱墙\r\n貴方をもっと知りたい\r\n让我更加坦诚地了解你\r\n言えないまま言えないまま\r\n欲言又止欲言又止\r\nいつの間にか雪は雨になりました\r\n不觉间积雪 化作了雨露\r\n夜明け前貴方は早々と\r\n你趁着黎明还未到来\r\n此処から出て行ってしまった\r\n匆忙地离开了我的家\r\nあんなに泣いていたのに\r\n任由泪水淌下\r\n溢れた溢れた\r\n泪如雨下 泪如雨下\r\n今までありがとさんなんて\r\n说什么感谢我照顾你那么久\r\n言わないでよ置いてかないで\r\n不必说啊不要走啊\r\nきっと帰れやしない\r\n恐怕是不会回来了\r\nこのままこのまま\r\n如此这般 如此这般\r\nいつか夢で会えても\r\n以后我在梦里遇到你时\r\n貴方にゃきっと届かない\r\n也无法和你分享我的梦\r\n僕は此処で僕は此処で\r\n我就在这里我就在这里\r\n袖を濡らしながら帰りを待つだけ\r\n以袖掩面 袖口沾湿 静待你归来\r\nさぁ宴のたけなわ超えて\r\n来吧 渡过酒宴的酣醉\r\n生きてみようか 今更\r\n让我试着活下去 事到如今\r\n禊ぎの火は禊の火は\r\n净罪之火 净罪之火\r\n雨に雨に濡れていた\r\n雨露润泽 将它熄灭\r\n晴れた晴れた朝ぼらけ\r\n烟雾消散在拂晓的晴空\r\n見てるかな\r\n你能看到吧\r\n', NULL, 11, 1, 0, 1, 14, 9, 0, '2026-03-11 21:58:31', '2026-03-11 22:10:18');
INSERT INTO `tracks` VALUES (39, '心做し', 'Sou', NULL, 273, 0, 'audio/mpeg', 'music/b56d1108-5840-4cba-aa7b-330ad0db7855.mp3', 'cover/2b7cb986-cbbf-4a64-9fc3-fa52097db58e.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/2b7cb986-cbbf-4a64-9fc3-fa52097db58e.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T135929Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=c73cf353a8c641307c8378dfbfe274538302e9051f94cd2edeb3c7850cfc5314', 11466889, 'ねぇ、もしも 全て投（な）げ捨て られたら\r\n呐，若然能将一切舍弃的话\r\n笑って 生きる ことが楽（らく）に なるの？\r\n笑着活下去这样的事就会变的轻松吗？\r\nまた胸が 痛くなるから\r\n胸口又再疼痛起来呢\r\nもう何も 言わないでよ\r\n够了什么都不要说了啊\r\nねぇ、もしも 全て忘れ られたなら\r\n呐，若然一切都能尽数忘却的话\r\n泣かないで 生きることも 楽になるの？\r\n不再哭泣而活下去这事亦会变得轻松吗？\r\nでも そんな事 出来ない から\r\n然而那般的事是不可能的呢\r\nもう何も 見せないでよ\r\n够了什么都不要再给我看啊\r\n君に どれだけ 近（ちか）づ いても\r\n就算怎么接近你\r\n僕の心臓（しんぞう）は 一つ だけ\r\n我的心脏亦是仅此唯一的\r\n酷（ひど）いよ 酷（ひど）いよ、もういっそ僕の体を\r\n太残酷了　太残酷了\r\n壊（こわ）して 引（ひ）き裂（さ）いて 好きなよう にしてよ\r\n干脆将我的身体 破坏吧　撕裂吧  随你喜欢地处置吧\r\n叫（さけ）んで 藻掻（もが）いて 瞼を 腫（は）らしても\r\n不论怎样呼叫　怎样挣扎  怎样哭得双眼红肿也好\r\nまだ君は 僕の事を 抱（だ）きしめ て離さない\r\n你还是紧抱着我永不分离\r\nもういいよ\r\n已经够了啊\r\nねぇ、もしも 僕の願いが 叶（かな）うなら\r\n呐，若然我的愿望能得以实现的话\r\n君と 同じもの が欲しいんだ\r\n我想要得到与你相同的事物呢\r\nでも僕には 存在しないから\r\n但因为对我而言那般的喜欢并不存在\r\nじゃあ せめて 此処（ここ）に来てよ\r\n所以啊至少希望你到来这里啊\r\n君に どれだけ 愛され ても\r\n就算有多被你所爱\r\n僕の心臓（しんぞう）は 一つだけ\r\n我的心脏亦是仅此唯一的\r\nやめてよ やめてよ、優（やさ）しく しないでよ\r\n住手吧　住手吧\r\nどうしても 僕には理解（りかい）が できないよ\r\n不要对我那么温柔啊 不论怎样我亦无法理解啊\r\n痛いよ 痛いよ、言葉で 教えてよ\r\n好痛啊　好痛啊  用言语告诉我吧\r\nこんなの 知らないよ 独りに しないで\r\n这样的事我不懂啊 不要让我独自一人\r\n酷（ひど）いよ 酷（ひど）いよ、もういっそ僕の体を\r\n太残酷了　太残酷了  干脆将我的身体\r\n壊（こわ）して 引（ひ）き裂（さ）いて 好きなよう にしてよ\r\n破坏吧　撕裂吧  随你喜欢地处置吧\r\n叫（さけ）んで 藻掻（もが）いて 瞼を 腫（は）らしても\r\n不论怎样呼叫　怎样挣扎  怎样哭得双眼红肿也好\r\nまだ君は 僕の事を 抱（だ）きしめ て離さない\r\n你还是紧抱着我永不分离\r\nもういいよ\r\n已经够了啊\r\nねぇ、もしも 僕に 心がある なら\r\n呐，若然我拥有心的话\r\nどうやって それを 見つければ いいの？\r\n那我该怎样去寻找那物才好呢？\r\n少し 微笑んで 君が言う\r\n稍作微笑的你言道\r\n「それはね、ここにあるよ」\r\n「那个呢，就在这里啊」\r\n', NULL, 11, 7, 0, 1, 14, 9, 0, '2026-03-11 21:59:30', '2026-03-14 21:50:52');
INSERT INTO `tracks` VALUES (40, '轻涟 La vaguelette', 'HOYO-MiX', NULL, 150, 0, 'audio/mpeg', 'music/45e1fb11-574c-466d-8844-fdd428b66e98.mp3', 'cover/2b758483-d293-4295-a038-a3d127c00fb2.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/2b758483-d293-4295-a038-a3d127c00fb2.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T140121Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=2bbca5a0821e1c0cb81fb4e07b72a8496cc17fd72424675fe4fce3bf81a6dade', 6721381, NULL, 'lyrics/869c9f21-862f-4908-856b-91c976d7b3fe.lrc', 26, 0, 1, 1, 14, 14, 0, '2026-03-11 22:01:21', '2026-03-12 03:17:31');
INSERT INTO `tracks` VALUES (41, '独角', 'UnicornPhantom', NULL, 182, 0, 'audio/mpeg', 'music/7e9360cd-1cc1-4954-99d5-3088c2b05dca.mp3', 'cover/7c9a7acc-e5ea-47a8-89de-10148736529a.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/7c9a7acc-e5ea-47a8-89de-10148736529a.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T140315Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=31df3b62fb472445e037fb276248f4007fc3a89958745016c400ad502704b6e0', 7769569, NULL, NULL, 25, 8, 1, 1, 14, 10, 0, '2026-03-11 22:03:16', '2026-03-14 21:46:19');
INSERT INTO `tracks` VALUES (42, '大喜', '泠鸢yousa', NULL, 181, 0, 'audio/flac', 'music/a32891a5-5550-4c9a-b67b-dca9f6b15519.flac', 'cover/fd5cda32-9775-4988-bb65-88470c4dea9f.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/fd5cda32-9775-4988-bb65-88470c4dea9f.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T141916Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=ad6ada7f88b198a069a97ae1020ba6f4725394237a863501be5845544617c211', 39248376, '作词: 假寐\r\n作曲: 殇小谨\r\n编曲: 于瑾\r\n制作人: 殇小谨\r\n喜鹊叫闹\r\n来添红烛\r\n春风良宵\r\n碎玉铺路\r\n只此刻都心慌\r\n像是小鹿撞\r\n来人来客匆忙\r\n也快忘礼让\r\n我才攥住一颗喜糖\r\n分些喜气给红娘\r\n金钗摇\r\n摆摆摆摆~\r\n花轿摇\r\n摆摆摆摆~\r\n招摇\r\n摆摆摆摆~\r\n铃铛摇\r\n摆摆摆摆~\r\n一拜同心邀 山水迢迢\r\n二拜永结好 欢欢笑笑\r\n三拜共垂老 暮暮朝朝\r\n南来飞燕终归巢\r\n恰君子天骄 淑女窈窕\r\n有情相会七夕桥\r\n天官凡尘也落俗套\r\n赠红包\r\n许你我此生不辜负\r\n同甘~~~~\r\n共苦~~~~\r\n惜福~~~~\r\n许你我此生不辜负\r\n良辰~~~~\r\n共度~~~~\r\n无数~~~~\r\n只此刻都心慌\r\n像是小鹿撞\r\n来人来客匆忙\r\n也快忘礼让\r\n我才攥住一颗喜糖\r\n分些喜气给红娘\r\n金钗摇\r\n摆摆摆摆~\r\n花轿摇\r\n摆摆摆摆~\r\n招摇\r\n摆摆摆摆~\r\n铃铛摇\r\n摆摆摆摆~\r\n摆摆摆摆~\r\n摆摆摆摆~\r\n摆摆摆摆~\r\n摆摆摆摆~\r\n沾了粉黛\r\n张灯结彩\r\n看新人羞涩相对拜\r\n', NULL, 27, 0, 0, 1, 14, 15, 0, '2026-03-11 22:19:16', '2026-03-11 22:19:16');
INSERT INTO `tracks` VALUES (43, '願い～あの頃のキミへ～', '當山みれい', '', 340, 0, 'audio/mpeg', 'music/52f17e2c-98ab-4ecf-973c-6a04379b4586.mp3', 'cover/a1575ac3-6575-41af-a809-3a08a6f04e66.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/a1575ac3-6575-41af-a809-3a08a6f04e66.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T142354Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=8bc9bdac834f1521de018ee76e423cddf63aaaf6daa8246e56f5b1f96d1c63f1', 13619422, '\n[ml:1.0]\n[00:00.00]願い～あの頃のキミへ～ (祈愿~致那个时候的你～) - 當山みれい (当山真玲)\n[00:05.01]   \n[00:05.01]词：Dohzi-T\n[00:10.03]   \n[00:10.03]曲：Shingo.S/Dohzi-T\n[00:15.05]   \n[00:15.05]ふたりの想い出\n[00:17.79]如果将两个人的回忆\n[00:17.79]かき集めたなら\n[00:20.59]搜集在一起\n[00:20.59]また泣けてきちゃう\n[00:23.50]一定会再次哭泣\n[00:23.50]寂しさ溢れて\n[00:26.28]寂寞满溢\n[00:26.28]最後の恋だと信じて願った\n[00:31.99]曾相信这是最后的恋情\n[00:31.99]あの日々にウソはなかった\n[00:41.27]那些日子里没有丝毫谎言\n[00:41.27]希望夢明るい未来\n[00:44.09]希望 梦想 还有那明亮的未来\n[00:44.09]東京に持った大きな期待\n[00:46.83]对东京持有很大的期待\n[00:46.83]だけど現実は甘くなくて\n[00:49.54]但现实却没有那么令人满溢\n[00:49.54]落ち葉見つめ深く思いつめてた\n[00:52.75]凝视着落叶陷入沉思\n[00:52.75]そんな時にあなたと出会って\n[00:55.72]那个时候与你相遇\n[00:55.72]いつもあなたに助けられて\n[00:58.50]总是得到你的帮助\n[00:58.50]バイトが楽しみになって\n[01:01.05]变得期待打工时间\n[01:01.05]実はシフト被るように狙ってた\n[01:04.22]实际上是希望沉浸于工作而忘却自己\n[01:04.22]スタンプ使いが妙に上手くて\n[01:07.02]印章的使用意外地顺利\n[01:07.02]お化けも虫も受け付けなくて\n[01:09.81]怪物和虫子全部不能接受\n[01:09.81]くしゃくしゃの笑顔が可愛くて\n[01:12.66]圆圆的笑脸是那么可爱\n[01:12.66]眠れない夜は君のせいで\n[01:15.62]失眠的夜晚全都是因为你\n[01:15.62]この気持ち今すぐに伝えたい\n[01:18.29]现在就想传达出内心的情感\n[01:18.29]けどバレたくない\n[01:19.69]但是却不想暴露自己\n[01:19.69]どうしたらいいの\n[01:21.30]到底该怎么办才好\n[01:21.30]迷ってるうちに\n[01:22.64]在不知所措的期间里\n[01:22.64]夜明けが来て\n[01:24.06]黎明已经来临\n[01:24.06]馬鹿みたいに後悔して\n[01:26.34]像个笨蛋一样不断后悔\n[01:26.34]ふたりの想い出\n[01:28.71]如果将两个人的回忆\n[01:28.71]かき集めたなら\n[01:31.58]搜集在一起\n[01:31.58]また泣けてきちゃう\n[01:34.39]一定会再次哭泣\n[01:34.39]寂しさ溢れて\n[01:37.14]寂寞满溢\n[01:37.14]最後の恋だと信じて願った\n[01:42.96]曾相信这是最后的恋情\n[01:42.96]あの日々にウソはなかった\n[02:00.42]那些日子里没有丝毫谎言\n[02:00.42]帰り道の公園で受けた告白\n[02:03.90]在回家路上的公园里接受的告白\n[02:03.90]ベタすぎるセリフ笑っちゃった\n[02:06.71]台词太美好 让人忍不住笑\n[02:06.71]一生忘れられない思い出\n[02:09.56]一生都无法忘记的回忆\n[02:09.56]あなたがプレゼントしてくれた\n[02:12.42]你所给我的礼物\n[02:12.42]一日中ゲームやりこんで\n[02:15.12]一整天沉迷于游戏里\n[02:15.12]夜ご飯は一緒に作って\n[02:18.02]两个人一起做晚饭\n[02:18.02]贅沢なんてしなくたって\n[02:20.60]虽然不想过分要求\n[02:20.60]２人いればそれだけでよくて\n[02:23.76]但只要两个人在一起就好\n[02:23.76]口下手２人が本気で喧嘩\n[02:26.57]两个嘴笨的人认真吵架\n[02:26.57]お互いブロック通じない電話\n[02:29.39]两个人闹的很僵 也不打电话\n[02:29.39]本気でぶつかり合えることが\n[02:32.19]却从没意识到这样认真的吵架\n[02:32.19]どんな愛しいが気づけなかって\n[02:35.11]是怎样的一种爱意\n[02:35.11]あなたが教えてくれたこと\n[02:38.24]你所告诉我的事情\n[02:38.24]くれたもの\n[02:39.77]给我的东西\n[02:39.77]胸に刻み過ごしてる今日も\n[02:42.55]今天也依然铭刻于心里\n[02:42.55]だから伝えたいありがとう\n[02:45.69]所以想和你说声谢谢\n[02:45.69]ふたりの想い出\n[02:48.24]如果将两个人的回忆\n[02:48.24]かき集めたなら\n[02:51.05]搜集在一起\n[02:51.05]また泣けてきちゃう\n[02:53.95]一定会再次哭泣\n[02:53.95]寂しさ溢れて\n[02:56.71]寂寞满溢\n[02:56.71]最後の恋だと信じて願った\n[03:02.50]曾相信这是最后的恋情\n[03:02.50]あの日々にウソはなかった\n[03:08.81]那些日子里没有丝毫谎言\n[03:08.81]子供のままでいられたなら\n[03:14.24]如果能够永远都长不大\n[03:14.24]何も怖がらず歩いて行けたかな\n[03:19.98]是否能够毫不畏惧继续前行\n[03:19.98]もっと早く大人になっていたなら\n[03:25.67]如果能够更早的变成熟\n[03:25.67]２人で乗り越えられたかな\n[03:30.64]两个人是否就能跨越这一切\n[03:30.64]今も君の夢夜空へ願う\n[03:37.82]如今依然向夜空中祈愿你的梦境\n[03:37.82]今でも君は\n[03:39.83]如今的你\n[03:39.83]あの頃と同じ笑顔で\n[03:43.33]依然保持和那时相同的笑脸\n[03:43.33]今でも君は\n[03:45.44]如今的你\n[03:45.44]あの頃のようにまっすぐで\n[03:48.95]如同那时一样率直\n[03:48.95]今でも君は\n[03:51.13]如今的你\n[03:51.13]あの頃と変わらない優しさで\n[03:54.69]和那个时候一样温柔\n[03:54.69]今でも君は\n[03:57.50]如今的你\n[03:57.50]君のままでいてほしいそう願うよ\n[04:02.48]希望你能一直保持这个样子\n[04:02.48]ふたりの想い出\n[04:04.95]如果将两个人的回忆\n[04:04.95]かき集めたなら\n[04:07.82]搜集在一起\n[04:07.82]また泣けてきちゃう\n[04:10.68]一定会再次哭泣\n[04:10.68]寂しさ溢れて\n[04:13.45]寂寞满溢\n[04:13.45]最後の恋だと信じて願った\n[04:19.25]曾相信这是最后的恋情\n[04:19.25]あの日々にウソはなかった\n[04:25.28]那些日子里没有丝毫谎言\n[04:25.28]ふたりの想い出集めたら\n[04:28.15]如果将两个人的回忆搜集在一起\n[04:28.15]泣き出しそうになる今夜も\n[04:30.98]放声哭泣的今夜\n[04:30.98]寂しさ溢れて苦しくなる\n[04:36.57]依然充满着寂寞 让人痛苦\n[04:36.57]最後の恋と信じ願った\n[04:39.51]曾相信这是最后的恋情\n[04:39.51]あの日々に嘘はなかった\n[04:42.43]那些日子里没有丝毫谎言\n[04:42.43]離れてもあなたの幸せ願う\n[04:48.00]即使相互分离 也祝愿你能得到幸福\n[04:48.00]ふたりの想い出集めたら\n[04:50.83]如果将两个人的回忆搜集在一起\n[04:50.83]泣き出しそうになる今夜も\n[04:53.71]放声哭泣的今夜\n[04:53.71]寂しさ溢れて苦しくなる\n[04:59.33]依然充满着寂寞 让人痛苦\n[04:59.33]最後の恋と信じ願った\n[05:02.24]曾相信这是最后的恋情\n[05:02.24]あの日々に嘘はなかった\n[05:05.12]那些日子里没有丝毫谎言\n[05:05.12]離れてもあなたの幸せ願う\n[05:10.12]即使相互分离 也祝愿你能得到幸福\n[05:10.12]\n', 'lyrics/dbfbaf1a-5601-46ef-809e-ddd8636dbf20.lrc', 28, 0, 1, 1, 14, 9, 0, '2026-03-11 22:23:54', '2026-03-11 23:26:58');
INSERT INTO `tracks` VALUES (44, 'Take me hand', '塞西尔·科贝尔（Cécile Corbel）', '', 216, 0, 'audio/mpeg', 'music/58e1afc8-d336-4a7a-a753-be16ec115955.mp3', 'cover/5c11495e-e80f-42b4-8357-b07d88ae49fc.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/5c11495e-e80f-42b4-8357-b07d88ae49fc.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T154055Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=3861a9a71e338fb8517b2101aa2330bc7fc23ee60d19e02587c4b1f87d3487b8', 8627972, ' \r\n[ml:1.0]\r\n[ti:Take me hand]\r\n[ar:Cécile Corbel]\r\n[al:Take me hand]\r\n[by:yalin_karakal]\r\n[offset:0]\r\n[00:00.06]Take Me Hand - Cécile Corbel\r\n[00:01.82]   \r\n[00:01.82]Lyrics by：Cécile Corbel\r\n[00:03.07]   \r\n[00:03.07]Composed by：DAISHI DANCE/Tomoharu Moriya\r\n[00:22.80]   \r\n[00:22.80]In my dreams\r\n[00:24.62]我的梦里\r\n[00:24.62]I feel your light\r\n[00:26.48]有你的光芒\r\n[00:26.48]I feel love is born again\r\n[00:30.24]爱再次绽放\r\n[00:30.24]Fireflies\r\n[00:32.12]萤火虫\r\n[00:32.12]In the moonlight\r\n[00:33.96]在月光里\r\n[00:33.96]Rising stars\r\n[00:37.76]如闪烁的繁星\r\n[00:37.76]Remember\r\n[00:40.14]还记得吗\r\n[00:40.14]The day\r\n[00:42.04]在那一天\r\n[00:42.04]I fell in love with you\r\n[00:45.29]我迷恋上了你\r\n[00:45.29]Darling won\'t you break\r\n[00:49.43]亲爱的 请不要伤害\r\n[00:49.43]My heart\r\n[00:53.23]我的心\r\n[00:53.23]Take my hand now\r\n[00:55.19]抓紧我的手\r\n[00:55.19]Stay close to me\r\n[00:57.05]靠近我的心\r\n[00:57.05]Be my lover\r\n[00:58.77]成为我爱人\r\n[00:58.77]Won\'t you let me go\r\n[01:00.74]不要放开我的手\r\n[01:00.74]Close your eyes now\r\n[01:02.53]闭上你的眼睛\r\n[01:02.53]And you will see\r\n[01:04.49]你将会看到\r\n[01:04.49]There\'s a rainbow\r\n[01:06.34]有道彩虹\r\n[01:06.34]For you and me\r\n[01:22.98]连接你我的心\r\n[01:22.98]As I wake up\r\n[01:24.64]当我醒来\r\n[01:24.64]I see your face\r\n[01:26.43]看到你的脸\r\n[01:26.43]I feel love is born again\r\n[01:30.27]爱再次绽放\r\n[01:30.27]Cherry blossom\r\n[01:32.11]樱花盛开\r\n[01:32.11]Flying birds\r\n[01:33.95]飞翔的鸟儿\r\n[01:33.95]In the sky\r\n[01:37.83]在蓝天翱翔\r\n[01:37.83]Can\'t you see\r\n[01:40.10]你看见了吗\r\n[01:40.10]The sun\r\n[01:41.40]阳光\r\n[01:41.40]That is shining on the fields\r\n[01:45.36]在原野闪烁\r\n[01:45.36]Is it shining in\r\n[01:49.44]像闪烁在\r\n[01:49.44]Your heart\r\n[01:53.26]你的心\r\n[01:53.26]Take my hand now\r\n[01:55.03]抓紧我的手\r\n[01:55.03]Stay close to me\r\n[01:57.03]靠近我的心\r\n[01:57.03]Be my lover\r\n[01:58.81]成为我爱人\r\n[01:58.81]Won\'t you let me go\r\n[02:00.71]不要放开我的手\r\n[02:00.71]Close your eyes now\r\n[02:02.61]闭上你的眼睛\r\n[02:02.61]And you will see\r\n[02:04.48]你将会看到\r\n[02:04.48]There\'s a rainbow\r\n[02:06.33]有道彩虹\r\n[02:06.33]For you and me\r\n[02:07.86]连接你我的心\r\n[02:07.86]And I dream of you\r\n[02:11.56]你出现在我梦中\r\n[02:11.56]Every night\r\n[02:15.18]每个夜晚\r\n[02:15.18]Cause\'s there only you\r\n[02:18.95]因为只有你\r\n[02:18.95]In my mind\r\n[02:22.85]在我脑海里\r\n[02:22.85]Will you be\r\n[02:25.22]你愿成为\r\n[02:25.22]A stranger or a friend in my life\r\n[02:30.23]我生命中的陌生人或朋友\r\n[02:30.23]Darling won\'t you break\r\n[02:33.91]亲爱的 请不要伤害\r\n[02:33.91]My heart\r\n[02:38.32]我的心\r\n[02:38.32]Take my hand now\r\n[02:40.06]抓紧我的手\r\n[02:40.06]Stay close to me\r\n[02:41.95]靠近我的心\r\n[02:41.95]Be my lover\r\n[02:43.82]成为我爱人\r\n[02:43.82]Won\'t you let me go\r\n[02:45.66]不要放开我的手\r\n[02:45.66]Close your eyes now\r\n[02:47.58]闭上你的眼睛\r\n[02:47.58]And you will see\r\n[02:49.42]你将会看到\r\n[02:49.42]There\'s a rainbow\r\n[02:51.31]有道彩虹\r\n[02:51.31]For you and me\r\n[02:53.22]连接你我的心\r\n[02:53.22]Take my hand now\r\n[02:55.52]抓紧我的手\r\n[02:55.52]Stay close to me\r\n[02:57.13]靠近我的心\r\n[02:57.13]Be my lover\r\n[02:58.79]成为我爱人\r\n[02:58.79]Won\'t you let me go\r\n[03:00.60]不要放开我的手\r\n[03:00.60]Close your eyes now\r\n[03:01.67]闭上你的眼睛\r\n[03:01.67]And you will see\r\n[03:02.75]你将会看到\r\n[03:02.75]There\'s a rainbow\r\n[03:03.84]有道彩虹\r\n[03:03.84]For you and me\r\n[03:08.084]连接你我的心\r\n[03:08.084]\r\n', 'lyrics/cface4a3-07d4-4761-9f38-6957d7ef9d89.lrc', 29, 1, 1, 1, 14, 14, 0, '2026-03-11 23:40:56', '2026-03-12 15:52:35');
INSERT INTO `tracks` VALUES (45, '原 Origin', 'CORSAK胡梦周', '', 239, 0, 'audio/mpeg', 'music/c74b5397-c1dd-43ce-bfe2-e322f74c6d81.mp3', 'cover/8cb88710-cbe3-4248-bd12-cda9c98055bd.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/8cb88710-cbe3-4248-bd12-cda9c98055bd.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T154801Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=f5c73ff0e1b7e1a78fdd7de235fdf68877f6061ef86c1771c40917b49f5e0f71', 9576715, '[00:00.00] \r\n[ti:原 Origin]\r\n[ar:CORSAK胡梦周]\r\n[al:原 Origin]\r\n[by:dongmei_karakal]\r\n[offset:0]\r\n[00:00.00]原 Origin - CORSAK胡梦周\r\n[00:00.82]词：CORSAK胡梦周\r\n[00:01.41]曲：CORSAK胡梦周\r\n[00:02.00]编曲：CORSAK胡梦周\r\n[00:02.71]制作人：CORSAK胡梦周\r\n[00:03.54]钢琴：CORSAK胡梦周\r\n[00:04.24]合声编写：CORSAK胡梦周\r\n[00:05.19]合声：CORSAK胡梦周\r\n[00:05.90]弦乐编写：CORSAK胡梦周\r\n[00:06.84]录音师：刘俊杰\r\n[00:07.55]混音师：刘俊杰\r\n[00:08.26]母带工程师：Kwon Nam Woo\r\n[00:09.20]母带工作室：821 Mastering Studio\r\n[00:10.21]都快结束\r\n[00:14.61]没说完让它随风\r\n[00:19.75]暂时沉默陪我\r\n[00:22.64]就让渺小的我\r\n[00:25.09]躲进人海漂流\r\n[00:29.36]闭上眼 的时候\r\n[00:34.51]倒影清楚又模糊\r\n[00:39.17]我们刻在沙滩\r\n[00:41.72]那最初的美梦\r\n[00:44.44]被冲刷掉没有\r\n[00:47.64]如果这就是\r\n[00:50.06]故事的结尾我\r\n[00:52.28]不愿接受\r\n[00:53.77]辽阔世界突然走到尽头\r\n[00:56.97]如果这一刻能回到原点我\r\n[01:01.65]我会紧握住\r\n[01:03.45]还颤抖的手\r\n[01:05.53]然后全力一搏\r\n[01:15.59]守护你到最后\r\n[01:24.70]我会全力一搏\r\n[01:33.85]我会全力一搏\r\n[01:44.25]我会全力一搏\r\n[01:46.55]来到最后一章\r\n[01:48.70]每个音符我\r\n[01:50.79]都用生命大声唱\r\n[01:55.35]别人笑我们疯狂\r\n[01:58.35]可有谁的青春\r\n[02:00.75]不曾横冲直撞\r\n[02:05.40]闭上眼 的时候\r\n[02:10.25]倒影清楚又模糊\r\n[02:14.26]少年追逐海浪\r\n[02:17.79]用沙堆的城堡\r\n[02:20.14]在心中屹立不倒\r\n[02:23.42]如果这就是\r\n[02:26.05]故事的结尾我\r\n[02:28.37]不愿接受\r\n[02:29.70]辽阔世界突然走到尽头\r\n[02:33.19]如果这一刻能回到原点我\r\n[02:38.08]我会紧握住\r\n[02:39.76]还颤抖的手\r\n[02:41.11]然后全力一搏\r\n[02:50.97]守护你到最后\r\n[03:00.63]我会全力一搏\r\n[03:10.50]我会全力一搏\r\n[03:13.04]我会紧握住\r\n[03:15.26]还颤抖的手\r\n[03:17.91]然后全力一搏\r\n[03:20.31]守护你到最后\r\n[03:29.25]我会全力一搏\r\n[03:39.52]我会全力一搏\r\n[03:42.01]都还没结束\r\n[03:45.78]哪怕只剩一分钟\r\n[03:50.71]还有人在爱我\r\n[03:53.92]还有人要守护\r\n[03:56.33]我会全力一搏\r\n', 'lyrics/d1424692-0faf-412e-b11d-9f004f6ff5b0.lrc', 30, 0, 0, 1, 14, 11, 0, '2026-03-11 23:48:02', '2026-03-11 23:48:02');
INSERT INTO `tracks` VALUES (46, '驰 Timelapse', 'CORSAK胡梦周', NULL, 194, 0, 'audio/mpeg', 'music/85b28058-7d28-44fc-860c-3b74babd6bb3.mp3', 'cover/9bf943f3-dfaf-4c75-8083-084b1141ef83.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/9bf943f3-dfaf-4c75-8083-084b1141ef83.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T154957Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=147fb3db287dec23e38a8150be4e94998ff2dd1470681c61434cb403f9e9b097', 7750246, NULL, 'lyrics/d9080543-1339-4b48-becb-2d1e2032f62a.lrc', 30, 0, 0, 1, 14, 11, 0, '2026-03-11 23:49:57', '2026-03-11 23:49:57');
INSERT INTO `tracks` VALUES (47, '溯 (Reverse)', 'CORSAK胡梦周', NULL, 192, 0, 'audio/mpeg', 'music/43275f93-bacd-4630-96e5-6906d1718ecb.mp3', 'cover/518b110d-ae4e-4f3f-a6d4-ddb7200e1a0d.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/518b110d-ae4e-4f3f-a6d4-ddb7200e1a0d.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T155155Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=dd1e02c4d603e37f4ec14f5eccca2fb0e6ec525cb11089edf2692047922676b7', 7684323, NULL, 'lyrics/14417083-ecee-4cee-840a-9913ee59ecc3.lrc', 30, 0, 0, 1, 14, 11, 0, '2026-03-11 23:51:55', '2026-03-11 23:51:55');
INSERT INTO `tracks` VALUES (48, '君に最後の口づけを', 'majiko', NULL, 280, 0, 'audio/mpeg', 'music/616cfe56-01f6-43f3-8a59-11814247ace6.mp3', 'cover/99ee8169-fd51-4a06-bd81-446e075307f1.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/99ee8169-fd51-4a06-bd81-446e075307f1.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T155331Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=dd59eebec888976f60993293b6c4e263b9d529824bed9d5386cc64ee3bdf4c32', 11204663, NULL, 'lyrics/81e53344-933f-453b-9378-600bdcff435d.lrc', 9, 0, 0, 1, 14, 9, 0, '2026-03-11 23:53:32', '2026-03-11 23:53:32');
INSERT INTO `tracks` VALUES (49, '心做し(カバー)', 'majiko', NULL, 274, 0, 'audio/mpeg', 'music/f69bcf33-c7ef-4a54-8ff4-4db8238c105a.mp3', 'cover/5e23b714-f2a5-4ab1-8739-a4d4084f5d34.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/5e23b714-f2a5-4ab1-8739-a4d4084f5d34.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T155440Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=7e5b3d534016671a81bc09c2565c3cb22a61e70af2584d6b7cbf0f870472989d', 10946561, NULL, 'lyrics/c0c8ac05-412e-471f-b360-2086d272a758.lrc', 9, 0, 1, 1, 14, 9, 0, '2026-03-11 23:54:41', '2026-03-12 14:54:11');
INSERT INTO `tracks` VALUES (50, 'なんでもないや', 'RADWIMPS', '你的名字', 342, 0, 'audio/mpeg', 'music/70065fd9-c705-4f90-b8aa-174b401f78d9.mp3', 'cover/68e42260-0377-4026-a5a6-2fdfbaf0eac0.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/68e42260-0377-4026-a5a6-2fdfbaf0eac0.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T155611Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=c0159baed276998e36d0f7745b11ee2d735c48f4066392052d5e5fa7e26b4b84', 13678975, NULL, 'lyrics/93779fcc-7a6c-4298-967e-3f2ba5d05380.lrc', 7, 3, 0, 1, 14, 9, 0, '2026-03-11 23:56:12', '2026-03-14 21:37:48');
INSERT INTO `tracks` VALUES (51, '大丈夫(Movie edit)', 'RADWIMPS', '天气之子', 258, 0, 'audio/mpeg', 'music/af2a5538-a375-4932-bf88-fe11c7be84cf.mp3', 'cover/79bfed84-1423-4a55-a758-7174c03cb5ae.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/79bfed84-1423-4a55-a758-7174c03cb5ae.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T155714Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=ed5b8ee5aa5c477882503733375e2c6657335074c02c56d829c48f470a46f81e', 10337381, NULL, 'lyrics/f02d73d0-cc4d-4966-b72f-137063178b4a.lrc', 7, 0, 0, 1, 14, 9, 0, '2026-03-11 23:57:15', '2026-03-11 23:57:15');
INSERT INTO `tracks` VALUES (52, '夢灯籠', 'RADWIMPS', '你的名字', 128, 0, 'audio/mpeg', 'music/3e2130ae-e3ff-49ec-ad53-7500e34307b6.mp3', 'cover/fd3d1599-fea0-4522-8e34-215228b313fb.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/fd3d1599-fea0-4522-8e34-215228b313fb.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T155744Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=ac5b2121b435d9a1bcdebd9c2347963c14248588423e0bbbfa51f38e8cb556b2', 5136926, NULL, 'lyrics/53509aac-eda6-4e54-ad16-935c3d113919.lrc', 7, 0, 0, 1, 14, 9, 0, '2026-03-11 23:57:44', '2026-03-11 23:57:44');
INSERT INTO `tracks` VALUES (53, 'すずめ feat.十明', 'RADWIMPS', '铃芽之旅', 239, 0, 'audio/mpeg', 'music/ec76a0cf-ab83-44e6-b849-a596e06c311e.mp3', 'cover/f51e73f9-d148-49bb-ab72-a5a7f7b1ce3a.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/f51e73f9-d148-49bb-ab72-a5a7f7b1ce3a.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T155920Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=6a39f0cd10d04582a341c3fd499387788516320283893042607dbe00cfb8483f', 9545373, NULL, 'lyrics/e159eed6-a991-4a40-b2f9-035d5d76076b.lrc', 7, 31, 0, 1, 14, 9, 0, '2026-03-11 23:59:21', '2026-03-15 01:43:57');
INSERT INTO `tracks` VALUES (54, 'ANIMA', 'ReoNa', '刀剑神域', 267, 0, 'audio/mpeg', 'music/d235b5d5-9364-4563-aa6e-14e64ac64fed.mp3', 'cover/2b785dbb-33bc-4635-be2b-4cfc49eb28d7.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/2b785dbb-33bc-4635-be2b-4cfc49eb28d7.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T160042Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=3cdda3152d3b84545e2d8b84e7aa750a381cfbcd3cf3ad05a593a8423425eb33', 10689512, NULL, 'lyrics/56a88767-ba72-46fa-a9b5-3acdbb3a8dfc.lrc', 8, 0, 0, 1, 14, 9, 0, '2026-03-12 00:00:42', '2026-03-12 00:00:42');
INSERT INTO `tracks` VALUES (55, '虹の彼方に', 'ReoNa', '刀剑神域', 290, 0, 'audio/mpeg', 'music/4f709174-4599-4406-bec6-53aaf78c36b6.mp3', 'cover/033e263a-3604-41b7-a036-4d735bbfb0a7.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/033e263a-3604-41b7-a036-4d735bbfb0a7.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T160132Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=70c604b053238156170e0847b47b9d710002717e03e90af39544a48d69e0de80', 11615307, NULL, 'lyrics/1a1b877b-0916-45d7-a138-ab810b6a6909.lrc', 8, 0, 0, 1, 14, 9, 0, '2026-03-12 00:01:32', '2026-03-12 00:01:32');
INSERT INTO `tracks` VALUES (56, '愛にできることはまだあるかい(Movie edit)', 'RADWIMPS', '天气之子', 151, 0, 'audio/mpeg', 'music/86bc6dc2-9551-4764-aaa3-8aa0d09261b9.mp3', 'cover/61225dfb-a0fe-4639-9724-883e1a172f1e.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/61225dfb-a0fe-4639-9724-883e1a172f1e.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T160222Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=01424234581f2244c43f113dd9c6941c9ffe1dd8afa795605bbe167c286e827d', 6029289, NULL, 'lyrics/b4001b06-8f2f-4a31-82a7-9cb6c3b006e8.lrc', 7, 38, 0, 1, 14, 9, 0, '2026-03-12 00:02:22', '2026-03-14 23:39:33');
INSERT INTO `tracks` VALUES (57, '一点', 'Muyoi&Pezzi', NULL, 201, 0, 'audio/mpeg', 'music/01a13d1c-042d-441c-91b6-94686b7e5acb.mp3', 'cover/33242add-3228-4557-a732-c144045b0795.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/33242add-3228-4557-a732-c144045b0795.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T160419Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=b730ef6085abee66f8fc304d805ea4fb773c4e3bc2db7af14002c2dd1763fc9f', 8029214, NULL, 'lyrics/e7591d9c-87ea-442f-9aa7-3d0932f48b78.lrc', 31, 1, 0, 1, 14, 11, 0, '2026-03-12 00:04:19', '2026-03-13 15:32:46');
INSERT INTO `tracks` VALUES (58, 'LilaS-', '澤野弘之', NULL, 245, 0, 'audio/mpeg', 'music/53bb6479-d0a5-4b1c-8c6c-75214a1a1c18.mp3', 'cover/d1b1e973-68ca-44f0-8397-6b3a8b6898e0.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/d1b1e973-68ca-44f0-8397-6b3a8b6898e0.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T160536Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=e88b837e622a6d296975c8b3bf2296ae7103390e9def1b334e88e37b22c78590', 9818708, NULL, 'lyrics/3ab0c4d0-2644-46d4-8fd6-7e4c46689fb7.lrc', 6, 0, 0, 1, 14, 9, 0, '2026-03-12 00:05:37', '2026-03-12 00:05:37');
INSERT INTO `tracks` VALUES (59, 'Unravel', 'TK', '东京喰种', 238, 0, 'audio/mpeg', 'music/77a37dee-e8d0-4b1e-b2a4-7f923f8e9f30.mp3', 'cover/9fba9080-fbe9-4bf3-8239-d1502ff3c281.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/9fba9080-fbe9-4bf3-8239-d1502ff3c281.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T160926Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=e7b94337dae11df7ddfe80f11119345a821dfc3fa25c6d8d49a6af61012cbac7', 9522387, NULL, 'lyrics/9774ba4c-949f-476c-8a60-d57bfce91e3a.lrc', 32, 0, 0, 1, 14, 9, 0, '2026-03-12 00:09:26', '2026-03-12 00:09:26');
INSERT INTO `tracks` VALUES (60, 'もう少しだけ', 'YOASOBI', NULL, 219, 0, 'audio/mpeg', 'music/f4d04bee-f0df-43f8-84a2-bfc2f5b14a64.mp3', 'cover/390b40a0-9a84-4e15-8506-c232aaf02de9.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/390b40a0-9a84-4e15-8506-c232aaf02de9.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T161030Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=dc7de68cffcdec04297f88128f81f4aa31730b8fc88584fa51e00068a33370f5', 8756459, NULL, 'lyrics/f6f49932-be1f-4694-9565-ce46f45e63fb.lrc', 13, 0, 1, 1, 14, 9, 0, '2026-03-12 00:10:31', '2026-03-12 14:07:22');
INSERT INTO `tracks` VALUES (61, '群青', 'YOASOBI', NULL, 248, 0, 'audio/mpeg', 'music/8f6b34e5-9e77-4220-aac2-2794f09753ed.mp3', 'cover/a4e8bedf-d46a-4bff-92a3-c6a992ae351a.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/a4e8bedf-d46a-4bff-92a3-c6a992ae351a.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T161120Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=a4ded9b2a69ecaa61e630806446bb1c234878d8bf6f68ef3e2894d9c23ad71e0', 9940312, NULL, 'lyrics/bed7c08c-eff1-4b2e-b86c-d8dae56c1608.lrc', 13, 0, 0, 1, 14, 9, 0, '2026-03-12 00:11:20', '2026-03-12 00:11:20');
INSERT INTO `tracks` VALUES (62, '夜に駆ける', 'YOASOBI', NULL, 261, 0, 'audio/mpeg', 'music/5ab1517e-c950-47f8-8f79-baec521f659d.mp3', 'cover/78ff9157-45a3-4611-aaa9-84601c4a9273.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/78ff9157-45a3-4611-aaa9-84601c4a9273.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T161207Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=9b6d9527fe300a8885439870f38177cc066b30d447cc4499302db2c2aefc2176', 10442920, NULL, 'lyrics/1a80bdba-ab28-411a-9276-748b11dc32e1.lrc', 13, 0, 0, 1, 14, 9, 0, '2026-03-12 00:12:08', '2026-03-12 00:12:08');
INSERT INTO `tracks` VALUES (63, '勇者', 'YOASOBI', '葬送的芙莉莲', 194, 0, 'audio/mpeg', 'music/d8f07547-f1fc-4579-9210-07f60ad8d3ea.mp3', 'cover/77625cbb-b421-4ee2-81a6-72bb511a5733.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/77625cbb-b421-4ee2-81a6-72bb511a5733.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T161317Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=363dafbf533d263df9153762c82d8b7eebbc3aeef9bdf8ea9b7c0dba14207080', 7773222, NULL, 'lyrics/5fd0ec98-0ba9-4ec3-a07e-14808a3f45bb.lrc', 13, 0, 0, 1, 14, NULL, 0, '2026-03-12 00:13:18', '2026-03-12 00:13:18');
INSERT INTO `tracks` VALUES (64, 'GLISTENING♭', '安野希世乃', '路人女主的养成方法', 320, 0, 'audio/mpeg', 'music/3e8eea5f-b29a-497a-911a-08ab201060b6.mp3', 'cover/10c900a7-6654-43e6-85c3-66a315774e54.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/10c900a7-6654-43e6-85c3-66a315774e54.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T161601Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=9ed4ef3d60f6946604bf472b3252276773e390ef65aff3ffab141e315a4c21aa', 12821180, NULL, 'lyrics/68c69579-44e7-42d0-beb8-c580c6e18af7.lrc', 33, 15, 3, 1, 14, 9, 0, '2026-03-12 00:16:01', '2026-03-14 21:11:47');
INSERT INTO `tracks` VALUES (65, 'M♭', '安野希世乃', '路人女主的养成方法', 222, 0, 'audio/mpeg', 'music/37fc7a46-a27b-4e66-af2d-9139129bf4bd.mp3', 'cover/136addff-4a47-4724-90d6-1f2cf8218a1f.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/136addff-4a47-4724-90d6-1f2cf8218a1f.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T161649Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=afe2c2096ae5346511a5a5be04069b201cab86d3ad093ac9848ea56eb6d8be79', 8881880, NULL, 'lyrics/1408cf3e-ae29-4d7a-ae5c-ba99b6d1c0ee.lrc', 33, 6, 1, 1, 14, 9, 0, '2026-03-12 00:16:50', '2026-03-14 21:27:53');
INSERT INTO `tracks` VALUES (66, 'ULTIMATE♭(Inst.)', '安野希世乃', '路人女主的养成方法', 273, 0, 'audio/mpeg', 'music/963e4bf2-21f8-4173-ab25-6cac182105b9.mp3', 'cover/8c8e26ba-f526-44a0-a82b-73746ae80d38.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/8c8e26ba-f526-44a0-a82b-73746ae80d38.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T161744Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=ab608c138c8a3438d589ae6bdbe40254b2f7844300758680f8638be09814329a', 10923631, NULL, 'lyrics/41c93b2a-d802-49a4-955d-72a47d67a6ed.lrc', 33, 2, 1, 1, 14, 9, 0, '2026-03-12 00:17:44', '2026-03-12 14:45:13');
INSERT INTO `tracks` VALUES (67, '你从未离去', '白挺', '熊出没', 223, 0, 'audio/mpeg', 'music/3bc094a1-f093-490c-92c1-9ed9f5b60ec7.mp3', 'cover/f56bbf11-71e9-4336-b911-25e38402da61.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/f56bbf11-71e9-4336-b911-25e38402da61.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T161932Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=423658efa39c6a359e3494f99400ec092e94789b9d38a35873fb5b693885e887', 8926763, NULL, 'lyrics/4859c135-793d-4eeb-ae62-1e2d77663ff5.lrc', 34, 0, 0, 1, 14, 11, 0, '2026-03-12 00:19:33', '2026-03-12 00:19:33');
INSERT INTO `tracks` VALUES (68, '红色高跟鞋', '蔡健雅', NULL, 207, 0, 'audio/mpeg', 'music/21dda3b6-475c-4c0d-80c4-bcace2f75719.mp3', 'cover/3ac639d0-2f66-4702-98de-ee65e59e96f6.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/3ac639d0-2f66-4702-98de-ee65e59e96f6.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T162108Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=4a3b74a368707eee5b6889fb678ef69db840a9130abf0ee0527a534df450c14e', 8266389, NULL, 'lyrics/cba8603d-2a2a-4055-9bfd-4db987b61b94.lrc', 35, 0, 0, 1, 14, 12, 0, '2026-03-12 00:21:09', '2026-03-12 00:21:09');
INSERT INTO `tracks` VALUES (69, 'Cry for the moon', '出羽良彰', '来自风平浪静的明天', 180, 0, 'audio/mpeg', 'music/ae868b3b-928a-4183-aafb-21adfaed8d2a.mp3', 'cover/4e70a1c6-2206-4fc9-8291-985f2186fac6.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/4e70a1c6-2206-4fc9-8291-985f2186fac6.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T162258Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=d510e2194b4b2b752ab7980bd654690ae9956f621be4cdc169e2c7235d684b51', 7183723, NULL, NULL, 36, 0, 0, 1, 14, 10, 0, '2026-03-12 00:22:59', '2026-03-12 00:22:59');
INSERT INTO `tracks` VALUES (70, '我的名字', '焦迈奇', NULL, 252, 0, 'audio/mpeg', 'music/3a1b51ce-aa1f-4263-8171-55ba9b42c00f.mp3', 'cover/97c3ec24-23d8-4f7b-8e4d-ee6b9a1bc27d.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/97c3ec24-23d8-4f7b-8e4d-ee6b9a1bc27d.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T162502Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=0e871c5dceb28149de611e036fb6961dcd0b36d58d6a14ff42395fb37f6d5e53', 10063610, NULL, 'lyrics/0b778cde-e8c6-4d47-be20-a427b49c58c6.lrc', 37, 0, 0, 1, 14, 11, 0, '2026-03-12 00:25:02', '2026-03-12 00:25:02');
INSERT INTO `tracks` VALUES (71, '我们', '乐柠组合', '', 220, 0, 'audio/mpeg', 'music/05d3f060-4f30-41f0-88f0-93d0fa783a91.mp3', 'cover/76717bb8-71ed-40d4-b14e-5e0842079890.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/76717bb8-71ed-40d4-b14e-5e0842079890.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T162723Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=d37ad457e8a959a61000d0624da485966a96ab7a4d033b9a03701b93e789706b', 8798095, '[00:00.00] \r\n[ti:我们]\r\n[ar:乐柠组合]\r\n[al:我们 (原唱版)]\r\n[by:]\r\n[offset:0]\r\n[00:00.09]我们 - 乐柠组合\r\n[00:01.28]词：乐柠组合/小婷\r\n[00:02.70]曲：乐柠组合/群可\r\n[00:04.07]编曲：朱鸽\r\n[00:04.81]录音：浔浔\r\n[00:05.53]混缩：殇小谨\r\n[00:06.41]和声：Kent王健/殇小谨\r\n[00:07.86]和声编写：Kent王健/殇小谨\r\n[00:09.71]制作人：朱鸽\r\n[00:10.68]配唱制作人：朱鸽/Kent王健\r\n[00:13.11]录音室：Hot Music Studio\r\n[00:14.57]混音室：Hot Music Studio\r\n[00:30.64]男：\r\n[00:31.27]我想起了\r\n[00:32.34]你和我相爱的经过\r\n[00:35.45]回忆如此斑驳\r\n[00:38.99]可能你和我都太懦弱\r\n[00:42.66]忍不住泪光闪烁\r\n[00:45.87]命中注定了让你遇见我\r\n[00:49.61]最放不下的是深深爱过\r\n[00:53.37]如今成熟了我想对你说\r\n[00:56.99]未来的日子还有很多\r\n[00:59.76]我想与你度过\r\n[01:01.08]女：\r\n[01:01.64]我们这一路走来真的不容易\r\n[01:05.34]多少次流着泪说还不如分离\r\n[01:09.03]可是为什么后来都再次把你\r\n[01:12.62]拥入怀里\r\n[01:16.69]我们这爱情经过了太多风雨\r\n[01:20.28]我会比从前的我更加珍惜你\r\n[01:24.01]谁都离不开谁就算吵得彻底\r\n[01:27.60]还是一如既往爱着你\r\n[01:45.71]男：\r\n[01:46.18]我想起了\r\n[01:47.18]你和我相爱的经过\r\n[01:50.55]回忆如此斑驳\r\n[01:53.91]可能你和我都太懦弱\r\n[01:57.66]忍不住泪光闪烁\r\n[02:00.92]命中注定了让你遇见我\r\n[02:04.60]最放不下的是深深爱过\r\n[02:08.35]如今成熟了我想对你说\r\n[02:11.96]未来的日子还有很多\r\n[02:14.71]我想与你度过\r\n[02:16.08]女：\r\n[02:16.71]我们这一路走来真的不容易\r\n[02:20.28]多少次流着泪说还不如分离\r\n[02:24.04]可是为什么后来都再次把你\r\n[02:27.57]拥入怀里\r\n[02:31.53]我们这爱情经过了太多风雨\r\n[02:35.28]我会比从前的我更加珍惜你\r\n[02:39.02]谁都离不开谁就算吵得彻底\r\n[02:42.50]还是一如既往爱着你\r\n[02:46.13]男：\r\n[02:46.27]命中注定了让你遇见我\r\n[02:49.57]最放不下的是深深爱过\r\n[02:53.29]如今成熟了我想对你说\r\n[02:57.03]未来的日子还有很多\r\n[02:59.80]我想与你度过\r\n[03:02.70]女：\r\n[03:05.58]我们这一路走来真的不容易\r\n[03:09.01]多少次流着泪说还不如分离\r\n[03:12.75]可是为什么后来都再次把你\r\n[03:16.28]拥入怀里\r\n[03:20.36]我们这爱情经过了太多风雨\r\n[03:23.98]我会比从前的我更加珍惜你\r\n[03:27.73]谁都离不开谁就算吵得彻底\r\n[03:31.20]还是一如既往爱着你\r\n', 'lyrics/5492b076-0168-40fa-bcde-ce2adce7cec7.lrc', 38, 0, 0, 1, 14, 11, 0, '2026-03-12 00:27:23', '2026-03-12 00:27:23');
INSERT INTO `tracks` VALUES (72, '勾指起誓', '泠鸢yousa', '', 184, 0, 'audio/mpeg', 'music/07d355ec-6041-495f-8353-d1a62bebf617.mp3', 'cover/c0696e80-f266-4c10-b5fc-0dd66b878986.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/c0696e80-f266-4c10-b5fc-0dd66b878986.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T162908Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=26c9be4d072f7677c914e129eea1da2097b98258efbe24d334bb61199b51e2e2', 7343424, '[00:00.00] \r\n[ti:勾指起誓（Cover：ilem）]\r\n[ar:泠鸢yousa]\r\n[al:【泠鸢翻唱2019】]\r\n[by:]\r\n[offset:0]\r\n[00:00.00]勾指起誓 - 泠鸢yousa\r\n[00:03.16]词：ilem\r\n[00:06.32]曲：ilem\r\n[00:09.48]编曲：ilem\r\n[00:12.65]洛天依调校：ilem\r\n[00:15.81]P V：PinoEliza(明暗像素)\r\n[00:18.97]原唱：洛天依\r\n[00:22.14]你是信的开头诗的内容\r\n[00:25.37]童话的结尾\r\n[00:27.53]你是理所当然的奇迹\r\n[00:30.76]你是月色真美\r\n[00:33.23]你是圣诞老人送给我\r\n[00:36.61]好孩子的礼物\r\n[00:38.78]你是三千美丽世界里\r\n[00:42.28]我的一瓢水\r\n[00:44.52]所以让我再靠近一点点\r\n[00:47.91]因为你太温暖\r\n[00:50.16]我会再变得坚强一点点\r\n[00:53.60]因为你太柔软\r\n[00:55.76]交换无名指金色的契约\r\n[00:59.25]给彼此岁月\r\n[01:01.39]说好从今以后都牵着手\r\n[01:04.87]因为要走很远\r\n[01:29.99]你是我万水千山的冒险\r\n[01:33.11]要找的标记点\r\n[01:35.25]你是我分割人生的线\r\n[01:38.54]又将它们相连\r\n[01:40.91]你是前世千次的回眸\r\n[01:44.18]虔诚牵的手\r\n[01:46.50]你是其余所有的一切\r\n[01:49.85]你是我的世界\r\n[01:52.13]所以请你再闪亮一点点\r\n[01:55.75]尽管我太平凡\r\n[01:57.86]我会再变得柔软一点点\r\n[02:01.39]因为你太敏感\r\n[02:03.58]交换无名指金色的契约\r\n[02:07.10]给彼此岁月\r\n[02:09.19]说好从今以后都牵着手\r\n[02:12.68]不管要走多远\r\n[02:37.55]所以\r\n[02:38.14]让我再靠近一点点\r\n[02:40.91]因为你太温暖\r\n[02:43.17]我会再变得坚强一点点\r\n[02:46.65]因为你太柔软\r\n[02:48.68]交换无名指金色的契约\r\n[02:52.20]给彼此岁月\r\n[02:54.42]说好从今以后都牵着手\r\n[02:57.87]因为要走很远\r\n', 'lyrics/dc871881-3ebe-4abd-b5cf-2c19cbf17f2d.lrc', 39, 0, 0, 1, 14, 11, 0, '2026-03-12 00:29:08', '2026-03-12 00:29:08');
INSERT INTO `tracks` VALUES (73, '归期', '钱润玉Runyu', '凡人修仙传', 280, 0, 'audio/mpeg', 'music/871707ff-3610-47d8-87e4-eee5f3f7dc37.mp3', 'cover/6bc91f4d-2118-4be2-a77a-c6462e04e544.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/6bc91f4d-2118-4be2-a77a-c6462e04e544.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T163047Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=98cf6d77a5cd257313379bc10dea9262591ee9ab46d6f7bfee4baed49faf2e72', 11198387, NULL, 'lyrics/8d6491fd-41c4-4095-bf64-923f233b4418.lrc', 40, 0, 0, 1, 14, 11, 0, '2026-03-12 00:30:47', '2026-03-12 00:30:47');
INSERT INTO `tracks` VALUES (74, '把回忆拼好给你', '苏星婕', NULL, 182, 0, 'audio/mpeg', 'music/38758462-f361-4f48-b770-b2437aea3570.mp3', 'cover/bb16742a-1dc3-4bb9-a27e-ac1f08470422.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/bb16742a-1dc3-4bb9-a27e-ac1f08470422.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T163220Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=24eb573d261785e669672f98ce81e5681c08b96d0253917c40b1aae7ad4ed620', 7262651, NULL, 'lyrics/496be676-6a2c-413c-a3c8-77c835e68b6d.lrc', 41, 0, 0, 1, 14, 11, 0, '2026-03-12 00:32:21', '2026-03-12 00:32:21');
INSERT INTO `tracks` VALUES (75, '树读', '王俊凯', '', 237, 0, 'audio/mpeg', 'music/2d6f8b7a-6bcf-451d-aaf8-18d4ab9445f9.mp3', 'cover/40f27d1a-7778-49f2-b9db-7470ec7f7ef7.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/40f27d1a-7778-49f2-b9db-7470ec7f7ef7.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T163337Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=87a9fd445617019f5ed8c5a88757dad01d62d6fe468a244174e2ef65f470f846', 9470100, '[00:00.00] \r\n[ti:树读]\r\n[ar:王俊凯]\r\n[al:树读]\r\n[by:]\r\n[offset:0]\r\n[00:00.00]树读 - 王俊凯\r\n[00:05.47]词：黄俊郎\r\n[00:10.95]曲：王俊凯\r\n[00:16.43]编曲：林迈可\r\n[00:21.91]它往上 想明白那阳光\r\n[00:29.34]也往下 想守护着土壤\r\n[00:36.91]当天空不再蓝\r\n[00:40.52]就落下一张张\r\n[00:43.58]落地声响 慢慢枯黄\r\n[00:47.97]曾经淡绿的忧伤\r\n[00:52.26]山丘蜿蜒形状 被贪婪切成方\r\n[00:59.86]没人听见 它在日夜 祈求的愿望\r\n[01:07.70]河流不再笑着流淌 花也不再香\r\n[01:14.77]我们唯一学会的面对 竟然是遗忘\r\n[01:22.48]让它倒在一场 雷雨之后的小巷\r\n[01:29.44]而我要 实现它的愿望\r\n[01:42.02]它曾 扶持过瓦墙\r\n[01:43.91]也为 孩子们遮阳\r\n[01:45.81]用呼吸让这世界 不再浑浊\r\n[01:49.75]责怪的话从不说 难过也只是静默\r\n[01:53.67]只懂对别人温柔\r\n[01:56.97]当天空不再蓝\r\n[02:00.43]就落下一张张\r\n[02:03.57]落地声响 慢慢枯黄\r\n[02:07.88]曾经淡绿的忧伤\r\n[02:12.24]山丘蜿蜒形状 被贪婪切成方\r\n[02:19.83]没人听见 它在日夜 祈求的愿望\r\n[02:31.30]河流不再笑着流淌 花也不再香\r\n[02:38.79]我们唯一学会的面对 竟然是遗忘\r\n[02:46.24]让它倒在一场 雷雨之后的小巷\r\n[02:53.22]而我要 实现它的愿望\r\n[03:01.80]河流不再笑着流淌 花也不再香\r\n[03:09.25]我们唯一学会的面对 竟然是遗忘\r\n[03:16.95]让它倒在一场 雷雨之后的小巷\r\n[03:23.68]而我要 实现它的愿望\r\n[03:33.18]实现树的愿望\r\n', 'lyrics/b4a8cd76-17c8-4cfb-8c61-c0ff7e385295.lrc', 42, 0, 0, 1, 14, 11, 0, '2026-03-12 00:33:38', '2026-03-12 00:33:38');
INSERT INTO `tracks` VALUES (76, '暗许', '夏婉安', NULL, 190, 0, 'audio/mpeg', 'music/820f1bc3-1c32-4707-a039-021d8ffbcbce.mp3', 'cover/db2e66af-cea7-4db3-a417-4bb72d2ea6b9.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/db2e66af-cea7-4db3-a417-4bb72d2ea6b9.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T163650Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=68126e7fedf1a5b3411efd17d02f57a2c2bd73d0b5cb259b363af6813b77fabe', 7608092, NULL, 'lyrics/fbebfcba-dbe0-4bd4-8592-2aca4fa4a653.lrc', 43, 0, 0, 1, 14, 12, 0, '2026-03-12 00:36:50', '2026-03-12 00:36:50');
INSERT INTO `tracks` VALUES (77, '分了就分了', '夏婉安', NULL, 268, 0, 'audio/mpeg', 'music/1acc629a-0d76-4861-9aa9-b746e5bebf9c.mp3', 'cover/fbce591b-0d29-4ee3-af5c-6cf48831637f.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/fbce591b-0d29-4ee3-af5c-6cf48831637f.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T163752Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=c98383d4e66a656cd186696d42e2dddc3177bb541c0dcc06a69ae96864e565d0', 10722945, NULL, 'lyrics/fce96ae5-8c13-4afd-9be7-805c16240a44.lrc', 43, 0, 0, 1, 14, 12, 0, '2026-03-12 00:37:53', '2026-03-12 00:37:53');
INSERT INTO `tracks` VALUES (78, '夏婉安 - 一个人', '夏婉安', NULL, 194, 0, 'audio/mpeg', 'music/4c305b8d-81bc-4a5b-b949-5ffaec4fd181.mp3', 'cover/db2a2753-3962-4361-896d-6fd2369315c4.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/db2a2753-3962-4361-896d-6fd2369315c4.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T163813Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=1e8b1a341d89f1f97a776f47d906b370c4b2b9c114757393f9be503b5b4122b3', 7765546, NULL, 'lyrics/98cc22c3-63a3-4edf-8121-efc95bd86310.lrc', 43, 0, 0, 1, 14, 12, 0, '2026-03-12 00:38:13', '2026-03-12 14:48:15');
INSERT INTO `tracks` VALUES (79, 'リセット', '向井太一', '强风吹拂', 250, 0, 'audio/mpeg', 'music/418bafb0-2a51-4723-93ff-671533669980.mp3', 'cover/d24e655d-04a1-432d-991c-e7d290e8da7f.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/d24e655d-04a1-432d-991c-e7d290e8da7f.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T163950Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=333123622b5af9691f6444b57c9c3bbf16900ac2e47bc4cd385850df39ede049', 9996738, NULL, 'lyrics/7ed90ff5-3b73-451f-a1a1-fcccf254a365.lrc', 44, 0, 0, 1, 14, 9, 0, '2026-03-12 00:39:50', '2026-03-12 00:39:50');
INSERT INTO `tracks` VALUES (80, '鸽子', '徐秉龙', NULL, 138, 0, 'audio/mpeg', 'music/c6d4cd2b-42de-4833-bc07-3b541235a562.mp3', 'cover/8a9afd36-3e6b-42a4-9c44-d1fb52f43ea1.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/8a9afd36-3e6b-42a4-9c44-d1fb52f43ea1.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T164226Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=05c5f40dc118868eb7790153da9e8d2bb1d546f5753b25662db03c15fa00a5bf', 5522475, NULL, 'lyrics/90237d60-7f5d-4b0b-9b07-8b7eae6b3936.lrc', 17, 0, 0, 1, 14, 12, 0, '2026-03-12 00:42:26', '2026-03-12 00:42:26');
INSERT INTO `tracks` VALUES (81, '千禧', '徐秉龙', NULL, 199, 0, 'audio/mpeg', 'music/d4181672-71ca-4e38-a4bc-ffcbf8403fbb.mp3', 'cover/ab3f8da4-b9cb-496c-899a-fca46e787f7b.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/ab3f8da4-b9cb-496c-899a-fca46e787f7b.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T164311Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=a1c674b79db572e0510efd4e02a68127e01cf0cf72ee529a3c2c2eb86adfdf85', 7964402, NULL, 'lyrics/1963531f-4c3b-4a36-9d74-635f6b0391b1.lrc', 17, 0, 0, 1, 14, 12, 0, '2026-03-12 00:43:12', '2026-03-12 00:43:12');
INSERT INTO `tracks` VALUES (82, '拥抱', '徐秉龙', NULL, 186, 0, 'audio/mpeg', 'music/843000d9-0e27-4d4b-9dbb-f7f6bb91b68e.mp3', 'cover/7b5d258c-fa20-45fe-b0a9-39581f8e8340.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/7b5d258c-fa20-45fe-b0a9-39581f8e8340.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T164343Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=f614081242c7ac1a717e8caa79ae279f808d7c4418336a1aae99bddd542e8b7c', 7434639, NULL, 'lyrics/9cc31341-e6f4-465d-a672-7458a8341406.lrc', 17, 0, 0, 1, 14, 12, 0, '2026-03-12 00:43:43', '2026-03-12 00:43:43');
INSERT INTO `tracks` VALUES (83, '心事', '徐秉龙', NULL, 224, 0, 'audio/mpeg', 'music/2451743c-faf8-4d32-a4b3-a9f03d7cff42.mp3', 'cover/a64702c9-b4e0-48ff-9832-b13e9dcee7d6.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/a64702c9-b4e0-48ff-9832-b13e9dcee7d6.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T164405Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=457840f057d80fbb510a8cad4a2d0b926dc119032ffa1a3b7963c0045dc88618', 8962279, NULL, 'lyrics/78b8f682-eb5a-4f6d-987e-9f7556122623.lrc', 17, 0, 0, 1, 14, 12, 0, '2026-03-12 00:44:05', '2026-03-12 00:44:05');
INSERT INTO `tracks` VALUES (84, '坏女孩', '徐良', NULL, 242, 0, 'audio/mpeg', 'music/24e6e6cd-d528-4f3a-86f4-145032273930.mp3', 'cover/d6a47313-094c-4e67-93b9-a9bb3ed68df2.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/d6a47313-094c-4e67-93b9-a9bb3ed68df2.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T164518Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=fccdb7b6f34ebb56c898fc33a9191840ec35ac11aea46075b8679183610f6553', 9699985, NULL, 'lyrics/3da979ca-5297-4201-b533-38b0afc90cce.lrc', 15, 0, 0, 1, 14, 11, 0, '2026-03-12 00:45:19', '2026-03-12 00:45:19');
INSERT INTO `tracks` VALUES (85, '那时雨', '徐良', NULL, 214, 0, 'audio/mpeg', 'music/305256f7-430a-4db9-9386-492e3ccb0807.mp3', 'cover/c7f2b1a2-9cb0-4331-9ef0-1bb3d6ac25cc.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/c7f2b1a2-9cb0-4331-9ef0-1bb3d6ac25cc.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T164551Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=6a202d68efffca8d2d5d7f8d89ba38e3660d15ef2b37fce89a36928083460559', 8578804, NULL, 'lyrics/87fccab4-a8c8-4630-beb4-d5022ce868fb.lrc', 15, 0, 0, 1, 14, 11, 0, '2026-03-12 00:45:51', '2026-03-12 00:45:51');
INSERT INTO `tracks` VALUES (86, '玫瑰花的葬礼', '许嵩', NULL, 259, 0, 'audio/mpeg', 'music/a9e9b2fd-2921-4ac1-beba-f4c17126938a.mp3', 'cover/aa04c462-2d38-4cf5-b21f-09f1f41bb9a4.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/aa04c462-2d38-4cf5-b21f-09f1f41bb9a4.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T164759Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=298c484046e07ddde895afd233af82cfb6e967e06d69ca650801de3d76e7bcb0', 10359312, NULL, 'lyrics/70b997ea-a77f-4795-9e8e-a6266b43332b.lrc', 16, 0, 0, 1, 14, 12, 0, '2026-03-12 00:48:00', '2026-03-12 00:48:00');
INSERT INTO `tracks` VALUES (87, '清明雨上', '许嵩', NULL, 220, 0, 'audio/mpeg', 'music/0105a007-b401-41e6-a587-706e9f74785b.mp3', 'cover/b507fe44-d96f-4e85-88fc-7f07e5b0e3df.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/b507fe44-d96f-4e85-88fc-7f07e5b0e3df.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T164830Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=f25a21bb99ff2631abc95844fdd613f304931a62f00bf99e0d71c1d576528f54', 8797198, NULL, 'lyrics/d1b8a792-0717-496d-af7a-cb43a69da751.lrc', 16, 1, 0, 1, 14, 11, 0, '2026-03-12 00:48:31', '2026-03-12 03:13:39');
INSERT INTO `tracks` VALUES (88, '雅俗共赏', '许嵩', NULL, 250, 0, 'audio/mpeg', 'music/162b3987-cc07-4e7a-8b96-3f58e2dc0d40.mp3', 'cover/c7e479c5-e726-42b3-abda-da4d40eb9197.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/c7e479c5-e726-42b3-abda-da4d40eb9197.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T164935Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=23138e6f93f8b3602b2b2af23b2883231d0162efc81c691d52a0357978b82e09', 9986891, NULL, 'lyrics/b1d1b21e-2ff1-47e9-b3b0-b5447ebe6bd8.lrc', 16, 1, 0, 1, 14, 11, 0, '2026-03-12 00:49:36', '2026-03-13 15:39:39');
INSERT INTO `tracks` VALUES (89, '有何不可', '许嵩', NULL, 242, 0, 'audio/mpeg', 'music/1f7a53fb-61c4-4c54-8bd2-cf3299a068ff.mp3', 'cover/245c772e-5c32-4672-bae0-489aaf03a73a.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/245c772e-5c32-4672-bae0-489aaf03a73a.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T165052Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=081f9cc861d83839571a00e86148ff25fe7beeb29efe4f81368193e698168fa3', 9675882, NULL, 'lyrics/846f101c-ffa0-4339-8740-4f2c30a412a9.lrc', 16, 0, 0, 1, 14, 11, 0, '2026-03-12 00:50:53', '2026-03-12 00:50:53');
INSERT INTO `tracks` VALUES (90, 'Call of Silence', '澤野弘之', '进击的巨人', 178, 0, 'audio/mpeg', 'music/72e4cecc-167d-44d9-9b26-d92616b36dbf.mp3', 'cover/81336e8f-1411-4ea5-9a27-88daf4ea1441.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/81336e8f-1411-4ea5-9a27-88daf4ea1441.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T165243Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=b7be7d45e59a133a42fc7ad89e559caabc67d38bf7d070c08c9b05e887482a49', 7131710, NULL, 'lyrics/78023220-6bac-4e94-848e-47a632b18d44.lrc', 6, 2, 0, 1, 14, 9, 0, '2026-03-12 00:52:44', '2026-03-14 22:01:18');
INSERT INTO `tracks` VALUES (91, '偏爱', '张芸京', '仙剑奇侠传', 213, 0, 'audio/mpeg', 'music/e0fe362f-b3de-4a80-ae8b-5e9f2a8e7272.mp3', 'cover/70df50c7-c9cd-4c35-a4a2-cde55fec66e1.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/70df50c7-c9cd-4c35-a4a2-cde55fec66e1.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260311%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260311T165458Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=5697f51ae9f45b53303fa4641d4c0c6d9758834061d2d26aeb618fe9ea8bc01c', 8519245, NULL, 'lyrics/16bd7fea-af42-49a0-8824-dbab7d9cbe1e.lrc', 22, 0, 1, 1, 14, 12, 0, '2026-03-12 00:54:58', '2026-03-12 15:25:25');
INSERT INTO `tracks` VALUES (92, '可不可以', '张紫豪', '', 241, 0, 'audio/mpeg', 'music/03af591c-3512-4886-9645-860a23e1f54b.mp3', 'cover/df8b6d49-e117-4949-bd53-b73e67b27a29.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/df8b6d49-e117-4949-bd53-b73e67b27a29.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260312%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260312T073929Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=9520fa85c4cdb9d81c0cd008a421473d6bb31a54c50f50f08dc235b910fa9909', 9638336, '[00:00.00] \r\n[ti:可不可以]\r\n[ar:张紫豪]\r\n[al:可不可以]\r\n[by:]\r\n[offset:0]\r\n[00:00.43]可不可以 - 张紫豪\r\n[00:01.67]词：刘伟锋\r\n[00:02.32]曲：刘伟锋\r\n[00:03.08]编曲：刘伟锋\r\n[00:03.83]录制混缩：巨人先生\r\n[00:05.01]出品：西亚斯音频工作室\r\n[00:06.55]企划：谭梦\r\n[00:07.17]发行公司：恬音文化\r\n[00:16.50]说好带你流浪\r\n[00:20.09]而我却半路返航\r\n[00:23.62]坠落自责的海洋\r\n[00:30.72]发现离不开你\r\n[00:34.21]我开始决定回去\r\n[00:37.80]你已不在原地\r\n[00:44.02]我可以接受你的所有\r\n[00:46.16]所有小脾气\r\n[00:47.54]我可以带你去吃很多\r\n[00:49.73]很多好东西\r\n[00:51.13]我可以偶尔给你带来\r\n[00:53.24]带来小甜蜜\r\n[00:54.65]就像前几年那样\r\n[00:56.05]每天都会给你制造很多惊喜\r\n[00:58.73]你的心伤 我能治愈\r\n[01:01.80]我的快乐也只有你能给予\r\n[01:06.26]我们就别再分离\r\n[01:11.73]可不可以 和你在一起\r\n[01:15.30]我们之间有太多回忆\r\n[01:18.82]爱上了你 没什么道理\r\n[01:22.31]只是刚好情窦初开遇到你\r\n[01:25.82]不希望我的未来不是你\r\n[01:29.44]只愿意和你永远不分离\r\n[01:33.03]趁我还没有过保质期\r\n[01:36.59]趁你还愿意\r\n[02:10.34]三年的回忆\r\n[02:13.82]我如何抹去\r\n[02:17.42]能不能再拾起\r\n[02:24.53]永远在一起\r\n[02:28.08]还没有过期\r\n[02:31.64]我们就别再分离\r\n[02:37.23]可不可以 和你在一起\r\n[02:40.44]我们之间有太多回忆\r\n[02:44.33]爱上了你 没什么道理\r\n[02:47.72]只是刚好情窦初开遇到你\r\n[02:51.29]不希望我的未来不是你\r\n[02:54.79]只愿意和你永远不分离\r\n[02:58.36]趁我还没有过保质期\r\n[03:01.91]趁你还愿意\r\n[03:05.34]可不可以 和你在一起\r\n[03:09.10]我们之间有太多回忆\r\n[03:12.57]爱上了你 没什么道理\r\n[03:16.01]只是刚好情窦初开遇到你\r\n[03:19.63]不希望我的未来不是你\r\n[03:23.28]只愿意和你永远不分离\r\n[03:26.79]趁我还没有过保质期\r\n[03:30.29]趁你还愿意\r\n[03:33.92]趁我还没有过保质期\r\n[03:41.23]趁你还愿意\r\n', 'lyrics/e8c31b50-8abc-41fe-83b1-9cbb4b12f691.lrc', 24, 1, 1, 1, 14, 11, 0, '2026-03-12 00:56:02', '2026-03-13 15:24:58');
INSERT INTO `tracks` VALUES (93, '冬眠', '司南', '冬眠', 270, 0, 'audio/flac', 'music/7d26ab39-1103-40b8-ae51-a343de3ab0a5.flac', 'cover/584a16e4-5fa6-4bfc-a855-5f518d908bbd.jpg', 'http://127.0.0.1:9000/yinbomusic/cover/584a16e4-5fa6-4bfc-a855-5f518d908bbd.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20260314%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20260314T121620Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=8b9c238383ed846a111a1081be895f969537ba05a351c7276ccd9f7fdd7a364e', 26213182, '[00:00.00] \r\n[ti:冬眠]\r\n[ar:司南]\r\n[al:冬眠]\r\n[by:]\r\n[offset:0]\r\n[00:00.08]冬眠 - 司南\r\n[00:01.42]词：桃玖\r\n[00:02.48]曲：CMJ\r\n[00:03.37]编曲：CMJ\r\n[00:04.51]制作人：易泽禹\r\n[00:06.41]吉他：吴海峰\r\n[00:08.16]和声：皎月\r\n[00:09.69]混音/母带工程师：何世渝\r\n[00:13.15]（版权所有，未经许可请勿使用）\r\n[00:35.98]巷口灯光忽明忽灭\r\n[00:43.17]手中甜咖啡已冷却\r\n[00:50.59]嘴角不经意泄露想念\r\n[00:57.91]在发呆的窗前凝结\r\n[01:05.33]其实不爱漫漫长夜\r\n[01:12.73]因为你才多了情结\r\n[01:20.10]可是蜷缩的回忆不热烈\r\n[01:27.52]我如何把孤单融解\r\n[01:33.08]你看啊春日的蝴蝶\r\n[01:36.64]你看它颤抖着飞越\r\n[01:40.33]和风与暖阳倾斜\r\n[01:43.60]却冰冷 的季节\r\n[01:47.79]你看啊仲夏的弯月\r\n[01:51.44]你看它把欢愉偷窃\r\n[01:56.51]倒挂天际的笑靥\r\n[02:33.94]故事里的最后一页\r\n[02:41.32]过往和光阴都重叠\r\n[02:48.71]我用尽所有字眼去描写\r\n[02:56.20]无法留你片刻停歇\r\n[03:01.93]你听啊秋末的落叶\r\n[03:05.23]你听它叹息着离别\r\n[03:08.95]只剩我独自领略\r\n[03:12.19]海与山 风和月\r\n[03:16.38]你听啊冬至的白雪\r\n[03:19.99]你听它掩饰着哽咽\r\n[03:25.16]在没有你的世界\r\n[03:31.11]你听啊秋末的落叶\r\n[03:34.78]你听它叹息着离别\r\n[03:38.47]只剩我独自领略\r\n[03:41.72]海与山 风和月\r\n[03:45.87]你听啊冬至的白雪\r\n[03:49.54]你听它掩饰着哽咽\r\n[03:54.72]在没有你的世界\r\n[04:01.93]再没有你的冬眠\r\n', 'lyrics/faba7922-9f48-4b1f-a980-8e7d20b48450.lrc', 45, 0, 0, 1, 14, 11, 0, '2026-03-14 20:16:21', '2026-03-14 20:16:21');

-- ----------------------------
-- Table structure for user_activities
-- ----------------------------
DROP TABLE IF EXISTS `user_activities`;
CREATE TABLE `user_activities`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `action_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_id` bigint NULL DEFAULT NULL,
  `target_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_time`(`user_id` ASC, `created_at` DESC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_activities
-- ----------------------------

-- ----------------------------
-- Table structure for user_follows
-- ----------------------------
DROP TABLE IF EXISTS `user_follows`;
CREATE TABLE `user_follows`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `follower_id` bigint NOT NULL,
  `following_id` bigint NOT NULL,
  `created_at` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_follow`(`follower_id` ASC, `following_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_follows
-- ----------------------------
INSERT INTO `user_follows` VALUES (1, 15, 13, '2026-03-11 01:49:07');
INSERT INTO `user_follows` VALUES (4, 16, 15, '2026-03-12 03:14:12');
INSERT INTO `user_follows` VALUES (5, 15, 16, '2026-03-12 03:26:32');
INSERT INTO `user_follows` VALUES (6, 13, 16, '2026-03-12 03:29:39');
INSERT INTO `user_follows` VALUES (7, 16, 13, '2026-03-12 03:31:57');
INSERT INTO `user_follows` VALUES (9, 13, 15, '2026-03-14 21:54:16');

-- ----------------------------
-- Table structure for user_privacy
-- ----------------------------
DROP TABLE IF EXISTS `user_privacy`;
CREATE TABLE `user_privacy`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `history_visible` tinyint NULL DEFAULT 1 COMMENT '1=public 0=private',
  `favorites_visible` tinyint NULL DEFAULT 1,
  `follows_visible` tinyint NULL DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `user_id`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_privacy
-- ----------------------------

-- ----------------------------
-- Table structure for users
-- ----------------------------
-- 若旧库曾含 phone 列，可执行：ALTER TABLE users DROP INDEX uk_users_phone; ALTER TABLE users DROP COLUMN phone;
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USER',
  `avatar` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `signature` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `gender` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'male/female/other',
  `birthday` date NULL DEFAULT NULL COMMENT 'Birthday',
  `region` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'Region',
  `status` tinyint NOT NULL DEFAULT 0,
  `deleted` tinyint NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE,
  INDEX `idx_username`(`username` ASC) USING BTREE,
  INDEX `idx_email`(`email` ASC) USING BTREE,
  INDEX `idx_role`(`role` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (13, 'axc123456', 'admin1@yinbo.cm', '$2a$10$nklwEMRoCXww.5l6ijN8W.5tndGSlWNAmbsB6fMBduNXXwsI9/M5q', 'USER', 'avatar/dc88ab53-49b4-4612-8e01-510028e17082.jpg', '带土', '琳', 'male', '2003-02-07', '火之国', 0, 0, '2026-03-07 20:50:19', '2026-03-07 20:50:19');
INSERT INTO `users` VALUES (14, 'admin1', 'admin1@yinbo.com', '$2a$10$PWvZw2MMnwB3BZYEGQCfHurXiopsR2sxnm9nojTnnGJJ5SAia.PHi', 'ADMIN', 'avatar/03932372-6fff-450b-ba87-48953e3e6128.jpg', 'admin1', NULL, NULL, NULL, NULL, 0, 0, '2026-03-07 20:51:44', '2026-03-07 20:51:44');
INSERT INTO `users` VALUES (15, 'as123456', 'as123456@yinbo.com', '$2a$10$LoofNTyRZOOrg6lmkylXZu6e7KAlWTvIJsbcjDbtw33KMw2xFbO72', 'USER', 'avatar/bd4def4f-941d-4218-a39f-9aafeae29d5d.jpg', '野原新之助', '春野部幼儿园', 'male', '2020-05-05', '日本琦玉', 0, 0, '2026-03-08 15:38:19', '2026-03-08 15:38:19');
INSERT INTO `users` VALUES (16, 'Xmgz1120', 'Xmgz1120@yinbo.com', '$2a$10$hv4clYEFdrAvAKUwzt/hpOrEzCeJFmEOOSTe/FQ/5kLWK6gBoumQS', 'USER', 'avatar/64d5237c-9997-4e2a-ad51-da4996a7227d.jpg', '夏目贵志', '这里是夏目', 'male', '2002-11-01', '日本', 0, 0, '2026-03-12 02:38:19', '2026-03-14 19:51:43');

SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------
-- （可选）迁移：拼音检索列 / 楼中楼评论
-- 仅执行下面一段时请先：USE `yinbo_music`;
-- 列已存在会报错，删掉对应 ALTER 行即可。当前后端未强制依赖这些列。
-- ----------------------------
-- USE `yinbo_music`;
-- ALTER TABLE `tracks` ADD COLUMN `search_norm` varchar(2000) NULL DEFAULT NULL COMMENT '检索：原文+拼音+首字母' AFTER `category_id`;
-- ALTER TABLE `singers` ADD COLUMN `search_norm` varchar(1000) NULL DEFAULT NULL COMMENT '检索：歌手名拼音' AFTER `description`;
-- ALTER TABLE `comments` ADD COLUMN `root_comment_id` bigint NULL DEFAULT NULL COMMENT '楼层根评论ID' AFTER `parent_id`;
-- ALTER TABLE `comments` ADD COLUMN `reply_to_user_id` bigint NULL DEFAULT NULL COMMENT '被回复用户' AFTER `root_comment_id`;
-- ALTER TABLE `comments` ADD INDEX `idx_comments_root`(`root_comment_id`);
-- UPDATE `comments` SET `root_comment_id` = `id` WHERE `parent_id` IS NULL;
-- UPDATE `comments` `c` INNER JOIN `comments` `p` ON `c`.`parent_id` = `p`.`id` SET `c`.`root_comment_id` = COALESCE(`p`.`root_comment_id`, `p`.`id`) WHERE `c`.`parent_id` IS NOT NULL;
-- UPDATE `comments` `c` INNER JOIN `comments` `p` ON `c`.`parent_id` = `p`.`id` SET `c`.`root_comment_id` = COALESCE(`p`.`root_comment_id`, `p`.`id`) WHERE `c`.`parent_id` IS NOT NULL;

