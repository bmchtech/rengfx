module re.core;

import re.util.logger;

/**
Core class
*/
class Core {
    public Logger log;

    this() {
        initialize();
    }

    protected void initialize() {
        // TODO: initialize things

        log = new Logger(Logger.Verbosity.Information);
        log.sinks ~= new Logger.ConsoleSink();
    }
}
