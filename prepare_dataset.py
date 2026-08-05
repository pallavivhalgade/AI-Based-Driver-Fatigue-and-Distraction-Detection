import os
import cv2
import numpy as np

DATASET_PATH = r"C:\Users\mahes\OneDrive\Desktop\driver-fatigue-ai\dataset"

IMG_SIZE = 224

classes = ["yawn", "notyawn", "open", "closed"]

def load_images(folder_path):
    images = []
    labels = []

    for label, category in enumerate(classes):
        path = os.path.join(folder_path, category)

        if not os.path.exists(path):
            print("Folder missing:", path)
            continue

        for img in os.listdir(path):
            img_path = os.path.join(path, img)

            try:
                image = cv2.imread(img_path)
                image = cv2.resize(image, (IMG_SIZE, IMG_SIZE))
                image = image / 255.0

                images.append(image)
                labels.append(label)
            except:
                continue

    return np.array(images), np.array(labels)


print("Loading training dataset...")
X_train, y_train = load_images(os.path.join(DATASET_PATH, "train"))

print("Loading testing dataset...")
X_test, y_test = load_images(os.path.join(DATASET_PATH, "test"))

np.save("X_train.npy", X_train)
np.save("y_train.npy", y_train)

np.save("X_test.npy", X_test)
np.save("y_test.npy", y_test)

print("\nDataset prepared successfully")
print("Training samples:", len(X_train))
print("Testing samples:", len(X_test))