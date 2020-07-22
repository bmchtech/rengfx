module re.core;

import re.util.logger;
import re.gfx.window;
import re.scene;
import raylib;

/**
Core class
*/
class Core {
    public static Logger log;
    public static Window window;
    public static bool running;
    private static Scene _scene;

    this(int width, int height, string title) {
        log = new Logger(Logger.Verbosity.Information);
        log.sinks ~= new Logger.ConsoleSink();

        window = new Window(width, height);
        window.initialize();
        window.set_title(title);

        initialize();
    }

    protected void initialize() {
    }

    public void run() {
        running = true;
        // start the game loop
        while (running) {
            running = !raylib.WindowShouldClose();

            update();
            draw();
        }
    }

    public static void exit() {
        running = false;
    }

    protected void update() {
        if (scene !is null) {
            scene.update();
        }
    }

    protected void draw() {
        raylib.BeginDrawing();
        if (scene !is null) {
            scene.draw();
        }
        raylib.EndDrawing();
    }

    static @property Scene scene() {
        return _scene;
    }

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

    public void destroy() {
        window.destroy();
    }
}
