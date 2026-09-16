## 字典树（Trie）

### 简介

字典树（Trie，前缀树）可用于维护字符串集合。还可以维护前缀等信息。

### 代码

所需头文件：

- `<array>`
- `<vector>`
- `<string_view>`

```cpp
struct trie {
    struct node {
        std::array<int, 26> next;
        int cnt = 0;
        node() {
            next.fill(-1);
        }
    };
    std::vector<node> tree;
    trie() {
        tree.emplace_back();
    }
    void insert(std::string_view sv) {
        int p = 0;
        for (auto c : sv) {
            int idx = c - 'a';
            if (tree[p].next[idx] == -1) {
                tree[p].next[idx] = static_cast<int>(tree.size());
                tree.emplace_back();
            }
            p = tree[p].next[idx];
        }
        ++tree[p].cnt;
    }
    int query(std::string_view sv) const {
        int p = 0;
        for (auto c : sv) {
            int idx = c - 'a';
            if (tree[p].next[idx] == -1) {
                return 0;
            }
            p = tree[p].next[idx];
        }
        return tree[p].cnt;
    }
};
```

### 复杂度

设字符集大小为 $\sigma$，本实现中 $\sigma=26$。  
设 $L$ 为当前 `insert` 或 `query` 的字符串长度，$N$ 为 Trie 中节点总数（含根），$m$ 为所有插入字符串的总长度，$M$ 为所有查询字符串的总长度。

| 项目                 | 复杂度               |
| ------------------ | -----------------:|
| 初始化 `trie()`       | $\Theta(\sigma)$  |
| 新建一个节点（均摊）         | $\Theta(\sigma)$  |
| `insert(sv)` 单次最坏  | $\Theta(L\sigma)$ |
| `query(sv)` 单次最坏   | $\Theta(L)$       |
| 插入总长度 $m$、总节点数 $N$ | $O(m + N\sigma)$  |
| 查询总长度 $M$          | $O(M)$            |
| 结构自身占用空间           | $\Theta(N\sigma)$ |
