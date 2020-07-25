module re.time;
static import raylib;

/// utility class for time calculations
class Time {
    /// the time elapsed since the last update (a.k.a. dt)
    public static float delta_time = 0;
    /// unscaled delta time
    public static float raw_delta_time = 0;
    /// total elapsed time
    public static float total_time = 0;
    /// time scale to apply to delta time
    public static float time_scale = 1;
    /// frame count
    public static uint frame_count = 0;

    /// internally used to update the time counters
    public static void update(float dt) {
        total_time += dt;
        delta_time = dt * time_scale;
        raw_delta_time = dt;
        frame_count++;
    }
}
