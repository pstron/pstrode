## `modint`

### 简介

`modint` 是固定模意义下的整数类，可以方便地进行运算，尤其适用于取模的模拟题。

设模数为 `m`，`modint<m>` 表示一个模 `m` 的整数类。

它支持：

- 加法
- 减法
- 乘法
- 除法
- 幂运算
- 取模意义下的逆元
- 自增 / 自减
- 比较运算

!!! danger
    该 modint 的除法实现基于费马小定理求模逆元，假设模数 m 为质数。若模数非质数，则涉及除法的操作是未定义行为。

---

### 代码

所需头文件：

- `<cstdint>`

```cpp
template <int m>
struct modint {
    using u32 = std::uint32_t;
    using u64 = std::uint64_t;
    u32 v_;
    static constexpr u32 umod() { return m; }

    modint() : v_(0) {}
    modint(i64 v) {
        i64 x = (i64)(v % (i64)(umod()));
        if (x < 0) x += umod();
        v_ = (u32)(x);
    }

    int val() const { return v_; }

    modint& operator++() {
        v_++;
        if (v_ == umod()) v_ = 0;
        return *this;
    }
    modint& operator--() {
        if (v_ == 0) v_ = umod();
        v_--;
        return *this;
    }
    modint operator++(int) {
        modint result = *this;
        ++*this;
        return result;
    }
    modint operator--(int) {
        modint result = *this;
        --*this;
        return result;
    }

    modint& operator+=(const modint& rhs) {
        v_ += rhs.v_;
        if (v_ >= umod()) v_ -= umod();
        return *this;
    }
    modint& operator-=(const modint& rhs) {
        v_ -= rhs.v_;
        if (v_ >= umod()) v_ += umod();
        return *this;
    }
    modint& operator*=(const modint& rhs) {
        u64 z = v_;
        z *= rhs.v_;
        v_ = (u32)(z % umod());
        return *this;
    }
    modint& operator/=(const modint& rhs) { return *this = *this * rhs.inv(); }

    modint operator+() const { return *this; }
    modint operator-() const { return modint() - *this; }

    modint pow(i64 n) const {
        modint x = *this, r = 1;
        while (n) {
            if (n & 1) r *= x;
            x *= x;
            n >>= 1;
        }
        return r;
    }
    modint inv() const {
        return pow(umod() - 2);
    }

    friend modint operator+(const modint& lhs, const modint& rhs) {
        return modint(lhs) += rhs;
    }
    friend modint operator-(const modint& lhs, const modint& rhs) {
        return modint(lhs) -= rhs;
    }
    friend modint operator*(const modint& lhs, const modint& rhs) {
        return modint(lhs) *= rhs;
    }
    friend modint operator/(const modint& lhs, const modint& rhs) {
        return modint(lhs) /= rhs;
    }
    friend bool operator==(const modint& lhs, const modint& rhs) {
        return lhs.v_ == rhs.v_;
    }
    friend bool operator!=(const modint& lhs, const modint& rhs) {
        return lhs.v_ != rhs.v_;
    }
};
```

---

### 使用示例

```cpp
constexpr int MOD = 998244353;
using mint = modint<MOD>;
mint a = 100;
a /= 3;
std::cout << a.val() << '\n';
std::cout << (a * 3).val() << '\n';
```

---

### 复杂度

| 操作               |      复杂度 |
| ------------------ | ----------: |
| 构造               |      $O(1)$ |
| `val()`            |      $O(1)$ |
| `++`, `--`         |      $O(1)$ |
| `+`, `-`, `*`      |      $O(1)$ |
| `pow(n)`           | $O(\log n)$ |
| `/`，`inv()`       | $O(\log m)$ |

