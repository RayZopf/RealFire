///////////////////////////////////////////////////////////////////////////////////////////////////
//Remote control (secondary switch) for RealFire
//
// Author: Rene10957 Resident
// Date: 31-05-2013
//
// This work is licensed under the Creative Commons Attribution 3.0 Unported (CC BY 3.0) License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/.
//
// Author and license headers must be left intact.
// Content creator? Please read the license notecard!
//
// Drop this in an external prim you want to use as an extra on/off/menu switch
// Note: only useful if you need an external switch for a single fire
//
// A switch can be bound to a fire by entering the same word in the description of both prims
// Alternatively, you can use the network switch to control up to 9 fires
//
//
//modified by: Zopf Resident - Ray Zopf (Raz)
//Additions: initial structure for multiple sound files, implement linked_message system, background sound, LSLForge Modules
//03. Feb. 2014
//v1.0-0.1
//

//Files:
// Fire.lsl
// Remote_receiver.lsl
//
// Smoke.lsl
// Sound.lsl
// config
// User Manual
//
//
//Prequisites:
// Remote_receiver.lsl in same prim as Fire.lsl
//
//Notecard format: see config NC
//basic help: User Manual and in header
//
//Changelog
// Formatting
// LSLFore modules

//FIXME: ----

//TODO: ----
//
///////////////////////////////////////////////////////////////////////////////////////////////////


//===============================================
//GLOBAL VARIABLES
//===============================================

//debug variables
//-----------------------------------------------
integer g_iDebugMode=FALSE; // set to TRUE to enable Debug messages
integer g_iVerbose = FALSE;


//user changeable variables
//-----------------------------------------------
string LINKSETID = "RealFire"; // to be compared to first word in prim description - only listen to link-messages from prims that have this id;


//internal variables
//-----------------------------------------------
string g_sTitle = "RealFire Remote Control";            // title
string g_sVersion = "1.0-0.1";        // version
string g_sScriptName;
string g_sType = "remote";
integer g_iType = LINK_SET;
string g_sAuthors = "Rene10957, Zopf";

// Constants
string SEPARATOR = ";;";           // separator for region messages


//===============================================
//LSLForge MODULES
//===============================================
$import RealFireMessageMap.lslm();
$import Debug.lslm(m_iDebugMode=g_iDebugMode, m_sScriptName=g_sScriptName);
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
		if (g_iVerbose) llWhisper(0, g_sTitle + " " + g_sVersion+" by "+g_sAuthors + " ready");
	}

	on_rez(integer start_param)
	{
		llResetScript();
	}

	touch_start(integer total_number)
	{
		llResetTime();
	}

	touch_end(integer total_number)
	{
		key kUser = llDetectedKey(0);
		string command;

		if (llGetTime() > 1.0) command = "menu";
			else command = "switch";

		list msgList = [getGroup(LINKSETID), command, kUser];
		string msgData = llDumpList2String(msgList, SEPARATOR);
		llRegionSay(REMOTE_CHANNEL, msgData);
	}

//-----------------------------------------------
//END STATE: default
//-----------------------------------------------
}