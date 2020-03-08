package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"ehrfs/server/src/routes"
	"ehrfs/server/src/utilities/logger"

	"github.com/labstack/echo/v4"
)

func main() {
	e := echo.New()

	routes.Router(e)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		log.Printf("Defaulting to port %s", port)
	}

	log.Printf("Listening on port %s", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), logger.Init(e)))
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	fmt.Fprint(w, "Hello, World!")
}
