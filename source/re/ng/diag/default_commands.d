module re.ng.diag.default_commands;

import re.core;
import re.ecs;
import std.range;
import std.array;
import std.algorithm;
import std.string;

debug static class DefaultCommands {
    alias log = Core.log;
    alias scenes = Core.scenes;
    alias dbg = Core.debugger;
    alias con = dbg.console;

    static void c_help(string[] args) {
        auto sb = appender!string();
        sb ~= "available commmands:\n";
        auto command_names = con.commands.keys.sort();
        foreach (command_name; command_names) {
            auto command = con.commands[command_name];
            sb ~= format("%s - %s\n", command.name, command.help);
        }
        log.info(sb.data);
    }

    static void c_entities(string[] args) {
        auto sb = appender!string();
        sb ~= "entity list:\n";
        foreach (i, scene; scenes) {
            // print scene header
            sb ~= format("▶ Scene[%d]: %s ¬\n", i, typeid(scene).name);
            foreach (entity; scene.ecs.entities) {
                // get list of components
                auto component_types = entity.get_all_components().map!(x => x.classinfo.name);
                // sb ~= format("  ▷ %s: pos(%s) components[%d] {%s}\n", entity.name,
                //         entity.position, entity.components.length, component_types);
                sb ~= format("  ▷ %s: pos(%s) components[%s]\n", entity.name, entity.position, component_types
                        .length);
                foreach (component_type; component_types) {
                    sb ~= format("    ■ %s\n", component_type);
                }
            }
        }
        log.info(sb.data);
    }

    private static bool pick_entity(string name, out Entity entity) {
        // find entities in all scenes
        foreach (scene; scenes) {
            if (scene.ecs.has_entity(name)) {
                entity = scene.get_entity(name);
                log.info(format("selected entity '%s' in scene %s",
                        entity.name, typeid(scene).name));
                return true;
            }
        }

        log.err(format("entity '%s' not found", name));
        return false;
    }

    private static bool pick_component(string[] args, out Component comp) {
        if (args.length < 2) {
            log.err("usage: <entity> <component>");
            return false;
        }
        Entity entity;
        if (!pick_entity(args[0], entity))
            return false;
        auto comp_search = args[1].toLower;
        // find matching component
        auto matches = entity.get_all_components()
            .find!(x => x.classinfo.name.toLower.indexOf(comp_search) > 0);
        if (matches.length == 0) {
            log.err(format("no matching component for '%s'", comp_search));
            return false;
        }
        comp = matches.front;
        return true;
    }

    static void c_dump(string[] args) {
        Component comp;
        if (!pick_component(args, comp))
            return;
        // dump this component
        auto sb = appender!(string);
        auto comp_class = comp.getMetaType;
        log.info(format("dumping: %s", comp_class.getName));
        foreach (field; comp_class.getFields) {
            sb ~= format("%s = %s\n", field.getName, field.get(comp));
        }
        log.info(sb.data);
    }

    static void c_inspect(string[] args) {
        if (args.length == 0 && dbg.inspector.open) {
            // close inspector when run without args
            dbg.inspector.close();
            return;
        }
        Entity entity;
        if (!pick_entity(args[0], entity))
            return;
        if (dbg.inspector.open)
            dbg.inspector.close(); // close the existing inspector

        // attach the inspector to this entity
        dbg.inspector.inspect(entity);
    }
}
