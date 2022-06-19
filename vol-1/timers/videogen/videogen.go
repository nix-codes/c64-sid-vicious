/*
   The entry point for generating the different sub-videos that we use on our
   main video.
*/
package videogen

import (
	// local
	"c64-sid-vicious/timer-videos/c64"
	"c64-sid-vicious/timer-videos/common"

	// standard
	"bufio"
	"bytes"
	"fmt"
	"image"
	"image/color"
	"image/png"
	"os"
	"path/filepath"
	"time"
)

const (
	OutputPath                   = "out/"
	TimerUpVideoFramesFilename   = "global-timer-up"
	TimerDownVideoFramesFilename = "global-timer-down"
	FramesFileExt                = ".frames"
)

type SongMetadata struct {
	Name        string
	Description string
	Seconds     float64
}

func GenerateSongTimerVideos(songMetas []SongMetadata, fps int) {

	for i := 0; i < len(songMetas); i++ {
		songMeta := songMetas[i]
		GenerateSongTimerVideo(songMeta.Name, songMeta.Description, songMeta.Seconds, fps)
	}
}

func GenerateSongTimerVideo(name string, description string, seconds float64, fps int) {
	bgColor := color.RGBA{85, 65, 187, 255}
	gt := c64.NewGraphicText(50, 3, c64.CharWidth, c64.CharHeight, bgColor)

	upTimer := c64.NewTimer(0)
	downTimer := c64.NewTimer(int(seconds))
	frameImg := gt.GetImage()

	paintTimer := func() {
		timerText := upTimer.ToString() + " | " + downTimer.ToString()
		gt.SetLine(2, c64.GreenOnBlueCharset, timerText)
	}

	gt.SetLine(0, c64.YellowOnBlueCharset, description)
	paintTimer()

	generateVideo(name, seconds, fps, frameImg, func(frameIdx int) {

		if (frameIdx+1)%fps == 0 {
			upTimer.TickUp()
			downTimer.TickDown()
			paintTimer()
		}
	})
}

func GenerateTimerUpVideo(seconds float64, fps int) {
	timer := c64.NewTimer(0)
	bgColor := color.Black
	gt := c64.NewGraphicText(5, 1, c64.CharWidth, c64.CharHeight, bgColor)
	frameImg := gt.GetImage()

	paintTimer := func() {
		gt.SetLine(0, c64.WhiteOnLightBlueCharset, timer.ToString())
	}

	paintTimer()
	generateVideo(TimerUpVideoFramesFilename, seconds, fps, frameImg, func(frameIdx int) {

		if (frameIdx+1)%fps == 0 {
			timer.TickUp()
			paintTimer()
		}
	})
}

func GenerateTimerDownVideo(seconds float64, fps int) {
	timer := c64.NewTimer(int(seconds))
	bgColor := color.Black
	gt := c64.NewGraphicText(5, 1, c64.CharWidth, c64.CharHeight, bgColor)
	frameImg := gt.GetImage()

	paintTimer := func() {
		gt.SetLine(0, c64.WhiteOnLightBlueCharset, timer.ToString())
	}

	paintTimer()
	generateVideo(TimerDownVideoFramesFilename, seconds, fps, frameImg, func(frameIdx int) {

		if (frameIdx+1)%fps == 0 {
			timer.TickDown()
			paintTimer()
		}
	})
}

func generateVideo(name string, seconds float64, fps int, frameImg image.Image,
	frameWritten func(int)) {

	outFile := createOutFile(name)
	fmt.Println("Generating " + outFile.Name())
	defer outFile.Close()
	buffer := new(bytes.Buffer)
	writer := bufio.NewWriter(outFile)

	totalFrames := int(seconds * float64(fps))

	monitorVideoGeneration(totalFrames, func(frameIdx int) {
		/* uncomment the following line if you need to debug and look at each frame */
		// common.WritePngToFile(fmt.Sprintf("out/%04d.png", frameIdx), frameImg)

		// write frame into the file using a buffer
		png.Encode(buffer, frameImg)
		_, err := writer.Write(buffer.Bytes())
		common.CheckErr(err)
		buffer.Reset()

		frameWritten(frameIdx)
	})

	writer.Flush()
}

func monitorVideoGeneration(totalFrames int, writeFrame func(int)) {

	startTime := time.Now()
	elapsed := time.Duration(0)
	lastElapsedCheckTime := startTime
	eta := elapsed

	for i := 0; i < totalFrames; i++ {
		fmt.Printf("processing frame: %d / %d  |  elapsed: %s  | eta: %s                          \r",
			i+1, totalFrames, elapsed, eta)

		if time.Since(lastElapsedCheckTime).Truncate(time.Second) >= 1 {
			// we update the elapsed and eta every second
			lastElapsedCheckTime = time.Now()
			elapsed = time.Since(startTime).Truncate(time.Second)
			remainingFrames := totalFrames - i
			eta = time.Duration(int(float64(remainingFrames)*elapsed.Seconds()/float64(i))) * time.Second
		}

		writeFrame(i)
	}

	fmt.Println()
}

func createOutFile(name string) *os.File {
	common.EnsurePath(OutputPath)
	outFilePath := filepath.Join(OutputPath, name+FramesFileExt)
	outFile, err := os.Create(outFilePath)
	common.CheckErr(err)

	return outFile
}
