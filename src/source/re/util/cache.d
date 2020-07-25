module re.util.cache;

import std.array;
import std.typecons;

/// represents a cache that associates string keys with items
struct KeyedCache(T) {
    private T[string] _cache;

    /// cache an item
    public void put(string key, T value) {
        _cache[key] = value;
    }

    /// check if an item is cached
    public Nullable!T get(string key) {
        if (key in _cache) {
            return Nullable!T(_cache[key]);
        }
        return Nullable!T.init;
    }

    /// get all items
    public T[] get_all() {
        return _cache.byValue().array;
    }

    /// clear cache
    public void drop() {
        _cache.clear();
    }
}

unittest {
    auto num_cache = KeyedCache!int();

    enum VAL_APPLE = 4;

    num_cache.put("apple", VAL_APPLE);

    immutable auto i1 = num_cache.get("apple");
    assert(!i1.isNull);
    assert(i1.get == VAL_APPLE);
    assert(num_cache.get_all.length == 1);

    num_cache.drop();

    immutable auto i2 = num_cache.get("apple");
    assert(i2.isNull);
}
