package main

import (
	"encoding/json"
	"log"
	"net/http"
	"sync"
)

var (
	items []string
	mu    sync.Mutex
)

func main() {
	http.HandleFunc("/", indexHandler)
	http.HandleFunc("/items", itemsHandler)

	port := "3000"
	log.Printf("Server listening on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html")
	w.Write([]byte(`<h1>Demo Go App (JSON API)</h1>
<p>Endpoints:</p>
<ul>
<li>GET /items</li>
<li>POST /items?name=your_item</li>
</ul>
<form action="/items" method="POST">
<input type="text" name="name" placeholder="Item name">
<button type="submit">Add Item</button>
</form>
`))
}

func itemsHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		mu.Lock()
		defer mu.Unlock()
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(items)

	case "POST":
		name := r.URL.Query().Get("name")
		if name == "" {
			name = r.FormValue("name")
		}
		if name == "" {
			http.Error(w, "Missing name parameter", http.StatusBadRequest)
			return
		}
		mu.Lock()
		items = append(items, name)
		mu.Unlock()
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(map[string]string{"added": name})

	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}
