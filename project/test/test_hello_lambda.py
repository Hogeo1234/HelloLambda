import json
from src.hello_lambda import handler


def test_handler_returns_ok():
    event = {}
    context = None
    result = handler(event, context)

    assert result["statusCode"] == 200
    body = json.loads(result["body"])
    assert body["message"] == "OK"