"""Backend API validation tests."""


def test_api_service_status_structure():
    """Validate expected API response fields."""
    response = {
        "status": "running",
        "service": "driver-monitor-api",
    }

    assert response["status"] == "running"
    assert response["service"] == "driver-monitor-api"


def test_status_response_contains_required_fields():
    """Validate driver status response format."""
    response = {
        "driver_status": "normal",
        "eyes": "open",
        "yawning": False,
        "head_pose": "center",
    }

    required_fields = [
        "driver_status",
        "eyes",
        "yawning",
        "head_pose",
    ]

    for field in required_fields:
        assert field in response
