// LSL script generated: RealFire-Rene10957.LSL.Sound.lslp Wed Feb 12 05:08:21 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//Sound Enhancement to Realfire
// by Zopf Resident - Ray Zopf (Raz)
//
//11. Feb. 2014
//v0.88
//
//
// (Realfire by Rene)
// (Author: Rene10957 Resident)
// (v2.2)
//

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
//
//Changelog
// LSLForge Modules
//

//FIXME: sound on fire on does not work

//TODO: make file check (lists) the other way round: check if every inventory file is member of RealFire file list?
//TODO: decide if touch event should really block touch on child prim and how to preload sound
//TODO: think about fire size = 0 what happens to normal sound (B-sound would just go working on)
//TODO: use more sounds and change them randomly http://wiki.secondlife.com/wiki/Script:Random_Sounds
//TODO: check if other sound scripts are in same prim
//TODO: create a module sizeSelect, put size class borders into variables and settings notecard
//TODO: is "change sound while off" really needed? - check sound on/off, sound more/less louder
///////////////////////////////////////////////////////////////////////////////////////////////////


//===============================================
//GLOBAL VARIABLES
//===============================================

//user changeable variables
//-----------------------------------------------
integer g_iSound;

string g_sSoundFileStart = "75145__willc2-45220__struck-match-8b-22k-1-65s";
string g_sSoundFileSmall = "17742__krisboruff__fire-crackles-no-room_med";
string g_sSoundFileMedium1 = "104958__glaneur-de-sons__petit-feu-little-fire-2_loud";
string g_sSoundFileMedium2 = "104957__glaneur-de-sons__petit-feu-little-fire-1_loud";
string g_sSoundFileFull = "4211__dobroide__fire-crackling_loud";

integer g_iSoundNFiles;
//starting sound has to be first in list
list g_lSoundFileList = [g_sSoundFileStart,g_sSoundFileSmall,g_sSoundFileMedium1,g_sSoundFileMedium2,g_sSoundFileFull];
string g_sCurrentSoundFile = g_sSoundFileMedium2;

string LINKSETID = "RealFire";


//internal variables
//-----------------------------------------------
string g_sTitle = "RealSound";
string g_sVersion = "0.88";
string g_sAuthors = "Zopf";

string g_sType = "sound";

integer g_iSoundAvail = 0;
integer g_iSoundFileStartAvail = 1;
integer g_iSoundNFilesAvail;
float g_fSoundVolumeCur = 0.0;
float g_fSoundVolumeNew;
string g_sSize = "0";
integer g_iVerbose = 1;
string g_sMainScript = "Fire.lsl";
string g_sScriptName;
integer silent = 0;
string SEPARATOR = ";;";
integer COMMAND_CHANNEL = -15700;
integer SOUND_CHANNEL = -15780;


//###
//CheckForFiles.lslm
//0.21 - 11Feb2014

string CheckForFiles(integer iNFiles,list lgivenFileList,integer iPermCheck,string sCurrentFile){
    integer iFileNumber = llGetInventoryNumber(1);
    
    if ((iFileNumber > 0)) {
        (g_iSoundNFilesAvail = 0);
        list lFileAvail = [];
        list lFileList = [];
        integer i;
        for ((i = 0); (i < iFileNumber); (++i)) {
            (lFileList += llGetInventoryName(1,i));
        }
        list lFileCompare = [];
        for ((i = 0); (i < iNFiles); (++i)) {
            (lFileCompare = llList2List(lgivenFileList,i,i));
            if ((-1 == llListFindList(lFileList,lFileCompare))) {
                (lFileAvail += 0);
                if ((((0 < i) && (((string)lFileCompare) == sCurrentFile)) && (2 < iNFiles))) {
                    integer iFileNAvail = llGetListLength(lFileAvail);
                    if ((iNFiles > iFileNAvail)) (sCurrentFile = ((string)llList2List(lgivenFileList,(i + 1),(i + 1))));
                    else  {
                        list lFileAvailTmp = llList2List(lFileAvail,1,(iNFiles - 1));
                        integer j = llListFindList(lFileAvailTmp,[1]);
                        if ((0 <= j)) (sCurrentFile = ((string)llList2List(lFileAvailTmp,j,j)));
                    }
                }
                llWhisper(0,((g_sTitle + " - File not found in inventory: ") + ((string)lFileCompare)));
            }
            else  {
                if (iPermCheck) {
                    if ((!(32768 & llGetInventoryPermMask(((string)lFileCompare),1)))) {
                        llWhisper(0,((g_sTitle + " - File has wrong permission: ") + ((string)lFileCompare)));
                        (lFileAvail += 0);
                    }
                    else  {
                        (lFileAvail += 1);
                        (g_iSoundNFilesAvail++);
                    }
                }
                else  {
                    (lFileAvail += 1);
                    (g_iSoundNFilesAvail++);
                }
            }
        }
        if ((0 == llListFindList(lFileAvail,[1]))) (g_iSoundFileStartAvail = 1);
        else  (g_iSoundFileStartAvail = 0);
        if ((-1 != llListFindList(llList2List(lFileAvail,1,(iNFiles - 1)),[1]))) (g_iSoundAvail = 1);
        else  (g_iSoundAvail = 0);
        return sCurrentFile;
    }
    else  {
        (g_iSoundAvail = 0);
        return "0";
    }
}


selectStuff(float fVal){
    
    if ((fVal <= 25.0)) {
        (g_sCurrentSoundFile = g_sSoundFileSmall);
    }
    else  if (((fVal > 25.0) && (fVal < 50.0))) {
        (g_sCurrentSoundFile = g_sSoundFileMedium1);
    }
    else  if (((fVal >= 50.0) && (fVal < 80.0))) {
        (g_sCurrentSoundFile = g_sSoundFileMedium2);
    }
    else  if (((fVal >= 80.0) && (fVal <= 100))) {
        (g_sCurrentSoundFile = g_sSoundFileFull);
    }
    else  {
        
        if (((g_fSoundVolumeNew > 0) && (1 == g_iSoundFileStartAvail))) {
            integer n;
            for ((n = 0); (n < 3); (++n)) {
                llTriggerSound(g_sSoundFileStart,g_fSoundVolumeNew);
            }
        }
        (g_fSoundVolumeNew = 0.0);
        (g_sSize = "0");
        return;
    }
    (g_sSize = ((string)fVal));
}



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default {

	state_entry() {
        (g_iSound = 1);
        (g_iSoundNFiles = 5);
        integer rc = -1;
        (rc = llSetMemoryLimit(32000));
        if ((g_iVerbose && (1 > rc))) llWhisper(0,(((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - Setting memory limit failed"));
        (g_sScriptName = llGetScriptName());
        
        llStopSound();
        (g_sCurrentSoundFile = CheckForFiles(g_iSoundNFiles,g_lSoundFileList,0,g_sCurrentSoundFile));
        llSleep(1);
        integer link = -1;
        if (g_iSound) {
            if ((0 && (-1 == llGetInventoryType(g_sMainScript)))) {
                (g_iSoundAvail = 0);
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
            if (g_iSoundAvail) llMessageLinked(link,SOUND_CHANNEL,"1",((key)sId));
        }
        @__end02;
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
        if (((!silent) && g_iVerbose)) llWhisper(0,((((((((("\n\t- used/max available memory: " + ((string)llGetUsedMemory())) + "/") + ((string)llGetMemoryLimit())) + " - free: ") + ((string)llGetFreeMemory())) + "-\n(v) ") + g_sTitle) + "/") + g_sScriptName));
    }


	on_rez(integer start_param) {
        llResetScript();
    }


	touch(integer total_number) {
    }


	changed(integer change) {
        if ((change & 1)) {
            if ((!silent)) llWhisper(0,"Inventory changed, checking sound samples...");
            llStopSound();
            (g_sCurrentSoundFile = CheckForFiles(g_iSoundNFiles,g_lSoundFileList,0,g_sCurrentSoundFile));
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
            if (((!silent) && g_iVerbose)) llWhisper(0,((((((((("\n\t- used/max available memory: " + ((string)llGetUsedMemory())) + "/") + ((string)llGetMemoryLimit())) + " - free: ") + ((string)llGetFreeMemory())) + "-\n(v) ") + g_sTitle) + "/") + g_sScriptName));
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
                if (((!silent) && g_iVerbose)) llWhisper(0,((((((((("\n\t- used/max available memory: " + ((string)llGetUsedMemory())) + "/") + ((string)llGetMemoryLimit())) + " - free: ") + ((string)llGetFreeMemory())) + "-\n(v) ") + g_sTitle) + "/") + g_sScriptName));
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
        
        if ((((((float)sMsg) == g_fSoundVolumeCur) && ((sVal == g_sSize) || ("" == sVal))) || ("-1" == sVal))) return;
        
        (g_fSoundVolumeNew = ((float)sMsg));
        if ((((((0 == g_fSoundVolumeNew) && (sVal != g_sSize)) && ("" != sVal)) && ("0" != sVal)) && ("110" != sVal))) {
            if ((g_iSoundNFilesAvail > 1)) selectStuff(((float)sVal));
            
            return;
        }
        if ((("0" != sVal) && ((g_fSoundVolumeNew > 0) && (g_fSoundVolumeNew <= 1)))) {
            llSetTimerEvent(0.0);
            if ((("" == sVal) || (sVal == g_sSize))) {
                if ((g_fSoundVolumeCur > 0.0)) {
                    llAdjustSoundVolume(g_fSoundVolumeNew);
                    if (((!silent) && g_iVerbose)) llWhisper(0,"(v) Sound range for fire has changed");
                }
                else  {
                    llPreloadSound(g_sCurrentSoundFile);
                    llStopSound();
                    llLoopSound(g_sCurrentSoundFile,g_fSoundVolumeNew);
                    if (((!silent) && g_iVerbose)) llWhisper(0,"(v) The fire starts to make noise again");
                }
            }
            else  {
                string sCurrentSoundFileTemp = g_sCurrentSoundFile;
                string sSizeTemp = g_sSize;
                if ((g_iSoundNFilesAvail > 1)) selectStuff(((float)sVal));
                if (("110" == sMsg)) return;
                if (((g_sCurrentSoundFile == sCurrentSoundFileTemp) && ("0" != sSizeTemp))) {
                    llAdjustSoundVolume(g_fSoundVolumeNew);
                    if (((!silent) && g_iVerbose)) llWhisper(0,"(v) Sound range for fire has changed");
                }
                else  {
                    if (g_iVerbose) {
                        if ((((!silent) && g_iVerbose) && (g_fSoundVolumeCur > 0.0))) llWhisper(0,"(v) The fire changes it's sound");
                        else  if ((!silent)) llWhisper(0,"(v) The fire starts to make noise");
                    }
                    
                    llPreloadSound(g_sCurrentSoundFile);
                    llSleep(1.3);
                    llStopSound();
                    llLoopSound(g_sCurrentSoundFile,g_fSoundVolumeNew);
                }
            }
            (g_fSoundVolumeCur = g_fSoundVolumeNew);
        }
        else  llSetTimerEvent(1.2);
    }



	timer() {
        llStopSound();
        if (((!silent) && g_iVerbose)) llWhisper(0,"(v) Noise from fire ended");
        (g_fSoundVolumeNew = (g_fSoundVolumeCur = 0.0));
        (g_sSize = "0");
        llSetTimerEvent(0.0);
    }
}
