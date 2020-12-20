module re.libs;

import std.stdio;
import std.conv;
import loader = bindbc.loader.sharedlib;

static class LibraryDependencies {
    public static bool load_all() {
        bool load_error = false;

        version (physics) {
            // - load newton using BindBC
            
            import bindbc.newton;

            NewtonSupport newton_ret = loadNewton();
            if (newton_ret != newtonSupport) {
                load_error = true;
                writefln("library NEWTON failed to load");
                foreach (info; loader.errors) {
                    writeln(info.error.to!string, " ", info.message.to!string);
                }
            }
        }

        return !load_error;
    }
}
