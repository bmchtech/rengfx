module re.ng.diag.command;

/// console commands
struct ConsoleCommand {
    string name;
    void function(string[]) action;
    string help;
}
