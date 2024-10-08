/** diagnostic console */

module re.ng.diag.console;

import std.conv;
import std.string;
import std.array;
import std.range;
import std.format;
import std.functional;
import std.algorithm : sort;

import re.input.input;
import re.core;
import re.math;
import re.gfx;
import re.ng.diag.default_inspect_commands;
import re.util.interop;
static import raygui;

/// represents a command for the debug console
public struct ConsoleCommand {
    string name;
    void delegate(string[]) action;
    string help;
}

/// overlay debug console
class InspectorConsole {
    /// the key that opens the console
    public Keys key = Keys.KEY_GRAVE;
    /// the character representation of the console key
    public char key_char = '`';
    /// whether the console is open
    public bool open = false;
    /// 64 chars of space
    private enum blank = "\0                                                                ";

    /// console commands
    public ConsoleCommand[string] commands;
    private enum height = 30;
    private char* console_text;
    private Appender!(string[]) _history;
    private int _history_depth = 0;

    /// create a debug console
    this() {
        console_text = blank.c_str();
    }

    private void add_builtin_commands() {
        add_command(ConsoleCommand("help", &cmd_help, "lists available commands"));
    }

    debug public void add_default_inspector_commands() {
        add_command(ConsoleCommand("entities", toDelegate(
                &DefaultEntityInspectorCommands.c_entities), "lists scene entities"));
        add_command(ConsoleCommand("inspect", toDelegate(&DefaultEntityInspectorCommands.c_inspect),
                "open the inspector on a component"));
        add_command(ConsoleCommand("dump", toDelegate(&DefaultEntityInspectorCommands.c_dump), "dump a component"));
    }

    public void reset_commands() {
        commands.clear();
        add_builtin_commands();
    }

    public void reset_history() {
        _history.clear();
        _history_depth = 0;
    }

    public void reset() {
        reset_commands();
        reset_history();
    }

    public void add_command(ConsoleCommand command) {
        commands[command.name] = command;
    }

    private void cmd_help(string[] args) {
        auto sb = appender!string();
        sb ~= "available commmands:\n";
        auto command_names = commands.keys.sort();
        foreach (command_name; command_names) {
            auto command = commands[command_name];
            sb ~= format("%s - %s\n", command.name, command.help);
        }
        Core.log.info(sb.data);
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
        alias pad = Core.inspector_overlay.screen_padding;
        auto screen_br = Vector2(Core.inspector_overlay.ui_bounds.width, Core
                .inspector_overlay.ui_bounds.height);
        // Core.log.info(format("screen_br: (%s", screen_br));
        auto console_bg_bounds = Rectangle(pad,
            screen_br.y - pad - height, screen_br.x - pad * 2, height);
        // console background
        // raylib.DrawRectangleRec(console_bg_bounds, bg_col);
        auto bg_padding = 4;
        auto console_bounds = Rectangle(console_bg_bounds.x + bg_padding, console_bg_bounds.y + bg_padding,
            console_bg_bounds.width - bg_padding * 2, console_bg_bounds.height - bg_padding * 2);
        // console text
        if (raygui.GuiTextBox(console_bounds, console_text, 64, true)) {
            auto console_text_str = to!string(console_text);
            // strip extra whitespace
            console_text_str = console_text_str.strip();
            if (console_text_str.length > 0) {
                _history_depth = 0; // we just executed a command, no longer in history
                _history ~= console_text_str; // add to history
                // get raw command string
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
            Core.log.err("unrecognized command: %s", cmd);
        }
    }
}
