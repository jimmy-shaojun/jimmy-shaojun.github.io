---
layout: page_with_comment
title: "Hyperledger Frabric/EOS/Ethereum/Bitcoin对比"
date: "2020-01-16"
categories: 
  - "区块链"
tags: 
  - "bitcoin"
  - "cft"
  - "eos"
  - "ethereum"
  - "fabric"
  - "hyperledger"
  - "kafka"
  - "pbft"
  - "raft"
  - "smart-contract"
  - "以太坊"
  - "区块链"
  - "智能合约"
  - "比特币"
---

Fabric的知识源于 [https://hyperledger-fabric.readthedocs.io/en/latest/whatis.html](https://hyperledger-fabric.readthedocs.io/en/latest/whatis.html)

Fabric是一个基于策略的有权限机制的通用区块链平台。一个或者多个组织可以设定策略(Network Configuration)，搭建平台，并允许其他组织加入该平台，不同的组织之间可以在平台上形成一个一个个的Channel，每一个Channel对应了一个配置策略(Channel Configuration)以及保存于Channel上的账本（Ledger），每一个Channel的账本和智能合约(Smart contract, a.k.a chaincode)可以分布在多个Peer Node上，Fabric上的应用(Application)通过调用智能合约，产生交易(Transaction)，交易在Peer Node上得到背书(endoresement)，并最终提交到Ordering Service Node，打包成为区块(Block)，区块分发到Peer Node上并被验证，验证后，有效的交易就会提交(Committed)，Fabric的World State也得到了更新。

与EOS等相比，Fabric既不是POS(Proof of Stake)也不是POW(Proof of Work)，而是一种基于策略的机制。最初，Fabric采用的是单机共识或者以及基于Kafka的CFT(Crash Fault Tolerance)机制，目前，Fabric已经增加了Raft的支持。

另外，由于Fabric有Channel的概念，而且不同的Channel之间有隔离机制，这就使得Fabric在不同的Channel之间的共识可以互不干扰，有了并发的基础，而对于EOS，以太坊(Ethereum)和比特币(Bitcoin)来说，每一次共识必须是全网的共识，这决定了Fabric天生就比EOS/以太坊/比特币等有性能优势。

从性能角度来看，实际而言，比特币性能最差(不考虑Off-chain和闪电网络等因素)，以太坊次之，EOS又好一些，Fabric最好。实践中，EOS由于其独特的抵押机制，导致CPU和内存资源分配必须依赖于用户所能抵押的EOS数量，所以，尽管全网来说，EOS性能应该优于比特币和以太坊，但是，对于普通用户来说，往往由于自己能抵押的币很少，普通用户在EOS上可能迟迟得不到运行应用的时间，导致实际上无法执行操作。Fabric由于Channel的隔离因素，所以，对于大量不相关联的交易，完全可以互不干扰，分布在不同的Channel上，因此，Fabric可以实现水平扩展，而这时BTC/EOS/ETH都无法实现的。

对于Fabric来说，根据 [https://arxiv.org/pdf/1805.11390.pdf](https://arxiv.org/pdf/1805.11390.pdf)

在一个拥有8个peer node，每个peer有E5 2.0GHz 32GB内存的Fabric网络下，以Kafka作为Ordering Service的前提下，TPS达到了140，这是在一个比较普通的配置下所达到的。

从系统特性角度来看，EOS/以太坊/比特币都在存储数据上有较大限制，链上不适合存储大量的数据。必须通过各种off-chain机制存储大数据，而Fabric原生支持私有数据(private data)，再结合Channel隔离，Fabric本身就可以支持较大的数据直接存储在链上。

从智能合约开发角度来看，Fabric支持用go, java和nodejs来开发智能合约，因此，对于开发者来说更为友好，相比之下, EOS的智能合约C++，以太坊的智能合约语言为Solidity，Bitcoin本身支持一些简单的操作，不是完全不可以开发智能合约，然而限制很大。
