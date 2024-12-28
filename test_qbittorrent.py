import pytest
import requests
import subprocess
import time
import os
from pathlib import Path
from datetime import datetime, timedelta

def wait_for_service(url: str, timeout_seconds: int = 30, interval_seconds: int = 0.5) -> bool:
    """Wait for service to be ready by polling the URL."""
    start_time = datetime.now()
    timeout = timedelta(seconds=timeout_seconds)
    
    while datetime.now() - start_time < timeout:
        try:
            response = requests.get(url)
            if response.status_code == 200:
                return True
        except requests.RequestException:
            pass
        time.sleep(interval_seconds)
    
    return False

@pytest.fixture(scope="session", autouse=True)
def docker_environment():
    """Start and stop the docker environment"""
    # Build and start the containers
    subprocess.run(["docker", "compose", "up", "-d"], check=True)
    
    # Wait for service to be ready
    assert wait_for_service("http://localhost:8080"), "Service failed to become ready within timeout"
    
    yield
    
    # Cleanup
    subprocess.run(["docker", "compose", "down"], check=True)

def test_qbittorrent_web_ui_no_login():
    """Test if qBittorrent web UI is accessible without login screen"""
    try:
        response = requests.get("http://localhost:8080")
        assert response.status_code == 200
        
        # Check that we're not on the login page
        assert 'loginform' not in response.text.lower(), "Login form found - UI requires authentication"
        
        # Check for elements that should be present in the main UI
        assert 'qbittorrent' in response.text.lower(), "qBittorrent UI not found"
        assert 'add torrent' in response.text.lower(), "Main UI elements not found - might be on login screen"
    except requests.exceptions.ConnectionError:
        pytest.fail("Could not connect to qBittorrent web UI")

def test_download_directory():
    """Test if the download directory is properly mounted"""
    download_path = Path("/tmp")
    assert download_path.exists(), "Download directory does not exist"
    assert download_path.is_dir(), "Download path is not a directory"
    assert os.access(download_path, os.W_OK), "Download directory is not writable"

def test_container_running():
    """Test if the container is running"""
    container_id = subprocess.run(
        ["docker", "compose", "ps", "-q", "qbittorrent"],
        capture_output=True,
        text=True
    ).stdout.strip()
    assert container_id, "qBittorrent container is not running"
    
    # Check container status
    status = subprocess.run(
        ["docker", "inspect", "-f", "{{.State.Status}}", container_id],
        capture_output=True,
        text=True
    )
    assert "running" in status.stdout.lower(), "qBittorrent container is not in running state"

def test_ports_listening():
    """Test if required ports are listening"""
    container_id = subprocess.run(
        ["docker", "compose", "ps", "-q", "qbittorrent"],
        capture_output=True,
        text=True
    ).stdout.strip()
    
    # Check port mappings
    port_check = subprocess.run(
        ["docker", "port", container_id],
        capture_output=True,
        text=True
    )
    port_output = port_check.stdout.lower()
    
    assert "8080" in port_output, "Web UI port 8080 is not mapped"
    assert "6881" in port_output, "BitTorrent port 6881 is not mapped"
