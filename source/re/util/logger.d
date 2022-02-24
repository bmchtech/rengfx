module re.util.logger;

import std.stdio;
import std.format;
import std.conv;
import std.datetime;
import colorize;

/// a utility class for displaying diagnostic messages
class Logger {
    /// how verbose the messages are
    enum Verbosity {
        Trace = 4,
        Information = 3,
        Warning = 2,
        Error = 1,
        Critical = 0
    }

    /// maximum message verbosity
    public Verbosity verbosity;
    /// message output targets
    public ILogSink[] sinks;

    /**
    initialize a logger with a given verbosity
    */
    this(Verbosity verbosity) {
        this.verbosity = verbosity;
    }

    /// writes a message
    public void write_line(string log, Verbosity level) {
        if (level <= verbosity) {
            foreach (sink; sinks) {
                sink.write_line(log, level);
            }
        }
    }

    /// writes a message at TRACE verbosity
    public void trace(string log) {
        write_line(log, Verbosity.Trace);
    }

    /// writes a message at INFO verbosity
    public void info(string log) {
        write_line(log, Verbosity.Information);
    }

    /// writes a message at WARNING verbosity
    public void warn(string log) {
        write_line(log, Verbosity.Warning);
    }

    /// writes a message at ERROR verbosity
    public void err(string log) {
        write_line(log, Verbosity.Error);
    }

    /// writes a message at CRITICAL verbosity
    public void crit(string log) {
        write_line(log, Verbosity.Critical);
    }

    private static string shortVerbosity(Verbosity level) {
        switch (level) {
        case Verbosity.Trace:
            return "trce";
        case Verbosity.Information:
            return "info";
        case Verbosity.Warning:
            return "warn";
        case Verbosity.Error:
            return "err!";
        case Verbosity.Critical:
            return "crit";
        default:
            return to!string(level);
        }
    }

    private static string formatMeta(Verbosity level) {
        auto time = cast(TimeOfDay) Clock.currTime();
        return format("[%s/%s]", shortVerbosity(level), time.toISOExtString());
    }

    /// a sink that accepts log messages
    public interface ILogSink {
        /// writes a message to the sink
        void write_line(string log, Verbosity level);
    }

    /// a sink that outputs to the console
    public static class ConsoleSink : ILogSink {
        public void write_line(string log, Verbosity level) {
            auto col = colorFor(level);
            colorize.cwritef(formatMeta(level).color(col, colorize.bg.black));
            colorize.cwritefln(" %s", log);
        }

        private colorize.fg colorFor(Verbosity level) {
            switch (level) {
            case Verbosity.Trace:
                return colorize.fg.light_black;
            case Verbosity.Information:
                return colorize.fg.green;
            case Verbosity.Warning:
                return colorize.fg.yellow;
            case Verbosity.Error:
                return colorize.fg.light_red;
            case Verbosity.Critical:
                return colorize.fg.red;
            default:
                return colorize.fg.white;
            }
        }
    }

    /// a sink that outputs to a file
    public static class FileSink : ILogSink {
        public string path;
        private File of;

        this(string path) {
            this.path = path;
            this.of = File(path, "a");
        }

        public void write_line(string log, Verbosity level) {
            of.write(formatMeta(level));
            of.writeln(" {log}");
            of.flush();
        }
    }
}
