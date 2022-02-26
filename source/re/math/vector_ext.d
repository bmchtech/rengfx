/** vector utilities */

module re.math.vector_ext;

import re.math.raytypes;

// - raylib aliases
alias Normalize = raymath.Vector2Normalize;
alias Normalize = raymath.Vector3Normalize;

// - custom

float LengthSquared(Vector2 v) {
    return (v.x * v.x) + (v.y * v.y);
}


enum Vector2Zero = Vector2(0, 0);
enum Vector2One = Vector2(1, 1);
enum Vector3Zero = Vector3(0, 0, 0);
enum Vector3One = Vector3(1, 1, 1);