module re.math.transform;

public import raylib : Vector2, Vector3, Matrix4;

struct Transform {
    private bool _dirty;
    private Vector3 _position;
    private float _rotation;
    Matrix4 _localTransform;

    // 2d position wrapper

    @property Vector2 position2() {
        auto pos = position;
        return Vector2(pos.x, pos.y);
    }

    @property Vector2 position2(Vector2 value) {
        position = Vector3(value.x, value.y, 0);
        return value;
    }

    // main sub-transforms

    @property Vector3 position() {
        update_transform();
        return _position;
    }

    @property Vector3 position(Vector3 value) {
        _dirty = true;
        return _position = value;
    }

    @property float rotation() {
        update_transform();
        return _rotation;
    }

    @property float rotation(float radians) {
        _dirty = true;
        return _rotation = radians;
    }

    private void update_transform() {
        if (_dirty) {
            // recompute matrices
            
            
            _dirty = false;
        }
    }
}
