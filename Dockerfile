# ---------- Build Stage ----------
FROM python:3.14.0-slim as builder

WORKDIR /app

COPY requirements.txt .

# Install packages into /app/.local using --prefix (non-root safe)
RUN pip install --upgrade pip \
  && pip install --no-cache-dir --prefix=/app/.local -r requirements.txt

# ---------- Final Stage ----------
FROM python:3.14.0-slim

# Create non-root user
RUN useradd -m appuser

# Set environment variables so Python and PATH work for appuser
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH=/home/appuser/.local/bin:$PATH \
    PYTHONPATH=/home/appuser/.local/lib/python3.14/site-packages \
    REDIS_HOST=localhost

WORKDIR /app

# Copy installed packages and app code
COPY --from=builder /app/.local /home/appuser/.local
COPY greet.py .
COPY requirements.txt .

# Set ownership and switch to non-root user
RUN chown -R appuser /app /home/appuser
USER appuser


EXPOSE 8080

# Run the app with Gunicorn on port 8080
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "greet:app", "--workers", "2"]