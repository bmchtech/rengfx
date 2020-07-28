module source.re.util.dual_map;

class DualMap(T1, T2) {
    public T2[T1] map1;
    public T1[T2] map2;

    public void set(T1 key1, T2 key2) {
        map1[key1] = key2;
        map2[key2] = key1;
    }

    public T2 get(T1 key1) {
        return map1[key1];
    }

    public T1 get(T2 key2) {
        return map2[key2];
    }

    public bool has(T1 key1) {
        return cast(bool)(key1 in map1);
    }

    public bool has(T2 key2) {
        return cast(bool)(key2 in map2);
    }

    public bool remove(T1 key1, T2 key2) {
        return map1.remove(key1) && map2.remove(key2);
    }

    public bool remove(T1 key1) {
        auto key2 = get(key1);
        return remove(key1, key2);
    }

    public bool remove(T2 key2) {
        auto key1 = get(key2);
        return remove(key1, key2);
    }

    public void clear() {
        map1.clear();
        map2.clear();
    }

    @property public size_t count() {
        assert(map1.length == map2.length, "maps are out of sync");
        return map1.length;
    }
}

@("util-dualmap")
unittest {
    auto dm = new DualMap!(string, int)();

    dm.set("sunday", 0);
    dm.set("monday", 1);
    dm.set("tuesday", 2);

    assert(dm.get(1) == "monday");
    assert(dm.get("tuesday") == 2);
    assert(dm.count == 3);

    assert(dm.has("monday"));
    assert(dm.has(2));

    assert(dm.remove("tuesday"));
    assert(dm.remove(1));

    assert(dm.count == 1);
    assert(!dm.has(1));

    dm.clear();
    assert(dm.count == 0);
}
