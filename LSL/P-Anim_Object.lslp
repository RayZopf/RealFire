///////////////////////////////////////////////////////////////////////////////////////////////////
//PrimFire rezzed object script
// by Zopf Resident - Ray Zopf (Raz)
//
//01. Feb. 2014
//v0.2
//

//Files:
// P-Anim_Object.lsl
//
// Fire.lsl
// P-Anim.lsl
// config
// User Manual
//
//
//Prequisites: Fireobjects need to be in same prim as P-Anim.lsl
//Notecard format: see config NC
//basic help: User Manual
//
//Changelog
//

//FIXME: ---

//TODO: additional script to animate/change fire prim textures
//TODO: fire objects need to be phantom... maybe make them flexiprim too
//TODO: sound + message on touch_start (sound, danger message), touch (hot message) and touch_end (menu + burns message)
///////////////////////////////////////////////////////////////////////////////////////////////////


//===============================================
//GLOBAL VARIABLES
//===============================================

//debug variables
//-----------------------------------------------
integer g_iDebugMode=FALSE; // set to TRUE to enable Debug messages


//user changeable variables
//-----------------------------------------------
//integer g_iVerbose = TRUE;

//string LINKSETID = "RealFire"; // to be compared to first word in prim description - only listen to link-messages from prims that have this id;


//internal variables
//-----------------------------------------------
//string g_sTitle = "RealPrimFire-Object";     // title
//string g_sVersion = "0.2";       // version
string g_sScriptName;
integer g_iType = LINK_SET;

integer g_iLowprim = FALSE;
key g_kOwner;                      // object owner

//RealFire MESSAGE MAP
//integer PRIMCOMMAND_CHANNEL = kill fire prims or make temp prims


//===============================================
//LSLForge MODULES
//===============================================
$import RealFireMessageMap.lslm();
$import Debug.lslm(m_iDebugMode=g_iDebugMode, m_sScriptName=g_sScriptName);


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

/*SelectPrimFire(float fMsg)
{
	Debug("SelectPrimFire: "+(string)fMsg);
	if (fMsg <= 25) {
			g_sCurrentPrimFireFile = g_sPrimFireFileSmall;
	} else if (fMsg > 25 && fMsg <= 50) {
		g_sCurrentPrimFireFile = g_sPrimFireFileMedium1;
	} else if (fMsg > 50 && fMsg < 80) {
			g_sCurrentPrimFireFile = g_sPrimFireFileMedium1;
	} else if (fMsg >= 80 && fMsg <= 100) {
			g_sCurrentPrimFireFile = g_sPrimFireFileFull;
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
	g_sSize = (string)fMsg;
}*/


//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default
{
	state_entry()
	{
		g_kOwner = llGetOwner();
		//g_sScriptName = llGetScriptName();
		Debug("state_entry");
		//!make permanent on state_entry, so that object does not get deleted after putting the script in a prim!
		llSetPrimitiveParams([PRIM_TEMP_ON_REZ, FALSE,
			PRIM_PHANTOM, TRUE]);
		llListen(PRIMCOMMAND_CHANNEL, "", NULL_KEY, "");
		llOwnerSay("Wait, if you want to make object temp - else react within next 10 seconds");
		llSleep(10.0); //gives you some time to react
		//Makes the object temporary so the whole 0 prim part works
		llSetPrimitiveParams([PRIM_TEMP_ON_REZ, TRUE]);
		g_iLowprim = TRUE;
		llOwnerSay("Now, object is temp and will vanish shortly");
	}

	/*changed(integer change)
	{
		if (change & CHANGED_OWNER) {
			llResetScript();
	}
	}*/

	on_rez(integer start_param)
	{
		Debug("on_rez: " +(string)start_param);
		if (0 == start_param) {
			llSetLinkPrimitiveParamsFast(g_iType, [PRIM_TEMP_ON_REZ, FALSE]); //make it permanent if not rezzed/attached by avi - do not use "0" as llRezObject start param
			integer g_iLowprim = TRUE;
		}
		g_kOwner = llGetOwner();
	}

//listen for messages from PrimFire script
//-----------------------------------------------
	listen(integer iChan, string name, key kId, string sSet)
	{
		Debug("listen: "+sSet);
		// Security - check the object belongs to our owner, not using llListen - filter, as we have state_entry and on_rez events
		if (llGetOwnerKey(kId) != g_kOwner) return;
		if ("toggle" == sSet) {
			g_iLowprim = !g_iLowprim;
			Debug("listen - toggle:" + (string)g_iLowprim);
			if (g_iLowprim) llSetLinkPrimitiveParamsFast(g_iType, [PRIM_TEMP_ON_REZ, TRUE]);
				else llSetLinkPrimitiveParamsFast(g_iType, [PRIM_TEMP_ON_REZ, FALSE]);
			} else if ("die" == sSet) llDie();
//else if ((integer)sVal > 0 && 100 >= (integer)sVal) {
//	SelectPrimFire((float)sVal);
//}
	}

//-----------------------------------------------
//END STATE: default
//-----------------------------------------------
}
