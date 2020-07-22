module re.time;
static import raylib;

class Time {
    static @property float deltaTime() {
        return raylib.GetFrameTime();
    }
}