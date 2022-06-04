/** content/asset loader and manager */

module re.content;

import std.string;
import std.file;
import std.conv;
import std.path;
import std.stdio;
import std.exception: enforce;

import re.util.cache;
import re.util.interop;
static import raylib;

/// manages external content loading
class ContentManager {
    alias TexCache = KeyedCache!(raylib.Texture2D);
    private TexCache _tex_cache;
    alias ModelCache = KeyedCache!(raylib.Model);
    private ModelCache _mdl_cache;
    alias ShaderCache = KeyedCache!(raylib.Shader);
    private ShaderCache _shd_cache;

    /// search paths for content
    public string[] paths;

    /// initializes the content manager
    this() {
        // setup
        _tex_cache = TexCache((tex) { raylib.UnloadTexture(tex); });
        _mdl_cache = ModelCache((mdl) { raylib.UnloadModel(mdl); });
        _shd_cache = ShaderCache((shd) { raylib.UnloadShader(shd); });
    }

    /// get the physical path to a logical content path
    public string get_path(string path) {
        // check if this is already a valid path
        if (std.file.exists(path)) {
            return path;
        }
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
        return join_paths(base, path);
    }

    private char* get_path_cstr(string path) {
        return get_path(path).c_str;
    }

    /// loads a texture from disk
    public raylib.Texture2D load_texture2d(string path) {
        raylib.Texture2D tex;
        auto cached = _tex_cache.get(path);
        if (cached.isNull) {
            auto image = raylib.LoadImage(get_path_cstr(path));
            tex = raylib.LoadTextureFromImage(image);
            raylib.UnloadImage(image);
            _tex_cache.put(path, tex);
        } else {
            tex = cached.get;
        }

        // copy image to VRAM
        return tex;
    }

    /// loads a model from disk
    public raylib.Model load_model(string path) {
        raylib.Model mdl;
        auto cached = _mdl_cache.get(path);
        if (cached.isNull) {
            mdl = raylib.LoadModel(get_path_cstr(path));
            _mdl_cache.put(path, mdl);
        } else {
            mdl = cached.get;
        }
        return mdl;
    }

    public raylib.ModelAnimation[] load_model_animations(string path) {
        uint num_loaded_anims = 0;
        raylib.ModelAnimation* loaded_anims = raylib.LoadModelAnimations(get_path_cstr(path), &num_loaded_anims);
        auto anims = loaded_anims[0 .. num_loaded_anims]; // access array as slice
        return anims;
    }

    /// loads a shader from disk (vertex shader, fragment shader).
    /// pass null to either arg to use the default
    public raylib.Shader load_shader(string vs_path, string fs_path, bool bypass_cache = false) {
        raylib.Shader shd;
        import std.digest.sha : sha1Of, toHexString;

        auto path_hash = to!string(sha1Of(vs_path ~ fs_path).toHexString);
        auto cached = _shd_cache.get(path_hash);
        if (cached.isNull || bypass_cache) {
            auto vs = vs_path.length > 0 ? get_path_cstr(vs_path) : null;
            auto fs = fs_path.length > 0 ? get_path_cstr(fs_path) : null;
            shd = raylib.LoadShader(vs, fs);
            if (!bypass_cache)
                _shd_cache.put(path_hash, shd);
        } else {
            shd = cached.get;
        }
        return shd;
    }

    /// loads music from disk
    public raylib.Music load_music(string file_path) {
        if (!exists(get_path(file_path))) enforce(0, format("music file not found: %s", file_path));
        return raylib.LoadMusicStream(get_path_cstr(file_path));
    }

    public void unload_music(raylib.Music music) {
        raylib.UnloadMusicStream(music);
    }

    public void drop_caches() {
        // delete textures
        _tex_cache.drop();
        // delete models
        _mdl_cache.drop();
        // delete shaders
        _shd_cache.drop();
    }

    /// releases all resources
    public void destroy() {
        drop_caches();
    }
}
