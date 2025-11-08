# greet-app

# Flask + Redis Greeting App

This is a lightweight Flask application that stores and retrieves a user's name using Redis. It’s designed to run seamlessly in Docker, Docker Compose, and Kubernetes environments.

---

## 🚀 Features

- Stores user name via POST request
- Retrieves greeting via GET request
- Uses Redis for persistence
- Production-ready Dockerfile with Gunicorn
- Environment-driven configuration for portability

---

## 🧱 Architecture Decisions

### 🔹 Why I Created the Docker Network `greet-app`

Docker containers are isolated by default. To enable communication between the Flask app and Redis, I created a user-defined bridge network:

```bash
docker network create greet-app


🔹 Why I Modified greet.py to Use os.getenv("REDIS_HOST")
Hardcoding localhost only works if Redis is inside the same container. To make the app portable across environments, I updated the Redis connection logic:

import os
red = redis.StrictRedis(
    host=os.getenv("REDIS_HOST", "localhost"),
    port=6379,
    db=1
)

This allows Redis hostname to be injected via environment variables:
- localhost for local dev
- redis for Docker Compose or Kubernetes
- Cloud hostname for managed Redis services


🔹 Why I Removed app.run() in greet.py and Used Gunicorn
Flask’s built-in server is not suitable for production. I replaced it with Gunicorn in the Dockerfile:
CMD ["gunicorn", "--bind", "0.0.0.0:9090", "greet:app", "--workers", "2"]


Benefits:
- Multi-worker concurrency
- Graceful shutdowns
- Compatibility with Docker healthchecks and Kubernetes probes

🐳 Running with Docker
1. Build the image
docker build -t greet-app:1.0 .

2. Create network
docker network create greet-app

3. Start Redis
docker run -d --name redis --network greet-app redis:latest


4. Start Flask app
docker run -d --name app --network greet-app -p 8080:9090 -e REDIS_HOST=redis greet-app:1.0


🧪 API Usage

POST /
Stores the user's name.
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{"name": "Anil"}'

GET /
Returns the greeting.

curl http://localhost:8080