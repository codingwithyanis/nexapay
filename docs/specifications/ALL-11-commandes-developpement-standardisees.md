# ALL-11 — Commandes de développement standardisées

## Vue d’ensemble

Fournir un point d’entrée unique, versionné et reproductible pour les commandes locales récurrentes de NexaPay.

## Objectifs

- Ajouter un `Makefile` à la racine du dépôt.
- Standardiser le build, les tests et le lancement local de l’application.
- Standardiser le cycle de vie du PostgreSQL local défini dans `infra/docker/`.
- Documenter les commandes disponibles.

## Hors périmètre

- Introduire Taskfile ou un autre gestionnaire de tâches.
- Conteneuriser l’application Spring Boot.
- Ajouter des commandes de déploiement, Kubernetes ou Terraform.
- Modifier la configuration Maven ou Docker Compose existante.

## Commandes proposées

| Commande | Comportement |
| --- | --- |
| `make build` | Exécute `./mvnw --batch-mode --no-transfer-progress package -DskipTests`. |
| `make test` | Exécute `./mvnw --batch-mode --no-transfer-progress verify`. |
| `make run` | Lance l’application avec Maven Wrapper. |
| `make infra-up` | Démarre PostgreSQL depuis `infra/docker/`. |
| `make infra-down` | Arrête PostgreSQL sans supprimer ses données. |
| `make infra-logs` | Suit les logs du service PostgreSQL. |
| `make infra-reset` | Supprime explicitement le conteneur et le volume PostgreSQL locaux. |
| `make help` | Affiche la liste des commandes et leur description. |

## Contraintes

- Le Makefile s’appuie sur le Maven Wrapper, jamais sur une installation Maven système.
- Les commandes Docker ciblent explicitement `infra/docker/docker-compose.yml` afin d’être exécutables depuis la racine.
- Le port hôte PostgreSQL est configurable avec `NEXAPAY_POSTGRES_PORT` et vaut `5432` par défaut.
- `infra-reset` est destructive et doit être clairement signalée dans l’aide et la documentation.
- Aucune variable sensible ne doit être introduite.

## Documentation attendue

Le README indiquera les prérequis : Java 25, Docker Compose pour les commandes d’infrastructure, et GNU Make. Il présentera `make help` comme point d’entrée principal.

## Critères d’acceptation

- Les commandes sont versionnées et documentées.
- Le build et les tests sont accessibles avec une commande chacun.
- Les commandes sont reproductibles depuis la racine du dépôt.
- La syntaxe du Makefile est vérifiable sans exécuter de commande destructive.

## Étapes d’implémentation

1. Ajouter le Makefile et les cibles documentées.
2. Référencer les commandes dans le README.
3. Vérifier l’aide et les commandes non destructives ; démarrer puis arrêter PostgreSQL avec les cibles d’infrastructure.
4. Vérifier le démarrage avec un port hôte alternatif déjà documenté.
