# System Architecture

## AI Driver Fatigue and Distraction Detection System

```text
Camera Input
     |
     v
Face Detection (OpenCV + MediaPipe)
     |
     +----------------+
     |                |
     v                v
Eye State Model     Yawn Detection
     |                |
     +----------------+
              |
              v
       Fatigue Decision Engine
              |
     +--------+---------+
     |                  |
     v                  v
 Voice Alert        SMS Alert

Flutter Mobile Application
          |
          v
 Backend API
          |
          v
 TensorFlow Lite Model
```

## Components

- Computer Vision pipeline for face and landmark detection.
- TensorFlow/TensorFlow Lite model for fatigue classification.
- Backend API for communication and services.
- Flutter mobile application for user interaction.
- Alert system for real-time warnings.
