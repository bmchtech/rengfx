module re.content;

static import raylib;
import std.string;
import std.file;
import std.path;
import re.util.cache;

/// manages external content loading
class ContentManager {
    private KeyedCache!(raylib.Texture2D) _tex_cache;
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
        raylib.Texture2D tex;
        immutable auto cached = _tex_cache.get(path);
        if (cached.isNull) {
            auto image = raylib.LoadImage(get_path(path));
            tex = raylib.LoadTextureFromImage(image);
            raylib.UnloadImage(image);
            _tex_cache.put(path, tex);
        } else {
            tex = cached.get;
        }

        // copy image to VRAM
        return tex;
    }

    /// releases all resources
    public void destroy() {
        foreach (texture; _tex_cache.get_all) {
            raylib.UnloadTexture(texture);
        }
        _tex_cache.drop();
    }
}
