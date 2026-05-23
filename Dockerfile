FROM python:3.9-slim

RUN apt-get update && apt-get install -y curl \
    && curl -fsSL -o get_helm.sh https://githubusercontent.com \
    && chmod 700 get_helm.sh \
    && ./get_helm.sh \
    && rm get_helm.sh \
    && rm -rf /var/lib/apt/lists/*
COPY requirements.txt /myapp/requirements.txt
WORKDIR /myapp
RUN pip install -r requirements.txt
COPY . .

EXPOSE 8000
CMD ["python3", "app.py"]
