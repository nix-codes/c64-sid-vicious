package common

import (
	"bufio"
	"bytes"
	"image"
	"image/jpeg"
	"image/png"
	"log"
	"os"
)

func EnsurePath(path string) {

	if err := os.MkdirAll(path, os.ModePerm); err != nil {
		log.Fatal(err)
	}
}

func WritePngToFile(filePath string, img image.Image) {
	outFile, err := os.Create(filePath)
	CheckErr(err)
	defer outFile.Close()

	err = png.Encode(outFile, img)
	CheckErr(err)
}

func WriteJpegToFile(filePath string, img image.Image) {
	outFile, err := os.Create(filePath)
	CheckErr(err)
	defer outFile.Close()

	buf := new(bytes.Buffer)
	writer := bufio.NewWriter(outFile)

	jpeg.Encode(buf, img, &jpeg.Options{100})
	_, err = writer.Write(buf.Bytes())
	CheckErr(err)
}

func ReadImageFromFile(filePath string) image.Image {

	f, err := os.Open(filePath)
	CheckErr(err)
	defer f.Close()

	img, _, err := image.Decode(f)
	CheckErr(err)

	return img
}

func CheckErr(err error) {
	if err != nil {
		log.Fatal(err)
	}
}
