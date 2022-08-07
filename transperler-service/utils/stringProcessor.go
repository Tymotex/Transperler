package utils

import "strings"

func LinesStringCount(s string) int {
    n := strings.Count(s, "\n")
    if len(s) > 0 && !strings.HasSuffix(s, "\n") {
        n++
    }
    return n
}