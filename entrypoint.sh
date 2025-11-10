#!/bin/bash

if [[ $MLFLOW_MODEL_URI_MODE='alias' ]]; then
  export MLFLOW_MODEL_URI="models:/$MLFLOW_MODEL_NAME@$MLFLOW_MODEL_ALIAS"
else
  export MLFLOW_MODEL_URI="models:/$MLFLOW_MODEL_NAME/$MLFLOW_MODEL_VERSION"
fi

if [[ $MLFLOW_MODE = 'server' ]]; then
  mlflow server \
      --host 0.0.0.0 \
      --port 5000 \
      --backend-store-uri $MLFLOW_BACKEND_STORE_URI \
      --default-artifact-root $MLFLOW_ARTIFACT_ROOT \
      --allowed-hosts $MLFLOW_SERVER_ALLOWED_HOSTS
  # Use this line to customize allowed hosts
  # Remember to bracket the argument with single quotes ''
  # --allowed-hosts '<hostname>:<port>,localhost:<port>'
else
  mlflow models serve \
      # model-uri format: models:/<model-name>/<model-version>
      # if you have a registered model with name "MyModel" and version 1
      # the URI referring to the model is: models:/MyModel/1".
      # or models:/<model-name>/<model-version>
      # like models:/MyModel@Staging
      --model-uri "models:/$MLFLOW_MODEL_NAME@$MLFLOW_MODEL_ALIAS" \
      --host 0.0.0.0 \
      --port 5001 \
      --workers $MLFLOW_WORKERS \
      --no-conda
fi