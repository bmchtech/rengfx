module re.input.input;

import re.math;
static import raylib;

alias Keys = raylib.KeyboardKey;
alias MouseButton = raylib.MouseButton;
alias GamepadButtons = raylib.GamepadButton;
alias Axes = raylib.GamepadAxis;

public static class Input {
    static this() {
    }

    // - keyboard

    public static bool is_key_pressed(Keys key) {
        return raylib.IsKeyPressed(key);
    }

    public static bool is_key_down(Keys key) {
        return raylib.IsKeyDown(key);
    }

    public static bool is_key_released(Keys key) {
        return raylib.IsKeyReleased(key);
    }

    public static bool is_key_up(Keys key) {
        return raylib.IsKeyUp(key);
    }

    // - gamepad
    // TODO

    // - mouse
    public static bool is_mouse_pressed(MouseButton button) {
        return raylib.IsMouseButtonPressed(button);
    }

    public static bool is_mouse_down(MouseButton button) {
        return raylib.IsMouseButtonDown(button);
    }

    public static bool is_mouse_released(MouseButton button) {
        return raylib.IsMouseButtonReleased(button);
    }

    public static bool is_mouse_up(MouseButton button) {
        return raylib.IsMouseButtonUp(button);
    }

    @property public static Vector2 mouse_position() {
        return raylib.GetMousePosition();
    }
}
