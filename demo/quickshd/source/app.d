module app;

import std.stdio;

import re;
import re.gfx;
import re.gfx.shapes.model;
import re.gfx.shapes.grid;
import re.gfx.shapes.cube;
import re.gfx.effects.frag;
import re.ng.camera;
import re.util.hotreload;
import re.math;
static import raylib;

class Game : Core {
	enum WIDTH = 960;
	enum HEIGHT = 540;

	this() {
		super(WIDTH, HEIGHT, "quickshd");
	}

	override void initialize() {
		default_resolution = Vector2(WIDTH, HEIGHT);
		content.paths ~= ["../content/", "content/"];

		load_scenes([new PlayScene()]);
	}
}

class PlayScene : Scene3D {
	SceneCamera3D cam;
	Effect postfx1;
	Effect cubefx1;
	Cube cube1;

	override void on_start() {
		clear_color = Colors.LIGHTGRAY;

		cam = (cast(Viewport3D) viewports[0]).cam;

		// set the camera position
		cam.entity.position = Vector3(0, 10, 10);

		auto block = create_entity("block", Vector3(0, 0, 0));
		cube1 = block.add_component(new Cube(Vector3(2, 2, 2)));

		// point the camera at the block, then orbit it
		cam.look_at(block.position);
		cam.entity.add_component(new CameraOrbit(block, 0.5));

		// enable an example shader on cube
		// auto cross_stitch = new Effect(Core.content.load_shader(null,
		// 		"shader/cross_stitch.frag").front, Colors.DARKGREEN);
		cubefx1 = new FragEffect(this, new ReloadableShader(null, "shader/cross_stitch.frag"));
		cubefx1.color = Colors.DARKGREEN;

		// draw a grid at the origin
		auto grid = create_entity("grid");
		grid.add_component(new Grid3D(10, 1));

		// add postprocessing
		postfx1 = new Effect(new ReloadableShader(null, "shader/chromatic_aberration.frag"));
		auto postfx1_pp = new PostProcessor(resolution, postfx1);
		postprocessors ~= postfx1_pp;
	}

	override void update() {
		super.update();

		cubefx1.update();
		cube1.effect = cubefx1; // update shader effect
		// cubefx1.set_shader_var_imm("stitch_mix", cast(float) 0.05);

		postfx1.update();
		postfx1.set_shader_var_imm("sample_offset", cast(float[2])[0.005, 0.0]);
	}
}

void main() {
	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up
}
