// LSL script generated: RealFire-Rene10957.LSL.Smoke.lslp Tue Feb 11 22:58:57 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//Realfire by Rene - Smoke
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
// See fire.lsl for feature list
//
//
//modified by: Zopf Resident - Ray Zopf (Raz)
//Additions: register with Fire.lsl, LSLForge Modules
//11. Feb. 2014
//v2.1.3-0.6
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

//user changeable variables
//-----------------------------------------------
integer g_iSmoke;

string LINKSETID = "RealFire";

// Particle parameters
float g_fAge;
float g_fRate;
integer g_iCount;
float g_fStartAlpha;


//internal variables
//-----------------------------------------------
string g_sTitle = "RealSmoke";
string g_sVersion = "2.1.3-0.6";
string g_sAuthors = "Rene10957, Zopf";

string g_sSize = "0";
integer g_iVerbose = 1;
string g_sMainScript = "Fire.lsl";
string g_sScriptName;
integer silent = 0;
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


float percentage(float per,float num){
    return ((num / 100.0) * per);
}



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default {

	state_entry() {
        MESSAGE_MAP();
        (g_iSmoke = 1);
        (g_fAge = 10.0);
        (g_fRate = 0.5);
        (g_iCount = 5);
        (g_fStartAlpha = 0.4);
        integer rc = -1;
        (rc = llSetMemoryLimit(21000));
        if ((g_iVerbose && (1 > rc))) llWhisper(0,(((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - Setting memory limit failed"));
        (g_sScriptName = llGetScriptName());
        
        
        if (g_iSmoke) llParticleSystem([]);
        llSleep(1);
        integer link = -2;
        if (g_iSmoke) {
            if ((0 && (-1 == llGetInventoryType(g_sMainScript)))) {
                (g_iSmoke = 0);
                jump __end02;
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
            if (g_iSmoke) llMessageLinked(link,PARTICLE_CHANNEL,"1",((key)sId));
        }
        @__end02;
        if ((g_iVerbose && 0)) {
            if (g_iSmoke) {
                if ((!silent)) llWhisper(0,(("(v) " + g_sTitle) + " - File(s) found in inventory: Yes"));
            }
            else  llWhisper(0,(((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
        }
        if (g_iSmoke) {
            if (g_iSmoke) {
                if ((!silent)) llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + "\t ready"));
            }
            else  llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " not ready"));
        }
        else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " script disabled"));
        if (((!silent) && g_iVerbose)) llWhisper(0,((((((((("\n\t- used/max available memory: " + ((string)llGetUsedMemory())) + "/") + ((string)llGetMemoryLimit())) + " - free: ") + ((string)llGetFreeMemory())) + "-\n(v) ") + g_sTitle) + "/") + g_sScriptName));
    }


	on_rez(integer start_param) {
        llResetScript();
    }

/* not needed, as there currently are no dependencies on files or config
	changed(integer change)
	{
		if (change & CHANGED_INVENTORY) {
		initExtension();
		}
	}
*/

//listen for linked messages from Fire (main) script
//-----------------------------------------------
	link_message(integer iSender,integer iChan,string sSet,key kId) {
        
        if ((iChan == COMMAND_CHANNEL)) {
            list lValues = llParseString2List(sSet,[SEPARATOR],[]);
            string sCommand = llList2String(lValues,0);
            if (("register" == sCommand)) {
                integer link = -2;
                if (g_iSmoke) {
                    if ((0 && (-1 == llGetInventoryType(g_sMainScript)))) {
                        (g_iSmoke = 0);
                        jump __end01;
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
                    if (g_iSmoke) llMessageLinked(link,PARTICLE_CHANNEL,"1",((key)sId));
                }
                @__end01;
            }
            else  if (("verbose" == sCommand)) {
                (g_iVerbose = 1);
                if ((g_iVerbose && 0)) {
                    if (g_iSmoke) {
                        if ((!silent)) llWhisper(0,(("(v) " + g_sTitle) + " - File(s) found in inventory: Yes"));
                    }
                    else  llWhisper(0,(((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
                }
                if (g_iSmoke) {
                    if (g_iSmoke) {
                        if ((!silent)) llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + "\t ready"));
                    }
                    else  llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " not ready"));
                }
                else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " script disabled"));
                if (((!silent) && g_iVerbose)) llWhisper(0,((((((((("\n\t- used/max available memory: " + ((string)llGetUsedMemory())) + "/") + ((string)llGetMemoryLimit())) + " - free: ") + ((string)llGetFreeMemory())) + "-\n(v) ") + g_sTitle) + "/") + g_sScriptName));
            }
            else  if (("nonverbose" == sCommand)) (g_iVerbose = 0);
            else  if ((0 && ("config" == sCommand))) {
                
                jump _end0;
            }
            else  if (g_iSmoke) llSetTimerEvent(0.1);
            "";
            jump _end0;
        }
        "";
        @_end0;
        if (((iChan != PARTICLE_CHANNEL) || (!g_iSmoke))) return;
        string _ret2;
        string _sDefGroup4 = LINKSETID;
        if (("" == _sDefGroup4)) (_sDefGroup4 = "Default");
        string _str2 = llStringTrim(llGetObjectDesc(),3);
        if (((llToLower(_str2) == "(no description)") || (_str2 == ""))) (_str2 = _sDefGroup4);
        else  {
            list _lGroup7 = llParseString2List(_str2,[" "],[]);
            (_str2 = llList2String(_lGroup7,0));
        }
        string _str5 = _str2;
        list lKeys = llParseString2List(((string)kId),[SEPARATOR],[]);
        string sGroup = llList2String(lKeys,0);
        string _sScriptName6 = llList2String(lKeys,1);
        if ((((_str5 == sGroup) || (LINKSETID == sGroup)) || (LINKSETID == _str5))) {
            (_ret2 = _sScriptName6);
            jump _end3;
        }
        (_ret2 = "exit");
        @_end3;
        string sScriptName = _ret2;
        string _ret8;
        string _sDefGroup10 = LINKSETID;
        if (("" == _sDefGroup10)) (_sDefGroup10 = "Default");
        string __str211 = llStringTrim(llGetObjectDesc(),3);
        if (((llToLower(__str211) == "(no description)") || (__str211 == ""))) (__str211 = _sDefGroup10);
        else  {
            list _lGroup16 = llParseString2List(__str211,[" "],[]);
            (__str211 = llList2String(_lGroup16,0));
        }
        string _str12 = __str211;
        list _lKeys13 = llParseString2List(((string)kId),[SEPARATOR],[]);
        string _sGroup14 = llList2String(_lKeys13,0);
        string _sScriptName15 = llList2String(_lKeys13,1);
        if ((((_str12 == _sGroup14) || (LINKSETID == _sGroup14)) || (LINKSETID == _str12))) {
            (_ret8 = _sScriptName15);
            jump _end9;
        }
        (_ret8 = "exit");
        @_end9;
        if (("exit" == _ret8)) return;
        list lParams = llParseString2List(sSet,[SEPARATOR],[]);
        string sVal = llList2String(lParams,0);
        string sMsg = llList2String(lParams,1);
        if (((sVal == g_sSize) && ("0" != sVal))) {
            llSetTimerEvent(0.0);
            return;
        }
        if ((((((integer)sVal) > 0) && (((integer)sVal) <= 100)) && ("smoke" == sMsg))) {
            llSetTimerEvent(0.0);
            float fAlpha = percentage(((float)sVal),g_fStartAlpha);
            
            llParticleSystem([0,3,9,2,16,0.1,1,<0.5,0.5,0.5>,3,<0.5,0.5,0.5>,2,fAlpha,4,0.0,5,<0.1,0.1,0.0>,6,<3.0,3.0,0.0>,7,g_fAge,13,g_fRate,15,g_iCount,8,<0.0,0.0,0.2>,17,0.0,18,0.1]);
            if ((((!silent) && g_iVerbose) && ("0" != g_sSize))) llWhisper(0,"(v) Smoke changes it's appearance");
            (g_sSize = sVal);
        }
        else  if ((("smoke" == sMsg) || ("" == sMsg))) {
            if ((!silent)) llWhisper(0,"Fumes are fading");
            llSetTimerEvent(11.0);
        }
    }



	timer() {
        llParticleSystem([]);
        if (((!silent) && g_iVerbose)) llWhisper(0,"(v) Smoke vanished");
        
        (g_sSize = "0");
        llSetTimerEvent(0.0);
    }
}
