module re.ng.command;

/// console commands
struct ConsoleCommand {
    string name;
    void delegate(string[]) action;
    string help;
}
