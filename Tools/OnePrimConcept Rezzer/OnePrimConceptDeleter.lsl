// Created by Ana Imfinity
// Change parameters below:
float range = 30; //sensor range of avatar detector
float scan = 10; //how fast to scan after avatars
default
{
    state_entry()
    {
        llSensorRepeat("",NULL_KEY,AGENT_BY_LEGACY_NAME,30,PI,10);
    }
    no_sensor()
    {
        llDie();
    }
}