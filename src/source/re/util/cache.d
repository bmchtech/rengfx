module re.util.cache;

import std.array;
import std.typecons;

/// represents a cache that associates string keys with items
struct KeyedCache(T) {
    private T[string] _cache;
    void delegate(T) _free;

    this(void delegate(T) on_free) {
        _free = on_free;
    }

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
        // run free on each item
        if (_free !is null) {
            foreach (item; get_all()) {
                _free(item);
            }
        }
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

unittest {
    auto resources_used = 0;
    auto res_cache = KeyedCache!int((x) { resources_used += x; });

    enum handle = 3;
    res_cache.put("handle", handle);

    res_cache.drop();
    assert(res_cache.get_all.length == 0);

    assert(resources_used > 0, "free was not called");
}
