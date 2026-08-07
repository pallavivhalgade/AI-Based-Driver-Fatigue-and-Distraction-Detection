from pathlib import Path


def test_model_file_exists():
    model_path = Path("driver_fatigue_model.h5")
    assert model_path.exists(), f"Model file not found: {model_path}"


def test_model_file_not_empty():
    model_path = Path("driver_fatigue_model.h5")
    assert model_path.stat().st_size > 0