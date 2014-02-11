///////////////////////////////////////////////////////////////////////////////////////////////////
//Remote receiver for RealFire
//
// Author: Rene10957 Resident
// Date: 02-02-2014
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
//11. Feb. 2014
//v1.2-0.46
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

//user changeable variables
//-----------------------------------------------
integer g_iRemote;         // Remote on/off
string LINKSETID = "RealFire"; // to be compared to first word in prim description - only listen to link-messages from prims that have this id;


//internal variables
//-----------------------------------------------
string g_sTitle = "RealFire Remote Receiver";            // title
string g_sVersion = "1.2-0.46";        // version
string g_sAuthors = "Rene10957, Zopf";

string g_sType = "remote";
integer g_iType = LINK_SET;

integer g_iListenHandle = 0;

// Constants
integer BOOL = TRUE;


//===============================================
//LSLForge MODULES
//===============================================
$import Debug2.lslm(m_sScriptName=g_sScriptName);
$import MemoryManagement.lslm(m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_iVerbose=g_iVerbose);
$import RealFireMessageMap.lslm();
$import PrintStatusInfo.lslm(m_iAvail=BOOL, m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_iEnabled=g_iRemote, m_sVersion=g_sVersion, m_sAuthors=g_sAuthors);
$import ExtensionBasics.lslm(m_sGroup=LINKSETID, m_iSingle=BOOL, m_iEnabled=g_iRemote, m_iAvail=BOOL, m_iChannel=REMOTE_CHANNEL, m_sScriptName=g_sScriptName, m_iLinkType=g_iType, m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_sVersion=g_sVersion, m_sAuthors=g_sAuthors);
$import GroupHandling.lslm(m_sGroup=LINKSETID);


//===============================================
//PREDEFINED FUNCTIONS
//===============================================


// pragma inline
initExtension()
{
	llListenRemove(g_iListenHandle);
	g_iListenHandle = llListen(REMOTE_CHANNEL, "", "", "");
	InfoLines(FALSE);
	if (INVENTORY_NONE == llGetInventoryType(g_sMainScript)) llWhisper(PUBLIC_CHANNEL, g_sTitle + " is not in same prim as " + g_sMainScript+"! Remote control will not work!");
	if (g_iVerbose) llWhisper(PUBLIC_CHANNEL, "(v) "+g_sTitle + " uses channel: " + (string)g_iMsgNumber+" and listens on "+(string)REMOTE_CHANNEL +" for remote controler");
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
		//debug=TRUE; // set to TRUE to enable Debug messages
		MESSAGE_MAP();
		g_iRemote = TRUE;

		MemRestrict(19000);
		//g_kOwner = llGetOwner();
		g_sScriptName = llGetScriptName();
		initExtension();
	}

	on_rez(integer start_param)
	{
		llResetScript();
	}

	listen(integer channel, string name, key kId, string msg)
	{
		if (debug) Debug("listen: "+msg, FALSE, FALSE);
		// Security - check the object belongs to our owner, not using llListen - filter, as we have state_entry and on_rez events
		//if (llGetOwnerKey(kId) != g_kOwner) return; // disabled as remote only workswithin range of llSay and we want to give away remotes (objects)

		//if (channel != REMOTE_CHANNEL) return; not needed, as we listen only on REMOTE_CHANNEL
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
	link_message(integer iSender, integer iChan, string sSet, key kId)
	{
		if (debug) Debug("link_message = channel " + (string)iChan + "; sSoundSet " + sSet + "; kId " + (string)kId, FALSE, FALSE);
		string sConfig = MasterCommand(iChan, sSet, TRUE);
		if ("" != sConfig) {
			if (getConfigRemote(sConfig)) {
				initExtension();
			}
		}
	}

//-----------------------------------------------
//END STATE: default
//-----------------------------------------------
}
