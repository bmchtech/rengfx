module re.scene;

class Scene {
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

    }

    public void begin() {
        on_start();
    }

    public void end() {
        unload();
    }
}
