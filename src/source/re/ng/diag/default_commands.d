module re.ng.diag.default_commands;

import re.core;
import std.range;
import std.array;
import std.algorithm;
import std.string;

static class DefaultCommands {
    alias log = Core.log;
    alias scene = Core.scene;
    alias dbg = Core.debugger;

    static void c_help(string[] args) {
        auto sb = appender!string();
        sb ~= "available commmands:\n";
        auto command_names = dbg.commands.keys.sort();
        foreach (command_name; command_names) {
            auto command = dbg.commands[command_name];
            sb ~= format("%s - %s\n", command.name, command.help);
        }
        log.info(sb.data);
    }

    static void c_entities(string[] args) {
        auto sb = appender!string();
        sb ~= "entities:\n";
        foreach (entity; scene.ecs.entities) {
            // get list of components
            auto component_types = entity.get_all_components().map!(x => x.classinfo.name);
            sb ~= format("%s: components[%d] {%s}\n", entity.name,
                    entity.components.length, component_types);
        }
        log.info(sb.data);
    }

    static void c_inspect(string[] args) {
        if (args.length < 2) {
            log.err("usage: inspect <entity> <component>");
            return;
        }
        auto nt_name = args[0];
        if (!scene.ecs.has_entity(nt_name)) {
            log.err(format("entity '%s' not found", nt_name));
            return;
        }
        auto entity = scene.get_entity(nt_name);
        auto comp_search = args[1].toLower;
        // find matching component
        auto matches = entity.get_all_components()
            .find!(x => x.classinfo.name.toLower.indexOf(comp_search) > 0);
        if (matches.length == 0) {
            log.err(format("no matching component for '%s'", comp_search));
            return;
        }
        auto comp = matches.front;
        log.info(format("inspecting: %s", comp.classinfo.name));
        auto sb = appender!(string);
        // dump this component
        auto comp_class = comp.metaof;
        foreach (field; comp_class.getFields) {
            sb ~= format("%s = %s", field.getName, field.get(comp));
        }
        log.info(sb.data);
    }
}
