"""Basic model validation tests."""

from pathlib import Path


def test_model_file_location():
    model_path = Path("ai_model/models/driver_fatigue_model.h5")
    assert model_path.parent.name == "models"
