export DOCKER_BUILDKIT=1

export COMPOSE_DOCKER_CLI_BUILD=1

OSSYSTEM=$(shell uname -s)
ifeq ($(OSSYSTEM),Linux)
  SED = sed -i
else
  SED = sed -i ""
endif

REGISTRY ?= ghcr.io/example
IMAGE ?= fastapi-template
TAG ?= $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo latest)
FULL_IMAGE := $(REGISTRY)/$(IMAGE):$(TAG)

.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make build        — build app image (variables: REGISTRY, IMAGE, TAG)"
	@echo "  make pull         — docker compose pull (tests stack)"
	@echo "  make down         — docker compose down (tests stack)"
	@echo "  make up           — run environment (down -> pull -> build -> up)"
	@echo "  make tests        — run tests stack and tests (option d=1 for detached)"
	@echo "  make tests_debug  — like tests, but starts only services without tests container"
	@echo "  make down_tests   — docker compose down for tests stack"
	@echo "  make mig          — create Alembic migration: make mig msg=\"init\""
	@echo "  make db_up        — apply all migrations up to head (alembic upgrade head)"
	@echo "  make lint         — run Ruff linter (uv run --with ruff)"
	@echo "  make ch           — add/update template in CHANGELOG.md"

.PHONY: build
build:
	docker build -f Dockerfile --target app -t $(FULL_IMAGE) .

.PHONY: pull
pull:
	docker compose -f tests/docker-compose.tests.yaml pull

.PHONY: down
down:
	docker compose -f tests/docker-compose.tests.yaml down -v --remove-orphans -t 0

.PHONY: up
up: down pull build
	docker compose -f tests/docker-compose.tests.yaml up


.PHONY: tests
tests: arg=${if ${d},-d,}
tests: down_tests
	docker compose -f tests/docker-compose.tests.yaml build
	docker compose -f tests/docker-compose.tests.yaml up ${arg}

.PHONY: tests_debug
tests_debug: arg=${if ${d},-d,}
tests_debug: down_tests
	docker compose -f tests/docker-compose.tests.yaml build
	docker compose -f tests/docker-compose.tests.yaml up postgres service redis tasks ${arg}

.PHONY: down_tests
down_tests:
	docker compose -f tests/docker-compose.tests.yaml down -v --remove-orphans -t 0

# Alembic
.PHONY: mig
mig: msg?=empty
mig: ## create Alembic migration: make mig msg="init" (autogenerate enabled by default)
	uv run --with alembic --with sqlalchemy alembic -c alembic.ini revision -m "${msg}" --autogenerate

.PHONY: db_up
db_up: ## apply migrations up to head
	uv run --with alembic --with sqlalchemy alembic -c alembic.ini upgrade head

.PHONY: lint
lint:
	uv run --with ruff ruff check .

.PHONY: ch
ch: header=\# Change Log
ch: branch=$(shell git rev-parse --abbrev-ref HEAD)
ch: issue=$(shell echo "${branch}" | grep -oE '[A-Za-z]+-[0-9]+' || echo "")
ch: url=https://youtrack.ubic.tech/issue/
ch: task_header=\#\# [$(if ${issue},[${branch}](${url}${issue}),${branch})]
ch: filename=CHANGELOG.md
ch:  ## adds a template with current branch and task link to CHANGELOG.md
	@if ! grep -qF "${task_header}" ${filename}; \
  	  then \
    	    echo "${header}" > temp_file; \
	    echo "${task_header} - $$(date +'%Y-%m-%d')" >> temp_file; \
	    echo "### Fix" >> temp_file; \
	    echo "- REPLACE_ME" >> temp_file; \
	    echo "### Add" >> temp_file; \
	    echo "- REPLACE_ME" >> temp_file; \
	    ${SED} 's/${header}//g' ${filename}; \
	    cat ${filename} >> temp_file; \
	    mv temp_file ${filename}; \
	    echo "ChangeLog template added"; \
  	  else \
  	    OLD_DATE=$$(grep -F "${task_header}" CHANGELOG.md | awk -F ' - ' '{print $$2}') && \
  	    OLD_TASK_HEADER="${task_header} - $${OLD_DATE}" && \
  	    ESCAPED_OLD=$$(printf '%s\n' "$$${OLD_TASK_HEADER}" | sed -e 's/[]\/$*.^[]/\\&/g') && \
  	    NEW_TASK_HEADER="${task_header} - $$(date +'%Y-%m-%d')" && \
   	    ESCAPED_NEW=$$(printf '%s\n' "$$${NEW_TASK_HEADER}" | sed -e 's/[]\/$*.^[]/\\&/g') && \
   	    ${SED} "s|$${ESCAPED_OLD}|$${ESCAPED_NEW}|" ${filename}; \
  	    echo "template already exists, updated date"; \
	fi;


format: ## Run ruff formatter (make format [FORMAT_PATH=<path>])
	@if [ -z "$(FORMAT_PATH)" ]; then \
		echo "Running ruff formatter for the whole project..."; \
		uv run --with ruff ruff format .; \
		uv run --with ruff ruff check --fix .; \
	else \
		echo "Running ruff formatter for $(FORMAT_PATH)..."; \
		uv run --with ruff ruff format $(FORMAT_PATH); \
		uv run --with ruff ruff check --fix $(FORMAT_PATH); \
	fi
