/*
Navicat MySQL Data Transfer

Source Server         : localhost_3306
Source Server Version : 80037
Source Host           : localhost:3306
Source Database       : green_pencil

Target Server Type    : MYSQL
Target Server Version : 80037
File Encoding         : 65001

Date: 2025-04-19 11:44:08
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for authority
-- ----------------------------
DROP TABLE IF EXISTS `authority`;
CREATE TABLE `authority` (
  `id` int NOT NULL AUTO_INCREMENT,
  `authority` varchar(200) DEFAULT NULL COMMENT '权限',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of authority
-- ----------------------------
INSERT INTO `authority` VALUES ('1', 'ROLE_admin');
INSERT INTO `authority` VALUES ('2', 'ROLE_common');

-- ----------------------------
-- Table structure for comments
-- ----------------------------
DROP TABLE IF EXISTS `comments`;
CREATE TABLE `comments` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '评论唯一标识，自增长整数',
  `user_id` int NOT NULL COMMENT '评论用户的 ID，外键关联 users 表的 id 字段',
  `post_id` int NOT NULL COMMENT '被评论的内容 ID，外键关联 posts 表的 id 字段',
  `parent_comment_id` int DEFAULT NULL COMMENT '如果是回复评论，关联父评论的 ID，可为 NULL',
  `reply_to_user_id` int DEFAULT NULL COMMENT '回复的目标用户ID',
  `comment_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '评论内容',
  `comment_date` datetime NOT NULL COMMENT '评论日期',
  PRIMARY KEY (`id`),
  KEY `fk_comments_user_id` (`user_id`),
  KEY `fk_comments_post_id` (`post_id`),
  KEY `fk_comments_parent_comment_id` (`parent_comment_id`),
  KEY `fk_comments_reply_to_user_id` (`reply_to_user_id`),
  CONSTRAINT `fk_comments_parent_comment_id` FOREIGN KEY (`parent_comment_id`) REFERENCES `comments` (`id`),
  CONSTRAINT `fk_comments_post_id` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`),
  CONSTRAINT `fk_comments_reply_to_user_id` FOREIGN KEY (`reply_to_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_comments_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='存储用户对内容的评论';

-- ----------------------------
-- Records of comments
-- ----------------------------
INSERT INTO `comments` VALUES ('1', '1', '1', null, null, '很棒的分享！', '2025-03-24 14:00:00');
INSERT INTO `comments` VALUES ('2', '2', '1', '1', '1', '确实很有启发。', '2025-03-24 14:05:00');
INSERT INTO `comments` VALUES ('3', '3', '2', null, null, '学习了，谢谢！', '2025-03-24 14:10:00');
INSERT INTO `comments` VALUES ('4', '4', '2', '3', '3', '期待更多分享。', '2025-03-24 14:15:00');
INSERT INTO `comments` VALUES ('5', '5', '3', null, null, '风景真美！', '2025-03-24 14:20:00');
INSERT INTO `comments` VALUES ('6', '6', '3', '5', '5', '好想也去看看。', '2025-03-24 14:25:00');
INSERT INTO `comments` VALUES ('7', '7', '4', null, null, '评测很专业。', '2025-03-24 14:30:00');
INSERT INTO `comments` VALUES ('8', '8', '4', '7', '7', '有参考价值。', '2025-03-24 14:35:00');
INSERT INTO `comments` VALUES ('9', '9', '5', null, null, '技巧很实用。', '2025-03-24 14:40:00');
INSERT INTO `comments` VALUES ('10', '10', '5', '9', '9', '感谢分享。', '2025-03-24 14:45:00');
INSERT INTO `comments` VALUES ('11', '11', '6', null, null, '蛋糕看起来很好吃。', '2025-03-24 14:50:00');
INSERT INTO `comments` VALUES ('12', '12', '6', '11', '11', '我要试试。', '2025-03-24 14:55:00');
INSERT INTO `comments` VALUES ('56', '1', '1', null, null, '看起来好好吃', '2025-04-05 18:55:18');
INSERT INTO `comments` VALUES ('57', '1', '1', '56', '1', '确实好吃，我吃吃吃\n', '2025-04-05 18:55:27');
INSERT INTO `comments` VALUES ('61', '1', '1', '1', '2', '1', '2025-04-18 09:35:51');
INSERT INTO `comments` VALUES ('62', '1', '1', '56', '1', '是啊', '2025-04-18 09:48:10');
INSERT INTO `comments` VALUES ('63', '1', '13', null, null, '99\n', '2025-04-18 18:45:51');
INSERT INTO `comments` VALUES ('65', '1', '13', '63', '1', '12', '2025-04-18 18:50:52');

-- ----------------------------
-- Table structure for favorites
-- ----------------------------
DROP TABLE IF EXISTS `favorites`;
CREATE TABLE `favorites` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '收藏记录唯一标识，自增长整数',
  `user_id` int NOT NULL COMMENT '收藏用户的 ID，外键关联 users 表的 id 字段',
  `post_id` int NOT NULL COMMENT '被收藏的内容 ID，外键关联 posts 表的 id 字段',
  `favorite_date` datetime NOT NULL COMMENT '收藏日期',
  PRIMARY KEY (`id`),
  KEY `fk_favorites_user_id` (`user_id`),
  KEY `fk_favorites_post_id` (`post_id`),
  CONSTRAINT `fk_favorites_post_id` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`),
  CONSTRAINT `fk_favorites_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='记录用户收藏的内容';

-- ----------------------------
-- Records of favorites
-- ----------------------------
INSERT INTO `favorites` VALUES ('1', '1', '1', '2025-03-24 14:00:00');
INSERT INTO `favorites` VALUES ('2', '2', '2', '2025-03-24 14:05:00');
INSERT INTO `favorites` VALUES ('3', '3', '3', '2025-03-24 14:10:00');
INSERT INTO `favorites` VALUES ('4', '4', '4', '2025-03-24 14:15:00');
INSERT INTO `favorites` VALUES ('5', '5', '5', '2025-03-24 14:20:00');
INSERT INTO `favorites` VALUES ('6', '6', '6', '2025-03-24 14:25:00');
INSERT INTO `favorites` VALUES ('7', '7', '7', '2025-03-24 14:30:00');
INSERT INTO `favorites` VALUES ('8', '8', '8', '2025-03-24 14:35:00');
INSERT INTO `favorites` VALUES ('9', '9', '9', '2025-03-24 14:40:00');
INSERT INTO `favorites` VALUES ('10', '10', '10', '2025-03-24 14:45:00');
INSERT INTO `favorites` VALUES ('11', '11', '11', '2025-03-24 14:50:00');
INSERT INTO `favorites` VALUES ('12', '12', '12', '2025-03-24 14:55:00');

-- ----------------------------
-- Table structure for images
-- ----------------------------
DROP TABLE IF EXISTS `images`;
CREATE TABLE `images` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '图片唯一标识，自增长整数',
  `post_id` int DEFAULT NULL COMMENT '关联的帖子 ID，外键关联 posts 表的 id 字段',
  `user_id` int DEFAULT NULL COMMENT '关联的用户 ID，外键关联 users 表的 id 字段',
  `section_id` int DEFAULT NULL COMMENT '关联的分区 ID，外键关联 sections 表的 id 字段',
  `comment_id` int DEFAULT NULL COMMENT '关联的评论 ID，外键关联 comments 表的 id 字段',
  `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '图片的 URL',
  PRIMARY KEY (`id`),
  KEY `fk_images_post_id` (`post_id`),
  KEY `fk_images_user_id` (`user_id`),
  KEY `fk_images_section_id` (`section_id`),
  KEY `fk_images_comment_id` (`comment_id`),
  CONSTRAINT `fk_images_comment_id` FOREIGN KEY (`comment_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_images_post_id` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_images_section_id` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_images_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='存储所有图片信息';

-- ----------------------------
-- Records of images
-- ----------------------------
INSERT INTO `images` VALUES ('1', '1', null, '1', null, 'https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/6224af7e-0075-4a72-9c42-70337e739370.png');
INSERT INTO `images` VALUES ('2', '2', null, '2', null, 'https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/411210f6-0f8f-4146-bcb0-3e9e44152585.jpg');
INSERT INTO `images` VALUES ('3', '3', null, '3', null, 'https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/558ac8e5-0c13-4bdf-9555-01787dc57f32.jpg');
INSERT INTO `images` VALUES ('4', '4', null, '4', null, 'https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/3050aae5-0eb3-4e62-85a9-6089ae676ba3.jpg');
INSERT INTO `images` VALUES ('5', '5', null, '5', null, 'https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/cda39236-4584-4e35-8e30-5877c442fb33.jpg');
INSERT INTO `images` VALUES ('6', '6', null, '6', null, 'https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/203151aa-791e-4097-9674-d07200507467.jpg');
INSERT INTO `images` VALUES ('7', '7', null, '7', null, 'https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/1019cca8-c00f-4a41-a292-b9d265a1da44.jpg');
INSERT INTO `images` VALUES ('8', '8', null, '8', null, 'https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/82cfe2eb-d7a6-4946-b8e4-61a5be1376bb.jpg');
INSERT INTO `images` VALUES ('9', '9', null, '9', null, 'https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/d0fb4bd0-20c2-44ca-a99c-1f0be6e73072.jpg');
INSERT INTO `images` VALUES ('10', '10', null, '10', null, 'https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/bf1433e7-9f45-4ca6-9f84-58df01e0a6fd.jpeg');
INSERT INTO `images` VALUES ('11', '11', null, '11', null, 'https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/01a3ea24-bd37-4c4e-9523-d8c87a996f24.jpg');
INSERT INTO `images` VALUES ('12', '12', null, '12', null, 'https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/e911313e-b0cc-4310-b2ba-82c4d50340e4.jpg');
INSERT INTO `images` VALUES ('13', null, null, null, null, 'https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/1.jpg');
INSERT INTO `images` VALUES ('14', '1', null, null, null, 'https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/ea199571-1923-4a79-b1c2-00bef04c1898.png');
INSERT INTO `images` VALUES ('15', '1', null, null, null, 'https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/da5e4611-e275-4001-8714-26a4ff265988.png');
INSERT INTO `images` VALUES ('16', '13', null, null, null, 'https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/50fe3b6e-638e-4ad4-9f34-2642e69c73bc.png');
INSERT INTO `images` VALUES ('18', null, '1', null, null, 'https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/a460b5de-f76f-4ea3-ad83-3412cbfc6c01.jpg');
INSERT INTO `images` VALUES ('19', '14', null, null, null, 'https://blackbox-web.oss-cn-wuhan-lr.aliyuncs.com/e1612e09-dfdb-4f03-b819-8073f09163cd.jpg');

-- ----------------------------
-- Table structure for likes
-- ----------------------------
DROP TABLE IF EXISTS `likes`;
CREATE TABLE `likes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `post_id` int NOT NULL,
  `like_date` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_post_idx` (`user_id`,`post_id`),
  KEY `post_id` (`post_id`),
  CONSTRAINT `likes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `likes_ibfk_2` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of likes
-- ----------------------------
INSERT INTO `likes` VALUES ('12', '1', '13', '2025-04-18 18:45:44');
INSERT INTO `likes` VALUES ('16', '2', '13', '2025-04-19 09:00:30');
INSERT INTO `likes` VALUES ('18', '2', '14', '2025-04-19 09:30:01');

-- ----------------------------
-- Table structure for messages
-- ----------------------------
DROP TABLE IF EXISTS `messages`;
CREATE TABLE `messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sender_id` int NOT NULL COMMENT '发送者ID',
  `receiver_id` int NOT NULL COMMENT '接收者ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '消息内容',
  `send_time` datetime NOT NULL COMMENT '发送时间',
  `is_read` tinyint(1) DEFAULT '0' COMMENT '是否已读',
  `attachment_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '附件URL',
  `attachment_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '附件名称',
  `attachment_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '附件类型，如file或image',
  `reference_post_id` int DEFAULT NULL COMMENT '转发的帖子ID',
  PRIMARY KEY (`id`),
  KEY `fk_messages_sender_id` (`sender_id`),
  KEY `fk_messages_receiver_id` (`receiver_id`),
  KEY `fk_messages_reference_post_id` (`reference_post_id`),
  CONSTRAINT `fk_messages_receiver_id` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_messages_reference_post_id` FOREIGN KEY (`reference_post_id`) REFERENCES `posts` (`id`),
  CONSTRAINT `fk_messages_sender_id` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户私信表';

-- ----------------------------
-- Records of messages
-- ----------------------------

-- ----------------------------
-- Table structure for posts
-- ----------------------------
DROP TABLE IF EXISTS `posts`;
CREATE TABLE `posts` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '内容唯一标识，自增长整数',
  `user_id` int NOT NULL COMMENT '发布内容的用户 ID，外键关联 users 表的 id 字段',
  `section_id` int DEFAULT NULL COMMENT '关联分区ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '内容标题',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '内容正文',
  `post_date` datetime NOT NULL COMMENT '发布日期',
  `likes_count` int DEFAULT '0' COMMENT '点赞数，初始值为 0',
  `comments_count` int DEFAULT '0' COMMENT '评论数，初始值为 0',
  `views` int NOT NULL DEFAULT '0' COMMENT '浏览量',
  PRIMARY KEY (`id`),
  KEY `fk_posts_user_id` (`user_id`),
  KEY `fk_posts_section_id` (`section_id`),
  CONSTRAINT `fk_posts_section_id` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`),
  CONSTRAINT `fk_posts_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='记录用户发布的游戏相关内容（如文章、攻略等）';

-- ----------------------------
-- Records of posts
-- ----------------------------
INSERT INTO `posts` VALUES ('1', '1', '1', '晨跑新体验', '今天晨跑感觉棒极了，分享下感受。', '2025-03-24 12:00:00', '10', '2', '1');
INSERT INTO `posts` VALUES ('2', '2', '2', '高效学习秘籍', '分享几个高效学习的方法。', '2025-03-24 12:10:00', '15', '2', '0');
INSERT INTO `posts` VALUES ('3', '3', '3', '巴黎之旅', '记录在巴黎的美好时光。', '2025-03-24 12:20:00', '20', '2', '0');
INSERT INTO `posts` VALUES ('4', '4', '4', '新手机评测', '对新款手机的详细评测。', '2025-03-24 12:30:00', '25', '2', '0');
INSERT INTO `posts` VALUES ('5', '5', '5', '职场晋升技巧', '分享职场晋升的一些技巧。', '2025-03-24 12:40:00', '30', '2', '0');
INSERT INTO `posts` VALUES ('6', '6', '6', '美食制作分享', '教你做一道美味的蛋糕。', '2025-03-24 12:50:00', '35', '2', '0');
INSERT INTO `posts` VALUES ('7', '7', '7', '艺术作品欣赏', '欣赏一幅经典的绘画作品。', '2025-03-24 13:00:00', '40', '2', '0');
INSERT INTO `posts` VALUES ('8', '8', '8', '宠物训练方法', '分享一些宠物训练的方法。', '2025-03-24 13:10:00', '45', '2', '0');
INSERT INTO `posts` VALUES ('9', '9', '9', '历史故事解读', '解读一个有趣的历史故事。', '2025-03-24 13:20:00', '50', '2', '1');
INSERT INTO `posts` VALUES ('10', '10', '10', '时尚穿搭指南', '提供一些时尚穿搭的建议。', '2025-03-24 13:30:00', '55', '2', '0');
INSERT INTO `posts` VALUES ('11', '11', '11', '游戏攻略分享', '分享一款热门游戏的攻略。', '2025-03-24 13:40:00', '60', '2', '0');
INSERT INTO `posts` VALUES ('12', '12', '12', '亲子活动推荐', '推荐几个有趣的亲子活动。', '2025-03-24 13:50:00', '65', '2', '2');
INSERT INTO `posts` VALUES ('13', '1', '1', 'test', '1', '2025-04-11 14:17:27', '2', '1', '5');
INSERT INTO `posts` VALUES ('14', '1', '12', 'test1', 'aWDw', '2025-04-18 18:51:23', '1', '0', '3');

-- ----------------------------
-- Table structure for post_analytics_daily
-- ----------------------------
DROP TABLE IF EXISTS `post_analytics_daily`;
CREATE TABLE `post_analytics_daily` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL COMMENT '帖子ID',
  `date` date NOT NULL COMMENT '统计日期',
  `views_count` int DEFAULT '0' COMMENT '当日浏览量',
  `unique_viewers` int DEFAULT '0' COMMENT '当日唯一访客数',
  `total_view_duration` int DEFAULT '0' COMMENT '总浏览时长(秒)',
  `likes_count` int DEFAULT '0' COMMENT '当日新增点赞数',
  `comments_count` int DEFAULT '0' COMMENT '当日新增评论数',
  `shares_count` int DEFAULT '0' COMMENT '当日分享数',
  `favorites_count` int DEFAULT '0' COMMENT '当日收藏数',
  `new_followers_count` int DEFAULT '0' COMMENT '当日新增粉丝数',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_post_date` (`post_id`,`date`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_date` (`date`),
  CONSTRAINT `fk_analytics_post_id` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='帖子每日数据统计表';

-- ----------------------------
-- Records of post_analytics_daily
-- ----------------------------
INSERT INTO `post_analytics_daily` VALUES ('1', '1', '2025-04-19', '1', '0', '0', '10', '2', '0', '1', '0');
INSERT INTO `post_analytics_daily` VALUES ('2', '2', '2025-04-19', '0', '0', '0', '15', '2', '0', '1', '0');
INSERT INTO `post_analytics_daily` VALUES ('3', '3', '2025-04-19', '0', '0', '0', '20', '2', '0', '1', '0');
INSERT INTO `post_analytics_daily` VALUES ('4', '4', '2025-04-19', '0', '0', '0', '25', '2', '0', '1', '0');
INSERT INTO `post_analytics_daily` VALUES ('5', '5', '2025-04-19', '0', '0', '0', '30', '2', '0', '1', '0');
INSERT INTO `post_analytics_daily` VALUES ('6', '6', '2025-04-19', '0', '0', '0', '35', '2', '0', '1', '0');
INSERT INTO `post_analytics_daily` VALUES ('7', '7', '2025-04-19', '0', '0', '0', '40', '2', '0', '1', '0');
INSERT INTO `post_analytics_daily` VALUES ('8', '8', '2025-04-19', '0', '0', '0', '45', '2', '0', '1', '0');
INSERT INTO `post_analytics_daily` VALUES ('9', '9', '2025-04-19', '1', '0', '0', '50', '2', '0', '1', '0');
INSERT INTO `post_analytics_daily` VALUES ('10', '10', '2025-04-19', '0', '0', '0', '55', '2', '0', '1', '0');
INSERT INTO `post_analytics_daily` VALUES ('11', '11', '2025-04-19', '0', '0', '0', '60', '2', '0', '1', '0');
INSERT INTO `post_analytics_daily` VALUES ('12', '12', '2025-04-19', '2', '1', '2', '65', '2', '0', '1', '0');
INSERT INTO `post_analytics_daily` VALUES ('13', '13', '2025-04-19', '5', '1', '2', '2', '1', '0', '0', '0');
INSERT INTO `post_analytics_daily` VALUES ('14', '14', '2025-04-19', '3', '2', '8', '1', '0', '0', '0', '0');

-- ----------------------------
-- Table structure for post_shares
-- ----------------------------
DROP TABLE IF EXISTS `post_shares`;
CREATE TABLE `post_shares` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL COMMENT '被分享的帖子ID',
  `user_id` int NOT NULL COMMENT '分享用户ID',
  `share_platform` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '分享平台',
  `share_time` datetime NOT NULL COMMENT '分享时间',
  PRIMARY KEY (`id`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `fk_shares_post_id` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`),
  CONSTRAINT `fk_shares_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='帖子分享记录表';

-- ----------------------------
-- Records of post_shares
-- ----------------------------

-- ----------------------------
-- Table structure for post_views
-- ----------------------------
DROP TABLE IF EXISTS `post_views`;
CREATE TABLE `post_views` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL COMMENT '被浏览的帖子ID',
  `user_id` int DEFAULT NULL COMMENT '浏览用户ID，未登录用户为NULL',
  `ip_address` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '访问者IP地址',
  `view_time` datetime NOT NULL COMMENT '浏览开始时间',
  `exit_time` datetime DEFAULT NULL COMMENT '浏览结束时间',
  `view_duration` int DEFAULT NULL COMMENT '浏览时长(秒)',
  `device_info` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '设备信息',
  `session_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '会话ID，用于关联view和exit记录',
  `referrer` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '来源页面URL',
  PRIMARY KEY (`id`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_view_time` (`view_time`),
  CONSTRAINT `fk_views_post_id` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`),
  CONSTRAINT `fk_views_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='帖子浏览记录表';

-- ----------------------------
-- Records of post_views
-- ----------------------------
INSERT INTO `post_views` VALUES ('1', '14', '1', '127.0.0.1', '2025-04-18 22:44:27', null, null, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', null, null);
INSERT INTO `post_views` VALUES ('2', '14', '1', '127.0.0.1', '2025-04-18 22:44:37', null, null, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', null, null);
INSERT INTO `post_views` VALUES ('3', '14', '1', '127.0.0.1', '2025-04-18 22:59:18', null, null, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', null, null);
INSERT INTO `post_views` VALUES ('4', '14', '1', '127.0.0.1', '2025-04-18 22:59:38', null, null, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', null, null);
INSERT INTO `post_views` VALUES ('5', '14', '1', '127.0.0.1', '2025-04-18 22:59:39', null, null, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', null, null);
INSERT INTO `post_views` VALUES ('6', '14', '1', '127.0.0.1', '2025-04-18 23:02:09', null, null, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', null, null);
INSERT INTO `post_views` VALUES ('7', '14', '1', '127.0.0.1', '2025-04-18 23:02:20', null, null, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', null, null);
INSERT INTO `post_views` VALUES ('8', '14', '1', '127.0.0.1', '2025-04-18 23:02:20', null, null, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', null, null);
INSERT INTO `post_views` VALUES ('9', '14', '1', '127.0.0.1', '2025-04-18 23:03:21', null, null, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', null, null);
INSERT INTO `post_views` VALUES ('10', '14', '1', '127.0.0.1', '2025-04-18 23:03:26', null, null, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', null, null);
INSERT INTO `post_views` VALUES ('11', '14', '1', '127.0.0.1', '2025-04-18 23:03:26', null, null, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', null, null);
INSERT INTO `post_views` VALUES ('12', '14', '1', '127.0.0.1', '2025-04-18 23:06:30', null, null, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', null, null);
INSERT INTO `post_views` VALUES ('13', '12', '1', '127.0.0.1', '2025-04-18 23:07:22', null, null, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', null, null);
INSERT INTO `post_views` VALUES ('14', '14', '1', '127.0.0.1', '2025-04-18 23:12:50', '2025-04-18 23:12:52', '2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '1744989169945-8857b01qv', null);
INSERT INTO `post_views` VALUES ('15', '14', '1', '127.0.0.1', '2025-04-18 23:12:54', null, null, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '1744989169945-8857b01qv', null);
INSERT INTO `post_views` VALUES ('16', '14', '1', '127.0.0.1', '2025-04-18 23:12:54', '2025-04-18 23:12:57', '2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '1744989169945-8857b01qv', null);
INSERT INTO `post_views` VALUES ('17', '14', '1', '127.0.0.1', '2025-04-19 08:41:53', '2025-04-19 08:41:54', '1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '1745023312754-dw6sukqe6ku', null);
INSERT INTO `post_views` VALUES ('18', '14', '2', '127.0.0.1', '2025-04-19 09:00:25', '2025-04-19 09:00:26', '1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '1745023312754-dw6sukqe6ku', null);
INSERT INTO `post_views` VALUES ('19', '13', '2', '127.0.0.1', '2025-04-19 09:00:29', '2025-04-19 09:00:31', '2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '1745024428516-vzxz7685h9c', null);
INSERT INTO `post_views` VALUES ('20', '14', '2', '127.0.0.1', '2025-04-19 09:00:33', '2025-04-19 09:00:34', '0', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '1745023312754-dw6sukqe6ku', null);
INSERT INTO `post_views` VALUES ('21', '14', '2', '127.0.0.1', '2025-04-19 09:21:51', '2025-04-19 09:21:51', '0', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '1745023312754-dw6sukqe6ku', null);
INSERT INTO `post_views` VALUES ('22', '14', '2', '127.0.0.1', '2025-04-19 09:29:59', null, null, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '1745023312754-dw6sukqe6ku', null);
INSERT INTO `post_views` VALUES ('23', '14', '1', '127.0.0.1', '2025-04-19 09:31:17', '2025-04-19 09:31:19', '2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '1745023312754-dw6sukqe6ku', null);
INSERT INTO `post_views` VALUES ('24', '12', '1', '127.0.0.1', '2025-04-19 09:31:23', '2025-04-19 09:31:26', '2', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0', '1745026282584-und5gm1wm4q', null);

-- ----------------------------
-- Table structure for sections
-- ----------------------------
DROP TABLE IF EXISTS `sections`;
CREATE TABLE `sections` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '分区唯一标识',
  `section_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '分区名称（如攻略、评测、新闻）',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '分区描述',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------
-- Records of sections
-- ----------------------------
INSERT INTO `sections` VALUES ('1', '健康生活', '分享健康饮食、运动健身等生活技巧');
INSERT INTO `sections` VALUES ('2', '学习成长', '学习方法、知识管理、效率提升经验');
INSERT INTO `sections` VALUES ('3', '旅行见闻', '记录旅途中的美景与文化体验');
INSERT INTO `sections` VALUES ('4', '科技前沿', '探讨科技创新与数码产品评测');
INSERT INTO `sections` VALUES ('5', '职场心得', '职场经验、沟通技巧与职业规划');
INSERT INTO `sections` VALUES ('6', '美食天地', '分享各类美食体验和烹饪技巧');
INSERT INTO `sections` VALUES ('7', '艺术鉴赏', '涵盖绘画、音乐、电影等艺术领域的鉴赏');
INSERT INTO `sections` VALUES ('8', '宠物世界', '关于宠物饲养、训练等方面的内容');
INSERT INTO `sections` VALUES ('9', '历史研究', '对历史事件和人物的研究与探讨');
INSERT INTO `sections` VALUES ('10', '时尚潮流', '时尚穿搭、美妆护肤等潮流资讯');
INSERT INTO `sections` VALUES ('11', '游戏天地', '各类游戏攻略、评测和讨论');
INSERT INTO `sections` VALUES ('12', '亲子时光', '亲子活动、教育等相关内容');

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '用户唯一标识，自增长整数',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名，字符串类型，需保证唯一',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户密码，建议使用加密后的字符串存储',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '用户邮箱，可用于找回密码等操作',
  `phone_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '用户电话号码，可选',
  `registration_date` date DEFAULT NULL COMMENT '用户注册日期',
  `last_login_date` datetime DEFAULT NULL COMMENT '用户最后登录日期',
  `image_id` int DEFAULT '13',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `fk_users_image_id` (`image_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用于存储用户的基本信息';

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES ('1', 'zba', '123456', 'user1@example.com', '1234567890', '2025-01-01', '2025-04-19 10:30:29', '18');
INSERT INTO `users` VALUES ('2', 'user2', '123456', 'user2@example.com', '0987654321', '2025-01-02', '2025-04-19 09:21:48', '13');
INSERT INTO `users` VALUES ('3', 'user3', 'password3', 'user3@example.com', '1122334455', '2025-01-03', '2025-03-24 10:20:00', '13');
INSERT INTO `users` VALUES ('4', 'user4', 'password4', 'user4@example.com', '5544332211', '2025-01-04', '2025-03-24 10:30:00', '13');
INSERT INTO `users` VALUES ('5', 'user5', 'password5', 'user5@example.com', '1212121212', '2025-01-05', '2025-03-24 10:40:00', '13');
INSERT INTO `users` VALUES ('6', 'user6', 'password6', 'user6@example.com', '2121212121', '2025-01-06', '2025-03-24 10:50:00', '13');
INSERT INTO `users` VALUES ('7', 'user7', 'password7', 'user7@example.com', '3333444455', '2025-01-07', '2025-03-24 11:00:00', '13');
INSERT INTO `users` VALUES ('8', 'user8', 'password8', 'user8@example.com', '5555444433', '2025-01-08', '2025-03-24 11:10:00', '13');
INSERT INTO `users` VALUES ('9', 'user9', 'password9', 'user9@example.com', '6666777788', '2025-01-09', '2025-03-24 11:20:00', '13');
INSERT INTO `users` VALUES ('10', 'user10', 'password10', 'user10@example.com', '8888777766', '2025-01-10', '2025-03-24 11:30:00', '13');
INSERT INTO `users` VALUES ('11', 'user11', 'password11', 'user11@example.com', '9999000011', '2025-01-11', '2025-03-24 11:40:00', '13');
INSERT INTO `users` VALUES ('12', 'user12', 'password12', 'user12@example.com', '1100998877', '2025-01-12', '2025-03-24 11:50:00', '13');

-- ----------------------------
-- Table structure for user_authority
-- ----------------------------
DROP TABLE IF EXISTS `user_authority`;
CREATE TABLE `user_authority` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL COMMENT '关联的用户id',
  `authority_id` int NOT NULL COMMENT '关联的权限id',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of user_authority
-- ----------------------------
INSERT INTO `user_authority` VALUES ('1', '1', '1');
INSERT INTO `user_authority` VALUES ('2', '2', '2');
INSERT INTO `user_authority` VALUES ('3', '3', '2');
INSERT INTO `user_authority` VALUES ('4', '4', '2');
INSERT INTO `user_authority` VALUES ('5', '5', '2');
INSERT INTO `user_authority` VALUES ('6', '6', '2');
INSERT INTO `user_authority` VALUES ('7', '7', '2');
INSERT INTO `user_authority` VALUES ('8', '8', '2');
INSERT INTO `user_authority` VALUES ('9', '9', '2');
INSERT INTO `user_authority` VALUES ('10', '10', '2');
INSERT INTO `user_authority` VALUES ('11', '11', '2');
INSERT INTO `user_authority` VALUES ('12', '12', '2');

-- ----------------------------
-- Table structure for user_details
-- ----------------------------
DROP TABLE IF EXISTS `user_details`;
CREATE TABLE `user_details` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '详情记录唯一标识，自增长整数',
  `user_id` int NOT NULL COMMENT '关联用户表的用户 ID，外键',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '用户昵称',
  `gender` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '用户性别',
  `bio` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT '用户个人简介',
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `fk_user_details_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='存储用户的详细信息';

-- ----------------------------
-- Records of user_details
-- ----------------------------
INSERT INTO `user_details` VALUES ('1', '1', 'Nick1', 'other', '2');
INSERT INTO `user_details` VALUES ('2', '2', 'Nick2', 'Female', 'This is user2\'s bio.');
INSERT INTO `user_details` VALUES ('3', '3', 'Nick3', 'Male', 'This is user3\'s bio.');
INSERT INTO `user_details` VALUES ('4', '4', 'Nick4', 'Female', 'This is user4\'s bio.');
INSERT INTO `user_details` VALUES ('5', '5', 'Nick5', 'Male', 'This is user5\'s bio.');
INSERT INTO `user_details` VALUES ('6', '6', 'Nick6', 'Female', 'This is user6\'s bio.');
INSERT INTO `user_details` VALUES ('7', '7', 'Nick7', 'Male', 'This is user7\'s bio.');
INSERT INTO `user_details` VALUES ('8', '8', 'Nick8', 'Female', 'This is user8\'s bio.');
INSERT INTO `user_details` VALUES ('9', '9', 'Nick9', 'Male', 'This is user9\'s bio.');
INSERT INTO `user_details` VALUES ('10', '10', 'Nick10', 'Female', 'This is user10\'s bio.');
INSERT INTO `user_details` VALUES ('11', '11', 'Nick11', 'Male', 'This is user11\'s bio.');
INSERT INTO `user_details` VALUES ('12', '12', 'Nick12', 'Female', 'This is user12\'s bio.');

-- ----------------------------
-- Table structure for user_follow_sources
-- ----------------------------
DROP TABLE IF EXISTS `user_follow_sources`;
CREATE TABLE `user_follow_sources` (
  `id` int NOT NULL AUTO_INCREMENT,
  `relationship_id` int NOT NULL COMMENT '关联user_relationships表的ID',
  `source_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '来源类型',
  `source_post_id` int DEFAULT NULL COMMENT '来源帖子ID',
  `created_at` datetime NOT NULL COMMENT '记录创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_relationship_id` (`relationship_id`),
  KEY `idx_source_post_id` (`source_post_id`),
  CONSTRAINT `fk_follow_source_post_id` FOREIGN KEY (`source_post_id`) REFERENCES `posts` (`id`),
  CONSTRAINT `fk_follow_source_relationship_id` FOREIGN KEY (`relationship_id`) REFERENCES `user_relationships` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户关注来源表';

-- ----------------------------
-- Records of user_follow_sources
-- ----------------------------

-- ----------------------------
-- Table structure for user_relationships
-- ----------------------------
DROP TABLE IF EXISTS `user_relationships`;
CREATE TABLE `user_relationships` (
  `id` int NOT NULL AUTO_INCREMENT,
  `follower_id` int NOT NULL COMMENT '关注者ID',
  `followed_id` int NOT NULL COMMENT '被关注者ID',
  `create_time` datetime NOT NULL COMMENT '关注时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_follower_followed` (`follower_id`,`followed_id`),
  KEY `idx_follower_id` (`follower_id`),
  KEY `idx_followed_id` (`followed_id`),
  CONSTRAINT `fk_followed_id` FOREIGN KEY (`followed_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_follower_id` FOREIGN KEY (`follower_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户关注关系表';

-- ----------------------------
-- Records of user_relationships
-- ----------------------------
INSERT INTO `user_relationships` VALUES ('4', '1', '5', '2025-04-18 18:52:34');
INSERT INTO `user_relationships` VALUES ('7', '1', '9', '2025-04-18 18:53:00');
INSERT INTO `user_relationships` VALUES ('12', '2', '1', '2025-04-19 09:29:52');
