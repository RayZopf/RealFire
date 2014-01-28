// LSL script generated: RealFire-Rene10957.LSL.B-Sound.lslp Tue Jan 28 02:33:22 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//Sound Enhancement to Realfire by Zopf Resident - Ray Zopf (Raz)
//
//28. Jan. 2014
//v0.41
//
//
// (Realfire by Rene)
// (Author: Rene10957 Resident)
// (v2.2)

//Files:
//B-Sound.lsl
//
//Fire.lsl
//config
//User Manual
//
//
//Prequisites: Soundfile need to be in same prim as B-Sound.lsl;
//	for fastest start, keep in prim that get's touched at start
//Notecard format: see config NC
//basic help: User Manual

//Changelog
// LSLForge Modules
//

//bug: soundpreload on touch is useless in child prim

//todo: decide if touch event should really block touch on child prim and how to preload sound
//todo: simplify to use only one sound file as background noise (at half? the normal volume - volume == volume falloff!!!)
//todo: sMsg has to be changed in Fire.lsl
//todo: make sounds from different prims asynchronus
//todo: check if other sound scripts are in same prim
//todo: touch passtrouch/touch event - check if that is handled correctly
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


//internal variables
//-----------------------------------------------
string g_sTitle = "RealB-Sound";
string g_sVersion = "0.41";
string g_sScriptName;

integer g_iSoundAvail = FALSE;
float g_fSoundVolumeCur = 0.0;
float g_fSoundVolumeCurF = 0.0;
float g_fSoundVolumeNew;
string g_sSize = "0";
float g_fFactor;

//RealFire MESSAGE MAP
integer COMMAND_CHANNEL = -10950;
integer SOUND_CHANNEL = -10956;

//###
//Debug.lslm
//0.1 - 14Jan2014
//###


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
//0.11 - 14Jan2014
//###

InfoLines(){
    if (g_iVerbose) {
        if (g_iSoundAvail) llWhisper(0,(g_sTitle + " - File(s) found in inventory: Yes"));
        else  llWhisper(0,(((g_sTitle + " / ") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
        if ((!g_iSound)) llWhisper(0,(((g_sTitle + " / ") + g_sScriptName) + " script disabled"));
        if ((g_iSound && g_iSoundAvail)) llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " ready"));
        else  llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " not ready"));
    }
}

//###
//RegisterExtension.lslm
//0.1 - 14Jan2014
//###

RegisterExtension(integer link){
    if ((g_iSound && g_iSoundAvail)) llMessageLinked(link,SOUND_CHANNEL,"1",((key)g_sScriptName));
    else  llMessageLinked(link,SOUND_CHANNEL,"0",((key)g_sScriptName));
}


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

CheckSoundFiles(){
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
        CheckSoundFiles();
        llSleep(1);
        RegisterExtension(LINK_SET);
        InfoLines();
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
            CheckSoundFiles();
            llSleep(1);
            RegisterExtension(LINK_SET);
            InfoLines();
        }
    }



//listen for linked messages from Fire (main) script
//-----------------------------------------------
    link_message(integer iSender,integer iChan,string sSoundSet,key kId) {
        Debug(((((("link_message = channel " + ((string)iChan)) + "; sSoundSet ") + sSoundSet) + "; kId ") + ((string)kId)));
        if ((iChan == COMMAND_CHANNEL)) RegisterExtension(LINK_SET);
        if (((((iChan != SOUND_CHANNEL) || (!g_iSound)) || (!g_iSoundAvail)) || (llSubStringIndex(llToLower(((string)kId)),"sound") >= 0))) return;
        list lParams = llParseString2List(sSoundSet,[","],[]);
        string sVal = llList2String(lParams,0);
        string sMsg = llList2String(lParams,1);
        Debug(((((((("no changes? backround on/off? " + sVal) + "-") + sMsg) + "...g_fSoundVolumeCur=") + ((string)g_fSoundVolumeCur)) + "-g_sSize=") + g_sSize));
        if (("110" == sMsg)) return;
        llSetTimerEvent(0.0);
        if (((((float)sVal) == g_fSoundVolumeCur) && ((sMsg == g_sSize) || ("" == sMsg)))) return;
        Debug("work on link_message");
        (g_fSoundVolumeNew = ((float)sVal));
        if (((g_fSoundVolumeNew > 0) && (g_fSoundVolumeNew <= 1))) {
            Debug(("Factor start " + ((string)g_fFactor)));
            if (("-1" == sMsg)) (g_fFactor = 1.0);
            else  if (((0 < ((integer)sMsg)) && (100 >= ((integer)sMsg)))) {
                if ((((integer)sMsg) <= 15)) (g_fFactor = (5.0 / 6.0));
                else  (g_fFactor = (7.0 / 8.0));
            }
            else  if ((("" != sMsg) && (((integer)g_sSize) <= 15))) (g_fFactor = (5.0 / 6.0));
            else  if (((("" != sMsg) && (((integer)g_sSize) > 15)) && (100 <= ((integer)g_sSize)))) (g_fFactor = (5.0 / 6.0));
            Debug(("Factor calculated " + ((string)g_fFactor)));
            float fSoundVolumeF = (g_fSoundVolumeNew * g_fFactor);
            if (((g_fSoundVolumeCur > 0) && (g_fSoundVolumeCurF > 0))) {
                Debug(("Vol-adjust: " + ((string)fSoundVolumeF)));
                llAdjustSoundVolume(fSoundVolumeF);
            }
            else  {
                Debug(("play sound: " + ((string)fSoundVolumeF)));
                llStopSound();
                llSleep(2);
                llLoopSound(BACKSOUNDFILE,fSoundVolumeF);
                if (g_iVerbose) llWhisper(0,"Fire emits a crackling background sound");
            }
            (g_fSoundVolumeCur = g_fSoundVolumeNew);
            (g_fSoundVolumeCurF = fSoundVolumeF);
            if (("" != sMsg)) (g_sSize = sMsg);
        }
        else  {
            llWhisper(0,"Background fire noises getting quieter and quieter...");
            llSetTimerEvent(11.0);
        }
    }



	timer() {
        llStopSound();
        if (g_iVerbose) llWhisper(0,"Background noise off");
        (g_fSoundVolumeNew = (g_fSoundVolumeCur = (g_fSoundVolumeCurF = 0.0)));
        (g_sSize = "0");
        llSetTimerEvent(0.0);
    }
}
