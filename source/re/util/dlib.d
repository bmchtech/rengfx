module re.util.dlib;

version (physics_dlib) {
    import dl_vec = dlib.math.vector;
    import dl_quat = dlib.math.quaternion;
    import dl_mat = dlib.math.matrix;
    import re.math;

    pragma(inline, true) {
        static dl_vec.Vector3f convert_vec3(const(Vector3) vec) {
            return dl_vec.Vector3f(vec.x, vec.y, vec.z);
        }

        static Vector3 convert_vec3(const(dl_vec.Vector3f) vec) {
            return Vector3(vec.x, vec.y, vec.z);
        }

        static Quaternion convert_quat(const(dl_quat.Quaternionf) quat) {
            auto vec = quat.vectorof[];
            return Quaternion(vec[0], vec[1], vec[2], vec[3]);
        }

        static dl_quat.Quaternionf convert_quat(const(Quaternion) quat) {
            return dl_quat.Quaternionf(quat.x, quat.y, quat.z, quat.w);
        }

        static dl_mat.Matrix4x4f convert_mat(const(Matrix) mat) {
            return dl_mat.Matrix4x4f([
                    mat.m0, mat.m4, mat.m8, mat.m12, mat.m1, mat.m5, mat.m9,
                    mat.m13, mat.m2, mat.m6, mat.m10, mat.m14, mat.m3, mat.m7,
                    mat.m11, mat.m15
                    ]);
        }
    }
}
