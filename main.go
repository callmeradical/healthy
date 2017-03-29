package main

import (
	"encoding/json"
	"log"
	"net/http"
)

type Response struct {
	Version string `json:"version"`
	Message string `json:"message"`
}

func healthz(w http.ResponseWriter, r *http.Request) {
	res := Response{
		Version: "v1.0",
		Message: "We are Healthy!",
	}

	str, err := json.MarshalIndent(&res, "", "\t")
	if err != nil {
		log.Println(err.Error())
	}

	w.Write(str)
}

func main() {
	http.HandleFunc("/health", healthz)
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
