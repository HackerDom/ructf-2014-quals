CREATE USER 'secritter'@'localhost' IDENTIFIED BY  'FEyYEs5QdMKXAZD9';
GRANT USAGE ON * . * TO  'secritter'@'localhost' IDENTIFIED BY 'FEyYEs5QdMKXAZD9' MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;
CREATE DATABASE IF NOT EXISTS `secritter`;
GRANT ALL PRIVILEGES ON `secritter` . * TO  'secritter'@'localhost';


CREATE TABLE IF NOT EXISTS `secritter`.`users` (
  `uid` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` varchar(32) NOT NULL,
  `fb_id` varchar(255) NULL,
  `fb_state` varchar(32) NOT NULL,
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;


CREATE TABLE IF NOT EXISTS `messages` (
  `mid` int(11) NOT NULL AUTO_INCREMENT,
  `author` int(11) NOT NULL,
  `owner` int(11) NOT NULL,
  `message` varchar(140) NOT NULL,
  PRIMARY KEY (`mid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;
