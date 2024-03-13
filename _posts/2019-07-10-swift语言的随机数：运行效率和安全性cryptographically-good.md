---
layout: page_with_comment
title: "Swift语言的随机数：运行效率和安全性(cryptographically good)"
date: "2019-07-10"
categories: 
  - "ios"
  - "swift"
tags: 
  - "arc4random"
  - "random"
  - "swift"
  - "随机数"
---

Apple推出Swift语言已经很多年了，如今，Swift语言已经进化到了5.1版本，很多细节也越来越完善了，不过，总的来说，Swift语言的overhead仍然较大，具体到随机数上，Swift内置的运行时生成随机数效率低，不适用于模拟，测试和游戏等对于cryptographically good要求不高的场景。

如果读者需要大量生成随机数的话，建议用arc4random或者arc4random\_uniform，不要使用arc4random\_buf或者Swift语言的random方法。对于测试，模拟和游戏等不需要cryptographically good/secure的情况，可以直接引入C语言类库的rand方法，运行效率更高。

Swift对于内置的Double, Int等类型提供了random方法，用以生成指定的开闭区间内的随机数。然而，经过实际测试，我发现，一方面，Swift语言本身的overhead很大，另一方面，Swift内置的SystemRandomNumberGenerator使用的是arc4random\_buf，该方法比arc4random和arc4random\_buf慢很多。所以，如果效率非常重要，那么，请不要使用Swift类库的随机数，应该在Swift中调用C/C++语言实现的随机数库。

```

       var i = 0;
        while(i<100000000){
 //1亿个随机数，每个随机数在闭区间[0,11]内取值，随机数独立同分布
            let _ = arc4random_uniform(11)
            i += 1;
        }

```

```
       var i = 0;
        while(i<100000000){
//1亿个随机数，每个随机数在闭区间[0,2^32-1]内取值，随机数独立同分布
            let _ = arc4random()
            i += 1;
        }

```

```
       var i = 0;
        while(i<100000000){
            var b:UInt32 = 0;
//1亿个随机数，每个随机数在闭区间[0,2^32-1]内取值
            arc4random_buf(&b, 4)
            i += 1;
        }

```

```
        var i = 0;
        while(i<100000000){
            var b:UInt32 = 0;
            b = UInt32.random(in: 0...10)
            i += 1;
        }

```

以下为一个特别简单的模n同余的Linear Congruent伪随机数生成器，实际测试发现，生成1亿个32位随机数的话，Debug模式下需要耗时29.31秒， Release模式下需要5.06秒。

```
struct LCG: RandomNumberGenerator {
    var seed:UInt64
    
    init() {
        self.seed = mach_absolute_time()
    }
    
    init(seed:UInt64) {
        self.seed = seed;
    }
    
    mutating func next() -> UInt64 {
        self.seed = 32479 &+ self.seed
        return self.seed
    }
    
}

var i = 0;
while(i<100000000){
    var b:UInt32 = 0;
    b = UInt32.random(in: 0...10, using: &lcg)
    i += 1;
}

```

经过实际测试，结果如下 1亿个随机数， \[table\] 随机数生成方法, debug, release rand, 11.21秒, 0.52秒 arc4random, 3.09秒, 2.34秒 arc4random\_uniform, 3.41秒, 2.67秒 arc4random\_buf, 19.69秒, 18.79秒 UInt32.random, 47.98秒, 19.27秒 自定义LCG, 29.31秒, 5.06秒 \[/table\]

UInt32.random实际上会使用Swift内置的SystemRandomNumberGenerator，实际上最终调用了arc4random\_buf，然而，与直接调用arc4random\_buf相比，UInt32.random在Debug模式下慢了近30秒，Release模式下则慢了16秒，因此，我们可以得出结论，即便是Release模式下，Swift的overhead还是很大的。因此，如果需要高效率生成很多随机数的话，不建议直接使用Swift的Double, Int的random方法。不过很特别的是，rand函数在Debug模式下竟然比arc4random慢很多，甚至和arc4random\_buf差不多了，但是，在Release模式下，rand还是最快的，0.52秒就可以生成1亿个伪随机数。

接下来，我们来看看为什么arc4random\_buf比arc4random和arc4random\_uniform慢这么多。

经过查看苹果的具体实现 https://opensource.apple.com/source/Libc/Libc-1272.200.26/gen/FreeBSD/arc4random.c.auto.html

我们不难发现，arch4random方法的具体代码如下，其中CACHE\_LENGTH的值为64

```
uint32_t
arc4random(void)
{
	int ret;
	os_unfair_lock_lock(&arc4_lock);
	arc4_init();
	if (arc4_count <= 0) {
	    arc4_stir();
	}
	if (cache_pos >= CACHE_LENGTH) {
		ret = ccdrbg_generate(&rng_info, rng_state, sizeof(rand_buffer), rand_buffer, 0, NULL);
		os_assert_zero(ret);
		cache_pos = 0;
	}
	uint32_t rand = rand_buffer[cache_pos];
	// Delete the current random number from buffer
	memset_s(rand_buffer+cache_pos, sizeof(rand_buffer[cache_pos]), 0, sizeof(rand_buffer[cache_pos]));
	arc4_count--;
	cache_pos++;
	os_unfair_lock_unlock(&arc4_lock);
	return rand;
}

```

而arc4random\_uniform实际调用arc4random方法，并且通过多次循环避免modulo bias

```
/*
 * Calculate a uniformly distributed random number less than upper_bound
 * avoiding "modulo bias".
 *
 * Uniformity is achieved by trying successive ranges of bits from the random
 * value, each large enough to hold the desired upper bound, until a range
 * holding a value less than the bound is found.
 */
uint32_t
arc4random_uniform(uint32_t upper_bound)
{
	if (upper_bound < 2)
		return 0;

	// find smallest 2**n -1 >= upper_bound
	int zeros = __builtin_clz(upper_bound);
	int bits = CHAR_BIT * sizeof(uint32_t) - zeros;
	uint32_t mask = 0xFFFFFFFFU >> zeros;

	do {
		uint32_t value = arc4random();

		// If low 2**n-1 bits satisfy the requested condition, return result
		uint32_t result = value & mask;
		if (result < upper_bound) {
			return result;
		}

		// otherwise consume remaining bits of randomness looking for a satisfactory result.
		int bits_left = zeros;
		while (bits_left >= bits) {
			value >>= bits;
			result = value & mask;
			if (result < upper_bound) {
				return result;
			}
			bits_left -= bits;
		}
	} while (1);
}

```

也就是说，arc4random和arc4random\_uniform由于rand\_buffer\[64\]的存在，每生成64个32位随机数，才需要调用一次ccdrbg\_generate，而arc4random\_buf每一次调用，都需要调用一次ccdrbg\_generate。所以，如果读者需要大量生成随机数的话，建议用arc4random或者arc4random\_uniform，不要使用arc4random\_buf或者Swift语言的random方法。

对于测试，模拟和游戏等不需要cryptographically good/secure的情况，可以直接引入C语言类库的rand方法，运行效率更高。
