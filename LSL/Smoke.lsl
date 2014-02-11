// LSL script generated: RealFire-Rene10957.LSL.Smoke.lslp Tue Feb 11 11:39:03 Mitteleuropäische Zeit 2014
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
//v2.1.3-0.59
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
string g_sVersion = "2.1.3-0.59";
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
        if (((!silent) && g_iVerbose)) llWhisper(0,((((("\n\t- free memory: " + ((string)llGetFreeMemory())) + " -\n(v) ") + g_sTitle) + "/") + g_sScriptName));
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
        string _sMsg1 = ((((((("link_message = channel " + ((string)iChan)) + "; sSet ") + sSet) + "; kId ") + ((string)kId)) + " ...g_sSize ") + g_sSize);
        
        if ((iChan == COMMAND_CHANNEL)) {
            list lValues = llParseString2List(sSet,[SEPARATOR],[]);
            string sCommand = llList2String(lValues,0);
            if (("register" == sCommand)) {
                integer link = -2;
                if (g_iSmoke) {
                    if ((0 && (-1 == llGetInventoryType(g_sMainScript)))) {
                        (g_iSmoke = 0);
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
                    if (g_iSmoke) llMessageLinked(link,PARTICLE_CHANNEL,"1",((key)sId));
                }
                @__end03;
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
                if (((!silent) && g_iVerbose)) llWhisper(0,((((("\n\t- free memory: " + ((string)llGetFreeMemory())) + " -\n(v) ") + g_sTitle) + "/") + g_sScriptName));
            }
            else  if (("nonverbose" == sCommand)) (g_iVerbose = 0);
            else  if ((0 && ("config" == sCommand))) {
                
                jump _end2;
            }
            else  if (g_iSmoke) llSetTimerEvent(0.1);
            "";
            jump _end2;
        }
        "";
        @_end2;
        if (((iChan != PARTICLE_CHANNEL) || (!g_iSmoke))) return;
        string _ret4;
        string _sDefGroup6 = LINKSETID;
        if (("" == _sDefGroup6)) (_sDefGroup6 = "Default");
        string _str2 = llStringTrim(llGetObjectDesc(),3);
        if (((llToLower(_str2) == "(no description)") || (_str2 == ""))) (_str2 = _sDefGroup6);
        else  {
            list _lGroup9 = llParseString2List(_str2,[" "],[]);
            (_str2 = llList2String(_lGroup9,0));
        }
        string _str7 = _str2;
        list lKeys = llParseString2List(((string)kId),[SEPARATOR],[]);
        string sGroup = llList2String(lKeys,0);
        string _sScriptName8 = llList2String(lKeys,1);
        if ((((_str7 == sGroup) || (LINKSETID == sGroup)) || (LINKSETID == _str7))) {
            (_ret4 = _sScriptName8);
            jump _end5;
        }
        (_ret4 = "exit");
        @_end5;
        string sScriptName = _ret4;
        string _ret10;
        string _sDefGroup12 = LINKSETID;
        if (("" == _sDefGroup12)) (_sDefGroup12 = "Default");
        string __str213 = llStringTrim(llGetObjectDesc(),3);
        if (((llToLower(__str213) == "(no description)") || (__str213 == ""))) (__str213 = _sDefGroup12);
        else  {
            list _lGroup18 = llParseString2List(__str213,[" "],[]);
            (__str213 = llList2String(_lGroup18,0));
        }
        string _str14 = __str213;
        list _lKeys15 = llParseString2List(((string)kId),[SEPARATOR],[]);
        string _sGroup16 = llList2String(_lKeys15,0);
        string _sScriptName17 = llList2String(_lKeys15,1);
        if ((((_str14 == _sGroup16) || (LINKSETID == _sGroup16)) || (LINKSETID == _str14))) {
            (_ret10 = _sScriptName17);
            jump _end11;
        }
        (_ret10 = "exit");
        @_end11;
        if (("exit" == _ret10)) return;
        list lParams = llParseString2List(sSet,[SEPARATOR],[]);
        string sVal = llList2String(lParams,0);
        string sMsg = llList2String(lParams,1);
        if (((sVal == g_sSize) && ("0" != sVal))) {
            llSetTimerEvent(0.0);
            return;
        }
        if ((((((integer)sVal) > 0) && (((integer)sVal) <= 100)) && ("smoke" == sMsg))) {
            llSetTimerEvent(0.0);
            float num = g_fStartAlpha;
            float fAlpha = ((num / 100.0) * ((float)sVal));
            
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
