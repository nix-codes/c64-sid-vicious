package c64

import (
	// local
	"c64-sid-vicious/timer-videos/common"

	// standard
	"image"
)

const CharWidth = 8
const CharHeight = 8

var charMapping = map[rune]image.Point{
	'a': image.Point{0, 0},
	'b': image.Point{1, 0},
	'c': image.Point{2, 0},
	'd': image.Point{3, 0},
	'e': image.Point{4, 0},
	'f': image.Point{5, 0},
	'g': image.Point{6, 0},
	'h': image.Point{7, 0},
	'i': image.Point{8, 0},
	'j': image.Point{9, 0},
	'k': image.Point{10, 0},
	'l': image.Point{11, 0},
	'm': image.Point{12, 0},
	'n': image.Point{13, 0},
	'o': image.Point{14, 0},
	'p': image.Point{15, 0},
	'q': image.Point{16, 0},
	'r': image.Point{17, 0},
	's': image.Point{18, 0},
	't': image.Point{19, 0},
	'u': image.Point{20, 0},
	'v': image.Point{21, 0},
	'w': image.Point{22, 0},
	'x': image.Point{23, 0},
	'y': image.Point{24, 0},
	'z': image.Point{25, 0},

	'A': image.Point{0, 1},
	'B': image.Point{1, 1},
	'C': image.Point{2, 1},
	'D': image.Point{3, 1},
	'E': image.Point{4, 1},
	'F': image.Point{5, 1},
	'G': image.Point{6, 1},
	'H': image.Point{7, 1},
	'I': image.Point{8, 1},
	'J': image.Point{9, 1},
	'K': image.Point{10, 1},
	'L': image.Point{11, 1},
	'M': image.Point{12, 1},
	'N': image.Point{13, 1},
	'O': image.Point{14, 1},
	'P': image.Point{15, 1},
	'Q': image.Point{16, 1},
	'R': image.Point{17, 1},
	'S': image.Point{18, 1},
	'T': image.Point{19, 1},
	'U': image.Point{20, 1},
	'V': image.Point{21, 1},
	'W': image.Point{22, 1},
	'X': image.Point{23, 1},
	'Y': image.Point{24, 1},
	'Z': image.Point{25, 1},

	'0': image.Point{0, 2},
	'1': image.Point{1, 2},
	'2': image.Point{2, 2},
	'3': image.Point{3, 2},
	'4': image.Point{4, 2},
	'5': image.Point{5, 2},
	'6': image.Point{6, 2},
	'7': image.Point{7, 2},
	'8': image.Point{8, 2},
	'9': image.Point{9, 2},

	'.':  image.Point{0, 3},
	':':  image.Point{1, 3},
	',':  image.Point{2, 3},
	';':  image.Point{3, 3},
	'+':  image.Point{4, 3},
	'-':  image.Point{5, 3},
	'*':  image.Point{6, 3},
	'=':  image.Point{7, 3},
	'\'': image.Point{8, 3},
	'"':  image.Point{9, 3},
	'(':  image.Point{10, 3},
	')':  image.Point{11, 3},
	'!':  image.Point{12, 3},
	'?':  image.Point{13, 3},
	'|':  image.Point{14, 3},
	' ':  image.Point{15, 3},
}

var YellowOnBlueCharset = NewC64charset(
	"resources/c64-charset_yellow-on-blue.png", charMapping)

var GreenOnBlueCharset = NewC64charset(
	"resources/c64-charset_green-on-blue.png", charMapping)

var WhiteOnLightBlueCharset = NewC64charset(
	"resources/c64-charset_white-on-light-blue.png", charMapping)

type C64charset struct {
	charsetImg image.Image
	charMap    map[rune]image.Point
}

func NewC64charset(charsetImageFile string, charMapping map[rune]image.Point) *C64charset {

	charsetImg := common.ReadImageFromFile(charsetImageFile)

	return &C64charset{
		charsetImg: charsetImg,
		charMap:    charMapping,
	}
}

func (c *C64charset) CharWidth() int {
	return CharWidth
}

func (c *C64charset) CharHeight() int {
	return CharHeight
}

func (c *C64charset) CharsetImage() image.Image {
	return c.charsetImg
}

func (c *C64charset) CharMapping() map[rune]image.Point {
	return c.charMap
}
