module re.ng.debugger;

import re.core;
import re.ecs.renderable;
import re.input.input;
import re.gfx;
import re.math;
import std.string;
import std.utf;
import std.conv;

// import core.stdc.string;
static import raylib;
static import raygui;

class Debugger {
    /// the key that opens the console
    public Keys console_key = Keys.KEY_GRAVE;
    /// the character representation of the console key
    public char console_key_char = '`';

    private enum screen_padding = 12;
    private enum bg_col = Color(180, 180, 180, 180);
    private enum console_height = 30;
    private bool console_open = false;
    private char* console_text;

    this() {
        console_text = "".toUTFz!(char*)();
    }

    public void update() {
        if (Input.is_key_pressed(console_key)) {
            Core.debug_render = !Core.debug_render;
            console_open = !console_open;
        }

        if (console_open)
            update_console();
    }

    private void update_console() {
        // remove all instances of c from str
        void sstrip(char* str, char c) {
            char* pr = str;
            char* pw = str;
            while (*pr) {
                *pw = *pr++;
                pw += (*pw != c);
            }
            *pw = '\0';
        }

        // remove console key from textbox
        sstrip(console_text, '`');
    }

    /// process a command in the console
    public void console_command(string cmd) {
        Core.log.info(format("got command: %s", cmd));
    }

    public void render() {
        if (console_open)
            render_console();
    }

    private void render_console() {
        auto console_bg_bounds = Rectangle(screen_padding, Core.window.height - screen_padding - console_height,
                Core.window.width - screen_padding * 2, console_height);
        // console background
        raylib.DrawRectangleRec(console_bg_bounds, bg_col);
        auto bg_padding = 4;
        auto console_bounds = Rectangle(console_bg_bounds.x + bg_padding, console_bg_bounds.y + bg_padding,
                console_bg_bounds.width - bg_padding * 2, console_bg_bounds.height - bg_padding * 2);
        // console text
        if (raygui.GuiTextBox(console_bounds, console_text, 12, true)) {
            console_command(to!string(console_text));
            // pass command
            console_text[0] = '\0'; // clear text
        }
    }

    public static void default_debug_render(Renderable renderable) {
        raylib.DrawRectangleLinesEx(renderable.bounds, 1, raylib.Colors.RED);
    }
}
