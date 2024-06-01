# Transperler 🐚⚪
A transpiler client (developed with Vue, Nuxt.js and TypeScript), and API (developed with Go and Gin),
that wraps around a transpiler written in Perl 5 that maps POSIX shell scripts to their equivalent Perl 5 scripts. Supports most
of the control structures and builtin commands in the POSIX Shell standard. Aims
to preserve comments and indentation in the Shell source code.

## Transperler Service
The Transperler Service is a simple backend server developed with Go and Gin. It
serves as a wrapper around the shell static analyser, [ShellCheck](https://github.com/koalaman/shellcheck), and the Perl 5
transpiler binary.

**Setup & Usage**

Install [shellcheck](https://github.com/koalaman/shellcheck) to `/usr/bin/shellcheck`.

To start the Transperler API locally, execute the following *from the project root*.
```bash
cd transpiler-service
docker build -t api .
docker run -p 8080:8080 -v $PWD:/app api
```

Alternatively to using Docker, run the following:
```bash
cd transpiler-service
go get .    # Fetch all third-party dependencies.
go run .    # Start the development server at port 8080.
```

To run HTTP tests, simply run `go test`.

**Endpoints**
The service exposes only two endpoints:
1. `POST /api/transpiler`
    - Input: `sh_source_code`.
        - `sh_source_code` must be fewer than 1000 lines or 50000 characters.
        - Assumes that the source code is valid, ie. that the source code has been validated through `POST /api/shellanalysis`.
    - Output: `{ pl_output: "..." }`.

2. `POST /api/shell-analysis`
    - Input: `sh_source_code`.
        - `sh_source_code` must be fewer than 1000 lines or 50000 characters.
    - Output: `{ status: "error" | "success", message: "..." }`.

## Transperler Client

The Transperler Client is a web frontend developed with Vue, Nuxt.js and
TypeScript.

**Setup & Usage**
From `client`, run the following:
```bash
yarn
yarn dev
```

## Deployment

The Transperler Client is deployed on Vercel. The Transperler Service is dockerised and can be deployed on AWS ECS or Google
Cloud Run, for example.
I am using NGINX as a reverse proxy to direct requests to the Docker container
for the service. Currently, deployment just involves running
`docker-compose up -d` or `nohup go run .`.
