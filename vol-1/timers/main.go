package main

import (
	// local
	"c64-sid-vicious/timer-videos/videogen"

	// standard
	"fmt"
)

func main() {
	/* The reason for why we add 0.5 seconds to every video is so that the user
	   can see the timer reach the target value (like 64:00); otherwise it would
	   only be 1 frame and the viewer will not see it */
	fps := 60
	songMetas := []videogen.SongMetadata{
		{"01_boulder-dash", "Boulder Dash - 1984, Peter Liepa", 120.5},
		{"02_bubble-bobble", "Bubble Bobble - 1987, Peter Clarke", 261.5},
		{"03_california-games", "California Games - 1987, Chris Grigg", 90.5},
		{"04_commando", "Commando - 1985, Rob Hubbard", 358.5},
		{"05_double-dragon-ii", "Double Dragon II - 1989, Dave Lowe", 398.5},
		{"06_dragon-ninja", "Dragon Ninja - 1989, Jonathan Dunn", 325.5},
		{"07_elevator-action", "Elevator Action - 1987, David Whittaker", 155.5},
		{"08_emlyn-hughes-intl-soccer", "Emlyn Hughes Intl. Soccer - 1988, Barry Leich", 126.5},
		{"09_ghostbusters", "Ghostbusters - 1984, Russell Lieblich", 237.5},
		{"10_ghost-n-goblins", "Ghost 'n Goblins - 1986, Mark Cooksey", 241.5},
		{"11_the-great-giana-sisters", "The Great Giana Sisters - 1987, Chris Huelsbeck", 688.5},
		{"12_lazy-jones", "Lazy Jones - 1984, David Whittaker", 349.5},
		{"13_maniac-mansion", "Maniac Mansion - 1987, Chris Grigg+David Lawrence", 103.5},
		{"14_microprose-soccer", "MicroProse Soccer - 1988, Martin Galway", 247.5},
		{"15_cracktro_impact-us", "(Crack Intro) Impact US", 63.5},
	}

	videogen.GenerateTimerUpVideo(64.0*60.0+0.5, fps)
	videogen.GenerateTimerDownVideo(64.0*60.0+0.5, fps)
	videogen.GenerateSongTimerVideos(songMetas, fps)

	fmt.Println("done")
}
