## Pollard Rho 算法

用于找到合数 $n$ 的一个非平凡因子。

一个较快的实现：

该实现得到模 $p$ 序列的伪随机函数为 $f(x) = (x^2 + c) \bmod N$，其中 $c$ 在该实现中取了固定值 $5$；判环方法为 Floyd 判环。

- 需要头文件 `<numeric>` 提供 `std::gcd` 。

- 需要定义模乘`mul`。参见[mulmod](mulmod.md)。

```cpp
i64 rho(i64 n) {
    if (!(n & 1)) return 2;
    i64 x = 0, y = 0, prod = 1;
    i64 c = 5;
    auto f = [&](i64 x) -> i64 { return (mul(x, x, n) + c) % n; };
    for (int t = 30, z = 0; t % 64 || std::gcd(prod, n) == 1; ++t) {
        if (x == y) x = ++z, y = f(x);
        if (i64 q = mul(prod, x + n - y, n)) prod = q;
        x = f(x), y = f(f(y));
    }
    return std::gcd(prod, n);
}
```

对于偶数返回因子 2；否则尝试以期望 $O(n^\frac{1}{4})$ 的时间返回一个非平凡因子。若返回 n，表示本次失败。

## 基于 Pollard Rho 的质因子分解

- `isprime()` 来自 [Miller-Rabin](miller_rabin.md)

```cpp
std::vector<i64> factorize(i64 x) {
    std::vector<i64> res;
    auto f = [&](this auto&& self, i64 x) -> void {
        if (x == 1) return;
        if (isprime(x)) return res.push_back(x);
        i64 y = rho(x);
        self(y), self(x / y);
    };
    f(x);
    std::sort(res.begin(), res.end());
    return res;
}
```
