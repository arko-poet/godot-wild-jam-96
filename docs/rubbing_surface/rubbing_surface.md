# Rubbing Surface Component
The component is made up of four main nodes:
	1. `RubbingSurface` --> This is the orchestrator node, which should be exposed publicly to 
	other components.
	2. `CollisionShape2D` --> The area over which we monitor the rubbing.
	3. `RubbingDetector` --> Converts the user's mouse activity over the collision shape into a 
	measurable `rubbing_intensity` ranging from (0.0) to (1.0)
	4. `ChargeController` --> Using the `rubbing_intensity` as input it handles the charge generation.
	It also handles the discharge computation + the storage of the charge. Exposed through the
	`RubbingSurface` node. 
	
# How does the Rub Detection Works?
The Rubbing Surface keeps the `RubbingDetector` updated of mouse events. It just announces when the 
mouse is pressed or not over the Collision Shape.

The `RubbingDetector` gets in a `RUBBING` state when the mouse is pressed over the collision shape
and exits that state when the mouse is released, or when the mouse is out of the collision shape after
a small grace period. 

During the `RUBBING` state, the process samples the mouse positions and movement vectors. 
Between samples, if the mouse has moved more than a minimum correction distance, we calculate the 
angle between direction of the previous movement, and the direction of the current movement. 

We accumulate the change in degrees over the span of a sampling window `directional_change_in_window`
and at the end of this sampling window, we measure the intensity by normalizing it against an `ideal_direction_change_rate`.

The sampling window resets and the detection continues. 

# How do we convert Rubbing Intensity to Charge?
The `RubbingSurface` delivers the `rubbing_intensity` per frame to to the `ChargeController`. 
It is **important** to notice that the `rubbing_intensity` updates only when the sampling window has rolled out, but
with the current parameters the illusion seems to be maintained properly.

The `ChargeController` does some simple math:
	- Charge Gained per second = `charge_generation_rate` x `rubbing_intensity`  - `charge_discharge_rate` 
	- The calculation is applied per delta. 
	- Charge is clamped between 0 and `max_charge`
	
The `ChargeController` is configured through a `ChargeConfig` resource in case we need to have different
towers have different charge characteristics.

A Charge Status enum is also setup with a logic to allow configuring percentile based threshold to map
charge levels to these statuses. By default
- `-90% or below` : Overcharged Negatively
- `-90% to -20%` : Charged Negatively
- `-20% to +20%` : No Charge.
- `20% to 90%` : Charged Positively
- `90% or higher`: Overcharged Positively

The `RubbingSurface` exposes this status in case we want to implement logic based on these statuses.
Alternatively we can have the logic directly depend on charge_percentage which is also exposed.
Keep in mind that we can set the threshold for each RubbingSurface to something else or we could even
have towers with flunctuating characteristics.

# Setting up the Component in another object?
To setup the component we would likely need to add it and then make sure to edit the CollisionShape2D
under it, adjusting it's shape to the object we want to use. For example if we are to add it to towers,
we should likely add the component in the `tower.tscn` 

# Etc.
Some Debugging parameters have been setup to allow displaying the Intensity, the Charge and the generated
charge per second. Also a Sprite was added to make testing easier, I don't know if we will keep it, remove
it entirely or change it to something specific. 
You can find those in the inspector for the `RubbingSurface` 

# Update (Negative CHarging added)
To charge the RubbingSurface, a user needs to press their Left Mouse Button and start rubbing. 
If they are also holding down the Right Mouse Button the Charging is signed Negatively. 
