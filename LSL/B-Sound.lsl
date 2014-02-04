// LSL script generated: RealFire-Rene10957.LSL.B-Sound.lslp Tue Feb  4 23:33:07 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//Sound Enhancement to Realfire
// by Zopf Resident - Ray Zopf (Raz)
//
//04. Feb. 2014
//v0.48
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

//debug variables
//-----------------------------------------------
integer g_iDebugMode = FALSE;


//user changeable variables
//-----------------------------------------------
integer g_iSound = TRUE;
integer g_iVerbose = TRUE;

string BACKSOUNDFILE = "17742__krisboruff__fire-crackles-no-room";

string LINKSETID = "RealFire";


//internal variables
//-----------------------------------------------
string g_sTitle = "RealB-Sound";
string g_sVersion = "0.48";
string g_sAuthors = "Zopf";

string g_sType = "sound";
integer g_iType = LINK_SET;

integer g_iSoundAvail = FALSE;
float g_fSoundVolumeCur = 0.0;
float g_fSoundVolumeNew;
string g_sSize = "0";
float g_fFactor;
integer g_iInTimer = FALSE;
string g_sScriptName;
string SEPARATOR = ";;";
float SIZE_EXTRASMALL = 15.0;
integer COMMAND_CHANNEL = -15700;
integer SOUND_CHANNEL = -15780;


//###
//Debug.lslm
//0.1 - 28Jan2014

//===============================================================================
//= parameters   :    string    sMsg    message string received
//=
//= return        :    none
//=
//= description  :    output debug messages
//=
//===============================================================================
Debug(string sMsg){
    if ((!g_iDebugMode)) return;
    llOwnerSay(((("DEBUG: " + g_sScriptName) + "; ") + sMsg));
}


//###
//PrintStatusInfo.lslm
//0.13 - 04Feb2014

InfoLines(integer bool){
    if ((g_iVerbose && bool)) {
        if (g_iSoundAvail) llWhisper(0,(g_sTitle + " - File(s) found in inventory: Yes"));
        else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
    }
    if (g_iSound) {
        if (g_iSoundAvail) llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + "\t ready"));
        else  llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " not ready"));
    }
    else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " script disabled"));
    if (g_iVerbose) llWhisper(0,((((("\n\t- free memory: " + ((string)llGetFreeMemory())) + " -\n(v) ") + g_sTitle) + "/") + g_sScriptName));
}


//###
//GroupHandling.lslm
//0.5 - 31Jan2014

string getGroup(string sDefGroup){
    if (("" == sDefGroup)) (sDefGroup = "Default");
    string str = llStringTrim(llGetObjectDesc(),STRING_TRIM);
    if (((llToLower(str) == "(no description)") || (str == ""))) (str = sDefGroup);
    else  {
        list lGroup = llParseString2List(str,[" "],[]);
        (str = llList2String(lGroup,0));
    }
    return str;
}


string GroupCheck(key kId){
    string str = getGroup(LINKSETID);
    list lKeys = llParseString2List(((string)kId),[SEPARATOR],[]);
    string sGroup = llList2String(lKeys,0);
    string sScriptName = llList2String(lKeys,1);
    if ((((str == sGroup) || (LINKSETID == sGroup)) || (LINKSETID == str))) return sScriptName;
    return "exit";
}


//###
//ExtensionBasics.lslm
//0.32 - 04Feb2014

RegisterExtension(integer link){
    string sId = ((getGroup(LINKSETID) + SEPARATOR) + g_sScriptName);
    if ((g_iSound && g_iSoundAvail)) llMessageLinked(link,SOUND_CHANNEL,"1",((key)sId));
    else  llMessageLinked(link,SOUND_CHANNEL,"0",((key)sId));
}


MasterCommand(integer iChan,string sVal){
    if ((iChan == COMMAND_CHANNEL)) {
        if (("register" == sVal)) RegisterExtension(g_iType);
        else  if (("verbose" == sVal)) {
            (g_iVerbose = TRUE);
            InfoLines(FALSE);
        }
        else  if (("nonverbose" == sVal)) (g_iVerbose = FALSE);
        else  if (("globaldebug" == sVal)) (g_iVerbose = TRUE);
        else  llSetTimerEvent(0.1);
    }
}


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

checkSoundFiles(){
    integer iSoundNumber = llGetInventoryNumber(INVENTORY_SOUND);
    Debug(("Sound number = " + ((string)iSoundNumber)));
    if ((iSoundNumber > 0)) {
        integer i;
        for ((i = 0); (i < iSoundNumber); (++i)) {
            string sSoundName = llGetInventoryName(INVENTORY_SOUND,i);
            if ((sSoundName == BACKSOUNDFILE)) (g_iSoundAvail = TRUE);
        }
    }
    else  (g_iSoundAvail = FALSE);
}



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default {

	state_entry() {
        (g_sScriptName = llGetScriptName());
        Debug("state_entry");
        (g_fFactor = (7.0 / 8.0));
        llPassTouches(TRUE);
        if (g_iSound) llStopSound();
        checkSoundFiles();
        llSleep(1);
        RegisterExtension(g_iType);
        if (g_iSoundAvail) llPreloadSound(BACKSOUNDFILE);
        InfoLines(TRUE);
    }


	on_rez(integer start_param) {
        llResetScript();
    }


	touch(integer total_number) {
        if ((g_iSoundAvail && g_iSound)) llPreloadSound(BACKSOUNDFILE);
    }


	changed(integer change) {
        if ((change & CHANGED_INVENTORY)) {
            llWhisper(0,"Inventory changed, checking sound samples...");
            if (g_iSound) llStopSound();
            checkSoundFiles();
            llSleep(1);
            RegisterExtension(g_iType);
            if (g_iSoundAvail) llPreloadSound(BACKSOUNDFILE);
            InfoLines(TRUE);
        }
    }



//listen for linked messages from Fire (main) script
//-----------------------------------------------
	link_message(integer iSender,integer iChan,string sSoundSet,key kId) {
        Debug(((((("link_message = channel " + ((string)iChan)) + "; sSoundSet ") + sSoundSet) + "; kId ") + ((string)kId)));
        MasterCommand(iChan,sSoundSet);
        string sScriptName = GroupCheck(kId);
        if (("exit" == sScriptName)) return;
        if ((((iChan != SOUND_CHANNEL) || ((!g_iSound) && (!g_iSoundAvail))) || (llSubStringIndex(llToLower(sScriptName),g_sType) >= 0))) return;
        list lParams = llParseString2List(sSoundSet,[SEPARATOR],[]);
        string sVal = llList2String(lParams,0);
        string sMsg = llList2String(lParams,1);
        Debug(((((((("no changes? backround on/off? " + sVal) + "-") + sMsg) + "...g_fSoundVolumeCur=") + ((string)g_fSoundVolumeCur)) + "-g_sSize=") + g_sSize));
        if ((("110" == sVal) || (("0" == sMsg) && g_iInTimer))) return;
        llSetTimerEvent(0.0);
        (g_iInTimer = FALSE);
        if (((((float)sMsg) == g_fSoundVolumeCur) && ((sVal == g_sSize) || ("" == sVal)))) return;
        Debug("work on link_message");
        (g_fSoundVolumeNew = ((float)sMsg));
        if (((g_fSoundVolumeNew > 0.0) && (g_fSoundVolumeNew <= 1.0))) {
            Debug(("Factor start " + ((string)g_fFactor)));
            if (("-1" == sVal)) (g_fFactor = 1.0);
            else  if (((0 < ((integer)sVal)) && (100 >= ((integer)sVal)))) {
                if ((((integer)sVal) <= SIZE_EXTRASMALL)) (g_fFactor = (5.0 / 6.0));
                else  (g_fFactor = (7.0 / 8.0));
            }
            else  if ((("" != sVal) && (((integer)g_sSize) <= SIZE_EXTRASMALL))) (g_fFactor = (5.0 / 6.0));
            else  if (((("" != sVal) && (((integer)g_sSize) > SIZE_EXTRASMALL)) && (100 <= ((integer)g_sSize)))) (g_fFactor = (5.0 / 6.0));
            Debug(("Factor calculated " + ((string)g_fFactor)));
            float fSoundVolumeF = (g_fSoundVolumeNew * g_fFactor);
            if ((g_fSoundVolumeCur > 0)) {
                Debug(("Vol-adjust: " + ((string)fSoundVolumeF)));
                llAdjustSoundVolume(fSoundVolumeF);
            }
            else  {
                Debug(("play sound: " + ((string)fSoundVolumeF)));
                llPreloadSound(BACKSOUNDFILE);
                llStopSound();
                llLoopSound(BACKSOUNDFILE,fSoundVolumeF);
                if (g_iVerbose) llWhisper(0,"(v) Fire emits a crackling background sound");
            }
            (g_fSoundVolumeCur = g_fSoundVolumeNew);
            if (("" != sVal)) (g_sSize = sVal);
        }
        else  {
            llWhisper(0,"Background fire noises getting quieter and quieter...");
            (g_iInTimer = TRUE);
            llSetTimerEvent(12.0);
        }
    }



	timer() {
        llStopSound();
        if (g_iVerbose) llWhisper(0,"(v) Background noise off");
        (g_fSoundVolumeNew = (g_fSoundVolumeCur = 0.0));
        (g_sSize = "0");
        (g_iInTimer = FALSE);
        llSetTimerEvent(0.0);
    }
}
