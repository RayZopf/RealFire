// Realfire by Rene - Smoke
//
// Author: Rene10957 Resident
// Date: 05-10-2014
//
// This work is licensed under the Creative Commons Attribution 3.0 Unported (CC BY 3.0) License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/.
//
// Author and license headers must be left intact.
// Content creator? Please read the license notecard!

string title = "RealSmoke";          // title
string version = "2.2";              // version
integer silent = FALSE;              // silent startup

// Constants

integer smokeChannel = -15790;       // smoke channel
key texture = "5de058da-95f0-2736-b0e0-e218184ddece";   // whispy smoke

// Particle parameters (general)

float age = 16.0;                    // particle lifetime
float rate = 0.5;                    // particle burst rate
integer count = 3;                   // particle count
vector startColor = <0.5, 0.5, 0.5>; // particle start color
vector endColor = <0.5, 0.5, 0.5>;   // particle end color
float startAlpha = 1.0;              // particle start alpha
float endAlpha = 0.0;                // particle end alpha

// Particle parameters (resizing)

vector startScale = <0.1, 0.1, 0>;   // particle start size (100%)
vector endScale = <4, 4, 0>;         // particle end size (100%)
float minSpeed = 0.0;                // particle min. burst speed (100%)
float maxSpeed = 0.1;                // particle max. burst speed (100%)
float burstRadius = 0.1;             // particle burst radius (100%)
vector partAccel = <0, 0, 0.2>;      // particle accelleration (100%)

// Functions

updateSize(float size)
{
    vector start = startScale / 100.0 * size;   // start scale
    vector end = endScale / 100.0 * size;       // end scale
    float min = minSpeed / 100.0 * size;        // min. burst speed
    float max = maxSpeed / 100.0 * size;        // max. burst speed
    float radius = burstRadius / 100.0 * size;  // burst radius
    vector push = partAccel / 100.0 * size;     // accelleration

    updateParticles(start, end, min, max, radius, push);
}

string getGroup()
{
    string str = llStringTrim(llGetObjectDesc(), STRING_TRIM);
    if (llToLower(str) == "(no description)" || str == "") str = "Default";
    return str;
}

float percentage (float per, float num)
{
    return num / 100.0 * per;
}

updateParticles(vector start, vector end, float min, float max, float radius, vector push)
{
    llParticleSystem([
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
        PSYS_SRC_TEXTURE, texture,
        PSYS_PART_START_COLOR, startColor,
        PSYS_PART_END_COLOR, endColor,
        PSYS_PART_START_ALPHA, startAlpha,
        PSYS_PART_END_ALPHA, endAlpha,
        PSYS_PART_START_SCALE, start,
        PSYS_PART_END_SCALE, end,
        PSYS_PART_MAX_AGE, age,
        PSYS_SRC_BURST_RATE, rate,
        PSYS_SRC_BURST_PART_COUNT, count,
        PSYS_SRC_BURST_SPEED_MIN, min,
        PSYS_SRC_BURST_SPEED_MAX, max,
        PSYS_SRC_BURST_RADIUS, radius,
        PSYS_SRC_ACCEL, push,
        PSYS_PART_FLAGS,
        0 |
        PSYS_PART_EMISSIVE_MASK |
        PSYS_PART_FOLLOW_VELOCITY_MASK |
        PSYS_PART_INTERP_COLOR_MASK |
        PSYS_PART_INTERP_SCALE_MASK ]);
}

default
{
    state_entry()
    {
        llParticleSystem([]);
        if (!silent) llWhisper(0, title + " " + version + " ready");
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }

    link_message(integer sender_number, integer number, string msg, key id)
    {
        if (number != smokeChannel) return;

        integer size = (integer)msg;
        string group = (string)id;

        if (group == getGroup() || group == "Default" || getGroup() == "Default") {
            if (size) updateSize((float)size);
            else llParticleSystem([]);
        }
    }
}
