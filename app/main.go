package main

import (
	"database/sql"
	"encoding/json"
	"log"
	"net/http"
	"os"

	_ "github.com/lib/pq"
)

var db *sql.DB

func main() {
	// Pobranie URL bazy z env
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		log.Fatal("DATABASE_URL env var required")
	}

	var err error
	db, err = sql.Open("postgres", dsn)
	if err != nil {
		log.Fatalf("Cannot connect to DB: %v", err)
	}

	// Tworzenie tabeli jeśli nie istnieje
	_, err = db.Exec(`CREATE TABLE IF NOT EXISTS items (
		id SERIAL PRIMARY KEY,
		name TEXT NOT NULL
	)`)
	if err != nil {
		log.Fatalf("Schema init failed: %v", err)
	}

	http.HandleFunc("/", indexHandler)
	http.HandleFunc("/items", itemsHandler)
	http.HandleFunc("/items/clear", clearItemsHandler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	log.Printf("Server listening on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html")
	w.Write([]byte(`<h1>Demo Go App with PostgreSQL</h1>
<p>Endpoints:</p>
<ul>
<li>GET /items</li>
<li>POST /items?name=your_item</li>
</ul>
<form action="/items" method="POST">
<input type="text" name="name" placeholder="Item name">
<button type="submit">Add Item</button>
</form>
<form action="/items/clear" method="POST">
<button type="submit">Clear All Items</button>
</form>
`))
}

func itemsHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		rows, err := db.Query("SELECT id, name FROM items ORDER BY id")
		if err != nil {
			http.Error(w, err.Error(), 500)
			return
		}
		defer rows.Close()

		var items []map[string]interface{}
		for rows.Next() {
			var id int
			var name string
			rows.Scan(&id, &name)
			items = append(items, map[string]interface{}{"id": id, "name": name})
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(items)

	case "POST":
		name := r.URL.Query().Get("name")
		if name == "" {
			name = r.FormValue("name")
		}
		if name == "" {
			http.Error(w, "Missing name parameter", 400)
			return
		}
		var id int
		err := db.QueryRow("INSERT INTO items(name) VALUES($1) RETURNING id", name).Scan(&id)
		if err != nil {
			http.Error(w, err.Error(), 500)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{"id": id, "name": name})

	default:
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
	}
}

func clearItemsHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	_, err := db.Exec("DELETE FROM items")
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "all items cleared"})
}
