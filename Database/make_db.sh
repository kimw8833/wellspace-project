#!/bin/bash

# Database config
DB_USER="wellspace"
DB_PASS="wellspace2025"
DB_NAME="wellspacedb"

echo "Running database setup..."

# Run SQL
sudo mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" < create_tables.sql

if [ $? -eq 0 ]; then
    echo "Database tables created successfully!"
else
    echo "Failed to create tables."
fi
