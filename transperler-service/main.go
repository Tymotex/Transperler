package main

import (
	"net/http"
	"transperler-service/shellAnalyser"
	"transperler-service/transpiler"

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
	
	// This used to be `router.Run("localhost:8080")` but this would make the
	// container unresponsive to queries. Changing it to `0.0.0.0:8080` solves
	// this issue.
	// Source: https://stackoverflow.com/questions/72783444/docker-go-server-does-not-respond
	router.Run("0.0.0.0:8080")
}
