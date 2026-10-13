# DinoGame — Game Design Brief v3

**Status:** Collaborative design decisions, with unsettled mechanics clearly marked. This is an original Roblox game inspired by real-time dinosaur command combat. Do not use licensed Jurassic Park characters, marks, assets, maps or story.

## 1. Premise and core gameplay
A human agent discovers a technology capable of communicating with and commanding dinosaurs. Exploring a fixed island, the agent confronts natural dinosaurs and modified/implanted dinosaurs controlled by an antagonist. Combat is **continuous real-time 1v1**, never turn-based. During battles, the player selects Offensive, Neutral, Defensive and Flanking stances and issues attack commands; the dinosaur moves autonomously rather than being directly WASD-driven. Player timing of **Rest** between actions is integral.

Each offensive skill visibly has **Damage**, **Effort** (stamina cost) and **Accuracy**, alongside configurable range, windup/startup, strike window, recovery, cooldown and effect tags. Health, stamina, positioning, dodging and armor affect combat. Skill-specific DNA polyomino puzzles modify each move rather than simply leveling a dinosaur.

## 2. Species and run limits
Twelve playable dinosaur species:
- Deinonychus (starter; scientifically informed equivalent of the fictional oversized Velociraptor)
- Gallimimus (starter; omnivorous ornithomimid)
- Dilophosaurus
- Stegosaurus
- Triceratops
- Ankylosaurus
- Tyrannosaurus
- Spinosaurus
- Allosaurus
- Parasaurolophus
- Brachiosaurus
- Giganotosaurus

Two non-playable prehistoric reptiles may appear as world threats or set pieces: Pteranodon (pterosaur) and Mosasaurus (marine squamate); neither is a dinosaur. Avoid unsupported natural venom/frill abilities for Dilophosaurus. Keep biological claims grounded and label fictional mechanics as fictional.

**Every new run** begins with a choice between Deinonychus and Gallimimus. The run roster holds at most **five dinosaurs** and never offers automatic possession of every available species. Each dinosaur has at most **five equipped offensive/combat skills**; the learnable pool is larger. Explicit upgrade lineages replace weaker versions within a slot. Stances, Rest and universal defensive controls do not count toward this cap.

## 3. Hidden irreversible opponent rewards — agreed rules
- A one-time encounter is **irreversibly consumed after its victory**. Only the winning dinosaur receives a chance to learn from that opponent. Other dinosaurs have permanently missed that specific opportunity *within the current run*, even if the winning dinosaur's reward roll fails.
- The player must **not know in advance** which dinosaur can learn from an enemy, nor precisely what will be learned. No universal analysis goggles, learning compatibility previews, guaranteed drop labels or predictable prebattle reward charts. Discovery and uncertainty are central.
- Almost **any dinosaur should be able to benefit from most reward-eligible opponents**. Compatibility generally changes the *nature of the possible skill* rather than locking a reward to a single winning species. Some carefully authored dinosaur-vs-dinosaur interactions may have special outcomes.
- Model three DISTINCT dimensions rather than a single level-based loot table:
  1. **Intrinsic opponent formidability:** strength/rarity of the opponent on its own, independent of the player's fighter; affects potential skill quality/type and ceiling.
  2. **Relative threat:** opponent threat compared with the *particular dinosaur entering battle*, using a frozen prebattle evaluation; controls reward eligibility and probability. Trivial opponents grant **no skill/DNA build progression**.
  3. **Compatibility:** opponent traits, winning species, known moves and specially authored species/skill interactions; chooses the available rewards, usually permissively.
- Rewards are stochastic with reproducible run-seeded RNG; ordinary victories do **not** automatically grant skills. Scripted exceptions/guarantees may exist but require explicit design sign-off and are not disclosed as a generic prebattle hint.
- Exact threshold ratios, reward probabilities, skill tiers, reward-vs-DNA weights and eligibility tables are **UNDECIDED**. Do not hardcode earlier illustrative numbers as canonical. Test distributions across seeds and winning species.
- Prevent mandatory encounter softlocks from missed random skills using baseline capabilities, accessible opportunities or alternative routes. Do not simply guarantee collection of every high-tier move.

## 4. Large-vs-small dinosaur power hierarchy — agreed
**Large dinosaurs must be decisively stronger in direct combat.** Even a maximally developed Deinonychus should have extremely little chance against a Tyrannosaurus in a straightforward fight. It should not be mathematically impossible to pull off a rare upset through exceptional play and conditions, but a balanced 50/50 duel is explicitly NOT a goal.

Smaller dinosaurs usually have superior dodge, movement/turn agility, fast move startup and recovery, and stamina efficiency. The player still decides when to Rest. Bigger dinosaurs gain overwhelming HP, impact, reach, physical damage, armor and stagger strength. Bounded individual upgrades are possible **inside one run**, but they do not remove the size hierarchy.

Small dinosaurs retain vital **noncombat exploration roles**: narrow tunnels/mazes, narrow ledges, weight-limited bridges and sinking ground/swamps. Large dinosaurs can smash obstructions, perform high-strength navigation tasks, cross demanding terrain or river obstacles and reliably fight giant opponents. A five-dinosaur team must not become permanently trapped by choosing an unfortunate composition. Exploration gates must have fair access/recruitment or alternative solutions.

## 5. Armored Ankylosaurus, Piercing and Crushing — agreed concept
When its armor is protecting an area, Ankylosaurus takes **no ordinary HP damage** from regular attacks to that armored area. Rare explicitly named skill types can bypass:
- **Piercing**: typically higher accuracy, lower damage, penetration of armored regions.
- **Crushing**: typically high damage, lower accuracy and/or high Effort plus long commitment; penetrates armored regions.

The attack name should visibly contain Piercing or Crushing (e.g. Piercing Thrust, Crushing Bite) so players can understand counterplay without being shown skill reward compatibility.

**NOT YET DECIDED:** exact armor coverage, weak points, stance interaction, whether positional gaps permit some normal hits, rarity and availability of the two counters, and interactions with other armored dinosaurs. Do not make mandatory fights unwinnable if the team lacks a rare learned counter. Do not extrapolate universal invincibility to all armored species.

## 6. Distinctive species abilities — only a possibility
Species-specific innate or exploration abilities are welcome. Parasaurolophus might detect distant chip-controlled dinosaur signals or warn of danger, as an original **fictional game ability** loosely inspired by plausible acoustic signaling through its crest. It must **not identify skill-eligible species or loot outcomes**. This ability is **not approved or finalized** and must not be implemented during the first prototype.

## 7. DNA customization and move upgrades
Each offensive skill has an independent puzzle board (an initial 5x5 is a *prototype choice*). DNA polyomino pieces are earned only within the run, have unique instance IDs and shape offsets, and can be rotated, placed, removed and reassigned legally. Modifiers adjust that skill's Damage/Effort/Accuracy and possibly status/damage-class traits with interesting tradeoffs.

The shared piece inventory is finite; one piece cannot be fitted to multiple boards simultaneously. Server validates ownership, shape, rotation, non-overlap, board bounds and caps/floors. Decide whether upgraded skills preserve fitted layouts or remap their pieces before Phase 3.

## 8. World: hand-authored geography, variable encounters
The geography of the island is **identical between runs**: biomes, terrain, rivers, paths, permanent buildings and research facilities stay in their authored locations. Do **not** procedurally generate/rearrange the landscape. Seeded run variation changes the **number and location of unscripted enemies** across ecological, difficulty and navigationally valid spawn nodes (types/variants may vary if approved). Some story-critical scripted opponents **always appear** in fixed situations. Ensure safe start areas, navigable encounters and coherent biome placement.

## 9. Persistence: knowledge only, never power
On starting a new run, completely reset dinosaur ownership/team, learned/equipped skills, upgrades, DNA pieces and layouts, items/equipment that give power, levels/stats, encounter states and all other mechanical progression.

Persist only an **informational journal** that can be read across runs:
- observed/discovered species and scientifically grounded field-guide information;
- story logs, learned plot information and past run notes;
- skills genuinely **discovered or used**, their already-observed effects and optionally the opponent/context of that discovery.

A discovered species is **not** a permanently owned or automatically recruitable dinosaur. A recorded skill is **not** an unlocked future skill or an accurate table of all possible enemy drops. Never expose unseen compatibility or precise unrevealed probabilities in the journal.

## 10. Before later phases: unresolved design questions
1. Reward chance curve, opponent formidability tiers, compatible reward generation, exceptional guaranteed pairings.
2. Armor hit regions/weak spots, skill tags beyond Piercing/Crushing, availability of mandatory counters.
3. Parasaurolophus (and other dinosaur) special abilities.
4. Exploration/party gates and prevention of five-dinosaur-roster softlocks.
5. Persistent journal disclosure policy and DNA-board handling on lineage upgrades.

**Historical reference caution:** the 2002 game inspires real-time command battle, stances and visible Damage/Effort/Accuracy. We have not authenticated its full numerical species/move database or exact RNG formula. All numbers introduced during prototyping must be labeled original provisional tuning, not asserted as canonical.

**Immediate implementation boundary:** Begin only with a small one-arena, two-placeholder dinosaur combat prototype. No progression, skill drops, armor special rules, DNA editor, save system, scanner, full island or story yet.
