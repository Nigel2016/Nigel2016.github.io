---
layout: post
title: "Project Blue: Acrobat Collisions and AI Improvement"
data:  2020-4-6 04:55:37
categories: game development
---

Over the past few weeks, I focused my efforts on improving the Acrobat enemy. I improved the Acrobat's repose mechanic so that it will move to a nearby ceiling after attacking the player. I also wrote code that allows the Acrobat that to move side by side (instead of from floor to ceiling), as well as a basic collision and bounce back when the Acrobat collides with the player.

Acrobat AI: Better Repose (15 Hours) (significant time debugging)
==================

![FinalAcrobatArt](/files/AcrobatArt.PNG)
![Movement](/files/AcrobatMovement.png)
The Acrobat is an enemy which has two movement behaviors: Leap and Repose. When the enemy leaps, it attacks the player's current location. When it has completed this attack, after a short cooldown, it will do a repose move where it moves back to the ceiling. Originally, the enemy would simply return to its original location:

<div style="width:100%;height:0;padding-bottom:54%;position:relative;"><iframe src="https://giphy.com/embed/kxl8E6lOuWr2QSqtaz" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/kxl8E6lOuWr2QSqtaz">via GIPHY</a></p>


While this approach worked fine, I talked to my project lead to see if there were a better way of doing the repose. I came up with the idea of modifying the repose so that instead of the Acrobat returning to its original position, it could instead move to a part of the ceiling that is closest to the player.

![NewAcrobatMovement](/files/NearestCeiling.PNG)


Now, instead of traveling back to its origin, the Acrobat could present a more interesting challenge to the player. With this movement style, it is possible for the Acrobat to briefly pursue the player if they (player) try to outmaneuver from it. Also, this would potentially make the Acrobat's movement seem more natural. This is the final result of implementing this change:

<div style="width:100%;height:0;padding-bottom:49%;position:relative;"><iframe src="https://giphy.com/embed/ggFDUwYu7rc3Krtde8" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/ggFDUwYu7rc3Krtde8">via GIPHY</a></p>

Implementing better repose for the Acrobat took a significant amount of time to debug: it took me a day or so figure out my previously mentioned improvement. While googling ways to send the Acrobat in a direction, I came across the idea of vector orthogonality. The idea behind this Linear Algebra concept is that if you have two vectors that form a 90-degree angle, there are considered perpendicular to each other. Moreover, if I added these two vectors together, then the result is a diagonal vector. From here, I read Unity's documentation on Vector2 (x,y) vectors and was able to come up with the math that I needed to get the Acrobat to repose in the desired direction:

![RightDiagonal](/files/RightDiagonal.PNG)

I modified the coroutine controlling the repose movement to calculate the direction the player is from the Acrobat. Then, depending on which direction the player was, my script would then move the Acrobat diagonally in that direction. I took advantage of the Vector2 Interfaces Up, Left, and Right vectors to calculate the new direction of the Acrobat. By adding a Vector2.Up (0, 1) and a Vector2.Right (1, 0), you get a vector that is diagonal in the right direction (1, 1). 

![LeftDiagonal](/files/LeftDiagonal.PNG)

You can also produce a left diagonal vector (-1, 1) by adding a Vector2.Up (0,1) to a Vector2.Left (-1, 0). When the player's direction is calculated, we set the Acrobat's velocity to be equal to the correct diagonal direction, and move it there.  

Moreover, I ran into several issues with Acrobat's movement that took the majority of my time to debug. In one issue, the Acrobat would become stuck on the wall, moving in the direction of the player. However, once it got stuck in a corner, it would no longer move. 

To figure out the cause of the issue, I wrote a function that would print out the state of the private variables I used to implement the script, the most important of which is my variable which indicates the player's current state. What I noticed was that this issue was happening between the enemy gained, and suddenly lost, aggro. I traced this issue to two boolean variables I was using to decide whether or not the enemy should perform a behavior, and change state: "canAct" and "midAction"

~~~
    private void Action()
    {
        if(canAct && !midAction)
        {
            if(enemyCurrentState == State.DORMANT)
            {
                enemyScript.desiredVelocity = Vector2.zero;
            }
            else if(enemyCurrentState == State.LEAP)
            {
                StartCoroutine(LeapAttack());
                enemyCurrentState = State.REPOSE;
            }
            else if(enemyCurrentState == State.REPOSE)
            {
                StartCoroutine(Repose());
                enemyCurrentState = State.LEAP;
            }
        }
    }
~~~

In my deaggro function, which is called when the player exits the enemy's aggro range, I forgot to reset the midAction variable to be false. As a result, the midAction variable became always set to true and would lock the Acrobat out of performing another action when aggro is obtained again. 

To resolve this issue, I got rid of the midAction variable. I realized if I properly set my canAct bool to false when every I entered a coroutine, and set it back to true immediately after the given coroutine's yield call returns, I could always guarantee that another coroutine would not start until the current one finishes. Moreover, I made sure the reset canAct and the Acrobat's state variable so that it could properly act again when the player regains its aggro. 


Acrobat: Collision Knockback (10 hours)
==================

For my next assignment, I was tasked with making the Acrobat's collisions with the player seem more natural. An idea that my pod lead gave me was to have the acrobat bounce away from the player upon collision and have it drop to the ground. In the previous implementation of the acrobat script, collisions were not handled at all. As a result, the Acrobat would become stuck midair where it hit the player until it reposed back to the ceiling. By implementing a basic knockback mechanic, interactions between the player and acrobat could look smoother, and more realistic. 

To begin implementing this, I began to think of different ways that the bounce-back could be handled. Essentially, the acrobat must move in a curve from the point of contact from the player to the ground. After doing some searching online, the idea of bezier curves came to mind:

<div style="width:100%;height:0;padding-bottom:42%;position:relative;"><iframe src="https://giphy.com/embed/H7g2aeaA307GKUockQ" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/H7g2aeaA307GKUockQ">via GIPHY</a></p>

In a bezier curve, there are 3 points: P0 is the starting point for the moving object. P2 is the endpoint, and P1 is the midpoint between P0 and P2. When the object moves, it will move in a curve formed by connecting the lines (P0, P1) and (P1, P2), and the object will move along this curve until it reaches P2. I incorporated the bezier curve into my code, and got smooth, curved, movement as a result:

<div style="width:100%;height:0;padding-bottom:49%;position:relative;"><iframe src="https://giphy.com/embed/Qub9DYfrNIRBi7vec3" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/Qub9DYfrNIRBi7vec3">via GIPHY</a></p>

However, an issue shows up when the player collides with the enemy in midair: with my attempted implementation, the enemy will begin to move down but will stop when it reaches the y-axis of the player. This results in the Acrobat becoming stuck in midair and within the environment background:

<div style="width:100%;height:0;padding-bottom:49%;position:relative;"><iframe src="https://giphy.com/embed/YrAw2xmYms6biUhUOL" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/YrAw2xmYms6biUhUOL">via GIPHY</a></p>

If there was a way to calculate the endpoint, such that we knew ahead of time where the best place for the Acrobat to land after being knocked back, then this issue would be solved by calculating P2 = (the desired x, desired y). However, without knowing where the level designers will place the acrobat, and no functions available in the unity library (from my knowledge), this would not be possible. 

For the sake of getting my task done on time, I ended up using Unity's physic's engine to implement the knockback mechanic:

<div style="width:100%;height:0;padding-bottom:49%;position:relative;"><iframe src="https://giphy.com/embed/mC0fnqvJ82D40Qd4Cs" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/mC0fnqvJ82D40Qd4Cs">via GIPHY</a></p>

Upon colliding with the player, I calculated the direction of the impact within Unity's OnCollisionEnter function. From here, I define a new state to transition the enemy to KNOCKBACK. In this state, I apply a constant force in the opposite direction of the collision, throughout several frames. As a result, a rough, but functional, knockback is achieved.

While implementing this functionality, I had to spend several hours debugging the Acrobat's movement behaviors. One of the major issues I faced with this script was applying the force onto Acrobat over several frames. I struggled with multiple bugs, including the Acrobat's movement being broken after one leap, as well as an issue with the force not being applied at all. Most of these issues came down to making sure that the script's internal variables were updated to enable the acrobat to transition back to the REPOSE state after the knockback is complete. I also resolved an issue where the Acrobat could lose aggro while being knocked back. Overall, using the 2D physics engine was straightforward, and the knockback works well. However, I will continue to improve upon the Acrobat's functionality in the coming weeks leading up the project's "Gold" deliverable. 

Side-By-Side Acrobat (5 hours): 
==================

As an additional task, I modified my Acrobat script so that it could move the Acrobat Side-by-Side, instead of moving from ceiling to floor: 

<div style="width:100%;height:0;padding-bottom:50%;position:relative;"><iframe src="https://giphy.com/embed/QW9KJ6aXPmchvpQCyc" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/QW9KJ6aXPmchvpQCyc">via GIPHY</a></p>

The side by side functionality can be activated by level designers in the unity editor; a public boolean can be checked which enables the Acrobat to move in this way. This could be useful for placing the Acrobat in narrow pits, as a trap to players. However, if the player collides with the enemy, then it would fall to the ground due to the knockback implementation. To address this issue, I spoke to one of the WolvenSoft Studio leads; he suggested making the Acrobat's 2D box collider into a trigger. This would prevent the Acrobat from being moved by the player: and would allow for it to perform its movement behaviors without being interrupted by any other physical object. However, some tweaking to the prefab (and potentially some code changes) may be necessary to get this working. I will attempt to implement this feature in the next sprint and will discuss its results (successful or not) in the next blog post. 

