---
layout: page_with_comment
title: "以太坊 Ethereum ERC20代币批量转账接口"
date: "2018-04-26"
categories: 
  - "区块链"
tags: 
  - "ethereum"
  - "一对多"
  - "区块链"
  - "智能合约"
  - "转账"
---

以太坊(Ethereum)作为一个知名的区块链平台，大量的代币发行（Initial Coin Offering）通过以太坊进行，而代币通常为以太坊上一个遵循了ERC20规范的智能合约。

如果一个以太坊智能合约实现了以下接口，那么，这个智能合约即为一个ERC20代币。

```
// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

```

然而，我们不难看到，ERC20规范中只有一对一转账的transfer和transferFrom，如果我们要一次实现向成千上万个地址转账，那么，我们就需要产生上万个transfer交易，这未免太低效了。

所以，不少ERC20代币都实现了批量转账的接口。 如近期[爆出漏洞](http://36kr.com/p/5131152.html)的BEC(https://etherscan.io/address/0xc5d105e63711398af9bbff092d4b6769c82f793d#code)实现了batchTransfer函数。

SMT(https://etherscan.io/address/0x55f93985431fc9304077687a35a1ba103dc1e081#code)也实现了allocateTokens函数。

他们都可以实现一笔以太坊交易(Transaction)完成对多个账户的代币转账或初始化。

本文提出了一种实现一对多转账的方法，该方法名称为transferMultiple

首先，本文默认已用了SafeMath库

```
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

```

接下来，transferMultiple

transferMultiple实现了从msg.sender向count个\_tos地址转账，且\_tos\[i\]获得\_values\[i\]的代币。

首先，第一个for循环进行了前置检查，确保了每一个\_tos地址都是非0地址，同时，计算了转账的总额，并将总额记录到total变量中。在计算过程中，为了防止溢出，我们采用了SafeMath库，并且每一次都要比较当前计算出来的总额total和上一笔总额total\_prev，确保total大于等于total\_prev，双重保证不会整数溢出导致转账故障。

其次，第二个for循环不直接调用transfer方法，而是直接修改内部变量，这是因为前置检查已经做了，如果再次调用transfer函数的话，会再次执行额外的不必要的前置检查，会增加消耗的gas。

```
function transferMultiple(address[] _tos, uint256[] _values, uint count)  payable public returns (bool success) {
        uint256 total = 0;
        uint256 total_prev = 0;
        uint i = 0;

        for(i=0;i
            total_prev = total;
            total = SafeMath.add(total, _values[i]);
            require(total >= total_prev);
        }

        require(total <= balanceOf(msg.sender);

        for(i=0;i<=count-1;i++){
            balances[msg.sender] = SafeMath.sub(balances[msg.sender], _values[i]);
            balances[_tos[i]] = SafeMath.add(balances[_tos[i]], _values[i]);
            Transfer(msg.sender, _tos[i], _values[i]);
            //以上三行也可以替换为下一行，好处是不需要假设客户的余额保存在类型为mapping的balances变量中，坏处是会额外增加很多不必要的前置检查，额外消耗gas
            //transfer(_tos[i], _values[i]);
        }

        return true;
    }

```

大家一定很关心，那么，我用transferMultiple一次实现一对一万转账行不行呢。 实际测试表明，一对四十转账的时候，大约消耗的gas在130万左右，而截止目前本文写作之时，以太坊一个区块的gas上限大约为800万，所以，大家不难看出，一次实现一对二百四十转账就差不多将区块的gas上限占满了。如果一次转账的收款对象数量太多，完全会因为超出区块gas上限而导致交易无法成功。
