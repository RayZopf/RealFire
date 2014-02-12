// LSL script generated: RealFire-Rene10957.LSL.Controls.Remote_receiver.lslp Wed Feb 12 05:08:21 Mitteleuropäische Zeit 2014
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
integer g_iRemote;
string LINKSETID = "RealFire";


//internal variables
//-----------------------------------------------
string g_sTitle = "RealFire Remote Receiver";
string g_sVersion = "1.2-0.46";
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
integer COMMAND_CHANNEL = -15700;
integer REMOTE_CHANNEL = -975102;



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default {

	state_entry() {
        (g_iRemote = 1);
        integer rc = -1;
        (rc = llSetMemoryLimit(21000));
        if ((g_iVerbose && (1 > rc))) llWhisper(0,(((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - Setting memory limit failed"));
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
        if (((!silent) && g_iVerbose)) llWhisper(0,((((((((("\n\t- used/max available memory: " + ((string)llGetUsedMemory())) + "/") + ((string)llGetMemoryLimit())) + " - free: ") + ((string)llGetFreeMemory())) + "-\n(v) ") + g_sTitle) + "/") + g_sScriptName));
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
        string _str2 = llStringTrim(llGetObjectDesc(),3);
        if (((llToLower(_str2) == "(no description)") || (_str2 == ""))) (_str2 = sDefGroup);
        else  {
            list lGroup = llParseString2List(_str2,[" "],[]);
            (_str2 = llList2String(lGroup,0));
        }
        string str = _str2;
        if ((((str != group) && (LINKSETID != group)) && (LINKSETID != str))) return;
        string command = llList2String(msgList,1);
        key user = ((key)llList2String(msgList,2));
        llMessageLinked(-4,g_iMsgNumber,command,user);
    }


//listen for linked messages from Fire (main) script
//-----------------------------------------------
	link_message(integer iSender,integer iChan,string sSet,key kId) {
        
        string _ret0;
        if ((iChan == COMMAND_CHANNEL)) {
            list lValues = llParseString2List(sSet,[SEPARATOR],[]);
            string sCommand = llList2String(lValues,0);
            if (("register" == sCommand)) {
                integer link = -1;
                if (g_iRemote) {
                    if ((BOOL && (-1 == llGetInventoryType(g_sMainScript)))) {
                        (BOOL = 0);
                        jump _end0;
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
                @_end0;
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
                if (((!silent) && g_iVerbose)) llWhisper(0,((((((((("\n\t- used/max available memory: " + ((string)llGetUsedMemory())) + "/") + ((string)llGetMemoryLimit())) + " - free: ") + ((string)llGetFreeMemory())) + "-\n(v) ") + g_sTitle) + "/") + g_sScriptName));
            }
            else  if (("nonverbose" == sCommand)) (g_iVerbose = 0);
            else  if ((1 && ("config" == sCommand))) {
                (_ret0 = sSet);
                jump _end1;
            }
            else  if (g_iRemote) llSetTimerEvent(0.1);
            (_ret0 = "");
            jump _end1;
        }
        (_ret0 = "");
        @_end1;
        string sConfig = _ret0;
        if (("" != sConfig)) {
            integer _ret2;
            list lConfigs = llParseString2List(sConfig,["config","=",SEPARATOR],[]);
            integer n = llGetListLength(lConfigs);
            integer count = 0;
            string par;
            
            if (((n > 1) && (0 == (n % 2)))) {
                string val;
                do  {
                    {
                        (par = llList2String(lConfigs,count));
                        (val = llList2String(lConfigs,(count + 1)));
                        if ((par == "msgnumber")) {
                            (g_iMsgNumber = ((integer)val));
                            (_ret2 = 1);
                            jump _end3;
                        }
                        (count = (count + 2));
                    }
                }
                while ((count <= n));
            }
            else  {
                (_ret2 = 0);
                jump _end3;
            }
            (_ret2 = 0);
            @_end3;
            if (_ret2) {
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
                if (((!silent) && g_iVerbose)) llWhisper(0,((((((((("\n\t- used/max available memory: " + ((string)llGetUsedMemory())) + "/") + ((string)llGetMemoryLimit())) + " - free: ") + ((string)llGetFreeMemory())) + "-\n(v) ") + g_sTitle) + "/") + g_sScriptName));
                if ((-1 == llGetInventoryType(g_sMainScript))) llWhisper(0,(((g_sTitle + " is not in same prim as ") + g_sMainScript) + "! Remote control will not work!"));
                if (g_iVerbose) llWhisper(0,(((((("(v) " + g_sTitle) + " uses channel: ") + ((string)g_iMsgNumber)) + " and listens on ") + ((string)REMOTE_CHANNEL)) + " for remote controler"));
            }
        }
    }
}
