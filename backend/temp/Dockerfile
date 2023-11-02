FROM python:3.12-bookworm

WORKDIR /app

COPY . .

RUN pip install -r requirements.txt

EXPOSE 8002
CMD ["python", "temp.py", "8002"]