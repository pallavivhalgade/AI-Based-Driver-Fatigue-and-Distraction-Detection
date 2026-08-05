"""Alert management module."""

import logging

from backend.config.settings import (
    TELEGRAM_BOT_TOKEN,
    TELEGRAM_CHAT_ID,
)

logger = logging.getLogger(__name__)


class AlertManager:
    """Manage driver warning notifications."""

    def voice_alert(self, message):
        logger.info("Voice alert: %s", message)

    def sms_alert(self, message):
        logger.info("SMS alert triggered: %s", message)

    def telegram_alert(self, message):
        if TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID:
            logger.info("Telegram alert triggered")
        else:
            logger.warning("Telegram credentials not configured")

    def trigger_alert(self, level, message):
        if level == "critical":
            self.sms_alert(message)
            self.telegram_alert(message)

        self.voice_alert(message)
