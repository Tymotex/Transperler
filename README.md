# Transperler 🦪🠺⚪
A transpiler client (developed with Vue, Nuxt.js and TypeScript), and API (developed with Go and Gin),
that wraps around a transpiler written in Perl 5 that maps POSIX shell scripts to their equivalent Perl 5 scripts. Supports most
of the control structures and builtin commands in the POSIX Shell standard. Aims
to preserve comments and indentation in the Shell source code.

To start the Transperler API locally, execute the following from the project root.
```bash
docker-compose build
docker-compose up -d    # The API will be listening on port 3456 by default.

# To tear down the service, run:
docker-compose down   
```

## Transperler Service
The Transperler Service is a simple backend server developed with Go and Gin. It
serves as a wrapper around the shell static analyser, [ShellCheck](https://github.com/koalaman/shellcheck), and the Perl 5
transpiler binary.

**Setup & Usage**
From `transperler-service`, run the following:
```bash
go get .    # Fetch all third-party dependencies.
go run .    # Start the development server at port 3456.
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

The Transperler Client's deployment to GitHub Pages is handled automatically
on pushes/merges to `master` by a GitHub Actions workflow.

The Transperler Service is dockerised and can be deployed on AWS ECS or Google
Cloud Run, for example. In my case, I've deployed the service on a Linux VM 
from [Vultr](https://www.vultr.com/) and have set up NGINX as a reverse proxy to
direct requests to the Docker container for the service. Currently, deployment
just involves running `docker-compose up -d`.
