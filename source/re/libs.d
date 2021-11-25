module re.libs;

import re.core;
import std.stdio;
import std.string;
import std.conv;
import loader = bindbc.loader.sharedlib;

static class LibraryDependencies {
    public static bool load_all() {
        bool load_error = false;

        version (physics) {
            // - load newton using BindBC
            
            import bindbc.newton;

            NewtonSupport newton_ret = loadNewton();
            auto newton_expected = NewtonSupport.newton314;
            if (newton_ret != newton_expected) {
                load_error = true;
                Core.log.err(format("library newton failed to load (expecting %s, got %s)", newton_expected, newton_ret));
                foreach (info; loader.errors) {
                    Core.log.err(format("%s: %s", info.error.to!string, info.message.to!string));
                }
            }
        }

        return !load_error;
    }
}
