/** math funcs */

module re.math.funcs;

import std.math;
import re.util.rng;

public static class Distribution {
    public static float exponentialDf(float x, float m) {
        return exp(-x * m);
    }

    /// <summary>
    /// selects a random value using a normal distribution
    /// </summary>
    /// <param name="u">mean value</param>
    /// <param name="s">standard deviation</param>
    /// <returns></returns>
    public static float normalRand(float u, float s) {
        // https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform
        // https://stackoverflow.com/a/218600
        auto u1 = 1.0f - Rng.next_float();
        auto u2 = 1.0f - Rng.next_float();
        auto dst = sqrt(-2f * log(u1)) * sin(2f * PI * u2);
        auto v = u + s * dst;
        return v;
    }

    public static float[] summarizeDistribution(float[] values) {
        import std.algorithm.sorting : sort;
        import std.algorithm.iteration : sum;

        auto sorted = values.sort();
        auto val_sum = sorted.sum();
        auto mean = val_sum / sorted.length;
        auto min = sorted[0];
        auto max = sorted[sorted.length - 1];
        auto q1 = sorted[cast(int)(sorted.length * 0.25)];
        auto q2 = sorted[cast(int)(sorted.length * 0.50)];
        auto q3 = sorted[cast(int)(sorted.length * 0.75)];
        return [mean, min, q1, q2, q3, max];
    }
}
