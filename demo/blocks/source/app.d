module app;

import std.stdio;

import re;
import re.math;
import std.stdio;
import play;
import hud;

class Game : Core {
	enum WIDTH = 1280;
	enum HEIGHT = 720;

	this() {
		super(WIDTH, HEIGHT, "blocks");
	}

	override void initialize() {
		// default_resolution = Vector2(WIDTH / 2, HEIGHT / 2);
		content.paths ~= ["../content/", "content/"];

		load_scenes([new PlayScene(), new HUDScene()]);
	}
}

void main() {
	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up
}
