module re.gfx.lighting.scene_lights;

import re.core;
import re.ecs;
import re.ng.manager;
import re.ng.scene3d;
import re.gfx;
import re.math;
import std.algorithm;
static import raylib;
import rlights = re.gfx.lighting.rlights;

/// acts as a manager for Light3D components
class SceneLightManager : Manager, Updatable {
    alias max_lights = rlights.MAX_LIGHTS;
    private rlights.Light[max_lights] _lights;
    private Light3D[max_lights] _comps;
    private int light_count;
    public Shader shader;

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
            rlights.UpdateLightValues(shader, _lights[i]);
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
        _lights[light_count] = rlights.set_light(light_count, rlights.LightType.LIGHT_POINT,
                light_comp.transform.position, Vector3Zero, light_comp.color, shader);
        _comps[light_count] = light_comp;
        light_comp._light = _lights[light_count];
        light_count++;
    }

    private void unregister(Light3D light_comp) {
        auto ix = cast(int) _comps[].countUntil(light_comp);
        Light3D[] new_comps;
        rlights.Light[] new_lights;
        // clear all lights
        for (int i = 0; i < light_count; i++) {
            rlights.clear_light(ix, shader);
        }
        // re-add components
        for (int i = 0; i < light_count; i++) {
            auto comp = _comps[i];
            if (comp == light_comp)
                continue;
            new_comps ~= comp;
        }
        // re-add lights
        for (int i = 0; i < light_count; i++) {
            auto light = _lights[i];
            if (i == ix)
                continue;
            new_lights ~= light;
        }
        light_count--; // we're removing a light
        assert(new_comps.length == new_lights.length);
        // reactivate the lights
        for (int i = 0; i < new_lights.length; i++) {
            _comps[i] = new_comps[i];
            // update shader
            _lights[i] = rlights.set_light(light_count, rlights.LightType.LIGHT_POINT,
                    _comps[i].transform.position, Vector3Zero, _comps[i].color, shader);
            // set associated light
            _comps[i]._light = _lights[i];
        }
    }
}

/// represents a 3D light
class Light3D : Component, Renderable3D {
    public Color color;
    private SceneLightManager _mgr;
    private enum phys_size = 0.2;
    private rlights.Light _light;

    public bool light_enabled = true;

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
