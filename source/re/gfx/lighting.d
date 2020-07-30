module re.gfx.lighting;

import re.core;
import re.ecs;
import re.ng.manager;
import re.ng.scene3d;
import re.gfx;
import re.math;
import std.algorithm;
import std.container.array;
static import raylib;

/// acts as a manager for Light3D components
class SceneLightManager : Manager, Updatable {
    /// max lights supported by shader
    private enum max_lights = 4;
    private Array!(ShaderLight) _lights;
    private Array!Light3D _comps;
    private int light_count;

    /// the lighting shader
    public Shader shader;

    private enum ShaderLightType {
        LIGHT_DIRECTIONAL,
        LIGHT_POINT
    }

    private struct ShaderLight {
        int type;
        Vector3 position;
        Vector3 target;
        Color color;
        bool enabled;

        // Shader locations
        int enabledLoc;
        int typeLoc;
        int posLoc;
        int targetLoc;
        int colorLoc;
    }

    this() {
        // load the shader
        shader = Core.content.load_shader("shader/basic_lighting.vert",
                "shader/basic_lighting.frag");
        // get some shader locations
        shader.locs[raylib.ShaderLocationIndex.LOC_MATRIX_MODEL] = raylib.GetShaderLocation(shader,
                "matModel");
        shader.locs[raylib.ShaderLocationIndex.LOC_VECTOR_VIEW] = raylib.GetShaderLocation(shader,
                "viewPos");

        // ambient light level
        auto ambient_loc = raylib.GetShaderLocation(shader, "ambient");
        auto col_ambient = 0.4;
        float[4] ambient_val = [col_ambient, col_ambient, col_ambient, 1];
        raylib.SetShaderValue(shader, ambient_loc, &ambient_val,
                raylib.ShaderUniformDataType.UNIFORM_VEC4);

        _lights.reserve(max_lights);
        _comps.reserve(max_lights);
    }

    override void update() {
        // update camera view pos in light shader
        float[3] camera_pos = [
            (cast(Scene3D) scene).cam.transform.position.x, (cast(Scene3D) scene)
            .cam.transform.position.y, (cast(Scene3D) scene).cam.transform.position.z
        ];
        raylib.SetShaderValue(shader, shader.locs[raylib.ShaderLocationIndex.LOC_VECTOR_VIEW],
                &camera_pos, raylib.ShaderUniformDataType.UNIFORM_VEC3);

        // update lights
        for (int i = 0; i < light_count; i++) {
            // sync fields
            _lights[i].position = _comps[i].transform.position;
            _lights[i].color = _comps[i].color;
            _lights[i].enabled = _comps[i].light_enabled;

            // update shader values
            update_shader_lights(shader, _lights[i]);
        }
    }

    override void destroy() {
        while (light_count > 0) {
            unregister(_comps[0]);
        }
    }

    private void register(Light3D light_comp) {
        assert(light_count < max_lights, "maximum light count exceeded.");
        // add a light
        _lights.insertBack(set_light(light_count, ShaderLightType.LIGHT_POINT,
                light_comp.transform.position, Vector3Zero, light_comp.color, shader));
        _comps.insertBack(light_comp);
        // set internal light reference
        light_comp._light = _lights[light_count];
        light_count++;
    }

    private void unregister(Light3D light_comp) {
        import std.range : dropExactly, takeOne;

        auto removed_index = cast(int) _comps[].countUntil(light_comp);
        // clear all lights
        for (int i = 0; i < light_count; i++) {
            clear_light(i, shader);
        }
        _comps.linearRemove(_comps[].dropExactly(removed_index).takeOne);
        _lights.linearRemove(_lights[].dropExactly(removed_index).takeOne);
        light_count--; // we're removing a light
        // ensure our lengths match
        assert(_lights.length == light_count);
        assert(_lights.length == _comps.length);
        // reactivate the lights
        for (int i = 0; i < light_count; i++) {
            // update shader
            _lights[i] = set_light(i, ShaderLightType.LIGHT_POINT,
                    _comps[i].transform.position, Vector3Zero, _comps[i].color, shader);
            // set associated light
            _comps[i]._light = _lights[i];
        }
    }

    // - ported from rlights

    private static ShaderLight set_light(int index, ShaderLightType type,
            Vector3 pos, Vector3 target, Color color, Shader shader, bool enabled = true) {
        ShaderLight light;

        light.enabled = enabled;
        light.type = type;
        light.position = pos;
        light.target = target;
        light.color = color;

        char[32] enabledName = "lights[x].enabled\0";
        char[32] typeName = "lights[x].type\0";
        char[32] posName = "lights[x].position\0";
        char[32] targetName = "lights[x].target\0";
        char[32] colorName = "lights[x].color\0";

        // Set location name [x] depending on lights count
        enabledName[7] = cast(char)('0' + index);
        typeName[7] = cast(char)('0' + index);
        posName[7] = cast(char)('0' + index);
        targetName[7] = cast(char)('0' + index);
        colorName[7] = cast(char)('0' + index);

        light.enabledLoc = raylib.GetShaderLocation(shader, cast(char*) enabledName);
        light.typeLoc = raylib.GetShaderLocation(shader, cast(char*) typeName);
        light.posLoc = raylib.GetShaderLocation(shader, cast(char*) posName);
        light.targetLoc = raylib.GetShaderLocation(shader, cast(char*) targetName);
        light.colorLoc = raylib.GetShaderLocation(shader, cast(char*) colorName);

        update_shader_lights(shader, light);

        return light;
    }

    private static void clear_light(int index, Shader shader) {
        // reset the light
        set_light(index, ShaderLightType.LIGHT_POINT, Vector3Zero, Vector3Zero,
                Colors.BLANK, shader, false);
    }

    // Send light properties to shader
    // NOTE: ShaderLight shader locations should be available 
    private static void update_shader_lights(Shader shader, ShaderLight light) {
        // Send to shader light enabled state and type
        raylib.SetShaderValue(shader, light.enabledLoc, &light.enabled,
                raylib.ShaderUniformDataType.UNIFORM_INT);
        raylib.SetShaderValue(shader, light.typeLoc, &light.type,
                raylib.ShaderUniformDataType.UNIFORM_INT);

        // Send to shader light position values
        float[3] position = [
            light.position.x, light.position.y, light.position.z
        ];
        raylib.SetShaderValue(shader, light.posLoc, &position,
                raylib.ShaderUniformDataType.UNIFORM_VEC3);

        // Send to shader light target position values
        float[3] target = [light.target.x, light.target.y, light.target.z];
        raylib.SetShaderValue(shader, light.targetLoc, &target,
                raylib.ShaderUniformDataType.UNIFORM_VEC3);

        // Send to shader light color values
        float[4] color = [
            cast(float) light.color.r / cast(float) 255,
            cast(float) light.color.g / cast(float) 255,
            cast(float) light.color.b / cast(float) 255,
            cast(float) light.color.a / cast(float) 255
        ];
        raylib.SetShaderValue(shader, light.colorLoc, &color,
                raylib.ShaderUniformDataType.UNIFORM_VEC4);
    }
}

/// represents a 3D light
class Light3D : Component, Renderable3D {
    private SceneLightManager _mgr;
    private enum phys_size = 0.2;
    private SceneLightManager.ShaderLight _light;

    /// the color of the light
    public Color color;

    /// whether the light is enabled
    public bool light_enabled = true;

    /// creates a new light with a given color
    this(Color color = Colors.WHITE) {
        this.color = color;
    }

    override void setup() {
        // register the light in the manager
        auto mgr = entity.scene.get_manager!SceneLightManager();
        assert(!mgr.isNull, "scene did not have SceneLightManager registered."
                ~ "please add that to the scene before creating this component.");
        _mgr = mgr.get;
        _mgr.register(this);
    }

    override void destroy() {
        _mgr.unregister(this);
    }

    @property BoundingBox bounds() {
        auto size = Vector3(phys_size, phys_size, phys_size);
        return BoundingBox(entity.position - size, entity.position + size);
    }

    void render() {
    }

    void debug_render() {
        import re.ng.diag.render;

        raylib.DrawSphereEx(entity.position, phys_size, 8, 8, color);
        raylib.DrawSphereWires(entity.position, phys_size * 1.5, 2, 2, DebugRender.debug_color);
    }
}
