# Use multi-stage builds to reduce the size of the final image
FROM python:3.12-slim as builder

ENV PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    POETRY_VERSION=1.5.1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/* \
    && pip install "poetry==$POETRY_VERSION"

COPY poetry.lock pyproject.toml ./

RUN  poetry install --no-interaction --no-ansi --no-root

FROM python:3.12-slim

WORKDIR /app

# Install poetry in the final image
RUN pip install "poetry==1.5.1"

COPY --from=builder / /
COPY . .

EXPOSE 8501

CMD ["sh", "-c", "poetry run streamlit run app.py --server.port=${PORT:-8501} --server.address=0.0.0.0"]
