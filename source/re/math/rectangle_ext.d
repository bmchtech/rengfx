/** rectangle utilities */

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

Rectangle scale(Rectangle r, float factor) {
    return Rectangle(r.x * factor, r.y * factor, r.width * factor, r.height * factor);
}

Rectangle scale(Rectangle r, Vector2 factor) {
    return Rectangle(r.x * factor.x, r.y * factor.y, r.width * factor.x, r.height * factor.y);
}

Rectangle scale_inplace(Rectangle r, float factor) {
    return Rectangle(r.x, r.y, r.width * factor, r.height * factor);
}

Rectangle scale_inplace(Rectangle r, Vector2 factor) {
    return Rectangle(r.x, r.y, r.width * factor.x, r.height * factor.y);
}

enum RectangleZero = Rectangle(0, 0, 0, 0);
enum RectangleUnit = Rectangle(0, 0, 1, 1);
