# Global ARG, available to all stages
ARG WORKDIR=/

# Must use a Cuda version 11+
FROM pytorch/pytorch:1.11.0-cuda11.3-cudnn8-runtime AS builder


# Explanations:
# Don't buffer `stdout`
# Don't create `.pyc` files
# https://pip.pypa.io/en/stable/topics/caching/#avoiding-caching
# https://pip.pypa.io/en/stable/cli/pip/?highlight=PIP_NO_CACHE_DIR#cmdoption-no-cache-dir
# https://pip.pypa.io/en/stable/cli/pip/?highlight=PIP_DISABLE_PIP_VERSION_CHECK#cmdoption-disable-pip-version-check
# https://pip.pypa.io/en/stable/cli/pip/?highlight=PIP_DEFAULT_TIMEOUT#cmdoption-timeout
# https://pip.pypa.io/en/stable/topics/configuration/#environment-variables
# https://python-poetry.org/docs/#installation
ARG POETRY_VERSION=1.3.2
ENV PYTHONUNBUFFERED = 1 \
    PYTHONDONTWRITEBYTECODE = 1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100

# Copy project into Docker image
ARG WORKDIR
WORKDIR ${WORKDIR}
COPY . .

# Install git, Poetry and Python packages
# RUN apt-get update && \
#   apt-get install -y git && \
#   pip install poetry==${POETRY_VERSION} && \
#   poetry config virtualenvs.in-project true && \
#   poetry install --only main
RUN apt-get update
RUN apt-get install -y git
RUN pip install poetry==${POETRY_VERSION}
RUN poetry config virtualenvs.in-project true
RUN poetry install --only main

# Final Docker image, where we just copy the virtual environment
FROM pytorch/pytorch:1.11.0-cuda11.3-cudnn8-runtime

ARG WORKDIR
WORKDIR ${WORKDIR}

COPY --from=builder ${WORKDIR} .

RUN ./.venv/bin/python download.py

CMD ./.venv/bin/python -u server.py
