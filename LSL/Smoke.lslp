///////////////////////////////////////////////////////////////////////////////////////////////////
//Realfire by Rene - Smoke
//
// Author: Rene10957 Resident
// Date: 12-01-2014
//
// This work is licensed under the Creative Commons Attribution 3.0 Unported (CC BY 3.0) License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/.
//
// Author and license headers must be left intact.
// Content creator? Please read the license notecard!
//
// See fire.lsl for feature list
//
//
//modified by: Zopf Resident - Ray Zopf (Raz)
//Additions: register with Fire.lsl, LSLForge Modules
//04. Feb. 2014
//v2.2.1-0.57
//

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
//
//Changelog
// Formatting
// moved functions into main code

//FIXME: if smoke is turned off via menu, llSleep still applies

//TODO: more natural smoke according to fire intensity - low fire with more fume, black smoke, smoke after fire is off, smoke fading instead of turning off
//TODO: en-/disable //PSYS_PART_WIND_MASK, if fire is out-/inside
//TODO: better use cone instead of explode (radius) + cone (placement)
//TODO: smoke reflecting fire light
//TODO: check if other sound scripts are in same prim
//TODO: more/different smoke (e.g. full perm prim fire)
///////////////////////////////////////////////////////////////////////////////////////////////////


//===============================================
//GLOBAL VARIABLES
//===============================================

//debug variables
//-----------------------------------------------
integer g_iDebugMode=FALSE; // set to TRUE to enable Debug messages


//user changeable variables
//-----------------------------------------------
integer g_iSmoke = TRUE;      // Smoke on/off in this prim
integer g_iVerbose = TRUE;

string LINKSETID = "RealFire"; // to be compared to first word in prim description - only listen to link-messages from prims that have this id;

// Particle parameters
float g_fAge = 10.0;               // life of each particle
float g_fRate = 0.5;               // how fast (rate) to emit particles
integer g_iCount = 5;              // how many particles to emit per BURST
float g_fStartAlpha = 0.4;         // start alpha (transparency) value


//internal variables
//-----------------------------------------------
string g_sTitle = "RealSmoke";     // title
string g_sVersion = "2.2.1-0.57";       // version
string g_sAuthors = "Rene10957, Zopf";

string g_sType = "smoke";
integer g_iType = LINK_ALL_OTHERS;

string g_sSize = "0";

//RealFire MESSAGE MAP
//integer COMMAND_CHANNEL =
//integer SMOKE_CHANNEL =  smoke channel


//===============================================
//LSLForge MODULES
//===============================================
$import RealFireMessageMap.lslm();
$import Debug.lslm(m_iDebugMode=g_iDebugMode, m_sScriptName=g_sScriptName);
$import PrintStatusInfo.lslm(m_iVerbose=g_iVerbose, m_iAvail=g_iSmoke, m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_iOn=g_iSmoke, m_sVersion=g_sVersion, m_sAuthors=g_sAuthors);
$import ExtensionBasics.lslm(m_iDebug=g_iDebugMode, m_sGroup=LINKSETID, m_iEnabled=g_iSmoke, m_iAvail=g_iSmoke, m_iChannel=PARTICLE_CHANNEL, m_sScriptName=g_sScriptName, m_iLinkType=g_iType, m_iVerbose=g_iVerbose, m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_sVersion=g_sVersion, m_sAuthors=g_sAuthors);
$import GroupHandling.lslm(m_sGroup=LINKSETID);


//===============================================
//PREDEFINED FUNCTIONS
//===============================================



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
		if (g_iSmoke) llParticleSystem([]);
		llSleep(1);
		//do some linked message to register with Fire.lsl
		RegisterExtension(g_iType);
		InfoLines(FALSE);
	}

	on_rez(integer start_param)
	{
		llResetScript();
	}

	changed(integer change)
	{
		if (change & CHANGED_INVENTORY) {
			if (g_iSmoke) llParticleSystem([]);
			llSleep(1);
			RegisterExtension(g_iType);
			InfoLines(FALSE);
		}
	}

//listen for linked messages from Fire (main) script
//-----------------------------------------------
	link_message(integer iSender, integer iChan, string sSet, key kId)
	{
		Debug("link_message = channel " + (string)iChan + "; sSet " + sSet + "; kId " + (string)kId+" ...g_sSize "+g_sSize);
		MasterCommand(iChan, sSet, FALSE);

		if (iChan != PARTICLE_CHANNEL || !g_iSmoke) return;
		string sScriptName = GroupCheck(kId);
		if ("exit" ==  GroupCheck(kId)) return;

		list lParams = llParseString2List(sSet, [SEPARATOR], []);
		string sVal = llList2String(lParams, 0);
		string sMsg = llList2String(lParams, 1);

		if (sVal == g_sSize && "0" != sVal) {
			llSetTimerEvent(0.0);
			return;
		}

		if ((integer)sVal > 0 && (integer)sVal <= 100 && "smoke" == sMsg) {
			llSetTimerEvent(0.0);
			float fAlpha = g_fStartAlpha / 100.0 * (float)sVal;
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
			if (g_iVerbose && "0"!= g_sSize) llWhisper(0, "(v) Smoke changes it's appearance");
			g_sSize = sVal;
		} else if ("smoke" == sMsg || "" == sMsg) {
			llWhisper(0, "Fumes are fading");
			llSetTimerEvent(11.0);
		}
	}


	timer()
	{
		llParticleSystem([]);
		if (g_iVerbose) llWhisper(0, "(v) Smoke vanished");
		Debug("smoke particles off");
		g_sSize = "0";
		llSetTimerEvent(0.0);
	}

//-----------------------------------------------
//END STATE: default
//-----------------------------------------------
}