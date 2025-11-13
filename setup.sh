#!/bin/bash

echo "=========================================="
echo "Interactive Coding - Setup Script"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print status
print_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $1"
    else
        echo -e "${RED}✗${NC} $1"
        exit 1
    fi
}

echo "Checking prerequisites..."
echo ""

# Check Ruby
if command_exists ruby; then
    RUBY_VERSION=$(ruby -v)
    echo -e "${GREEN}✓${NC} Ruby installed: $RUBY_VERSION"
else
    echo -e "${RED}✗${NC} Ruby not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y ruby-full
    print_status "Ruby installation"
fi

# Check Rails
if command_exists rails; then
    RAILS_VERSION=$(rails -v)
    echo -e "${GREEN}✓${NC} Rails installed: $RAILS_VERSION"
else
    echo -e "${YELLOW}!${NC} Rails not found. Installing..."
    gem install rails
    print_status "Rails installation"
fi

# Check Bundler
if command_exists bundle; then
    echo -e "${GREEN}✓${NC} Bundler installed"
else
    echo -e "${YELLOW}!${NC} Bundler not found. Installing..."
    gem install bundler
    print_status "Bundler installation"
fi

# Check Docker
if command_exists docker; then
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}✓${NC} Docker installed: $DOCKER_VERSION"
else
    echo -e "${RED}✗${NC} Docker not found. Installing..."
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    print_status "Docker installation"
    
    echo -e "${YELLOW}!${NC} Adding user to docker group..."
    sudo usermod -aG docker $USER
    echo -e "${YELLOW}!${NC} You may need to log out and back in for docker permissions to take effect."
fi

# Check Node.js
if command_exists node; then
    NODE_VERSION=$(node -v)
    echo -e "${GREEN}✓${NC} Node.js installed: $NODE_VERSION"
else
    echo -e "${RED}✗${NC} Node.js not found. Installing..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    print_status "Node.js installation"
fi

echo ""
echo "=========================================="
echo "Installing Ruby gems..."
echo "=========================================="
bundle install
print_status "Gem installation"

echo ""
echo "=========================================="
echo "Setting up database..."
echo "=========================================="

# Check if database exists
if [ -f "db/development.sqlite3" ]; then
    echo -e "${YELLOW}!${NC} Database already exists."
    read -p "Reset database? This will delete all data! (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rails db:drop
        rails db:setup
        print_status "Database reset"
    else
        echo "Keeping existing database."
    fi
else
    # Fresh setup - use db:setup (faster)
    rails db:setup
    print_status "Database setup"
fi

echo ""
echo "=========================================="
echo "Pre-pulling Docker images (optional)..."
echo "=========================================="
read -p "Download Docker images now? This may take a few minutes. (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Pulling ruby:3.3-alpine..."
    docker pull ruby:3.3-alpine
    
    echo "Pulling python:3.11-alpine..."
    docker pull python:3.11-alpine
    
    echo "Pulling openjdk:17-alpine..."
    docker pull openjdk:17-alpine
    
    echo -e "${GREEN}✓${NC} Docker images downloaded"
else
    echo "Skipped. Images will be downloaded automatically when needed."
fi

echo ""
echo "=========================================="
echo -e "${GREEN}Setup Complete!${NC}"
echo "=========================================="
echo ""
echo "To start the server, run:"
echo "  rails server"
echo ""
echo "Then visit: http://localhost:3000"
echo ""