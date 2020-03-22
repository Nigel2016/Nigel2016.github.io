---
layout: post
title: "Project Blue: Coroutines and Game Tuning"
data:  2020-3-22 02:13:37
categories: game development
---

For this development sprint, I contributed to the AI of the Dropper enemy, created a prefab for another enemy in production, and did fine tuning on the Acrobat prefab. I adjusted the acrobats properties (speed and aggro settings) so that it is at the right level of difficulty. 

Dropper AI:
==================

My main assignment for the past week was to develop the movement script for the Dropper enemy: 

![Dropper](/files/Dropper.png)

The dropper is a flying enemy that moves above the player and drops projectiles on the player. They have a simple movement pattern: they move strictly left and right on the x-axis, chaging their direction every few seconds: 

![DropperMovement](/files/DropperMovement.PNG)

To start coding the Droppers behavior, I used a similar approach to how I developeed the [acrobat](https://nigel2016.github.io/game/development/2020/03/02/Project-Blue-Extended-PreAlpha-Sprint.html), where I use a state machine to map out each of the acrobat's movement patterns. With this states, can easily convert them into code that makes the dropper move in the desired pattern: 

![DropperStateMachine](/files/DropperStateMachine.PNG)

The enemy can be in 3 states: IDLE, LEFT, and RIGHT. In the IDLE state, the enemy will take no action, waiting in anticipation for the enemy. When the player (Io) enters the enemy's aggro collider, a Unity event is called from the enemyAggro script that will transition the dropper from IDLE state to LEFT state. At this point, the dropper will move a a constant pace about the x-axis (the initial direction of the player) for a either a 2 seconds or until it collides with an object in the environment. At this point, the dropper then transitions to the RIGHT state, and will move in the opposite direction for 2 seconds. The script can be modified to make the dropper move in a particular direction for a longer period of time, or be programmed to change directions upon traveling a certain distance. If the player exits the enemy's aggro collider, a DeAggro event is triggered from the enemyAggro script which ends the dropper's movement and returns them to the IDLE state. 

<div style="width:100%;height:0;padding-bottom:59%;position:relative;"><iframe src="https://giphy.com/embed/SuIftmtORNk5bNfbxe" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/SuIftmtORNk5bNfbxe">via GIPHY</a></p>

While developing this enemy's movement, I ran into a few interesting issues. Firstly, I noticed that if the player exits the enemy's aggro collider, then enters it again, the dropper will move away from the player. This was caused due to my assumption that the player would continue to move right after killing the dropper or ignoring it. In order to make this less awkward, I modified the script so that it could detect the direction the player entered the dropper's collider. In this way, the script could then trigger the state the corresponds to the player's current direction, and move towards them. 

Another issue I faced dealt with the timing of the coroutine functions as the DeAggro event was being triggered. For this script, I utilized coroutines to execute the dropper's movement. Coroutines are functions which execution can be paused for a specified period of time, during which execution control is returned to Unity. Normal functions must have all its instructions be executed before returning. With coroutines, the dropper can move in a single direction across multiple frames before moving in the oppoiste direction. 

![dropperSynchonization](/files/MultiCoroutines.PNG)

The issue with the DeAggro event was that if another coroutine was waiting to return at the same time the DeAggro function was executing, it could overwrite the change to state (IDLE) the DeAggro event causes. This results in the dropper continuing to move in the opposite direction, despite the player having exited the enemy's aggro range. 

In order to fix this issue, I used a function in Unity's library called "StopAllCorountines()" which deactivates any coroutines that may be still running by the time the DeAggro event is triggered. If there happens to be no coroutines running, "StopAllCorountines()" does nothing. The inclusion of this function fixed the issue, and guarantees that no other coroutine overwites the state transition to IDLE. 

Acrobat prefab:
==================
