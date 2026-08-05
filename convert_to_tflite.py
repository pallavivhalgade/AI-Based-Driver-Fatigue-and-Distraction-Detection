import tensorflow as tf

MODEL_PATH = "driver_fatigue_model.h5"
TFLITE_PATH = "driver_fatigue_model.tflite"

print("Loading H5 model...")
model = tf.keras.models.load_model(MODEL_PATH)

print("Converting to TFLite...")
converter = tf.lite.TFLiteConverter.from_keras_model(model)

# Basic safe conversion
converter.optimizations = [tf.lite.Optimize.DEFAULT]

tflite_model = converter.convert()

with open(TFLITE_PATH, "wb") as f:
    f.write(tflite_model)

print("Conversion completed.")
print("Saved as:", TFLITE_PATH)