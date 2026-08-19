.DEFAULT_GOAL := help

MVNW := ./mvnw
DOCKER_COMPOSE := docker compose -f infra/docker/docker-compose.yml
NEXAPAY_POSTGRES_PORT ?= 5432

export NEXAPAY_POSTGRES_PORT

.PHONY: build test run infra-up infra-down infra-logs infra-reset help

build:
	$(MVNW) --batch-mode --no-transfer-progress package -DskipTests

test:
	$(MVNW) --batch-mode --no-transfer-progress verify

run:
	$(MVNW) -pl apps/nexapay-monolith spring-boot:run

infra-up:
	$(DOCKER_COMPOSE) up -d

infra-down:
	$(DOCKER_COMPOSE) down

infra-logs:
	$(DOCKER_COMPOSE) logs -f postgres

infra-reset:
	@printf '%s\n' 'Attention : cette commande supprime définitivement les données PostgreSQL locales.'
	$(DOCKER_COMPOSE) down --volumes

help:
	@printf '%s\n' \
		'Commandes de développement NexaPay :' \
		'  make build       Compile et package sans exécuter les tests.' \
		'  make test        Compile et exécute la suite de vérification Maven.' \
		'  make run         Lance l’application Spring Boot localement.' \
		'  make infra-up    Démarre PostgreSQL local.' \
		'  make infra-down  Arrête PostgreSQL sans supprimer ses données.' \
		'  make infra-logs  Suit les logs PostgreSQL.' \
		'  make infra-reset Supprime définitivement les données PostgreSQL locales.' \
		'  make help        Affiche cette aide.' \
		'' \
		'Port PostgreSQL hôte par défaut : 5432. Pour le modifier : NEXAPAY_POSTGRES_PORT=5433 make infra-up'
