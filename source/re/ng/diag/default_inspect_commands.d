/** default console commands */

module re.ng.diag.default_inspect_commands;

import std.range;
import std.array;
import std.algorithm;
import std.string;
import std.conv;

import re.core;
import re.ecs;

debug static class DefaultEntityInspectorCommands {
    alias log = Core.log;
    alias scenes = Core.scenes;
    alias dbg = Core.inspector_overlay;
    alias con = dbg.console;

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
                for (int j = 0; j < component_types.length; j++) {
                    sb ~= format("    ■ [%s] %s\n", j, component_types[j]);
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
                log.info("selected entity '%s' in scene %s",
                        entity.name, typeid(scene).name);
                return true;
            }
        }

        log.err("entity '%s' not found", name);
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
        auto comp_sel = args[1];
        auto all_comps = entity.get_all_components();
        // check if we can parse component selector as int
        try {
            auto comp_ix = comp_sel.to!int;

            // select component at this index
            comp = all_comps[comp_ix];
        } catch (ConvException) {
            // not an int, try to find component by name
            auto comp_search = comp_sel.toLower;
            // find matching component
            auto matches = all_comps
                .find!(x => x.classinfo.name.toLower.indexOf(comp_search) > 0);
            if (matches.length == 0) {
                log.err("no matching component for '%s'", comp_search);
                return false;
            }
            comp = matches.front;
        }

        return true;
    }

    static void c_dump(string[] args) {
        Component comp;
        if (!pick_component(args, comp))
            return;
        // dump this component
        auto sb = appender!(string);
        auto comp_class = comp.getMetaType;
        // log.info(format("dumping: %s", comp_class.getName));
        sb ~= format("dump: %s\n", comp_class.getName);
        foreach (field; comp_class.getFields) {
            sb ~= format("  %s = %s\n", field.getName, field.get(comp));
        }
        log.info(sb.data);
    }

    static void c_inspect(string[] args) {
        if (args.length == 0) {
            if (dbg.entity_inspect_view.open) {
                // close inspector when run without args
                dbg.entity_inspect_view.close();
            } else {
                // inspector isn't open, and no arg was given
                log.err("usage: inspect <entity>");
            }
            return;
        }
        Entity entity;
        if (!pick_entity(args[0], entity))
            return;
        if (dbg.entity_inspect_view.open)
            dbg.entity_inspect_view.close(); // close the existing inspector

        // attach the inspector to this entity
        dbg.entity_inspect_view.inspect(entity);
    }
}
