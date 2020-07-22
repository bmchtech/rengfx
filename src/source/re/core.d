module re.core;

import re.util.logger;
import re.gfx.window;
import raylib;

/**
Core class
*/
class Core {
    public Logger log;
    public Window window;
    public bool running;

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

    public void exit() {
        running = false;
    }

    protected void update() {
        // TODO: update
    }

    protected void draw() {
        raylib.BeginDrawing();
        // TODO: draw
        raylib.EndDrawing();
    }

    public void destroy() {
        window.destroy();
    }
}
