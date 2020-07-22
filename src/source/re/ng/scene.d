module re.ng.scene;

public import re.time;
static import raylib;
import re;
import std.string;
import re.ecs;
import re.math;

class Scene {
    public raylib.Color clear_color;
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
        foreach (component; ecs.storage.updatable_components) {
            auto updatable = cast(Updatable) component;
            updatable.update();
        }
    }

    public void draw() {
        raylib.ClearBackground(clear_color);

        // TODO: render components
        foreach (component; ecs.storage.renderable_components) {
            auto renderable = cast(Renderable) component;
            renderable.render();
        }
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

    // - ecs

    public Entity create_entity(string name) {
        auto nt = ecs.create_entity();
        nt.name = name;
        return nt;
    }

    public Entity create_entity(string name, Vector2 pos = Vector2(0, 0)) {
        auto nt = create_entity(name);
        nt.position2 = pos;
        return nt;
    }

    public Entity create_entity(string name, Vector3 pos = Vector3(0, 0, 0)) {
        auto nt = create_entity(name);
        nt.position = pos;
        return nt;
    }
}
