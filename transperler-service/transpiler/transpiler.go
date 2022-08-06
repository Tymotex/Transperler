package transpiler

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

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
}

func Post(context *gin.Context) {
	context.String(http.StatusOK, "Transpiler hit")
}
