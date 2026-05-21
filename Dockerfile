FROM python:3.12-alpine

WORKDIR /app

COPY docker/server.py /app/server.py
COPY build/web /app/web

ENV PORT=8081
ENV WEB_ROOT=/app/web
ENV SCORES_FILE=/data/scores.json

RUN mkdir -p /data

EXPOSE 8081

CMD ["python", "/app/server.py"]
