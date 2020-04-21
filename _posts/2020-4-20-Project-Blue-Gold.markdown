---
layout: post
title: "Io: Script Iteration"
data:  2020-04-20 08:14:50
categories: game development
---

The gold sprint is the Final deliverable for Project Blue, now known officially as Io. During the entire sprint, I spent the entirety of my time iterating upon my implementation of the Acrobat AI script. 

Acrobat's Not Triggering: (5 hours)
==================

In the beta build of the game, it was descovered by one of the lead developers for the studio that the Acrobat enemies in the level would not move. When the player reached the Aggro range of the Acrobat, it would take no action:

<div style="width:100%;height:0;padding-bottom:57%;position:relative;"><iframe src="https://giphy.com/embed/M9lZJO8oNKibT4Y5mw" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/M9lZJO8oNKibT4Y5mw">via GIPHY</a></p>


This bug was very frustrating for me to hear about. In my local development scene, the Acrobat appeared to be working fine. However, I realized that my development scene could have been out of date with the official scene for the game. In order to figure out this issue, I first reviewed my acrobat movement code, making sure I did not accidently add a change that would prevent the enemy from moving. I placed several debug statements in my code that would print information regarding the internal state of the Acrobat. From the statements that I saw, I could confirm that the coroutines I set up to move the Acrobat were not activating. 

![TriggerIssues](/files/AcrobatTriggeringIssues.PNG)

Something outside of the Acrobat script was causing it not to move. The only component on the prefab that could be problematic is the Aggro child. 

![Aggro](/files/AcrobatAggroObject.PNG)

While reviewing the Aggro object's settings, I noticed that there was a variable named "Raycast Line of Sight" which I paid no attention to while working on the Acrobat. I began to suspect that either this setting, or the Raycast Layer Mask, was causing tthe Acrobat to not move. These variables belong to the EnemyAggro script, which contains logic for how the enemy uses its circle collider to detect players. Which looking over the code, I found a problematic section that could cause the issue: 

~~~~~~~~
    private void OnTriggerEnter2D(Collider2D other) {
        // Invoke OnAggro when the player enters the enemy's trigger or enter search mode
        if(other.gameObject.CompareTag("Player"))
        {

            if (raycastLineOfSight)
            {
                isSearching = true;
            }
            else
            {
                target = other.gameObject;
                OnAggro.Invoke();
            }
        }
    }
~~~~~~~~

Due to several project deadlines that came up in my other classes, I did not have time to completely understand the enemyAggro code. However, it appears that by having the raycastLineOfSight variable on, the script is unable to obtain a reference to the Acrobat's target (which is the player). After turning this variable off, the Acrobat's in the level began to move again:

<div style="width:100%;height:0;padding-bottom:57%;position:relative;"><iframe src="https://giphy.com/embed/j03uuJLlkwiD7BDH9E" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/j03uuJLlkwiD7BDH9E">via GIPHY</a></p>

It is likely that this setting was intended for an enemy which actively patrols for the player: the stalker, for instance, will move back and forth in a segment of the level until it finds a player to attack. The Acrobat, on the other hand, remains idle on the ceiling until a player enters its aggro range. I was reliving that this was the only issue causing the Acrobat to not move. 

After fixing the bug with the Acrobat's aggro, I had to ensure that the Acrobats in the official scene, known as the Crystal Cave, behaved appropriately. After my fix was merged into the development branch, I immediately went into the crystal cave's scene, and turned off the raycast variable on all the Acrobats. Overall, while frustrating, it was overall straightforward to fix. 

Acrobat AI Iteration: (25 hours)
==================

A few weeks ago, I changed the Acrobat's prefab collider into a trigger. This change was intended to improve the collisions that the enemy would have with the player. If the object were a trigger, it would stop the player from moving the Acrobat and interrupting its movement patterns. However, while this seemed to work decently when I first implemented it, my change was later found to be buggy. The acrobats would frequently fly through the Crystal Cave's terrain, while attack the player from unexpected angles:

<div style="width:100%;height:0;padding-bottom:57%;position:relative;"><iframe src="https://giphy.com/embed/l1Bn7XpAq0QVOtUUDH" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/l1Bn7XpAq0QVOtUUDH">via GIPHY</a></p>

This bug made the Acrobat frustrating to fight during the Wolverinsoft Studio playtests. Moreover, I did not intend for this issue to occur: at the time that I tested the change, I was unable to reproduce such a jarring bug. For the remainder of the Studio's gold sprint, the last deliverable before the game was released, I spent a significant amount of time fixing this bug, and improving upon the movement patterns of the Acrobat.

I spent several hours attempting to get the trigger collider code to better detect Terrain. I tried using the Unity library's "IsTouching" function to prevent non-player objects from triggering the Acrobat collider. In addition, I put in tag comparisions in order to detect the type of object which triggered the Acrobat: upon hitting an object tagged as "Terrain" or "Hazard", I would set the acrobat's velocity to zero. However, these changes were not enough to consistently prevent the Acrobat's from penetrating the terrain. 

With the final deadline looming, and after several failed attempts, I ended up reverting the Acrobat's collider into a default one. Having the Acrobat as a trigger turned out to be more problematic for physics with the environment, and was ultimately too difficult for me to get working within the project's time constraints. 

Acrobat: Fixing Unpredictability
==================

Another piece of feedback that I recieved during the studio's playtest session was that the Acrobat's movement behaviors were too unpredictable. Upon leaping to the player, the Acrobat would repose back to the ceiling, diagonally in the player's direction:

![OriginalImplementation](/files/NearestCeiling.PNG)

 While this made the enemy with challenging behavior for the player to overcome, it ultimately proved to be more of an annoyance to players. Without a way to determine where the Acrobat would move next, the player's became frustrated with the enemy, and ended up skipping them all together.

<div style="width:100%;height:0;padding-bottom:57%;position:relative;"><iframe src="https://giphy.com/embed/hogR4W4fEl2iN951pq" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/hogR4W4fEl2iN951pq">via GIPHY</a></p>

After discussing this issue with my team lead, I decided to go back to a previous implementation of the Acrobats repose movement: instead of leaping in a direction towards the player, the enemy would simply return to its origin location in the environment: 

After implementing this change, I realized that consistent attack patterns were key to having a fun enemy AI to fight against. Consistent movement allows for the player to anticipate attacks, anaylze them, and then react to them in a swift manner. The previous implementation made the Acrobat more irradicaly, and resulted in a negative player experience overall. 

Acrobat: Smoother Movement, and syncing state
==================

In addition to making the Acrobat's movement more consistent, I working on making the Acrobat's movements smoother. Previously, the Acrobat would suddenly attack the player, charging at them at a high speed. This would give the player little time to react to the attack, and prevent them from counterattacking before the enemy decides to repose back to tthe ceiling. While looking up how to implement this online, I came across a nice formula that worked well: 

~~~~~~~~~~~~
enemyScript.desiredVelocity = (location)  * speed * Time.fixedDeltaTime;
~~~~~~~~~~~~

To set the enemy's velocity, I took the location I wanted the Acrobat to move in, and amplified it by a speed constant. What is ket to making the Acrobat's movement feel gradual is Time.fixedDeltaTime. This variable gives an interval, in seconds, at which physics in the game are running. by multiplying the velocity by this variable, this allows for the velocity to be applied over time, as apposed to being done at an instant.

Moreover, I took the opportunity to iron out some difficult bugs I have noticed in the 