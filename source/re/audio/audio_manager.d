module re.audio.audio_manager;

import re.core;
import re.ecs;
import re.ng.manager;

static import raylib;

class AudioManager : Manager, Updatable {
    this() {
        raylib.InitAudioDevice();
    }

    enum Mode {
        Idle,
        PlayMusic,
    }

    public Mode mode;
    public raylib.Music music_stream;

    override void setup() {
    }

    override void update() {
        switch (mode) {
        case Mode.PlayMusic:
            raylib.UpdateMusicStream(music_stream);
            import std.stdio;

            break;
        default:
            break;
        }
    }

    public void play_music(raylib.Music music) {
        mode = Mode.PlayMusic;
        this.music_stream = music;
        raylib.PlayMusicStream(music_stream);
    }
}
