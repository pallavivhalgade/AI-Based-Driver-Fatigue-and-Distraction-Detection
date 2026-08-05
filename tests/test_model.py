"""Model validation tests."""

from pathlib import Path


MODEL_FILES = [
    Path("driver_fatigue_model.h5"),
    Path("driver_fatigue_model.tflite"),
]


def test_model_files_location():
    """Verify model files exist."""
    assert any(path.exists() for path in MODEL_FILES)


def test_model_file_extension():
    """Verify supported TensorFlow formats."""
    for model in MODEL_FILES:
        assert model.suffix in {".h5", ".tflite"}


def test_model_path_is_relative():
    """Prevent absolute machine paths."""
    for model in MODEL_FILES:
        assert not model.is_absolute()
