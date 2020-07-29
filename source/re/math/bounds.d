module re.math.bounds;

import std.algorithm.comparison;
static import raymath;
import re.math;

static class Bounds {
    /** based on
    calculate bounds for an object in 2d space taking into account its transform
    https://github.com/prime31/Nez/blob/0e97e68bd9df191fb3b893eb69e54238c30fcc80/Nez.Portable/Utils/Extensions/Bounds.cs#L184
    */
    public static Rectangle calculate(ref Transform transform, Vector2 origin,
            float width, float height) {
        auto rotation = transform.rotation_z;
        auto position = transform.position2;
        auto scale = transform.scale2;
        if (rotation == 0) {
            return Rectangle(cast(int)(position.x - (origin.x * scale.x)),
                    cast(int)(position.y - (origin.y * scale.y)),
                    cast(int)(width * scale.x), cast(int)(height * scale.y));
        } else {
            auto tmp1 = Matrix4.init;

            // set the reference point to world reference taking origin into account
            auto transform_mat = raymath.MatrixTranslate(-position.x - origin.x,
                    -position.y - origin.y, 0);
            tmp1 = raymath.MatrixScale(scale.x, scale.y, 1); // scale ->
            transform_mat = raymath.MatrixMultiply(transform_mat, tmp1);
            tmp1 = raymath.MatrixRotateZ(rotation); // rotate ->
            transform_mat = raymath.MatrixMultiply(transform_mat, tmp1);
            tmp1 = raymath.MatrixTranslate(position.x, position.y, 0); // translate back
            transform_mat = raymath.MatrixMultiply(transform_mat, tmp1);

            // get all four corners in world space
            auto top_left_w = Vector3(position.x, position.y, 0);
            auto top_right_w = Vector3(position.x + width, position.y, 0);
            auto btm_left_w = Vector3(position.x, position.y + height, 0);
            auto btm_right_w = Vector3(position.x + width, position.y + height, 0);

            // transform the corners into our work space
            auto top_left = raymath.Vector3Transform(top_left_w, transform_mat);
            auto top_right = raymath.Vector3Transform(top_right_w, transform_mat);
            auto btm_left = raymath.Vector3Transform(btm_left_w, transform_mat);
            auto btm_right = raymath.Vector3Transform(btm_right_w, transform_mat);

            // find the min and max values so we can concoct our bounding box
            auto min_x = cast(int) min(top_left.x, btm_right.x, top_right.x, btm_left.x);
            auto max_x = cast(int) max(top_left.x, btm_right.x, top_right.x, btm_left.x);
            auto min_y = cast(int) min(top_left.y, btm_right.y, top_right.y, btm_left.y);
            auto max_y = cast(int) max(top_left.y, btm_right.y, top_right.y, btm_left.y);

            return Rectangle(min_x, min_y, max_x - min_x, max_y - min_y);
        }
    }

    /// calculate the new bounding box by applying the transform to the raw bounding box
    public static BoundingBox calculate(BoundingBox bounds, ref Transform transform) {
        // this should work, but...
        // auto t_min = raymath.Vector3Transform(bounds.min, transform.local_to_world_transform);
        // auto t_max = raymath.Vector3Transform(bounds.max, transform.local_to_world_transform);

        // TODO: this is a crappy workaround
        import re.util.dlib;

        // auto rot_quat = transform.orientation;
        // auto dl_rot_quat = convert_quat(rot_quat);
        // auto dl_rot_mat = dl_rot_quat.toMatrix4x4();
        // auto t_min = convert_vec3(bounds.min) * dl_rot_mat;
        // auto t_max = convert_vec3(bounds.max) * dl_rot_mat;
        auto dl_tf = convert_mat(transform.local_to_world_transform);
        auto t_min = convert_vec3(bounds.min) * dl_tf;
        auto t_max = convert_vec3(bounds.max) * dl_tf;

        return BoundingBox(convert_vec3(t_min), convert_vec3(t_max));
        // return BoundingBox(bounds.min * 1.1f, bounds.max * 1.1f);
    }
}
