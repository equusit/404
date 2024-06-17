package main

import (
	"net/http"
)

// notFoundHandler is a handler function that always returns a 404 status code.
func notFoundHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusNotFound)
	w.Write([]byte("404 - Not Found"))
}

func main() {
	// Use http.HandleFunc to direct all routes to the notFoundHandler
	http.HandleFunc("/", notFoundHandler)

	// Start the server on port 8080
	if err := http.ListenAndServe(":8080", nil); err != nil {
		panic(err)
	}
}
