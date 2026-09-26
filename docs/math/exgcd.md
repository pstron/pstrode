## 扩展欧几里得算法（exgcd）

### 简介

可以用于求二元一次不定方程：

$$
ax + by = \gcd(a, b)
$$

的一组解。并且当 $ab \neq 0$ 时该解满足：

$$
|x| \leq \frac{|b|}{g}, |y| \leq \frac{|a|}{g}
$$

若进一步 $|a| \neq |b|$ 还可以做到：

$$
|x| \leq \frac{|b|}{2g}, |y| \leq \frac{|a|}{2g}
$$

其中 $g = \gcd(a, b)$ 。

### 代码

该实现要求输入数字非负。

- 递归版本

```cpp
int exgcd(int a, int b, int &x, int &y) {
    if (!b) {
        x = 1;
        y = 0;
        return a;
    }
    int d = exgcd(b, a % b, x, y);
    int t = x;
    x = y;
    y = t - (a / b) * y;
    return d;
}
```

- 迭代版本

需要头文件 `<tuple>` 。

```cpp
int exgcd(int a, int b, int &x, int &y) {
    int x1 = 1, x2 = 0, x3 = 0, x4 = 1;
    while (b != 0) {
        int c = a / b;
        std::tie(x1, x2, x3, x4, a, b) =
            std::make_tuple(x3, x4, x1 - x3 * c, x2 - x4 * c, b, a - b * c);
    }
    x = x1, y = x2;
    return a;
}
```

### 复杂度

时间 $\Theta(\log\min(a,b))$ 。
