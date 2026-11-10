# Task 05 — Externalize Runtime Configuration and Secrets

Externalized the frontend API URL (`REST_API_URL`), backend database URL, username and password (`POSTGRES_URL`, `POSTGRES_USER`, `POSTGRES_PASS`, or their `MYSQL_*` equivalents), and active Spring profiles (`SPRING_PROFILES_ACTIVE`). Values are supplied at startup, allowing the same images to be reused across environments.

The examples assume the images are built, `petclinic-net` exists, and `POSTGRES_PASSWORD` is set in your shell.

```bash
docker run -d \
  --name petclinic-db \
  --network petclinic-net \
  -e POSTGRES_DB=petclinic \
  -e POSTGRES_USER=petclinic \
  -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  -v petclinic-pgdata:/var/lib/postgresql \
  postgres:18

docker run -d \
  --name petclinic-backend \
  --network petclinic-net \
  -p 9966:9966 \
  -e SPRING_PROFILES_ACTIVE=postgres,spring-data-jpa \
  -e POSTGRES_URL=jdbc:postgresql://petclinic-db:5432/petclinic \
  -e POSTGRES_USER=petclinic \
  -e POSTGRES_PASS="$POSTGRES_PASSWORD" \
  backend:task05

docker run -d \
  --name petclinic-frontend \
  --network petclinic-net \
  -p 8080:8080 \
  -e REST_API_URL=http://localhost:9966/petclinic/api/ \
  frontend:task05
```
