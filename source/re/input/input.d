module re.input.input;

import re.core;
import re.math;
import re.input;
static import raylib;

alias Keys = raylib.KeyboardKey;
alias MouseButton = raylib.MouseButton;
alias GamepadButtons = raylib.GamepadButton;
alias Axes = raylib.GamepadAxis;

/// input helper
public static class Input {
    /// global virtual input list
    public static VirtualInput[] virtual_inputs;
    private static Vector2 last_mouse_position;
    public static Vector2 mouse_delta;

    static this() {
    }

    public static void update() {
        // update core input pipeline
        immutable auto current_mouse_pos = mouse_position();
        mouse_delta = current_mouse_pos - last_mouse_position;
        last_mouse_position = current_mouse_pos;
        // update virtual inputs
        debug {
            // skip virtual input update if console open
            if (Core.debugger.console.open) {
                return;
            }
        }
        foreach (input; virtual_inputs) {
            input.update();
        }
    }

    // - keyboard

    /// if a key was pressed this frame
    public static bool is_key_pressed(Keys key) {
        return raylib.IsKeyPressed(key);
    }

    /// if a key is currently down
    public static bool is_key_down(Keys key) {
        return raylib.IsKeyDown(key);
    }

    /// if a key was released this frame
    public static bool is_key_released(Keys key) {
        return raylib.IsKeyReleased(key);
    }

    /// if a key is currently up
    public static bool is_key_up(Keys key) {
        return raylib.IsKeyUp(key);
    }

    // - gamepad
    // TODO

    // - mouse

    /// if the mouse was pressed this frame
    public static bool is_mouse_pressed(MouseButton button) {
        return raylib.IsMouseButtonPressed(button);
    }

    /// if the mouse is currently down
    public static bool is_mouse_down(MouseButton button) {
        return raylib.IsMouseButtonDown(button);
    }

    /// if the mouse was released this frame
    public static bool is_mouse_released(MouseButton button) {
        return raylib.IsMouseButtonReleased(button);
    }

    /// if the mouse is currently up
    public static bool is_mouse_up(MouseButton button) {
        return raylib.IsMouseButtonUp(button);
    }

    /// the position of the mouse as a vector
    @property public static Vector2 mouse_position() {
        return raylib.GetMousePosition();
    }

    /// the mouse scroll wheel delta
    @property public static int scroll_delta() {
        return raylib.GetMouseWheelMove();
    }

    private static bool _cursor_locked = false;
    @property public static bool is_cursor_locked() {
        return _cursor_locked;
    }

    /// lock the cursor
    public static void lock_cursor() {
        raylib.DisableCursor();
        _cursor_locked = true;
    }

    /// unlock the cursor
    public static void unlock_cursor() {
        raylib.EnableCursor();
        _cursor_locked = false;
    }
}
