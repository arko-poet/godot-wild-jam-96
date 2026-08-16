# Tower Placement Controls
Tower Placement is managed by this node `TowerPlacementController` which needs to be added under
`Level` Node and have its References updated properly.

The nodes that it needs to reference are the GroundLayer, the PathLayer and finally a Node2D which
would contain the Towers after they are instanced into the scene. This Node needs to be created by 
the owner of the Level.tscn file. (I am trying not to edit .tscn files that are shared like this one
to avoid messy conflicts)

## The logic flow.

After the user clicks on the Place Tower Button in the UI the follow flow is triggered.
UI -> Game -> Level -> Tower Placement Controller

At the Current Stage of development, the Tower is preselected to a default one, but later on 
we will be having UI to allow selecting the required tower.

A preview of the tower is created following the mouse and snapping onto the grid. 
The tower looks holographic green if the placement is valid, or red if it's invalid. 

Upon clicking the Game is notified, which asks for a confirmation dialog from the UI. 
Upon confirmation, the Game handles the cost payment, while the Tower Placement Controller 
handles the final placement of the tower and brings the tower placement control state to an end.

Click on Valid Tile -> Tower Placement Controller -> Game -> UI -> TowerConfirmationPopup

Confirm on Popup -> Game (Updates Ectoplasm) -> Tower Placement Controller. 
