import cv2
import mediapipe as mp
import numpy as np
import time
import pyttsx3

engine = pyttsx3.init()

mp_face_mesh = mp.solutions.face_mesh
face_mesh = mp_face_mesh.FaceMesh(refine_landmarks=True)

cap = cv2.VideoCapture(0)

last_alert_time = 0
alert_cooldown = 4

while True:
    ret, frame = cap.read()
    if not ret:
        break

    h, w, _ = frame.shape
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

    results = face_mesh.process(rgb_frame)

    if results.multi_face_landmarks:
        for face_landmarks in results.multi_face_landmarks:

            nose = face_landmarks.landmark[1]
            left_eye = face_landmarks.landmark[33]
            right_eye = face_landmarks.landmark[263]

            nose_x = int(nose.x * w)
            nose_y = int(nose.y * h)

            left_x = int(left_eye.x * w)
            right_x = int(right_eye.x * w)

            center_face = (left_x + right_x) // 2

            direction = "Forward"

            if nose_x < center_face - 30:
                direction = "Looking Left"
            elif nose_x > center_face + 30:
                direction = "Looking Right"
            elif nose_y > h * 0.6:
                direction = "Looking Down"
            elif nose_y < h * 0.3:
                direction = "Looking Up"

            cv2.putText(frame, direction, (30, 50),
                        cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)

            current_time = time.time()

            if direction != "Forward":
                if current_time - last_alert_time > alert_cooldown:
                    engine.say("Driver distracted")
                    engine.runAndWait()
                    last_alert_time = current_time

    cv2.imshow("Head Pose Detection", frame)

    if cv2.waitKey(1) == 27:
        break

cap.release()
cv2.destroyAllWindows()