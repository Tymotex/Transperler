package main

import (
	"fmt"
	"net/http"
	"os"
	"strconv"
	"time"
	"transperler-service/shellAnalyser"
	"transperler-service/transpiler"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)


func CORSMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {

        c.Header("Access-Control-Allow-Origin", "*")
        c.Header("Access-Control-Allow-Credentials", "true")
        c.Header("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
        c.Header("Access-Control-Allow-Methods", "POST,HEAD,PATCH, OPTIONS, GET, PUT")

        if c.Request.Method == "OPTIONS" {
            c.AbortWithStatus(204)
            return
        }

        c.Next()
    }
}

// Initialise the Gin router and attach all endpoints.
func setupRouter() *gin.Engine {
	router := gin.Default()

	router.Use(cors.New(cors.Config{
        AllowOrigins:     []string{"http://localhost:3000"},
        AllowMethods:     []string{"POST", "GET"},
        AllowHeaders:     []string{"Origin"},
        ExposeHeaders:    []string{"Content-Length"},
        AllowCredentials: true,
        MaxAge: 12 * time.Hour,
    }))
	
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
	
	port, error := strconv.Atoi(os.Getenv("PORT"))
	if error != nil {
		fmt.Println("Couldn't retrieve the PORT environment variable. Defaulting to 8080.")
		port = 8080
	}

	// This used to be `router.Run("localhost:8080")` but this would make the
	// container unresponsive to queries. Changing it to `0.0.0.0:8080` solves
	// this issue.
	// Source: https://stackoverflow.com/questions/72783444/docker-go-server-does-not-respond
	fmt.Printf("Listening at 0.0.0.0:%d", port)

	router.Run(fmt.Sprintf("0.0.0.0:%d", port))
}
