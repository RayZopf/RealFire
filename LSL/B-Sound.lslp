///////////////////////////////////////////////////////////////////////////////////////////////////
//Sound Enhancement to Realfire
// by Zopf Resident - Ray Zopf (Raz)
//
//09. Feb. 2014
//v0.49
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
integer g_iSound;			// Sound on/off in this prim

string BACKSOUNDFILE = "17742__krisboruff__fire-crackles-no-room_loud";                   // backroundsound for small fire

string LINKSETID = "RealFire"; // to be compared to first word in prim description - only listen to link-messages from prims that have this id;


//internal variables
//-----------------------------------------------
string g_sTitle = "RealB-Sound";     // title
string g_sVersion = "0.49";       // version
string g_sAuthors = "Zopf";

string g_sType = "sound";
integer g_iType = LINK_SET;

integer g_iSoundAvail = FALSE;
float g_fSoundVolumeCur = 0.0;
float g_fSoundVolumeNew;
string g_sSize = "0";
float g_fFactor;


//===============================================
//LSLForge MODULES
//===============================================
$import RealFireMessageMap.lslm();
$import Debug.lslm(m_iDebugMode=g_iDebugMode, m_sScriptName=g_sScriptName);
$import PrintStatusInfo.lslm(m_iVerbose=g_iVerbose, m_iAvail=g_iSoundAvail, m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_iEnabled=g_iSound, m_sVersion=g_sVersion, m_sAuthors=g_sAuthors);
$import ExtensionBasics.lslm(m_iDebug=g_iDebugMode, m_sGroup=LINKSETID, m_iSingle=g_iSingleSound, m_iEnabled=g_iSound, m_iAvail=g_iSoundAvail, m_iChannel=SOUND_CHANNEL, m_sScriptName=g_sScriptName, m_iLinkType=g_iType, m_iVerbose=g_iVerbose, m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_sVersion=g_sVersion, m_sAuthors=g_sAuthors);
$import GroupHandling.lslm(m_sGroup=LINKSETID);


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

// pragma inline
initExtension()
{
	if (g_iSound) llStopSound();
	checkSoundFiles();
	llSleep(1);
	RegisterExtension(g_iType);
	if (g_iSoundAvail) llPreloadSound(BACKSOUNDFILE);
	InfoLines(TRUE);
}


checkSoundFiles()
{
	integer iSoundNumber = llGetInventoryNumber(INVENTORY_SOUND);
	Debug("Sound number = " +(string)iSoundNumber);
	if ( iSoundNumber > 0) {
		integer i;
		for (i = 0; i < iSoundNumber; ++i) {
			string sSoundName = llGetInventoryName(INVENTORY_SOUND, i);
			if (sSoundName == BACKSOUNDFILE) g_iSoundAvail = TRUE;
		}
	} else g_iSoundAvail = FALSE;
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
		//g_iDebugMode=TRUE; // set to TRUE to enable Debug messages
		MESSAGE_MAP();
		g_iSound=TRUE;

		g_sScriptName = llGetScriptName();
		Debug("state_entry");
		g_fFactor = 7.0 / 8.0;
		llPassTouches(TRUE); //this need review!
		initExtension();
	}

	on_rez(integer start_param)
	{
		llResetScript();
	}

	touch(integer total_number)
	{
		if (g_iSoundAvail && g_iSound) llPreloadSound(BACKSOUNDFILE); //maybe change preloaded soundfile to medium fire sound
		//this also blocks touch events on this child to be passed to root prim!
	}

	changed(integer change)
	{
		if (change & CHANGED_INVENTORY) {
			if (!silent) llWhisper(0, "Inventory changed, checking sound samples...");
			initExtension();
		}
	}


//listen for linked messages from Fire (main) script
//-----------------------------------------------
	link_message(integer iSender, integer iChan, string sSoundSet, key kId)
	{
		Debug("link_message = channel " + (string)iChan + "; sSoundSet " + sSoundSet + "; kId " + (string)kId);
		string sConfig = MasterCommand(iChan, sSoundSet, FALSE);
		if ("" != sConfig) {
//			if (getConfigBSound(sConfig)) initExtension();
		}

		string sScriptName = GroupCheck(kId);
		if ("exit" == sScriptName) return;
		if (iChan != SOUND_CHANNEL || !g_iSound || !g_iSoundAvail || (llSubStringIndex(llToLower(sScriptName), g_sType) >= 0)) return; //scripts need to have that identifier in their name, so that we can discard those messages

		list lParams = llParseString2List(sSoundSet, [SEPARATOR], []);
		string sVal = llList2String(lParams, 0);
		string sMsg = llList2String(lParams, 1);
		Debug("no changes? backround on/off? "+sVal+"-"+sMsg+"...g_fSoundVolumeCur="+(string)g_fSoundVolumeCur+"-g_sSize="+g_sSize);
		if ("110" == sVal || ("0" == sMsg && g_iInTimer)) return; // 110 = Sound.lsl

		llSetTimerEvent(0.0);
		g_iInTimer = FALSE;
		if ((float)sMsg == g_fSoundVolumeCur && (sVal == g_sSize || "" == sVal)) return; //no "backround sound off" currently, 110 = Sound.lsl
		Debug("work on link_message");

		g_fSoundVolumeNew = (float)sMsg;
		if (g_fSoundVolumeNew > 0.0 && g_fSoundVolumeNew <= 1.0) { //background sound on/volume adjust
			Debug("Factor start "+(string)g_fFactor);
			//simple adjustment to different fire sizes (full, at start, when special B_Sound message with sVal = -1)
			if ("-1" == sVal) g_fFactor = 1.0;
				else if ( 0 < (integer)sVal && 100 >= (integer)sVal) {
					if ((integer)sVal <= SIZE_SMALL ) g_fFactor = 4.0 / 5.0;
						else g_fFactor = 6.0 / 7.0;
				} else if ("" != sVal && (integer)g_sSize <= SIZE_SMALL ) g_fFactor = 5.0 / 6.0; //fallback - is this still needed?
					else if ("" != sVal && (integer)g_sSize > SIZE_SMALL && 100 <= (integer)g_sSize) g_fFactor = 5.0 / 6.0;
			Debug("Factor calculated "+(string)g_fFactor);
			float fSoundVolumeF = g_fSoundVolumeNew*g_fFactor;

			if (g_fSoundVolumeCur > 0) { //sound should already run
				Debug("Vol-adjust: "+(string)fSoundVolumeF);
				llAdjustSoundVolume(fSoundVolumeF);
			} else {
				Debug("play sound: "+(string)fSoundVolumeF);
				llPreloadSound(BACKSOUNDFILE);
				llStopSound(); // just in case...
				llLoopSound(BACKSOUNDFILE, fSoundVolumeF);
				if (!silent && g_iVerbose) llWhisper(0, "(v) Fire emits a crackling background sound");
			}
			g_fSoundVolumeCur = g_fSoundVolumeNew;
			if ("" != sVal) g_sSize = sVal;
		} else {
			if (!silent) llWhisper(0, "Background fire noises getting quieter and quieter...");
			g_iInTimer = TRUE;
			llSetTimerEvent(12.0); //wait ... better would be to fade out
		}
	}


	timer()
	{
		llStopSound();
		if (!silent && g_iVerbose) llWhisper(0, "(v) Background noise off");
		g_fSoundVolumeNew = g_fSoundVolumeCur = 0.0;
		g_sSize = "0";
		g_iInTimer = FALSE;
		llSetTimerEvent(0.0);
	}

//-----------------------------------------------
//END STATE: default
//-----------------------------------------------
}