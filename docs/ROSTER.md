# Monstros roster

The planned roster of 150 monsters, with design notes to support sprite creation.
Generated from [`roster.json`](roster.json) by `tools/make_roster_doc.py`. Edit the JSON, not this file.

- **Status:** *in game* monsters already exist in `data/species.json`; *planned* ones will be added as the
  region is built. All of them can be drawn now. Use the ID as the folder name: `assets/monsters/<id>/`.
- **Sprites per monster:** `front.png` (64×64, facing left), `back.png` (64×64), `icon.png` (64×32,
  2 frames). See [ART_SPEC.md](ART_SPEC.md).
- **Size** is how much of the 64×64 frame the front sprite should fill, so relative sizes read
  correctly in battle: **S** fills about half the 64x64 frame; **M** about two thirds of the frame; **L** most of the frame; **XL** fills the frame, may touch the edges.
- **Palette** lists the main colours, most dominant first. Keep each sprite to about 15 colours plus transparency.
- Evolution stages should read as the same creature growing up: keep a signature feature,
  colour or marking through each line.
- **Evolution methods** marked *Item*, *Trade* or *Friendship* are planned and not implemented yet.
  Levels and items may change during balancing.
- All names and designs are original. Don't base a design on any existing franchise's monster;
  see [CONTENT_GUIDELINES.md](CONTENT_GUIDELINES.md).

## Type distribution

How many monsters carry each type (dual types count for both):

| Type | Count | | Type | Count | | Type | Count |
|---|---|---|---|---|---|---|---|
| Water | 22 | | Earth | 16 | | Stone | 16 |
| Wind | 16 | | Flora | 15 | | Toxic | 15 |
| Metal | 14 | | Fae | 14 | | Mind | 14 |
| Insect | 13 | | Brawl | 13 | | Flame | 12 |
| Common | 12 | | Shadow | 12 | | Spirit | 11 |
| Volt | 10 | | Frost | 10 | | Wyrm | 7 |

## Index

| # | Name | Type | Status |
|---|---|---|---|
| 001 | Fernling | Flora | in game |
| 002 | Bramblehorn | Flora | in game |
| 003 | Briarhart | Flora / Earth | in game |
| 004 | Emberkit | Flame | in game |
| 005 | Blazepaw | Flame | in game |
| 006 | Forgemane | Flame / Metal | in game |
| 007 | Ripplet | Water | in game |
| 008 | Tidalisk | Water | in game |
| 009 | Coralith | Water / Stone | in game |
| 010 | Pipwing | Common / Wind | in game |
| 011 | Gustlark | Common / Wind | planned |
| 012 | Galecrest | Common / Wind | planned |
| 013 | Nibbet | Common | in game |
| 014 | Chiselfang | Common | planned |
| 015 | Grubble | Insect | in game |
| 016 | Spindlepod | Insect | planned |
| 017 | Lumimoth | Insect / Fae | planned |
| 018 | Needlit | Insect / Toxic | planned |
| 019 | Hivecase | Insect / Toxic | planned |
| 020 | Stingarch | Insect / Toxic | planned |
| 021 | Pebbit | Stone / Earth | in game |
| 022 | Bouldrum | Stone / Earth | planned |
| 023 | Cragmount | Stone / Earth | planned |
| 024 | Flintling | Stone | planned |
| 025 | Shalehorn | Stone | in game |
| 026 | Duskit | Shadow / Wind | planned |
| 027 | Echowing | Shadow / Wind | planned |
| 028 | Umbravane | Shadow / Wind | planned |
| 029 | Coilbit | Volt / Metal | planned |
| 030 | Dynacoil | Volt / Metal | planned |
| 031 | Zaptole | Volt / Water | planned |
| 032 | Galvanewt | Volt / Water | planned |
| 033 | Sparrel | Volt | planned |
| 034 | Stormglider | Volt / Wind | planned |
| 035 | Joltlet | Volt | planned |
| 036 | Joltquill | Volt | planned |
| 037 | Flickerfly | Volt / Insect | planned |
| 038 | Finnick | Water | planned |
| 039 | Riptooth | Water / Shadow | planned |
| 040 | Shellop | Water | planned |
| 041 | Pearlseer | Water / Mind | planned |
| 042 | Pinchet | Water | planned |
| 043 | Anvilcrab | Water / Metal | planned |
| 044 | Driftjel | Water / Toxic | planned |
| 045 | Stingsail | Water / Toxic | planned |
| 046 | Selkin | Water / Frost | planned |
| 047 | Walrune | Water / Frost | planned |
| 048 | Otterpop | Water | planned |
| 049 | Rapidrift | Water / Brawl | planned |
| 050 | Sporebud | Flora / Toxic | planned |
| 051 | Toxbloom | Flora / Toxic | planned |
| 052 | Rotblossom | Flora / Toxic | planned |
| 053 | Petalkin | Flora / Fae | planned |
| 054 | Blossprite | Flora / Fae | planned |
| 055 | Puffseed | Flora / Wind | planned |
| 056 | Dandeloft | Flora / Wind | planned |
| 057 | Pricklet | Flora | planned |
| 058 | Saguardo | Flora / Brawl | planned |
| 059 | Shroomp | Flora | planned |
| 060 | Grimcap | Flora / Spirit | planned |
| 061 | Cindig | Flame / Earth | planned |
| 062 | Calderhulk | Flame / Earth | planned |
| 063 | Censerling | Flame | planned |
| 064 | Pyreoracle | Flame / Mind | planned |
| 065 | Brimgecko | Flame / Toxic | planned |
| 066 | Kilnpup | Flame | planned |
| 067 | Kilnhound | Flame / Stone | planned |
| 068 | Snowhop | Frost | planned |
| 069 | Aurorabbit | Frost / Fae | planned |
| 070 | Rimeshard | Frost | planned |
| 071 | Hailcrown | Frost / Stone | planned |
| 072 | Yetling | Frost | planned |
| 073 | Avalanchor | Frost / Brawl | planned |
| 074 | Gruffkid | Brawl | planned |
| 075 | Ramstrike | Brawl | planned |
| 076 | Summitram | Brawl / Stone | planned |
| 077 | Calmkoa | Brawl | planned |
| 078 | Zenkoa | Brawl / Mind | planned |
| 079 | Mantlet | Insect / Brawl | planned |
| 080 | Prayblade | Insect / Brawl | planned |
| 081 | Slimlet | Toxic | planned |
| 082 | Slogslug | Toxic / Earth | planned |
| 083 | Smogling | Toxic | planned |
| 084 | Miasmaw | Toxic / Wind | planned |
| 085 | Cauldrop | Toxic | planned |
| 086 | Brewitch | Toxic / Spirit | planned |
| 087 | Burrowl | Earth | planned |
| 088 | Dunestrix | Earth / Wind | planned |
| 089 | Sandling | Earth | planned |
| 090 | Dunewyrm | Earth / Wyrm | planned |
| 091 | Augerbit | Earth / Metal | planned |
| 092 | Bormaw | Earth / Metal | planned |
| 093 | Rollodillo | Earth | planned |
| 094 | Breezlet | Wind | planned |
| 095 | Cyclonix | Wind | planned |
| 096 | Kestrike | Wind / Brawl | planned |
| 097 | Dozelet | Mind | planned |
| 098 | Reverell | Mind | planned |
| 099 | Somnarch | Mind / Fae | planned |
| 100 | Tickowl | Mind / Metal | planned |
| 101 | Chronowl | Mind / Metal | planned |
| 102 | Omencat | Mind / Shadow | planned |
| 103 | Riddlecub | Mind | planned |
| 104 | Sphyrion | Mind / Earth | planned |
| 105 | Wisplet | Spirit | planned |
| 106 | Mournlight | Spirit | planned |
| 107 | Veilwraith | Spirit / Shadow | planned |
| 108 | Parasoul | Spirit / Wind | planned |
| 109 | Cairnling | Spirit / Stone | planned |
| 110 | Cairnwight | Spirit / Stone | planned |
| 111 | Pilfurr | Shadow | planned |
| 112 | Banditail | Shadow | planned |
| 113 | Snickerpup | Shadow | planned |
| 114 | Cacklehyde | Shadow / Brawl | planned |
| 115 | Grimpkin | Shadow / Fae | planned |
| 116 | Rivetbug | Insect / Metal | planned |
| 117 | Ironshell | Insect / Metal | planned |
| 118 | Chimelet | Metal / Fae | planned |
| 119 | Carillon | Metal / Fae | planned |
| 120 | Gearpup | Metal | planned |
| 121 | Clankhound | Metal | planned |
| 122 | Dewlette | Fae | planned |
| 123 | Dewdancer | Fae | planned |
| 124 | Fluffawn | Fae | planned |
| 125 | Starlette | Fae / Mind | planned |
| 126 | Scalelet | Wyrm | planned |
| 127 | Ridgedrake | Wyrm | planned |
| 128 | Peakwyrm | Wyrm / Stone | planned |
| 129 | Coilfin | Water | planned |
| 130 | Maelstrake | Water / Wyrm | planned |
| 131 | Verdrake | Wyrm / Flora | planned |
| 132 | Lumbear | Common | planned |
| 133 | Snoutle | Common | planned |
| 134 | Truffhog | Common / Earth | planned |
| 135 | Hummling | Common / Fae | planned |
| 136 | Mimicat | Common | planned |
| 137 | Woolump | Common | planned |
| 138 | Woolossus | Common | planned |
| 139 | Ashcrow | Flame / Shadow | planned |
| 140 | Rimewisp | Frost / Spirit | planned |
| 141 | Bellbuoy | Spirit / Water | planned |
| 142 | Platefin | Stone / Water | planned |
| 143 | Dunkleon | Stone / Water | planned |
| 144 | Scuttlite | Stone / Insect | planned |
| 145 | Scorptera | Stone / Insect | planned |
| 146 | Halvorn | Frost / Wind | planned |
| 147 | Thundrel | Volt / Brawl | planned |
| 148 | Solaric | Flame / Mind | planned |
| 149 | Vaelith | Spirit / Wyrm | planned |
| 150 | Primmi | Fae / Mind | planned |

## Design notes

### 001–003 · Fernling line

*Flora starter: a shy sprout that grows into a rooted forest guardian.* · Found in: Starter

**001 Fernling** (`fernling`) · Flora · Lv 16 → Bramblehorn · Size S · *in game*  
Palette: leaf green, cream, bark brown  
Small round-bodied sprout on stubby legs, with two curled fern fronds on its head like ears. When nervous the fronds curl tight. Big dark eyes, cream belly.

**002 Bramblehorn** (`bramblehorn`) · Flora · Lv 36 → Briarhart · Size M · *in game*  
Palette: leaf green, thorn brown, cream  
Leggy, fawn-like quadruped. The fronds have hardened into a small crown of thorny bramble branches. Cream spots along the flanks, alert stance.

**003 Briarhart** (`briarhart`) · Flora / Earth · Final · Size L · *in game*  
Palette: deep green, earth brown, moss, berry red  
Massive stag whose antlers are living briar, trailing roots and red berries. Hooves sink into the ground as roots. Shoulders are mossy, earthen plates. Calm, regal pose.


### 004–006 · Emberkit line

*Flame starter: a playful kit that becomes a lion with a forge-hot mane.* · Found in: Starter

**004 Emberkit** (`emberkit`) · Flame · Lv 16 → Blazepaw · Size S · *in game*  
Palette: ember orange, charcoal, cream  
Small kitten-like creature with an oversized, smouldering tuft of fur on its head and tail tip. Charcoal paws as if it walked through ash. Playful crouch.

**005 Blazepaw** (`blazepaw`) · Flame · Lv 36 → Forgemane · Size M · *in game*  
Palette: flame orange, charcoal, yellow  
Lean, fast young big cat. Flames lick from its shoulders and tail, and its paws glow at the pads, leaving scorch marks. Mid-stride, eager.

**006 Forgemane** (`forgemane`) · Flame / Metal · Final · Size L · *in game*  
Palette: molten orange, iron grey, white-hot yellow  
Powerful lion. Its mane is a ring of molten flame held in place by iron-grey armour plates on the brow, chest and forelegs, like hammered metal. Claws are steel. Proud, upright pose.


### 007–009 · Ripplet line

*Water starter: a bobbing swimmer whose shell grows into a living reef.* · Found in: Starter

**007 Ripplet** (`ripplet`) · Water · Lv 16 → Tidalisk · Size S · *in game*  
Palette: sky blue, sand, white  
Round, buoyant creature like a little float, with a small sand-coloured shell on its back and flipper feet. Bobs upright. Wide smile.

**008 Tidalisk** (`tidalisk`) · Water · Lv 36 → Coralith · Size M · *in game*  
Palette: ocean blue, sand, white  
Lizard-like swimmer with a long tail fin. Its shell has spread into a back plate patterned with wave ripples, as on wet sand. Low, ready-to-pounce stance.

**009 Coralith** (`coralith`) · Water / Stone · Final · Size L · *in game*  
Palette: deep blue, coral pink, stone grey  
Heavy, armoured reptilian whose back plate has grown into a craggy living reef of pink and orange coral. Tiny fish shelter in the gaps. Thick stone-grey forearms. Sturdy, grounded pose.


### 010–012 · Pipwing line

*The common early bird line.* · Found in: Early routes

**010 Pipwing** (`pipwing`) · Common / Wind · Lv 18 → Gustlark · Size S · *in game*  
Palette: brown, cream, orange beak  
Plump, round little songbird, almost a ball with a beak. Oversized orange feet, a short jaunty tail cocked upward, and a cream belly. Its beak is always slightly open mid-whistle, with a tiny musical-note-shaped tuft on its head.

**011 Gustlark** (`gustlark`) · Common / Wind · Lv 34 → Galecrest · Size M  
Palette: brown, cream, slate  
Sleeker, longer lark. The head tuft has become a swept-back crest, and the wing tips are long and pointed. Brown back, slate wing bars, cream underside. Shown banking in flight with one wing raised.

**012 Galecrest** (`galecrest`) · Common / Wind · Final · Size L  
Palette: bronze, cream, slate blue  
Large soaring bird with a dramatic double crest that streams back like wind-torn banners. Broad bronze wings spread wide, the tail fanned into points. Sharp, confident eye. It should read as fast and proud, not a bird of prey.


### 013–014 · Nibbet line

*The common early rodent. (Planned evolution for the existing Nibbet.)* · Found in: Early routes

**013 Nibbet** (`nibbet`) · Common · Lv 20 → Chiselfang · Size S · *in game*  
Palette: grey-brown, pink, cream  
Small, chubby rodent with huge ivory front teeth, round ears and a stubby tail. Cheeks puffed out with something it's chewing. Sits up on its haunches holding a crumb. Mischievous rather than dirty.

**014 Chiselfang** (`chiselfang`) · Common · Final · Size M  
Palette: grey-brown, cream, ivory  
Stocky, beaver-like gnawer standing on its hind legs. Two long chisel-shaped teeth, a broad flat tail with cross-hatched texture, and a gnawed stick held like a club. A cocky, buck-toothed grin.


### 015–017 · Grubble line

*Silk grub to glowing moth. (Planned evolutions for the existing Grubble.)* · Found in: Early routes / woodland

**015 Grubble** (`grubble`) · Insect · Lv 7 → Spindlepod · Size S · *in game*  
Palette: lime green, yellow, white  
Plump, segmented lime-green grub with five pairs of stubby legs and a yellow stripe down each side. A spinneret mouth with a strand of silk trailing behind it. Big friendly eyes.

**016 Spindlepod** (`spindlepod`) · Insect · Lv 10 → Lumimoth · Size S  
Palette: pale green, silk white  
Spindle-shaped cocoon tightly wrapped in silk spirals, hanging from one thread at the top. Two eyes peek out through a gap in the silk. Barely moves, so the sprite should feel still and patient.

**017 Lumimoth** (`lumimoth`) · Insect / Fae · Final · Size M  
Palette: moon white, pale teal, soft gold  
Delicate moth with broad, rounded forewings covered in softly glowing teal eyespots. Fluffy white thorax ruff, feathery gold antennae. Tiny sparkles drift down from the wings. Hovering, wings open.


### 018–020 · Needlit line

*A stinging line: larva to wasp regent.* · Found in: Woodland

**018 Needlit** (`needlit`) · Insect / Toxic · Lv 7 → Hivecase · Size S  
Palette: yellow, black, purple  
Small larva with alternating yellow and black bands and a single purple needle on its tail. A defensive pose, tail curled up over its back like a question mark.

**019 Hivecase** (`hivecase`) · Insect / Toxic · Lv 10 → Stingarch · Size S  
Palette: honey yellow, wax tan  
A pupa sealed inside a hexagonal wax cell, like one cell of a honeycomb. Its eyes show through the translucent wax lid, and its stinger pokes out of the bottom. Rigid and upright.

**020 Stingarch** (`stingarch`) · Insect / Toxic · Final · Size M  
Palette: gold, black, violet  
Regal wasp with a crown-like crest of three spikes, four sharp translucent wings and a long, violet-tipped stinger. Its abdomen has gold and black chevrons like a royal sash. Hovering with the stinger angled forward.


### 021–023 · Pebbit line

*Rolling stone line. (Planned evolutions for the existing Pebbit.)* · Found in: Caves / mountains

**021 Pebbit** (`pebbit`) · Stone / Earth · Lv 25 → Bouldrum · Size S · *in game*  
Palette: sandstone, brown, dark grey  
Pebble-shaped creature, mostly body, with stubby rock arms, flat feet and a permanently grumpy face. Dusty from rolling, with a few small pebbles stuck to it. Looks like it just tumbled down a hill and is annoyed about it.

**022 Bouldrum** (`bouldrum`) · Stone / Earth · Trade → Cragmount · Size M  
Palette: sandstone, clay, grey  
Barrel-shaped boulder on short legs that drums on its own hollow belly with rocky fists. Cracks across its shell show packed earth inside. Its mouth is open mid-drum-roll.

**023 Cragmount** (`cragmount`) · Stone / Earth · Final · Size L  
Palette: grey, moss, sandstone  
A hulking living cliffside on four stumpy pillar legs. Its back is a jagged mountain ridge with patches of moss and a few pebbles tumbling off. A small, stern face under a rocky brow.


### 024–025 · Flintling line

*Flaky shale line. (Shalehorn already exists; Flintling is its planned pre-evolution.)* · Found in: Caves

**024 Flintling** (`flintling`) · Stone · Lv 22 → Shalehorn · Size S  
Palette: flint grey, white, orange spark  
Small quadruped chipped from dark flint, with sharp faceted edges and a single conical horn. White chips mark the fresh breaks. Orange sparks flicker at its hooves and horn tip. Head lowered to charge.

**025 Shalehorn** (`shalehorn`) · Stone · Final · Size M · *in game*  
Palette: slate grey, layered browns  
Rhino-like creature whose large horn is made of thin layered shale that flakes off in sheets when it charges. Body has visible strata lines.


### 026–028 · Duskit line

*The cave bat line.* · Found in: Caves (night)

**026 Duskit** (`duskit`) · Shadow / Wind · Lv 22 → Echowing · Size S  
Palette: dusk purple, black, pale pink  
Tiny round bat that is mostly ears: two huge, sensitive pink-lined ears and small wings. Eyes squeezed shut, because it navigates by sound. Hanging upside down, wrapped in its wings.

**027 Echowing** (`echowing`) · Shadow / Wind · Friendship → Umbravane · Size M  
Palette: indigo, black, pink  
Sleeker bat with wide indigo wings and concentric ripple markings on the wing membranes that show its echo calls. Mouth wide mid-shriek, with small fangs. Flying straight at the viewer.

**028 Umbravane** (`umbravane`) · Shadow / Wind · Final · Size L  
Palette: midnight blue, black, silver  
Large, elegant bat whose wings look like tattered night sky flecked with silver stars. A long tail ending in an arrow like a weathervane. Graceful glide pose, silhouetted against a moonless sky.


### 029–030 · Coilbit line

*A magnetic coil line.* · Found in: Power plant / city

**029 Coilbit** (`coilbit`) · Volt / Metal · Lv 30 → Dynacoil · Size S  
Palette: copper, steel grey, electric yellow  
Small floating copper coil, a short spring of wire, with a single round eye in the middle and two magnet-pole nubs (red and blue tips) on the ends. Static sparks crackle around it.

**030 Dynacoil** (`dynacoil`) · Volt / Metal · Final · Size M  
Palette: copper, steel, yellow  
Three copper coils fused around a glowing yellow core, arranged like a dynamo. Arcs of electricity jump between the coils, and the core has the eye. It should look like it's spinning.


### 031–032 · Zaptole line

*An electric tadpole to newt.* · Found in: Rivers / marsh

**031 Zaptole** (`zaptole`) · Volt / Water · Lv 26 → Galvanewt · Size S  
Palette: teal, yellow, white  
Fat teal tadpole with a lightning-bolt-shaped tail and two rows of glowing yellow spots. Wiggling swim pose with its tail mid-zigzag. Tiny back legs just starting to show.

**032 Galvanewt** (`galvanewt`) · Volt / Water · Final · Size M  
Palette: teal, yellow, dark green  
Slender teal newt with a frilled crest and gills that crackle with electricity. Yellow battery-like stripes run down its back. A low, alert crouch with the tail curled.


### 033–034 · Sparrel line

*A gliding squirrel that rides storm winds.* · Found in: Woodland

**033 Sparrel** (`sparrel`) · Volt · Lv 24 → Stormglider · Size S  
Palette: golden yellow, cream, brown  
Squirrel with a huge, fluffy golden tail that collects static, so its fur stands on end in spikes. It clutches an acorn that sparks. Sitting up, cheeky expression.

**034 Stormglider** (`stormglider`) · Volt / Wind · Final · Size M  
Palette: storm grey, yellow, white  
Flying squirrel shown spread-eagled, with wide grey gliding membranes edged in crackling lightning. White belly, yellow cheek pouches that store charge. The tail streams behind like a rudder.


### 035–036 · Joltlet line

*A battery hedgehog.* · Found in: Routes / meadows

**035 Joltlet** (`joltlet`) · Volt · Lv 28 → Joltquill · Size S  
Palette: yellow, brown, white  
Round little hedgehog whose quills are short yellow lightning spikes. Brown face, white tummy, tiny feet. It's half-curled into a crackling ball, peeking out.

**036 Joltquill** (`joltquill`) · Volt · Final · Size M  
Palette: yellow, dark brown, white  
Larger hedgehog standing upright on its hind legs. Its long jagged quills crackle like a storm cloud and are flared outward in threat. Arms in a ready stance.


### 037 · Flickerfly

*A firefly that flashes a charged light.* · Found in: Woodland (night)

**037 Flickerfly** (`flickerfly`) · Volt / Insect · Does not evolve · Size S  
Palette: black, lime glow, yellow  
Small black firefly with a big, glowing lime-green abdomen, stubby wings and long antennae. Cheerful hovering pose. The glow should be the brightest part of the sprite.


### 038–039 · Finnick line

*A small fish that becomes a shark.* · Found in: Rivers / sea (fishing)

**038 Finnick** (`finnick`) · Water · Lv 25 → Riptooth · Size S  
Palette: silver blue, white, red fin  
Small silvery fish, very ordinary except for one oversized red dorsal fin that it is very proud of. Shown sideways, flapping out of the water with its mouth agape.

**039 Riptooth** (`riptooth`) · Water / Shadow · Final · Size L  
Palette: navy, white, red  
Sleek navy shark with a white underbelly, a scarred snout, an enormous toothy grin and a ragged red dorsal fin left over from Finnick. A lunging bite pose, coming at the viewer.


### 040–041 · Shellop line

*A clam that dreams up pearls of foresight.* · Found in: Coast

**040 Shellop** (`shellop`) · Water · Item: Moon Pearl → Pearlseer · Size S  
Palette: lilac, pearl white  
Small lilac scallop shell with frilly edges, two eyes peeking out from between the halves and a tongue poking out. Sits on the sand, slightly open.

**041 Pearlseer** (`pearlseer`) · Water / Mind · Final · Size M  
Palette: lilac, pearl, violet glow  
An open clam with a large, luminous pearl floating above it like a crystal ball, glowing violet. Wise, half-lidded eyes along the shell rim. Mystical sparkles around the pearl.


### 042–043 · Pinchet line

*A crab with anvil-heavy claws.* · Found in: Coast

**042 Pinchet** (`pinchet`) · Water · Lv 28 → Anvilcrab · Size S  
Palette: coral red, cream  
Small coral-red crab with mismatched claws, one tiny and one comically big. Stalk eyes and a sideways scuttle pose, big claw raised.

**043 Anvilcrab** (`anvilcrab`) · Water / Metal · Final · Size M  
Palette: iron grey, coral red  
Heavy crab whose big claw has become an anvil-shaped iron hammer. Its shell is coral red with iron-grey plating and rivet-like bumps. Braced on short legs, claw raised to strike.


### 044–045 · Driftjel line

*A drifting jellyfish line.* · Found in: Sea (surfing)

**044 Driftjel** (`driftjel`) · Water / Toxic · Lv 30 → Stingsail · Size S  
Palette: translucent pink, purple  
Small translucent pink jellyfish with a dome bell, two curly tentacles and a faint purple inner glow. Drifting gently, tentacles swaying.

**045 Stingsail** (`stingsail`) · Water / Toxic · Final · Size L  
Palette: pink, violet, blue  
Man-o'-war-like creature with a tall translucent blue sail crest on top of a pink float and long violet trailing tentacles. A drifting pose leaning with the wind. Should feel large and ominous.


### 046–047 · Selkin line

*A seal pup that grows into a rune-tusked walrus.* · Found in: Snowy coast

**046 Selkin** (`selkin`) · Water / Frost · Lv 32 → Walrune · Size S  
Palette: white, pale blue, grey  
Fluffy white seal pup with huge dark eyes, frost-tipped whiskers and a pale-blue nose. Lying on its belly, flippers tucked. Almost too cute.

**047 Walrune** (`walrune`) · Water / Frost · Final · Size L  
Palette: blue-grey, ice white, cyan glow  
Massive blue-grey walrus sitting upright, with long ice tusks carved with glowing cyan rune marks. Thick folds of blubber, a bristly moustache and a wise, heavy-lidded gaze.


### 048–049 · Otterpop line

*A playful otter that becomes a river brawler.* · Found in: Rivers

**048 Otterpop** (`otterpop`) · Water · Lv 30 → Rapidrift · Size S  
Palette: brown, cream, blue  
Small brown otter floating on its back, holding a smooth pebble on its chest. Sleek wet fur, cream face, tiny paws. Content expression.

**049 Rapidrift** (`rapidrift`) · Water / Brawl · Final · Size M  
Palette: dark brown, cream, white water  
Muscular otter standing in a boxing stance, with water swirling around its fists like hand wraps. Darker fur, a cream chest and a bandana-like fur pattern. Tail braced for balance.


### 050–052 · Sporebud line

*A spore bud that blooms into a pungent giant flower.* · Found in: Marsh / woodland

**050 Sporebud** (`sporebud`) · Flora / Toxic · Lv 21 → Toxbloom · Size S  
Palette: green, purple, yellow  
Bulb-shaped bud on little root feet. Its closed purple petals leak puffs of yellow spores. Two leaf arms and a drowsy face on the bulb.

**051 Toxbloom** (`toxbloom`) · Flora / Toxic · Item: Leaf Stone → Rotblossom · Size M  
Palette: green, violet, yellow  
Half-open flower with drooping violet petals and dripping nectar. A face in the flower's centre, a green stem body and leaf arms. Swaying unsteadily, as if dizzy from its own scent.

**052 Rotblossom** (`rotblossom`) · Flora / Toxic · Final · Size L  
Palette: maroon, spotted white, green  
Enormous squat flower like a giant rafflesia, with five thick maroon petals spotted white and a gaping central maw. Small vine arms, visible stink lines. The petals almost fill the frame.


### 053–054 · Petalkin line

*A shy petal sprite.* · Found in: Meadows

**053 Petalkin** (`petalkin`) · Flora / Fae · Item: Sun Stone → Blossprite · Size S  
Palette: pink, white, leaf green  
Tiny humanoid sprite whose skirt is a pink flower bloom and whose hair is two white petals. Small leaf in hand, half-hiding behind it shyly.

**054 Blossprite** (`blossprite`) · Flora / Fae · Final · Size M  
Palette: rose pink, white, gold  
Graceful flower fairy with four translucent petal wings and a crown of rose blossoms. A flowing petal dress, mid-twirl, scattering petals.


### 055–056 · Puffseed line

*Seeds that drift on the wind.* · Found in: Meadows / hills

**055 Puffseed** (`puffseed`) · Flora / Wind · Lv 26 → Dandeloft · Size S  
Palette: white fluff, green  
Small dandelion clock: a round white seed-head body with a face, tiny leaf arms and a short stem leg. Floating, a few seeds drifting off.

**056 Dandeloft** (`dandeloft`) · Flora / Wind · Final · Size M  
Palette: yellow, white fluff, green  
Tall, slender dandelion creature holding a huge fluffy seed head above it like a hot-air balloon, its feet dangling below. A yellow flower collar at its neck.


### 057–058 · Pricklet line

*A cactus that learns to box.* · Found in: Desert

**057 Pricklet** (`pricklet`) · Flora · Lv 30 → Saguardo · Size S  
Palette: cactus green, pink flower  
Small round cactus with a single pink flower on top, stubby arms and lots of tiny spines like a pin cushion. Squinting, sun-loving expression.

**058 Saguardo** (`saguardo`) · Flora / Brawl · Final · Size L  
Palette: cactus green, sand, pink  
Tall saguaro cactus with two muscular arm branches raised in a boxer's guard. Spines cluster on its 'knuckles'. A stern face with a pink flower on its head like a headband.


### 059–060 · Shroomp line

*A mushroom haunted by forest spirits.* · Found in: Woodland (dark)

**059 Shroomp** (`shroomp`) · Flora · Lv 28 → Grimcap · Size S  
Palette: red cap, white spots, cream  
Tiny mushroom with a big red cap with white spots and stubby feet. A worried little face under the cap. Waddling.

**060 Grimcap** (`grimcap`) · Flora / Spirit · Final · Size M  
Palette: grey-violet cap, pale glow  
Tall, ghostly mushroom with a drooping grey-violet cap and a lantern-like glow underneath. Its stem fades into wispy spirit trails instead of feet. Hollow glowing eyes.


### 061–062 · Cindig line

*A digging mole of the volcano.* · Found in: Volcano

**061 Cindig** (`cindig`) · Flame / Earth · Lv 32 → Calderhulk · Size S  
Palette: dark brown, ember orange  
Small mole with glowing ember claws and dark soot rings around its eyes like goggles. Popping out of a hole, with dirt and sparks around it.

**062 Calderhulk** (`calderhulk`) · Flame / Earth · Final · Size L  
Palette: basalt black, lava orange  
Huge burrowing beast with a volcano-crater hump on its back that smokes and glows with lava. Basalt-black hide with orange cracks and massive digging claws. Heavy, low stance.


### 063–064 · Censerling line

*An incense burner that reads the future in smoke.* · Found in: Ruins / temples

**063 Censerling** (`censerling`) · Flame · Lv 33 → Pyreoracle · Size S  
Palette: brass, ember orange, smoke grey  
Small round brass incense burner with a face on the lid, swinging from its own chain. Fragrant grey smoke curls from the vents in pretty spirals.

**064 Pyreoracle** (`pyreoracle`) · Flame / Mind · Final · Size M  
Palette: brass, violet flame, gold  
Floating, ornate brass brazier with violet flames inside that form a third eye. Smoke streams down from it like robes. Two thin chain arms. Mysterious and solemn.


### 065 · Brimgecko

*A sulfur-spitting gecko.* · Found in: Volcano

**065 Brimgecko** (`brimgecko`) · Flame / Toxic · Does not evolve · Size S  
Palette: sulfur yellow, red, black  
Gecko with big sticky toe pads, sulfur-yellow skin and red warning stripes. Licking its own eyeball. Small puffs of yellow smoke from its nostrils.


### 066–067 · Kilnpup line

*A kiln-fired guard dog.* · Found in: Towns (potteries)

**066 Kilnpup** (`kilnpup`) · Flame · Lv 30 → Kilnhound · Size S  
Palette: terracotta, orange glow  
Puppy made of fired terracotta clay, with a glowing kiln opening for a mouth. Little cracks glow orange when it's excited. Wagging, playful pose.

**067 Kilnhound** (`kilnhound`) · Flame / Stone · Final · Size L  
Palette: terracotta, stone grey, orange  
Large guard dog of glazed stoneware with a glowing furnace grille in its chest. Thick, statuesque legs. Sitting on guard like a temple statue.


### 068–069 · Snowhop line

*A snow hare that shines with aurora light.* · Found in: Snowfields

**068 Snowhop** (`snowhop`) · Frost · Item: Dawn Crystal → Aurorabbit · Size S  
Palette: white, pale blue  
Round white hare with long ears tipped with frost and a pale blue nose. Shown mid-hop with all four feet off the ground. Small puff of snow beneath.

**069 Aurorabbit** (`aurorabbit`) · Frost / Fae · Final · Size M  
Palette: white, aurora green and violet  
Elegant, long-legged hare with very long flowing ears that shimmer with aurora greens and violets. Ribbons of light trail behind it. Standing tall and alert.


### 070–071 · Rimeshard line

*A crystal shard that grows into a glacier crown.* · Found in: Ice caves

**070 Rimeshard** (`rimeshard`) · Frost · Lv 34 → Hailcrown · Size S  
Palette: ice blue, white  
Floating jagged ice-crystal shard with a face reflected in its facets. Cold mist drifts off it. A few small crystals orbit it.

**071 Hailcrown** (`hailcrown`) · Frost / Stone · Final · Size L  
Palette: ice blue, granite grey  
Glacier golem with a crown of ice spikes, a granite body seamed with blue ice and heavy fists. A stomping pose, with frost spreading from its feet.


### 072–073 · Yetling line

*The snow beast.* · Found in: Mountains

**072 Yetling** (`yetling`) · Frost · Lv 32 → Avalanchor · Size S  
Palette: white fur, grey, blue  
Small yeti cub with shaggy white fur, a grey face and huge blue-grey feet. Holding a snowball overhead, about to throw it.

**073 Avalanchor** (`avalanchor`) · Frost / Brawl · Final · Size L  
Palette: white, blue-grey, ice  
Huge yeti with ice-encased fists like gauntlets and a back shaped like a snowy mountain ridge. Mid-punch, snow flying. Fierce but noble.


### 074–076 · Gruffkid line

*A mountain goat line.* · Found in: Mountains

**074 Gruffkid** (`gruffkid`) · Brawl · Lv 28 → Ramstrike · Size S  
Palette: beige, brown, white  
Small beige goat kid with tiny nub horns and a little white beard tuft. Head lowered, ready to butt. Stubborn expression.

**075 Ramstrike** (`ramstrike`) · Brawl · Lv 42 → Summitram · Size M  
Palette: brown, white, horn tan  
Muscular brown ram standing on its hind legs in a fighter's stance, with curled horns and wrapped forehooves. White chest fluff.

**076 Summitram** (`summitram`) · Brawl / Stone · Final · Size L  
Palette: stone grey, white, horn gold  
Massive ram whose spiral horns are solid grey stone with gold-veined tips. Standing proudly on a rock peak, chest out, beard flowing.


### 077–078 · Calmkoa line

*A meditative koala.* · Found in: Ruins / mountains

**077 Calmkoa** (`calmkoa`) · Brawl · Lv 34 → Zenkoa · Size S  
Palette: grey, white, leaf green  
Small grey koala seated cross-legged, eyes closed in meditation, with a eucalyptus leaf balanced on its head. White ear tufts.

**078 Zenkoa** (`zenkoa`) · Brawl / Mind · Final · Size M  
Palette: grey, white, violet aura  
Koala martial artist floating cross-legged with a soft violet aura. Prayer beads around its neck, one palm raised. Calm but powerful.


### 079–080 · Mantlet line

*A mantis duellist.* · Found in: Grasslands

**079 Mantlet** (`mantlet`) · Insect / Brawl · Lv 30 → Prayblade · Size S  
Palette: leaf green, pink  
Small leaf-green mantis with oversized foreclaws held up like boxing gloves. Big triangle head, pink eyes. Determined little stance.

**080 Prayblade** (`prayblade`) · Insect / Brawl · Final · Size M  
Palette: green, steel-like edges  
Tall green mantis whose forearms are long blades with gleaming edges. Folded wings drape like a cape. A fencer's stance, one blade forward.


### 081–082 · Slimlet line

*A toxic slug.* · Found in: Marsh

**081 Slimlet** (`slimlet`) · Toxic · Lv 28 → Slogslug · Size S  
Palette: purple, green slime  
Small purple slug with two eye stalks, a glistening green slime trail and a few drips. Sluggish, sleepy expression.

**082 Slogslug** (`slogslug`) · Toxic / Earth · Final · Size L  
Palette: purple, mud brown, green  
Enormous mud-caked purple slug with a shell-like hump of hardened earth on its back. Thick green ooze drips around it. Low and wide.


### 083–084 · Smogling line

*A fume cloud that becomes a vulture.* · Found in: Industrial

**083 Smogling** (`smogling`) · Toxic · Lv 30 → Miasmaw · Size S  
Palette: grey-green smoke  
Small round puff of grey-green smog with a face and two wispy arms. Coughing, with little smoke rings.

**084 Miasmaw** (`miasmaw`) · Toxic / Wind · Final · Size M  
Palette: grey-green, black, yellow  
Vulture made of swirling fumes, with a gas-mask-like beak and yellow eyes. Its wings trail smog. Perched, hunched over.


### 085–086 · Cauldrop line

*A bubbling cauldron.* · Found in: Haunted marsh

**085 Cauldrop** (`cauldrop`) · Toxic · Item: Dusk Stone → Brewitch · Size S  
Palette: iron black, green brew  
Tiny black iron cauldron on three stubby legs, bubbling with green brew. Two eyes peek over the rim, and a ladle handle sticks out like an antenna.

**086 Brewitch** (`brewitch`) · Toxic / Spirit · Final · Size M  
Palette: black, green, violet  
Witch-like spirit rising out of a cauldron. A pointed hat made of steam, ladle-shaped arms and a trailing violet body. Cackling.


### 087–088 · Burrowl line

*A burrowing owl.* · Found in: Desert / plains

**087 Burrowl** (`burrowl`) · Earth · Lv 28 → Dunestrix · Size S  
Palette: sand brown, cream  
Small, long-legged sand-coloured owl standing at the entrance of a burrow. Wide yellow eyes, head tilted sideways.

**088 Dunestrix** (`dunestrix`) · Earth / Wind · Final · Size M  
Palette: sand, brown, gold  
Larger owl with sand-coloured wings that whip up small dust devils. Golden eyes, talons dug into the sand. Wings half-spread.


### 089–090 · Sandling line

*A sandworm that becomes a dune wyrm.* · Found in: Desert (rare)

**089 Sandling** (`sandling`) · Earth · Lv 40 → Dunewyrm · Size S  
Palette: sand, pink mouth  
Small segmented sandworm poking out of the sand, with a round mouth ringed with tiny teeth and no visible eyes. Swaying.

**090 Dunewyrm** (`dunewyrm`) · Earth / Wyrm · Final · Size XL  
Palette: sand gold, brown, bone white  
Enormous serpent wyrm with armoured sand-gold segments, a fringe of bone-white spikes and a crown-like head. Bursting out of the dunes. Should fill the frame and be clearly rare and powerful.


### 091–092 · Augerbit line

*A living drill.* · Found in: Caves / mines

**091 Augerbit** (`augerbit`) · Earth / Metal · Lv 31 → Bormaw · Size S  
Palette: steel grey, brown  
Small mole-like creature with a drill-bit snout, tiny steel claws and dust goggles. Mid-dig.

**092 Bormaw** (`bormaw`) · Earth / Metal · Final · Size L  
Palette: steel, rust, brown  
Large drilling beast with a spiral drill jaw, armoured steel plates rusted at the edges and powerful forelimbs. Tunnelling pose, debris flying.


### 093 · Rollodillo

*A rolling armadillo.* · Found in: Plains

**093 Rollodillo** (`rollodillo`) · Earth · Does not evolve · Size M  
Palette: tan, brown bands  
Tan armadillo with banded armour, half curled into a ball and peeking out with one eye. Small ears, pointed snout.


### 094–095 · Breezlet line

*A whirlwind spirit.* · Found in: Hills / sky

**094 Breezlet** (`breezlet`) · Wind · Lv 35 → Cyclonix · Size S  
Palette: pale cyan, white  
Tiny swirl of pale cyan wind with a face and two leaf-shaped arms. Spinning, with a couple of leaves caught in it.

**095 Cyclonix** (`cyclonix`) · Wind · Final · Size L  
Palette: cyan, white, grey  
Towering cyclone creature with a funnel-shaped body, swirling debris and two glowing eyes inside the vortex. Arms made of whipping wind.


### 096 · Kestrike

*A kicking falcon.* · Found in: Cliffs

**096 Kestrike** (`kestrike`) · Wind / Brawl · Does not evolve · Size M  
Palette: rust, white, black  
Rust-and-white falcon with strong taloned legs raised in a high kick. Wing feathers flare like a martial-arts sash, and it has fierce black eye stripes.


### 097–099 · Dozelet line

*A dreaming sheep.* · Found in: Meadows (night)

**097 Dozelet** (`dozelet`) · Mind · Lv 18 → Reverell · Size S  
Palette: lavender wool, white  
Small sleepy lamb with a cloud-like lavender wool coat and closed eyes. A dream bubble with a little star floats above its head.

**098 Reverell** (`reverell`) · Mind · Lv 38 → Somnarch · Size M  
Palette: lavender, white, starry blue  
Sheep whose lavender wool forms swirling dream clouds dotted with tiny stars. It walks in its sleep, eyes closed and serene.

**099 Somnarch** (`somnarch`) · Mind / Fae · Final · Size L  
Palette: midnight blue, lavender, gold stars  
Majestic ram of dreams with a starry midnight-blue wool cloak and crescent-moon horns. Floating, with dream wisps drifting around it.


### 100–101 · Tickowl line

*A clockwork owl.* · Found in: City clocktower

**100 Tickowl** (`tickowl`) · Mind / Metal · Lv 34 → Chronowl · Size S  
Palette: brass, teal  
Small brass owl with clock-face eyes and gear-shaped wings. Its head is tilted, and a ticking motion is implied.

**101 Chronowl** (`chronowl`) · Mind / Metal · Final · Size M  
Palette: brass, teal, white  
Larger owl with a pendulum tail, a clock dial on its chest and wing feathers like clock hands. Its eyes are glowing teal dials.


### 102 · Omencat

*A black cat of omens.* · Found in: Towns (night)

**102 Omencat** (`omencat`) · Mind / Shadow · Does not evolve · Size S  
Palette: black, violet eyes  
Sleek black cat with glowing violet eyes, a third eye on its forehead and a forked tail. Sitting elegantly, staring.


### 103–104 · Riddlecub line

*A riddle-asking sphinx.* · Found in: Desert ruins

**103 Riddlecub** (`riddlecub`) · Mind · Lv 40 → Sphyrion · Size S  
Palette: sand gold, blue  
Lion cub with a pharaoh-like striped headdress pattern in its fur and blue eye markings. Head tilted curiously.

**104 Sphyrion** (`sphyrion`) · Mind / Earth · Final · Size L  
Palette: gold, lapis blue, sandstone  
Sphinx with golden wings and a lapis-and-sandstone headdress. Lounging regally on a stone plinth, with eyes that see everything.


### 105–107 · Wisplet line

*A wisp line.* · Found in: Haunted house / graveyard

**105 Wisplet** (`wisplet`) · Spirit · Lv 25 → Mournlight · Size S  
Palette: pale blue glow  
Small floating wisp of pale blue light with a sad face and a trailing tail. Faintly translucent.

**106 Mournlight** (`mournlight`) · Spirit · Trade → Veilwraith · Size M  
Palette: blue glow, grey  
Lantern-shaped spirit whose body is a glowing lamp of mournful blue light. A cracked glass face and drifting chain arms.

**107 Veilwraith** (`veilwraith`) · Spirit / Shadow · Final · Size L  
Palette: black veil, violet, pale face  
Tall wraith in a flowing black veil with a pale, mask-like face and long clawed hands reaching forward. Violet eyes.


### 108 · Parasoul

*A haunted umbrella.* · Found in: Rainy towns

**108 Parasoul** (`parasoul`) · Spirit / Wind · Does not evolve · Size M  
Palette: faded red paper, wood  
Old paper umbrella with faded red paper, one large eye and a long tongue, hopping on its wooden handle. Torn edges.


### 109–110 · Cairnling line

*A haunted cairn of stones.* · Found in: Graveyard / ruins

**109 Cairnling** (`cairnling`) · Spirit / Stone · Lv 36 → Cairnwight · Size S  
Palette: grey stones, blue glow  
Small stack of grey stones with ghostly blue eyes glowing in the gaps. Moss on the top stone.

**110 Cairnwight** (`cairnwight`) · Spirit / Stone · Final · Size L  
Palette: dark stone, blue glow  
Tall cairn of stacked dark stones forming a hulking figure with long arms and a glowing blue core in its chest.


### 111–112 · Pilfurr line

*A sneaky raccoon thief.* · Found in: Towns

**111 Pilfurr** (`pilfurr`) · Shadow · Lv 30 → Banditail · Size S  
Palette: grey, black mask, white  
Raccoon kit with a black bandit mask and a ringed tail. Holding a stolen shiny coin and looking over its shoulder.

**112 Banditail** (`banditail`) · Shadow · Final · Size M  
Palette: grey, black, gold  
Raccoon on two legs in a black mask, with a bushy ringed tail stuffed with stolen gold trinkets. Sly grin.


### 113–114 · Snickerpup line

*A cackling hyena.* · Found in: Night routes

**113 Snickerpup** (`snickerpup`) · Shadow · Lv 32 → Cacklehyde · Size S  
Palette: dusty tan, black spots  
Hyena pup with dusty tan spotted fur, big round ears and an oversized giggling grin.

**114 Cacklehyde** (`cacklehyde`) · Shadow / Brawl · Final · Size L  
Palette: dark tan, black, red  
Muscular hyena brute with a bristling red-tipped mane and scarred knuckles. Standing upright, laughing.


### 115 · Grimpkin

*A mischievous pumpkin imp.* · Found in: Haunted woods

**115 Grimpkin** (`grimpkin`) · Shadow / Fae · Does not evolve · Size S  
Palette: orange, black, purple  
Small imp wearing a carved pumpkin as a helmet, with a forked tail and purple sparkly mischief magic in one hand.


### 116–117 · Rivetbug line

*A rolling armoured bug.* · Found in: Caves / mines

**116 Rivetbug** (`rivetbug`) · Insect / Metal · Lv 33 → Ironshell · Size S  
Palette: steel grey, rivets  
Small pill bug made of overlapping steel plates fastened with rivets. Half-curled, peeking out.

**117 Ironshell** (`ironshell`) · Insect / Metal · Final · Size M  
Palette: iron, bronze  
Large armoured beetle with plate armour like a knight's and a long horn like a lance. Bronze trim. A charging stance.


### 118–119 · Chimelet line

*A wind chime spirit.* · Found in: Shrines / mountains

**118 Chimelet** (`chimelet`) · Metal / Fae · Lv 34 → Carillon · Size S  
Palette: silver, pastel pink  
Small wind chime with hanging metal tubes for legs and a cheerful face on the top bar. A pastel ribbon.

**119 Carillon** (`carillon`) · Metal / Fae · Final · Size M  
Palette: silver, gold, pastel  
Bell-tower creature with a large silver bell body, small arms and chimes that ring a melody. Visible musical notes.


### 120–121 · Gearpup line

*A clockwork dog.* · Found in: Towns

**120 Gearpup** (`gearpup`) · Metal · Lv 32 → Clankhound · Size S  
Palette: steel, brass  
Small robot puppy with gear-shaped ears, a wind-up key in its back and a wagging spring tail.

**121 Clankhound** (`clankhound`) · Metal · Final · Size L  
Palette: steel, brass, red eye  
Large mechanical hound with piston legs, a steam vent on its back and a glowing red eye. A guard-dog stance.


### 122–123 · Dewlette line

*A dewdrop fairy.* · Found in: Meadows (dawn)

**122 Dewlette** (`dewlette`) · Fae · Item: Sun Stone → Dewdancer · Size S  
Palette: clear blue, pink  
Tiny fairy whose body is a clear blue dewdrop with a face and a leaf hat. Sitting on a leaf.

**123 Dewdancer** (`dewdancer`) · Fae · Final · Size M  
Palette: clear blue, pink, white  
Graceful fairy dancer whose dress is made of water droplets catching the light. Mid-pirouette.


### 124 · Fluffawn

*A fluffy fawn.* · Found in: Woodland

**124 Fluffawn** (`fluffawn`) · Fae · Does not evolve · Size M  
Palette: cream, pink, white  
Cream fawn with cloud-like fluff on its chest and tiny flower antlers. Big, gentle eyes.


### 125 · Starlette

*A wishing star.* · Found in: Hills (night)

**125 Starlette** (`starlette`) · Fae / Mind · Does not evolve · Size S  
Palette: gold, white, pink  
Small five-pointed golden star creature with a twinkling face and a trailing sparkle tail.


### 126–128 · Scalelet line

*The pseudo-legendary dragon line.* · Found in: Mountain peak (rare)

**126 Scalelet** (`scalelet`) · Wyrm · Lv 30 → Ridgedrake · Size S  
Palette: jade, cream  
Small jade serpentine dragon with stubby legs, a big head and oversized cream belly scales. Baby-like.

**127 Ridgedrake** (`ridgedrake`) · Wyrm · Lv 55 → Peakwyrm · Size M  
Palette: jade, grey, cream  
Lithe jade drake with grey stone ridges along its spine, small wings and a long tail. Alert, about to take off.

**128 Peakwyrm** (`peakwyrm`) · Wyrm / Stone · Final · Size XL  
Palette: jade, slate, gold  
Massive dragon whose spine forms a mountain range of slate peaks, with gold-tipped stone horns and great wings. Rearing. Fills the frame.


### 129–130 · Coilfin line

*A whirlpool sea drake. (Moved here from the Water starter line: too strong for a starter.)* · Found in: Sea (late game, rare)

**129 Coilfin** (`coilfin`) · Water · Lv 45 → Maelstrake · Size S  
Palette: deep blue, white  
Small, deep-blue eel-like fish with a frilly white fin crest, coiled around itself like a spring.

**130 Maelstrake** (`maelstrake`) · Water / Wyrm · Final · Size XL  
Palette: deep blue, teal, white foam  
Huge sea drake coiled in a spiral like a whirlpool, with a frill of white foam and a long, sinuous body. Fills the frame.


### 131 · Verdrake

*A forest dragon.* · Found in: Ancient forest (rare)

**131 Verdrake** (`verdrake`) · Wyrm / Flora · Does not evolve · Size L  
Palette: forest green, bark brown, blossoms  
Dragon covered in moss and blossoms, with branch-like horns and leafy wings. Peaceful but ancient.


### 132 · Lumbear

*A sleepy bear.* · Found in: Routes

**132 Lumbear** (`lumbear`) · Common · Does not evolve · Size XL  
Palette: brown, cream  
Huge sleepy brown bear lying across a path, snoring, with a cream belly. Fills the frame.


### 133–134 · Snoutle line

*A truffle pig.* · Found in: Farms / woods

**133 Snoutle** (`snoutle`) · Common · Lv 30 → Truffhog · Size S  
Palette: pink, brown  
Small pink piglet with an oversized snout always sniffing the ground. Curly tail.

**134 Truffhog** (`truffhog`) · Common / Earth · Final · Size M  
Palette: brown, pink, earth  
Brown boar with a powerful digging snout, small tusks and truffles growing on its bristly back.


### 135 · Hummling

*A hummingbird.* · Found in: Gardens

**135 Hummling** (`hummling`) · Common / Fae · Does not evolve · Size S  
Palette: iridescent green, pink  
Tiny iridescent green hummingbird with blurred wings, a long beak and a pink throat.


### 136 · Mimicat

*A copycat cat.* · Found in: Towns

**136 Mimicat** (`mimicat`) · Common · Does not evolve · Size S  
Palette: cream, patchwork colours  
Cream cat with patchwork fur patches that copy the patterns of other creatures. Sly smile.


### 137–138 · Woolump line

*A woolly sheep.* · Found in: Farms / hills

**137 Woolump** (`woolump`) · Common · Lv 30 → Woolossus · Size S  
Palette: white wool, grey face  
Small, round white sheep that is mostly wool, with a grey face and tiny legs.

**138 Woolossus** (`woolossus`) · Common · Final · Size XL  
Palette: white wool, grey  
Gigantic sheep whose white wool is a mountain of fluff, with a small grey face peeking out. Fills the frame.


### 139 · Ashcrow

*An ash crow.* · Found in: Volcano

**139 Ashcrow** (`ashcrow`) · Flame / Shadow · Does not evolve · Size M  
Palette: ash grey, ember orange  
Crow whose feathers smoulder at the tips with ember orange, trailing ash. Perched, cawing.


### 140 · Rimewisp

*A frost wisp lantern.* · Found in: Ice caves

**140 Rimewisp** (`rimewisp`) · Frost / Spirit · Does not evolve · Size S  
Palette: ice blue, pale glow  
Floating frozen lantern spirit with a cold blue flame inside a frosted glass body.


### 141 · Bellbuoy

*A haunted buoy bell.* · Found in: Sea

**141 Bellbuoy** (`bellbuoy`) · Spirit / Water · Does not evolve · Size M  
Palette: rusty red, white, sea green  
Old harbour buoy, rusty red with a sea-green base, whose bell tolls by itself. Barnacles and a ghostly face.


### 142–143 · Platefin line

*An armoured prehistoric fish.* · Found in: Fossil (museum revival)

**142 Platefin** (`platefin`) · Stone / Water · Lv 40 → Dunkleon · Size S  
Palette: bone tan, slate  
Small armoured fish with a bony plate head and a tan body. Ancient look.

**143 Dunkleon** (`dunkleon`) · Stone / Water · Final · Size L  
Palette: slate, bone, dark  
Massive armoured fish with a huge bony jaw plate that slices like shears. Slate and bone colours. Fills the frame.


### 144–145 · Scuttlite line

*A prehistoric sea scorpion.* · Found in: Fossil (museum revival)

**144 Scuttlite** (`scuttlite`) · Stone / Insect · Lv 40 → Scorptera · Size S  
Palette: amber, brown  
Small, trilobite-like amber-coloured creature with segmented armour and many tiny legs.

**145 Scorptera** (`scorptera`) · Stone / Insect · Final · Size L  
Palette: amber, dark brown  
Huge sea scorpion with paddle legs, armoured amber plates and a spiked tail. A menacing raised-claws pose.


### 146–148 · Halvorn line

*The three Peak Wardens, each guarding a mountain.* · Found in: Legendary

**146 Halvorn** (`halvorn`) · Frost / Wind · Final · Size XL  
Palette: ice white, pale blue, silver  
Great owl-stag of the glacier: an owl's head and wings on a stag's body, with ice-crystal antlers and a frost cape. Should read as ancient and serene. Fills the frame.

**147 Thundrel** (`thundrel`) · Volt / Brawl · Final · Size XL  
Palette: storm yellow, black, white  
Storm titan: a bear-like humanoid wrapped in storm clouds, with lightning-bolt horns and fists crackling with thunder. Should look fierce and electric. Fills the frame.

**148 Solaric** (`solaric`) · Flame / Mind · Final · Size XL  
Palette: sun gold, white, crimson  
Sun spirit lion with a radiant golden mane like a solar corona, a third eye of crimson fire and floating rings. Should look serene and powerful. Fills the frame.


### 149 · Vaelith

*The region's great legend.* · Found in: Legendary

**149 Vaelith** (`vaelith`) · Spirit / Wyrm · Does not evolve · Size XL  
Palette: silver, pale violet, black  
Ancient spirit dragon of silver and pale violet, with long translucent wings like veils, a skeletal crown and trailing spectral mist. The region's great legend. Fills the frame.


### 150 · Primmi

*The origin of all monsters.* · Found in: Mythical

**150 Primmi** (`primmi`) · Fae / Mind · Does not evolve · Size S  
Palette: soft pink, white  
Tiny primordial creature, soft pink and white, with big curious eyes, a long tail and small wing-like ears. Floating playfully. Simple shapes that hint at every other monster.
