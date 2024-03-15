DROP TABLE IF EXISTS `websites`;
CREATE TABLE `websites` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` char(20) NOT NULL DEFAULT '' COMMENT '站点名称',
  `url` varchar(255) NOT NULL DEFAULT '',
  `alexa` int NOT NULL DEFAULT '0' COMMENT 'Alexa 排名',
  `country` char(10) NOT NULL DEFAULT '' COMMENT '国家',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3;

INSERT INTO `websites` VALUES (1,'Google','google.com',1,'美国');
INSERT INTO `websites` VALUES (2,'Youtube','youtube.com',2,'美国');
INSERT INTO `websites` VALUES (3,'Facebook','facebook.com',3,'美国');
INSERT INTO `websites` VALUES (4,'Baidu','baidu.com',4,'美国');
INSERT INTO `websites` VALUES (5,'Yahoo','yahoo.com',5,'美国');
INSERT INTO `websites` VALUES (6,'Amazon','amazon.com',6,'美国');
INSERT INTO `websites` VALUES (7,'Wikipedia','wikipedia.org',7,'美国');
INSERT INTO `websites` VALUES (8,'QQ','qq.com',8,'中国');
INSERT INTO `websites` VALUES (9,'Google.co.in','google.co.in',9,'印度');
INSERT INTO `websites` VALUES (10,'Twitter','twitter.com',10,'美国');
