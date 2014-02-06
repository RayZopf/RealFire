///////////////////////////////////////////////////////////////////////////////////////////////////
//PrimFire Enhancement to Realfire
// by Zopf Resident - Ray Zopf (Raz)
//
//04. Feb. 2014
//v0.14
//
//
// (Realfire by Rene)
// (Author: Rene10957 Resident)
// (v2.2)

//Files:
// P-Anim.lsl
//
// Fire.lsl
// config
// User Manual
//
//
//Prequisites: Fireobjects need to be in same prim as P-Anim.lsl
//Notecard format: see config NC
//basic help: User Manual

//Changelog
//

//FIXME: ---

//TODO: make file check (lists) the other way round: check if every inventory file is member of RealFire file list?
//TODO: create a module sizeSelect, put size class borders into variables and settings notecard
//TODO: selectStuff needs more work - less stages than selectSound in Sound.lsl
//TODO: maybe make them flexiprim too
//TODO: temp prim handling not good
//TODO: listen event + timer to check if fire prim really was created
///////////////////////////////////////////////////////////////////////////////////////////////////



//===============================================
//GLOBAL VARIABLES
//===============================================

//debug variables
//-----------------------------------------------
integer g_iDebugMode=FALSE; // set to TRUE to enable Debug messages


//user changeable variables
//-----------------------------------------------
integer g_iPrimFire = TRUE; // Sound on/off in this prim
integer g_iVerbose = TRUE;

//string g_sPrimFireFileStart = "75145__willc2-45220__struck-match-8b-22k-1-65s";   // starting fire (somehow special sound!)
string g_sPrimFireFileSmall = "Fire_small";            // for small fire
vector g_vOffsetSmall = <0.0, 0.0, 0.0>;
string g_sPrimFireFileMedium1 = "Fire_medium";    // for medium fire
vector g_vOffsetMedium1 = <0.0, 0.0, 0.0>;
//string g_sPrimFireFileMedium2 = "104957__glaneur-de-sons__petit-feu-little-fire-1";    // second sound for medium fire
string g_sPrimFireFileFull = "Fire_full";                   // for big fire
vector g_vOffsetFull = <0.0, 0.0, 0.0>;

integer g_iPrimFireNFiles = 3;
//starting sound has to be first in list
list g_lPrimFireFileList = [g_sPrimFireFileSmall, g_sPrimFireFileMedium1, g_sPrimFireFileFull];
string g_sCurrentPrimFireFile = g_sPrimFireFileMedium1; // standard

float g_fAltitude = 1.0; // height for rezzed prim

string LINKSETID = "RealFire"; // to be compared to first word in prim description - only listen to link-messages from prims that have this id;


//internal variables
//-----------------------------------------------
string g_sTitle = "RealPrimFire";     // title
string g_sVersion = "0.14";       // version
string g_sAuthors = "Zopf";

string g_sType = "anim";
integer g_iType = LINK_SET;

integer g_iPrimFireAvail = FALSE;
integer g_iInvType = INVENTORY_OBJECT;
//integer g_iPrimFireFileStartAvail = TRUE;
integer g_iPrimFireNFilesAvail;
integer g_iLowprim = FALSE;
integer g_iPermCheck = TRUE;
string g_sSize = "0";
vector g_vOffset;

//RealFire MESSAGE MAP
//integer COMMAND_CHANNEL =
//integer ANIM_CHANNEL = primfire/textureanim channel
//integer PRIMCOMMAND_CHANNEL = kill fire prims or make temp prims


//===============================================
//LSLForge MODULES
//===============================================
$import RealFireMessageMap.lslm();
$import Debug.lslm(m_iDebugMode=g_iDebugMode, m_sScriptName=g_sScriptName);
$import PrintStatusInfo.lslm(m_iVerbose=g_iVerbose, m_iAvail=g_iPrimFireAvail, m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_iOn=g_iPrimFire, m_sVersion=g_sVersion, m_sAuthors=g_sAuthors);
$import ExtensionBasics.lslm(m_iDebug=g_iDebugMode, m_sGroup=LINKSETID, m_iEnabled=g_iPrimFire, m_iAvail=g_iPrimFireAvail, m_iChannel=ANIM_CHANNEL, m_sScriptName=g_sScriptName, m_iLinkType=g_iType, m_iVerbose=g_iVerbose, m_sTitle=g_sTitle, m_sScriptName=g_sScriptName, m_sVersion=g_sVersion, m_sAuthors=g_sAuthors);
$import GroupHandling.lslm(m_sGroup=LINKSETID);
$import CheckForFiles.lslm(m_iDebugMode=g_iDebugMode, m_sScriptName=g_sScriptName, m_iInvType=g_iInvType, m_iFileStartAvail=g_iPrimFireAvail, m_sTitle=g_sTitle, m_iNFilesAvail=g_iPrimFireNFilesAvail, m_iAvail=g_iPrimFireAvail);


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

selectStuff(float fVal)
{
	Debug("selectStuff: "+(string)fVal);
	if (fVal <= SIZE_SMALL) {
		g_sCurrentPrimFireFile = g_sPrimFireFileSmall;
		g_vOffset = <g_vOffsetSmall.x, g_vOffsetSmall.y, g_vOffsetSmall.z+g_fAltitude>;
	} else if (fVal > SIZE_SMALL && fVal < SIZE_MEDIUM) {
		g_sCurrentPrimFireFile = g_sPrimFireFileMedium1;
		g_vOffset = <g_vOffsetMedium1.x, g_vOffsetMedium1.y, g_vOffsetMedium1.z+g_fAltitude>;
	} else if (fVal >= SIZE_MEDIUM && fVal < SIZE_LARGE) {
		g_sCurrentPrimFireFile = g_sPrimFireFileMedium1;
		g_vOffset = <g_vOffsetMedium1.x, g_vOffsetMedium1.y, g_vOffsetMedium1.z+g_fAltitude>;
	} else if (fVal >= SIZE_LARGE && fVal <= 100) {
		g_sCurrentPrimFireFile = g_sPrimFireFileFull;
		g_vOffset = <g_vOffsetFull.x, g_vOffsetFull.y, g_vOffsetFull.z+g_fAltitude>;
	} else {
		//Debug("start if g_fSoundVolumeNew > 0: -"+(string)g_fSoundVolumeNew+"-");
		//if (g_fSoundVolumeNew > 0 && TRUE == g_iSoundFileStartAvail) {
		//	integer n;
		//	for (n = 0; n < 3; ++n) { //let sound appear louder
		//		llTriggerSound(g_sSoundFileStart, g_fSoundVolumeNew); //preloaded on touch
		//	}
		// to let the sound play additionally to looping ones and without getting stoped
		//}
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
			g_sScriptName = llGetScriptName();
			Debug("state_entry");
			llSay(PRIMCOMMAND_CHANNEL, "die");
			g_sCurrentPrimFireFile = CheckForFiles(g_iPrimFireNFiles, g_lPrimFireFileList, g_iPermCheck, g_sCurrentPrimFireFile);
			llSleep(1);
			RegisterExtension(g_iType);
			InfoLines(TRUE);
		}

		on_rez(integer start_param)
		{
			llResetScript();
		}

	changed(integer change)
	{
		if (change & CHANGED_INVENTORY) {
			llWhisper(0, "Inventory changed, checking objects...");
			llSay(PRIMCOMMAND_CHANNEL, "die");
			g_sCurrentPrimFireFile = CheckForFiles(g_iPrimFireNFiles, g_lPrimFireFileList, g_iPermCheck, g_sCurrentPrimFireFile);
			llSleep(1);
			RegisterExtension(g_iType);
			InfoLines(TRUE);
		}
	}


//listen for linked messages from Fire (main) script
//-----------------------------------------------
	link_message(integer iSender, integer iChan, string sSet, key kId)
	{
		Debug("link_message = channel " + (string)iChan + "; sSet " + sSet + "; kId " + (string)kId);
		MasterCommand(iChan, sSet);

		string sScriptName = GroupCheck(kId);
		if ("exit" == sScriptName) return;
		if (iChan != ANIM_CHANNEL || !g_iPrimFire || !g_iPrimFireAvail || (llSubStringIndex(llToLower(sScriptName), g_sType) >= 0)) return; // scripts need to have that identifier in their name, so that we can discard those messages

		list lParams = llParseString2List(sSet, [SEPARATOR], []);
		string sVal = llList2String(lParams, 0);
		string sMsg = llList2String(lParams, 1);
		//Debug("no changes? background? "+sVal+"-"+sMsg+"...g_fSoundVolumeCur="+(string)g_fSoundVolumeCur+"-g_sSize="+g_sSize);
		Debug("work on link_message");

		if (sVal != g_sSize || (integer)sMsg != g_iLowprim) {
			if (sVal == g_sSize && ("0" == sMsg || "1" == sMsg)) {
				llSetTimerEvent(0.0);
				g_iLowprim = !g_iLowprim;
				llSay(PRIMCOMMAND_CHANNEL, "toggle");
				if (g_iLowprim) state temprez;
				return; //should not happen - as for temp prim, script should allready be in state temprez
			}
		} else return;

		if ((integer)sVal > 0 && 100 >= (integer)sVal) {
			llSetTimerEvent(0.0);
			if ((integer)sMsg != g_iLowprim && ("0" == sMsg || "1" == sMsg)) g_iLowprim = !g_iLowprim;
			string sCurrentPrimFireFileTemp = g_sCurrentPrimFireFile;
			string g_sSizeTemp = g_sSize;
			if (g_iPrimFireNFilesAvail > 1) selectStuff((float)sVal);

			if ("0" == g_sSizeTemp) {
				llSleep(2.0); // let fire slowly begin (not counting on lag when rezzing)
				llRezObject(g_sCurrentPrimFireFile, llGetPos()+g_vOffset,ZERO_VECTOR,ZERO_ROTATION,1);
				if (!g_iLowprim) {
					llSleep(3.0);
					llSay(PRIMCOMMAND_CHANNEL, "toggle");
					llSay(PRIMCOMMAND_CHANNEL, sVal); //make sure texture animation is correct
				}
			} else {
					if (g_sCurrentPrimFireFile != sCurrentPrimFireFileTemp) {
						llSay(PRIMCOMMAND_CHANNEL, "die");
						llRezObject(g_sCurrentPrimFireFile, llGetPos()+g_vOffset,ZERO_VECTOR,ZERO_ROTATION,1);
						if (!g_iLowprim) {
							llSleep(3.0);
							llSay(PRIMCOMMAND_CHANNEL, "toggle");
						}
					} else llSay(PRIMCOMMAND_CHANNEL, sVal); //texture animation change
				}
			if (g_iLowprim) state temprez;
		} else llSetTimerEvent(1.0);
	}


	timer()
	{
		llSay(PRIMCOMMAND_CHANNEL, "die");
		if (g_iVerbose) llWhisper(0, "(v) Prim fire effects ended");
		g_sSize = "0";
		llSetTimerEvent(0.0);
	}

//-----------------------------------------------
//END STATE: default
//-----------------------------------------------
}



state temprez
{
	state_entry()
	{
		//llMessage - "temp"
		state default; //so that scripts runs, even if temp rez is not done
		llSetTimerEvent(0.0);
	}

//listen for linked messages from Fire (main) script
//-----------------------------------------------
		//link_message(integer iSender, integer iChan, string sSet, key kId)


	timer()
	{
		llRezObject(g_sCurrentPrimFireFile, llGetPos()+g_vOffset,ZERO_VECTOR,ZERO_ROTATION,1);
	}

//-----------------------------------------------
//END STATE: temprez
//-----------------------------------------------
}
