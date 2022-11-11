/** game logger */

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
        Info = 3,
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
    public void write_line(A...)(Verbosity level, A a) {
        if (level <= verbosity) {
            foreach (sink; sinks) {
                sink.write_line(format(a), level);
            }
        }
    }

    /// writes a message at TRACE verbosity
    public void trace(A...)(A a) {
        write_line(Verbosity.Trace, a);
    }

    /// writes a message at INFO verbosity
    public void info(A...)(A a) {
        write_line(Verbosity.Info, a);
    }

    /// writes a message at WARNING verbosity
    public void warn(A...)(A a) {
        write_line(Verbosity.Warning, a);
    }

    /// writes a message at ERROR verbosity
    public void err(A...)(A a) {
        write_line(Verbosity.Error, a);
    }

    /// writes a message at CRITICAL verbosity
    public void crit(A...)(A a) {
        write_line(Verbosity.Critical, a);
    }

    private static string shortVerbosity(Verbosity level) {
        switch (level) {
        case Verbosity.Trace:
            return "trce";
        case Verbosity.Info:
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
            case Verbosity.Info:
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
