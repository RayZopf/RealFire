// LSL script generated: RealFire-Rene10957.LSL.F-Anim.lslp Mon Feb 10 02:45:20 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//ParticleFire Enhancement to Realfire
// by Zopf Resident - Ray Zopf (Raz)
//
//09. Feb. 2014
//v0.31
//
//
// (Realfire by Rene)
// (Author: Rene10957 Resident)
// (v2.2)

//Files:
// F-Anim.lsl
//
// Fire.lsl
// config
// User Manual
//
//
//Prequisites: Fireobjects need to be in same prim as P-Anim.lsl
//Notecard format: see config NC
//basic help: User Manual
// to use "integer g_iSingleFire = FALSE;      // single fire or multiple fires"
// - put F-Anim.lsl scripts in those prims
// then you may want to play with "integer g_iTextureAnim = TRUE;" and "integer g_iLight = TRUE;"
// and modify "integer g_iTypeXXX = LINK_SET;              // in this case it defines which prim(s) emitts the light and changes texture;"
// values: LINK_THIS (only this prim, if you have more than one particle fire source/script), LINK_SET (all); LINK_ALL_OTHERS, LINK_ROOT LINK_ALL_CHILDREN
// if you want to use a single fire script that is not in the same prim as main Fire.lsl, set singleFire to false in config notecard!

//Changelog
//

//FIXME: on/off via menu sometimes "not working"

//TODO: create a module sizeSelect, put size class borders into variables and settings notecard
///////////////////////////////////////////////////////////////////////////////////////////////////



//===============================================
//GLOBAL VARIABLES
//===============================================

//user changeable variables
//-----------------------------------------------
integer g_iParticleFire;
integer g_iType;
integer g_iTextureAnim;
integer g_iTypeTexture;
integer g_iLight;
integer g_iTypeLight;

string LINKSETID = "RealFire";
vector g_vStartScale = <0.4,2.0,0.0>;
vector g_vEndScale = <0.4,2.0,0.0>;
vector g_vPartAccel = <0.0,0.0,10.0>;
vector g_vStartColor = <1.0,1.0,0.0>;
vector g_vEndColor = <1.0,0.0,0.0>;

//internal variables
//-----------------------------------------------
string g_sTitle = "RealParticleFire";
string g_sVersion = "0.31";
string g_sAuthors = "Zopf";

string g_sType = "anim";

integer g_iParticleFireAvail = 1;

string g_sSize = "0";

// Variables
vector g_vLightColor;
float g_fLightIntensity;
float g_fLightRadius;
float g_fLightFalloff;
float g_fStartIntensity;
float g_fStartRadius;
integer g_iVerbose = 1;
string g_sMainScript = "Fire.lsl";
string g_sScriptName;
integer silent = 0;
integer g_iChangeLight = 1;
integer g_iSingleFire = 1;
vector g_vDefStartColor = <100.0,100.0,0.0>;
vector g_vDefEndColor = <100.0,0.0,0.0>;
integer g_iDefIntensity = 100;
integer g_iDefRadius = 50;
integer g_iDefFalloff = 40;
integer g_iPerRedStart;
integer g_iPerGreenStart;
integer g_iPerBlueStart;
integer g_iPerRedEnd;
integer g_iPerGreenEnd;
integer g_iPerBlueEnd;
integer g_iInTimer = 0;
string SEPARATOR = ";;";
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


//###
//GenericFunctions.lslm
//0.22 - 09Feb2014

// pragma noinlining
integer checkInt(string par,integer val,integer min,integer max){
    if (((val < min) || (val > max))) {
        if ((val < min)) (val = min);
        else  if ((val > max)) (val = max);
        llWhisper(0,((par + " out of range, corrected to ") + ((string)val)));
    }
    return val;
}


// pragma noinlining
integer min(integer x,integer y){
    if ((x < y)) return x;
    else  return y;
}


// pragma noinlining
integer max(integer x,integer y){
    if ((x > y)) return x;
    else  return y;
}


 integer getConfigParticleFire(string sVal){
    list lConfigs = llParseString2List(sVal,["config","=",SEPARATOR],[]);
    integer n = llGetListLength(lConfigs);
    integer count = 0;
    string par;
    
    if (((n > 1) && (0 == (n % 2)))) {
        string val;
        do  {
            (par = llList2String(lConfigs,count));
            (val = llList2String(lConfigs,(count + 1)));
            if ((par == "changelight")) (g_iChangeLight = ((integer)val));
            else  if (("singlefire" == par)) (g_iSingleFire = ((integer)val));
            else  if ((par == "topcolor")) (g_vDefEndColor = ((vector)val));
            else  if ((par == "bottomcolor")) (g_vDefStartColor = ((vector)val));
            else  if ((par == "intensity")) (g_iDefIntensity = ((integer)val));
            else  if ((par == "radius")) (g_iDefRadius = ((integer)val));
            else  if ((par == "falloff")) (g_iDefFalloff = ((integer)val));
            else  if (("startcolor" == par)) {
                {
                    if ((val == "-Red")) (g_iPerRedStart = max((g_iPerRedStart - 10),0));
                    else  if ((val == "-Green")) (g_iPerGreenStart = max((g_iPerGreenStart - 10),0));
                    else  if ((val == "-Blue")) (g_iPerBlueStart = max((g_iPerBlueStart - 10),0));
                    else  if ((val == "+Red")) (g_iPerRedStart = min((g_iPerRedStart + 10),100));
                    else  if ((val == "+Green")) (g_iPerGreenStart = min((g_iPerGreenStart + 10),100));
                    else  if ((val == "+Blue")) (g_iPerBlueStart = min((g_iPerBlueStart + 10),100));
                    else  if ((val == "R min/max")) {
                        if (g_iPerRedStart) (g_iPerRedStart = 0);
                        else  (g_iPerRedStart = 100);
                    }
                    else  if ((val == "G min/max")) {
                        if (g_iPerGreenStart) (g_iPerGreenStart = 0);
                        else  (g_iPerGreenStart = 100);
                    }
                    else  if ((val == "B min/max")) {
                        if (g_iPerBlueStart) (g_iPerBlueStart = 0);
                        else  (g_iPerBlueStart = 100);
                    }
                    else  if ((val == "One color")) {
                        (g_iPerRedEnd = g_iPerRedStart);
                        (g_iPerGreenEnd = g_iPerGreenStart);
                        (g_iPerBlueEnd = g_iPerBlueStart);
                    }
                }
                if ((2 == n)) return 2;
            }
            else  if (("endcolor" == par)) {
                {
                    if ((val == "-Red")) (g_iPerRedEnd = max((g_iPerRedEnd - 10),0));
                    else  if ((val == "-Green")) (g_iPerGreenEnd = max((g_iPerGreenEnd - 10),0));
                    else  if ((val == "-Blue")) (g_iPerBlueEnd = max((g_iPerBlueEnd - 10),0));
                    else  if ((val == "+Red")) (g_iPerRedEnd = min((g_iPerRedEnd + 10),100));
                    else  if ((val == "+Green")) (g_iPerGreenEnd = min((g_iPerGreenEnd + 10),100));
                    else  if ((val == "+Blue")) (g_iPerBlueEnd = min((g_iPerBlueEnd + 10),100));
                    else  if ((val == "R min/max")) {
                        if (g_iPerRedEnd) (g_iPerRedEnd = 0);
                        else  (g_iPerRedEnd = 100);
                    }
                    else  if ((val == "G min/max")) {
                        if (g_iPerGreenEnd) (g_iPerGreenEnd = 0);
                        else  (g_iPerGreenEnd = 100);
                    }
                    else  if ((val == "B min/max")) {
                        if (g_iPerBlueEnd) (g_iPerBlueEnd = 0);
                        else  (g_iPerBlueEnd = 100);
                    }
                    else  if ((val == "One color")) {
                        (g_iPerRedStart = g_iPerRedEnd);
                        (g_iPerGreenStart = g_iPerGreenEnd);
                        (g_iPerBlueStart = g_iPerBlueEnd);
                    }
                }
                if ((2 == n)) return 2;
            }
            (count = (count + 2));
        }
        while ((count <= n));
    }
    else  {
        if ((1 == n)) {
            (par = llList2String(lConfigs,count));
            if (("reset" == par)) {
                (g_iPerRedStart = ((integer)g_vDefStartColor.x));
                (g_iPerGreenStart = ((integer)g_vDefStartColor.y));
                (g_iPerBlueStart = ((integer)g_vDefStartColor.z));
                (g_iPerRedEnd = ((integer)g_vDefEndColor.x));
                (g_iPerGreenEnd = ((integer)g_vDefEndColor.y));
                (g_iPerBlueEnd = ((integer)g_vDefEndColor.z));
            }
        }
        return 0;
    }
    return 1;
}


//===============================================
//PREDEFINED FUNCTIONS
//===============================================

initExtension(integer bool){
    if (g_iParticleFire) {
        llParticleSystem([]);
        if (g_iTextureAnim) llSetLinkTextureAnim(g_iTypeTexture,0,-1,4,4,0,0,1);
        if (g_iLight) llSetLinkPrimitiveParamsFast(g_iTypeLight,[23,0,ZERO_VECTOR,0,0,0]);
    }
    (g_vDefStartColor.x = checkInt("ColorOn (RED)",((integer)g_vDefStartColor.x),0,100));
    (g_vDefStartColor.y = checkInt("ColorOn (GREEN)",((integer)g_vDefStartColor.y),0,100));
    (g_vDefStartColor.z = checkInt("ColorOn (BLUE)",((integer)g_vDefStartColor.z),0,100));
    (g_vDefEndColor.x = checkInt("ColorOff (RED)",((integer)g_vDefEndColor.x),0,100));
    (g_vDefEndColor.y = checkInt("ColorOff (GREEN)",((integer)g_vDefEndColor.y),0,100));
    (g_vDefEndColor.z = checkInt("ColorOff (BLUE)",((integer)g_vDefEndColor.z),0,100));
    float per = g_iDefIntensity;
    float num = 1.0;
    (g_fStartIntensity = ((num / 100.0) * per));
    float _per4 = g_iDefRadius;
    float _num5 = 20.0;
    (g_fStartRadius = ((_num5 / 100.0) * _per4));
    float _per8 = g_iDefFalloff;
    float _num9 = 2.0;
    (g_fLightFalloff = ((_num9 / 100.0) * _per8));
    llSleep(1);
    if (bool) {
        integer link = g_iType;
        if (g_iParticleFire) {
            if ((g_iSingleFire && (-1 == llGetInventoryType(g_sMainScript)))) {
                (g_iParticleFireAvail = 0);
                jump _end10;
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
            if (g_iParticleFireAvail) llMessageLinked(link,PARTICLE_CHANNEL,"1",((key)sId));
            else  if (g_iSingleFire) llMessageLinked(link,PARTICLE_CHANNEL,"0",((key)sId));
        }
        @_end10;
    }
    if ((g_iVerbose && 0)) {
        if (g_iParticleFireAvail) {
            if ((!silent)) llWhisper(0,(("(v) " + g_sTitle) + " - File(s) found in inventory: Yes"));
        }
        else  llWhisper(0,(((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
    }
    if (g_iParticleFire) {
        if (g_iParticleFireAvail) {
            if ((!silent)) llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + "\t ready"));
        }
        else  llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " not ready"));
    }
    else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " script disabled"));
    if (((!silent) && g_iVerbose)) llWhisper(0,((((("\n\t- free memory: " + ((string)llGetFreeMemory())) + " -\n(v) ") + g_sTitle) + "/") + g_sScriptName));
}


//most important function
//-----------------------------------------------
updateSize(float size){
    vector vStart;
    vector vEnd;
    float fMin;
    float fMax;
    float fRadius;
    vector vPush;
    (vEnd = ((g_vEndScale / 100.0) * size));
    (fMin = (0.0 * size));
    (fMax = (4.0e-4 * size));
    (vPush = ((g_vPartAccel / 100.0) * size));
    if ((size > 25.0)) {
        (vStart = ((g_vStartScale / 100.0) * size));
        (fRadius = (4.0e-3 * size));
        if (g_iTextureAnim) {
            if ((size >= 80.0)) llSetLinkTextureAnim(g_iTypeTexture,3,-1,4,4,0,0,9);
            else  if ((size >= 50.0)) llSetLinkTextureAnim(g_iTypeTexture,3,-1,4,4,0,0,6);
            else  llSetLinkTextureAnim(g_iTypeTexture,3,-1,4,4,0,0,4);
        }
    }
    else  {
        if (g_iTextureAnim) {
            if ((size >= 15.0)) llSetLinkTextureAnim(g_iTypeTexture,3,-1,4,4,0,0,3);
            else  llSetLinkTextureAnim(g_iTypeTexture,3,-1,4,4,0,0,1);
        }
        (vStart = (g_vStartScale / 4.0));
        (fRadius = 0.1);
        if ((size < 5.0)) {
            (vStart.y = ((2.0e-2 * size) * 5.0));
            if ((vStart.y < 0.25)) (vStart.y = 0.25);
        }
        if (g_iLight) {
            if (g_iChangeLight) {
                float num = g_fStartIntensity;
                (g_fLightIntensity = ((num / 100.0) * (size * 4.0)));
                float _num4 = g_fStartRadius;
                (g_fLightRadius = ((_num4 / 100.0) * (size * 4.0)));
            }
            else  {
                (g_fLightIntensity = g_fStartIntensity);
                (g_fLightRadius = g_fStartRadius);
            }
        }
    }
    float per = ((float)g_iPerRedStart);
    float _num6 = 1.0;
    (g_vStartColor.x = ((_num6 / 100.0) * per));
    float _per4 = ((float)g_iPerGreenStart);
    float _num5 = 1.0;
    (g_vStartColor.y = ((_num5 / 100.0) * _per4));
    float _per8 = ((float)g_iPerBlueStart);
    float _num9 = 1.0;
    (g_vStartColor.z = ((_num9 / 100.0) * _per8));
    float _per12 = ((float)g_iPerRedEnd);
    float _num13 = 1.0;
    (g_vEndColor.x = ((_num13 / 100.0) * _per12));
    float _per16 = ((float)g_iPerGreenEnd);
    float _num17 = 1.0;
    (g_vEndColor.y = ((_num17 / 100.0) * _per16));
    float _per20 = ((float)g_iPerBlueEnd);
    float _num21 = 1.0;
    (g_vEndColor.z = ((_num21 / 100.0) * _per20));
    (g_vLightColor = ((g_vStartColor + g_vEndColor) / 2.0));
    llSleep(0.8);
    llParticleSystem([0,259,9,2,16,fRadius,1,g_vStartColor,3,g_vEndColor,2,1.0,4,0.0,5,vStart,6,vEnd,7,1.0,13,0.1,15,10,8,vPush,17,fMin,18,fMax]);
    if (g_iLight) llSetLinkPrimitiveParamsFast(g_iTypeLight,[23,1,g_vLightColor,g_fLightIntensity,g_fLightRadius,g_fLightFalloff]);
    
}


specialFire(){
    
    llParticleSystem([0,259,9,2,16,0.148438,1,<0.74902,0.6,0.14902>,3,<1.0,0.2,0.0>,2,0.101961,4,7.05882e-2,5,<0.59375,0.59375,0.0>,6,<9.375e-2,9.375e-2,0.0>,12,((key)"23d133ad-c669-18a8-02a3-a75baa9b214a"),7,3.0,13,1.0e-2,15,1,8,<0.0,0.0,0.203125>,17,1.95313e-2,18,2.73438e-2]);
}



//===============================================
//===============================================
//MAIN
//===============================================
//===============================================


default {

	state_entry() {
        MESSAGE_MAP();
        (g_iParticleFire = 1);
        (g_iType = -1);
        (g_iTextureAnim = 1);
        (g_iTypeTexture = -1);
        (g_iLight = 1);
        (g_iTypeLight = -1);
        (g_sScriptName = llGetScriptName());
        
        
        initExtension(1);
    }


	on_rez(integer start_param) {
        llResetScript();
    }


	changed(integer change) {
        if ((change & 1)) {
            if ((!silent)) llWhisper(0,"Inventory changed, checking objects...");
            initExtension(1);
        }
    }



//listen for linked messages from Fire (main) script
//-----------------------------------------------
	link_message(integer iSender,integer iChan,string sSet,key kId) {
        
        string _ret1;
        if ((iChan == COMMAND_CHANNEL)) {
            list lValues = llParseString2List(sSet,[SEPARATOR],[]);
            string sCommand = llList2String(lValues,0);
            if (("register" == sCommand)) {
                integer link = g_iType;
                if (g_iParticleFire) {
                    if ((g_iSingleFire && (-1 == llGetInventoryType(g_sMainScript)))) {
                        (g_iParticleFireAvail = 0);
                        jump __end03;
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
                    if (g_iParticleFireAvail) llMessageLinked(link,PARTICLE_CHANNEL,"1",((key)sId));
                    else  if (g_iSingleFire) llMessageLinked(link,PARTICLE_CHANNEL,"0",((key)sId));
                }
                @__end03;
            }
            else  if (("verbose" == sCommand)) {
                (g_iVerbose = 1);
                if ((g_iVerbose && 0)) {
                    if (g_iParticleFireAvail) {
                        if ((!silent)) llWhisper(0,(("(v) " + g_sTitle) + " - File(s) found in inventory: Yes"));
                    }
                    else  llWhisper(0,(((("(v) " + g_sTitle) + "/") + g_sScriptName) + " - Needed files(s) found in inventory: NO"));
                }
                if (g_iParticleFire) {
                    if (g_iParticleFireAvail) {
                        if ((!silent)) llWhisper(0,(((((g_sTitle + " ") + g_sVersion) + " by ") + g_sAuthors) + "\t ready"));
                    }
                    else  llWhisper(0,(((g_sTitle + " ") + g_sVersion) + " not ready"));
                }
                else  llWhisper(0,(((g_sTitle + "/") + g_sScriptName) + " script disabled"));
                if (((!silent) && g_iVerbose)) llWhisper(0,((((("\n\t- free memory: " + ((string)llGetFreeMemory())) + " -\n(v) ") + g_sTitle) + "/") + g_sScriptName));
            }
            else  if (("nonverbose" == sCommand)) (g_iVerbose = 0);
            else  if ((1 && ("config" == sCommand))) {
                (_ret1 = sSet);
                jump _end2;
            }
            else  if (g_iParticleFire) llSetTimerEvent(0.1);
            (_ret1 = "");
            jump _end2;
        }
        (_ret1 = "");
        @_end2;
        string sConfig = _ret1;
        if (("" != sConfig)) {
            integer rc = getConfigParticleFire(sConfig);
            if ((1 == rc)) initExtension(0);
            else  if ((1 <= rc)) updateSize(((float)g_sSize));
        }
        string _ret4;
        string _sDefGroup6 = LINKSETID;
        if (("" == _sDefGroup6)) (_sDefGroup6 = "Default");
        string _str2 = llStringTrim(llGetObjectDesc(),3);
        if (((llToLower(_str2) == "(no description)") || (_str2 == ""))) (_str2 = _sDefGroup6);
        else  {
            list _lGroup9 = llParseString2List(_str2,[" "],[]);
            (_str2 = llList2String(_lGroup9,0));
        }
        string _str7 = _str2;
        list lKeys = llParseString2List(((string)kId),[SEPARATOR],[]);
        string sGroup = llList2String(lKeys,0);
        string _sScriptName8 = llList2String(lKeys,1);
        if ((((_str7 == sGroup) || (LINKSETID == sGroup)) || (LINKSETID == _str7))) {
            (_ret4 = _sScriptName8);
            jump _end5;
        }
        (_ret4 = "exit");
        @_end5;
        string sScriptName = _ret4;
        if (("exit" == sScriptName)) return;
        if (((((iChan != PARTICLE_CHANNEL) || (!g_iParticleFire)) || (!g_iParticleFireAvail)) || (llSubStringIndex(llToLower(sScriptName),g_sType) >= 0))) return;
        list lParams = llParseString2List(sSet,[SEPARATOR],[]);
        string sVal = llList2String(lParams,0);
        string sMsg = llList2String(lParams,1);
        
        if ((("0" == sVal) && g_iInTimer)) return;
        llSetTimerEvent(0.0);
        (g_iInTimer = 0);
        if ((sVal == g_sSize)) {
            return;
        }
        else  if ((((((integer)sVal) > 0) && (100 >= ((integer)sVal))) && ("fire" == sMsg))) {
            string g_sSizeTemp = g_sSize;
            if (("0" == g_sSizeTemp)) {
                llSleep(0.7);
                specialFire();
                (g_fLightIntensity = g_fStartIntensity);
                (g_fLightRadius = g_fStartRadius);
                llSleep(2.4);
                updateSize(((float)sVal));
            }
            else  {
                updateSize(((float)sVal));
            }
            (g_sSize = sVal);
        }
        else  if ((("fire" == sMsg) || ("" == sMsg))) {
            (g_iInTimer = 1);
            llSetTimerEvent(1.0);
            llSleep(1.3);
            specialFire();
            llSleep(2.9);
        }
    }



	timer() {
        
        if (g_iLight) llSetLinkPrimitiveParamsFast(g_iTypeLight,[23,0,ZERO_VECTOR,0,0,0]);
        llSleep(1.3);
        llParticleSystem([]);
        
        llSleep(3.9);
        if (g_iTextureAnim) llSetLinkTextureAnim(g_iTypeTexture,0,-1,4,4,0,0,1);
        if (((!silent) && g_iVerbose)) llWhisper(0,"(v) Particle fire effects ended");
        (g_sSize = "0");
        (g_iInTimer = 0);
        llSetTimerEvent(0.0);
    }
}
