# NexaPay

Plateforme de traitement de paiements conçue comme un projet Java 25 / Spring Boot 4.1 de niveau production.

Le développement débute en **modular monolith** : PostgreSQL est la source de vérité des états transactionnels et financiers. Les priorités absolues sont l'idempotence des commandes financières, l'intégrité du ledger et l'isolation multi-tenant.

## État du projet

Niveau 0 — bootstrap et standards. Le build Maven multi-modules et le bootstrap Spring Boot sont prêts ; les cas d'usage métier commencent ensuite au niveau 1.

## Architecture

NexaPay est une application Spring Boot unique déployée depuis `apps/nexapay-monolith/`. Conformément à ADR-001, les bounded contexts métier — `merchant`, `payment`, `ledger`, `identity`, `outbox`, `notification` et `fraud` — sont des modules internes organisés par packages sous `dev.nexapay`.

`libs/` est réservé aux primitives et contrats réellement partagés, notamment un éventuel shared kernel minimal. Les domaines métier ne sont pas des bibliothèques partagées. Toute extraction en microservice exige une décision d’architecture documentée.

- `apps/nexapay-monolith/` : point d'entrée Spring Boot et bounded contexts internes sous `dev.nexapay`.
- `libs/` : réservé à d'éventuelles primitives ou contrats réellement partagés et stables ; aucun bounded context métier n'y est publié.
- `infra/` : Docker, Kubernetes et Terraform.
- `docs/` : ADR, architecture, API, sécurité, runbooks et preuves.
- `tests/` : tests end-to-end, de charge et de chaos.
- `observability/` : dashboards et alertes versionnés.

## Principes non négociables

- Les montants sont exprimés en unités mineures, jamais en flottants.
- Toute commande financière est idempotente.
- Le ledger est append-only et équilibré par transaction.
- Les secrets, données carte et données personnelles inutiles ne sont jamais versionnés ni journalisés.
- Kafka et les microservices sont introduits seulement quand une décision d'architecture le justifie.

## Références

- [Cahier des charges NexaPay](NexaPay_Cahier_des_Charges_Production_Grade.pdf)
- [ADR-001 — Modular monolith avant les microservices](docs/adr/ADR-001-modular-monolith.md)

## Quickstart

### Prérequis

- Java 25 ;
- Docker Compose ;
- GNU Make.

### Démarrer localement

Depuis la racine du dépôt :

```bash
make help
make infra-up
make test
make run
```

`make infra-up` démarre PostgreSQL. Par défaut, la base est accessible avec l’hôte `localhost`, le port `5432`, la base `nexapay`, l’utilisateur `nexapay` et le mot de passe `nexapay`. Ces identifiants sont exclusivement destinés au développement local.

Si le port `5432` est déjà utilisé, choisir un port hôte libre :

```bash
NEXAPAY_POSTGRES_PORT=5433 make infra-up
```

Dans ce cas, PostgreSQL est accessible sur `localhost:5433`.

Pour arrêter PostgreSQL sans supprimer ses données :

```bash
make infra-down
```

Les commandes disponibles sont listées par `make help`. `make infra-reset` supprime définitivement les données PostgreSQL locales.

### Alternatives directes

Le Makefile est le point d’entrée recommandé. Maven Wrapper reste accessible pour les besoins ponctuels :

```bash
./mvnw verify
./mvnw -pl apps/nexapay-monolith spring-boot:run
```
