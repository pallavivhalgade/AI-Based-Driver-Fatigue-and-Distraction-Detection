"""Alert manager tests."""

from ai_model.alerts.alert_manager import AlertManager


def test_alert_manager_initialization():
    manager = AlertManager()
    assert manager is not None


def test_warning_alert_does_not_fail():
    manager = AlertManager()
    manager.trigger_alert("warning", "Driver fatigue warning")
