"""Model validation tests."""

from pathlib import Path


MODEL_PATH = Path("ai_model/models/driver_fatigue_model.h5")


def test_model_file_location():
    """Verify expected model directory structure."""
    assert MODEL_PATH.parent.name == "models"


def test_model_file_extension():
    """Verify supported TensorFlow model format."""
    assert MODEL_PATH.suffix in {".h5", ".tflite"}


def test_model_path_is_relative():
    """Prevent hardcoded absolute machine paths."""
    assert not MODEL_PATH.is_absolute()
