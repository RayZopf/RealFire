// LSL script generated: RealFire-Rene10957.LSL.B-Sound.lslp Tue Feb 11 16:16:26 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//Sound Enhancement to Realfire
// by Zopf Resident - Ray Zopf (Raz)
//
//11. Feb. 2014
//v0.511
//
//
// (Realfire by Rene)
// (Author: Rene10957 Resident)
// (v2.2)

//Files:
// B-Sound.lsl
//
// Fire.lsl
// config
// User Manual
//
//
//Prequisites: Soundfile need to be in same prim as B-Sound.lsl;
// for fastest start, keep in prim that get's touched at start
//Notecard format: see config NC
//basic help: User Manual
//
//Changelog
// LSLForge Modules
//

//FIXME: soundpreload on touch is useless in child prim

//TODO: decide if touch event should really block touch on child prim and how to preload sound
//TODO: simplify to use only one sound file as background noise (at half? the normal volume - volume == volume falloff!!!)
//TODO: sMsg has to be changed in Fire.lsl
//TODO: make sounds from different prims asynchronus
//TODO: check if other sound scripts are in same prim
//TODO: touch passtrouch/touch event - check if that is handled correctly
///////////////////////////////////////////////////////////////////////////////////////////////////



//===============================================
//GLOBAL VARIABLES
//===============================================

//user changeable variables
//-----------------------------------------------
integer g_iSound;

string BACKSOUNDFILE = "17742__krisboruff__fire-crackles-no-room_loud";

string LINKSETID = "RealFire";


//internal variables
//-----------------------------------------------
string g_sTitle = "RealB-Sound";
string g_sVersion = "0.511";
string g_sAuthors = "Zopf";

string g_sType = "sound";

integer g_iSoundAvail = 0;
float g_fSoundVolumeCur = 0.0;
float g_fSoundVolumeNew;
string g_sSize = "0";
float g_fFactor;
integer g_iVerbose = 1;
string g_sMainScript = "Fire.lsl";
string g_sScriptName;
integer silent = 0;
integer g_iInTimer = 0;
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


checkSoundFiles(){
    integer iSoundNumber = llGetInventoryNumber(1);
    
    if ((iSoundNumber > 0)) {
        integer i;
        for ((i = 0); (i < iSoundNumber); (++i)) {
            string sSoundName = llGetInventoryName(1,i);
            if ((sSoundName == BACKSOUNDFILE)) (g_iSoundAvail = 1);
        }
    }
    else  (g_iSoundAvail = 0);
}



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default {

	state_entry() {
        MESSAGE_MAP();
        (g_iSound = 1);
        (g_sScriptName = llGetScriptName());
        
        (g_fFactor = 0.875);
        llPassTouches(1);
        if (g_iSound) llStopSound();
        checkSoundFiles();
        llSleep(1);
        integer link = -1;
        if (g_iSound) {
            if ((0 && (-1 == llGetInventoryType(g_sMainScript)))) {
                (g_iSoundAvail = 0);
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
            if (g_iSoundAvail) llMessageLinked(link,SOUND_CHANNEL,"1",((key)sId));
        }
        @__end01;
        if (g_iSoundAvail) llPreloadSound(BACKSOUNDFILE);
        if ((g_iVerbose && 1)) {
            if (g_iSoundAvail) {
                if ((!silent)) llWhisper(0,(("(v) " + g_sTitle) + " - File(s) found in inventory: Yes"));
            }
            else  llWhisper(0,(((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
        }
        if (g_iSound) {
            if (g_iSoundAvail) {
                if ((!silent)) llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + "\t ready"));
            }
            else  llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " not ready"));
        }
        else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " script disabled"));
        if (((!silent) && g_iVerbose)) llWhisper(0,((((((("\n\t- currently used/free memory: (u)" + ((string)llGetUsedMemory())) + "/") + ((string)llGetFreeMemory())) + "(f) -\n(v) ") + g_sTitle) + "/") + g_sScriptName));
    }


	on_rez(integer start_param) {
        llResetScript();
    }


	touch(integer total_number) {
        if ((g_iSoundAvail && g_iSound)) llPreloadSound(BACKSOUNDFILE);
    }


	changed(integer change) {
        if ((change & 1)) {
            if ((!silent)) llWhisper(0,"Inventory changed, checking sound samples...");
            if (g_iSound) llStopSound();
            checkSoundFiles();
            llSleep(1);
            integer link = -1;
            if (g_iSound) {
                if ((0 && (-1 == llGetInventoryType(g_sMainScript)))) {
                    (g_iSoundAvail = 0);
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
                if (g_iSoundAvail) llMessageLinked(link,SOUND_CHANNEL,"1",((key)sId));
            }
            @__end01;
            if (g_iSoundAvail) llPreloadSound(BACKSOUNDFILE);
            if ((g_iVerbose && 1)) {
                if (g_iSoundAvail) {
                    if ((!silent)) llWhisper(0,(("(v) " + g_sTitle) + " - File(s) found in inventory: Yes"));
                }
                else  llWhisper(0,(((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
            }
            if (g_iSound) {
                if (g_iSoundAvail) {
                    if ((!silent)) llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + "\t ready"));
                }
                else  llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " not ready"));
            }
            else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " script disabled"));
            if (((!silent) && g_iVerbose)) llWhisper(0,((((((("\n\t- currently used/free memory: (u)" + ((string)llGetUsedMemory())) + "/") + ((string)llGetFreeMemory())) + "(f) -\n(v) ") + g_sTitle) + "/") + g_sScriptName));
        }
    }



//listen for linked messages from Fire (main) script
//-----------------------------------------------
	link_message(integer iSender,integer iChan,string sSoundSet,key kId) {
        
        string _ret0;
        if ((iChan == COMMAND_CHANNEL)) {
            list lValues = llParseString2List(sSoundSet,[SEPARATOR],[]);
            string sCommand = llList2String(lValues,0);
            if (("register" == sCommand)) {
                integer link = -1;
                if (g_iSound) {
                    if ((0 && (-1 == llGetInventoryType(g_sMainScript)))) {
                        (g_iSoundAvail = 0);
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
                    if (g_iSoundAvail) llMessageLinked(link,SOUND_CHANNEL,"1",((key)sId));
                }
                @_end0;
            }
            else  if (("verbose" == sCommand)) {
                (g_iVerbose = 1);
                if ((g_iVerbose && 0)) {
                    if (g_iSoundAvail) {
                        if ((!silent)) llWhisper(0,(("(v) " + g_sTitle) + " - File(s) found in inventory: Yes"));
                    }
                    else  llWhisper(0,(((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
                }
                if (g_iSound) {
                    if (g_iSoundAvail) {
                        if ((!silent)) llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + "\t ready"));
                    }
                    else  llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " not ready"));
                }
                else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " script disabled"));
                if (((!silent) && g_iVerbose)) llWhisper(0,((((((("\n\t- currently used/free memory: (u)" + ((string)llGetUsedMemory())) + "/") + ((string)llGetFreeMemory())) + "(f) -\n(v) ") + g_sTitle) + "/") + g_sScriptName));
            }
            else  if (("nonverbose" == sCommand)) (g_iVerbose = 0);
            else  if ((0 && ("config" == sCommand))) {
                (_ret0 = sSoundSet);
                jump _end1;
            }
            else  if (g_iSound) llSetTimerEvent(0.1);
            (_ret0 = "");
            jump _end1;
        }
        (_ret0 = "");
        @_end1;
        string sConfig = _ret0;
        if (("" != sConfig)) {
        }
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
        if (("exit" == sScriptName)) return;
        if (((((iChan != SOUND_CHANNEL) || (!g_iSound)) || (!g_iSoundAvail)) || (llSubStringIndex(llToLower(sScriptName),g_sType) >= 0))) return;
        list lParams = llParseString2List(sSoundSet,[SEPARATOR],[]);
        string sVal = llList2String(lParams,0);
        string sMsg = llList2String(lParams,1);
        
        if ((("110" == sVal) || (("0" == sMsg) && g_iInTimer))) return;
        llSetTimerEvent(0.0);
        (g_iInTimer = 0);
        if (((((float)sMsg) == g_fSoundVolumeCur) && ((sVal == g_sSize) || ("" == sVal)))) return;
        
        (g_fSoundVolumeNew = ((float)sMsg));
        if (((g_fSoundVolumeNew > 0.0) && (g_fSoundVolumeNew <= 1.0))) {
            
            if (("-1" == sVal)) (g_fFactor = 1.0);
            else  if (((0 < ((integer)sVal)) && (100 >= ((integer)sVal)))) {
                if ((((integer)sVal) <= 25.0)) (g_fFactor = 0.8);
                else  (g_fFactor = 0.8571428571428571);
            }
            else  if ((("" != sVal) && (((integer)g_sSize) <= 25.0))) (g_fFactor = 0.8333333333333334);
            else  if (((("" != sVal) && (((integer)g_sSize) > 25.0)) && (100 <= ((integer)g_sSize)))) (g_fFactor = 0.8333333333333334);
            
            float fSoundVolumeF = (g_fSoundVolumeNew * g_fFactor);
            if ((g_fSoundVolumeCur > 0)) {
                
                llAdjustSoundVolume(fSoundVolumeF);
            }
            else  {
                
                llPreloadSound(BACKSOUNDFILE);
                llStopSound();
                llLoopSound(BACKSOUNDFILE,fSoundVolumeF);
                if (((!silent) && g_iVerbose)) llWhisper(0,"(v) Fire emits a crackling background sound");
            }
            (g_fSoundVolumeCur = g_fSoundVolumeNew);
            if (("" != sVal)) (g_sSize = sVal);
        }
        else  {
            if ((!silent)) llWhisper(0,"Background fire noises getting quieter and quieter...");
            (g_iInTimer = 1);
            llSetTimerEvent(12.0);
        }
    }



	timer() {
        llStopSound();
        if (((!silent) && g_iVerbose)) llWhisper(0,"(v) Background noise off");
        (g_fSoundVolumeNew = (g_fSoundVolumeCur = 0.0));
        (g_sSize = "0");
        (g_iInTimer = 0);
        llSetTimerEvent(0.0);
    }
}
