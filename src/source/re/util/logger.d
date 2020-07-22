module re.util.logger;

import std.stdio;
import std.format;
import std.conv;
import std.datetime;
import datefmt;

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
            // Console.ResetColor();
            // var col = colorFor(level);
            // Console.ForegroundColor = col;
            // Console.BackgroundColor = ConsoleColor.Black;
            write(formatMeta(level));
            // Console.ResetColor();
            writefln(" %s", log);
        }

        // private ConsoleColor colorFor(Verbosity level) {
        //     switch (level) {
        //     case Verbosity.Trace:
        //         return ConsoleColor.Gray;
        //     case Verbosity.Information:
        //         return ConsoleColor.Green;
        //     case Verbosity.Warning:
        //         return ConsoleColor.Yellow;
        //     case Verbosity.Error:
        //         return ConsoleColor.Red;
        //     case Verbosity.Critical:
        //         return ConsoleColor.DarkRed;
        //     default:
        //         return ConsoleColor.White;
        //     }
        // }
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
