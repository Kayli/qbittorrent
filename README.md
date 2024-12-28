# qBittorrent Docker Setup

A convenient Docker setup for qBittorrent with a macOS desktop shortcut for easy container management.

## Features

- Docker Compose configuration for qBittorrent
- macOS desktop shortcut for easy container management
- Automated health checks
- Configured for local development

## Prerequisites

- macOS
- Docker Desktop
- Python 3.x
- Poetry (Python package manager)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/qbittorrent.git
   cd qbittorrent
   ```

2. Install dependencies using Poetry:
   ```bash
   poetry install
   ```

3. Create desktop shortcut:
   ```bash
   ./create_shortcut.sh
   ```

## Usage

### Desktop Shortcut

1. Double-click `QBittorrent.app` on your desktop to:
   - Start the qBittorrent container
   - Open the web UI in your default browser
2. Use ⌘Q to:
   - Stop the container
   - Clean up resources

Note: The first time you run it, macOS might ask for permissions to:
- Control Terminal
- Access network

### Health Checks

```bash
poetry run pytest
```

Verifies:
- Web UI accessibility
- Container status
- Port mappings

## Configuration

- Web UI: http://localhost:8080
- BitTorrent port: 6881
- Download directory: `/tmp`

## Project Structure

- `docker-compose.yml` - Docker configuration
- `test_qbittorrent.py` - Health checks
- `create_shortcut.sh` - Desktop shortcut creator
- `pyproject.toml` - Poetry dependencies and configuration

## Development

1. Make changes to the code
2. Verify everything works:
   ```bash
   poetry run pytest
   ```
3. If you modify the shortcut behavior, recreate it:
   ```bash
   ./create_shortcut.sh
   ```

## License

MIT
