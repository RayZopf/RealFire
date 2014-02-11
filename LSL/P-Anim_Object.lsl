// LSL script generated: RealFire-Rene10957.LSL.P-Anim_Object.lslp Tue Feb 11 16:16:26 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//PrimFire rezzed object script
// by Zopf Resident - Ray Zopf (Raz)
//
//11. Feb. 2014
//v0.22
//



integer g_iLowprim = 0;
key g_kOwner;
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


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

/*SelectPrimFire(float fMsg)
{
	if (debug) Debug("SelectPrimFire: "+(string)fMsg, FALSE, FALSE);
	if (fMsg <= 25) {
			g_sCurrentPrimFireFile = g_sPrimFireFileSmall;
	} else if (fMsg > 25 && fMsg <= 50) {
		g_sCurrentPrimFireFile = g_sPrimFireFileMedium1;
	} else if (fMsg > 50 && fMsg < 80) {
			g_sCurrentPrimFireFile = g_sPrimFireFileMedium1;
	} else if (fMsg >= 80 && fMsg <= 100) {
			g_sCurrentPrimFireFile = g_sPrimFireFileFull;
	} else {
		//if (debug) Debug("start if g_fSoundVolumeNew > 0: -"+(string)g_fSoundVolumeNew+"-", FALSE, FALSE);
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


default {

	state_entry() {
        MESSAGE_MAP();
        (g_kOwner = llGetOwner());
        
        llSetPrimitiveParams([4,0,5,1]);
        llListen(PRIMCOMMAND_CHANNEL,"",NULL_KEY,"");
        llOwnerSay("Wait, if you want to make object temp - else react within next 10 seconds");
        llSleep(10.0);
        llSetPrimitiveParams([4,1]);
        (g_iLowprim = 1);
        llOwnerSay("Now, object is temp and will vanish shortly");
    }


	/*changed(integer change)
	{
		if (change & CHANGED_OWNER) {
			llResetScript();
	}
	}*/

	on_rez(integer start_param) {
        
        if ((0 == start_param)) {
            llSetLinkPrimitiveParamsFast(-1,[4,0]);
            integer _g_iLowprim0 = 1;
        }
        (g_kOwner = llGetOwner());
    }


//listen for messages from PrimFire script
//-----------------------------------------------
	listen(integer iChan,string name,key kId,string sSet) {
        
        if ((llGetOwnerKey(kId) != g_kOwner)) return;
        if (("toggle" == sSet)) {
            (g_iLowprim = (!g_iLowprim));
            
            if (g_iLowprim) llSetLinkPrimitiveParamsFast(-1,[4,1]);
            else  llSetLinkPrimitiveParamsFast(-1,[4,0]);
        }
        else  if (("die" == sSet)) llDie();
    }
}
