import requests

BOT_TOKEN = "8328978924:AAF2amSV-pY7CNuuVbS1HhASzWmQ8JPZjj4"
CHAT_ID = "5580786238"

def send_telegram_alert(message):
    url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"

    data = {
        "chat_id": CHAT_ID,
        "text": message
    }

    response = requests.post(url, data=data)
    print(response.text)

