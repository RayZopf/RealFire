// LSL script generated: RealFire-Rene10957.LSL.Sound.lslp Mon Jan 27 06:05:39 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//Sound Enhancement to Realfire by Zopf Resident - Ray Zopf (Raz)
//
//14. Jan. 2014
//v0.7
//
//
// (Realfire by Rene)
// (Author: Rene10957 Resident)
// (v2.2)

//Files:
//Sound.lsl
//
//Fire.lsl
//config
//User Manual
//
//
//Prequisites: Soundfiles need to be in same prim as Sound.lsl
//Notecard format: see config NC
//basic help: User Manual

//Changelog
// LSLForge Modules
//

//bug: ---

//todo: improve sound file check
//todo: make sound file check (lists) the other way round: check if every inventory file is member of fire sound list?
//todo: decide if touch event should really block touch on child prim and how to preload sound
//todo: think about fire size = 0 what happens to normal sound (B-sound would just go working on)
//todo: use more sounds and change them randomly http://wiki.secondlife.com/wiki/Script:Random_Sounds
//todo: check if other sound scripts are in same prim
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

string g_sSoundFileStart = "75145__willc2-45220__struck-match-8b-22k-1-65s";
string g_sSoundFileSmall = "17742__krisboruff__fire-crackles-no-room";
string g_sSoundFileMedium1 = "104958__glaneur-de-sons__petit-feu-little-fire-2";
string g_sSoundFileMedium2 = "104957__glaneur-de-sons__petit-feu-little-fire-1";
string g_sSoundFileFull = "4211__dobroide__fire-crackling";

integer g_iSoundNFiles = 5;
//starting sound has to be first in list
list g_lSoundFileList = [g_sSoundFileStart,g_sSoundFileSmall,g_sSoundFileMedium1,g_sSoundFileMedium2,g_sSoundFileFull];
string g_sCurrentSoundFile = g_sSoundFileMedium2;


//internal variables
//-----------------------------------------------
string g_sTitle = "RealSound";
string g_sVersion = "0.7";
string g_sScriptName;

integer g_iSoundAvail = FALSE;
list g_lSoundFileAvail = [];
integer g_iSoundFileStartAvail = TRUE;
float g_fSoundVolumeCur = 0.0;
float g_fSoundVolumeNew;
string g_sSize = "0";

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
        (g_lSoundFileAvail = []);
        list lSoundList = [];
        integer i;
        for ((i = 0); (i < iSoundNumber); (++i)) {
            (lSoundList += llGetInventoryName(INVENTORY_SOUND,i));
        }
        for ((i = 0); (i < g_iSoundNFiles); (++i)) {
            list lSoundCompare = llList2List(g_lSoundFileList,i,i);
            if ((ERR_GENERIC == llListFindList(lSoundList,lSoundCompare))) {
                (g_lSoundFileAvail += FALSE);
                if ((((0 < i) && (((string)lSoundCompare) == g_sCurrentSoundFile)) && (2 < g_iSoundNFiles))) {
                    integer g_iSoundFileNAvail = llGetListLength(g_lSoundFileAvail);
                    if ((g_iSoundNFiles > g_iSoundFileNAvail)) (g_sCurrentSoundFile = ((string)llList2List(g_lSoundFileList,(i + 1),(i + 1))));
                    else  {
                        list lSoundFileAvailTmp = llList2List(g_lSoundFileAvail,1,(g_iSoundNFiles - 1));
                        integer j = llListFindList(lSoundFileAvailTmp,[TRUE]);
                        if ((0 <= j)) (g_sCurrentSoundFile = ((string)llList2List(lSoundFileAvailTmp,j,j)));
                    }
                }
                llWhisper(0,((g_sTitle + " - Sound not found in inventory: ") + ((string)lSoundCompare)));
            }
            else  (g_lSoundFileAvail += TRUE);
        }
        if ((0 == llListFindList(g_lSoundFileAvail,[TRUE]))) (g_iSoundFileStartAvail = TRUE);
        else  (g_iSoundFileStartAvail = FALSE);
        if ((ERR_GENERIC != llListFindList(llList2List(g_lSoundFileAvail,1,(g_iSoundNFiles - 1)),[TRUE]))) (g_iSoundAvail = TRUE);
        else  (g_iSoundAvail = FALSE);
    }
    else  (g_iSoundAvail = FALSE);
}


SelectSound(float fMsg){
    Debug(("SelectSound: " + ((string)fMsg)));
    if ((fMsg <= 25)) {
        (g_sCurrentSoundFile = g_sSoundFileSmall);
    }
    else  if (((fMsg > 25) && (fMsg <= 50))) {
        (g_sCurrentSoundFile = g_sSoundFileMedium1);
    }
    else  if (((fMsg > 50) && (fMsg < 80))) {
        (g_sCurrentSoundFile = g_sSoundFileMedium2);
    }
    else  if (((fMsg >= 80) && (fMsg <= 100))) {
        (g_sCurrentSoundFile = g_sSoundFileFull);
    }
    else  {
        Debug((("start if g_fSoundVolumeNew > 0: -" + ((string)g_fSoundVolumeNew)) + "-"));
        if (((g_fSoundVolumeNew > 0) && (TRUE == g_iSoundFileStartAvail))) {
            integer n;
            for ((n = 0); (n < 3); (++n)) {
                llTriggerSound(g_sSoundFileStart,g_fSoundVolumeNew);
            }
        }
        (g_sSize = "0");
        return;
    }
    (g_sSize = ((string)fMsg));
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
        llStopSound();
        CheckSoundFiles();
        llSleep(1);
        RegisterExtension(LINK_SET);
        InfoLines();
    }


    on_rez(integer start_param) {
        llResetScript();
    }

	
	touch(integer total_number) {
    }

	
	changed(integer change) {
        if ((change & CHANGED_INVENTORY)) {
            llWhisper(0,"Inventory changed, checking sound samples...");
            llStopSound();
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
        Debug(((((((("no changes? background? " + sVal) + "-") + sMsg) + "...g_fSoundVolumeCur=") + ((string)g_fSoundVolumeCur)) + "-g_sSize=") + g_sSize));
        if ((((((float)sVal) == g_fSoundVolumeCur) && ((sMsg == g_sSize) || ("" == sMsg))) || ("-1" == sMsg))) return;
        Debug("work on link_message");
        (g_fSoundVolumeNew = ((float)sVal));
        if (((((0 == g_fSoundVolumeNew) && (sMsg != g_sSize)) && ("" != sMsg)) && ("0" != sMsg))) {
            SelectSound(((float)sMsg));
            Debug("change while off");
            return;
        }
        if (((g_fSoundVolumeNew > 0) && (g_fSoundVolumeNew <= 1))) {
            if ((("" == sMsg) || (sMsg == g_sSize))) {
                if ((g_fSoundVolumeCur > 0)) {
                    llAdjustSoundVolume(g_fSoundVolumeNew);
                    if (g_iVerbose) llWhisper(0,"Fire changes it's volume level");
                }
                else  {
                    llLoopSound(g_sCurrentSoundFile,g_fSoundVolumeNew);
                    if (g_iVerbose) llWhisper(0,"The fire starts to make some noise");
                }
                (g_fSoundVolumeCur = g_fSoundVolumeNew);
                return;
            }
            string sCurrentSoundFileTemp = g_sCurrentSoundFile;
            SelectSound(((float)sMsg));
            if ((("110" == sMsg) || (g_sCurrentSoundFile == sCurrentSoundFileTemp))) return;
            if ((g_iVerbose && ("0" != g_sSize))) llWhisper(0,"The fire changes it's sound");
            Debug(("play sound: " + g_sCurrentSoundFile));
            llPreloadSound(g_sCurrentSoundFile);
            (g_fSoundVolumeCur = g_fSoundVolumeNew);
            llStopSound();
            llLoopSound(g_sCurrentSoundFile,g_fSoundVolumeNew);
        }
        else  {
            llSleep(1);
            llStopSound();
            if (g_iVerbose) llWhisper(0,"Noise from fire ended");
            (g_fSoundVolumeNew = (g_fSoundVolumeCur = 0.0));
            (g_sSize = "0");
        }
    }
}
