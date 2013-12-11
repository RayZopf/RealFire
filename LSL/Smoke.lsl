///////////////////////////////////////////////////////////////////////////////////////////////////
// Realfire by Rene - Smoke
//
// Author: Rene10957 Resident
// Date: 17-05-2013
//
// This work is licensed under the Creative Commons Attribution 3.0 Unported (CC BY 3.0) License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/.
//
// Author and license headers must be left intact.
// Content creator? Please read the license notecard!
//
// See fire.lsl for feature list


//modified by: Zopf Resident - Ray Zopf (Raz)
//Additions: ---
//11. Dec. 2013 v2.2-0.1

//Files:
//Fire.lsl
//Smoke.lsl
//config
//User Manual
//
//
//Prequisites: Smoke.lsl in another prim as Fire.lsl
//Notecard format: see config NC
//basic help: User Manual

//Changelog
//Formatting

//bug: ---

//todo: ---
///////////////////////////////////////////////////////////////////////////////////////////////////


//===============================================
//FIRESTORM SPECIFIC DEBUG STUFF
//===============================================

//#define FSDEBUG
//#include "fs_debug.lsl"



//===============================================
//GLOBAL VARIABLES
//===============================================

//debug variables
//-----------------------------------------------
integer g_iDebugMode=TRUE; // set to TRUE to enable Debug messages


//user changeable variables
//-----------------------------------------------
// Particle parameters
float age = 10.0;               // life of each particle
float rate = 0.5;               // how fast (rate) to emit particles
integer count = 5;              // how many particles to emit per BURST
float startAlpha = 0.1;         // start alpha (transparency) value


//internal variables
//-----------------------------------------------
string title = "RealSmoke";     // title
string version = "2.1.1";       // version
integer debug = FALSE;          // show/hide debug messages

// Constants
integer smokeChannel = -10957;  // smoke channel



//===============================================
//PREDEFINED FUNCTIONS
//===============================================

//===============================================================================
//= parameters   :    string    sMsg    message string received
//=
//= return        :    none
//=
//= description  :    output debug messages
//=
//===============================================================================

Debug(string sMsg)
{
    if (!g_iDebugMode) return;
    llOwnerSay("DEBUG: "+ llGetScriptName() + ": " + sMsg);
}


float percentage (float per, float num)
{
    return num / 100.0 * per;
}


//most important function
//-----------------------------------------------
updateParticles(float alpha)
{
    llParticleSystem([
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
        PSYS_PART_START_COLOR, <0.5, 0.5, 0.5>,
        PSYS_PART_END_COLOR, <0.5, 0.5, 0.5>,
        PSYS_PART_START_ALPHA, alpha,
        PSYS_PART_END_ALPHA, 0.0,
        PSYS_PART_START_SCALE, <0.1, 0.1, 0.0>,
        PSYS_PART_END_SCALE, <3.0, 3.0, 0.0>,
        PSYS_PART_MAX_AGE, age,
        PSYS_SRC_BURST_RATE, rate,
        PSYS_SRC_BURST_PART_COUNT, count,
        PSYS_SRC_BURST_SPEED_MIN, 0.0,
        PSYS_SRC_BURST_SPEED_MAX, 0.1,
        PSYS_SRC_BURST_RADIUS, 0.1,
        PSYS_SRC_ACCEL, <0.0, 0.0, 0.2>,
        PSYS_PART_FLAGS,
        0 |
        PSYS_PART_EMISSIVE_MASK |
        PSYS_PART_FOLLOW_VELOCITY_MASK |
        PSYS_PART_INTERP_COLOR_MASK |
        PSYS_PART_INTERP_SCALE_MASK ]);
}



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default
{
    state_entry()
    {
        llParticleSystem([]);
        if (debug) llOwnerSay("Particle count: " + (string)llRound((float)count * age / rate));
        llWhisper(0, title + " " + version + " ready");
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }
	
//listen for linked messages from Fire (main) script
//-----------------------------------------------
    link_message(integer sender, integer number, string msg, key id)
    {
        if (debug) llOwnerSay("[Smoke] LINK_MESSAGE event: " + (string)number + "; " + msg + "; " + (string)id);
        if (number != smokeChannel) return;
        if ((integer)msg) updateParticles(percentage((float)msg, startAlpha));
        else llParticleSystem([]);
    }
}