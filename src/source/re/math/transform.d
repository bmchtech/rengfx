module re.math.transform;

import re.math;

struct Transform {
    private bool _dirty;
    private Vector3 _position = Vector3(0, 0, 0);
    private Vector3 _scale = Vector3(1, 1, 1);
    private float _rotation = 0;
    private Matrix4 _localTransform;

    // 2d wrappers

    /// gets 2d position
    @property Vector2 position2() {
        auto pos = position;
        return Vector2(pos.x, pos.y);
    }

    /// sets 2d position
    @property Vector2 position2(Vector2 value) {
        position = Vector3(value.x, value.y, 0);
        return value;
    }

    /// gets 2d scale
    @property Vector2 scale2() {
        auto scl = scale;
        return Vector2(scl.x, scl.y);
    }

    /// sets 2d scale
    @property Vector2 scale2(Vector2 value) {
        scale = Vector3(value.x, value.y, 1);
        return value;
    }

    // main sub-transforms

    /// gets 3d position
    @property ref Vector3 position() return {
        update_transform();
        return _position;
    }

    /// sets 3d position
    @property Vector3 position(Vector3 value) {
        _dirty = true;
        return _position = value;
    }

    /// gets 3d scale
    @property ref Vector3 scale() return {
        update_transform();
        return _scale;
    }

    /// sets 3d scale
    @property Vector3 scale(Vector3 value) {
        _dirty = true;
        return _scale = value;
    }

    /// gets Z-axis rotation
    @property ref float rotation() return {
        update_transform();
        return _rotation;
    }

    /// sets Z-axis rotation
    @property float rotation(float radians) {
        _dirty = true;
        return _rotation = radians;
    }

    private void update_transform() {
        if (_dirty) {
            // recompute matrices
            auto translation_mat = raymath.MatrixTranslate(_position.x, _position.y, _position.z);
            auto rotation_mat = raymath.MatrixRotateZ(_rotation);
            auto scale_mat = raymath.MatrixScale(_scale.x, _scale.y, _scale.z);

            auto tmp1 = raymath.MatrixMultiply(scale_mat, rotation_mat);
            auto tmp2 = raymath.MatrixMultiply(tmp1, translation_mat);

            _localTransform = tmp2;

            _dirty = false;
        }
    }
}
