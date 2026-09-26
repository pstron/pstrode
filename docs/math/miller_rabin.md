一个 Miller-Rabin 实现，做到 $n<2^{64}$ 的**确定性**素性测试。使用前需要定义好`mul`和`pow`，实现参考[模乘与模幂](mulmod.md)。

```cpp
bool isprime(i64 n) {
    if (n < 2 || n % 6 % 4 != 1) return (n | 1) == 3;
    i64 s = __builtin_ctzll(n - 1), d = n >> s;
    for (i64 a : {2, 325, 9375, 28178, 450775, 9780504, 1795265022}) {
        i64 p = pow(a % n, d, n), i = s;
        while (p != 1 && p != n - 1 && a % n && i--) p = mul(p, p, n);
        if (p != n - 1 && i != s) return false;
    }
    return true;
}
```

最坏情况不超过 899 次模乘。时间复杂度 $O(\log n \cdot T_{mul})$。


