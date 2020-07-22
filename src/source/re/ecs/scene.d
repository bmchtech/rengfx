module re.ecs.scene;

public import re.time;
import star.entity;
static import raylib;
import re.ecs.renderable;

class Scene {
    public raylib.Color clearColor;
    private star.entity.Engine ecsManager;

    this() {
        // initialize
    }

    protected void on_start() {

    }

    protected void unload() {

    }

    public void update() {
        auto dt = Time.deltaTime;

        // ecs update
        // ecsManager.systems.update(cast(double) dt);
    }

    public void draw() {
        raylib.ClearBackground(clearColor);

        // render components
        foreach (entity; ecsManager.entities.entities!(Renderable)) {
            auto renderable = entity.component!Renderable();
            renderable.render();
        }
    }

    public void begin() {
        // set up ecs
        ecsManager = new star.entity.Engine;

        on_start();
    }

    public void end() {
        unload();
    }

    // - ecs

    public Entity create_entity() {
        return ecsManager.entities.create();
    }
}
