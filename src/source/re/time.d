module re.time;
static import raylib;

/// utility class for time calculations
class Time {
    /// the time elapsed since the last update (a.k.a. dt)
    static @property float delta_time() {
        return raylib.GetFrameTime();
    }
}