"""Model inference pipeline for driver fatigue detection."""

from pathlib import Path
import tensorflow as tf


class FatigueDetector:
    """Load and run fatigue detection model predictions."""

    def __init__(self, model_path):
        self.model_path = Path(model_path)
        self.model = self._load_model()

    def _load_model(self):
        if not self.model_path.exists():
            raise FileNotFoundError(f"Model not found: {self.model_path}")

        return tf.keras.models.load_model(self.model_path)

    def predict(self, processed_frame):
        """Generate prediction from processed input."""
        return self.model.predict(processed_frame)
