---
layout: post
title: "Project Blue: Extended Pre-Alpha Sprint"
data:  2020-03-02 02:07:50
categories: game development
---

Leading up to the Spring Break Sprint for Project Blue, I worked on making AI for the game's Acrobat enemy. In addition, I working on a DevOps solution that will allow for our web developer's work to be automatically saved and pushed to the studio's github repo. I also created several prototypes inspired by games that I have been playing recently. 

Acrobat AI:
==================

For this sprint, my main task was to implement the movement behaviors for the Acrobat enemy. The Acrobat is an agile enemy which has the following movement patterns:

![Movement](/files/AcrobatMovement.png)

The enemy must first detect the player by using a script called "EnemyAggro." The enemy is surrounded by a sphere collider; when the player enter's this spear, an event called "OnAggro" is triggered. Upon detecting the player, the enemy will leap to the players location in order to detect them. Upon executing this attack, there is a brief cooldown, and then the enemy will reset by performing a "repose" to a nearby wall. 

In order to implement this behavior, I modeled the Acrobats behavior to a finite state machine: 

![StateMachine](/files/AcrobatStateMachine.PNG)

In the Acrobat's movement script, one function is used to control the movements of the enemy. We can model the movements into three states: "dormant", "leap", and "repose". In the script, there is a check to determine what the current state of the enemy is, then the enemy's movement is modify by directly accessing its "FlyingMovementScript" component (component that moves the enemy given a desired velocity). 

In the dormant sage, we make sure that the enemy is not movement by zeroing out their velocity. Upon an "OnAggro" event, the enemy's aggro script will execute a function that changes the acrobat's state to Leaping, and then set the enemy's velocity to launch into the direction of the player. If the enemy still has sight of the player, it will transition to the "repose" stage, and return to its original location. This behavior is repeated until the player exits the Acrobat's aggro range. A deaggro event is executed in thsi case, and the enemy is transitioned back to "dormant." 

<div style="width:100%;height:0;padding-bottom:54%;position:relative;"><iframe src="https://giphy.com/embed/kxl8E6lOuWr2QSqtaz" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/kxl8E6lOuWr2QSqtaz">via GIPHY</a></p>

Rsync Version Control:
==================

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

![rsync](/files/rsync.PNG)

The script must be ran as a process on the server where the website's repository is located. Rsync must be able to establish a connection with the web developer's computer, and pull any changes that the developer makes into the server repository. I will continue to work on this solution in the comming weeks, and will give an update in the next blog post. 

Enemies spawning enemies:
==================

A few weeks ago, Nikhil, the enemy pod leader, was thinking about a prototype concept of an enemy that spawns sub enemies. This is a pattern
that is common in many games: one infamous example is from the Library level in Halo Combat Evolved:

<figure class="video_container">
  <iframe width="560" height="315" src="https://www.youtube.com/embed/90-8dTwn7-4?start=675" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</figure>

In this level, "flood" are the primary enemies to the player. When the player shoots the larger flood, they split into smaller, more agile, opponents. This level has been an annoyance to those in the Halo community, as these flood enemies not only spawn infinitely, but are relentless when grouped together. 

I began to think of how this could be implemented in project blue. Two methods came to mind:
    -There can be enemies that are deactivated hidden in the level. When a trigger in the environment is tripped, they are activated. 
    -Enemies can be spawned from an object pool: while the player is engaged with a superior foe, smaller opponents can spawn from a 
     fixed location in the enviornment. 

For the first idea: I drew a rough sketch of what this would look like in a 2D game:

![disableEnabledEnemies](/files/enemyTriggered.PNG)

We can have a fixed container of hidden enemies. When the player enters the aggro range of an opponent, we simply iterate through the container,
and activate each of the enemies's game objects. This is a straightforward implementation which a developer could quickly implement: create the 
hidden foes, then place them into the game enviornment. We then need to setup an aggro script so that we can activate the hostiles on a Unity aggro event. A demonstration of this is below:
 
 <div style="width:100%;height:0;padding-bottom:54%;position:relative;"><iframe src="https://giphy.com/embed/QU4LFwb6HXUqVJBL7D" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/QU4LFwb6HXUqVJBL7D">via GIPHY</a></p>

However, you would need to have many of these objects in your game scene at once. Depending on avaliable resources, this may prove to be costly. Moreover, there is no point in these objects being in the game enviornment if they have not been triggered yet. In addition, you would need to ensure that there is logic in your game code so that all of these enemies do not spawn at once. This is where object pooling might be useful: 

![ObjectPool](/files/ObjectPool.PNG)

With the object pool method, you can place an invisible "portal" within your game enviornment. When the player gets the attention of an enemy, an event can be sent to this portal, telling it to spawn some enemies. To ensure that the player is not overwhelmed, you can write logic to control the maximum number of enemies that spawn from this portal at a time. When the enemy is killed, the spawn portal can be destroyed. With this method, you could have a manageble means of spawning infinite enemies while a player is enaged with a more superior opponent. In addition, you spawn enemies exactly when you need them, as opposed to keeping them idle in the enviornment. 

However, great care has to be taken when designing game mechanics that revolved around respawning opponents. As mentioend in the Halo example, respawning enemies can be a great hinderance to the player's progress, and not challenge them in a meaningful way. Killing the same enemy repeatly over a long strech of gameplay is arguably not a sound way of keeping audiences engaged with the experience. 

Conclusion:
==================

One of the biggest challenges in this sprint was to balance my work on the studio project with my other classes. This past week, I had a midterm in my Operating System's class (EECS 482), in addition to a project being due in this class a few days before. This was by far one of my most stressful weeks while being a student at the University of Michigan. EECS 482 has a negative atmosphere around it: it is considered by many to be one of the hardest classes at the University, with time consuming (difficult) projects and hard exams. I am doing my best to equally distribute time across all of the class I am taking this semester, using resources such as google calendar to block specific times to focus on specific subjects. In addition, I am reaching out to other students taking the class, so that I can form study groups to prepare for the final exam.

In addition, I must ensure that I seek out additional assignments for Project Blue, to go alongside my mandatory ones. I am currently expected to contribute 30 hours biweekly to the project. However, I have not been assigned enough work from my pod leader in order to reach this. To ensure that I am working full time, I will come up with interesting features to experiment with and implement during the future sprints. I have played several games recently (such as the phenomenal Celeste) and have ideas for concepts from those games I would like to recreate. Although they may not end up in the game, working on these featurres will give me more experience programming gameplay, and will help me sharpen my Unity and C# skills. 