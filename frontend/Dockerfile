FROM python:3.12-bookworm

WORKDIR /app

COPY . .

RUN pip install -r requirements.txt

EXPOSE 8000
CMD ["python", "frontend.py", "8000"]