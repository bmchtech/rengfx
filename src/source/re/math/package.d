module re.math;

public {
    import re.math.transform;
    import re.math.rect;
    import re.math.vector_ext;

    import std.math;

    /// the mathematical constant pi
    enum PI = std.math.PI;

    /// factor to convert radians to degrees
    enum RAD2DEG = (180.0f / PI);

    /// factor to convert degrees to radians
    enum DEG2RAD = (PI / 180.0f);

    // raylib
    static import raymath;
    import raylib : Vector2, Vector3, Matrix4;
    import raylib : Rectangle;
}
