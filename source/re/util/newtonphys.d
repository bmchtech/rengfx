module re.util.newtonphys;

version (physics) {
    import newton = bindbc.newton.types;
    import re.math;

    struct newton_vector {
        align(4):
        newton.dFloat x = 0;
        newton.dFloat y = 0;
        newton.dFloat z = 0;
        newton.dFloat w = 0;
    }

    struct newton_matrix {
        align(4):
        newton_vector front;
        newton_vector up;
        newton_vector right;
        newton_vector posit;
    }

    pragma(inline, true) {
        static newton_vector convert_vec3(const(Vector3) vec) {
            return newton_vector(vec.x, vec.y, vec.z, 1.0);
        }

        static Vector3 convert_vec3(const(newton_vector) vec) {
            return Vector3(vec.x, vec.y, vec.z);
        }

        // static Quaternion convert_quat(const(dl_quat.Quaternionf) quat) {
        //     auto vec = quat.vectorof[];
        //     return Quaternion(vec[0], vec[1], vec[2], vec[3]);
        // }

        // static dl_quat.Quaternionf convert_quat(const(Quaternion) quat) {
        //     return dl_quat.Quaternionf(quat.x, quat.y, quat.z, quat.w);
        // }

        // static dl_mat.Matrix4x4f convert_mat(const(Matrix) mat) {
        //     return dl_mat.Matrix4x4f([
        //             mat.m0, mat.m4, mat.m8, mat.m12, mat.m1, mat.m5, mat.m9,
        //             mat.m13, mat.m2, mat.m6, mat.m10, mat.m14, mat.m3, mat.m7,
        //             mat.m11, mat.m15
        //             ]);
        // }
    }
}