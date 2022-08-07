package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"transperler-service/transpiler"

	"github.com/stretchr/testify/assert"
)

// Sourced from https://gin-gonic.com/docs/testing/.
func TestHealth(t *testing.T) {
	router := setupRouter()

	// Launch an HTTP GET / request.
	responseRecorder := httptest.NewRecorder()
	req, _ := http.NewRequest(http.MethodGet, "/", nil)
	router.ServeHTTP(responseRecorder, req)

	assert.Equal(t, http.StatusOK, responseRecorder.Code)
	assert.Equal(t, "Transperler API is alive.", responseRecorder.Body.String())
}

/* ------------------------- Transpiler Route Tests ------------------------- */
func TestTranspilerPrimesSh(t *testing.T) {
	router := setupRouter()

	// var shellSource transpiler.ShellSource = 
	shellSource := transpiler.ShellSource {
		ShSourceCode: `#!/bin/sh

is_prime() {
    local n i
    n=$1
    i=2
    while test $i -lt $n
    do
        test $((n % i)) -eq 0 && return 1
        i=$((i + 1))
    done
    return 0
}

i=0
while test $i -lt 1000
do
    is_prime $i && echo $i
    i=$((i + 1))
done
`,
	}
	expectedPerlOutput := transpiler.PerlOutput {
		PlOutput: `#!/usr/bin/perl

sub is_prime {
    my ($n, $i);
    $n = $_[0];
    $i = 2;
    while ($i < $n) {
        $n % $i == 0 and return 1;
        $i = $i + 1;
    }
    return 0;
}

$i = 0;
while ($i < 1000) {
    is_prime ($i, and, print, $i\n);
    $i = $i + 1;
}
`,
		Message: "Transpiled successfully.",
	}

	var b bytes.Buffer
	err := json.NewEncoder(&b).Encode(shellSource)
	if err != nil {
		t.Fatal(err)
	}

	// Launch an HTTP POST /transpiler request.
	responseRecorder := httptest.NewRecorder()
	req, _ := http.NewRequest(http.MethodPost, "/transpiler", &b)
	req.Header.Set("Content-Type", "application/json")
	router.ServeHTTP(responseRecorder, req)

	var actualPerlOutput transpiler.PerlOutput
	// fmt.Println(actualPerlOutput)

	json.NewDecoder(responseRecorder.Body).Decode(&actualPerlOutput)
	assert.Equal(t, http.StatusOK, responseRecorder.Code)
	assert.EqualValues(t, actualPerlOutput, expectedPerlOutput)
}
