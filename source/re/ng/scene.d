/** represents a set of things to be drawn to screen */

module re.ng.scene;

import re;
import std.string;
import re.ecs;
import re.gfx;
import re.math;
import re.ng.manager;
import std.typecons;
import std.range;
static import raylib;

public {
    import re.time;
    import re.ng.scene2d;
    import re.ng.scene3d;
    import re.ng.viewport;
}

/// represents a collection of entities that draw to a texture
abstract class Scene {
    /// the cleared background color
    public raylib.Color clear_color = Colors.WHITE;
    /// the entity manager
    public EntityManager ecs;
    private Vector2 _resolution;
    /// the mode of compositing
    public CompositeMode composite_mode;
    /// postprocessors effects
    public PostProcessor[] postprocessors;
    /// updatable managers
    public Manager[] managers;
    /// viewports
    public Viewport[] viewports;
    /// whether to use a single default viewport
    public bool use_default_viewport = true;

    /// the mode for compositing a scene onto the display buffer
    public struct CompositeMode {
        /// the texture render tint color
        raylib.Color color = raylib.Colors.WHITE;
    }

    /// creates a new scene
    this() {
    }

    /// gets the render resolution. initialized to Core.default_resolution
    @property Vector2 resolution() {
        return _resolution;
    }

    /// sets the render resolution and updates the render target
    @property Vector2 resolution(Vector2 value) {
        _resolution = value;
        update_render_target();
        return value;
    }

    /// called at the start of the scene
    protected void on_start() {

    }

    /// called right before cleanup
    protected void unload() {

    }

    void update_updatable(Component component) {
        auto updatable = cast(Updatable) component;
        updatable.update();
    }

    /// called internally to update ecs. can be overridden, but super.update() must be called.
    public void update() {
        // update ecs
        ecs.update();

        // update managers
        foreach (manager; managers) {
            manager.update();
        }

        // update components
        foreach (component; ecs.storage.updatable_components) {
            update_updatable(component);
        }
        foreach (component; ecs.storage.updatable_renderable_components) {
            update_updatable(component);
        }

        // update viewports
        foreach (viewport; viewports) {
            viewport.update();
        }
    }

    /// called internally to render ecs
    public void render() {
        foreach (viewport; viewports) {
            raylib.BeginTextureMode(viewport.render_target);
            raylib.ClearBackground(clear_color);
            
            render_scene(viewport);

            raylib.EndTextureMode();
        }
    }

    /// run postprocessors
    public void post_render() {
        import std.algorithm : filter;
        import std.array : array;

        auto pipeline = postprocessors.filter!(x => x.enabled).array;
        // skip if no postprocessors
        if (pipeline.length == 0)
            return;

        foreach (viewport; viewports) {
            pipeline[0].process(viewport.render_target);
            auto last_buf = pipeline[0].buffer;
            for (auto i = 1; i < pipeline.length; i++) {
                auto postprocessor = pipeline[i];
                postprocessor.process(last_buf);
                last_buf = postprocessor.buffer;
            }
            // draw the last buf in the chain to the main texture
            RenderExt.draw_render_target_from(last_buf, viewport.render_target);
        }
    }

    protected abstract void render_scene(Viewport viewport);

    /// may optionally be used to render global things from a scene
    protected void render_hook() {
    }

    /// recreate the render target
    private void update_render_target() {
        if (Core.headless)
            return;
        
        // // free any old render target
        // if (render_target != RenderTarget.init) {
        //     RenderExt.destroy_render_target(render_target);
        // }
        // // create render target
        // // TODO: use scene resolution instead of window resolution
        // render_target = RenderExt.create_render_target(
        //     cast(int) resolution.x, cast(int) resolution.y
        // );
        // Core.log.info(format("recreated render target of size %s", resolution));
        // // apply texture filter
        // raylib.SetTextureFilter(render_target.texture, Core.default_filter_mode);

        foreach (viewport; viewports) {
            // free any old render target
            if (viewport.render_target != RenderTarget.init) {
                RenderExt.destroy_render_target(viewport.render_target);
            }

            if (viewport.sync_maximized) {
                // copy output rect from screen bounds
                viewport.output_rect = Core.window.screen_bounds;
                viewport.resolution = resolution; // copy resolution
                Core.log.info(format("synced viewport to screen bounds: %s", viewport.output_rect));
            }

            // create render target
            viewport.render_target = RenderExt.create_render_target(
                cast(int) viewport.resolution.x, cast(int) viewport.resolution.y
            );
        }
    }

    abstract void create_default_viewport();

    void reset_viewports() {
        foreach (vp; viewports) {
            vp.destroy();
        }
        viewports.length = 0;
    }

    /// called internally on scene creation
    public void begin() {
        setup();

        on_start();
    }

    /// setup that hapostprocessorsens after begin, but before the child scene starts
    protected void setup() {
        // set up ecs
        ecs = new EntityManager;

        resolution = Core.default_resolution;

        if (use_default_viewport) {
            // create default viewport
            create_default_viewport();
        }
    }

    /// called internally on scene destruction
    public void end() {
        unload();

        ecs.destroy();
        ecs = null;

        foreach (postprocessor; postprocessors) {
            postprocessor.destroy();
        }
        postprocessors = [];

        foreach (manager; managers) {
            manager.destroy();
        }

        if (!Core.headless) {
            // destroy viewports
            foreach (viewport; viewports) {
                viewport.destroy();
            }
        }
    }

    /// window resize event
    void on_window_resized() {
        // if the option is enabled, resize the render target to the new window size
        if (Core.sync_render_target_to_window_resolution) {
            // the setter will also trigger update_render_target
            resolution = Core.default_resolution;
        }
    }

    public Nullable!T get_manager(T)() {
        import std.algorithm.searching : find;

        // find a manager matching the type
        auto matches = managers.find!(x => (cast(T) x) !is null);
        if (matches.length > 0) {
            return Nullable!T(cast(T) matches.front);
        }
        return Nullable!T.init;
    }

    /// adds a manager to this scene
    public T add_manager(T)(T manager) {
        managers ~= manager;
        manager.scene = this;
        manager.setup();
        return manager;
    }

    // - ecs

    /// create an entity given a name
    public Entity create_entity(string name) {
        auto nt = ecs.create_entity();
        nt.name = name;
        nt.scene = this;
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

    public Entity get_entity(string name) {
        return ecs.get_entity(name);
    }
}

@("scene-lifecycle")
unittest {
    class TestScene : Scene2D {
        override void on_start() {
            auto apple = create_entity("apple");
            assert(get_entity("apple") == apple, "could not get entity by name");
        }
    }

    Core.headless = true;
    auto scene = new TestScene();
    scene.begin();
    scene.update();
    scene.end();
}

@("scene-load")
unittest {
    class TestScene : Scene2D {
    }

    Core.headless = true;

    auto scene = new TestScene();
    Core.load_scenes([scene]);
    assert(Core.get_scene!TestScene == scene);
}

/// create a test game, with a test scene, and update it
@("scene-full")
unittest {
    import re.util.test : TestGame;

    static class TestScene : Scene2D {
        class Plant : Component, Updatable {
            public int height = 0;

            void update() {
                height++;
            }
        }

        override void on_start() {
            // create a basic entity
            auto nt = create_entity("apple");
            // add a basic component
            nt.add_component(new Plant());
        }
    }

    auto my_scene = new TestScene();

    class Game : TestGame {
        override void initialize() {
            load_scenes([my_scene]);
        }
    }

    auto game = new Game();
    game.run();

    // make sure scene is accessible
    assert(game.primary_scene == my_scene, "primary scene does not match loaded scene");

    // make sure components worked
    assert(my_scene.get_entity("apple").get_component!(TestScene.Plant)()
            .height > 0, "test Updatable was not updated");

    game.destroy(); // clean up

    // make sure scene is cleaned up
    assert(my_scene.ecs is null, "scene was not cleaned up");
}
