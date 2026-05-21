对于模数 $p$ 是质数的情况，可由费马小定理：

$$
a ^ {p - 2} \equiv a ^ {-1} \mod p
$$

使用[快速幂](binpow.md)即可：

```cpp
i64 inv(i64 a, i64 p) {
  return binpow(a, p - 2, p);
}
```
