module re.util.rng;

import std.random;

static class Rng {
    public static std.random.Random rng;

    static this() {
    }

    public static uint next() {
        return rng.front;
    }

    public static int next_int() {
        return cast(int) next();
    }
}
