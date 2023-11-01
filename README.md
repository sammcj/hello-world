# Hello World

Hello World application written in Go.

## Features

- Always returns a HTTP 200 status code and a "Hello, World!" message at the / path.
- Has a metrics endpoint at /metrics that returns Prometheus metrics.
- Has a health check endpoint, /health, that returns an empty response and a HTTP 200 response.

## Build

```bash
make deps
make build
```

## Usage

### local

```bash
./hello_world                                                         <region:ap-southeast-2>
[GIN-debug] [WARNING] Running in "debug" mode. Switch to "release" mode in production.
 - using env: export GIN_MODE=release
 - using code: gin.SetMode(gin.ReleaseMode)

[GIN-debug] GET    /metrics                  --> github.com/zsais/go-gin-prometheus.(*Prometheus).SetMetricsPath.prometheusHandler.func2 (4 handlers)
[GIN-debug] GET    /health                   --> main.healthFunc (6 handlers)
[GIN-debug] GET    /                         --> main.helloFunc (6 handlers)
[GIN-debug] GET    /version                  --> main.versionFunc (6 handlers)
[GIN-debug] Environment variable PORT is undefined. Using port :8080 by default
[GIN-debug] Listening and serving HTTP on :8080
```

### Docker

```bash
docker run \
  --detach \
  --name hello-world \
  --publish 8000:8080 \
  ghcr.io/infrastructure-as-code/hello-world
```

curl the container

`curl http://0.0.0.0:8000/`

curl the health check endpoint which returns an empty 200 response

`curl http://0.0.0.0:8000/health`

curl Prometheus metrics

`curl http://0.0.0.0:8000/metrics`

## Acknowledgements

- [infrastructure-as-code/docker-hello-world](https://github.com/infrastructure-as-code/docker-hello-world)
