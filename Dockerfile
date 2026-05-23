FROM python:3.9-slim
COPY . /myapp
WORKDIR /myapp
RUN pip install -r requirements.txt
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*


RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list


RUN apt-get update && apt-get install -y helm \
    && rm -rf /var/lib/apt/lists/*
EXPOSE 8000
CMD ["python3", "app.py"]
