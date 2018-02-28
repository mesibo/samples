DROP TABLE IF EXISTS users;
CREATE TABLE users (
  uid int(10) unsigned NOT NULL,
  ns varchar(32) DEFAULT '',
  name varchar(64) DEFAULT '',
  phone bigint(20) unsigned NOT NULL DEFAULT '0',
  token varchar(128) DEFAULT '',
  ts int(10) unsigned DEFAULT '0',
  PRIMARY KEY (uid),
  UNIQUE KEY phone (phone),
  KEY ts (ts)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

