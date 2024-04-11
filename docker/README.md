# Docker Support

- NVidia CUDA 12.4.0 Docker image with GPU support
- Python 3.11.8
- Miniconda3 environment
- Build cache shared between services
- Localization at OS level with 152 UTF-8 locales

## Dockerized OpenDevin

Use following sequence to have it up and running.

```shell
$ git clone https://github.com/OpenDevin/OpenDevin.git .
$ cd OpenDevin
$ docker compose up --build
```

Also `docker compose up --build app` will start application container with dependencies, as well as `docker compose up --build ui` will start the UI server.

### Components

 - OpenDevin service
 - LiteLLM Proxy service
 - Mitmproxy for debugging
 - Ollama LLM service
 - Postgres server
 - Redis server

### configuration using `.env` files
- Ports 
- Time zone configuration
- Directory paths

## Use as a systemd service

1. Clone the repository

`git clone https://github.com/lehcode/oppendevin.git /opt/oppendevin`

1. Stop or disable existing ollama

Temporarily stop or disable Ollama systemd service on host system to avoid running multiple Ollama services.

```shell
$ systemctl stop ollama.service
$ systemctl disable ollama.service
```

2. Create a systemd Service Unit File

Create a systemd service unit file (e.g., oppendevin.service) in the /etc/systemd/system/ directory:

```shell
sudo systemctl edit --full docker-compose@.opendevin.service
```

```ini
[Unit]
Description=Oppendevin systemd service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/oppendevin
ExecStart=/usr/local/bin/docker-compose up up -d --remove-orphans
ExecStop=/usr/local/bin/docker-compose down

[Install]
WantedBy=multi-user.target
```

- Update the paths to docker-compose and docker-compose.yml as necessary.

3. Reload systemd and enable the service

After creating the systemd service unit file, reload systemd to load the new service and enable it to start automatically on boot.

```bash
sudo systemctl daemon-reload
sudo systemctl start oppendevin
```

Optionally enable service to start automatically on boot.

```bash
sudo systemctl enable oppendevin
```
