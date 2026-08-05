"""Image preprocessing utilities for fatigue detection models."""

import cv2
import numpy as np


class ImageProcessor:
    """Prepare camera frames before model inference."""

    def __init__(self, image_size=(224, 224)):
        self.image_size = image_size

    def preprocess(self, frame):
        """Resize and normalize an image frame."""
        resized = cv2.resize(frame, self.image_size)
        normalized = resized.astype(np.float32) / 255.0
        return np.expand_dims(normalized, axis=0)
