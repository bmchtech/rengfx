module re.gfx.lighting.rlights;

import raylib;

/**********************************************************************************************
*
*   raylib.lights - Some useful functions to deal with lights data
*
*   CONFIGURATION:
*
*   enum RLIGHTS_IMPLEMENTATION
*       Generates the implementation of the library into the included file.
*       If not defined, the library is in header only mode and can be included in other headers 
*       or source files without problems. But only ONE file should hold the implementation.
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2017 Victor Fisac and Ramon Santamaria
*
*   This software is provided "as-is", without any express or implied warranty. In no event
*   will the authors be held liable for any damages arising from the use of this software.
*
*   Permission is granted to anyone to use this software for any purpose, including commercial
*   applications, and to alter it and redistribute it freely, subject to the following restrictions:
*
*     1. The origin of this software must not be misrepresented; you must not claim that you
*     wrote the original software. If you use this software in a product, an acknowledgment
*     in the product documentation would be appreciated but is not required.
*
*     2. Altered source versions must be plainly marked as such, and must not be misrepresented
*     as being the original software.
*
*     3. This notice may not be removed or altered from any source distribution.
*
**********************************************************************************************/

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------
enum MAX_LIGHTS = 4; // max lights supported by shader

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
enum LightType {
    LIGHT_DIRECTIONAL,
    LIGHT_POINT
}

struct Light {
    int type;
    Vector3 position;
    Vector3 target;
    Color color;
    bool enabled;

    // Shader locations
    int enabledLoc;
    int typeLoc;
    int posLoc;
    int targetLoc;
    int colorLoc;
}

/***********************************************************************************
*
*   RLIGHTS IMPLEMENTATION
*
************************************************************************************/

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------
// ...

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
// ...

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------
static int lightsCount = 0; // Current amount of created lights

//----------------------------------------------------------------------------------
// Module specific Functions Declaration
//----------------------------------------------------------------------------------
// ...

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------

// Defines a light and get locations from PBR shader
static Light CreateLight(int type, Vector3 pos, Vector3 targ, Color color, Shader shader) {
    Light light;

    if (lightsCount < MAX_LIGHTS) {
        light.enabled = true;
        light.type = cast(LightType) type;
        light.position = pos;
        light.target = targ;
        light.color = color;

        char[32] enabledName = "lights[x].enabled\0";
        char[32] typeName = "lights[x].type\0";
        char[32] posName = "lights[x].position\0";
        char[32] targetName = "lights[x].target\0";
        char[32] colorName = "lights[x].color\0";

        // Set location name [x] depending on lights count
        enabledName[7] = cast(char)('0' + lightsCount);
        typeName[7] = cast(char)('0' + lightsCount);
        posName[7] = cast(char)('0' + lightsCount);
        targetName[7] = cast(char)('0' + lightsCount);
        colorName[7] = cast(char)('0' + lightsCount);

        light.enabledLoc = GetShaderLocation(shader, cast(char*) enabledName);
        light.typeLoc = GetShaderLocation(shader, cast(char*) typeName);
        light.posLoc = GetShaderLocation(shader, cast(char*) posName);
        light.targetLoc = GetShaderLocation(shader, cast(char*) targetName);
        light.colorLoc = GetShaderLocation(shader, cast(char*) colorName);

        UpdateLightValues(shader, light);

        lightsCount++;
    }

    return light;
}

// Send light properties to shader
// NOTE: Light shader locations should be available 
void UpdateLightValues(Shader shader, Light light) {
    // Send to shader light enabled state and type
    SetShaderValue(shader, light.enabledLoc, &light.enabled,
            raylib.ShaderUniformDataType.UNIFORM_INT);
    SetShaderValue(shader, light.typeLoc, &light.type, raylib.ShaderUniformDataType.UNIFORM_INT);

    // Send to shader light position values
    float[3] position = [light.position.x, light.position.y, light.position.z];
    SetShaderValue(shader, light.posLoc, &position, raylib.ShaderUniformDataType.UNIFORM_VEC3);

    // Send to shader light target position values
    float[3] target = [light.target.x, light.target.y, light.target.z];
    SetShaderValue(shader, light.targetLoc, &target, raylib.ShaderUniformDataType.UNIFORM_VEC3);

    // Send to shader light color values
    float[4] color = [
        cast(float) light.color.r / cast(float) 255,
        cast(float) light.color.g / cast(float) 255,
        cast(float) light.color.b / cast(float) 255,
        cast(float) light.color.a / cast(float) 255
    ];
    SetShaderValue(shader, light.colorLoc, &color, raylib.ShaderUniformDataType.UNIFORM_VEC4);
}
