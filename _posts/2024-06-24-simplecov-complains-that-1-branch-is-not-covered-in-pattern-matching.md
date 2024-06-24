---
layout: page_with_comment
title: "SimpleCov complains that 1 branch is not covered in pattern matching."
date: "2024-06-24"
tags:
  - "ruby"
  - "rspec"
  - "unit"
  - "test"
  - "coverage"
  - "pattern"
  - "matching"
---

Pattern matching is a feature available in multiple programming languages that allows developers to test an expression to determine if it has certain characteristics.

Ruby supports pattern matching and you can do deep matching of structured values such as arrays or hashes.

Code Block 1
```
v = [1, 2, 3, 4]
case v 
in [head,*tail]
  puts("head=#{head}, tail=#{tail}")
else
  puts("Not matched")
end
```

will output "head=1, tail=[2, 3, 4]"

Code Block 2
```
v = [1, 2, 3, 4]
case v 
in [head,*tail]
  puts("head=#{head}, tail=#{tail}")
in []
  puts("Not matched")
end
```

will also output "head=1, tail=[2, 3, 4]"

Code Block 1 and 2 are equivalent but if you use SimpleCov to generate code coverage, even if you have 100% line coverage, you will notice that SimpleCov still says that you do not have 100% branch coverage and 1 branch is not covered.

Why? Aren't these two blocks equivalent?

No, the above two blocks are not equivalent. The missed branch in Code Block 2 is the "else" branch in ruby pattern matching. We can only view the two blocks equiavlent if `v` is array type. However, ruby is a dynamic type langauge and `v` can be nil, hashes or other types.

Even if you are 100% sure that `v` must be an array, it is always good practice to have else branch in a pattern matching.