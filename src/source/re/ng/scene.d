module re.ng.scene;

public import re.time;
static import raylib;
import re.gfx.renderable;
import re.ecs;

class Scene {
    public raylib.Color clearColor;
    protected EntityManager ecs;

    this() {
        // initialize
        ecs = new EntityManager();
    }

    protected void on_start() {

    }

    protected void unload() {

    }

    public void update() {
        auto dt = Time.deltaTime;

        // TODO: update components
    }

    public void draw() {
        raylib.ClearBackground(clearColor);

        // TODO: render components
    }

    public void begin() {
        // set up ecs
        ecs = new EntityManager;

        on_start();
    }

    public void end() {
        unload();

        ecs.destroy();
    }
}
