module re.gfx.lighting.scene_lights;

import re.core;
import re.ecs;
import re.ng.manager;
import re.ng.scene3d;
import re.gfx;
import re.math;
static import raylib;
import rlights = re.gfx.lighting.rlights;

/// acts as a manager for Light3D components
class SceneLightManager : Manager, Updatable {
    alias max_lights = rlights.MAX_LIGHTS;
    private int light_count = 0;
    private rlights.Light[max_lights] lights;
    private Light3D[] _light_comps;
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
        for (int i = 0; i < _light_comps.length; i++) {
            auto comp = _light_comps[i];
            // sync position
            lights[i].position = comp.transform.position;
            // update shader values
            rlights.UpdateLightValues(shader, lights[i]);
        }
    }

    override void destroy() {
        // TODO: clean up after lights
    }

    private void register(Light3D light) {
        lights[light_count] = rlights.CreateLight(rlights.LightType.LIGHT_POINT,
                light.transform.position, Vector3Zero, light.color, shader);
        _light_comps ~= light;
    }

    private void unregister(Light3D light) {
        // TODO: properly handle this
    }
}

/// represents a 3D light
class Light3D : Component, Renderable3D {
    public Color color;
    private SceneLightManager _mgr;
    private enum phys_size = 0.2;

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
