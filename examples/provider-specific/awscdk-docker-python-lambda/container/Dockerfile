FROM public.ecr.aws/lambda/python:3.9

ENV POETRY_VERSION=1.4.2

# Install poetry
RUN pip install "poetry==$POETRY_VERSION"

# Copy only requirements to cache them in docker layer
WORKDIR ${LAMBDA_TASK_ROOT}
COPY poetry.lock pyproject.toml ${LAMBDA_TASK_ROOT}/

# Project initialization:
RUN poetry config virtualenvs.create false && poetry install --no-interaction --no-ansi --no-root

# Copy our Flask app to the Docker image
COPY src ${LAMBDA_TASK_ROOT}/

# Set the CMD to your handler (could also be done as a parameter override outside of the Dockerfile)
CMD [ "lambda_1.index.handler" ]