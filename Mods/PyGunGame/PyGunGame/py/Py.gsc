#include py\PyUtils;

pyOnInit()
{
	enableJumpMod = getDvarInt("py_enableJumpMod");
	if(enableJumpMod == 1)
	{
	    jumpHeight = getDvarInt("py_jumpHeight");
		setDvar("jump_height", jumpHeight);
		
		enableFallDamage = getDvarInt("py_enableFallDamage");
		if(enableFallDamage != 1)
		{
		    setDvar("bg_fallDamageMinHeight", 1001); // Max jumpHeight is 1000
		    setDvar("bg_fallDamageMaxHeight", 1002); // Has to be higher than min value
		}
	}
}

pyOnStartGameType()
{
	expFogStartDist = getDvarInt("py_expFogStartDist");
	expFogHalfDist = getDvarInt("py_expFogHalfDist");
	expFogRed = getDvarFloat("py_expFogRed");
	expFogGreen = getDvarFloat("py_expFogGreen");
	expFogBlue = getDvarFloat("py_expFogBlue");
	expFogTransition = getDvarFloat("py_expFogTransition");
	setExpFog(expFogStartDist, expFogHalfDist, expFogRed, expFogGreen, expFogBlue, expFogTransition);
}

pyCallback_PlayerConnect()
{
    self pySetClientDvars();
}

pySetClientDvars()
{
	self setClientDvars(
		"fx_enable", getDvarInt("py_fx_enable"),
		"r_fullbright", getDvarInt("py_r_fullbright"),
		"player_sustainAmmo", getDvarInt("py_player_sustainAmmo"),
		"r_fog", getDvarInt("py_r_fog"),
		"r_drawDecals", getDvarInt("py_r_drawDecals"),
		"r_drawSun", getDvarInt("py_r_drawSun"),
		"r_picmip_water", getDvarInt("py_r_picmip_water"),
		"cg_brass", getDvarInt("py_cg_brass"),
		"com_maxFPS", getDvarInt("py_com_maxFPS")
		);
}

pyOnSpawnPlayer()
{
    if(getDvarInt("py_anticamp_enabled") != 0)
        self thread pyPlayerAntiCamp();

    welcome_text = getDvar("py_welcome_text");
    
    if(welcome_text == "")
        self IprintLnBold("No Greeting!");
    else
    {
        replaced_welcome_text = string_replace( welcome_text, "<name>", self.name );
        self IprintLnBold( replaced_welcome_text );
    }
}

pyPlayerAntiCamp()
{
    self endon( "death" );
    my_camp_time = 0;
    have_i_been_warned = false;
    camp_radius = getDvarInt("py_anticamp_camp_radius");
    camp_to_warning_time = getDvarInt("py_anticamp_camp_to_warning_time");
    warning_to_death_time = getDvarInt("py_anticamp_warning_to_death_time");
    warning_text = getDvar("py_anticamp_warning_text");
    death_text = getDvar("py_anticamp_death_text");

    while( 1 )
    {
        old_position = self.origin;
        //wait 1;
        wait 1;
        new_position = self.origin;
        distance = distance2d( old_position, new_position );

        if( distance < camp_radius )
        {
            my_camp_time++;
        }
        else
        {
            my_camp_time = 0;
            have_i_been_warned = false;
        }

        if( my_camp_time >= camp_to_warning_time && !have_i_been_warned )
        {
            self IprintLnBold( warning_text );
            have_i_been_warned = true;
        }

        if( my_camp_time >= ( camp_to_warning_time + warning_to_death_time ) && have_i_been_warned )
        {
            self IprintLnBold( death_text );
            wait 1;
            self suicide();
        }
    }
}
