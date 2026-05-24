FROM python:3.9-slim
RUN pip install --upgrade pip
COPY requirements.txt /myapp/requirements.txt
WORKDIR /myapp
RUN pip install -r requirements.txt
COPY . .

EXPOSE 8000
CMD ["python3", "app.py"]
