///////////////////////////////////////////////////////////////////////////////////////////////////
//Remote receiver for RealFire
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
// Drop this into the same prim where the FIRE SCRIPT is located
// Note: only useful if you are also using the remote control script
//
//
//modified by: Zopf Resident - Ray Zopf (Raz)
//Additions: initial structure for multiple sound files, implement linked_message system, background sound, LSLForge Modules
//03. Feb. 2014
//v1.1-0.21
//

//Files:
// Fire.lsl
//
// Smoke.lsl
// Sound.lsl
// config
// User Manual
//
//
//Prequisites:
// Remote_receiver.lsl in same prim as Fire.lsl
// Remote_control.lsl to make use of this script
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


//user changeable variables
//-----------------------------------------------
integer g_iVerbose = TRUE;
integer g_iRemote = TRUE;         // Remote on/off
string LINKSETID = "RealFire"; // to be compared to first word in prim description - only listen to link-messages from prims that have this id;


//internal variables
//-----------------------------------------------
string g_sTitle = "RealFire Remote Receiver";            // title
string g_sVersion = "1.1-0.21";        // version
string g_sAuthors = "Rene10957, Zopf";
string g_sScriptName;
string g_sType = "remote";
integer g_iType = LINK_SET;

// Constants
string SEPARATOR = ";;";           // separator for region messages
integer BOOL = TRUE;

//===============================================
//LSLForge MODULES
//===============================================
$import RealFireMessageMap.lslm();
$import Debug.lslm(m_iDebugMode=g_iDebugMode, m_sScriptName=g_sScriptName);
$import PrintStatusInfo.lslm(m_iVerbose=g_iVerbose, m_iAvail=BOOL, m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_iOn=g_iRemote, m_sVersion=g_sVersion, m_sAuthors=g_sAuthors);
$import ExtensionBasics.lslm(m_sGroup=LINKSETID, m_iEnabled=g_iRemote, m_iAvail=BOOL, m_iChannel=FAKE_CHANNEL, m_sScriptName=g_sScriptName, m_iLinkType=g_iType, m_iVerbose=g_iVerbose, m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_sVersion=g_sVersion, m_sAuthors=g_sAuthors);
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
		llListen(REMOTE_CHANNEL, "", "", "");
		InfoLines(FALSE);
	}

	on_rez(integer start_param)
	{
		llResetScript();
	}

	listen(integer channel, string name, key kId, string msg)
	{
		Debug("listen: "+msg);

		if (channel != REMOTE_CHANNEL) return;
		list msgList = llParseString2List(msg, [SEPARATOR], []);
		string group = llList2String(msgList, 0);

		string str = getGroup(LINKSETID);
		if (str != group && LINKSETID != group && LINKSETID != str) return;

		string command = llList2String(msgList, 1);
		key user = (key)llList2String(msgList, 2);

		llMessageLinked(LINK_THIS, g_iMsgNumber, command, user);
	}

//listen for linked messages from Fire (main) script
//-----------------------------------------------
	link_message(integer iSender, integer iChan, string sSoundSet, key kId)
	{
		Debug("link_message = channel " + (string)iChan + "; sSoundSet " + sSoundSet + "; kId " + (string)kId);
		MasterCommand(iChan, sSoundSet);
	}

//-----------------------------------------------
//END STATE: default
//-----------------------------------------------
}
