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
integer g_iSound;         // Sound on/off in this prim

string g_sSoundFileStart = "75145__willc2-45220__struck-match-8b-22k-1-65s";     // starting fire (somehow special sound!)
string g_sSoundFileSmall = "17742__krisboruff__fire-crackles-no-room_med";           // sound for small fire
string g_sSoundFileMedium1 = "104958__glaneur-de-sons__petit-feu-little-fire-2_loud"; // first sound for medium fire (yes, file fire-2)
string g_sSoundFileMedium2 = "104957__glaneur-de-sons__petit-feu-little-fire-1_loud"; // second sound for medium fire
string g_sSoundFileFull = "4211__dobroide__fire-crackling_loud";                      // standard sound, sound for big fire

integer g_iSoundNFiles;
//starting sound has to be first in list
list g_lSoundFileList = [g_sSoundFileStart, g_sSoundFileSmall, g_sSoundFileMedium1, g_sSoundFileMedium2, g_sSoundFileFull];
string g_sCurrentSoundFile = g_sSoundFileMedium2; // standard sound - must not be sound for starting fire!

string LINKSETID = "RealFire"; // to be compared to first word in prim description - only listen to link-messages from prims that have this id;


//internal variables
//-----------------------------------------------
string g_sTitle = "RealSound";     // title
string g_sVersion = "0.88";       // version
string g_sAuthors = "Zopf";

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


//===============================================
//LSLForge MODULES
//===============================================
$import Debug2.lslm(m_sScriptName=g_sScriptName);
$import MemoryManagement.lslm(m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_iVerbose=g_iVerbose);
$import RealFireMessageMap.lslm();
$import PrintStatusInfo.lslm(m_iAvail=g_iSoundAvail, m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_iEnabled=g_iSound, m_sVersion=g_sVersion, m_sAuthors=g_sAuthors);
$import ExtensionBasics.lslm(m_sGroup=LINKSETID, m_iSingle=g_iSingleSound, m_iEnabled=g_iSound, m_iAvail=g_iSoundAvail, m_iChannel=SOUND_CHANNEL, m_sScriptName=g_sScriptName, m_iLinkType=g_iType, m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_sVersion=g_sVersion, m_sAuthors=g_sAuthors);
$import GroupHandling.lslm(m_sGroup=LINKSETID);
$import CheckForFiles.lslm(m_sScriptName=g_sScriptName, m_iInvType=g_iInvType, m_iFileStartAvail=g_iSoundFileStartAvail, m_sTitle=g_sTitle, m_iNFilesAvail=g_iSoundNFilesAvail, m_iAvail=g_iSoundAvail);


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

// pragma inline
initExtension()
{
	llStopSound();
	g_sCurrentSoundFile = CheckForFiles(g_iSoundNFiles, g_lSoundFileList, g_iPermCheck, g_sCurrentSoundFile);
	llSleep(1);
	RegisterExtension(g_iType);
	InfoLines(TRUE);
}


selectStuff(float fVal)
{
	if (debug) Debug("selectStuff: "+(string)fVal, FALSE, FALSE);
	if (fVal <= SIZE_SMALL) {
		g_sCurrentSoundFile = g_sSoundFileSmall;
	} else if (fVal > SIZE_SMALL && fVal < SIZE_MEDIUM) {
		g_sCurrentSoundFile = g_sSoundFileMedium1;
	} else if (fVal >= SIZE_MEDIUM && fVal < SIZE_LARGE) {
		g_sCurrentSoundFile = g_sSoundFileMedium2;
	} else if (fVal >= SIZE_LARGE && fVal <= 100) {
		g_sCurrentSoundFile = g_sSoundFileFull;
	} else {
		if (debug) Debug("start if g_fSoundVolumeNew > 0: -"+(string)g_fSoundVolumeNew+"-", FALSE ,FALSE);
		if (g_fSoundVolumeNew > 0 && TRUE == g_iSoundFileStartAvail) {
			integer n;
			for (n = 0; n < 3; ++n) { //let sound appear louder
				llTriggerSound(g_sSoundFileStart, g_fSoundVolumeNew); //preloaded on touch
			}
		// to let the sound play additionally to looping ones and without getting stoped
		}
		g_fSoundVolumeNew = 0.0;
		g_sSize = "0";
		return;
	}
	g_sSize = (string)fVal;
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
		//debug=TRUE; // set to TRUE to enable Debug messages
		MESSAGE_MAP();
		g_iSound = TRUE;
		g_iSoundNFiles = 5;

		MemRestrict(32000);
		g_sScriptName = llGetScriptName();
		if (debug) Debug("state_entry", TRUE, FALSE);
		initExtension();
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
			if (!silent) llWhisper(PUBLIC_CHANNEL, "Inventory changed, checking sound samples...");
			initExtension();
		}
	}


//listen for linked messages from Fire (main) script
//-----------------------------------------------
	link_message(integer iSender, integer iChan, string sSoundSet, key kId)
	{
		if (debug) Debug("link_message = channel " + (string)iChan + "; sSoundSet " + sSoundSet + "; kId " + (string)kId, FALSE ,FALSE);
		string sConfig = MasterCommand(iChan, sSoundSet, FALSE);

		string sScriptName = GroupCheck(kId);
		if ("exit" == sScriptName) return;
		if (iChan != SOUND_CHANNEL || !g_iSound || !g_iSoundAvail || (llSubStringIndex(llToLower(sScriptName), g_sType) >= 0)) return; // scripts need to have that identifier in their name, so that we can discard those messages

		list lParams = llParseString2List(sSoundSet, [SEPARATOR], []);
				string sVal = llList2String(lParams, 0);
				string sMsg = llList2String(lParams, 1);
		if (debug) Debug("no changes? background? "+sVal+"-"+sMsg+"...g_fSoundVolumeCur="+(string)g_fSoundVolumeCur+"-g_sSize="+g_sSize, FALSE ,FALSE);
		if (((float)sMsg == g_fSoundVolumeCur && (sVal == g_sSize || "" == sVal)) || "-1" == sVal) return; // -1 for background sound script
		if (debug) Debug("work on link_message", FALSE ,FALSE);

		g_fSoundVolumeNew = (float)sMsg;
		//change sound while sound is muted or off
		if ((0 == g_fSoundVolumeNew && sVal != g_sSize && "" != sVal && "0" != sVal) && "110" != sVal) {
			if (g_iSoundNFilesAvail > 1) selectStuff((float)sVal);
			if (debug) Debug("change while off", FALSE ,FALSE);
			return;
		}

		if ("0" != sVal && (g_fSoundVolumeNew > 0 && g_fSoundVolumeNew <= 1)) {
		llSetTimerEvent(0.0);
			if ("" == sVal || sVal == g_sSize) {
				if (g_fSoundVolumeCur > 0.0) {
					llAdjustSoundVolume(g_fSoundVolumeNew);
					if (!silent && g_iVerbose) llWhisper(PUBLIC_CHANNEL, "(v) Sound range for fire has changed");
				} else {
					llPreloadSound(g_sCurrentSoundFile); // give fire some time to start before making noise
					llStopSound(); // just to be save
					llLoopSound(g_sCurrentSoundFile, g_fSoundVolumeNew);
					if (!silent && g_iVerbose) llWhisper(PUBLIC_CHANNEL, "(v) The fire starts to make noise again");
				}
			} else {

				string sCurrentSoundFileTemp = g_sCurrentSoundFile;
				string sSizeTemp = g_sSize;
				if (g_iSoundNFilesAvail > 1) selectStuff((float)sVal);
				if ("110" == sMsg) return;

				if (g_sCurrentSoundFile == sCurrentSoundFileTemp && "0" != sSizeTemp) {
					llAdjustSoundVolume(g_fSoundVolumeNew); // fire size changed - but still same soundsample
					if (!silent && g_iVerbose) llWhisper(PUBLIC_CHANNEL, "(v) Sound range for fire has changed");
				} else {
					if (g_iVerbose) {
						if (!silent && g_iVerbose &&g_fSoundVolumeCur > 0.0) llWhisper(PUBLIC_CHANNEL, "(v) The fire changes it's sound");
							else if (!silent) llWhisper(PUBLIC_CHANNEL, "(v) The fire starts to make noise");
					}
					if (debug) Debug("play sound: "+g_sCurrentSoundFile, FALSE ,FALSE);
					llPreloadSound(g_sCurrentSoundFile);
					llSleep(1.3); // give fire some time to start before making noise or before changing the sound
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
		if (!silent && g_iVerbose) llWhisper(PUBLIC_CHANNEL, "(v) Noise from fire ended");
		g_fSoundVolumeNew =g_fSoundVolumeCur = 0.0;
		g_sSize = "0";
		llSetTimerEvent(0.0);
	}

//-----------------------------------------------
//END STATE: default
//-----------------------------------------------
}
