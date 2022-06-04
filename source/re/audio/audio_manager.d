module re.audio.audio_manager;

import re.core;
import re.ecs;
import re.ng.manager;

static import raylib;

class AudioManager : Manager, Updatable {
    this() {

    }

    override void setup() {
        raylib.InitAudioDevice();
    }

    override void update() {
        
    }
}