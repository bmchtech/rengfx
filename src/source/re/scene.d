module re.scene;

public import re.time;
import star.entity;
public static import raylib;

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
        ecsManager.update(dt);
    }

    public void draw() {
        raylib.ClearBackground(clearColor);
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
