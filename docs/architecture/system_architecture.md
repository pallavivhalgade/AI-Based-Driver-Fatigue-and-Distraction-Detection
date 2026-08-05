# System Architecture

## Overview

The driver fatigue detection system follows a modular AI pipeline.

```text
Camera Input
      |
      v
OpenCV Frame Capture
      |
      v
MediaPipe Face Processing
      |
      +----------------+
      |                |
      v                v
Eye Detection     Yawn Detection
      |                |
      +----------------+
              |
              v
     Fatigue Decision Engine
              |
       +------+------+ 
       |             |
       v             v
 Voice Alert   SMS/Telegram Alert
              |
              v
       Mobile Dashboard
```

## Components

### AI Layer
- Face detection
- Eye state analysis
- Yawn detection
- Fatigue classification

### Alert Layer
- Voice warnings
- SMS notifications
- Telegram notifications

### Application Layer
- Backend API
- Flutter mobile application
