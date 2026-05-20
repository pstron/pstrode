```cpp
i64 binpow(i64 a, i64 b, i64 p) {
  i64 res = 1;
  while (b > 0) {
    if (b & 1) res = res * a % p;
    a = a * a % p;
    b >>= 1;
  }
  return res;
}
```

计算 $a^b \bmod p$ 的值，时间复杂度 $\Theta(\log b)$
