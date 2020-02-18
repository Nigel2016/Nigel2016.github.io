---
layout: post
title: "Project Blue: Pre-Alpha 1 Sprint"
data:  2020-02-17 08:07:37
categories: game development
---

This will be my first blog post regarding my contributions to the WolverineSoft Studio's game project (currently dubbed Project Blue). We are conceptualizing and building a new action adventure game from the ground up using Unity as our game engine. 

What I do:

I am a programmer and designer on the Enemies team of the Project. As a designer, I am tasked with creating concepts for enemies that the player will encounter throughout their experience, and designing their movements and attacks. As a programmer, I am responsible for programming the artificial intelligence for the enemies, and creating C# scripts which other developers throughout the studio can use to tune the enemies behavior as they debug features in Unity's editor. 

Design:

For this sprint, I was tasked with drafting two enemy design concepts:

* The first enemy, the Gungnir, is a range based thrower that challenges the player into mastering the game's signature mechanic. The player's main use of navigating through the game enviornment is a weapon teleportation technique, where they can throw their weapon and rapidly warp to its destination. The Gungnir throws high velocity projectiles at the player. The idea behind this enemy is that ordinary manuevers (jumping and running) cannot be used to avoid its attacks. The weapon teleport mechanic must be utilized in order to dodge the Gungnir's fast attacks and to get close enough to the enemy in order to defeat it. 
//TODO: Insert image. 

* The second enemy, the Sniper, is a slow moving enemy that defy's gravity and shoots homing projectiles at the player. Rather than sticking to the ground, the Sniper moves through the environment by utilizing portals to warp and flank the player from behind. They fire bursts of magic missiles which will target's its prey with great precision. The motivation behind this enemy is to give the player another practical means of using the weapon teleportation mechanic to outmaneuver and kill opponents. All the while, they are a relatively easy enemy to defeat once the player realizes they can deflect the enemies projectiles. An idea I had for this enemy is if the player warps into, and strikes the missiles, they can deflect the missiles back at the Sniper, and kill it instantly. 


While coming up with these concepts, I thought about how they could positiviely enhance the player's experience. How can the enemies challenge the player's understanding of the game's mechanics, without being a huge burden on their progress? In what ways can enemies be used to make the weapon teleportation mechanic useful in combat, in addition to ordinary exploration? My intent was to design enemies which motivate the player to learn the weapon teleportation mechanic, and to challenge them into using this mechanic as a means of survival. 

Programming:

During this sprint, I was also responisble for creating a Flying Character Script. Given a 2D velocity (x,y), the script had to move a game object in that velocity's direction:

<div style="width:100%;height:0;padding-bottom:54%;position:relative;"><iframe src="https://giphy.com/embed/MdMOBgALWG84rSDJiB" width="100%" height="100%" style="position:absolute" frameBorder="0" class="giphy-embed" allowFullScreen></iframe></div><p><a href="https://giphy.com/gifs/MdMOBgALWG84rSDJiB">via GIPHY</a></p>

Through a public variable in my script, a developer can control the movement of the object by inputing a x and y value into the Unity editor. This script can also be referenced by other scripts to make objects fly, making it foundational for flying enemies that will eventually be featured in the game. 

My main difficulty with writing the script was figure out which methods in unity would be best for moving the object. There are many different methods avaliable that can manipulate the position of a game object.Some of these involve getting an objects "transform" component, and manually setting the x, y, and z positions of the component, or modifying the "RidgidBody" components movement by applying a force with the "AddForce" function. What I ultimately stored a reference to the "RidgidBody" in the script, then directly modifed it's velocity variable using a public variable. I believed that this would be the simplest way to modify the object. In the fututre, I will ask the lead developers on clarification regarding best practices for manipulating 3D objects as are code base becomes more complex.

Summary:

Overall, this sprint went smoothly. I believe that I was given tasks which were clear in scope, and could be done within the tiem constrait of the sprint (2 weeks). The only downside was that I was not given much work to complete. This is understandable, since the project has only just finished its conceptual phase. As development ramps up, there will be an abundance of opportunities to contribute code and design to the game.