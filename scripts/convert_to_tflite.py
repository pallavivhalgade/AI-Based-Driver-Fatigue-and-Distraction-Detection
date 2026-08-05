import tensorflow as tf
from pathlib import Path

MODEL_PATH = Path("ai_model/models/driver_fatigue_model.h5")
TFLITE_PATH = Path("ai_model/models/driver_fatigue_model.tflite")


print("Loading H5 model...")
model = tf.keras.models.load_model(MODEL_PATH)

print("Converting model to TensorFlow Lite...")
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]

converted_model = converter.convert()

TFLITE_PATH.write_bytes(converted_model)

print(f"Saved TensorFlow Lite model: {TFLITE_PATH}")
