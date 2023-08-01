module re.util.env;

import std.conv;
import std.process : environment;
import std.algorithm.searching : canFind;

static class Environment {
    static string get(string name, string default_value = null) {
        return environment.get(name, default_value);
    }

    static bool get_bool(string name, bool default_value = false) {
        auto value = get(name);
        static immutable TRUE_VALUES = ["1", "true", "yes"];
        static immutable FALSE_VALUES = ["0", "false", "no"];
        if (TRUE_VALUES.canFind(value)) {
            return true;
        } else if (FALSE_VALUES.canFind(value)) {
            return false;
        } else {
            return default_value;
        }
    }

    static int get_int(string name, int default_value = 0) {
        auto value = get(name);
        if (value is null) {
            return default_value;
        }
        try {
            return value.to!int;
        } catch (Exception e) {
            return default_value;
        }
    }
}
