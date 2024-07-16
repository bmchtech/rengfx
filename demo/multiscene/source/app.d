import std.stdio;

import re;
import re.math;
import std.stdio;
import play;

class Game : Core {
	enum WIDTH = 800;
	enum HEIGHT = 400;

	this() {
		super(WIDTH, HEIGHT, "multiscene");
	}

	override void initialize() {
		default_resolution = Vector2(WIDTH / 4, HEIGHT / 4);
		content.paths ~= "../content/";

		load_scenes([new PlayScene()]);
	}
}

void main() {
	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up
}
