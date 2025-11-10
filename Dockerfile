FROM python:3.11-bullseye

USER root

ENV MLFLOW_TRACKING_URI="http://mlflow-server:5000"
      # 告诉它S3(MinIO)在哪里
ENV MLFLOW_S3_ENDPOINT_URL="http://minio:9000"
ENV AWS_ACCESS_KEY_ID=minioadmin
ENV AWS_SECRET_ACCESS_KEY=minioadmin
# 后端存储 (元数据): 指向现有的Postgres服务和新数据库
ENV MLFLOW_BACKEND_STORE_URI="postgresql://airflow:airflow@postgres:5432/mlflow_db"
      # 产物存储 (模型文件): 指向MinIO服务
ENV MLFLOW_ARTIFACT_ROOT="s3://mlflow-artifacts/"
      # S3连接凭证 (指向MinIO)
ENV AWS_ACCESS_KEY_ID=minioadmin
ENV AWS_SECRET_ACCESS_KEY=minioadmin
ENV MLFLOW_EXPOSE_PROMETHEUS='./mlflow_metrics'
# 'server' or 'model' 
ENV MLFLOW_MODE='server'
ENV MLFLOW_MODEL_NAME ='iris_logistic_regression'

ENV MLFLOW_MODEL_VERSION='1'
ENV MLFLOW_MODEL_ALIAS='Staging'
ENV MLFLOW_WORKERS=2
ENV MLFLOW_SERVER_ALLOWED_HOSTS='mlflow-server:5000,localhost:5000'

RUN apt-get update && \
    # --------  Important  ------------
    # Use headless JDK to avoid ument depandencies exceptions
    # --------  Important  ------------
    apt-get install -y --no-install-recommends openjdk-17-jdk-headless \
    pip install --upgrade pip setuptools wheel && \
    pip install uv && uv venv mlflow-venv && \
    source mlflow-venv/bin/activate && \
    uv pip install Werkzeug prometheus_flask_exporter gunicorn alembic sqlalchemy flask psycopg2-binary boto3 mlflow && \
    uv pip install opentelemetry-sdk opentelemetry-exporter-otlp-proto-http opentelemetry-exporter-prometheus && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /opt/

ENTRYPOINT [ "/opt/entrypoint.sh" ]