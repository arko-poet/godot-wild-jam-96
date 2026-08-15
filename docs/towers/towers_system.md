# Overview
The Tower system and its flow is defined by 4 components.
- Tower Resource (`tower_resource.gd`)
- Tower Scene (`tower.tscn` + `tower.gd`)
- Tower Ability (`tower_ability.gd`)
- Tower Ability Context (`tower_ability_context.gd`)

## Tower Resource
The `tower_resource.gd` defines the schema of towers. It extends the resource class and it enables
designers to create tower configurations.

## Tower Scene 
The actual tower instance that exists in the game.
It takes the base configuration from the TowerResource when created and maintains its own 
runtime state, such as:

- Current Power
- Current Range
- Current Charge Rate
- Enemies currently in range

Upgrades and temporary effects modify the Tower's runtime values rather than modifying the 
original TowerResource.

## Tower Ability
Defines what happens when a tower activates.
Each different type of tower behavior is implemented as a child class of TowerAbility.

A VFX scene can be added to the Ability, which the TowerAbility  child class will decide how to use.

## Tower Ability Context
Contains information about the tower activation that an ability may need.
Currently this includes:

origin — where the ability originates
power — the tower's current Power
targets - the available targets within range.

The ability receives the Context when it is activated.

# Creating a Tower
Designers should not need to create or modify a Tower script to create a new tower.

Instead:
1. Create a new TowerResource.
2. Configure its base properties.
3. Select a TowerAbility.
4. Then the player can place it in the game! (Not implemented yet)

A Tower Resource contains:
- Tower Sprite: Sprite displayed by the tower
- Perception Radius: Base range at which the tower detects Mobs
- VFX Origin: Local position where ability effects originate
- Charge Rate: Charges gained per second
- Activation Cost: Number of charges required to activate
- Power: Base value passed to the ability
- Purchase Price: To be used by the towers placement system to define how many points
it costs to build this
- Sell Price: To be used when the player demolishes the tower, to define how many points
are returned for the action.
- Special Ability: Ability executed when the tower activates
- Targeting Priority: Determines which targets are selected first

Extra Scripting will only be needed to define new TowerAbilities.

## Targeting
- The ability defines how many targets are hit from the perceived ones. While the Targeting priority
defines in what order these targets are selected. 

Available Priorities right now include: 
- Furthest Along Path
- Closest to Tower
- Lowest HP
- Highest HP
- Fastest
- Slowest

## Power
Power is an intentionally generic stat.
The Tower passes its current Power to the Ability through the TowerAbilityContext.
An ability decides how Power affects its behavior.

For example:
```
Base Damage = 10
Power = 2
Final Damage = 10 × 2 = 20
```
But Power doesn't necessarily have to mean damage.

An ability could use it for Damage, Number of targets, Range, Duration, Slow strength,
Projectile speed, Healing, knockback etc.

This makes Power useful for future Tower upgrades or "supercharging" mechanics.
