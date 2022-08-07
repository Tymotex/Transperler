package transpiler

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"transperler-service/utils"

	"github.com/gin-gonic/gin"
)

const TranspilerBinaryPath = "./transpiler/transperler"
const TempShellDir = "./.tmp-shell"

// Note:
// Struct tags such as json:"shSourceCode" specify what a field’s name should be
// when the struct’s contents are serialized into JSON. Without them, the JSON
// would use the struct’s capitalized field names – a style not as common in
// JSON.
type ShellSource struct {
	ShSourceCode string `json:"shSourceCode"`
}

type PerlOutput struct {
	PlOutput string `json:"plOutput"`
	Message string `json:"message"`
}

func ExtractShellSourceToTempFile(context *gin.Context) *os.File {
	var perlOutput PerlOutput

	// Create a temporary file buffer for the shell source code. The transpiler
	// expects a filestream, not a string.
	tmpFile, createErr := os.CreateTemp(TempShellDir, "*.sh")
	if createErr != nil {
		perlOutput.Message = "Failed to create shell source file."
		context.JSON(http.StatusBadRequest, perlOutput)
		return nil
	}

	// Write the request's source code into the tmp file.
	var shSource ShellSource
	if extractErr := context.BindJSON(&shSource); extractErr != nil {
		perlOutput.Message = fmt.Sprintf("Bad request: %s", extractErr.Error())
		context.JSON(http.StatusBadRequest, perlOutput)
		return nil
	}

	if len(shSource.ShSourceCode) > 50000 || utils.LinesStringCount(shSource.ShSourceCode) > 1000 {
		perlOutput.Message = "Input shell script must be fewer than 50000 characters and 1000 lines."
		context.JSON(http.StatusBadRequest, perlOutput)
		return nil
	}

	_, writeErr := tmpFile.WriteString(shSource.ShSourceCode + "\n") 
	if writeErr != nil {
		perlOutput.Message = "Failed to write to shell source file."
		context.JSON(http.StatusInternalServerError, perlOutput)
	}
	tmpFile.Close()
	return tmpFile
}

func Post(context *gin.Context) {
	tmpFile := ExtractShellSourceToTempFile(context)
	defer os.Remove(tmpFile.Name())
	if tmpFile == nil {
		return
	}
	
	// Execute the transpiler, passing in the tmp file path.
	sourcePath := tmpFile.Name()
	cmd := exec.Command(TranspilerBinaryPath, sourcePath)
	stdout, err := cmd.Output()

	if err != nil {
		log.Fatal(err)
		perlOutput := PerlOutput {
			PlOutput: "",
			Message: fmt.Sprintf("The transpiler failed. Error: %s", err.Error()),
		}
		context.JSON(http.StatusInternalServerError, perlOutput)
		return
	}

	// Respond with transpiled output.
	perlOutput := PerlOutput {
		PlOutput: string(stdout),
		Message: "Transpiled successfully.",
	}
	context.JSON(http.StatusOK, perlOutput)
}
