module app;

import std.stdio;

import re;
import re.gfx;
import re.gfx.shapes.model;
import re.gfx.shapes.grid;
import re.gfx.shapes.cube;
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
	public Effect postfx1;

	override void on_start() {
		clear_color = Colors.LIGHTGRAY;

		// set the camera position
		cam.entity.position = Vector3(0, 10, 10);

		auto block = create_entity("block", Vector3(0, 0, 0));
		auto cube = block.add_component(new Cube(Vector3(2, 2, 2)));

		// point the camera at the block, then orbit it
		cam.look_at(block.position);
		cam.entity.add_component(new CameraOrbit(block, 0.5));

		// enable an example shader on cube
		auto cross_stitch = new Effect(Core.content.load_shader(null,
				"shader/cross_stitch.frag"), Colors.DARKGREEN);
		auto mixAmt = 0.05f;
		cross_stitch.set_shader_var("mixAmt", mixAmt);
		cube.effect = cross_stitch;

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

		postfx1.update();
		// postfx1.set_shader_var_imm("sample_offset", cast(float[2])[0.005, 0.05]);
	}
}

void main() {
	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up
}
