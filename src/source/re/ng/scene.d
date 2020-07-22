module re.ng.scene;

public import re.time;
static import raylib;
import re.gfx.renderable;
import re.ecs;
import re.ng.updatable;
import re.ng.renderable;

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
        foreach (nt; ecs.entities) {
            foreach (component; nt.components) {
                if (is(component : Updatable)) {
                    auto updatable = cast(Updatable) component;
                    updatable.update();
                }
            }
        }
    }

    public void draw() {
        raylib.ClearBackground(clearColor);

        // TODO: render components
        foreach (nt; ecs.entities) {
            foreach (component; nt.components) {
                if (is(component : Renderable)) {
                    auto renderable = cast(Renderable) component;
                    renderable.render();
                }
            }
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
}
