package main

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
)

// Sourced from https://gin-gonic.com/docs/testing/.
func TestHealth(t *testing.T) {
	router := setupRouter()

	// Launch an HTTP GET / request.
	responseRecorder := httptest.NewRecorder()
	req, _ := http.NewRequest("GET", "/", nil)
	router.ServeHTTP(responseRecorder, req)

	assert.Equal(t, 200, responseRecorder.Code)
	assert.Equal(t, "Transperler API is alive.", responseRecorder.Body.String())
}
