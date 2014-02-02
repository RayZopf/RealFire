///////////////////////////////////////////////////////////////////////////////////////////////////
//Sound Enhancement to Realfire
// by Zopf Resident - Ray Zopf (Raz)
//
//02. Feb. 2014
//v0.84
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

//FIXME: ---

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

//debug variables
//-----------------------------------------------
integer g_iDebugMode=FALSE; // set to TRUE to enable Debug messages


//user changeable variables
//-----------------------------------------------
integer g_iSound = TRUE;         // Sound on/off in this prim
integer g_iVerbose = TRUE;

string g_sSoundFileStart = "75145__willc2-45220__struck-match-8b-22k-1-65s";     // starting fire (somehow special sound!)
string g_sSoundFileSmall = "17742__krisboruff__fire-crackles-no-room";           // sound for small fire
string g_sSoundFileMedium1 = "104958__glaneur-de-sons__petit-feu-little-fire-2"; // first sound for medium fire (yes, file fire-2)
string g_sSoundFileMedium2 = "104957__glaneur-de-sons__petit-feu-little-fire-1"; // second sound for medium fire
string g_sSoundFileFull = "4211__dobroide__fire-crackling";                      // standard sound, sound for big fire

integer g_iSoundNFiles = 5;
//starting sound has to be first in list
list g_lSoundFileList = [g_sSoundFileStart, g_sSoundFileSmall, g_sSoundFileMedium1, g_sSoundFileMedium2, g_sSoundFileFull];
string g_sCurrentSoundFile = g_sSoundFileMedium2; // standard sound - must not be sound for starting fire!

string LINKSETID = "RealFire"; // to be compared to first word in prim description - only listen to link-messages from prims that have this id;


//internal variables
//-----------------------------------------------
string g_sTitle = "RealSound";     // title
string g_sVersion = "0.84";       // version
string g_sScriptName;
string g_sType = "sound";
integer g_iType = LINK_SET;

integer g_iSoundAvail = FALSE;
integer g_iInvType = INVENTORY_SOUND;
integer g_iSoundFileStartAvail = TRUE;
integer g_iPermCheck = FALSE;
integer g_iSoundNFilesAvail; // cut some stuff if only one file found
float g_fSoundVolumeCur = 0.0;
float g_fSoundVolumeNew;
string g_sSize = "0";

//RealFire MESSAGE MAP
//integer COMMAND_CHANNEL =
//integer SOUND_CHANNEL = sound channel


//===============================================
//LSLForge MODULES
//===============================================
$import RealFireMessageMap.lslm();
$import Debug.lslm(m_iDebugMode=g_iDebugMode, m_sScriptName=g_sScriptName);
$import PrintStatusInfo.lslm(m_iVerbose=g_iVerbose, m_iAvail=g_iSoundAvail, m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_iOn=g_iSound, m_sVersion=g_sVersion);
$import ExtensionBasics.lslm(m_sGroup=LINKSETID, m_iEnabled=g_iSound, m_iAvail=g_iSoundAvail, m_iChannel=SOUND_CHANNEL, m_sScriptName=g_sScriptName, m_iVerbose=g_iVerbose, m_iLinkType=g_iType);
$import GroupHandling.lslm(m_sGroup=LINKSETID);
$import CheckForFiles.lslm(m_iDebugMode=g_iDebugMode, m_sScriptName=g_sScriptName, m_iInvType=g_iInvType, m_iFileStartAvail=g_iSoundFileStartAvail, m_sTitle=g_sTitle, m_iNFilesAvail=g_iSoundNFilesAvail, m_iAvail=g_iSoundAvail);


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

SelectStuff(float fMsg)
{
	Debug("SelectStuff: "+(string)fMsg);
	if (fMsg <= SIZE_SMALL) {
		g_sCurrentSoundFile = g_sSoundFileSmall;
	} else if (fMsg > SIZE_SMALL && fMsg < SIZE_MEDIUM) {
		g_sCurrentSoundFile = g_sSoundFileMedium1;
	} else if (fMsg >= SIZE_MEDIUM && fMsg < SIZE_LARGE) {
		g_sCurrentSoundFile = g_sSoundFileMedium2;
	} else if (fMsg >= SIZE_LARGE && fMsg <= 100) {
		g_sCurrentSoundFile = g_sSoundFileFull;
	} else {
		Debug("start if g_fSoundVolumeNew > 0: -"+(string)g_fSoundVolumeNew+"-");
		if (g_fSoundVolumeNew > 0 && TRUE == g_iSoundFileStartAvail) {
			integer n;
			for (n = 0; n < 3; ++n) { //let sound appear louder
				llTriggerSound(g_sSoundFileStart, g_fSoundVolumeNew); //preloaded on touch
			}
		// to let the sound play additionally to looping ones and without getting stoped
		}
		g_sSize = "0";
		return;
	}
	g_sSize = (string)fMsg;
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
		g_sScriptName = llGetScriptName();
		Debug("state_entry");
		llStopSound();
		g_sCurrentSoundFile = CheckForFiles(g_iSoundNFiles, g_lSoundFileList, g_iPermCheck, g_sCurrentSoundFile);
		llSleep(1);
		RegisterExtension(g_iType);
		InfoLines();
	}

	on_rez(integer start_param)
	{
		llResetScript();
	}

	touch(integer total_number)
	{
		// if (g_iSoundAvail && g_iSound) llPreloadSound(g_sSoundFileMedium1); //maybe change preloaded soundfile to medium fire sound
		//this also blocks touch events on this child to be passed to root prim! only works if child prim is touched
	}

	changed(integer change)
	{
		if (change & CHANGED_INVENTORY) {
			llWhisper(0, "Inventory changed, checking sound samples...");
			llStopSound();
			g_sCurrentSoundFile = CheckForFiles(g_iSoundNFiles, g_lSoundFileList, g_iPermCheck, g_sCurrentSoundFile);
			llSleep(1);
			RegisterExtension(g_iType);
			InfoLines();
		}
	}


//listen for linked messages from Fire (main) script
//-----------------------------------------------
	link_message(integer iSender, integer iChan, string sSoundSet, key kId)
	{
		Debug("link_message = channel " + (string)iChan + "; sSoundSet " + sSoundSet + "; kId " + (string)kId);
		MasterCommand(iChan, sSoundSet);

		string sScriptName = GroupCheck(kId);
		if ("exit" == sScriptName) return;
		if (iChan != SOUND_CHANNEL || !g_iSound || !g_iSoundAvail || (llSubStringIndex(llToLower(sScriptName), g_sType) >= 0)) return; // scripts need to have that identifier in their name, so that we can discard those messages

		list lParams = llParseString2List(sSoundSet, [","], []);
				string sVal = llList2String(lParams, 0);
				string sMsg = llList2String(lParams, 1);
		Debug("no changes? background? "+sVal+"-"+sMsg+"...g_fSoundVolumeCur="+(string)g_fSoundVolumeCur+"-g_sSize="+g_sSize);
		if (((float)sVal == g_fSoundVolumeCur && (sMsg == g_sSize || "" == sMsg)) || "-1" == sMsg) return; // -1 for background sound script
		Debug("work on link_message");

		g_fSoundVolumeNew = (float)sVal;
		//change sound while sound is off
		if (0 == g_fSoundVolumeNew && sMsg != g_sSize && "" != sMsg && "0" != sMsg) {
			if (g_iSoundNFilesAvail > 1) SelectStuff((float)sMsg);
			llPreloadSound(g_sCurrentSoundFile);
			Debug("change while off");
			return;
		}

		llSetTimerEvent(0.0);
		if (g_fSoundVolumeNew > 0 && g_fSoundVolumeNew <= 1) {
			if ("" == sMsg || sMsg == g_sSize) {
				if (g_fSoundVolumeCur > 0) {
					llAdjustSoundVolume(g_fSoundVolumeNew);
					if (g_iVerbose) llWhisper(0, "(v) Sound range for fire has changed");
				} else {
					llPreloadSound(g_sCurrentSoundFile);
					llSleep(2.0); // give fire some time to start before making noise
					llLoopSound(g_sCurrentSoundFile, g_fSoundVolumeNew);
					if (g_iVerbose) llWhisper(0, "(v) The fire starts to make some noise");
				}
			} else {

				string sCurrentSoundFileTemp = g_sCurrentSoundFile;
				if (g_iSoundNFilesAvail > 1) SelectStuff((float)sMsg);

				if (g_sCurrentSoundFile == sCurrentSoundFileTemp) {
					llAdjustSoundVolume(g_fSoundVolumeNew); // fire size changed - but still same soundsample
					if (g_iVerbose) llWhisper(0, "(v) Sound range for fire has changed");
				} else {
					if (g_iVerbose && "0" != g_sSize) llWhisper(0, "(v) The fire changes it's sound");
					Debug("play sound: "+g_sCurrentSoundFile);
					llPreloadSound(g_sCurrentSoundFile);
					llStopSound();
					llLoopSound(g_sCurrentSoundFile, g_fSoundVolumeNew);
				}
			}
			g_fSoundVolumeCur = g_fSoundVolumeNew;
		} else llSetTimerEvent(1.2);
	}


	timer()
	{
		llStopSound();
		if (g_iVerbose) llWhisper(0, "(v) Noise from fire ended");
		g_fSoundVolumeNew =g_fSoundVolumeCur = 0.0;
		//g_sSize = "0";
		llSetTimerEvent(0.0);
	}

//-----------------------------------------------
//END STATE: default
//-----------------------------------------------
}
