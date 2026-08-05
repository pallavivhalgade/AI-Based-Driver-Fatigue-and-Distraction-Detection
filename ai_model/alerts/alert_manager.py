"""Alert management module."""

import logging

logger = logging.getLogger(__name__)


class AlertManager:
    """Manage driver warning notifications."""

    def voice_alert(self, message):
        logger.info("Voice alert: %s", message)

    def sms_alert(self, message):
        logger.info("SMS alert triggered: %s", message)

    def trigger_alert(self, level, message):
        if level == "critical":
            self.sms_alert(message)

        self.voice_alert(message)
