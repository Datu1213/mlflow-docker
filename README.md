# mlflow-docker
MLFlow Server Image for ML pipeline.

Set **`MLFLOW_MODE`** to run a MLFlow server or model serving.

Set **`MLFLOW_MODEL_URI_MODE`** to ues prefered model-uri:
- 'alias': models:/`$MLFLOW_MODEL_NAME`@`$MLFLOW_MODEL_ALIAS`
- 'version':models:/`$MLFLOW_MODEL_NAME`/`$MLFLOW_MODEL_VERSION`

Use it to minimize your code and config and run with no concern about depandencies problems.

| Environment Variable            | Description                                                                 | Default Value                                |
|---------------------------------|-----------------------------------------------------------------------------|----------------------------------------------|
| MLFLOW_TRACKING_URI             | Tracking server URI for MLflow                                              | http://mlflow-server:5000                    |
| MLFLOW_S3_ENDPOINT_URL          | S3 (MinIO) endpoint location                                                | http://minio:9000                            |
| AWS_ACCESS_KEY_ID               | S3 access key ID (for MinIO)                                                | minioadmin                                   |
| AWS_SECRET_ACCESS_KEY           | S3 secret access key (for MinIO)                                            | minioadmin                                   |
| MLFLOW_BACKEND_STORE_URI        | Backend store URI for metadata (Postgres database)                          | postgresql://airflow:airflow@postgres:5432/mlflow_db |
| MLFLOW_ARTIFACT_ROOT            | Artifact storage root (model files location in MinIO)                       | s3://mlflow-artifacts/                       |
| MLFLOW_EXPOSE_PROMETHEUS        | Path to expose Prometheus metrics                                           | ./mlflow_metrics                             |
| MLFLOW_MODE                     | MLflow mode: 'server' or 'model'                                            | server                                       |
| MLFLOW_MODEL_NAME               | Name of the MLflow model                                                    | iris_logistic_regression                     |
| MLFLOW_MODEL_VERSION            | Version of the MLflow model                                                 | 1                                            |
| MLFLOW_MODEL_ALIAS              | Alias for the MLflow model version                                          | Staging                                      |
| MLFLOW_WORKERS                  | Number of MLflow server workers                                             | 2                                            |
| MLFLOW_SERVER_ALLOWED_HOSTS     | Allowed hosts for MLflow server. Use this to avoid DNS attacks and relevant runtime exceptions.                                             | mlflow-server:5000,localhost:5000            |

# Usage
### docker
`docker pull ghcr.io/datu1213/mlflow-docker:1.2.5`
### Dockerfile
```yaml
mlflow-server:
    image: ghcr.io/datu1213/mlflow-docker:1.2.5
    ports:
      - "5000:5000"
    environment:
      MLFLOW_MODE: 'server'
      # Backend storage (Metastore): Postgres or others
      MLFLOW_BACKEND_STORE_URI: "postgresql://airflow:airflow@postgres:5432/mlflow_db"
      # Artifact (Model files): MinIO or your own S3
      MLFLOW_ARTIFACT_ROOT: "s3://mlflow-artifacts/"
      # S3 Access token
      AWS_ACCESS_KEY_ID: minioadmin
      AWS_SECRET_ACCESS_KEY: minioadmin
      MLFLOW_S3_ENDPOINT_URL: "http://minio:9000" # Tell MLflow to use MinIO，instead of AWS S3
      MLFLOW_EXPOSE_PROMETHEUS: ./mlflow_metrics
    depends_on:
      - minio

mlflow-model-server:
  image: ghcr.io/datu1213/mlflow-docker:1.2.6
  ports:
    - "5004:5001"
  environment:
    MLFLOW_MODE: 'model'
    # Where the MLflow server is
    MLFLOW_TRACKING_URI: "http://mlflow-server:5000"
    # S3 Access token
    AWS_ACCESS_KEY_ID: minioadmin
    AWS_SECRET_ACCESS_KEY: minioadmin
    # Tell MLflow to use MinIO，instead of AWS S3
    MLFLOW_S3_ENDPOINT_URL: "http://minio:9000"
    MLFLOW_MODEL_NAME: "iris_logistic_regression"
    MLFLOW_MODEL_VERSION: "1"
    MLFLOW_MODEL_ALIAS: "Staging"
    # Use alias to build model-uri
    MLFLOW_MODEL_URI_MODE: "alias"
  depends_on:
    - minio
    - mlflow-server
```