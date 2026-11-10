#!/bin/bash
# After: docker compose -f docker-compose-mongo-shards.yml up -d   (wait about 10 seconds)
set -e
C=docker-compose-mongo-shards.yml
docker compose -f $C exec cfg    mongosh --port 27019 --quiet --eval 'rs.initiate({_id:"cfgrs",configsvr:true,members:[{_id:0,host:"cfg:27019"}]})'
docker compose -f $C exec shard1 mongosh --port 27018 --quiet --eval 'rs.initiate({_id:"shard1rs",members:[{_id:0,host:"shard1:27018"}]})'
docker compose -f $C exec shard2 mongosh --port 27018 --quiet --eval 'rs.initiate({_id:"shard2rs",members:[{_id:0,host:"shard2:27018"}]})'
sleep 10
docker compose -f $C exec mongos mongosh --quiet --eval '
  sh.addShard("shard1rs/shard1:27018");
  sh.addShard("shard2rs/shard2:27018");
  sh.enableSharding("naijamart");
  sh.shardCollection("naijamart.products", { sku: "hashed" });
  db = db.getSiblingDB("naijamart");
  for (let i=1;i<=5000;i++) db.products.insertOne({sku:"SKU-"+i, name:"Product "+i, category:"Cat"+(i%10), price:1000+i});
  db.products.getShardDistribution();'
