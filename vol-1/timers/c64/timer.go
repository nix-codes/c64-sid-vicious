package c64

import (
	"fmt"
)

type timer struct {
	minutes int
	seconds int
}

func NewTimer(startingTotalSeconds int) *timer {

	minutes, seconds := parseTime(startingTotalSeconds)

	t := timer{
		minutes: minutes,
		seconds: seconds,
	}

	return &t
}

func parseTime(totalSeconds int) (int, int) {
	minutes := totalSeconds / 60
	seconds := totalSeconds % 60

	return minutes, seconds
}

func (t *timer) TickUp() {

	t.seconds += 1

	if t.seconds == 60 {
		t.seconds = 0
		t.minutes += 1
	}
}

func (t *timer) TickDown() {
	t.seconds -= 1

	if t.seconds < 0 {
		t.seconds = 59
		t.minutes -= 1
	}
}

func (t *timer) ToString() string {

	return fmt.Sprintf("%02d:%02d", t.minutes, t.seconds)
}
