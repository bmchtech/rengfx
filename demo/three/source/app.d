module app;

import std.stdio;

import re;
import re.math;
import std.stdio;
import play;
import hud;

class Game : Core {
	enum WIDTH = 640;
	enum HEIGHT = 480;

	this() {
		super(WIDTH, HEIGHT, "three");
	}

	override void initialize() {
		default_resolution = Vector2(WIDTH, HEIGHT);
		content.paths ~= ["../content/", "content/"];

		load_scenes([new PlayScene(), new HUDScene()]);
	}
}

void main() {
	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up
}
