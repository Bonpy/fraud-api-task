import os
import pickle
from pathlib import Path
from typing import Annotated, Callable, Literal

import pandas as pd
import uvicorn
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

THRESHOLD = float(os.getenv("THRESHOLD", 0.5))
MODEL_PATH = Path(os.getenv("MODEL_PATH", "fraud_model.pkl"))


class Input(BaseModel):
    age: Annotated[int, Field(ge=0, le=120)]
    gender_code: Literal[0, 1, 2]
    location: Annotated[int, Field(ge=0)]
    subscription_type_code: Literal[0, 1, 2]
    tenure_months: Annotated[int, Field(ge=0)]
    income_bracket_code: Literal[0, 1, 2]
    event_created_at_ts: float
    transaction_value: Annotated[float, Field(ge=0)]
    channel_code: Literal[0, 1]

    model_config = {"extra": "forbid"}


class Output(BaseModel):
    fraud_flag: bool
    fraud_probability: Annotated[float, Field(ge=0.0, le=1.0)]


app = FastAPI()


def _load_model() -> Callable[[Input], float]:
    """
    Load the model from the specified path and return a scoring function.
    If the model cannot be loaded, return a dummy scoring function.
    """

    if MODEL_PATH.is_file():
        try:
            with MODEL_PATH.open("rb") as f:
                model = pickle.load(f)

            def model_score(rec: Input) -> float:
                X = pd.DataFrame([rec.model_dump()])
                return float(model.predict_proba(X)[:, 1][0])

            return model_score
        except Exception:
            pass

    def dummy_score(rec: Input) -> float:
        return min(rec.transaction_value / 1000.0, 1.0)

    return dummy_score


score = _load_model()


@app.get("/ping")
async def ping() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/invocations", response_model=Output)
async def predict(record: Input) -> dict[str, float]:
    try:
        proba = score(record)
        return {"fraud_flag": proba >= THRESHOLD, "fraud_probability": proba}
    except Exception as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8080)
