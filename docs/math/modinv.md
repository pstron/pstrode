当且仅当 $\gcd(a, m) = 1$ 时，逆元 $a^{-1} \mod m$ 存在，且唯一存在。

## 质数模数

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

## 非质数模数

对于模数 $m$ 不是质数的情况：

1. 通过[扩展欧几里得算法（exgcd）](exgcd.md)求：
   ```cpp
   i64 inv(i64 a, i64 m) {
       i64 x, y;
       exgcd(a, m, x, y);
       return (x % m + m) % m;
   }
   ```

2. 通过欧拉函数求：
   $$
   a^{-1} \equiv a^{\phi(m) - 1} \mod m
   $$

## 批量求逆元

注意需要保证每个元素都满足逆元存在的条件。

```cpp
std::vector<int> array_inv(const std::vector<int>& a, int m) {
    int n = (int)a.size();
    std::vector<int> prod(n);
    i64 s = 1;
    for (int i = 0; i < n; ++i) {
        prod[i] = s;
        s = s * a[i] % m;
    }
    s = inv(s, m);
    std::vector<int> res(n);
    for (int i = n - 1; i >= 0; --i) {
        res[i] = s * prod[i] % m;
        s = s * a[i] % m;
    }
    return res;
}
```

时间复杂度 $\Theta(n + T_{inv}(m))$ 。

## 线性预处理逆元

要求模数 $p$ 为质数。可以线性时间预处理出 $1 \sim n$ 在模 $p$ 意义下的逆元：

```cpp
std::vector<int> init_inv(int n, int p) {
    std::vector<int> res(n + 1);
    res[1] = 1;
    for (int i = 2; i <= n; ++i) {
        res[i] = (i64)(p - p / i) * res[p % i] % p;
    }
    return res;
}
```

时间复杂度 $\Theta(n)$ 。
