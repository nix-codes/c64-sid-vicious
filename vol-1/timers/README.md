This program will generate frame images for the different timers that we use in the video, in the following format: "00:00"

Output is placed in out/<timer-name>.frames
A .frames file is a concatenation of png images that correspond to each frame.
In order to produce a video out of that, you can use `ffmpeg` like so:
`$ ffmpeg -framerate 60 -i out/global-timer-up.frames out/global-timer-up.mp4`

For simplicity and a quick implementation, we don't use real fonts when writing graphic text.
Instead, we use a technique where we create an image file that contains all characters available (charset). We then map a letter/rune to an area of that image in order to write the graphic text.

To create a charset image, these BASIC commands are useful on the C64:

```
rem ** change screen mode: lowercase + uppercase **
poke 53272, 23

rem ** change screen mode: uppercase + petscii **
poke 53272, 21

rem ** change background color **
poke 53281, 7

rem ** change foreground color **
poke 646,1
```
