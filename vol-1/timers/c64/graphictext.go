package c64

import (
	// standard
	"image"
	"image/color"
	"image/draw"
	"strings"
)

type charset interface {
	CharWidth() int
	CharHeight() int
	CharsetImage() image.Image
	CharMapping() map[rune]image.Point
}

type graphicText struct {
	numLines   int
	numColumns int
	canvas     draw.Image
}

type textLine struct {
	charset charset
	text    string
}

func NewGraphicText(numColumns int, numLines int, charWidth int,
	charHeight int, color color.Color) *graphicText {

	backgroundImg := image.NewUniform(color)
	canvasBounds := image.Rect(0, 0, charWidth*numColumns, charHeight*numLines)
	canvas := image.NewRGBA(canvasBounds)
	draw.Draw(canvas, canvasBounds, backgroundImg, image.ZP, draw.Src)

	return &graphicText{
		numLines:   numLines,
		numColumns: numColumns,
		canvas:     canvas,
	}
}

func (gt *graphicText) SetLine(lineNum int, charset charset, text string) {

	leftSpaces := (gt.numColumns - len(text)) / 2
	leftPadding := strings.Repeat(" ", leftSpaces)

	gt.renderLine(lineNum, charset, leftPadding+text)
}

func (gt *graphicText) GetImage() image.Image {
	return gt.canvas
}

func (gt *graphicText) renderLine(lineIdx int, charset charset, text string) {
	img := gt.canvas
	charmap := charset.CharMapping()
	charWidth := charset.CharWidth()
	charHeight := charset.CharHeight()
	tgtX := 0
	tgtY := lineIdx * charHeight

	for _, char := range text {

		if charLoc, exists := charmap[char]; exists {
			srcX := charLoc.X * charWidth
			srcY := charLoc.Y * charHeight
			tgtCharBounds := image.Rect(tgtX, tgtY, tgtX+charWidth, tgtY+charHeight)
			draw.Draw(img, tgtCharBounds, charset.CharsetImage(), image.Point{srcX, srcY}, draw.Src)
		}

		tgtX = tgtX + charWidth
	}
}
