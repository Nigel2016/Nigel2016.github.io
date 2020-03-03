---
layout: post
title: "Project Blue: Extended Pre-Alpha Sprint"
data:  2020-03-02 02:07:50
categories: game development
---

Leading up to the Spring Break Sprint for Project Blue, I worked on making AI for the game's Acrobat enemy. In addition, I working on a DevOps solution that will allow for our web developer's work to be automatically saved and pushed to the studio's github repo. I also created several prototypes inspired by games that I have been playing recently. 

Acrobat AI:

For this sprint, my main task was to implement the movement behaviors for the Acrobat enemy. The Acrobat is an agile enemy which has the following movement patterns:

![Movement](/files/AcrobatMovement.png)

The enemy must first detect the player by using a script called "EnemyAggro." The enemy is surrounded by a sphere collider; when the player enter's this spear, an event called "OnAggro" is triggered. Upon detecting the player, the enemy will leap to the players location in order to detect them. Upon executing this attack, there is a brief cooldown, and then the enemy will reset by performing a "repose" to a nearby wall. 

In order to implement this behavior, I modeled the Acrobats behavior to a finite state machine: 

![StateMachine](/files/AcrobatStateMachine.PNG)

In the Acrobat's movement script, one function is used to control the movements of the enemy. We can model the movements into three states: "dormant", "leap", and "repose". In the script, there is a check to determine what the current state of the enemy is, then the enemy's movement is modify by directly accessing its "FlyingMovementScript" component (component that moves the enemy given a desired velocity). 

In the dormant sage, we make sure that the enemy is not movement by zeroing out their velocity. Upon an "OnAggro" event, the enemy's aggro script will execute a function that changes the acrobat's state to Leaping, and then set the enemy's velocity to launch into the direction of the player. If the enemy still has sight of the player, it will transition to the "repose" stage, and return to its original location. This behavior is repeated until the player exits the Acrobat's aggro range. A deaggro event is executed in thsi case, and the enemy is transitioned back to "dormant." 

<div style="width:100%;height:0;padding-bottom:54%;position:relative;"><iframe src="https://giphy.com/embed/kxl8E6lOuWr2QSqtaz" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/kxl8E6lOuWr2QSqtaz">via GIPHY</a></p>

Rsync Version Control:

Another tasks that I was assigned with recently is releated to DevOps. Currently, we have a web developer who is working on Project Blue's promotional website. 

Whenever they write code to modify the website's interface, they have to manually add, commit, and send the changes that they make to the server which is hosting the website. My task was to research rsync, a file transfering tool avaliable in Linux systems, and come up with a solution that would automatically update the repository whenever the a change is made to it. To begin this task, I developed a script which allows for me to automatically send changes I make to my website repository to a repository belonging to my CAEN account (a computing resource provided to computer science students at the University of Michigan): 

~~~
#! /bin/bash

DIRECTORY="~/test_project_blue"
SOURCE="/mnt/c/users/123ch/Nigel2016.github.io/*"
DESTINATION="ndcharle@oncampus-course.engin.umich.edu"

while true; do
    sudo rsync -ruve ssh ${SOURCE} ${DESTINATION}:${DIRECTORY}
    sleep 10
done
~~~

The script here will perform the rsync command every 10 seconds: it takes code in a source directory and attempts to send it to "${DESTINATION}:${DIRECTORY}." The only issue with this script is that "oncampus-course.engin.umich.edu" is a domain belonging to my University, and requires me to login using my CAEN password whenever I want to establish a connection. A better solution would require for this login process to be done automatically, if not skipped.

Moreover, the actual solution should look something like this: 

![Movement](/files/rsync.png)

The script must be ran as a process on the server where the website's repository is located. Rsync must be able to establish a connection with the web developer's computer, and pull any changes that the developer makes into the server repository. I will continue to work on this solution in the comming weeks, and will give an update in the next blog post. 

