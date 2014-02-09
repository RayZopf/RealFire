// LSL script generated: RealFire-Rene10957.LSL.F-Anim.lslp Sun Feb  9 00:58:57 Mitteleuropäische Zeit 2014
///////////////////////////////////////////////////////////////////////////////////////////////////
//ParticleFire Enhancement to Realfire
// by Zopf Resident - Ray Zopf (Raz)
//
//07. Feb. 2014
//v0.3
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

//debug variables
//-----------------------------------------------
integer g_iDebugMode = FALSE;


//user changeable variables
//-----------------------------------------------
integer g_iParticleFire = TRUE;
integer g_iType = LINK_SET;
integer g_iTextureAnim = TRUE;
integer g_iTypeTexture = LINK_SET;
integer g_iLight = TRUE;
integer g_iTypeLight = LINK_SET;
// get singlefire from notecard, think about what to do - define linktype for all three anim things?!
integer g_iVerbose = TRUE;

string LINKSETID = "RealFire";

// Particle parameters
float g_fAge = 1.0;
float g_fRate = 0.1;
integer g_iCount = 10;
vector g_vStartScale = <0.4,2,0>;
vector g_vEndScale = <0.4,2,0>;
float g_fMinSpeed = 0.0;
float g_fMaxSpeed = 4.0e-2;
float g_fBurstRadius = 0.4;
vector g_vPartAccel = <0,0,10>;
vector g_vStartColor = <1,1,0>;
vector g_vEndColor = <1,0,0>;

//internal variables
//-----------------------------------------------
string g_sTitle = "RealParticleFire";
string g_sVersion = "0.3";
string g_sAuthors = "Zopf";

string g_sType = "anim";

integer g_iParticleFireAvail = TRUE;

string g_sSize = "0";

// Constants
float MAX_COLOR = 1.0;
float MAX_INTENSITY = 1.0;
float MAX_RADIUS = 20.0;
float MAX_FALLOFF = 2.0;

//RealFire MESSAGE MAP
//integer COMMAND_CHANNEL =
//integer ANIM_CHANNEL = primfire/textureanim channel
//integer PRIMCOMMAND_CHANNEL = kill fire prims or make temp prims

// Variables
vector g_vLightColor;
float g_fLightIntensity;
float g_fLightRadius;
float g_fLightFalloff;
float g_fStartIntensity;
float g_fStartRadius;
string g_sMainScript = "Fire.lsl";
string g_sScriptName;
integer silent = FALSE;
integer g_iChangeLight = TRUE;
integer g_iSingleFire = TRUE;
vector g_vDefStartColor = <100,100,0>;
vector g_vDefEndColor = <100,0,0>;
integer g_iDefIntensity = 100;
integer g_iDefRadius = 50;
integer g_iDefFalloff = 40;
integer g_iPerRedStart;
integer g_iPerGreenStart;
integer g_iPerBlueStart;
integer g_iPerRedEnd;
integer g_iPerGreenEnd;
integer g_iPerBlueEnd;
integer g_iInTimer = FALSE;
string SEPARATOR = ";;";
float SIZE_TINY = 5.0;
float SIZE_EXTRASMALL = 15.0;
float SIZE_SMALL = 25.0;
float SIZE_MEDIUM = 50.0;
float SIZE_LARGE = 80.0;
integer COMMAND_CHANNEL = -15700;
integer PARTICLE_CHANNEL = -15790;


//###
//Debug.lslm
//0.1 - 28Jan2014

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
//GenericFunctions.lslm
//0.2 - 06Feb2014

integer checkInt(string par,integer val,integer min,integer max){
    if (((val < min) || (val > max))) {
        if ((val < min)) (val = min);
        else  if ((val > max)) (val = max);
        llWhisper(0,((("[Notecard] " + par) + " out of range, corrected to ") + ((string)val)));
    }
    return val;
}


float percentage(float per,float num){
    return ((num / 100.0) * per);
}


integer min(integer x,integer y){
    if ((x < y)) return x;
    else  return y;
}


integer max(integer x,integer y){
    if ((x > y)) return x;
    else  return y;
}


//###
//PrintStatusInfo.lslm
//0.2 - 08Feb2014

InfoLines(integer bool){
    if ((g_iVerbose && bool)) {
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


//###
//GroupHandling.lslm
//0.5 - 31Jan2014

string getGroup(string sDefGroup){
    if (("" == sDefGroup)) (sDefGroup = "Default");
    string str = llStringTrim(llGetObjectDesc(),STRING_TRIM);
    if (((llToLower(str) == "(no description)") || (str == ""))) (str = sDefGroup);
    else  {
        list lGroup = llParseString2List(str,[" "],[]);
        (str = llList2String(lGroup,0));
    }
    return str;
}


string GroupCheck(key kId){
    string str = getGroup(LINKSETID);
    list lKeys = llParseString2List(((string)kId),[SEPARATOR],[]);
    string sGroup = llList2String(lKeys,0);
    string sScriptName = llList2String(lKeys,1);
    if ((((str == sGroup) || (LINKSETID == sGroup)) || (LINKSETID == str))) return sScriptName;
    return "exit";
}


//###
//ColorChanger.lslm
//0.11 - 07Feb2014

setColor(integer pos,string msg){
    if ((1 == pos)) {
        if ((msg == "-Red")) (g_iPerRedStart = max((g_iPerRedStart - 10),0));
        else  if ((msg == "-Green")) (g_iPerGreenStart = max((g_iPerGreenStart - 10),0));
        else  if ((msg == "-Blue")) (g_iPerBlueStart = max((g_iPerBlueStart - 10),0));
        else  if ((msg == "+Red")) (g_iPerRedStart = min((g_iPerRedStart + 10),100));
        else  if ((msg == "+Green")) (g_iPerGreenStart = min((g_iPerGreenStart + 10),100));
        else  if ((msg == "+Blue")) (g_iPerBlueStart = min((g_iPerBlueStart + 10),100));
        else  if ((msg == "R min/max")) {
            if (g_iPerRedStart) (g_iPerRedStart = 0);
            else  (g_iPerRedStart = 100);
        }
        else  if ((msg == "G min/max")) {
            if (g_iPerGreenStart) (g_iPerGreenStart = 0);
            else  (g_iPerGreenStart = 100);
        }
        else  if ((msg == "B min/max")) {
            if (g_iPerBlueStart) (g_iPerBlueStart = 0);
            else  (g_iPerBlueStart = 100);
        }
        else  if ((msg == "One color")) {
            (g_iPerRedEnd = g_iPerRedStart);
            (g_iPerGreenEnd = g_iPerGreenStart);
            (g_iPerBlueEnd = g_iPerBlueStart);
        }
    }
    else  {
        if ((msg == "-Red")) (g_iPerRedEnd = max((g_iPerRedEnd - 10),0));
        else  if ((msg == "-Green")) (g_iPerGreenEnd = max((g_iPerGreenEnd - 10),0));
        else  if ((msg == "-Blue")) (g_iPerBlueEnd = max((g_iPerBlueEnd - 10),0));
        else  if ((msg == "+Red")) (g_iPerRedEnd = min((g_iPerRedEnd + 10),100));
        else  if ((msg == "+Green")) (g_iPerGreenEnd = min((g_iPerGreenEnd + 10),100));
        else  if ((msg == "+Blue")) (g_iPerBlueEnd = min((g_iPerBlueEnd + 10),100));
        else  if ((msg == "R min/max")) {
            if (g_iPerRedEnd) (g_iPerRedEnd = 0);
            else  (g_iPerRedEnd = 100);
        }
        else  if ((msg == "G min/max")) {
            if (g_iPerGreenEnd) (g_iPerGreenEnd = 0);
            else  (g_iPerGreenEnd = 100);
        }
        else  if ((msg == "B min/max")) {
            if (g_iPerBlueEnd) (g_iPerBlueEnd = 0);
            else  (g_iPerBlueEnd = 100);
        }
        else  if ((msg == "One color")) {
            (g_iPerRedStart = g_iPerRedEnd);
            (g_iPerGreenStart = g_iPerGreenEnd);
            (g_iPerBlueStart = g_iPerBlueEnd);
        }
    }
}


//###
//ExtensionBasics.lslm
//0.462 - 08Feb2014

RegisterExtension(integer link){
    if (g_iParticleFire) {
        if ((g_iSingleFire && (INVENTORY_NONE == llGetInventoryType(g_sMainScript)))) {
            (g_iParticleFireAvail = FALSE);
            return;
        }
        string sId = ((getGroup(LINKSETID) + SEPARATOR) + g_sScriptName);
        if (g_iParticleFireAvail) llMessageLinked(link,PARTICLE_CHANNEL,"1",((key)sId));
        else  if (g_iSingleFire) llMessageLinked(link,PARTICLE_CHANNEL,"0",((key)sId));
    }
}


string MasterCommand(integer iChan,string sVal,integer conf){
    if ((iChan == COMMAND_CHANNEL)) {
        list lValues = llParseString2List(sVal,[SEPARATOR],[]);
        string sCommand = llList2String(lValues,0);
        if (("register" == sCommand)) {
            RegisterExtension(g_iType);
        }
        else  if (("verbose" == sCommand)) {
            (g_iVerbose = TRUE);
            InfoLines(FALSE);
        }
        else  if (("nonverbose" == sCommand)) (g_iVerbose = FALSE);
        else  if (("globaldebug" == sCommand)) (g_iVerbose = TRUE);
        else  if ((conf && ("config" == sCommand))) return sVal;
        else  if (g_iParticleFire) llSetTimerEvent(0.1);
        return "";
    }
    return "";
}


 integer getConfigParticleFire(string sVal){
    list lConfigs = llParseString2List(sVal,["config","=",SEPARATOR],[]);
    integer n = llGetListLength(lConfigs);
    integer count = 0;
    string par;
    Debug(((("getConfig Particlefire " + ((string)lConfigs)) + " n ") + ((string)n)));
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
                setColor(1,val);
                if ((2 == n)) return 2;
            }
            else  if (("endcolor" == par)) {
                setColor(0,val);
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
        if (g_iTextureAnim) llSetLinkTextureAnim(g_iTypeTexture,FALSE,ALL_SIDES,4,4,0,0,1);
        if (g_iLight) llSetLinkPrimitiveParamsFast(g_iTypeLight,[PRIM_POINT_LIGHT,FALSE,ZERO_VECTOR,0,0,0]);
    }
    (g_vDefStartColor.x = checkInt("ColorOn (RED)",((integer)g_vDefStartColor.x),0,100));
    (g_vDefStartColor.y = checkInt("ColorOn (GREEN)",((integer)g_vDefStartColor.y),0,100));
    (g_vDefStartColor.z = checkInt("ColorOn (BLUE)",((integer)g_vDefStartColor.z),0,100));
    (g_vDefEndColor.x = checkInt("ColorOff (RED)",((integer)g_vDefEndColor.x),0,100));
    (g_vDefEndColor.y = checkInt("ColorOff (GREEN)",((integer)g_vDefEndColor.y),0,100));
    (g_vDefEndColor.z = checkInt("ColorOff (BLUE)",((integer)g_vDefEndColor.z),0,100));
    (g_fStartIntensity = percentage(g_iDefIntensity,MAX_INTENSITY));
    (g_fStartRadius = percentage(g_iDefRadius,MAX_RADIUS));
    (g_fLightFalloff = percentage(g_iDefFalloff,MAX_FALLOFF));
    llSleep(1);
    if (bool) RegisterExtension(g_iType);
    InfoLines(FALSE);
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
    (fMin = ((g_fMinSpeed / 100.0) * size));
    (fMax = ((g_fMaxSpeed / 100.0) * size));
    (vPush = ((g_vPartAccel / 100.0) * size));
    if ((size > SIZE_SMALL)) {
        (vStart = ((g_vStartScale / 100.0) * size));
        (fRadius = ((g_fBurstRadius / 100.0) * size));
        if (g_iTextureAnim) {
            if ((size >= SIZE_LARGE)) llSetLinkTextureAnim(g_iTypeTexture,(ANIM_ON | LOOP),ALL_SIDES,4,4,0,0,9);
            else  if ((size >= SIZE_MEDIUM)) llSetLinkTextureAnim(g_iTypeTexture,(ANIM_ON | LOOP),ALL_SIDES,4,4,0,0,6);
            else  llSetLinkTextureAnim(g_iTypeTexture,(ANIM_ON | LOOP),ALL_SIDES,4,4,0,0,4);
        }
    }
    else  {
        if (g_iTextureAnim) {
            if ((size >= SIZE_EXTRASMALL)) llSetLinkTextureAnim(g_iTypeTexture,(ANIM_ON | LOOP),ALL_SIDES,4,4,0,0,3);
            else  llSetLinkTextureAnim(g_iTypeTexture,(ANIM_ON | LOOP),ALL_SIDES,4,4,0,0,1);
        }
        (vStart = (g_vStartScale / 4.0));
        (fRadius = (g_fBurstRadius / 4.0));
        if ((size < SIZE_TINY)) {
            (vStart.y = (((g_vStartScale.y / 100.0) * size) * 5.0));
            if ((vStart.y < 0.25)) (vStart.y = 0.25);
        }
        if (g_iLight) {
            if (g_iChangeLight) {
                (g_fLightIntensity = percentage((size * 4.0),g_fStartIntensity));
                (g_fLightRadius = percentage((size * 4.0),g_fStartRadius));
            }
            else  {
                (g_fLightIntensity = g_fStartIntensity);
                (g_fLightRadius = g_fStartRadius);
            }
        }
    }
    updateColor();
    updateParticles(vStart,vEnd,fMin,fMax,fRadius,vPush);
    if (g_iLight) llSetLinkPrimitiveParamsFast(g_iTypeLight,[PRIM_POINT_LIGHT,TRUE,g_vLightColor,g_fLightIntensity,g_fLightRadius,g_fLightFalloff]);
    Debug(((((((string)llRound(size)) + "% ") + ((string)vStart)) + " ") + ((string)vEnd)));
}


updateColor(){
    (g_vStartColor.x = percentage(((float)g_iPerRedStart),MAX_COLOR));
    (g_vStartColor.y = percentage(((float)g_iPerGreenStart),MAX_COLOR));
    (g_vStartColor.z = percentage(((float)g_iPerBlueStart),MAX_COLOR));
    (g_vEndColor.x = percentage(((float)g_iPerRedEnd),MAX_COLOR));
    (g_vEndColor.y = percentage(((float)g_iPerGreenEnd),MAX_COLOR));
    (g_vEndColor.z = percentage(((float)g_iPerBlueEnd),MAX_COLOR));
    (g_vLightColor = ((g_vStartColor + g_vEndColor) / 2.0));
}

updateParticles(vector vStart,vector vEnd,float fMin,float fMax,float fRadius,vector vPush){
    llSleep(0.8);
    llParticleSystem([PSYS_PART_FLAGS,(((0 | PSYS_PART_EMISSIVE_MASK) | PSYS_PART_INTERP_COLOR_MASK) | PSYS_PART_INTERP_SCALE_MASK),PSYS_SRC_PATTERN,PSYS_SRC_PATTERN_EXPLODE,PSYS_SRC_BURST_RADIUS,fRadius,PSYS_PART_START_COLOR,g_vStartColor,PSYS_PART_END_COLOR,g_vEndColor,PSYS_PART_START_ALPHA,1.0,PSYS_PART_END_ALPHA,0.0,PSYS_PART_START_SCALE,vStart,PSYS_PART_END_SCALE,vEnd,PSYS_PART_MAX_AGE,g_fAge,PSYS_SRC_BURST_RATE,g_fRate,PSYS_SRC_BURST_PART_COUNT,g_iCount,PSYS_SRC_ACCEL,vPush,PSYS_SRC_BURST_SPEED_MIN,fMin,PSYS_SRC_BURST_SPEED_MAX,fMax]);
}


specialFire(){
    Debug("specialFire");
    llParticleSystem([PSYS_PART_FLAGS,(((0 | PSYS_PART_EMISSIVE_MASK) | PSYS_PART_INTERP_COLOR_MASK) | PSYS_PART_INTERP_SCALE_MASK),PSYS_SRC_PATTERN,PSYS_SRC_PATTERN_EXPLODE,PSYS_SRC_BURST_RADIUS,0.148438,PSYS_PART_START_COLOR,<0.74902,0.6,0.14902>,PSYS_PART_END_COLOR,<1,0.2,0>,PSYS_PART_START_ALPHA,0.101961,PSYS_PART_END_ALPHA,7.05882e-2,PSYS_PART_START_SCALE,<0.59375,0.59375,0>,PSYS_PART_END_SCALE,<9.375e-2,9.375e-2,0>,PSYS_SRC_TEXTURE,((key)"23d133ad-c669-18a8-02a3-a75baa9b214a"),PSYS_PART_MAX_AGE,3.0,PSYS_SRC_BURST_RATE,1.0e-2,PSYS_SRC_BURST_PART_COUNT,1,PSYS_SRC_ACCEL,<0,0,0.203125>,PSYS_SRC_BURST_SPEED_MIN,1.95313e-2,PSYS_SRC_BURST_SPEED_MAX,2.73438e-2]);
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
        Debug(("Particle count: " + ((string)llRound(((((float)g_iCount) * g_fAge) / g_fRate)))));
        initExtension(TRUE);
    }


	on_rez(integer start_param) {
        llResetScript();
    }


	changed(integer change) {
        if ((change & CHANGED_INVENTORY)) {
            llWhisper(0,"Inventory changed, checking objects...");
            initExtension(TRUE);
        }
    }



//listen for linked messages from Fire (main) script
//-----------------------------------------------
	link_message(integer iSender,integer iChan,string sSet,key kId) {
        Debug(((((("link_message = channel " + ((string)iChan)) + "; sSet ") + sSet) + "; kId ") + ((string)kId)));
        string sConfig = MasterCommand(iChan,sSet,TRUE);
        if (("" != sConfig)) {
            integer rc = getConfigParticleFire(sConfig);
            if ((1 == rc)) initExtension(FALSE);
            else  if ((1 <= rc)) updateSize(((float)g_sSize));
        }
        string sScriptName = GroupCheck(kId);
        if (("exit" == sScriptName)) return;
        if (((((iChan != PARTICLE_CHANNEL) || (!g_iParticleFire)) || (!g_iParticleFireAvail)) || (llSubStringIndex(llToLower(sScriptName),g_sType) >= 0))) return;
        list lParams = llParseString2List(sSet,[SEPARATOR],[]);
        string sVal = llList2String(lParams,0);
        string sMsg = llList2String(lParams,1);
        Debug("work on link_message");
        if ((("0" == sVal) && g_iInTimer)) return;
        llSetTimerEvent(0.0);
        (g_iInTimer = FALSE);
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
            (g_iInTimer = TRUE);
            llSetTimerEvent(1.0);
            llSleep(1.3);
            specialFire();
            llSleep(2.9);
        }
    }



	timer() {
        Debug("timer");
        if (g_iLight) llSetLinkPrimitiveParamsFast(g_iTypeLight,[PRIM_POINT_LIGHT,FALSE,ZERO_VECTOR,0,0,0]);
        llSleep(1.3);
        llParticleSystem([]);
        Debug("light + particle off");
        llSleep(3.9);
        if (g_iTextureAnim) llSetLinkTextureAnim(g_iTypeTexture,FALSE,ALL_SIDES,4,4,0,0,1);
        if (g_iVerbose) llWhisper(0,"(v) Particle fire effects ended");
        (g_sSize = "0");
        (g_iInTimer = FALSE);
        llSetTimerEvent(0.0);
    }
}
