FROM python:3.9-slim
RUN  apt-get install curl gpg apt-transport-https --yes 
RUN curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null 
RUN echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
RUN  apt-get update
RUN  apt-get install helm
COPY requirements.txt /myapp/requirements.txt
WORKDIR /myapp
RUN pip install -r requirements.txt
COPY . .

EXPOSE 8000
CMD ["python3", "app.py"]
