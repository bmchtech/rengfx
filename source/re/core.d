module re.core;

import re.input;
import re.content;
import re.time;
import re.gfx.window;
import re.ng.scene;
import re.ng.diag;
import re.ng.manager;
import re.gfx.render_ext;
import re.math;
import re.util.logger;
import re.util.tweens.tween_manager;
import std.array;
import jar;
static import raylib;

/**
Core class
*/
abstract class Core {
    /// logger utility
    public static Logger log;

    /// game window
    public static Window window;

    /// content manager
    public static ContentManager content;

    /// the current scenes
    private static Scene[] _scenes;

    /// type registration container
    public static Jar jar;

    /// global managers
    public static Manager[] managers;

    /// whether to draw debug information
    public static bool debug_render;

    /// debugger utility
    debug public static Debugger debugger;

    /// whether the game is running
    public static bool running;

    /// whether graphics should be disabled
    public static bool headless = false;

    /// whether to pause when unfocused
    public static bool pause_on_focus_lost = true;

    /// the default render resolution for all scenes
    public static Vector2 default_resolution;

    /// sets up a game core
    this(int width, int height, string title) {
        log = new Logger(Logger.Verbosity.Information);
        log.sinks ~= new Logger.ConsoleSink();

        default_resolution = Vector2(width, height);
        if (!Core.headless) {
            window = new Window(width, height);
            window.initialize();
            window.set_title(title);
        }

        content = new ContentManager();

        jar = new Jar();

        managers ~= new TweenManager();

        debug {
            debugger = new Debugger();
        }

        initialize();
    }

    @property public static int fps() {
        return raylib.GetFPS();
    }

    /// sets up the game
    abstract void initialize();

    /// starts the game
    public void run() {
        running = true;
        // start the game loop
        while (running) {
            running = !raylib.WindowShouldClose();

            update();
            draw();
        }
    }

    /// gracefully exits the game
    public static void exit() {
        running = false;
    }

    protected void update() {
        if (pause_on_focus_lost && raylib.IsWindowMinimized()) {
            return; // pause
        }
        Time.update(raylib.GetFrameTime());
        foreach (manager; managers) {
            manager.update();
        }
        Input.update();
        foreach (scene; _scenes) {
            scene.update();
        }
        debug {
            debugger.update();
        }
    }

    protected void draw() {
        if (Core.headless)
            return;
        if (raylib.IsWindowMinimized()) {
            return; // suppress draw
        }
        raylib.BeginDrawing();
        foreach (scene; _scenes) {
            // render scene
            scene.render();
            // post-render
            scene.post_render();
            // composite screen render to window
            // TODO: support better compositing
            RenderExt.draw_render_target(scene.render_target, Rectangle(0, 0,
                    window.width, window.height), scene.composite_mode.color);
        }
        debug {
            debugger.render();
        }
        raylib.EndDrawing();

    }

    public static T get_scene(T)() {
        import std.algorithm.searching : find;

        // find a scene matching the type
        auto matches = _scenes.find!(x => (cast(T) x) !is null);
        assert(matches.length > 0, "no matching scene was found");
        return cast(T) matches.front;
    }

    public static T get_manager(T)() {
        import std.algorithm.searching : find;

        // find a scene matching the type
        auto matches = managers.find!(x => (cast(T) x) !is null);
        assert(matches.length > 0, "no matching manager was found");
        return cast(T) matches.front;
    }

    @property public static Scene[] scenes() {
        return _scenes;
    }

    @property public static Scene primary_scene() {
        return _scenes.front;
    }

    /// sets the current scenes
    static void load_scenes(Scene[] new_scenes) {
        foreach (scene; _scenes) {
            // end old scenes
            scene.end();
            scene = null;
        }
        // clear scenes list
        _scenes = [];

        _scenes ~= new_scenes;
        // begin new scenes
        foreach (scene; _scenes) {
            scene.begin();
        }
    }

    /// releases all resources and cleans up
    public void destroy() {
        debug {
            debugger.destroy();
        }
        content.destroy();
        load_scenes([]); // end scenes
        foreach (manager; managers) {
            manager.destroy();
        }
        if (!Core.headless) {
            window.destroy();
        }
    }
}
