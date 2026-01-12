#!/bin/bash

################################################################################
# Database Management Script
# Manage (delete, clear, backup/restore) Personal Trainer App SQLite database
# WARNING: This script modifies data. Always backup before destructive operations!
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
BACKUP_DIR="$HOME/.local/share/personal_trainer_app/backups"

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

print_warning() {
  echo -e "${RED}⚠ $1${NC}"
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

create_backup() {
  mkdir -p "$BACKUP_DIR"

  local timestamp=$(date +%Y%m%d_%H%M%S)
  local backup_path="$BACKUP_DIR/app_database_${timestamp}.sqlite"

  cp "$DB_PATH" "$backup_path"
  print_success "Backup created: $backup_path"
  echo "$backup_path"
}

show_backups() {
  print_header "Available Backups"

  if [ ! -d "$BACKUP_DIR" ]; then
    print_info "No backups directory found"
    return
  fi

  if [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
    print_info "No backups available"
    return
  fi

  ls -lh "$BACKUP_DIR"/app_database_*.sqlite | awk '{print $9, "(" $5 ")"}'
  echo ""
}

restore_backup() {
  show_backups

  if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
    print_error "No backups available"
    return 1
  fi

  read -p "Enter backup filename to restore (or press Enter to cancel): " backup_file

  if [ -z "$backup_file" ]; then
    print_info "Restore cancelled"
    return 0
  fi

  local backup_path="$BACKUP_DIR/$backup_file"

  if [ ! -f "$backup_path" ]; then
    print_error "Backup not found: $backup_path"
    return 1
  fi

  print_warning "WARNING: This will overwrite your current database!"
  read -p "Are you sure? (yes/no): " confirm

  if [ "$confirm" != "yes" ]; then
    print_info "Restore cancelled"
    return 0
  fi

  cp "$backup_path" "$DB_PATH"
  print_success "Database restored from: $backup_path"
}

show_table_stats() {
  print_header "Table Statistics"

  sqlite3 "$DB_PATH" << 'EOF'
.mode column
.headers on
SELECT
  name as 'Table Name',
  (SELECT COUNT(*) FROM sqlite_master m2
   WHERE m2.type='table' AND m2.name=m.name) as 'Exists',
  (SELECT COUNT(*) FROM (SELECT 1 UNION ALL SELECT * FROM (
    SELECT COUNT(*) FROM (SELECT 1 FROM main.sqlite_master m3
    WHERE m3.type='table' AND m3.name=m.name LIMIT 1)
  ))) as 'Status'
FROM sqlite_master m
WHERE type='table' AND name NOT LIKE 'sqlite_%'
ORDER BY name;

-- Get row counts dynamically
SELECT 'TABLE RECORD COUNTS:' as '';
EOF

  # Count rows in each table
  local tables=$(sqlite3 "$DB_PATH" ".tables" | tr ' ' '\n' | grep -v "sqlite_" | sort)

  for table in $tables; do
    local count=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM $table;")
    printf "  %-30s %5d rows\n" "$table" "$count"
  done
  echo ""
}

delete_record() {
  print_header "Delete Specific Record"

  local table_name
  read -p "Enter table name (or press Enter to cancel): " table_name

  if [ -z "$table_name" ]; then
    print_info "Cancelled"
    return 0
  fi

  # Check if table exists
  local table_exists=$(sqlite3 "$DB_PATH" \
    "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='$table_name';")

  if [ "$table_exists" -eq 0 ]; then
    print_error "Table '$table_name' not found"
    return 1
  fi

  # Show table schema
  print_info "Table schema:"
  sqlite3 "$DB_PATH" ".schema $table_name"
  echo ""

  # Get primary key
  local pk=$(sqlite3 "$DB_PATH" \
    "PRAGMA table_info($table_name);" | grep -i "1$" | cut -d'|' -f2 | head -1)

  if [ -z "$pk" ]; then
    print_error "Could not determine primary key for table '$table_name'"
    return 1
  fi

  read -p "Enter record ID to delete (or press Enter to cancel): " record_id

  if [ -z "$record_id" ]; then
    print_info "Cancelled"
    return 0
  fi

  # Preview record
  print_info "Record to delete:"
  sqlite3 "$DB_PATH" << EOF
.mode column
.headers on
SELECT * FROM $table_name WHERE $pk = $record_id;
EOF

  read -p "Delete this record? (yes/no): " confirm

  if [ "$confirm" != "yes" ]; then
    print_info "Cancelled"
    return 0
  fi

  # Create backup before deletion
  local backup=$(create_backup)

  # Delete record
  sqlite3 "$DB_PATH" "DELETE FROM $table_name WHERE $pk = $record_id;"

  print_success "Record deleted from '$table_name' where $pk = $record_id"
  print_info "Backup created at: $backup"
}

clear_table() {
  print_header "Clear Table Data"

  local table_name
  read -p "Enter table name to clear (or press Enter to cancel): " table_name

  if [ -z "$table_name" ]; then
    print_info "Cancelled"
    return 0
  fi

  # Check if table exists
  local table_exists=$(sqlite3 "$DB_PATH" \
    "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='$table_name';")

  if [ "$table_exists" -eq 0 ]; then
    print_error "Table '$table_name' not found"
    return 1
  fi

  # Show row count
  local row_count=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM $table_name;")
  print_warning "WARNING: This will delete ALL $row_count records from '$table_name'!"

  read -p "Are you sure? (yes/no): " confirm

  if [ "$confirm" != "yes" ]; then
    print_info "Cancelled"
    return 0
  fi

  # Create backup before clearing
  local backup=$(create_backup)

  # Clear table
  sqlite3 "$DB_PATH" "DELETE FROM $table_name;"

  print_success "Cleared all records from '$table_name'"
  print_info "Backup created at: $backup"
}

show_menu() {
  echo -e "\n${BLUE}Database Management Options:${NC}\n"
  echo "  1) Show table statistics (row counts)"
  echo "  2) Create backup"
  echo "  3) List backups"
  echo "  4) Restore from backup"
  echo "  5) Delete specific record"
  echo "  6) Clear entire table"
  echo "  0) Exit"
  echo ""
}

################################################################################
# Main Script
################################################################################

main() {
  print_header "Personal Trainer App - Database Manager"
  print_warning "⚠️  WARNING: This script modifies data. Always backup before destructive operations!"

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
      stats)
        show_table_stats
        ;;
      backup)
        create_backup
        ;;
      list-backups)
        show_backups
        ;;
      restore)
        restore_backup
        ;;
      delete-record)
        delete_record
        ;;
      clear-table)
        clear_table
        ;;
      *)
        print_error "Unknown command: $1"
        echo "Usage: $0 {stats|backup|list-backups|restore|delete-record|clear-table}"
        exit 1
        ;;
    esac
    exit 0
  fi

  # Interactive menu
  while true; do
    show_menu
    read -p "Select an option (0-6): " choice

    case $choice in
      1)
        show_table_stats
        ;;
      2)
        create_backup
        ;;
      3)
        show_backups
        ;;
      4)
        restore_backup
        ;;
      5)
        delete_record
        ;;
      6)
        clear_table
        ;;
      0)
        print_success "Exiting"
        exit 0
        ;;
      *)
        print_error "Invalid option. Please select 0-6."
        ;;
    esac

    read -p "Press Enter to continue..."
  done
}

# Run main function
main "$@"
