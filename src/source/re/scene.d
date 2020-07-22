module re.scene;

public static import raylib;

class Scene {
    public raylib.Color clearColor;

    this() {
        // initialize
    }

    protected void on_start() {

    }

    protected void unload() {

    }

    public void update() {

    }

    public void draw() {
        raylib.ClearBackground(clearColor);
    }

    public void begin() {
        on_start();
    }

    public void end() {
        unload();
    }
}
