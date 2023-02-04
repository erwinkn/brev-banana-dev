# Must use a Cuda version 11+
FROM pytorch/pytorch:1.11.0-cuda11.3-cudnn8-runtime

WORKDIR /

# Install git
RUN apt-get update && apt-get install -y git

# Install python packages
ADD requirements.txt requirements.txt
RUN curl -sSL https://install.python-poetry.org | python3 -
RUN poetry install

# We add the banana boilerplate here
ADD server.py .

# Add your model weight files 
# (in this case we have a python script)
ADD download.py .
RUN python3 download.py


# Add your custom app code, init() and inference()
ADD app.py .

EXPOSE 8000

CMD python3 -u server.py
