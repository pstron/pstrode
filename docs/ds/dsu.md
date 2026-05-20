## 简单版本

代码量小，有路径压缩。

所需头文件：

- `<vector>`
- `<numeric>`

```cpp
struct dsu {
  std::vector<int> pa;
  explicit dsu(int n) : pa(n) {
    std::iota(pa.begin(), pa.end(), 0);
  }
  int find(int x) {
    return pa[x] == x ? x : pa[x] = find(pa[x]);
  }
  bool unite(int x, int y) {
    x = find(x), y = find(y);
    if (x == y) return false;
    pa[y] = x;
    return true;
  }
};
```

| 项目                       | 复杂度           |
| -------------------------- | ---------------: |
| 初始化 `dsu(n)`            |      $\Theta(n)$ |
| `find(x)` 单次最坏         |      $\Theta(n)$ |
| `find(x)` 均摊             |      $O(\log n)$ |
| `unite(x, y)` 单次最坏     |      $\Theta(n)$ |
| `unite(x, y)` 均摊         |      $O(\log n)$ |
| m 次合并操作总时间         | $O(n + m\log n)$ |
| 结构自身占用空间           |      $\Theta(n)$ |
| `find` 递归栈最坏额外空间  |      $\Theta(n)$ |


## 进阶版本

有路径压缩和按大小合并。用额外空间维护大小信息。

`size[x]` 可查询连通块大小。

所需头文件：

- `<vector>`
- `<numeric>`
- `<utility>`

```cpp
struct dsu {
  std::vector<int> pa, size;
  explicit dsu(int n) : pa(n), size(n, 1) {
    std::iota(pa.begin(), pa.end(), 0);
  }
  int find(int x) {
    return pa[x] == x ? x : pa[x] = find(pa[x]);
  }
  bool unite(int x, int y) {
    x = find(x), y = find(y);
    if (x == y) return false;
    if (size[x] < size[y]) std::swap(x, y);
    pa[y] = x;
    size[x] += size[y];
    return true;
  }
};
```

| 项目                       | 复杂度              |
| -------------------------- | ------------------: |
| 初始化 `dsu(n)`            |         $\Theta(n)$ |
| `find(x)` 单次最坏         |    $\Theta(\log n)$ |
| `find(x)` 均摊             |      $O(\alpha(n))$ |
| `unite(x, y)` 单次最坏     |    $\Theta(\log n)$ |
| `unite(x, y)` 均摊         |      $O(\alpha(n))$ |
| m 次合并操作总时间         | $O(n + m\alpha(n))$ |
| 结构自身占用空间           |         $\Theta(n)$ |
| `find` 递归栈最坏额外空间  |    $\Theta(\log n)$ |


## ACL DSU

来自 AtCoder Library 的 DSU ，功能强大。

在原版的基础上简化了代码量，并且统一命名风格。

所需头文件：

- `<vector>`
- `<algorithm>`

```cpp
struct dsu {
  int n_;
  std::vector<int> ps;
  dsu() : n_(0) {}
  explicit dsu(int n) : n_(n), ps(n, -1) {}
  int find(int a) {
    if (ps[a] < 0) return a;
    return ps[a] = find(ps[a]);
  }
  int unite(int a, int b) {
    int x = find(a), y = find(b);
    if (x == y) return x;
    if (-ps[x] < -ps[y]) std::swap(x, y);
    ps[x] += ps[y];
    ps[y] = x;
    return x;
  }
  bool same(int a, int b) {
    return find(a) == find(b);
  }
  int size(int a) {
    return -ps[find(a)];
  }
  std::vector<std::vector<int>> groups() {
    std::vector<int> root(n_), gsize(n_);
    for (int i = 0; i < n_; ++i) {
      root[i] = find(i);
      ++gsize[root[i]];
    }
    std::vector<std::vector<int>> res(n_);
    for (int i = 0; i < n_; ++i) {
      res[i].reserve(gsize[i]);
    }
    for (int i = 0; i < n_; ++i) {
      res[root[i]].push_back(i);
    }
    res.erase(
        std::remove_if(res.begin(), res.end(),
                       [&](const std::vector<int>& v) { return v.empty(); }),
        res.end());
    return res;
  }
};
```

| 项目                       | 复杂度           |
| -------------------------- | ---------------: |
| 默认构造 `dsu()`           |      $\Theta(1)$ |
| 初始化 `dsu(n)`            |      $\Theta(n)$ |
| `find(a)` 单次最坏         | $\Theta(\log n)$ |
| `find(a)` 均摊             |   $O(\alpha(n))$ |
| `unite(a, b)` 单次最坏     | $\Theta(\log n)$ |
| `unite(a, b)` 均摊         |   $O(\alpha(n))$ |
| `same(a, b)` 单次最坏      | $\Theta(\log n)$ |
| `same(a, b)` 均摊          |   $O(\alpha(n))$ |
| `size(a)` 单次最坏         | $\Theta(\log n)$ |
| `size(a)` 均摊             |   $O(\alpha(n))$ |
| `groups()` 总时间          | $O(n \alpha(n))$ |
| 结构自身占用空间           |      $\Theta(n)$ |
| `find` 递归栈最坏额外空间  | $\Theta(\log n)$ |


## 说明

- $\alpha(n)$ 是反阿克曼函数，增长极慢，实际可视为常数。

