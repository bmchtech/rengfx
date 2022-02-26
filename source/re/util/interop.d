/** utilities for interop with c */

module re.util.interop;

import std.utf;

public static char* c_str(string str) {
    return str.toUTFz!(char*)();
}

@("interop-basic")
unittest {
    import core.stdc.string;
    import std.conv;

    auto str1 = "hello";
    char* str1c = str1.c_str;

    // check c string
    assert(str1c.to!string == str1);
    assert(strlen(str1c) == str1.length);
}
