class SuperHotGoatComponent extends GGMutatorComponent;

var GGGoat gMe;
var GGMutator myMut;

var GGSVehicle currVehicle;

var bool isForwardPressed;
var bool isBackPressed;
var bool isLeftPressed;
var bool isRightPressed;
var bool isJumpPressed;
var bool isGamepadPressed;
var float lastBaseY;
var float lastStrafe;

var bool sPressed;
var bool uPressed;
var bool pPressed;
var bool ePressed;
var bool rPressed;
var bool hPressed;
var bool oPressed;
var bool isSuperHot;

var bool lastPlayerOnly;

/**
 * See super.
 */
function AttachToPlayer( GGGoat goat, optional GGMutator owningMutator )
{
	super.AttachToPlayer(goat, owningMutator);

	if(mGoat != none)
	{
		gMe=goat;
		myMut=owningMutator;
	}
}

function KeyState( name newKey, EKeyState keyState, PlayerController PCOwner )
{
	local GGPlayerInputGame localInput;
	local bool checkTime;

	//myMut.WorldInfo.Game.Broadcast(myMut, "gMe.DrivenVehicle.Controller=" $ gMe.DrivenVehicle.Controller);
	if(PCOwner != gMe.Controller && (gMe.DrivenVehicle == none || PCOwner != gMe.DrivenVehicle.Controller))
		return;

	//myMut.WorldInfo.Game.Broadcast(myMut, "KeyState" @ newKey @ keyState @ PCOwner);
	localInput = GGPlayerInputGame( PCOwner.PlayerInput );

	if( keyState == KS_Down )
	{
		checkTime=true;
		if(localInput.IsKeyIsPressed("GBA_Forward", string( newKey )))
		{
			isForwardPressed=true;
		}
		else if(localInput.IsKeyIsPressed("GBA_Back", string( newKey )))
		{
			isBackPressed=true;
		}
		else if(localInput.IsKeyIsPressed("GBA_Left", string( newKey )))
		{
			isLeftPressed=true;
		}
		else if(localInput.IsKeyIsPressed("GBA_Right", string( newKey )))
		{
			isRightPressed=true;
		}
		else if( localInput.IsKeyIsPressed( "GBA_Jump", string( newKey ) ) )
		{
			isJumpPressed=true;
		}
		else if( newKey == 'gamepad_move' )
		{
			isGamepadPressed=true;
		}
		else
		{
			checkTime=false;
		}

		if(newKey == 'S')
		{
			sPressed=true;
		}
		else if(newKey == 'U' && sPressed)
		{
			uPressed=true;
		}
		else if(newKey == 'P' && uPressed)
		{
			pPressed=true;
		}
		else if(newKey == 'E' && pPressed)
		{
			ePressed=true;
		}
		else if(newKey == 'R' && ePressed)
		{
			rPressed=true;
		}
		else if(newKey == 'H' && rPressed)
		{
			hPressed=true;
		}
		else if(newKey == 'O' && hPressed)
		{
			oPressed=true;
		}
		else if(newKey == 'T' && oPressed)
		{
			ToggleWhiteTheme();
		}
		else
		{
			sPressed=false;
			uPressed=false;
			pPressed=false;
			ePressed=false;
			rPressed=false;
			hPressed=false;
			oPressed=false;
		}
	}
	else if( keyState == KS_Up )
	{
		checkTime=true;
		if(localInput.IsKeyIsPressed("GBA_Forward", string( newKey )))
		{
			isForwardPressed=false;
		}
		else if(localInput.IsKeyIsPressed("GBA_Back", string( newKey )))
		{
			isBackPressed=false;
		}
		else if(localInput.IsKeyIsPressed("GBA_Left", string( newKey )))
		{
			isLeftPressed=false;
		}
		else if(localInput.IsKeyIsPressed("GBA_Right", string( newKey )))
		{
			isRightPressed=false;
		}
		else if( localInput.IsKeyIsPressed( "GBA_Jump", string( newKey ) ) )
		{
			isJumpPressed=false;
		}
		else if( newKey == 'gamepad_move' )
		{
			isGamepadPressed=false;
		}
		else
		{
			checkTime=false;
		}
	}

	if(checkTime)
	{
		if(IsTimeStopped())//Start time if needed
		{
			if(isForwardPressed || isBackPressed || isLeftPressed || isRightPressed || isJumpPressed || isGamepadPressed)
			{
				ToggleTime();
			}
		}
		else //Stop time if needed
		{
			if(!(isForwardPressed || isBackPressed || isLeftPressed || isRightPressed || isJumpPressed || isGamepadPressed))
			{
				ToggleTime();
			}
		}
	}
}

function bool IsTimeStopped()
{
	local GGPlayerControllerGame gpcg;

	gpcg = GGPlayerControllerGame( gMe.GetALocalPlayerController() );

	return gpcg != none && gpcg.CustomTimeDilation == 0.01f;
}

function ToggleTime()
{
	local float newTimeSpeed;

	newTimeSpeed=IsTimeStopped()?1.f:0.01f;
	GGGameInfo( class'WorldInfo'.static.GetWorldInfo().Game ).SetGameSpeed(newTimeSpeed);
	gMe.RotationRate=gMe.default.RotationRate / newTimeSpeed;
}

function Tick( float deltaTime )
{
	local bool isMoving, wasMoving;
	local float currentBaseY, currentStrafe;
	local PlayerController currPlayerController;
	local GGSVehicle oldVehicle;

	currPlayerController=PlayerController(gMe.DrivenVehicle!=none?gMe.DrivenVehicle.Controller:gMe.Controller);
	if(GGLocalPlayer(currPlayerController.Player).mIsUsingGamePad)
	{
		currentBaseY=currPlayerController.PlayerInput.aBaseY;
		currentStrafe=currPlayerController.PlayerInput.aStrafe;
		//myMut.WorldInfo.Game.Broadcast(myMut, "currentBaseY=" $ currentBaseY $ " currentStrafe=" $ currentStrafe);

		isMoving=currentBaseY != 0.f || currentStrafe != 0.f;
		wasMoving=lastBaseY != 0.f || lastStrafe != 0.f;
		if(isMoving && ! wasMoving)
		{
			KeyState('gamepad_move', KS_Down, currPlayerController);
		}
		if(wasMoving && ! isMoving)
		{
			KeyState('gamepad_move', KS_Up, currPlayerController);
		}
		lastBaseY = currentBaseY;
		lastStrafe = currentStrafe;
	}

	if(currVehicle != none && currVehicle.bPendingDelete)
	{
		currVehicle=none;
	}
	oldVehicle = currVehicle;
	currVehicle = GGSVehicle(gMe.DrivenVehicle);

	if(currVehicle != none && oldVehicle == none)
	{
		OnEnterVehicle(currVehicle);
	}
	if(currVehicle == none && oldVehicle != none)
	{
		OnExitVehicle(oldVehicle);
	}
}

function OnEnterVehicle(GGSVehicle newVehicle)
{
	//myMut.WorldInfo.Game.Broadcast(myMut, "OnEnterVehicle(" $ newVehicle $ ")");
	TryRegisterInput( PlayerController( newVehicle.Controller ) );
}

function OnExitVehicle(GGSVehicle oldVehicle)
{
	//myMut.WorldInfo.Game.Broadcast(myMut, "OnExitVehicle(" $ oldVehicle $ ")");
	//TryUnregisterInput( PlayerController( gMe.Controller ) );
}

function ToggleWhiteTheme()
{
 	isSuperHot=!isSuperHot;
 	if(isSuperHot)
 	{
 		PlayerController(gMe.Controller).ConsoleCommand("viewmode lightingonly");
 	}
	else
	{
		PlayerController(gMe.Controller).ConsoleCommand("viewmode lit");
	}
}

defaultproperties
{

}