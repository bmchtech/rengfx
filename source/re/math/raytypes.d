module re.math.raytypes;

// - raylib types

public {
    import raylib : Vector2, Vector3, Vector4, Matrix4, Quaternion;
    import raylib : Rectangle;
    import raylib : BoundingBox;
    static import raymath;
}

/// represents an angle around a specified axis
struct AxisAngle {
    /// the axis of rotation
    Vector3 axis;
    /// the angle around the axis of rotation
    float angle;
}
