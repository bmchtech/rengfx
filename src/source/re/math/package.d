module re.math;

public {
    import re.math.transform;
    import re.math.rect;
    import re.math.vector_ext;

    import std.math;

    /// the mathematical constant pi
    enum C_PI = std.math.PI;
    enum C_PI_2 = std.math.PI / 2;
    enum C_PI_4 = std.math.PI / 4;

    /// factor to convert radians to degrees
    enum C_RAD2DEG = (180.0f / PI);

    /// factor to convert degrees to radians
    enum C_DEG2RAD = (PI / 180.0f);

    // raylib
    static import raymath;
    import raylib : Vector2, Vector3, Matrix4;
    import raylib : Rectangle;
    import raylib : BoundingBox;
}
