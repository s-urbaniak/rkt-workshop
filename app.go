package main

import (
	"fmt"
	"log"
	"net/http"
	"net/http/httputil"
)

func handler(w http.ResponseWriter, r *http.Request) {
	b, _ := httputil.DumpRequest(r, false)
	log.Println(string(b))
	fmt.Fprintln(w, "Hello World")
}

func main() {
	http.HandleFunc("/", handler)
	http.ListenAndServe(":8080", nil)
}
