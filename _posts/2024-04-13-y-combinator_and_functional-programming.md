---
layout: page_with_comment
title: "Y-combinator, not the startup accelerator, but the Y function in lambda calculus"
date: "2024-04-13"
tags: 
  - "ycombinator"
  - "functional programming"
  - "lambda calculus"
---

When people talk about Y combinator, they usually refer to [Y Combinator](https://www.ycombinator.com/), the startup accelerator. However, at the very beginning, Y-combinator is a function called Y in [lambda calculus](https://personal.utdallas.edu/~gupta/courses/apl/lambda.pdf).

> 现如今，当人们说起Y combinator的时候，他们通常指的是一个名为[Y Combinator](https://www.ycombinator.com/)的创业加速器。实际上，Y combinator最初指的是[lambda calculus](https://personal.utdallas.edu/~gupta/courses/apl/lambda.pdf)中的一个以Y为名称的特殊函数。

Before we learn about what Y combinator is, we need to understand what [lambda calculus](https://personal.utdallas.edu/~gupta/courses/apl/lambda.pdf) is. In short, λ calculus is a smallest universal programming language with a single transformation rule, called variable substitution. 

> 在我们进一步了解什么是Y combinator之前，我们需要先了解什么是[lambda calculus](https://personal.utdallas.edu/~gupta/courses/apl/lambda.pdf)。简单说，λ calculus是一个最简单的通用程序语言，仅有一种叫做变量替换的转换规则

Let us look at this example function **λ x . x**, which means a function that takes 1 parameter x and return x. if we apply 5 to this function, written as **λ x . x 5**, we substitute 2nd x with 5 and get **5**.

> 我们先看看一个最简单的例子**λ x . x**，该函数有一个参数x，返回值也是x，如果我们给该函数传入5，即**λ x . x 5**，那么按照变量替换规则，我们需要将第二个x替换为5，获得了最终结果**5**

You may notice, there is no function name in above example, and yes, all functions in lambda calculus are anonymous and the only transformation rule is variable substitution. Then, how are we going to support recursion? 

> 你也许注意到了，lambda calculus的函数是匿名呢，函数并没有一个名字，那么，lambda calculus如何支持递归呢？

Take below recursive fibnaocci function in **C**/**Haskell** as an example, we need the function name `fibonacci` to recursively call the function itself. There is also no `self` or `this` keyword in lambda calculus to refer to function itself.

> 让我们先看看C语言和Haskell语言之中递归是符合实现的，下面是`fibonacci`的具体实现。无论是C还是Haskell，我们都给函数起名字为`fibonacci`，而我们无法在lambda calculus中给函数起名字，同时lambda calculus也没有`self` 或者 `this`关键字。

*Please note that below implementations of fibonacci are not optimal and are for presentaiton purppose only.*
```C
// fibonacci C example 
int fibonacci(int n){
    if (num == 0 || num == 1)return num;
    return fibonacci(n-1)+fibonacci(n-2);
}
```

```haskell
-- fibonacci haskell example
fibonacci :: Integer -> Integer
fibonacci n = do
    if (n == 0) || (n == 1) then n
    else fibonacci(n-1)+fibonacci(n-2)
```

If we cannot give function a name, how can we support recursion? Here comes Y combinator. **Y** function in lambda calculus is 

> 如果我们不能给函数起名字，那么，难到lambda calculus不支持递归吗？并不是，lambda calculus定义了一个特别的Y函数，即Y combinator。

```
Y ≡ (λy.(λx.y(xx))(λx.y(xx)))
```

To better understand **Y**, let's apply **R** to **Y**.
> 为了更好理解 **Y**, 让我们看下面的例子，计算YR

```
(1) YR = (λy.(λx.y(xx))(λx.y(xx)))R
```

substitute variable y with R we get
> 将参数y 替换为R，我们可以得到下列结果

```
(2) (λx.R(xx))(λx.R(xx))
```

which means apply the 2nd **(λx.R(xx))** to 1st **(λx.R(xx))**, and we get
> 而该结果表示调用(λx.R(xx))，参数为(λx.R(xx))，因此我们可以得到下列结果

```
(3) R((λx.R(xx)(λx.R(xx)) = R(YR)
```

If we look at (1) and (2) we can know that **(λx.R(xx)(λx.R(xx)** is equal to **YR**, which means (3) is actually **R(YR)**, so we have 

> 我们将(1)(2)进行对照，不难发现，**(λx.R(xx)(λx.R(xx)** 其实等于**YR**，于是，我们可以将(3)进一步化简得到下列结果

```
(4) YR = R(YR) = R(R(YR)) = R(R(R(YR))) ....
```

Let's see a concrete Y combinator example in Haskell. We define y combinator function as **y r = r (y r)**, in the form of (4). The actual fibonacci function is called `fib` but as you can see in the actual implementation of `fib` we acheive recursion without knowing about the function name `fib`.

Function **y** takes a parameter **r** and **r** is also a function that takes a parameter **f** in `fib`. 

> 我们看到，下面的具体的Haskell例子，我们定义Y combinator为**y r = r (y r)**，即(4)的形式。尽管我们将fibonacci函数命名为`fib`，我们不难看到，`fib`本身并没有使用`fib`的函数名称就实现了递归。

```haskell
module Main where

y r = r (y r)

fib :: Integer -> Integer
fib = y (\f -> do
    \x -> do
        if x <= 1 then x
        else f(x-1)+f(x-2) 
    )

main :: IO ()
main = do
    print (fib 7) -- outputs 13
    print (fib 3) -- outputs 2
```

To better understand the above example, please note that **y** function is exactly the **Y** function in lambda calculus and **R** is below

> 为了更好理解上面的例子，我们要注意到，**y r = r (y r)**定义的**y**函数对应了lambda calculus中的**Y**函数。而**R**则对应了下面的函数

```
\f -> do
    \x -> do
        if x <= 1 then x
        else f(x-1)+f(x-2) 
    )
```

For `(fib 3)` in haskell,  if transalted to lambda calculus, we are doing 
> 让我们尝试来调用haskell的(fib 3)

**fib 3** =**y r 3** = **r (y r) 3** 

= **(\f -> \x -> ...) (y r) 3**

= **(\f -> \x -> ...) (y (\f -> \x -> ...)) 3**

= **(\x -> ...) 3**
 

then the 1st haskell lambda **(\f -> \x -> ...)** is called with parameter **f** =  **(y (\f -> \x -> ...))** which yields haskell lamda **(\x -> ...)**, which is later called with parameter **x** = **3**. Recall that the "..." in  **(\x -> ...) 3** is below implementation. 

> 我们不难发现，第一个lambda **(\f -> \x -> ...)** 获得参数 **(y (\f -> \x -> ...))** 并返回lambda **(\x -> ...)**，然后该lambda获得参数3. 注意， **(\x -> ...) 3** 中的"..."对应以下实现。


```haskell
    if x <= 1 then x
        else f(x-1)+f(x-2) 
```

And we know that **f** is **y r = (y (\f -> \x -> ...))**, thus, recursion is supported.

> 而**f**就对应了**y r = (y (\f -> \x -> ...))**，因此fib函数可以实现递归