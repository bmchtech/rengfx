module re.math.transform;

import re.math;

/// represents an object transform in both 2d and 3d space
struct Transform {
    /*
    
    The "dirty" system:
    
    used internally to keep track of what parts of the transform have been modified
    and are thus "out-of-sync" with its transformation matrices.

    for example, when you modify rotation via the Z-angle, rotation will be set dirty,
    and the transform will be synchronized to reflect that new transform. in addition,
    the orientation quaternion will also be updated so it is in sync.

    this helps save computation: since position and scale were not modified, there's
    no reason to recompute their matrices; we can reuse our cached matrices for them.
    whenever a part of the transform is modified, its matrix is marked dirty,
    so it alone can be recomputed.

    */

    /// whether anything is dirty
    private bool _dirty;
    /// whether scale is dirty
    private bool _dirty_scale;
    /// whether position is dirty
    private bool _dirty_position;
    /// whether rotation is dirty
    private bool _dirty_rotation;
    /// whether the dirty rotation is the Z-rotation
    private bool _dirty_rotation_z;
    /// whether the dirty rotation is the quaternion
    private bool _dirty_rotation_quat;

    private Vector3 _position = Vector3(0, 0, 0);
    private Vector3 _scale = Vector3(1, 1, 1);
    private float _rotation_z = 0;
    private Quaternion _rotation_quat = raymath.QuaternionIdentity();

    /// transform matrix for local scale
    private Matrix4 _scl_mat;
    /// transform matrix for local position
    private Matrix4 _pos_mat;
    /// transform matrix for local rotation
    private Matrix4 _rot_mat;

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
    @property ref Vector3 scale() return  {
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
        _dirty = _dirty_rotation = _dirty_rotation_z = true;
        _rotation_z = radians % C_2_PI;
        return radians;
    }

    /// gets orientation quaternion
    @property Quaternion orientation() {
        update_transform();
        return _rotation_quat;
    }

    /// sets orientation quaternion
    @property Quaternion rotation_z(Quaternion value) {
        _dirty = _dirty_rotation = _dirty_rotation_quat = true;
        _rotation_quat = value;
        return value;
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
        if (_dirty_position) {
            _pos_mat = raymath.MatrixTranslate(_position.x, _position.y, _position.z);
            _dirty_position = false;
        }
        if (_dirty_rotation) {
            if (_dirty_rotation_z) {
                _rot_mat = raymath.MatrixRotateZ(_rotation_z);
                _dirty_rotation_z = false;
                // sync Z-rotation to quaternion
                _rotation_quat = raymath.QuaternionFromMatrix(_rot_mat);
            }
            if (_dirty_rotation_quat) {
                // recompute rotation matrix from quaternion
                _rot_mat = raymath.QuaternionToMatrix(_rotation_quat);
                _dirty_rotation_quat = false;
                // sync quaternion to Z-rotation
                immutable auto euler_angles = raymath.QuaternionToEuler(_rotation_quat);
                _rotation_z = euler_angles.z;
            }
            _dirty_rotation = false;
        }
        if (_dirty_scale) {
            _scl_mat = raymath.MatrixScale(_scale.x, _scale.y, _scale.z);
            _dirty_scale = false;
        }

        auto tmp1 = raymath.MatrixMultiply(_scl_mat, _rot_mat);
        auto tmp2 = raymath.MatrixMultiply(tmp1, _pos_mat);

        _localToWorldTransform = tmp2;
        _worldToLocalTransform = raymath.MatrixInvert(_localToWorldTransform);

        _dirty = false;
    }
}
