package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// // album represents data about a record album.
// type album struct {
//     ID     string  `json:"id"`
//     Title  string  `json:"title"`
//     Artist string  `json:"artist"`
//     Price  float64 `json:"price"`
// }

// Initialise the Gin router and attach all endpoints.
func setupRouter() *gin.Engine {
	router := gin.Default()
	
	// Health check endpoint.
	router.GET("/", func(context *gin.Context) {
		context.String(200, "Transperler API is alive.")
	})

	// Register transpiler and shell analyser endpoints.
	// router.POST("/transpiler", postTranspiler)

	return router
}

func main() {
	router := setupRouter()	
	router.Run("localhost:8080")
}

func getIndex(context *gin.Context) {
	context.IndentedJSON(http.StatusOK, "The API is alive!")
}
