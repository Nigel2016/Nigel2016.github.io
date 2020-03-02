---
layout: post
title: "Project Blue: Extended Pre-Alpha Sprint"
data:  2020-03-02 02:07:50
categories: game development
---

Leading up to the Spring Break Sprint for Project Blue, I worked on making AI for the game's Acrobat enemy. In addition, I working on a DevOps solution that will allow for our web developer's work to be automatically saved and pushed to the studio's github repo. I also created several prototypes inspired by games that I have been playing recently. 

Acrobat AI:

For this sprint, my main task was to implement the movement behaviors for the Acrobat enemy. The Acrobat is an agile enemy which has the following movement patterns:

![Movement](../files/AcrobatMovement.png)

The enemy must first detect the player by using a script called "EnemyAggro." The enemy is surrounded by a sphere collider; when the player enter's this spear, an event called "OnAggro" is triggered. Upon detecting the player, the enemy will leap to the players location in order to detect them. Upon executing this attack, there is a brief cooldown, and then the enemy will reset by performing a "repose" to a nearby wall. 

In order to implement this behavior, I modeled the Acrobats behavior to a finite state machine: 

![StateMachine](../files/AcrobatStateMachine.PNG)

In the Acrobat's movement script, one function is used to control the movements of the enemy. We can model the movements into three states: "dormant", "leap", and "repose". In the script, there is a check to determine what the current state of the enemy is, then the enemy's movement is modify by directly accessing its "FlyingMovementScript" component (component that moves the enemy given a desired velocity). 

In the dormant sage, we make sure that the enemy is not movement by zeroing out their velocity. Upon an "OnAggro" event, the enemy's aggro script will execute a function that changes the acrobat's state to Leaping, and then set the enemy's velocity to launch into the direction of the player. If the enemy still has sight of the player, it will transition to the "repose" stage, and return to its original location. This behavior is repeated until the player exits the Acrobat's aggro range. A deaggro event is executed in thsi case, and the enemy is transitioned back to "dormant." 

<div style="width:100%;height:0;padding-bottom:54%;position:relative;"><iframe src="https://giphy.com/embed/kxl8E6lOuWr2QSqtaz" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/kxl8E6lOuWr2QSqtaz">via GIPHY</a></p>

Rsync Version Control

