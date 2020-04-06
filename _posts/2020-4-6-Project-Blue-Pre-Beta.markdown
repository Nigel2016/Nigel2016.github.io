---
layout: post
title: "Project Blue: Acrobat Collisions and AI Improvement"
data:  2020-4-6 04:55:37
categories: game development
---

Over the past few weeks, I focused my efforts on improving the Acrobat enemy. I improved the Acrobat's repose mechanic so that it will move to a nearby ceiling after attacking the player. I also wrote code that allows the Acrobat that to move side by side (instead of from floor to ceiling), as well as a basic collision and bounce back when the Acrobat collides with the player.

Acrobat AI: Better Repose (15 Hours) (significant time debugging)
==================

The Acrobat is an enemy which has two movement behaviors: Leap and Repose. When the enemy leaps, it attacks the player's current location. When it has completed this attack, after a short cooldown, it will do a repose move where it moves back to the ceiling. Originally, the enemy would simply return to its original location:

While this approach worked fine, I talked to my project lead to see if there were a better way of doing the repose. I came up with the idea of modifying the repose so that instead of the Acrobat returning to its original position, it could instead move to a part of the ceiling that is closest to the player:

Now, instead of traveling all the way back to its origin, the Acrobat could present a more interesting challenge to the player. With this movement style, it is possible for the Acrobat to briefly pursue the player if they (player) try to out manuever from it. In addition, this would potentially make the Acrobat's movement seem more natural. This is the final result of implementing this change:

In order to do this, I modified the coroutine controlling the repose movement to calculate the direction the player is with respect to the Acrobat. Then, depending on which direction the player was, my script would then move the Acrobat diagonally in that direction:

I took advantage of the Vector2 Interfaces Up, Left, and Right vectors to calculate the new direction of the Acrobat. By adding a Vector2.Up (0, 1) and a Vector2.Right (1, 0), you get a vector that is diagonal in the right direction. You can also produce a left diagonal vector by adding a Vector2.Up to a Vector2.Left. When the player's direction is calculated, we set the Acrobat's velocity to be equal to the correct diagonal direction, and move it there. 

Implementing better repose for the Acrobat took a significant amount of time to debug: it took me a day or so figure out my previously mentioned improvment. While googling ways to send the Acrobat in a direction, I came across the idea of vector orthagonality:

The basic idea behind this Linear Algebra concept is that if you have two vectors that form a 90 degree angle, there are considered perpendicular to each other. Moreover, if I added these two vectors together, then the result is a diagonal vector. From here, I read Unity's documentation on Vector2's and was able to come up with the math that I needed to get the Acrobat to repose in the desired direction. 

Moreover, I ran into several issues with the Acrobat's movement that took the majority of my time to debug. In one issue, the Acrobat would become stuck on the wall, moving in the direction of the player. However, once it got stuck in a corner, it would no longer move. I initially tried to exit, then re-enter the Acrobat's aggro range; however, this did not cause it to move again:

To figure out the cause of the issue, I wrote a function that would print out the state of the private variables I used to implement the script, the most important of which being my variable which indicates the player's current state. What I noticed was that this issue was happening between the enemy gained, and sudden lost, aggro. I traced this issue to two boolean variables I was using to decide whether or not the enemy should perform a behavior, and change state: "canAct" and "midAction"

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

In my deaggro function, which is called when the player exits the enemy's aggro range, I forgot to reset the midAction variable to be false. As a result, the midAction variable became always set to true, and would lock the Acrobat out of performing another action. 

To resolve this issue, I got rid of the midAction variable. I realized if I properly set my canAction bool to false when every I entered a coroutine, and set it back to true immediately after the given coroutine's yield call returns, I could always guarantee that another coroutine would not start until the current one finishes. 

Acrobat: Collision Knockback (10 hours)
==================

For my next assignment, I was tasked with making the Acrobat's collsiions with the player seem more natural. 