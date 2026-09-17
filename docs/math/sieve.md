## Eratosthenes 筛法

```cpp
std::vector<bool> isp;
void eratosthenes(int n = 1e7) {
    isp.resize(n + 1, true);
    isp[0] = isp[1] = false;
    for (int i = 2; (i64)i * i <= n; ++i)
        if (isp[i])
            for (int j = i * i; j <= n; j += i) isp[j] = false;
}
```

```cpp
const std::vector<bool> isp = [](int n) {
    std::vector<bool> p(n + 1, true);
    p[0] = p[1] = false;
    for (int i  = 2; (i64)i * i <= n; ++i) {
        if (p[i])
            for (int j = i * i; j <= n; j += i) p[j] = false;
    }
    return p;
}(1e7);
```

复杂度 $\Theta(n \log \log n)$ 。本实现采用 `std::vector<bool>` 优化，多数时候速度优于 Euler 筛法。

## Euler 筛法（线性筛法）

```cpp
std::vector<int> primes{}, minp;
void sieve(int n = 1e7) {
    minp.resize(n + 1);
    for (int i = 2; i <= n; ++i) {
        if (!minp[i]) {
            minp[i] = i;
            primes.push_back(i);
        }
        for (auto j : primes) {
            if (j > minp[i] || j > n / i) break;
            minp[i * j] = j;
        }
    }
}
```

复杂度 $\Theta(n)$ 。由于常数影响略慢于 Eratosthenes 筛法，优点是可以求最小质因子以及多种数论函数。
