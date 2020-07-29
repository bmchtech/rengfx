module re.math.bounds;

import std.algorithm.comparison;
static import raymath;
import re.math;

static class Bounds {
    /** based on
    calculate bounds for an object in 2d space taking into account its transform
    https://github.com/prime31/Nez/blob/0e97e68bd9df191fb3b893eb69e54238c30fcc80/Nez.Portable/Utils/Extensions/Bounds.cs#L184
    */
    public static Rectangle calculate_bounds_2d(Vector2 position, Vector2 origin,
            Vector2 scale, float rotation, float width, float height) {
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
}
