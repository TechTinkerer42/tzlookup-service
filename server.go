package main


import (
//	"encoding/json"
//	"fmt"
//	"os"
	"net/http"

//	"github.com/codegangsta/negroni"
//	"github.com/gorilla/mux"
//	"github.com/thoas/stats"
//	"github.com/julienschmidt/httprouter"

//	"github.com/gin-gonic/gin"
	"fmt"
	"github.com/julienschmidt/httprouter"
//	"github.com/gin-gonic/gin"
	"encoding/json"
	"strconv"
)

//func YourHandler(response http.ResponseWriter, request *http.Request) {
//	response.Header().Set("Content-Type", "application/json")
//	response.Write([]byte("Gorilla!\n"))
//	request.
//}

func Index(w http.ResponseWriter, r *http.Request, _ httprouter.Params) {
	fmt.Fprint(w, "Welcome!\n")
	fmt.Fprint(w, r.URL.Query().Get("test"))
	fmt.Fprint(w, "Done.\n")
}

func writeErrorJson(response http.ResponseWriter, errorMessage string, code int) {
	response.Header().Set("Content-Type", "application/json")
	response.WriteHeader(code)
	bytes, _ := json.Marshal(map[string]string{"error_message": errorMessage})
	fmt.Fprint(response, string(bytes))
}


var apiKeyRepository = map[string]bool{
	"THE_API_KEY": true,
	"EVIL_API_KEY": false,
}

func checkApiKey(apiKey string) bool {
	if enabled, present := apiKeyRepository[apiKey]; present && enabled {
		return true
	}
	return false
}

// GET http://domain/time_zone?lat=48.8567&lng=2.348692&api_key=THE_API_KEY
func TimeZone(response http.ResponseWriter, request *http.Request, _ httprouter.Params) {
	lat, lat_err := strconv.ParseFloat(request.URL.Query().Get("lat"), 64)
	lng, lng_err := strconv.ParseFloat(request.URL.Query().Get("lng"), 64)
	apiKey := request.URL.Query().Get("api_key")

	// if parameters are bad or missing: write an error and abort
	if lat_err != nil || lng_err != nil || len(apiKey) == 0 {
		writeErrorJson(response, "Missing, empty or invalid query parameters, need: lat (float), lng (float), api_key (string)", 400)
		return
	}

	if !checkApiKey(apiKey) {
		writeErrorJson(response, "Invalid or blocked api_key!", 404)
		return
	}

	timezoneId, _ := ResolveTimezone(lat, lng)
	fmt.Fprintf(response, "lat: %f + lng: %f => %s\n", lat, lng, timezoneId)
}

func main() {
	router := httprouter.New()

	router.GET("/", Index)
	router.GET("/time_zone", TimeZone)

	http.ListenAndServe(":8000", router)
}
