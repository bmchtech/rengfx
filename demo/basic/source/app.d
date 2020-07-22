import std.stdio;

import re;
import std.stdio;
import bounce;

class Game : Core {
	this() {
		super(960, 540, "basic demo");
	}

	override void initialize() {
		super.initialize();

		log.verbosity = Logger.Verbosity.Trace;
		log.info("basic demo game initialized.");

		content.base_path = "../content/";

		// set up stuff and things
		scenes ~= new BounceScene();

		// set scene
		scene = scenes[next_scene];
		next_scene = (next_scene + 1) % scenes.length;
	}

	public static Scene[] scenes;
	public static size_t next_scene = 0;
}

void main() {
	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up
}
