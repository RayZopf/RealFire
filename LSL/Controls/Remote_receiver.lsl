// LSL script generated: RealFire-Rene10957.LSL.Controls.Remote_receiver.lslp Tue Feb 11 12:25:29 Mitteleuropäische Zeit 2014
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
//v1.2-0.44
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
integer g_iRemote;
string LINKSETID = "RealFire";


//internal variables
//-----------------------------------------------
string g_sTitle = "RealFire Remote Receiver";
string g_sVersion = "1.2-0.44";
string g_sAuthors = "Rene10957, Zopf";

integer g_iListenHandle = 0;

// Constants
integer BOOL = 1;
integer g_iVerbose = 1;
string g_sMainScript = "Fire.lsl";
string g_sScriptName;
integer silent = 0;
integer g_iMsgNumber = 10959;
string SEPARATOR = ";;";
integer COMMAND_CHANNEL;
integer PARTICLE_CHANNEL;
integer SOUND_CHANNEL;
integer ANIM_CHANNEL;
integer PRIMCOMMAND_CHANNEL;
integer REMOTE_CHANNEL;


MESSAGE_MAP(){
    (COMMAND_CHANNEL = 15700);
    (PARTICLE_CHANNEL = -15790);
    (SOUND_CHANNEL = -15780);
    (ANIM_CHANNEL = -15770);
    (PRIMCOMMAND_CHANNEL = -15771);
    (REMOTE_CHANNEL = -975102);
}

/*
getConfigSound(string sConfig)
{
	list lConfigs = llParseString2List(sConfig, ["=",SEPARATOR], []);
	integer n = llGetListLength(lConfigs);
	integer count = 0;
	if (n > 1 && 0 == n%2) do {
		string par = llList2String(lConfigs, count);
		string val = llList2String(lConfigs, count+1);
/ *
		// config for particle fire
		if (par == "topcolor") g_vDefEndColor = checkVector("topColor", (vector)val);
		else if (par == "bottomcolor") g_vDefStartColor = checkVector("bottomColor", (vector)val);
		// config for light
		else if (par == "intensity") g_iDefIntensity = checkInt("intensity", (integer)val, 0, 100);
		else if (par == "radius") g_iDefRadius = checkInt("radius", (integer)val, 0, 100);
		else if (par == "falloff") g_iDefFalloff = checkInt("falloff", (integer)val, 0, 100);
		// color config
		else if ("startcolor" == par) setColor(1, val);
		else if ("endcolor" == par) setColor(0, val);
* /
		count = count +2;
	} while (count <= n);
}


integer getConfigBSound(string sConfig)
{
	list lConfigs = llParseString2List(sConfig, ["=",SEPARATOR], []);
	integer n = llGetListLength(lConfigs);
	integer count = 0;
	if (n > 1 && 0 == n%2) do {
		string par = llList2String(lConfigs, count);
		string val = llList2String(lConfigs, count+1);
/ *
		// config for particle fire
		if (par == "topcolor") g_vDefEndColor = checkVector("topColor", (vector)val);
		else if (par == "bottomcolor") g_vDefStartColor = checkVector("bottomColor", (vector)val);
		// config for light
		else if (par == "intensity") g_iDefIntensity = checkInt("intensity", (integer)val, 0, 100);
		else if (par == "radius") g_iDefRadius = checkInt("radius", (integer)val, 0, 100);
		else if (par == "falloff") g_iDefFalloff = checkInt("falloff", (integer)val, 0, 100);
		// color config
		else if ("startcolor" == par) setColor(1, val);
		else if ("endcolor" == par) setColor(0, val);
* /
		count = count +2;
	} while (count <= n);
	else return 0;
	return 1;
}
*/

integer getConfigRemote(string sVal){
    list lConfigs = llParseString2List(sVal,["config","=",SEPARATOR],[]);
    integer n = llGetListLength(lConfigs);
    integer count = 0;
    string par;
    
    if (((n > 1) && (0 == (n % 2)))) {
        string val;
        do  {
            (par = llList2String(lConfigs,count));
            (val = llList2String(lConfigs,(count + 1)));
            if ((par == "msgnumber")) {
                (g_iMsgNumber = ((integer)val));
                return 1;
            }
            (count = (count + 2));
        }
        while ((count <= n));
    }
    else  return 0;
    return 0;
}



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default {

	state_entry() {
        MESSAGE_MAP();
        (g_iRemote = 1);
        (g_sScriptName = llGetScriptName());
        llListenRemove(g_iListenHandle);
        (g_iListenHandle = llListen(REMOTE_CHANNEL,"","",""));
        if ((g_iVerbose && 0)) {
            if (BOOL) {
                if ((!silent)) llWhisper(0,(("(v) " + g_sTitle) + " - File(s) found in inventory: Yes"));
            }
            else  llWhisper(0,(((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
        }
        if (g_iRemote) {
            if (BOOL) {
                if ((!silent)) llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + "\t ready"));
            }
            else  llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " not ready"));
        }
        else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " script disabled"));
        if (((!silent) && g_iVerbose)) llWhisper(0,((((((("\n\t- currently used/free memory: (u)" + ((string)llGetUsedMemory())) + "/") + ((string)llGetFreeMemory())) + "(f) -\n(v) ") + g_sTitle) + "/") + g_sScriptName));
        if ((-1 == llGetInventoryType(g_sMainScript))) llWhisper(0,(((g_sTitle + " is not in same prim as ") + g_sMainScript) + "! Remote control will not work!"));
        if (g_iVerbose) llWhisper(0,(((((("(v) " + g_sTitle) + " uses channel: ") + ((string)g_iMsgNumber)) + " and listens on ") + ((string)REMOTE_CHANNEL)) + " for remote controler"));
    }


	on_rez(integer start_param) {
        llResetScript();
    }


	listen(integer channel,string name,key kId,string msg) {
        
        list msgList = llParseString2List(msg,[SEPARATOR],[]);
        string group = llList2String(msgList,0);
        string sDefGroup = LINKSETID;
        if (("" == sDefGroup)) (sDefGroup = "Default");
        string _str3 = llStringTrim(llGetObjectDesc(),3);
        if (((llToLower(_str3) == "(no description)") || (_str3 == ""))) (_str3 = sDefGroup);
        else  {
            list lGroup = llParseString2List(_str3,[" "],[]);
            (_str3 = llList2String(lGroup,0));
        }
        string str = _str3;
        if ((((str != group) && (LINKSETID != group)) && (LINKSETID != str))) return;
        string command = llList2String(msgList,1);
        key user = ((key)llList2String(msgList,2));
        llMessageLinked(-4,g_iMsgNumber,command,user);
    }


//listen for linked messages from Fire (main) script
//-----------------------------------------------
	link_message(integer iSender,integer iChan,string sSet,key kId) {
        
        string _ret1;
        if ((iChan == COMMAND_CHANNEL)) {
            list lValues = llParseString2List(sSet,[SEPARATOR],[]);
            string sCommand = llList2String(lValues,0);
            if (("register" == sCommand)) {
                integer link = -1;
                if (g_iRemote) {
                    if ((BOOL && (-1 == llGetInventoryType(g_sMainScript)))) {
                        (BOOL = 0);
                        jump __end03;
                    }
                    string sDefGroup = LINKSETID;
                    if (("" == sDefGroup)) (sDefGroup = "Default");
                    string str = llStringTrim(llGetObjectDesc(),3);
                    if (((llToLower(str) == "(no description)") || (str == ""))) (str = sDefGroup);
                    else  {
                        list lGroup = llParseString2List(str,[" "],[]);
                        (str = llList2String(lGroup,0));
                    }
                    string sId = ((str + SEPARATOR) + g_sScriptName);
                    if (BOOL) llMessageLinked(link,REMOTE_CHANNEL,"1",((key)sId));
                    else  if (BOOL) llMessageLinked(link,REMOTE_CHANNEL,"0",((key)sId));
                }
                @__end03;
            }
            else  if (("verbose" == sCommand)) {
                (g_iVerbose = 1);
                if ((g_iVerbose && 0)) {
                    if (BOOL) {
                        if ((!silent)) llWhisper(0,(("(v) " + g_sTitle) + " - File(s) found in inventory: Yes"));
                    }
                    else  llWhisper(0,(((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
                }
                if (g_iRemote) {
                    if (BOOL) {
                        if ((!silent)) llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + "\t ready"));
                    }
                    else  llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " not ready"));
                }
                else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " script disabled"));
                if (((!silent) && g_iVerbose)) llWhisper(0,((((((("\n\t- currently used/free memory: (u)" + ((string)llGetUsedMemory())) + "/") + ((string)llGetFreeMemory())) + "(f) -\n(v) ") + g_sTitle) + "/") + g_sScriptName));
            }
            else  if (("nonverbose" == sCommand)) (g_iVerbose = 0);
            else  if ((1 && ("config" == sCommand))) {
                (_ret1 = sSet);
                jump _end2;
            }
            else  if (g_iRemote) llSetTimerEvent(0.1);
            (_ret1 = "");
            jump _end2;
        }
        (_ret1 = "");
        @_end2;
        string sConfig = _ret1;
        if (("" != sConfig)) {
            if (getConfigRemote(sConfig)) {
                llListenRemove(g_iListenHandle);
                (g_iListenHandle = llListen(REMOTE_CHANNEL,"","",""));
                if ((g_iVerbose && 0)) {
                    if (BOOL) {
                        if ((!silent)) llWhisper(0,(("(v) " + g_sTitle) + " - File(s) found in inventory: Yes"));
                    }
                    else  llWhisper(0,(((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
                }
                if (g_iRemote) {
                    if (BOOL) {
                        if ((!silent)) llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + "\t ready"));
                    }
                    else  llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " not ready"));
                }
                else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " script disabled"));
                if (((!silent) && g_iVerbose)) llWhisper(0,((((((("\n\t- currently used/free memory: (u)" + ((string)llGetUsedMemory())) + "/") + ((string)llGetFreeMemory())) + "(f) -\n(v) ") + g_sTitle) + "/") + g_sScriptName));
                if ((-1 == llGetInventoryType(g_sMainScript))) llWhisper(0,(((g_sTitle + " is not in same prim as ") + g_sMainScript) + "! Remote control will not work!"));
                if (g_iVerbose) llWhisper(0,(((((("(v) " + g_sTitle) + " uses channel: ") + ((string)g_iMsgNumber)) + " and listens on ") + ((string)REMOTE_CHANNEL)) + " for remote controler"));
            }
        }
    }
}
