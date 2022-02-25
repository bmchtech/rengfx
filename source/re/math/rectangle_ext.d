module re.math.rectangle_ext;

import re.math.raytypes;

// - custom

Vector2 center(Rectangle r) {
    return Vector2(r.x + r.width / 2, r.y + r.height / 2);
}

Vector2 top_left(Rectangle r) {
    return Vector2(r.x, r.y);
}

Vector2 top_right(Rectangle r) {
    return Vector2(r.x + r.width, r.y);
}

Vector2 bottom_left(Rectangle r) {
    return Vector2(r.x, r.y + r.height);
}

Vector2 bottom_right(Rectangle r) {
    return Vector2(r.x + r.width, r.y + r.height);
}

float left(Rectangle r) {
    return r.x;
}

float right(Rectangle r) {
    return r.x + r.width;
}

float top(Rectangle r) {
    return r.y;
}

float bottom(Rectangle r) {
    return r.y + r.height;
}

enum RectangleUnit = Rectangle(0, 0, 1, 1);
