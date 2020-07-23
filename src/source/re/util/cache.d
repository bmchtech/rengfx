module re.util.cache;

import optional;

/// represents a cache that associates string keys with items
struct KeyedCache(T) {
    private T[string] _cache;

    /// cache an item
    void put(string key, T value) {
        _cache[key] = value;
    }

    /// check if an item is cached
    Optional!T get(string key) {
        if (key in _cache) {
            return some(_cache[key]);
        }
        return no!T;
    }

    /// clear cache
    void drop() {
        _cache.clear();
    }
}

unittest {
    auto num_cache = KeyedCache!int();

    enum VAL_APPLE = 4;

    num_cache.put("apple", VAL_APPLE);

    immutable auto i1 = num_cache.get("apple");
    assert(!i1.empty);
    assert(i1 == VAL_APPLE);

    num_cache.drop();

    immutable auto i2 = num_cache.get("apple");
    assert(i2.empty);
}
