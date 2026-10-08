.PHONY: init-db up down logs help check-env

-include .env
export

POSTGRES_HOST     ?= shared-postgres-db
POSTGRES_USER     ?= postgres
POSTGRES_PASSWORD ?=
EVOLUTION_DB_PASS ?=

help:
	@echo "Usage:"
	@echo "  make init-db  - Crea el usuario y base de datos de evolution"
	@echo "  make up       - Levanta los servicios"
	@echo "  make down     - Detiene los servicios"
	@echo "  make logs     - Muestra logs de todos los servicios"

check-env:
	@missing=""; \
	[ -z "$(POSTGRES_PASSWORD)" ] && missing="$$missing\n  - POSTGRES_PASSWORD"; \
	[ -z "$(EVOLUTION_DB_PASS)" ] && missing="$$missing\n  - EVOLUTION_DB_PASS"; \
	if [ -n "$$missing" ]; then \
		echo "ERROR: Las siguientes variables son requeridas pero no están en .env:"; \
		printf "$$missing\n"; \
		exit 1; \
	fi

init-db: check-env
	docker run --rm \
		--network shared-network \
		-e POSTGRES_HOST=$(POSTGRES_HOST) \
		-e POSTGRES_USER=$(POSTGRES_USER) \
		-e POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
		-e EVOLUTION_DB_PASS=$(EVOLUTION_DB_PASS) \
		-v $(PWD)/init-db.sh:/init-db.sh \
		postgres:16-alpine \
		bash /init-db.sh

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f
