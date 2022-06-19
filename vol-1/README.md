# C64 S.I.D. Vicious Vol. 1
This is the first video on the series (at the time of writing, I'm not sure there'll be a second one, but I still have some memorable tracks I would like to share, so maybe...)

<img src="https://github.com/nix-codes/c64-sid-vicious/blob/main/vol-1/preview.png" width="600">

Watch it [here](https://www.youtube.com/watch?v=8fDXlhXsQ64)




## Main tools used:
- Vice Emulator
- CBM Prg Studio - Arthur Jordison
- Dir Master (Style64) \<Windows\>
- Dir Master - Wim Taymans \<C64\>
- sidplay2 - A. Lorentzon / H. Pedersen
- ffmpeg
- VSDC Video Editor
- GIMP
- Audacity

Programmed mainly in 6502 assembly and Golang.


## Organization of the code
### 1) 6502 assembly files
These are written for CBM Prg Studio assembler:
* `intro.asm`: this program is the intro of the video, where there is some text shown and color effects on the borders of the screen.
* `clip-transition`: this is the program for creating the "transition" effect that we use between clips of gameplays
* `outro`: this one is the most complex routine of the 3. It shows the credits and uses some "color-cycling" effect.

### 2) Video generator for the different timers
The `timers` folder contains a program written in Golang that will generate little timer videos used for the tracks as well as for the overall timer of the video.
Originally I experimented with a few implementations of a timer in BASIC and then in Assembly. There was no way I could get it to be accurate enough (let alone making it frame-perfect). I eventually gave up and opted for implemeting a video generator for this.
As a bonus, the generator allows us to place arbitrary text above the timer, which we use for displaying the song name across the extended content area.

### 3) Scrolling pictures
These are generated with the [Countube](https://github.com/nix-codes/countube) project. We'll reuse it.

## How is the video sectioned and layered
We'll first divide the video in 3 major sections:
* intro
* main (game-clips + song tracks)
* outro

Some clarifications beforehand:
* By stacking layers and cropping different parts of videos, we can achieve the effect of making the C64 screen look wide.
We'll describe the layers in ascending order. Those layers that appear first and, consequently, have a lower sequence number will override the ones below.
* We'll use location coordinates like so: `(x, y, w, h)` representing the X coordinate, Y coordinate, width and height of an area of the video, respectively.
* Croppings are done on the source images

## C64 screen object sizes (in pixels):
- original
  - full screen: 384x272
  - top border: 35
  - bottom border: 37
  - left border: 32
  - right border: 32
  - inner area: 320x200
  - character: 8x8
- Resized:
  - full screen: 1525x1080
  - top border: ~139
  - bottom border: ~147
  - left border: 129
  - right border: 129
  - character: 32x32

  
## Audio
Each track ends with a 2-second silence, which we use to place the transition scenes.
For the spectrum, we generate a single wav file with all the audio from the main section and we synchronize the spectrum to that resource.

## Video composition

### Video section: Global timers
- **Layer 1**: Global timers appear throughout the whole video, so they appear at all times.
  - _top timer_ (timer counting upwards) location: `(1760, 0, 160, 32)`
  - _bottom timer_ (timer counting downwards) location: `(1760, 1048, 160, 32)`


### Video section: Intro
This section corresponds to editing what was produced by `intro.asm`. Given that we are making the screen wider, we need to make adjustments, and take especial care of the border loading effects.
- **Clear screen snapshot**: We take a snapshot of the frame of the video when the screen is clear. We'll use crops of this image on other parts.
- **Layer 2**: _top border, left side_
  - crop: `(0, 0, 384, 35)`
  - location: `(0, 0, 1525, 139)`
- **Layer 3**: _top border, right side_
  - crop: `(0, 0, 384, 35)`
  - location: `(395, 0, 1525, 139)`
- **Layer 4**: _left_ (excludes the right border)
  - crop: `(0, 0, 352, 272)`
  - location: `(0, 0, 1398, 1080)`
- **Layer 5**: _right border_
  - crop: `(352, 0, 32, 272)`
  - location: `(1793, 0, 129, 1080)`
- **Layer 6**: _bottom border, left side_
  - crop: `(0, 235, 384, 37)`
  - location: `(0, 933, 1525, 148)`
- **Layer 7**: _bottom border, right side_
  - crop: `(0, 235, 384, 37)`
  - location: `(395, 933, 1525, 148)`
- **Layer 8**: _blue area extender_ (using the **clear screen snapshot**)
  - crop: `(868, 137, 532, 798)`
  - location: `(1263, 137, 532, 798)`

### Video section: Main
- **Layer 9**: _gameplay clips_
  - crop: `(32, 35, 320, 200)`
  - location: `(480, 240, 960, 600)`
- **Layer 10**: _song title + timers_: we generate these mini videos with the code in `timers` directory
  - location: `(160, 840, 1600, 92)`
- **Layer 11**: _Countune scrolling pics_: this video is generated with `Countube`
  - location: `(128, 240, 1664, 600)`
- **Layer 12**: _static background screen, left_ (using the **clear screen snapshot**)
  - crop: `(0, 0, 1395, 1080)`
  - location: `(0, 0, 1395, 1080)`
- **Layer 13**: _static background screen, right_ (using the **clear screen snapshot**)
  - crop: `(999, 0, 526, 1080)`
  - location: `(1394, 0, 526, 1080)`
