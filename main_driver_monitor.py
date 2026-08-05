from telegram_alert import send_telegram_alert
import cv2
import mediapipe as mp
import numpy as np
import tensorflow as tf
import time
import pyttsx3
import json

model = tf.keras.models.load_model("driver_fatigue_model.h5")

engine = pyttsx3.init()

mp_face_detection = mp.solutions.face_detection
mp_face_mesh = mp.solutions.face_mesh

face_detection = mp_face_detection.FaceDetection(
    model_selection=0,
    min_detection_confidence=0.6
)

face_mesh = mp_face_mesh.FaceMesh(refine_landmarks=True)

cap = cv2.VideoCapture(0)

labels = ["Closed", "Open", "Yawn", "NoYawn"]

last_alert_time = 0
alert_cooldown = 4

alert_count = 0
last_emergency_time = 0
emergency_cooldown = 20

eye_closed_start = None
yawn_start = None
distraction_start = None

system_start_time = time.time()
startup_delay = 10


def update_status(driver_status, eyes, yawning, head_pose, alert_count, emergency=False):
    data = {
        "driver_status": driver_status,
        "eyes": eyes,
        "yawning": yawning,
        "head_pose": head_pose,
        "alert_count": alert_count,
        "emergency": emergency,
        "mode": "Online"
    }

    with open("status.json", "w") as file:
        json.dump(data, file)


def speak_alert(message):
    global last_alert_time, alert_count, last_emergency_time

    current_time = time.time()

    if current_time - system_start_time < startup_delay:
        return

    if current_time - last_alert_time > alert_cooldown:
        print(message)
        engine.say(message)
        engine.runAndWait()

        last_alert_time = current_time
        alert_count += 1

        print("Warning Count:", alert_count)

        if alert_count >= 3:
            if current_time - last_emergency_time > emergency_cooldown:
                send_telegram_alert(
                    "🚨 EMERGENCY: Driver may be sleeping or distracted and is not responding to alerts. Please check immediately."
                )

                print("Emergency message sent to Telegram")

                update_status(
                    "Emergency",
                    "Closed",
                    "Yes",
                    "Distracted",
                    alert_count,
                    True
                )

                last_emergency_time = current_time

            alert_count = 0


update_status("Normal", "Open", "No", "Forward", alert_count, False)


while True:
    ret, frame = cap.read()

    if not ret:
        print("Camera not detected")
        break

    frame = cv2.flip(frame, 1)

    h, w, _ = frame.shape
    rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

    current_time = time.time()

    current_driver_status = "Normal"
    current_eyes = "Open"
    current_yawning = "No"
    current_head_pose = "Forward"
    current_emergency = False

    results = face_detection.process(rgb)

    if results.detections:
        for detection in results.detections:
            bbox = detection.location_data.relative_bounding_box

            x = int(bbox.xmin * w)
            y = int(bbox.ymin * h)
            width = int(bbox.width * w)
            height = int(bbox.height * h)

            face = frame[y:y + height, x:x + width]

            if face.size == 0:
                continue

            face = cv2.resize(face, (224, 224))
            face = face.astype("float32") / 255.0
            face = np.expand_dims(face, axis=0)

            prediction = model.predict(face, verbose=0)
            label_index = np.argmax(prediction)
            label = labels[label_index]

            cv2.rectangle(
                frame,
                (x, y),
                (x + width, y + height),
                (0, 255, 0),
                2
            )

            cv2.putText(
                frame,
                label,
                (x, y - 10),
                cv2.FONT_HERSHEY_SIMPLEX,
                0.8,
                (0, 255, 0),
                2
            )

            if label == "Yawn":
                current_yawning = "Yes"

                if yawn_start is None:
                    yawn_start = current_time
                elif current_time - yawn_start >= 3:
                    current_driver_status = "Fatigued"
                    speak_alert(
                        "You look tired. Please take a break or stop the vehicle safely."
                    )
            else:
                yawn_start = None
                current_yawning = "No"

    mesh_results = face_mesh.process(rgb)

    if mesh_results.multi_face_landmarks:
        for face_landmarks in mesh_results.multi_face_landmarks:
            nose = face_landmarks.landmark[1]
            left_eye = face_landmarks.landmark[33]
            right_eye = face_landmarks.landmark[263]

            nose_x = int(nose.x * w)
            nose_y = int(nose.y * h)

            left_x = int(left_eye.x * w)
            right_x = int(right_eye.x * w)

            center = (left_x + right_x) // 2

            direction = "Forward"

            if nose_x < center - 40:
                direction = "Looking Left"
            elif nose_x > center + 40:
                direction = "Looking Right"
            elif nose_y > h * 0.65:
                direction = "Looking Down"
            elif nose_y < h * 0.30:
                direction = "Looking Up"

            current_head_pose = direction

            cv2.putText(
                frame,
                direction,
                (30, 50),
                cv2.FONT_HERSHEY_SIMPLEX,
                1,
                (255, 0, 0),
                2
            )

            top_left = face_landmarks.landmark[159]
            bottom_left = face_landmarks.landmark[145]

            top_right = face_landmarks.landmark[386]
            bottom_right = face_landmarks.landmark[374]

            left_eye_dist = abs(top_left.y - bottom_left.y)
            right_eye_dist = abs(top_right.y - bottom_right.y)

            eye_ratio = (left_eye_dist + right_eye_dist) / 2

            if eye_ratio < 0.015:
                current_eyes = "Closed"

                cv2.putText(
                    frame,
                    "Eyes Closed",
                    (30, 90),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    1,
                    (0, 0, 255),
                    2
                )

                if eye_closed_start is None:
                    eye_closed_start = current_time
                elif current_time - eye_closed_start >= 2.5:
                    current_driver_status = "Drowsy"
                    speak_alert(
                        "Wake up! Please open your eyes and focus on driving."
                    )
            else:
                eye_closed_start = None
                current_eyes = "Open"

            if direction != "Forward":
                if distraction_start is None:
                    distraction_start = current_time
                elif current_time - distraction_start >= 4:
                    current_driver_status = "Distracted"
                    speak_alert(
                        "Please look at the road. You are distracted."
                    )
            else:
                distraction_start = None

    if current_eyes == "Closed":
        current_driver_status = "Drowsy"

    if current_yawning == "Yes":
        current_driver_status = "Fatigued"

    if current_head_pose != "Forward":
        current_driver_status = "Distracted"

    if current_driver_status == "Emergency":
        current_emergency = True

    update_status(
        current_driver_status,
        current_eyes,
        current_yawning,
        current_head_pose,
        alert_count,
        current_emergency
    )

    cv2.imshow("AI Driver Monitoring System", frame)

    if cv2.waitKey(1) & 0xFF == 27:
        break


update_status(
    "System Stopped",
    "Unknown",
    "Unknown",
    "Unknown",
    alert_count,
    False
)

cap.release()
cv2.destroyAllWindows()