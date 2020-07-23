module re.core;

import re.input;
import re.util.logger;
import re.content;
import re.gfx.window;
import re.ng.scene;
import re.ng.debugger;
import re.ng.manager;
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

    /// whether to pause when unfocused
    public static bool pause_on_focus_lost = false;

    /// sets up a game core
    this(int width, int height, string title) {
        log = new Logger(Logger.Verbosity.Information);
        log.sinks ~= new Logger.ConsoleSink();

        window = new Window(width, height);
        window.initialize();
        window.set_title(title);

        content = new ContentManager();

        jar = new Jar();

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
        if (raylib.IsWindowMinimized()) {
            return; // suppress draw
        }
        raylib.BeginDrawing();
        if (scene !is null) {
            scene.draw();
        }
        debug {
            debugger.render();
        }
        raylib.EndDrawing();

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
        window.destroy();
    }
}
