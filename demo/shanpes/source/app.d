import std.stdio;

import re;
import re.math;
import std.stdio;
import play;

class Game : Core {
	enum WIDTH = 640;
	enum HEIGHT = 480;

	this() {
		super(WIDTH, HEIGHT, "shanpes");
	}

	override void initialize() {
		default_resolution = Vector2(WIDTH / 4, HEIGHT / 4);
		content.paths ~= "../content/";

		scene = new PlayScene();
	}
}

void main() {
	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up
}
