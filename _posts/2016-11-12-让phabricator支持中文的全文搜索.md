---
layout: page_with_comment
title: "让Phabricator支持中文的全文搜索"
date: "2016-11-12"
categories: 
  - "phabricator"
  - "互联网"
tags: 
  - "fulltext"
  - "mysql"
  - "ngram"
  - "phabricator"
  - "search"
  - "全文索引"
---

[Phabricator](https://secure.phabricator.com/)是一款优秀的开源项目管理、代码评审和代码管理平台，然而，默认情况下，它对于中文搜索的支持存在问题。

例如，如果你新建了一个标题为“公司年会准备工作”的Maniphest Task，那么，你在Phabricator中用“公司”或者“年会”进行搜索，是搜不到“公司年会准备工作”。这是因为Phabricator默认安装的时候，使用的是MySQL的全文索引，而MySQL默认的分词器是按照空白字符进行分词的，因此，“公司年会准备工作”是作为一个词语进行索引，而不是按照“公司”“年会”“准备”“工作”四个词语进行索引。

解决的办法有不少，例如，我们可以使用ElasticSearch为Phabricator的搜索引擎。不过，其实MySQL的全文索引是支持中文分词的，从MySQL 5.7.6开始，MySQL增加了[NGRAM分词器](https://dev.mysql.com/doc/refman/5.7/en/fulltext-search-ngram.html)，当你[设置ngram\_token\_size=2](https://dev.mysql.com/doc/refman/5.7/en/fulltext-search-ngram.html)时，“公司年会”会被分词为“公司” “司年” “年会”。

Phabricator的MySQL全文索引建立在phabricator\_search库的search\_documentfield表上，索引名称为corpus，对应的表的列名为corpus。 索引名称为key\_corpus，对应的列为corpus和stemmedCorpus。

``CREATE TABLE `search_documentfield` ( `phid` varbinary(64) NOT NULL, `phidType` varchar(4) COLLATE {$COLLATE_TEXT} NOT NULL, `field` varchar(4) COLLATE {$COLLATE_TEXT} NOT NULL, `auxPHID` varbinary(64) DEFAULT NULL, `corpus` longtext CHARACTER SET {$CHARSET_FULLTEXT} COLLATE {$COLLATE_FULLTEXT}, KEY `phid` (`phid`), FULLTEXT KEY `corpus` (`corpus`) ) ENGINE=MyISAM DEFAULT CHARSET={$CHARSET} COLLATE={$COLLATE_TEXT};``

我们看到，[DDL](https://en.wikipedia.org/wiki/Data_definition_language)语句中，创建全文索引的部分为“FULLTEXT KEY \`corpus\` (\`corpus\`)”，这使用的是默认的MySQL分词器，如果我们要使用NGRAM分词器，这个语句应该写成“FULLTEXT KEY \`corpus\` (\`corpus\`) WITH PARSER NGRAM”。

我已经有了一个已经安装好的Phabricator实例，我并不想重新安装Phabricator，所以，我的做法是删除掉corpus索引，然后重新建立以NGRAM作为分词器的corpus索引。

SQL语句如下(之前的版本) ``USE phabricator_search; DROP INDEX `corpus` ON `search_documentfield`; CREATE FULLTEXT INDEX `corpus` ON `search_documentfield`(`corpus`) WITH PARSER NGRAM;``

SQL语句如下(最新的版本) ``USE phabricator_search; DROP INDEX `key_corpus` ON `search_documentfield`; CREATE FULLTEXT INDEX `key_corpus` ON `search_documentfield`(`corpus`,`stemmedCorpus`) WITH PARSER NGRAM;``

我设置MySQL的ngram\_token\_size为2，因为中文中两个字的词非常多。

我的my.cnf中添加了以下配置项 `[mysqld] ngram_token_size=2`
