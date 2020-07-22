module re.util.logger;

import std.stdio;
import std.format;
import std.conv;
import std.datetime;
import datefmt;
import colorize;

class Logger {
    enum Verbosity {
        Trace = 4,
        Information = 3,
        Warning = 2,
        Error = 1,
        Critical = 0
    }

    public Verbosity verbosity;
    public ILogSink[] sinks;

    /**
    initialize a logger with a given verbosity
    */
    this(Verbosity verbosity) {
        this.verbosity = verbosity;
    }

    public void write_line(string log, Verbosity level) {
        if (level <= verbosity) {
            foreach (sink; sinks) {
                sink.write_line(log, level);
            }
        }
    }

    public void trace(string log) {
        write_line(log, Verbosity.Trace);
    }

    public void info(string log) {
        write_line(log, Verbosity.Information);
    }

    public void warn(string log) {
        write_line(log, Verbosity.Warning);
    }

    public void err(string log) {
        write_line(log, Verbosity.Error);
    }

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
        auto time = Clock.currTime();
        return format("[%s/:%s]", shortVerbosity(level), time.format("%H:%M:%S"));
    }

    public interface ILogSink {
        void write_line(string log, Verbosity level);
    }

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
