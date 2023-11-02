FROM python:3.12-bookworm

WORKDIR /app

COPY . .

RUN pip install -r requirements.txt

EXPOSE 8003
CMD ["python", "datastore.py", "8003"]