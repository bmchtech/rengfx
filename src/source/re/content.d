module re.content;

static import raylib;
import std.string;
import std.file;
import std.path;
import re.util.cache;

/// manages external content loading
class ContentManager {
    private KeyedCache!(raylib.Image) _image_cache;
    /// search paths for content
    public string[] paths;

    /// initializes the content manager
    this() {
        // setup
    }

    private char* get_path(string path) {
        auto base = string.init;
        alias join_paths = std.path.buildNormalizedPath;
        // check search paths first
        foreach (search_path; paths) {
            // if the combination path exists, then make this base
            if (std.file.exists(join_paths(search_path, path))) {
                base = search_path;
                break;
            }
        }
        return cast(char*) toStringz(join_paths(base, path));
    }

    /// loads a texture from disk
    public raylib.Texture2D load_texture2d(string path) {
        raylib.Image image;
        auto cached = _image_cache.get(path);
        if (cached.isNull) {
            image = raylib.LoadImage(get_path(path));
            _image_cache.put(path, image);
        } else {
            image = cached.get;
        }

        // copy image to VRAM
        return raylib.LoadTextureFromImage(image);
    }

    /// releases all resources
    public void destroy() {
        _image_cache.drop();
    }
}
