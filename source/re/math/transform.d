module re.math.transform;

import re.math;

struct Transform {
    /// whether anything is dirty
    private bool _dirty;
    /// whether scale is dirty
    private bool _dirty_scale;
    /// whether position is dirty
    private bool _dirty_position;
    /// whether rotation is dirty
    private bool _dirty_rotation;

    private Vector3 _position = Vector3(0, 0, 0);
    private Vector3 _scale = Vector3(1, 1, 1);
    private float _rotation_z = 0;

    /// transform matrix for local scale
    private Matrix4 _local_scl_transform;
    /// transform matrix for local position
    private Matrix4 _local_pos_transform;
    /// transform matrix for local rotation
    private Matrix4 _local_rot_transform;
    /// transform matrix from local to world
    private Matrix4 _localToWorldTransform;
    /// transform matrix from world to local
    private Matrix4 _worldToLocalTransform;

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
    @property ref Vector3 position() return  {
        update_transform();
        return _position;
    }

    /// sets 3d position
    @property Vector3 position(Vector3 value) {
        _dirty = _dirty_position = true;
        return _position = value;
    }

    /// gets 3d scale
    @property Vector3 scale() {
        update_transform();
        return _scale;
    }

    /// sets 3d scale
    @property Vector3 scale(Vector3 value) {
        _dirty = _dirty_scale = true;
        return _scale = value;
    }

    /// gets Z-axis rotation
    @property float rotation_z() {
        update_transform();
        return _rotation_z;
    }

    /// sets Z-axis rotation
    @property float rotation_z(float radians) {
        _dirty = _dirty_rotation = true;
        _rotation_z = radians % C_2_PI;
        return radians;
    }

    /// gets local-to-world transform
    @property Matrix4 local_to_world_transform() {
        update_transform();
        return _localToWorldTransform;
    }

    /// gets world-to-local transform
    @property Matrix4 world_to_local_transform() {
        update_transform();
        return _worldToLocalTransform;
    }

    private void update_transform() {
        if (!_dirty)
            return;

        // recompute matrices
        auto translation_mat = raymath.MatrixTranslate(_position.x, _position.y, _position.z);
        auto rotation_mat = raymath.MatrixRotateZ(_rotation_z);
        auto scale_mat = raymath.MatrixScale(_scale.x, _scale.y, _scale.z);

        auto tmp1 = raymath.MatrixMultiply(scale_mat, rotation_mat);
        auto tmp2 = raymath.MatrixMultiply(tmp1, translation_mat);

        _localToWorldTransform = tmp2;
        _worldToLocalTransform = raymath.MatrixInvert(_localToWorldTransform);

        _dirty = false;

    }
}
