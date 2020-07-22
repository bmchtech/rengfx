module re.math.transform;

public import raylib : Vector2, Vector3, Matrix4;
public static import raymath;

struct Transform {
    private bool _dirty;
    private Vector3 _position;
    private float _rotation = 0;
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
            auto translation_mat = raymath.MatrixTranslate(_position.x, _position.y, _position.z);
            auto rotation_mat = raymath.MatrixRotateZ(_rotation);
            auto scale_mat = raymath.MatrixScale(1, 1, 1);

            auto tmp1 = raymath.MatrixMultiply(scale_mat, rotation_mat);
            auto tmp2 = raymath.MatrixMultiply(tmp1, translation_mat);

            _localTransform = tmp2;
            
            _dirty = false;
        }
    }
}
