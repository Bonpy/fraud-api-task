from fastapi.testclient import TestClient

import main

client = TestClient(main.app)


def test_ping() -> None:
    resp = client.get("/ping")
    assert resp.status_code == 200
    assert resp.json() == {"status": "ok"}


def test_predict_dummy_low_value() -> None:
    """transaction_value < 500, prob < 0.5, flag False"""
    payload = {
        "age": 30,
        "gender_code": 1,
        "location": 10,
        "subscription_type_code": 1,
        "tenure_months": 12,
        "income_bracket_code": 1,
        "event_created_at_ts": 1718500000.0,
        "transaction_value": 149.99,
        "channel_code": 0,
    }
    resp = client.post("/invocations", json=payload)
    assert resp.status_code == 200
    body = resp.json()
    assert body["fraud_flag"] is False
    assert 0.0 <= body["fraud_probability"] < 0.5


def test_predict_dummy_high_value() -> None:
    """transaction_value >= 500, prob >= 0.5, flag True"""
    payload = {
        "age": 30,
        "gender_code": 1,
        "location": 10,
        "subscription_type_code": 1,
        "tenure_months": 12,
        "income_bracket_code": 1,
        "event_created_at_ts": 1718500000.0,
        "transaction_value": 999.0,
        "channel_code": 0,
    }
    resp = client.post("/invocations", json=payload)
    assert resp.status_code == 200
    body = resp.json()
    assert body["fraud_flag"] is True
    assert 0.5 <= body["fraud_probability"] <= 1.0


def test_schema_validation() -> None:
    """Negative age should fail validation (422)."""
    bad_payload = {
        "age": -1,
        "gender_code": 1,
        "location": 10,
        "subscription_type_code": 1,
        "tenure_months": 12,
        "income_bracket_code": 1,
        "event_created_at_ts": 1718500000.0,
        "transaction_value": 10.0,
        "channel_code": 0,
    }
    resp = client.post("/invocations", json=bad_payload)
    assert resp.status_code == 422
