module app;

import std.stdio;

import re;
import re.math;
import std.stdio;
import play;

class Game : Core {
	enum CAPTURE_DIMENS = 32;
	enum WIDTH = CAPTURE_DIMENS;
	enum HEIGHT = CAPTURE_DIMENS;

	this() {
		super(WIDTH, HEIGHT, "flatten");
	}

	override void initialize() {
		default_resolution = Vector2(WIDTH, HEIGHT);
		content.paths ~= ["../content/", "content/"];

		load_scenes([new PlayScene()]);
	}
}

void main() {
	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up
}
