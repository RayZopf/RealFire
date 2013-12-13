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
//Additions: register with Fire.lsl
//11. Dec. 2013
//v2.2-0.4

//Files:
//Smoke.lsl
//
//Fire.lsl
//config
//User Manual
//
//
//Prequisites: Smoke.lsl in another prim than Fire.lsl
//Notecard format: see config NC
//basic help: User Manual

//Changelog
//Formatting
//moved functions into main code

//bug: if smoke is turned off via menu, llSleep still applies

//todo: more natural smoke according to fire intensity - low fire with more fume, black smoke, smoke after fire is off, smoke fading instead of turning off
//todo: registering with Fire.lsl
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
integer g_iSmoke = TRUE;			// Smoke on/off in this prim

// Particle parameters
float g_fAge = 10.0;               // life of each particle
float g_fRate = 0.5;               // how fast (rate) to emit particles
integer g_iCount = 5;              // how many particles to emit per BURST
float g_fStartAlpha = 0.4;         // start alpha (transparency) value


//internal variables
//-----------------------------------------------
string g_sTitle = "RealSmoke";     // title
string g_sVersion = "2.2-0.4";       // version

// Constants
integer SMOKE_CHANNEL = -10957;  // smoke channel



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
		llSleep(1);
		//do some linked message to register with Fire.lsl
		llMessageLinked(LINK_ALL_OTHERS, SMOKE_CHANNEL, (string)g_iSmoke, "");
        Debug("state_entry, Particle count = " + (string)llRound((float)g_iCount * g_fAge / g_fRate));
        llWhisper(0, g_sTitle + " " + g_sVersion + " ready");
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }
	
	changed(integer change)
    {
		if (change & CHANGED_INVENTORY) {
			llMessageLinked(LINK_ALL_OTHERS, SMOKE_CHANNEL, (string)g_iSmoke, "");
			llWhisper(0, g_sTitle + " " + g_sVersion + " ready");
		}
    }
	
//listen for linked messages from Fire (main) script
//-----------------------------------------------
    link_message(integer iSender, integer iNumber, string sMsg, key kId)
    {
		Debug("link_message = channel " + (string)iNumber + "; sMsg " + sMsg + "; kId " + (string)kId);
        if (iNumber != SMOKE_CHANNEL) return;
		
        if ((integer)sMsg > 0 && (integer)sMsg <= 100) {
			float fAlpha = g_fStartAlpha / 100.0 * (float)sMsg;
			Debug("fAlpha " + (string)fAlpha);
			llParticleSystem([
				PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
				PSYS_PART_START_COLOR, <0.5, 0.5, 0.5>,
				PSYS_PART_END_COLOR, <0.5, 0.5, 0.5>,
				PSYS_PART_START_ALPHA, fAlpha,
				PSYS_PART_END_ALPHA, 0.0,
				PSYS_PART_START_SCALE, <0.1, 0.1, 0.0>,
				PSYS_PART_END_SCALE, <3.0, 3.0, 0.0>,
				PSYS_PART_MAX_AGE, g_fAge,
				PSYS_SRC_BURST_RATE, g_fRate,
				PSYS_SRC_BURST_PART_COUNT, g_iCount,
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
			} else {
				llWhisper(0, "Fumes are fading");
				llSleep(9);
				llParticleSystem([]);
				Debug("smoke particles off");
				}
    }
}