/** content/asset loader and manager */

module re.content;

import std.string;
import std.file;
import std.conv;
import std.path;
import std.stdio;
import std.exception : enforce;
import optional;

import re.util.cache;
import re.util.interop;
static import raylib;

/// manages external content loading
class ContentManager {
    /// search paths for content
    public string[] paths;

    alias Texture2D = raylib.Texture2D;
    alias Model = raylib.Model;
    alias Shader = raylib.Shader;
    alias Music = raylib.Music;

    private KeyedCache!Texture2D texture_cache;
    private KeyedCache!Model model_cache;
    private KeyedCache!Shader shader_cache;
    private KeyedCache!Music music_cache;

    /// initializes the content manager
    this() {
        // setup caches
        texture_cache = KeyedCache!Texture2D(tex => raylib.UnloadTexture(tex));
        model_cache = KeyedCache!Model(mdl => raylib.UnloadModel(mdl));
        shader_cache = KeyedCache!Shader(shd => raylib.UnloadShader(shd));
        music_cache = KeyedCache!Music(mus => raylib.UnloadMusicStream(mus));
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

    private KeyedCache!T cache_for(T)() {
        static if (is(T == Texture2D)) {
            return texture_cache;
        } else static if (is(T == Model)) {
            return model_cache;
        } else static if (is(T == Shader)) {
            return shader_cache;
        } else static if (is(T == Music)) {
            return music_cache;
        } else {
            static assert(0, format("no cache found for type %s", typeof(T)));
        }
    }

    private Optional!T load_cached_asset(T)(string path, T delegate(string) load_func) {
        auto cache = cache_for!T();
        auto cached = cache.get(path);
        if (cached.isNull) {
            auto real_path = get_path(path);
            if (!exists(real_path)) {
                return no!T;
            }
            auto asset = load_func(real_path);
            cache.put(path, asset);
            return some(asset);
        } else {
            auto asset = cached.get;
            return some(asset);
        }
    }

    /// loads a texture from disk
    public Optional!Texture2D load_texture2d(string path) {
        return load_cached_asset!Texture2D(path, (x) => raylib.LoadTexture(x.c_str));
    }

    /// loads a model from disk
    public Optional!Model load_model(string path) {
        return load_cached_asset!Model(path, (x) => raylib.LoadModel(x.c_str));
    }

    // public raylib.ModelAnimation[] load_model_animations(string path) {
    //     uint num_loaded_anims = 0;
    //     raylib.ModelAnimation* loaded_anims = raylib.LoadModelAnimations(get_path_cstr(path), &num_loaded_anims);
    //     auto anims = loaded_anims[0 .. num_loaded_anims]; // access array as slice
    //     return anims;
    // }

    /// loads a shader from disk (vertex shader, fragment shader).
    /// pass null to either arg to use the default
    /// since loading shaders is a bit of a pain, the loader uses custom logic
    public Optional!Shader load_shader(string vs_path, string fs_path, bool bypass_cache = false) {
        raylib.Shader shd;
        import std.digest.sha : sha1Of, toHexString;

        auto path_hash = to!string(sha1Of(vs_path ~ fs_path).toHexString);
        auto cache = cache_for!Shader();
        auto cached = cache.get(path_hash);
        if (cached.isNull || bypass_cache) {
            auto vs_real_path = get_path(vs_path);
            auto fs_real_path = get_path(fs_path);
            if (!exists(vs_real_path) && !exists(fs_real_path)) {
                // neither path exists
                return no!Shader;
            }
            auto vs = vs_path.length > 0 ? get_path_cstr(vs_path) : null;
            auto fs = fs_path.length > 0 ? get_path_cstr(fs_path) : null;
            shd = raylib.LoadShader(vs, fs);
            if (!bypass_cache)
                cache.put(path_hash, shd);
        } else {
            shd = cached.get;
        }
        return some(shd);
    }

    /// loads music from disk
    public Optional!Music load_music(string file_path) {
        return load_cached_asset!Music(file_path, (x) => raylib.LoadMusicStream(x.c_str));
    }

    public void drop_caches() {
        cache_for!Texture2D().drop();
        cache_for!Model().drop();
        cache_for!Shader().drop();
        cache_for!Music().drop();
    }

    /// releases all resources
    public void destroy() {
        drop_caches();
    }
}
