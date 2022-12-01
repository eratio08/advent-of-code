package helpers

import (
	"log"
	"os"
	"strings"
)

func ReadFile(input string) string {
	fileContent, err := os.ReadFile(input)
	if err != nil {
		log.Println(err)
		os.Exit(1)
	}

	return string(fileContent)
}

func ReadLines(input string) []string {
	content := ReadFile(input)
	return strings.Split(content, "\n")
}
