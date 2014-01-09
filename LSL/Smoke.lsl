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
//09. Jan. 2014
//v2.2-0.45

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
//todo: en-/disable //PSYS_PART_WIND_MASK, if fire is out-/inside
//todo: better use cone instead of explode (radius) + cone (placement)
//todo: smoke reflecting fire light
//todo: check if other sound scripts are in same prim
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
integer g_iDebugMode=FALSE; // set to TRUE to enable Debug messages


//user changeable variables
//-----------------------------------------------
integer g_iSmoke = TRUE;			// Smoke on/off in this prim
integer g_iVerbose = TRUE;

// Particle parameters
float g_fAge = 10.0;               // life of each particle
float g_fRate = 0.5;               // how fast (rate) to emit particles
integer g_iCount = 5;              // how many particles to emit per BURST
float g_fStartAlpha = 0.4;         // start alpha (transparency) value


//internal variables
//-----------------------------------------------
string g_sTitle = "RealSmoke";     // title
string g_sVersion = "2.2-0.45";       // version
string g_sScriptName;

string g_sSize = "0";

//RealFire MESSAGE MAP
integer COMMAND_CHANNEL = -10950;
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
    llOwnerSay("DEBUG: "+ g_sScriptName + "; " + sMsg);
}

RegisterExtension()
{
	llMessageLinked(LINK_ALL_OTHERS, SMOKE_CHANNEL, (string)g_iSmoke, (key)g_sScriptName);
}

InfoLines()
{
    if (g_iSmoke) llWhisper(0, g_sTitle + " " + g_sVersion + " ready");
		else if (g_iVerbose) llWhisper(0, g_sTitle + " " + g_sVersion + " (" + g_sScriptName + ") disabled");
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
		g_sScriptName = llGetScriptName();
        Debug("state_entry, Particle count = " + (string)llRound((float)g_iCount * g_fAge / g_fRate));
        llParticleSystem([]);
		llSleep(1);
		//do some linked message to register with Fire.lsl
		RegisterExtension();
		InfoLines();
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }
	
	changed(integer change)
    {
		if (change & CHANGED_INVENTORY) {
			RegisterExtension();
			InfoLines();
		}
    }
	
//listen for linked messages from Fire (main) script
//-----------------------------------------------
    link_message(integer iSender, integer iChan, string sMsg, key kId)
    {
		Debug("link_message = channel " + (string)iChan + "; sMsg " + sMsg + "; kId " + (string)kId+" ...g_sSize "+g_sSize);
		if (iChan == COMMAND_CHANNEL) RegisterExtension();
		
        if (iChan != SMOKE_CHANNEL || !g_iSmoke || sMsg == g_sSize) return;

        if ((float)sMsg > 0 && (float)sMsg <= 100) {
			float fAlpha = g_fStartAlpha / 100.0 * (float)sMsg;
			Debug("fAlpha " + (string)fAlpha);
		    llParticleSystem ([
			//System Behavior
				PSYS_PART_FLAGS,
	  			  0 |
					//PSYS_PART_BOUNCE_MASK |
					//PSYS_PART_EMISSIVE_MASK |
					//PSYS_PART_FOLLOW_SRC_MASK |
					//PSYS_PART_FOLLOW_VELOCITY_MASK |
				  PSYS_PART_INTERP_COLOR_MASK |
				  PSYS_PART_INTERP_SCALE_MASK, // |
					//PSYS_PART_RIBBON_MASK |
					//PSYS_PART_TARGET_LINEAR_MASK |
					//PSYS_PART_TARGET_POS_MASK |
					////PSYS_PART_WIND_MASK,
			//System Presentation
				PSYS_SRC_PATTERN, 
				  PSYS_SRC_PATTERN_EXPLODE, //|
					//PSYS_SRC_PATTERN_ANGLE_CONE |
					//PSYS_SRC_PATTERN_ANGLE |
					////PSYS_SRC_PATTERN_DROP,
				  PSYS_SRC_BURST_RADIUS, 0.1,
					//PSYS_SRC_ANGLE_BEGIN, float,
					//PSYS_SRC_ANGLE_END, float,
					//PSYS_SRC_TARGET_KEY, key,
			//Particle Appearance
				PSYS_PART_START_COLOR, <0.5, 0.5, 0.5>,
				PSYS_PART_END_COLOR, <0.5, 0.5, 0.5>,
				PSYS_PART_START_ALPHA, fAlpha,
				PSYS_PART_END_ALPHA, 0.0,
				PSYS_PART_START_SCALE, <0.1, 0.1, 0.0>,
				PSYS_PART_END_SCALE, <3.0, 3.0, 0.0>,
					//PSYS_SRC_TEXTURE, string,
					//PSYS_PART_START_GLOW, float,
					//PSYS_PART_END_GLOW, float,
			//Particle Blending
			//Particle Flow
					//PSYS_SRC_MAX_AGE, float,
				PSYS_PART_MAX_AGE, g_fAge,
				PSYS_SRC_BURST_RATE, g_fRate,
				PSYS_SRC_BURST_PART_COUNT, g_iCount,
			//Particle Motion
				PSYS_SRC_ACCEL, <0.0, 0.0, 0.2>,
					//PSYS_SRC_OMEGA, vector,
				PSYS_SRC_BURST_SPEED_MIN, 0.0,
				PSYS_SRC_BURST_SPEED_MAX, 0.1
			]);
				if (g_iVerbose && "0"!= g_sSize) llWhisper(0, "Smoke changes it's appearance");
		} else {
			llWhisper(0, "Fumes are fading");
			llSleep(15);
			llParticleSystem([]);
			if (g_iVerbose) llWhisper(0, "Smoke vanished");
			Debug("smoke particles off");
		}
		g_sSize = sMsg;
    }
}