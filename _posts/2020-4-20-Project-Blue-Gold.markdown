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