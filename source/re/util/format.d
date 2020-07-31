module re.util.format;

import re.math;
import std.string;
import std.conv : to;

string format_vec(Vector2 vec, int precision) {
    auto spec = "%." ~ to!string(precision) ~ "f";
    auto str = format("%s, %s", spec, spec);
    return format(str, vec.x, vec.y);
}

string format_vec(Vector3 vec, int precision) {
    auto spec = "%." ~ to!string(precision) ~ "f";
    auto str = format("%s, %s, %s", spec, spec, spec);
    return format(str, vec.x, vec.y, vec.z);
}

string format_vec(Vector4 vec, int precision) {
    auto spec = "%." ~ to!string(precision) ~ "f";
    auto str = format("%s, %s, %s, %s", spec, spec, spec, spec);
    return format(str, vec.x, vec.y, vec.z, vec.w);
}
