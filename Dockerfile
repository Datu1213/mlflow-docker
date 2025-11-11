# ---------- Builder Stage ----------
FROM python:3.11-bullseye AS builder

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-17-jdk-headless && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt /tmp/requirements.txt

# Create virtual environment with uv
# install pip/uv
RUN python -m pip install --upgrade pip setuptools wheel uv && \
    uv venv /opt/mlflow-venv && \
    . /opt/mlflow-venv/bin/activate && \
    uv pip install --no-cache-dir -vvv -r /tmp/requirements.txt

# ---------- Runtime Stage ----------
FROM python:3.11-slim-bullseye AS runtime

# Environment variables
ENV PATH="/opt/mlflow-venv/bin:$PATH" \
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 \
    PATH=$JAVA_HOME/bin:$PATH \
    MLFLOW_TRACKING_URI="http://mlflow-server:5000" \
    MLFLOW_S3_ENDPOINT_URL="http://minio:9000" \
    AWS_ACCESS_KEY_ID="minioadmin" \
    AWS_SECRET_ACCESS_KEY="minioadmin" \
    MLFLOW_BACKEND_STORE_URI="postgresql://airflow:airflow@postgres:5432/mlflow_db" \
    MLFLOW_ARTIFACT_ROOT="s3://mlflow-artifacts/" \
    MLFLOW_EXPOSE_PROMETHEUS="./mlflow_metrics" \
    MLFLOW_MODE="server" \
    MLFLOW_MODEL_NAME="iris_logistic_regression" \
    MLFLOW_MODEL_VERSION="1" \
    MLFLOW_MODEL_ALIAS="Staging" \
    MLFLOW_MODEL_URI_MODE="alias" \
    MLFLOW_WORKERS="2" \
    MLFLOW_SERVER_ALLOWED_HOSTS="mlflow-server:5000,localhost:5000"

# Copy virtual environment from builder
COPY --from=builder /opt/mlflow-venv /opt/mlflow-venv

# Copy entrypoint
COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh
# Create non-root user

RUN useradd -m -u 1000 mlflow && \
    chown -R mlflow:mlflow /opt

USER mlflow

WORKDIR /opt

ENTRYPOINT ["/opt/entrypoint.sh"]
