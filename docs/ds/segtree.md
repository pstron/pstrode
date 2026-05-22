> 本模板代码以及文档来自于 ACL (AtCoder Library) 的 `segtree.hpp` 和 `lazy_segtree.hpp` 。
>
> 并且进行了一定简化处理。

线段树可用于处理**幺半群** $(S, \cdot: S \times S \to S, e \in S)$ ，即满足以下性质的代数结构：

- 结合律：对所有 $a, b, c \in S$，有 $(a \cdot b) \cdot c = a \cdot (b \cdot c)$
- 单位元存在性：对所有 $a \in S$，有 $a \cdot e = e \cdot a = a$

---

## 普通线段树

### 简介

给定一个长度为 $n$ 的数组，线段树可以在 $O(\log n)$ 时间内处理：

- 单点修改
- 查询区间积

---

### 代码

所需头文件：

- `<algorithm>`
- `<vector>`
- `<bit>`

!!! note
    `<bit>` 需要 C++20 标准。若无 C++20 标准，则应该自行实现 `std::bit_ceil` 和 `std::countr_zero` ：
    ```cpp
    unsigned int bit_ceil(unsigned int n) {
        unsigned int x = 1;
        while (x < (unsigned int)(n)) x *= 2;
        return x;
    }
    ```
    ```cpp
    int countr_zero(unsigned int n) {
        return __builtin_ctz(n);
    }
    ```

```cpp
template <class S, auto op, auto e> struct segtree {
    // static_assert(std::is_convertible_v<decltype(op), std::function<S(S, S)>>,
    //               "op must work as S(S, S)");
    // static_assert(std::is_convertible_v<decltype(e), std::function<S()>>,
    //               "e must work as S()");
    int n_, size, log;
    std::vector<S> d;
    void update(int k) { d[k] = op(d[2 * k], d[2 * k + 1]); }
    segtree() : segtree(0) {}
    explicit segtree(int n) : segtree(std::vector<S>(n, e())) {}
    explicit segtree(const std::vector<S>& v) : n_(int(v.size())) {
        size = (int)std::bit_ceil((unsigned int)(n_));
        log = std::countr_zero((unsigned int)size);
        d = std::vector<S>(2 * size, e());
        for (int i = 0; i < n_; i++) d[size + i] = v[i];
        for (int i = size - 1; i >= 1; i--) {
            update(i);
        }
    }

    void set(int p, S x) {
        // assert(0 <= p && p < n_);
        p += size;
        d[p] = x;
        for (int i = 1; i <= log; i++) update(p >> i);
    }

    S get(int p) const {
        // assert(0 <= p && p < n_);
        return d[p + size];
    }

    S prod(int l, int r) const {
        // assert(0 <= l && l <= r && r <= n_);
        S sml = e(), smr = e();
        l += size;
        r += size;

        while (l < r) {
            if (l & 1) sml = op(sml, d[l++]);
            if (r & 1) smr = op(d[--r], smr);
            l >>= 1;
            r >>= 1;
        }
        return op(sml, smr);
    }

    S all_prod() const { return d[1]; }

    template <bool (*f)(S)> int max_right(int l) const {
        return max_right(l, [](S x) { return f(x); });
    }
    template <class F> int max_right(int l, F f) const {
        // assert(0 <= l && l <= n_);
        // assert(f(e()));
        if (l == n_) return n_;
        l += size;
        S sm = e();
        do {
            while (l % 2 == 0) l >>= 1;
            if (!f(op(sm, d[l]))) {
                while (l < size) {
                    l = (2 * l);
                    if (f(op(sm, d[l]))) {
                        sm = op(sm, d[l]);
                        l++;
                    }
                }
                return l - size;
            }
            sm = op(sm, d[l]);
            l++;
        } while ((l & -l) != l);
        return n_;
    }

    template <bool (*f)(S)> int min_left(int r) const {
        return min_left(r, [](S x) { return f(x); });
    }
    template <class F> int min_left(int r, F f) const {
        // assert(0 <= r && r <= n_);
        // assert(f(e()));
        if (r == 0) return 0;
        r += size;
        S sm = e();
        do {
            r--;
            while (r > 1 && (r % 2)) r >>= 1;
            if (!f(op(d[r], sm))) {
                while (r < size) {
                    r = (2 * r + 1);
                    if (f(op(d[r], sm))) {
                        sm = op(d[r], sm);
                        r--;
                    }
                }
                return r + 1 - size;
            }
            sm = op(d[r], sm);
        } while ((r & -r) != r);
        return 0;
    }
};
```

---

### 示例

```cpp
// 区间和
auto sum_op = [](i64 x, i64 y) -> i64 { return x + y; };
auto sum_e  = []() -> i64 { return 0; };
segtree<i64, sum_op, sum_e> sum_seg(a);  // a 为 std::vector<i64>
sum_seg.set(2, 10);
i64 s = sum_seg.prod(1, 5);
```

---

### 二分操作

#### `max_right`

```cpp
(1) int seg.max_right<f>(int l)
(2) int seg.max_right<F>(int l, F f)
```

- (1)：在线段树上进行二分搜索。需要定义函数 `bool f(S x)`。  
- (2)：需要定义一个函数对象，该对象接受 `S` 类型的参数并返回 `bool`。

它返回一个索引 `r`，同时满足以下两个条件：

- `r = l` 或 `f(op(a[l], a[l + 1], ..., a[r - 1])) = true`
- `r = n` 或 `f(op(a[l], a[l + 1], ..., a[r])) = false`

如果 `f` 是单调的，那么这就是满足 `f(op(a[l], a[l + 1], ..., a[r - 1])) = true` 的最大 `r`。

约束条件：

- 当 `f` 以相同的参数被调用时，它会返回相同的值，即 `f` 没有副作用。
- `f(e()) = true`
- $0 \leq l \leq n$

#### `min_left`

```cpp
(1) int seg.min_left<f>(int r)
(2) int seg.min_left<F>(int r, F f)
```

- (1)：在线段树上进行二分搜索。需要定义函数 `bool f(S x)`。  
- (2)：需要定义一个函数对象，该对象接受 `S` 类型的参数并返回 `bool`。

它返回一个索引 `l`，同时满足以下两个条件：

- `l = r` 或 `f(op(a[l], a[l + 1], ..., a[r - 1])) = true`
- `l = 0` 或 `f(op(a[l - 1], a[l], ..., a[r - 1])) = false`

如果 `f` 是单调的，那么这就是满足 `f(op(a[l], a[l + 1], ..., a[r - 1])) = true` 的最小 `l`。

约束条件：

- 当 `f` 以相同的参数被调用时，它会返回相同的值，即 `f` 没有副作用。
- `f(e()) = true`
- $0 \leq r \leq n$

---

### 复杂度

| 项目              |      复杂度 |
|-------------------|------------:|
| 构造              | $O(n)$      |
| `set(p, x)`       | $O(\log n)$ |
| `prod(l, r)`      | $O(\log n)$ |
| `all_prod()`      | $O(1)$      |
| `get(p)`          | $O(1)$      |
| `max_right(l, f)` | $O(\log n)$ |
| `min_left(r, f)`  | $O(\log n)$ |
| 空间占用          | $\Theta(n)$ |

> 若 `op` 或 `e` 的调用耗时 $O(T)$，则上述时间复杂度均需乘 $O(T)$。

---

## 懒惰线段树

### 简介

懒惰线段树（Lazy Segment Tree）是在普通线段树的基础上，进一步支持**区间作用**与**区间查询**的数据结构。

它维护的是一组幺半群 $S$，以及一组作用在 $S$ 上的映射集合 $F$。与普通线段树相比，它除了要求区间合并满足幺半群性质外，还要求映射集合满足以下条件：

- `id` 是恒等映射，即对任意 $x\in S$，有

  $$
  \mathrm{id}(x)=x
  $$

- `comp` 对 $F$ 封闭，且满足结合律，即 $F$ 在 `comp` 下构成幺半群

- `app` 保持区间合并结构，即对任意 $f\in F$ 与 $x,y\in S$，有

  $$
  f(x\cdot y)=f(x)\cdot f(y)
  $$

另外，`comp(f,g)` 表示映射复合 $f\circ g$，即**先作用 `g`，再作用 `f`**：

$$
\text{app}(\text{comp}(f,g),x)
=
\text{app}(f,\text{app}(g,x))
$$

这样就可以在 $O(\log n)$ 时间内完成：

- 对区间整体施加映射
- 查询区间积

---

### 代码

所需头文件：

- `<algorithm>`
- `<vector>`
- `<bit>`


!!! note
    `<bit>` 需要 C++20 标准。若无 C++20 标准，则应该自行实现 `std::bit_ceil` 和 `std::countr_zero` ：
    ```cpp
    unsigned int bit_ceil(unsigned int n) {
        unsigned int x = 1;
        while (x < (unsigned int)(n)) x *= 2;
        return x;
    }
    ```
    ```cpp
    int countr_zero(unsigned int n) {
        return __builtin_ctz(n);
    }
    ```

```cpp
template <class S,
          auto op,
          auto e,
          class F,
          auto app,
          auto comp,
          auto id>
struct lazy_segtree {
    // static_assert(std::is_convertible_v<decltype(op), std::function<S(S, S)>>,
    //               "op must work as S(S, S)");
    // static_assert(std::is_convertible_v<decltype(e), std::function<S()>>,
    //               "e must work as S()");
    // static_assert(
    //     std::is_convertible_v<decltype(app), std::function<S(F, S)>>,
    //     "app must work as S(F, S)");
    // static_assert(
    //     std::is_convertible_v<decltype(comp), std::function<F(F, F)>>,
    //     "comp must work as F(F, F)");
    // static_assert(std::is_convertible_v<decltype(id), std::function<F()>>,
    //               "id must work as F()");
    int _n, size, log;
    std::vector<S> d;
    std::vector<F> lz;
    void update(int k) { d[k] = op(d[2 * k], d[2 * k + 1]); }
    void all_apply(int k, F f) {
        d[k] = app(f, d[k]);
        if (k < size) lz[k] = comp(f, lz[k]);
    }
    void push(int k) {
        all_apply(2 * k, lz[k]);
        all_apply(2 * k + 1, lz[k]);
        lz[k] = id();
    }
    lazy_segtree() : lazy_segtree(0) {}
    explicit lazy_segtree(int n) : lazy_segtree(std::vector<S>(n, e())) {}
    explicit lazy_segtree(const std::vector<S>& v) : _n(int(v.size())) {
        size = (int)std::bit_ceil((unsigned int)(_n));
        log = std::countr_zero((unsigned int)size);
        d = std::vector<S>(2 * size, e());
        lz = std::vector<F>(size, id());
        for (int i = 0; i < _n; i++) d[size + i] = v[i];
        for (int i = size - 1; i >= 1; i--) {
            update(i);
        }
    }

    void set(int p, S x) {
        // assert(0 <= p && p < _n);
        p += size;
        for (int i = log; i >= 1; i--) push(p >> i);
        d[p] = x;
        for (int i = 1; i <= log; i++) update(p >> i);
    }

    S get(int p) {
        // assert(0 <= p && p < _n);
        p += size;
        for (int i = log; i >= 1; i--) push(p >> i);
        return d[p];
    }

    S prod(int l, int r) {
        // assert(0 <= l && l <= r && r <= _n);
        if (l == r) return e();

        l += size;
        r += size;

        for (int i = log; i >= 1; i--) {
            if (((l >> i) << i) != l) push(l >> i);
            if (((r >> i) << i) != r) push((r - 1) >> i);
        }

        S sml = e(), smr = e();
        while (l < r) {
            if (l & 1) sml = op(sml, d[l++]);
            if (r & 1) smr = op(d[--r], smr);
            l >>= 1;
            r >>= 1;
        }

        return op(sml, smr);
    }

    S all_prod() { return d[1]; }

    void apply(int p, F f) {
        // assert(0 <= p && p < _n);
        p += size;
        for (int i = log; i >= 1; i--) push(p >> i);
        d[p] = app(f, d[p]);
        for (int i = 1; i <= log; i++) update(p >> i);
    }
    void apply(int l, int r, F f) {
        // assert(0 <= l && l <= r && r <= _n);
        if (l == r) return;

        l += size;
        r += size;

        for (int i = log; i >= 1; i--) {
            if (((l >> i) << i) != l) push(l >> i);
            if (((r >> i) << i) != r) push((r - 1) >> i);
        }

        {
            int l2 = l, r2 = r;
            while (l < r) {
                if (l & 1) all_apply(l++, f);
                if (r & 1) all_apply(--r, f);
                l >>= 1;
                r >>= 1;
            }
            l = l2;
            r = r2;
        }

        for (int i = 1; i <= log; i++) {
            if (((l >> i) << i) != l) update(l >> i);
            if (((r >> i) << i) != r) update((r - 1) >> i);
        }
    }

    template <bool (*g)(S)> int max_right(int l) {
        return max_right(l, [](S x) { return g(x); });
    }
    template <class G> int max_right(int l, G g) {
        // assert(0 <= l && l <= _n);
        // assert(g(e()));
        if (l == _n) return _n;
        l += size;
        for (int i = log; i >= 1; i--) push(l >> i);
        S sm = e();
        do {
            while (l % 2 == 0) l >>= 1;
            if (!g(op(sm, d[l]))) {
                while (l < size) {
                    push(l);
                    l = (2 * l);
                    if (g(op(sm, d[l]))) {
                        sm = op(sm, d[l]);
                        l++;
                    }
                }
                return l - size;
            }
            sm = op(sm, d[l]);
            l++;
        } while ((l & -l) != l);
        return _n;
    }

    template <bool (*g)(S)> int min_left(int r) {
        return min_left(r, [](S x) { return g(x); });
    }
    template <class G> int min_left(int r, G g) {
        // assert(0 <= r && r <= _n);
        // assert(g(e()));
        if (r == 0) return 0;
        r += size;
        for (int i = log; i >= 1; i--) push((r - 1) >> i);
        S sm = e();
        do {
            r--;
            while (r > 1 && (r % 2)) r >>= 1;
            if (!g(op(d[r], sm))) {
                while (r < size) {
                    push(r);
                    r = (2 * r + 1);
                    if (g(op(d[r], sm))) {
                        sm = op(d[r], sm);
                        r--;
                    }
                }
                return r + 1 - size;
            }
            sm = op(d[r], sm);
        } while ((r & -r) != r);
        return 0;
    }
};
```

---

### 使用说明

构造懒惰线段树时，需要自行定义以下内容：

- `S`：线段树节点维护的值
- `op(S, S)`：区间合并函数
- `e()`：幺元
- `F`：懒标记类型
- `app(F, S)`：懒标记对节点的作用
- `comp(F, F)`：懒标记合成 $f\circ g$，表示先作用第二个参数，再作用第一个参数
- `id()`：懒标记单位元

其中最关键的是 `app` 与 `comp` 的定义要与题意一致。

---

### 示例

#### 区间加、区间和

```cpp
struct S {
    i64 sum;
    int len;
};

auto op = [](S x, S y) -> S {
    return S{ x.sum + y.sum, x.len + y.len };
};

auto e = []() -> S {
    return S{ 0, 0 };
};

using F = i64;

auto app = [](F f, S s) -> S {
    return S{ s.sum + f * s.len, s.len };
};

auto comp = [](F f, F g) -> F {
    return f + g;
};

auto id = []() -> F {
    return 0;
};

std::vector<S> v(n);
for (int i = 0; i < n; ++i) {
    v[i] = S{a[i], 1};
}

lazy_segtree<S, op, e, F, app, comp, id> seg(v);
seg.apply(l, r, 3);
i64 ans = seg.prod(l, r).sum;
```

---

### 二分操作

懒惰线段树同样支持在区间上进行二分搜索。

#### `max_right`

```cpp
(1) int seg.max_right<g>(int l)
(2) int seg.max_right<G>(int l, G g)
```

- (1)：在线段树上进行二分搜索。需要定义函数 `bool g(S x)`。
- (2)：需要定义一个函数对象，该对象接受 `S` 类型的参数并返回 `bool`。

它返回一个索引 `r`，同时满足以下两个条件：

- `r = l` 或 `g(op(a[l], a[l + 1], ..., a[r - 1])) = true`
- `r = n` 或 `g(op(a[l], a[l + 1], ..., a[r])) = false`

如果 `g` 是单调的，那么这就是满足 `g(op(a[l], a[l + 1], ..., a[r - 1])) = true` 的最大 `r`。

约束条件：

- 当 `g` 以相同的参数被调用时，它会返回相同的值，即 `g` 没有副作用。
- `g(e()) = true`
- $0 \leq l \leq n$

#### `min_left`

```cpp
(1) int seg.min_left<g>(int r)
(2) int seg.min_left<G>(int r, G g)
```

- (1)：在线段树上进行二分搜索。需要定义函数 `bool g(S x)`。
- (2)：需要定义一个函数对象，该对象接受 `S` 类型的参数并返回 `bool`。

它返回一个索引 `l`，同时满足以下两个条件：

- `l = r` 或 `g(op(a[l], a[l + 1], ..., a[r - 1])) = true`
- `l = 0` 或 `g(op(a[l - 1], a[l], ..., a[r - 1])) = false`

如果 `g` 是单调的，那么这就是满足 `g(op(a[l], a[l + 1], ..., a[r - 1])) = true` 的最小 `l`。

约束条件：

- 当 `g` 以相同的参数被调用时，它会返回相同的值，即 `g` 没有副作用。
- `g(e()) = true`
- $0 \leq r \leq n$

---

### 复杂度

| 项目              |      复杂度 |
| ----------------- | ----------: |
| 构造              |      $O(n)$ |
| `set(p, x)`       | $O(\log n)$ |
| `get(p)`          | $O(\log n)$ |
| `prod(l, r)`      | $O(\log n)$ |
| `all_prod()`      |      $O(1)$ |
| `apply(p, f)`     | $O(\log n)$ |
| `apply(l, r, f)`  | $O(\log n)$ |
| `max_right(l, f)` | $O(\log n)$ |
| `min_left(r, f)`  | $O(\log n)$ |
| 空间占用          | $\Theta(n)$ |

> 若 `op`、`e`、`app`、`comp` 或 `id` 的调用耗时为 $O(T)$，则上述时间复杂度均需乘上 $O(T)$。
