module re.math;

public import re.math.transform;
public import re.math.rect;

import std.math;

enum PI = std.math.PI;
enum RAD2DEG = (180.0f / PI);
enum DEG2RAD = (PI / 180.0f);

// raylib
public static import raymath;
public import raylib : Vector2, Vector3, Matrix4;
public import raylib : Rectangle;

enum Vector2Zero = Vector2(0, 0);
enum Vector2One = Vector2(1, 1);
enum Vector3Zero = Vector3(0, 0, 0);
enum Vector3One = Vector3(1, 1, 1);
