module re.math.transform;

public import raylib : Vector2, Vector3;

struct Transform {
    private bool _dirty;

    public Vector2 position;

    // @property Vector2 position() {
    //     return transform.position;
    // }

    // @property Vector2 position(Vector2 value) {
    //     transform.position = value;
    // }
}
