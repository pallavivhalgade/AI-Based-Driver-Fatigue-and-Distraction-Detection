from pathlib import Path


def test_model_file_exists():
    """
    Verify that the trained model file exists.
    """
    model_path = Path("driver_fatigue_model.h5")
    assert model_path.exists(), (
        f"Model file not found: {model_path}. "
        "Train the model or place the model file in the project root."
    )


def test_model_file_not_empty():
    """
    Verify that the model file is not empty.
    """
    model_path = Path("driver_fatigue_model.h5")
    assert model_path.stat().st_size > 0, "Model file is empty."
