# AI-Based Driver Fatigue and Distraction Detection System

## Overview

A real-time AI-powered driver monitoring system designed to detect fatigue and distraction while driving. The system uses computer vision and deep learning techniques to analyze driver behavior and provide early warnings to reduce accident risks.

The project combines a Python AI pipeline, backend API services, and a Flutter mobile application.

## Features

- Real-time driver fatigue detection
- Eye closure detection
- Yawn detection
- Head pose monitoring
- Computer vision based face analysis
- Voice warning alerts
- SMS alert integration support
- TensorFlow Lite mobile inference support
- Flutter mobile application support

## System Architecture

```text
Camera Input
      |
      v
OpenCV + MediaPipe Processing
      |
      v
Feature Extraction
      |
      +----------------+
      |                |
      v                v
Eye Detection     Yawn Detection
      |
      v
Fatigue Decision Engine
      |
      +-------------+
      |             |
      v             v
Voice Alert     SMS Alert
```

## Tech Stack

### Artificial Intelligence

- Python
- OpenCV
- MediaPipe
- TensorFlow
- TensorFlow Lite
- NumPy
- Scikit-learn

### Backend

- Flask
- REST API

### Mobile Application

- Flutter
- Android

## Project Structure

```text
ai_model/
 ├── training/        # Model training code
 ├── preprocessing/   # Image preprocessing
 ├── inference/       # Model prediction pipeline
 ├── alerts/          # Warning management
 └── models/          # Trained model files

backend/
 ├── api/             # API endpoints
 ├── services/        # Backend services
 └── config/          # Configuration

mobile_app/           # Flutter application

dataset/              # Dataset instructions

tests/                # Automated tests

scripts/              # Utility scripts
```

## Installation

### Clone Repository

```bash
git clone <repository-url>
cd AI-Based-Driver-Fatigue-and-Distraction-Detection
```

### Python Environment

```bash
python -m venv venv

# Windows
venv\\Scripts\\activate

pip install -r requirements.txt
```

## Model Setup

Place trained models inside:

```text
ai_model/models/
```

Supported formats:

- TensorFlow `.h5`
- TensorFlow Lite `.tflite`

## Running Backend

```bash
python backend/api/api_server.py
```

API starts on:

```text
http://localhost:5000
```

## Model Workflow

```text
Dataset
  |
Preprocessing
  |
Training
  |
Evaluation
  |
TensorFlow Lite Conversion
  |
Mobile Deployment
```

## Dataset

The model uses driver facial images containing fatigue-related classes such as:

- Open eyes
- Closed eyes
- Yawning
- Normal driver state

Large datasets are intentionally not stored in this repository.

## Screenshots and Demo

Add application screenshots and demo videos here:

```text
docs/screenshots/
```

## Future Improvements

- Improved head pose estimation
- Driver emotion analysis
- Edge deployment optimization
- Better model accuracy with larger datasets
- Cloud-based fleet monitoring dashboard
- Real-time analytics platform

## Security

- Never commit API keys or credentials.
- Store secrets using environment variables.
- Use `.env.example` as configuration reference.

## License

This project is licensed under the MIT License.
