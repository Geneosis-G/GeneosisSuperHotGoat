class SuperHotGoat extends GGMutator;

var array< SuperHotGoatComponent > mComponents;

function ModifyPlayer(Pawn Other)
{
	local GGGoat goat;
	local SuperHotGoatComponent superHotComp;

	super.ModifyPlayer( other );

	goat = GGGoat( other );
	if( goat != none )
	{
		superHotComp=SuperHotGoatComponent(GGGameInfo( class'WorldInfo'.static.GetWorldInfo().Game ).FindMutatorComponent(class'SuperHotGoatComponent', goat.mCachedSlotNr));
		if(superHotComp != none && mComponents.Find(superHotComp) == INDEX_NONE)
		{
			mComponents.AddItem(superHotComp);
		}
	}
}

simulated event Tick( float delta )
{
	local int i;

	for( i = 0; i < mComponents.Length; i++ )
	{
		mComponents[ i ].Tick( delta );
	}
	super.Tick( delta );
}

DefaultProperties
{
	mMutatorComponentClass=class'SuperHotGoatComponent'
}