module re.core;

import re.input;
import re.content;
import re.gfx.window;
import re.ng.scene;
import re.ng.debugger;
import re.ng.manager;
import re.math;
import re.util.logger;
import re.util.tween.tween_manager;
import jar;
static import raylib;

/**
Core class
*/
class Core {
    /// logger utility
    public static Logger log;

    /// game window
    public static Window window;

    /// content manager
    public static ContentManager content;

    /// the current scene
    private static Scene _scene;

    /// type registration container
    public static Jar jar;

    /// global managers
    public Manager[] managers;

    /// whether to draw debug information
    public static bool debug_render;

    /// debugger utility
    debug public static Debugger debugger;

    /// whether the game is running
    public static bool running;

    /// whether graphics should be disabled
    public static bool headless = false;

    /// whether to pause when unfocused
    public static bool pause_on_focus_lost = false;

    /// sets up a game core
    this(int width, int height, string title) {
        log = new Logger(Logger.Verbosity.Information);
        log.sinks ~= new Logger.ConsoleSink();

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

    protected void initialize() {
    }

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
        foreach (manager; managers) {
            manager.update();
        }
        Input.update();
        if (scene !is null) {
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
        if (scene !is null) {
            scene.draw();
            // composite screen render to window
            // TODO: support better compositing
            auto tex = scene.render_texture.texture;
            raylib.DrawTexturePro(tex, Rectangle(0, 0, tex.width, -tex.height), Rectangle(0, 0, window.width, window.height), Vector2(0, 0), 0, raylib.WHITE);
        }
        debug {
            debugger.render();
        }
        raylib.EndDrawing();

    }

     public static Scene get_scene(T)() {
        // TODO: support the multi scene
        // for now, just return a casted scene
        // return cast(T) scene;
        return scene;
    }

    /// gets the current scene
    static @property Scene scene() {
        return _scene;
    }

    /// sets the current scene
    static @property Scene scene(Scene value) {
        if (_scene !is null) {
            // end old scene
            _scene.end();
            _scene = null;
        }
        // begin new one
        value.begin();
        return _scene = value;
    }

    /// releases all resources and cleans up
    public void destroy() {
        content.destroy();
        if (!Core.headless) {
            window.destroy();
        }
    }
}
