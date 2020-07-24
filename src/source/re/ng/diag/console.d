module re.ng.diag.console;

import re.input.input;
import re.core;
import re.math;
import re.gfx;
import re.ng.diag.default_commands;
import std.conv;
import std.string;
import std.range;
import std.utf;
static import raygui;

/// overlay debug console
class Console {
    /// the key that opens the console
    public Keys key = Keys.KEY_GRAVE;
    /// the character representation of the console key
    public char key_char = '`';
    /// whether the console is open
    public bool open = false;

    /// console commands
    public Command[string] commands;
    private enum height = 30;
    private char* console_text;

    /// represents a command for the debug console
    struct Command {
        string name;
        void function(string[]) action;
        string help;
    }

    /// create a debug console
    this() {
        // 64 chars
        console_text = "\0                                                                ".toUTFz!(
                char*)();

        // add default commands
        add_command(Command("help", &DefaultCommands.c_help, "lists available commands"));
        add_command(Command("entities", &DefaultCommands.c_entities,
                "lists scene entities"));
        add_command(Command("dump", &DefaultCommands.c_dump, "dump a component"));
    }

    private void add_command(Command command) {
        commands[command.name] = command;
    }

    public void update() {
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

    public void render() {
        alias pad = Core.debugger.screen_padding;
        auto console_bg_bounds = Rectangle(pad,
                Core.window.height - pad - height, Core.window.width - pad * 2, height);
        // console background
        // raylib.DrawRectangleRec(console_bg_bounds, bg_col);
        auto bg_padding = 4;
        auto console_bounds = Rectangle(console_bg_bounds.x + bg_padding, console_bg_bounds.y + bg_padding,
                console_bg_bounds.width - bg_padding * 2, console_bg_bounds.height - bg_padding * 2);
        // console text
        if (raygui.GuiTextBox(console_bounds, console_text, 64, true)) {
            auto raw_command = to!string(console_text).split(' ');
            process_command(raw_command.front, raw_command.drop(1));
            // pass command
            console_text[0] = '\0'; // clear text
        }
    }

    /// process a command in the console
    public void process_command(string cmd, string[] args) {
        if (cmd in commands) {
            commands[cmd].action(args);
        } else {
            Core.log.err(format("unrecognized command: %s", cmd));
        }
    }
}
