module re.math.transform;

public import raylib : Vector2, Vector3;

struct Transform {
    private bool _dirty;

    private Vector3 _position;
    private float _rotation;

    @property Vector2 position2() {
        auto pos = position;
        return Vector2(pos.x, pos.y);
    }

    @property Vector2 position2(Vector2 value) {
        position = Vector3(value.x, value.y, 0);
        return value;
    }

    @property Vector3 position() {
        update_transform();
        return _position;
    }

    @property Vector3 position(Vector3 value) {
        return _position = value;
    }

    @property float rotation() {
        update_transform();
        return _rotation;
    }

    @property float rotation(float radians) {
        return _rotation = radians;
    }

    private void update_transform() {

    }
}
