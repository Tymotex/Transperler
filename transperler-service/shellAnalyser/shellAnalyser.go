package shellAnalyser

import (
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"transperler-service/transpiler"
	"transperler-service/utils"

	"github.com/gin-gonic/gin"
)

const ShellAnalyserBinaryPath = "/usr/bin/shellcheck"
const TempShellDir = "/tmp"

type ShellAnalyserOutput struct {
	Status string `json:"status"`
	Message string `json:"message"`
}

func ExtractShellSourceToTempFile(context *gin.Context) *os.File {
	var shellAnalyserOutput ShellAnalyserOutput

	// Create a temporary file buffer for the shell source code. The transpiler
	// expects a filestream, not a string.
	os.MkdirAll(filepath.Join(".", TempShellDir), os.ModePerm)
	tmpFile, createErr := os.CreateTemp(TempShellDir, "*.sh")
	if createErr != nil {
		shellAnalyserOutput.Status = "error"
		shellAnalyserOutput.Message = "Server failure. Failed to create shell source file."
		context.JSON(http.StatusBadRequest, shellAnalyserOutput)
		return nil
	}

	// Write the request's source code into the tmp file.
	var shSource transpiler.ShellSource
	if extractErr := context.BindJSON(&shSource); extractErr != nil {
		shellAnalyserOutput.Status = "error"
		shellAnalyserOutput.Message = fmt.Sprintf("Bad request: %s", extractErr.Error())
		context.JSON(http.StatusBadRequest, shellAnalyserOutput)
		return nil
	}

	if len(shSource.ShSourceCode) > 50000 || utils.LinesStringCount(shSource.ShSourceCode) > 1000 {
		shellAnalyserOutput.Status = "error"
		shellAnalyserOutput.Message = "Input shell script must be fewer than 50000 characters and 1000 lines."
		context.JSON(http.StatusBadRequest, shellAnalyserOutput)
		return nil
	}

	_, writeErr := tmpFile.WriteString(shSource.ShSourceCode + "\n") 
	if writeErr != nil {
		shellAnalyserOutput.Status = "error"
		shellAnalyserOutput.Message = "Server failure. Failed to write to shell source file."
		context.JSON(http.StatusInternalServerError, shellAnalyserOutput)
	}
	tmpFile.Close()
	return tmpFile
}

func Post(context *gin.Context) {
	tmpFile := ExtractShellSourceToTempFile(context)
	if tmpFile == nil {
		return
	}
	defer os.Remove(tmpFile.Name())

	// Execute the Shell analyser, passing in the tmp file path.
	sourcePath := tmpFile.Name()
	cmd := exec.Command(ShellAnalyserBinaryPath, sourcePath)
	stdout, err := cmd.Output()

	if err != nil {
		stdout := string(stdout)
		if stdout != "" {
			stdout = "Shell static analyser server error."
		}
		shellAnalyserOutput := ShellAnalyserOutput {
			Status: "error",
			Message: string(stdout),
		}
		context.JSON(http.StatusOK, shellAnalyserOutput)
		return
	} else {
		// Respond with transpiled output.
		shellAnalyserOutput := ShellAnalyserOutput {
			Status: "success",
			Message: "",
		}
		context.JSON(http.StatusOK, shellAnalyserOutput)
		return
	}
}
