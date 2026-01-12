#!/bin/bash

################################################################################
# Database Visualization Script
# Helps visualize and interact with the Personal Trainer App SQLite database
################################################################################

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Possible database locations (platform-specific)
DB_PATHS=(
  "$HOME/Documents/app_database.sqlite"                          # Linux Desktop
  "$HOME/.local/share/personal_trainer_app/app_database.sqlite"  # Linux app cache
  "$HOME/.local/share/app_database/app_database.sqlite"          # Alternative
)

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB_PATH=""

################################################################################
# Helper Functions
################################################################################

print_header() {
  echo -e "\n${BLUE}===============================================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}===============================================================================${NC}\n"
}

print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
  echo -e "${RED}✗ $1${NC}"
}

print_info() {
  echo -e "${YELLOW}ℹ $1${NC}"
}

find_database() {
  # Check each possible database location
  for path in "${DB_PATHS[@]}"; do
    if [ -f "$path" ]; then
      DB_PATH="$path"
      print_success "Database found at: $DB_PATH"
      return 0
    fi
  done

  print_error "Database not found in any of these locations:"
  for path in "${DB_PATHS[@]}"; do
    echo "  - $path"
  done

  print_info "Possible solutions:"
  echo "  1) Run the Flutter app first to create the database"
  echo "  2) Provide custom path: $0 --db-path /custom/path/app_database.sqlite"
  echo "  3) Check if app is running on a connected device/emulator"
  return 1
}

show_database_info() {
  print_header "Database Information"

  local file_size=$(du -h "$DB_PATH" | cut -f1)
  echo -e "Size: ${GREEN}$file_size${NC}"
  echo -e "Path: ${GREEN}$DB_PATH${NC}"

  # Show table count
  local table_count=$(sqlite3 "$DB_PATH" ".tables" | wc -w)
  echo -e "Tables: ${GREEN}$table_count${NC}"

  # Show row counts per table
  print_info "Row counts per table:"
  sqlite3 "$DB_PATH" << 'EOF'
.mode column
.headers on
SELECT
  name as 'Table Name',
  (SELECT COUNT(*) FROM (SELECT 1 FROM main.sqlite_master m2 WHERE m2.type='table' AND m2.name=m.name LIMIT 1)) as 'Exists'
FROM sqlite_master m
WHERE type='table' AND name NOT LIKE 'sqlite_%'
ORDER BY name;
EOF

  echo ""
}

show_schema() {
  print_header "Database Schema"
  sqlite3 "$DB_PATH" ".schema"
  echo ""
}

show_tables() {
  print_header "Available Tables"
  sqlite3 "$DB_PATH" ".tables"
  echo ""
}

show_trainers_table() {
  print_header "Trainers Table Data"
  sqlite3 "$DB_PATH" << 'EOF'
.mode column
.headers on
SELECT * FROM trainers_table;
EOF
  echo ""
}

show_clients_table() {
  print_header "Clients Table Data"
  sqlite3 "$DB_PATH" << 'EOF'
.mode column
.headers on
SELECT * FROM clients_table;
EOF
  echo ""
}

show_unsynced_records() {
  print_header "Unsynced Records (Pending Sync)"
  sqlite3 "$DB_PATH" << 'EOF'
.mode column
.headers on
SELECT name, 'trainers_table' as source FROM trainers_table WHERE is_synced = 0
UNION ALL
SELECT name, 'clients_table' as source FROM clients_table WHERE is_synced = 0
UNION ALL
SELECT name, 'workouts_table' as source FROM workouts_table WHERE is_synced = 0
ORDER BY source;
EOF
  echo ""
}

open_browser_gui() {
  print_info "Checking for sqlitebrowser..."

  if ! command -v sqlitebrowser &> /dev/null; then
    print_error "sqlitebrowser not installed"
    echo -e "Install with: ${YELLOW}sudo apt-get install sqlitebrowser${NC}"
    return 1
  fi

  print_info "Opening database in sqlitebrowser GUI..."
  sqlitebrowser "$DB_PATH" &
}

open_cli() {
  print_header "Opening SQLite CLI"
  echo -e "Useful commands:"
  echo -e "  ${GREEN}.tables${NC}              - List all tables"
  echo -e "  ${GREEN}.schema${NC}              - Show table definitions"
  echo -e "  ${GREEN}.schema <table>${NC}      - Show specific table schema"
  echo -e "  ${GREEN}SELECT * FROM <table>;${NC} - Query data"
  echo -e "  ${GREEN}.mode column${NC}         - Pretty-print results"
  echo -e "  ${GREEN}.headers on${NC}          - Show column headers"
  echo -e "  ${GREEN}.exit${NC}                - Exit CLI"
  echo ""

  sqlite3 "$DB_PATH"
}

run_custom_query() {
  local query="$1"
  print_header "Query Result"
  sqlite3 "$DB_PATH" << EOF
.mode column
.headers on
$query
EOF
  echo ""
}

clear_database() {
  print_error "WARNING: This will delete all database data!"
  read -p "Are you sure? (yes/no): " confirm

  if [ "$confirm" != "yes" ]; then
    print_info "Cancelled"
    return
  fi

  rm -f "$DB_PATH"
  print_success "Database cleared. Run app to recreate."
}

show_menu() {
  echo -e "\n${BLUE}Database Visualization Options:${NC}\n"
  echo "  1) Show database info (size, table counts)"
  echo "  2) Show database schema"
  echo "  3) Show all tables"
  echo "  4) Show trainers table data"
  echo "  5) Show clients table data"
  echo "  6) Show unsynced records (offline-first sync queue)"
  echo "  7) Open in sqlitebrowser GUI"
  echo "  8) Open SQLite CLI interactive mode"
  echo "  9) Run custom SQL query"
  echo "  10) Clear database"
  echo "  0) Exit"
  echo ""
}

################################################################################
# Main Script
################################################################################

main() {
  print_header "Personal Trainer App - Database Visualizer"

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --db-path)
        DB_PATH="$2"
        if [ ! -f "$DB_PATH" ]; then
          print_error "Database file not found at: $DB_PATH"
          exit 1
        fi
        print_success "Using custom database: $DB_PATH"
        shift 2
        ;;
      *)
        break
        ;;
    esac
  done

  # Find database if not provided
  if [ -z "$DB_PATH" ]; then
    if ! find_database; then
      exit 1
    fi
  fi

  # If argument provided, run that command directly
  if [ $# -gt 0 ]; then
    case "$1" in
      info)
        show_database_info
        ;;
      schema)
        show_schema
        ;;
      tables)
        show_tables
        ;;
      trainers)
        show_trainers_table
        ;;
      clients)
        show_clients_table
        ;;
      unsynced)
        show_unsynced_records
        ;;
      gui)
        open_browser_gui
        ;;
      cli)
        open_cli
        ;;
      query)
        if [ -z "$2" ]; then
          print_error "Usage: $0 query '<SQL query>'"
          exit 1
        fi
        run_custom_query "$2"
        ;;
      clear)
        clear_database
        ;;
      *)
        print_error "Unknown command: $1"
        echo "Usage: $0 {info|schema|tables|trainers|clients|unsynced|gui|cli|query '<sql>'|clear}"
        exit 1
        ;;
    esac
    exit 0
  fi

  # Interactive menu
  while true; do
    show_menu
    read -p "Select an option (0-10): " choice

    case $choice in
      1)
        show_database_info
        ;;
      2)
        show_schema
        ;;
      3)
        show_tables
        ;;
      4)
        show_trainers_table
        ;;
      5)
        show_clients_table
        ;;
      6)
        show_unsynced_records
        ;;
      7)
        open_browser_gui
        ;;
      8)
        open_cli
        ;;
      9)
        print_info "Enter SQL query (e.g., SELECT * FROM clients_table;):"
        read -p "> " query
        run_custom_query "$query"
        ;;
      10)
        clear_database
        ;;
      0)
        print_success "Exiting"
        exit 0
        ;;
      *)
        print_error "Invalid option. Please select 0-10."
        ;;
    esac

    read -p "Press Enter to continue..."
  done
}

# Run main function
main "$@"
