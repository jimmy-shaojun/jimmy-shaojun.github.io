---
layout: page_with_comment
title: "Shard aware query in a Ruby on Rails application"
date: "2024-09-22"
tags:
  - "ruby"
  - "rails"
  - "shard"
  - "ror"
  - "postgres"
---

I was working for a e-Commerce client that use PostgreSQL and [Citus](https://www.citusdata.com/). The Client uses Citus to turn Postgres into a distributed sharding clusters. Usually developers do not need to worry about the underlying sharding but when I encoutered a query timeout in a Ruby on Rails applicaiton, I found that I needed to optimize the code to query directly in each shard node.

The client has Postgres shard by user_id and the code I worked with involved querying users filtered by created_at and and partner_id and limit by 500. When the query succeeds, we need to run some database updates based on query reuslts. The query constantly timeout, preventing this task to succeed. After consulting with database team, I found that

1. the "LIMIT BY" clause is not pushed down to individual nodes but instead only evaluated in coordinator node, thus, "LIMIT BY" will not reduce the number of row scans
2. the "EXPLAIN" statement reveals that Postgres was not using indexes on both created_at and partner_id, instead, it only used partner_id index

I have to 
1. use "each_shard" method, a method created by the client, to query directly in shard nodes instead of coordinator node to push "LIMIT BY" clause
2. run analysis of data distribution in each shard nodes and then modify the "WHERE" clause so that Postgres begins to use indexes on both created_at and partner_id.

Given "WHERE partner_id = 10 AND created_at BETWEEN '2024-09-09' AND '2024-11-09'", I need to run multiple queries
* "WHERE partner_id = 10 AND created_at BETWEEN '2024-09-09 00:00:00' AND '2024-09-09 23:59:59.999999'"
* "WHERE partner_id = 10 AND created_at BETWEEN '2024-09-10 00:00:00' AND '2024-09-10 23:59:59.999999'"
* ......
* "WHERE partner_id = 10 AND created_at BETWEEN '2024-11-09 00:00:00' AND '2024-11-09 23:59:59.999999'"

I know this is not ideal and usually is what we want to avoid. However I have to make this trade-off
* The Postgres setting requires each query to complete in 5s. This is to avoid any inefficient long query to stuck the database
* We do need to run this kind of OLTP query which is likely to take more than 5s and we cannot use OLAP database to do the query and then do updates in production database.
