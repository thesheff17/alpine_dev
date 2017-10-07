/*
Simple web server created by Dan Sheffner
*/

package main

import (
	"fmt"
	"net/http"
)

func hello_world(w http.ResponseWriter, req *http.Request) {
	w.Write([]byte("Hello World. Welcome to Go Web Server.\nCreated: By Dan Sheffner"))
}

func main() {
	fmt.Println("Starting web server...")
	http.HandleFunc("/", hello_world)
	http.ListenAndServe(":8080", nil)
}
