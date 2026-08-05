# Model Files

This directory stores trained AI model files used by the driver fatigue detection system.

## Supported Formats

- `driver_fatigue_model.h5` - TensorFlow/Keras model
- `driver_fatigue_model.tflite` - TensorFlow Lite model for lightweight deployment

## Why models are not committed

Large binary model files are not stored directly in the repository. This keeps cloning and CI workflows lightweight.

Place downloaded or trained models inside:

```text
ai_model/models/
```

## TensorFlow Lite Conversion

Convert a TensorFlow model using:

```bash
python scripts/convert_to_tflite.py
```

## Used By

The inference pipeline loads models from this directory:

```text
ai_model/inference/fatigue_detector.py
```
