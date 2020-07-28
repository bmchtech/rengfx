module re.util.rng;

import std.random;

static class Rng {
    public static std.random.Random rng;

    static this() {
    }

    public static float next_float() {
        return (cast(float) next() / cast(float) uint.max);
    }

    public static uint next() {
        auto val = rng.front;
        rng.popFront();
        return val;
    }

    public static int next_int() {
        return cast(int) next();
    }
}
