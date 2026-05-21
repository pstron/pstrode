代码量小，支持区间询问。

需要预先定义 `lg2` 函数，用于取 $\lfloor \log_2(i) \rfloor$ 。

1. 使用 C++20 的 `std::bit_width` （需要引入 `<bit>` 头文件）

    ```cpp
    constexpr int lg2(unsigned long x) {
        return std::bit_width(x) - 1;
    }
    ```

2. 使用内置函数 `__builtin_clzll`

    ```cpp
    constexpr int lg2(unsigned long long i) {
        return i ? __builtin_clzll(1) - __builtin_clzll(i) : -1;
    }
    ```

所需头文件：

- `<vector>`
- `<bit>` （可选，用于 `lg2` ）

```cpp
template <typename T, auto op>
struct st {
  std::vector<std::vector<T>> st_;
  explicit st(const std::vector<T>& v) {
    int n = (int)v.size(), l = lg2(n);
    st_.assign(l + 1, std::vector<T>(n, 0));
    for (int i = 0; i < n; ++i) {
      st_[0][i] = v[i];
    }
    for (int j = 1; j <= l; ++j) {
      for (int i = 0; i + (1 << j) <= n; ++i) {
        st_[j][i] = op(st_[j - 1][i], st_[j - 1][i + (1 << (j - 1))]);
      }
    }
  }
  T query(int l, int r) {
    int q = lg2(r - l + 1);
    return op(st_[q][l], st_[q][r - (1 << q) + 1]);
  }
};
```

对于 `op` ：

应当能够通过此断言

```cpp
static_assert(std::is_convertible_v<decltype(op), std::function<T(T, T)>>,
              "op must work as T(T, T)");
```

且必须满足以下性质

* **结合律**：`op(op(a, b), c) == op(a, op(b, c))`
* **可重复贡献**：`op(x, x) == x`

示例：

```cpp
st<int, [](int x, int y) { return std::max(x, y); }> st_max(a);
```

对类型为 `std::vector<int>` 的 `a` 建立 ST 表以回答区间 max 问题。

| 项目                   |             复杂度 |
| ---------------------- | -----------------: |
| 初始化 `st(v)`         | $\Theta(n \log n)$ |
| `query(l, r)`          |        $\Theta(1)$ |
| 结构自身占用空间       | $\Theta(n \log n)$ |

