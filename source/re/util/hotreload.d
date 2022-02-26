module re.util.hotreload;

import re.core;
import re.content;
import re.util.interop;
import re.gfx.raytypes;
static import raylib;

interface Reloadable(T) {
    bool changed();
    T reload();
}

class ReloadableFile(T) : Reloadable!T {
    string[] source_files;
    long[] file_mod_times;

    this(string[] source_files) {
        this.source_files = source_files;
    }

    protected long get_file_mod_time(string file) {
        return raylib.GetFileModTime(file.c_str);
    }

    bool changed() {
        // make sure we have mod times for each file
        if (file_mod_times.length != source_files.length) {
            file_mod_times = [];
            // preallocate space
            file_mod_times.length = source_files.length;
            // now fetch the mod times
            for (int i = 0; i < source_files.length; i++) {
                file_mod_times[i] = get_file_mod_time(source_files[i]);
            }
            // this is first time we are updating
            return true;
        }
        // we already have previous entries for mod times, so check if any have changed
        // get all most recent mod times
        for (int i = 0; i < source_files.length; i++) {
            auto prev_mod_time = file_mod_times[i];
            long new_mod_time = get_file_mod_time(source_files[i]);
            file_mod_times[i] = new_mod_time;
            if (prev_mod_time != new_mod_time) {
                // at least one file has changed
                return true;
            }
        }
        return false;
    }

    abstract T reload();
}

class ReloadableShader : ReloadableFile!Shader {
    private enum VS_INDEX = 0;
    private enum FS_INDEX = 1;

    this(string vs_path, string fs_path) {
        super([vs_path, fs_path]);
    }

    override Shader reload() {
        // load shader, bypassing cache
        return Core.content.load_shader(source_files[VS_INDEX], source_files[FS_INDEX], true);
    }
}

@("hotreload-basic")
unittest {
    class ReloadableBag : Reloadable!int {
        int beans;
        int external_bean_register;

        this(int beans) {
            this.beans = beans;
            this.external_bean_register = this.beans;
        }

        bool changed() {
            return beans != external_bean_register;
        }

        int reload() {
            beans = external_bean_register;
            return beans;
        }
    }

    // create bag
    auto bag = new ReloadableBag(10);
    assert(bag.beans == 10);
    // check that it's not changed
    assert(!bag.changed());

    // change bag
    bag.external_bean_register = 20;
    assert(bag.changed());
    // reload bag
    assert(bag.reload() == 20);
}

@("hotreload-file")
unittest {
    bool fake_changed = false;
    long init_fake_time = 0;
    long new_fake_time = 10;
    int old_beans = 10;
    int new_beans = 20;

    class ReloadableMockFileBag : ReloadableFile!int {
        this(string mock_bean_file) {
            super([mock_bean_file]);
        }

        override long get_file_mod_time(string file) {
            return fake_changed ? new_fake_time : init_fake_time;
        }

        override int reload() {
            return fake_changed ? new_beans : old_beans;
        }
    }

    // create bag
    auto bag = new ReloadableMockFileBag("mock_bean_file");
    // it should be changed the first time, because on loading modtime it triggers a changed event
    assert(bag.changed());
    assert(bag.reload() == old_beans);
    // now, this time it should not be changed
    assert(!bag.changed());
    assert(bag.reload() == old_beans);
    // now, change the modtime
    fake_changed = true;
    // it should be changed now
    assert(bag.changed());
    assert(bag.reload() == new_beans);
    // it shold not be changed now
    assert(!bag.changed());
    assert(bag.reload() == new_beans);
}
