// Night fire plugin for RealFire
// A simple example script for creating your own plugin
//
// Automatically switches on at sunset and off at sunrise

///////////////////////////////////////////////////////////////////////////////
// HOW TO USE: drop this into the same prim where the FIRE SCRIPT is located //
///////////////////////////////////////////////////////////////////////////////

key owner;                // object owner
integer number = 10959;   // number part of link message

default
{
    state_entry()
    {
        owner = llGetOwner();
        llSetTimerEvent(300);
    }

    on_rez(integer start_param)
    {
        llResetScript();
    }

    timer()
    {
        vector sun = llGetSunDirection();
        if (sun.z < 0) llMessageLinked(LINK_THIS, number, "on", owner);
        else llMessageLinked(LINK_THIS, number, "off", owner);
    }
}
