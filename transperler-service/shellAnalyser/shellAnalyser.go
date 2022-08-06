package shellAnalyser

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type ShellAnalyserOutput struct {
	Status string `json:"status"`
	Message string `json:"message"`
}

func Post(context *gin.Context) {
	context.String(http.StatusOK, "Shell analyser hit")
}
