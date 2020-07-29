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
import std.typecons;
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

    version (unittest) {
        /// the frame limit (used for testing)
        public static int frame_limit = 60;
    }

    /// whether graphics should be disabled
    public static bool headless = false;

    /// whether to pause when unfocused
    public static bool pause_on_focus_lost = true;

    /// the default render resolution for all scenes
    public static Vector2 default_resolution;

    /// the default texture filtering mode for render targets
    public static raylib.TextureFilterMode default_filter_mode = raylib.TextureFilterMode.FILTER_POINT;

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
            if (!headless) {
                running = !raylib.WindowShouldClose();
            }

            update();
            draw();

            version (unittest) {
                if (Time.frame_count >= frame_limit) {
                    running = false;
                }
            }
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
        version (unittest) {
            Time.update(1f / 60f); // 60 fps
        } else {
            Time.update(raylib.GetFrameTime());
        }
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

    public static Nullable!T get_manager(T)() {
        import std.algorithm.searching : find;

        // find a manager matching the type
        auto matches = managers.find!(x => (cast(T) x) !is null);
        if (matches.length > 0) {
            return Nullable!T(cast(T) matches.front);
        }
        return Nullable!T.init;
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

@("core-basic")
unittest {
    import re.util.test : TestGame;

    class Game : TestGame {
        override void initialize() {
            // nothing much
        }
    }

    auto game = new Game();
    game.run();

    // ensure time has passed
    assert(Time.total_time > 0);

    game.destroy(); // clean up

    assert(game.scenes.length == 0, "scenes were not removed after Game cleanup");
}
