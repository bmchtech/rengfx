module re.ng.diag.console;

import re.input.input;
import re.core;
import re.math;
import re.gfx;
import re.ng.diag.default_commands;
import re.util.interop;
import std.conv;
import std.string;
import std.array;
import std.range;
static import raygui;

/// overlay debug console
debug class Console {
    /// the key that opens the console
    public Keys key = Keys.KEY_GRAVE;
    /// the character representation of the console key
    public char key_char = '`';
    /// whether the console is open
    public bool open = false;
    /// 64 chars of space
    private enum blank = "\0                                                                ";

    /// console commands
    public Command[string] commands;
    private enum height = 30;
    private char* console_text;
    private Appender!(string[]) _history;
    private int _history_depth = 0;

    /// represents a command for the debug console
    struct Command {
        string name;
        void function(string[]) action;
        string help;
    }

    /// create a debug console
    this() {
        console_text = blank.c_str();

        // add default commands
        add_command(Command("help", &DefaultCommands.c_help, "lists available commands"));
        add_command(Command("entities", &DefaultCommands.c_entities, "lists scene entities"));
        add_command(Command("dump", &DefaultCommands.c_dump, "dump a component"));
        add_command(Command("inspect", &DefaultCommands.c_inspect,
                "open the inspector on a component"));
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

        void load_history_entry() {
            // load a history entry
            auto entry = _history.data[$ - _history_depth];
            console_text = entry.c_str();
        }

        // arrows can scroll through history
        if (Input.is_key_pressed(Keys.KEY_UP)) {
            if (_history_depth < _history.data.length) {
                _history_depth++;
                load_history_entry();
            }
        } else if (Input.is_key_pressed(Keys.KEY_DOWN)) {
            if (_history_depth > 0) {
                _history_depth--;
                load_history_entry();
            } else {
                console_text = blank.c_str();
            }
        }
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
            auto console_text_str = to!string(console_text);
            if (console_text_str.length > 0) {
                _history_depth = 0; // we just executed a command, no longer in history
                _history ~= console_text_str; // add to history
                auto raw_command = console_text_str.split(' ');
                process_command(raw_command.front, raw_command.drop(1));
                // pass command
                console_text[0] = '\0'; // clear text
            }
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
