// Created by ana Imfinity
// Change the parameters below:
float altitude = 1.0; //how high will rezz the new object
float range = 30; //sensor range of avatar detector
float scan = 10; //how fast to scan after avatars
default
{
    state_entry()
    {
        llSensorRepeat("",NULL_KEY,AGENT_BY_LEGACY_NAME,range,PI,scan);
    }
    sensor(integer ana)
    {
        llRezObject(llGetInventoryName(INVENTORY_OBJECT,0),
        llGetPos()+<0.0,0.0,altitude>,ZERO_VECTOR,ZERO_ROTATION,0);
        llSleep(1);
        state alfa;
    }
}
state alfa
{
    state_entry()
    {
        
        llSensorRepeat("",NULL_KEY,AGENT_BY_LEGACY_NAME,range,PI,scan);
    }
    no_sensor()
    {
        llSleep(1);
        state default;
    }
}