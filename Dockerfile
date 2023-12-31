FROM python:3.10.11 AS base

ARG DEV_dentexmodel
#ARG CI_USER_TOKEN
#RUN echo "machine github.com\n  login $CI_USER_TOKEN\n" >~/.netrc

ENV \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=random \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    PIP_SRC=/src \
    PIPENV_HIDE_EMOJIS=true \
    NO_COLOR=true \
    PIPENV_NOSPIN=true

EXPOSE 8888
WORKDIR /app

# System dependencies
RUN apt-get update -y
RUN apt install 'libgl1-mesa-glx'\
    'ffmpeg'\
    'libsm6'\
    'libxext6'  -y

COPY setup.py .
COPY src/dentexmodel/__init__.py src/dentexmodel/__init__.py

# Install pipenv and deploy in system python
RUN pip install --upgrade pip
RUN pip install pipenv
RUN mkdir -p /app

# Install dependencies into system python
COPY Pipfile .
COPY Pipfile.lock .
RUN pipenv install --system --deploy --ignore-pipfile --dev

# PyTorch CPU version
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Run the jupyter lab server
# ENTRYPOINT ["/bin/bash", "/app/docker_entry.sh"]
CMD ["/bin/bash", "/app/docker_entry.sh"]