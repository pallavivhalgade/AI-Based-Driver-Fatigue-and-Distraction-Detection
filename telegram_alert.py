"""Telegram alert utility.

Credentials are loaded from environment variables.
Never store Telegram bot tokens in source code.
"""

import os
import requests
from dotenv import load_dotenv

load_dotenv()

BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
CHAT_ID = os.getenv("TELEGRAM_CHAT_ID")


def send_telegram_alert(message):
    if not BOT_TOKEN or not CHAT_ID:
        raise ValueError("Telegram credentials are not configured")

    url = f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage"

    data = {
        "chat_id": CHAT_ID,
        "text": message
    }

    response = requests.post(url, data=data, timeout=10)
    response.raise_for_status()

    return response.json()
