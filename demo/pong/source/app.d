import std.stdio;

import re;
import re.math;
import std.stdio;
import play;

class Game : Core {
	enum WIDTH = 480;
	enum HEIGHT = 800;

	this() {
		super(WIDTH, HEIGHT, "pong");
	}

	override void initialize() {
		default_resolution = Vector2(WIDTH / 2, HEIGHT / 2);
		content.paths ~= ["../content/", "content/"];

		load_scenes([new PlayScene()]);
	}
}

void main() {
	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up
}
