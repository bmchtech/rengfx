module re.util.logger;

import std.stdio;
import std.format;
import std.array;
import std.conv;
import std.uni;
import std.range;
import std.algorithm;
import colorize;

enum Verbosity : int {
    debug_ = 5,
    trace = 4,
    info = 3,
    warn = 2,
    error = 1,
    crit = 0,
}

struct Logger {
    public Verbosity verbosity = Verbosity.info;

    this(Verbosity verbosity) {
        this.verbosity = verbosity;
    }

    private static string shortVerbosity(Verbosity level) {
        switch (level) {
        case Verbosity.debug_:
            return "dbg";
        case Verbosity.trace:
            return "trce";
        case Verbosity.info:
            return "info";
        case Verbosity.warn:
            return "warn";
        case Verbosity.error:
            return "err!";
        case Verbosity.crit:
            return "crit";
        default:
            return to!string(level);
        }
    }

    private static string formatMeta(Verbosity level) {
        import std.datetime;

        auto time = cast(TimeOfDay) Clock.currTime();
        return format("[%s/%s]", shortVerbosity(level), time.toISOExtString());
    }

    private colorize.fg colorFor(Verbosity level) {
        switch (level) {
        case Verbosity.debug_:
            return colorize.fg.light_black;
        case Verbosity.trace:
            return colorize.fg.light_black;
        case Verbosity.info:
            return colorize.fg.green;
        case Verbosity.warn:
            return colorize.fg.yellow;
        case Verbosity.error:
            return colorize.fg.red;
        case Verbosity.crit:
            return colorize.fg.red;
        default:
            return colorize.fg.white;
        }
    }

    /// writes a message
    public void write_line(string log, Verbosity level) {
        if (level <= verbosity) {
            auto col = colorFor(level);
            colorize.cwritef(formatMeta(level).color(col, colorize.bg.black));
            colorize.cwritefln(" %s", log);
        }
    }

    public void put(T...)(T args, Verbosity level) {
        write_line(format(args), level);
    }

    public void debug_(T...)(T args) {
        put(args, Verbosity.debug_);
    }
    alias dbg = debug_;

    public void trace(T...)(T args) {
        put(args, Verbosity.trace);
    }
    alias trc = trace;

    public void info(T...)(T args) {
        put(args, Verbosity.info);
    }
    alias inf = info;

    public void warn(T...)(T args) {
        put(args, Verbosity.warn);
    }
    alias wrn = warn;

    public void error(T...)(T args) {
        put(args, Verbosity.error);
    }
    alias err = error;

    public void crit(T...)(T args) {
        put(args, Verbosity.crit);
    }
    alias cri = crit;
}
