64 位模乘与模幂。

## `mul` { #mul }

### 基于 `long double` { #long-double }

```cpp
i64 mul(i64 a, i64 b, i64 m) {
    i64 r = a * b - m * (i64)(1.L / m * a * b);
    return r - m * (r >= m) + m * (r < 0);
}
```

用 long double 算出 $\lfloor ab/m\rfloor$ 的近似值，再在整数上修正，误差不超过 $1$ 。在 $m\ge2^{63}$ 时 `1.L / m * a * b` 的误差可能超过 $1$ ，x86 的 80 位扩展精度下 $m<2^{62}$ 是安全的。

### 基于 `__int128_t` { #int128 }

```cpp
i64 mul(i64 a, i64 b, i64 m) {
    return (i128)a * b % m;
}
```

### 快速乘 { #binary }

```cpp
i64 mul(i64 a, i64 b, i64 m) {
    i64 r = 0;
    for (a %= m; b; b >>= 1, a = (a + a) % m)
        if (b & 1) r = (r + a) % m;
    return r;
}
```

时间是上面两版的约十倍。

## `pow` { #pow }

```cpp
i64 pow(i64 a, i64 b, i64 m) {
    i64 res = 1 % m;
    while (b > 0) {
        if (b & 1) res = mul(res, a, m);
        a = mul(a, a, m);
        b >>= 1;
    }
    return res;
}
```

时间 $\Theta(\log b \cdot T_{mul})$。 $m \le 3 \times 10^{9}$ 时用[快速幂](binpow.md)即可。
