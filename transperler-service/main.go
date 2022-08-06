package main

import (
	"net/http"
	"transperler-service/transpiler"
	"transperler-service/shellAnalyser"

	"github.com/gin-gonic/gin"
)

// Initialise the Gin router and attach all endpoints.
func setupRouter() *gin.Engine {
	router := gin.Default()
	
	// Health check endpoint.
	router.GET("/", func(context *gin.Context) {
		context.String(http.StatusOK, "Transperler API is alive.")
	})

	// Register transpiler and shell analyser endpoints.
	router.POST("/transpiler", transpiler.Post)
	router.POST("/shell-analysis", shellAnalyser.Post)

	return router
}

func main() {
	router := setupRouter()	
	router.Run("localhost:8080")
}
