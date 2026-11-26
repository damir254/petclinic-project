# Spring Petclinic

This repository uses the Spring Petclinic Angular frontend and Spring Boot REST backend for educational purposes only.

## Original Projects

- **Frontend:** [spring-petclinic-angular](https://github.com/spring-petclinic/spring-petclinic-angular)
- **Backend:** [spring-petclinic-rest](https://github.com/spring-petclinic/spring-petclinic-rest)

All rights to the original source code remain with their respective copyright holders.

## DevOps Internship Tasks

### Build Container Images

Run these commands from the repository root to build the frontend and backend images.

```sh
docker build -t petclinic-frontend:v1 ./frontend
docker build -t petclinic-backend:v1 ./backend
```

### Externalize Runtime Configuration and Secrets

The frontend `REST_API_URL` is set when the container starts, so the same image can be reused across environments. The Nginx entrypoint runs `envsubst` on [env.js.template](./frontend/env.js.template) to generate `env.js`, which Nginx serves at `/assets/env.js`. The browser loads the script from [index.html](./frontend/src/index.html) before Angular starts, and Angular reads the URL from `window.__env`.

The backend receives its environment-specific values through environment variables at startup.

### Deploy Petclinic with Docker Compose

Use [.env.example](./.env.example) to set database credentials in `.env`, then run `docker compose up --build -d` from the repository root. The [Compose configuration](./compose.yml) runs the frontend, backend, and PostgreSQL. Compose waits for PostgreSQL to pass its health check before starting the backend. Postgres data is stored inside a named volume, which you can remove if you provide `-v` flag during `docker compose down`.

### Automate EC2 Configuration with Ansible

The [EC2 preparation playbook](./ansible/playbooks/ec2_deployment_preparation.yml) installs Docker and the Compose plugin, enables Docker at boot, and gives `ec2-user` access to Docker.

### Deploy Petclinic to the EC2 Server

The [deployment playbook](./ansible/playbooks/deploy-petclinic.yml) loads database credentials from Ansible Vault, generates the [Compose and environment files](./ansible/roles/petclinic/templates/), and starts Petclinic. If `.env` is already present on server at `/opt/petclinic/` **Playbook will NOT override it because of `force: false`**, otherwise it will create default `.env` with [deployment defaults](./ansible/roles/petclinic/defaults/main.yml). Nginx role generates [configuration files](./ansible/roles/nginx/templates/) that route requests under `/petclinic/api/` to the backend and serves the frontend on other paths. 
**Make persistent changes in the Ansible templates or variables, since rerunning the playbook can overwrite manual edits to files it manages.**

### Configure Application Logging

The backend uses [Logback](./backend/src/main/resources/logback.xml) to write one JSON object per log event. At the default log level, `INFO` and `WARN` go to stdout and `ERROR` goes to stderr. Both streams use the same JSON format.

### Create the GitHub Actions CI Pipeline

CI validates pull requests to `main`. A shared change filter selects the relevant jobs. [CI workflow](./.github/workflows/ci.yml) · [Change filter](./.github/workflows/files-changed.yml)

### Create the Deployment Pipeline

On pushes to `main`, CD builds and pushes images for changed services to Docker Hub using the commit SHA as the tag. It connects to EC2 over SSH, updates the tags for successfully published images in `/opt/petclinic/.env`, and deploys them with Docker Compose. [CD workflow](./.github/workflows/cd.yml)


