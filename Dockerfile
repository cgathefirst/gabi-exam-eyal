FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y curl \
    && curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
COPY requirements.txt /myapp/requirements.txt
WORKDIR /myapp
RUN pip install -r requirements.txt
COPY . .

EXPOSE 8000
CMD ["python3", "app.py"]
