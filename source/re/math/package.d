module re.math;

public {
    import re.math.transform;
    import re.math.rect_ext;
    import re.math.vector_ext;

    import std.math;

    /// the mathematical constant pi
    enum C_PI = cast(float) std.math.PI;
    enum C_PI_2 = cast(float) std.math.PI / 2;
    enum C_PI_4 = cast(float) std.math.PI / 4;

    /// factor to convert radians to degrees
    enum C_RAD2DEG = cast(float)(180.0 / PI);

    /// factor to convert degrees to radians
    enum C_DEG2RAD = cast(float)(PI / 180.0);

    // raylib
    import re.math.raytypes;
}
