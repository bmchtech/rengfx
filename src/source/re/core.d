module re.core;

import re.util.logger;
import re.gfx.window;

/**
Core class
*/
class Core {
    public Logger log;
    public Window window;

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
        // start the game instance
    }

    public void destroy() {
        window.destroy();
    }
}
