module re.ng.scene;

public import re.time;
static import raylib;
import re;
import std.string;
import re.ecs;
import re.math;

/// represents a collection of entities that draw to a texture
class Scene {
    /// the cleared background color
    public raylib.Color clear_color;
    protected EntityManager ecs;

    /// creates a new scene
    this() {
        // initialize
        ecs = new EntityManager();
    }

    /// called at the start of the scene
    protected void on_start() {

    }

    /// called right before cleanup
    protected void unload() {

    }

    /// called internally to update ecs
    public void update() {
        auto dt = Time.delta_time;

        // TODO: update components
        foreach (component; ecs.storage.updatable_components) {
            auto updatable = cast(Updatable) component;
            updatable.update();
        }
    }

    /// called internally to render ecs
    public void draw() {
        raylib.ClearBackground(clear_color);

        // TODO: render components
        foreach (component; ecs.storage.renderable_components) {
            auto renderable = cast(Renderable) component;
            renderable.render();
            if (Core.debug_render) {
                renderable.debug_render();
            }
        }
    }

    /// called internally on scene creation
    public void begin() {
        // set up ecs
        ecs = new EntityManager;

        on_start();
    }

    /// called internally on scene destruction
    public void end() {
        unload();

        ecs.destroy();
    }

    // - ecs

    /// create an entity given a name
    public Entity create_entity(string name) {
        auto nt = ecs.create_entity();
        nt.name = name;
        return nt;
    }

    /// create an entity given a name and a 2d position
    public Entity create_entity(string name, Vector2 pos = Vector2(0, 0)) {
        auto nt = create_entity(name);
        nt.position2 = pos;
        return nt;
    }

    /// create an entity given a name and a 3d position
    public Entity create_entity(string name, Vector3 pos = Vector3(0, 0, 0)) {
        auto nt = create_entity(name);
        nt.position = pos;
        return nt;
    }
}
