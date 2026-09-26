模数 $p\le3\times10^{9}$ 时，`a * b` 不会溢出 64 位，直接相乘即可。

```cpp
i64 binpow(i64 a, i64 b, i64 p) {
    i64 res = 1 % p;
    while (b > 0) {
        if (b & 1) res = res * a % p;
        a = a * a % p;
        b >>= 1;
    }
    return res;
}
```

计算 $a^b \bmod p$ 的值，时间 $\Theta(\log b)$ 。要求模数 $p\le3\times10^{9}$，否则需用[基于mulmod的pow](mulmod.md#pow) 。
