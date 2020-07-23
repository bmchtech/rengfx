module re.util.jar;

import std.array;
import std.typecons;

class Jar {
    private Object[][TypeInfo] _instance_registry;

    public T register(T)(T instance) {
        auto type = typeid(instance);
        if (type !in _instance_registry) {
            _instance_registry[type] = new Object[0];
        }
        _instance_registry[type] ~= instance;
        return instance;
    }

    public T[] resolve_all(T)() {
        auto type = typeid(T);
        if (type in _instance_registry) {
            Appender!(T[]) resolved;
            foreach (item; _instance_registry[type]) {
                resolved ~= cast(T) item;
            }
            return resolved.data;
        }
        return new T[0];
    }

    public Nullable!T resolve(T)() {
        auto items = resolve_all!T();
        if (items.length > 0) {
            return Nullable!T(items[0]);
        }
        return Nullable!T.init;
    }
}

unittest {
    class Cookie {
        bool delicious = true;
    }

    auto jar = new Jar();

    auto c1 = new Cookie();
    jar.register(c1);
    auto r1 = jar.resolve!Cookie();
    assert(!r1.isNull, "resolved item was null");
    assert(r1.get() == c1, "resolved item did not match");

    auto c2 = new Cookie();
    jar.register(c2);
    
    auto cookies = jar.resolve_all!Cookie();
    assert(cookies.length == 2, "mismatch in number of registered items");
}
