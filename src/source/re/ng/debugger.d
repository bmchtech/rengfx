module re.ng.debugger;

import re.core;
import re.ecs.renderable;
import re.input.input;
import re.gfx;
import re.ng.command;
import re.math;
import std.string;
import std.utf;
import std.conv;
import std.range;

// import core.stdc.string;
static import raylib;
static import raygui;

/// a robust overlay debugging tool
class Debugger {
    /// the key that opens the console
    public Keys console_key = Keys.KEY_GRAVE;
    /// the character representation of the console key
    public char console_key_char = '`';
    /// console commands
    public ConsoleCommand[string] commands;
    /// whether the console is open
    public bool console_open = false;

    private enum screen_padding = 12;
    private enum bg_col = Color(180, 180, 180, 180);
    private enum console_height = 30;
    private char* console_text;

    /// create a debugger
    this() {
        // 64 chars
        console_text = "\0                                                                ".toUTFz!(
                char*)();

        // add default commands
        add_command(ConsoleCommand("help", &DefaultCommands.c_help, "lists available commands"));
        add_command(ConsoleCommand("entities", &DefaultCommands.c_entities, "lists scene entities"));
        add_command(ConsoleCommand("inspect", &DefaultCommands.c_inspect, "inspect a component"));
    }

    private void add_command(ConsoleCommand command) {
        commands[command.name] = command;
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
    public void console_command(string cmd, string[] args) {
        if (cmd in commands) {
            commands[cmd].action(args);
        } else {
            Core.log.err(format("unrecognized command: %s", cmd));
        }
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
        if (raygui.GuiTextBox(console_bounds, console_text, 64, true)) {
            auto raw_command = to!string(console_text).split(' ');
            console_command(raw_command.front, raw_command.drop(1));
            // pass command
            console_text[0] = '\0'; // clear text
        }
    }

    public static void default_debug_render(Renderable renderable) {
        raylib.DrawRectangleLinesEx(renderable.bounds, 1, raylib.Colors.RED);
    }
}
