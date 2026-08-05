import cv2
import numpy as np
import time
from tensorflow.keras.models import load_model
import pyttsx3

model = load_model("driver_fatigue_model.h5")

engine = pyttsx3.init()

IMG_SIZE = 224
classes = ["yawn", "notyawn", "open", "closed"]

cap = cv2.VideoCapture(0)

face_cascade = cv2.CascadeClassifier(
    cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
)

last_alert_time = 0
alert_cooldown = 5   # seconds

prediction_buffer = []

while True:
    ret, frame = cap.read()
    if not ret:
        break

    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    faces = face_cascade.detectMultiScale(gray, 1.3, 5)

    for (x, y, w, h) in faces:

        face = frame[y:y+h, x:x+w]
        face = cv2.resize(face, (IMG_SIZE, IMG_SIZE))
        face = face / 255.0
        face = np.reshape(face, (1, IMG_SIZE, IMG_SIZE, 3))

        prediction = model.predict(face, verbose=0)
        class_index = np.argmax(prediction)
        label = classes[class_index]

        prediction_buffer.append(label)

        if len(prediction_buffer) > 10:
            prediction_buffer.pop(0)

        stable_label = max(set(prediction_buffer), key=prediction_buffer.count)

        cv2.rectangle(frame, (x, y), (x+w, y+h), (0,255,0), 2)

        cv2.putText(frame, stable_label,
                    (x, y-10),
                    cv2.FONT_HERSHEY_SIMPLEX,
                    1,
                    (0,255,0),
                    2)

        current_time = time.time()

        if stable_label in ["closed", "yawn"]:
            if current_time - last_alert_time > alert_cooldown:
                engine.say("Driver seems tired")
                engine.runAndWait()
                last_alert_time = current_time

    cv2.imshow("Driver Fatigue Detection", frame)

    if cv2.waitKey(1) == 27:
        break

cap.release()
cv2.destroyAllWindows()