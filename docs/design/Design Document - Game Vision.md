This document describes the vision for the game, what kind of experience we want players to have in terms of gameplay (no audio and art style discussed).

*Note: below explanation is designed to be made in a very short amount of time. Therefore, this a set of features stripped to minimum. Stretch goals have been excluded from this document.*

### What makes tower defence games fun?
4 pillars of tower defence game:
1. **Sense of Progression** - little enemies, little towers and not much going on initially then there are huge amounts of monsters, lots of towers shooting fast etc.
2. **Player Choices**, its about giving players a lot of choices so they can experiment and play with different things and approaches. there is no need to think too much about validity of various strategies, its ok if there is one strategy that is much stronger as long as its not obvious and requires players to play around with different things
3. **Challenge**, need to worry about tower placement and types of tower use, how to spend resources in the best way. Ideally, palyers should not be able to beat the level the first time, they should use their first run to learn things and then do better next time
4. **New Features Over Time** - players discover things over time instead of game offering everything to the player everything at once, let players discover things slowly over time (new monster types, new towers)
To make the game fun the 4 pillars need to be satisfied.

### Tower Charging System
Our twist on tower defence game is the charging system. The system is meant to be a core game mechanic, rather than something extra. The goal of it is to emphasise the **charge** theme, introduce originality to the game, make gameplay more engaging and provide an extra dimension for player strategy.

Charging mechanic:
- every tower can be rubbed to make it more powerful temporarily
- the more tower is rubbed to more powerful it becomes
- towers can be charged **positively** or **negatively**, both charges will make it stronger but different charge will be better at countering different enemy types

Overcharge mechanic
- reaching maximum charge makes tower enter an even more powerful mode that will last very short period of time
- towers will have to rest after getting overcharged and won't be able to shoot during this time

Player interaction with the mechanic:
- players will have to learn which monsters are countered by positive charge and which ones by the negative charge
- tower rubbing requires a bit of skill, players who can rub faster will be able to boost their towers more rapidly
- players will need to learn timings of overcharging
- overcharging system will affect how players place towers. For example, they can consider spreading the towers such that they can chain overcharges as monsters traverse the path
-  in certain scenarios, players are expected to try to edge several towers so maintain them at high level instead of reaching overcharge
- players are expected to precharge towers as monsters approach

### Upgrade system
All tower defence games have some tower upgrading system. I'm proposing a different approach to upgrades then classical tower defence games. Normally towers are upgraded individually, in our game we will upgrade the AI core which will upgrade all existing tower in the system. However, it will only upgrade the towers that are already in the grid. New towers will start at lvl 1 even if player upgraded core.

The motivation for this system is because it's faster to make and it also provides an interesting choice for the players. Upgrading entire tower grid will cause a huge spike in power. However, these will be expensive and its cost will grow exponentially. 

Skilled players will try to delay using upgrade so they can upgrade larger number of towers at once which will help them in the long run. Players will also have to learn about power spikes in incoming waves, and don't delay upgrading too much.

### Monster Types
Ghosts type will be affected by 2 dimensions:
1. Type
	- Regular ghosts
	- Fast but less tanky ghosts
	- Boss ghosts, more tanky but much slower
2. Charge
	- no charge
	- positively charged (countered by negatively charged towers)
	- negatively charged (countered by positively charged towers)
All combinations generate 9 monster types total that will be introduced progressively over time

All monsters will do 1 damage, except bosses which will do more.

Monster ectoplasm drops will scale at the same time as their hp (explained in Wave System below)

### Wave System
Waves will consist of batches of monsters of various types, for example 5 regular ghosts, 5 fast ghosts, 5 regular ghosts, 5 regular positively charged ghosts. So, 4 batches 5 monsters in each.

Over time there will be more batches and more enemies which will be another dimension of scaling difficulty of the game. At the same time it will make it so that more is going on on the screen over time and income generation accelerates.

Wave Scaling
- waves 1-4 will consist of 1 batch of regular monsters, the batch size will scale with each wave
- wave 5 is where new monster type gets introduced and the number of batches increases
- wave 6-9 here we start introducing wave types (explained below) and also keep scaling batch size like in waves 1-4
- wave 10 will be a boss wave
- after boss all monsters become more tanky
- repeat the above until all monster types are in the pool
- last wave will consist of bosses only

**Wave Types**
To make things more interesting we can design wave types, for example a regular wave type would consist only of regular monsters, while fast waves will have large portion of fast monsters, boss waves will contain a boss, mix wave will contain a large variety of monsters etc.

### Tower Types
All towers will shoot in the same way. 1 projectile attacking 1 enemy. Towers will only differ by things that are simple to scale - damage, firing rate and range

Tower types:
- t1 regular tower, cheapest average in all aspects
- t2 towers, these are more expensive but are better
	- high damage tower
	- fast attack rate tower
	- high range tower
- t3 towers, these are more expensive than t2, very strong in 2 aspects but weak in other
	- very high damage and attack rate but very low range
	- very high damage and range but very low rate
	- very high range and rate but low damage

Tower shape
- ideally the towers should have different shapes and sizes so that players need to think more about tower placement
- if it's too much for art pipeline, we can consider making all towers occupy 4 tiles (2x2) and just use different colors for towers so they can be distinguished, at the same time tower projectiles will be recoloured accordingly


### Back to the pillars
How do the above systems achieve what's needed for a good tower defence experience?
1. **Sense of Progression**
	- more towers over time
	- towers improve over time
	- more monsters per batch in a wave increase
	- number of batches in a wave increases
	- more ectoplasm drops
  2. **Choices**
	  - which towers to choose
	  - where to place towers
	  - when to upgrade towers
	  - which towers to charge
	  - charge positively or negatively
	  - when to charge
	  - when and whether to overcharge
  3. **Challenge**
	  - players won't know many things so they will have to observe, learn and retry again
	  - players will not know how charging works initially
	  - players won't know how strong each tower is
	  - player's won't know how strong core upgrade is
	  - players won't know what monster types to expect
	  - players won't know how monsters scale
4. **New Features Over Time**
	- players won't be able to afford all tower types initially, so they will be able to use 1 only initially and then get more choices laters
	- players will discover different monster types over time