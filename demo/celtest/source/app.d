module app;

import std.stdio;

import re;
import re.math;
import std.stdio;
import play;
import hud;
import std.getopt;

static import raylib;

class Game : Core {
	// enum WIDTH = 960;
	// enum HEIGHT = 540;
	version (lite) {
		// enum WIDTH = 640;
		// enum HEIGHT = 480;
		enum WIDTH = 640;
		enum HEIGHT = 480;
	} else {
		enum WIDTH = 800;
		enum HEIGHT = 450;
	}

	public static string custom_mdl1_path = null;
	public static bool free_look = false;
	public static bool vr_enabled = false;

	this() {
		// super(WIDTH, HEIGHT, "celtest");
		super(WIDTH, HEIGHT, vr_enabled ? "celtest [VR]" : "celtest");
	}

	override void initialize() {
		// default_resolution = Vector2(WIDTH, HEIGHT);
		content.paths ~= ["../content/", "content/"];

		// load_scenes([new PlayScene(), new HUDScene()]);
		load_scenes([new PlayScene()]);
	}
}

int main(string[] args) {
	bool verbose;
	auto help = getopt(args,
		"verbose|v", &verbose,
		"model|m", &Game.custom_mdl1_path,
		"free-cam|f", &Game.free_look,
		"vr", &Game.vr_enabled,
	);

	// Core.auto_compensate_hidpi = false;

	if (help.helpWanted) {
		defaultGetoptPrinter("Usage: ./a [--model /path/to/model.glb] [-f]", help.options);
		return 1;
	}

	raylib.SetConfigFlags(raylib.ConfigFlags.FLAG_MSAA_4X_HINT);
	import re.util.logger;

	if (verbose) {
		raylib.SetTraceLogLevel(raylib.TraceLogLevel.LOG_INFO);
	} else {
		raylib.SetTraceLogLevel(raylib.TraceLogLevel.LOG_WARNING);
	}

	auto game = new Game(); // init game

	if (verbose) {
		Core.log.verbosity = Logger.Verbosity.Trace;
	} else {
		Core.log.verbosity = Logger.Verbosity.Information;
	}
	Core.log.trace("starting game");

	if (Game.vr_enabled) {
		// VR device parameters definition
		raylib.VrDeviceInfo vr_device_info;
		vr_device_info.hResolution = 2160;
		vr_device_info.vResolution = 1200;
		vr_device_info.hScreenSize = 0.133793f;
		vr_device_info.vScreenSize = 0.0669f;
		vr_device_info.vScreenCenter = 0.04678f;
		vr_device_info.eyeToScreenDistance = 0.041f;
		vr_device_info.lensSeparationDistance = 0.07f;
		vr_device_info.interpupillaryDistance = 0.07f;
		// NOTE: CV1 uses fresnel-hybrid-asymmetric lenses with specific compute shaders
		// Following parameters are just an approximation to CV1 distortion stereo rendering
		vr_device_info.lensDistortionValues[0] = 1.0f;
		vr_device_info.lensDistortionValues[1] = 0.22f;
		vr_device_info.lensDistortionValues[2] = 0.24f;
		vr_device_info.lensDistortionValues[3] = 0.0f;
		vr_device_info.chromaAbCorrection[0] = 0.996f;
		vr_device_info.chromaAbCorrection[1] = -0.004f;
		vr_device_info.chromaAbCorrection[2] = 1.014f;
		vr_device_info.chromaAbCorrection[3] = 0.0f;

		Game.vr.setup_vr(vr_device_info);

		// assert(0, "VR not implemented yet");
	}

	game.run();
	game.destroy(); // clean up

	return 0;
}
