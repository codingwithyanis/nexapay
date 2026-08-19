# ALL-10 — Environnement Docker local de démarrage

## Vue d’ensemble

Fournir un environnement PostgreSQL local, reproductible et démarrable avec Docker Compose pour les développements NexaPay.

## Objectifs

- Versionner `infra/docker/docker-compose.yml`.
- Démarrer PostgreSQL localement avec une commande Docker Compose.
- Conserver les données dans un volume Docker nommé.
- Exposer un healthcheck afin que les futurs consommateurs puissent attendre la disponibilité de PostgreSQL.
- Documenter le démarrage, l’arrêt et la réinitialisation locale.

## Hors périmètre

- Démarrer l’application Spring Boot dans Docker.
- Ajouter Redis, Kafka, un fournisseur de paiement ou tout autre service.
- Ajouter les migrations Flyway ou connecter l’application à la base.
- Versionner des identifiants, mots de passe réels ou données sensibles.

## Configuration proposée

Le compose `infra/docker/docker-compose.yml` définit un seul service `postgres` fondé sur une image PostgreSQL officiellement maintenue. Il utilise :

- une base, un utilisateur et un mot de passe de développement non sensibles ;
- un port PostgreSQL local exposé, configurable avec `NEXAPAY_POSTGRES_PORT` (valeur par défaut : `5432`) ;
- un volume nommé pour les données ;
- `pg_isready` comme healthcheck.

Les valeurs pourront être remplacées localement au moyen de variables d’environnement Docker Compose. Le dépôt ne contiendra aucun fichier `.env` réel.

## Documentation attendue

Le README décrira :

1. le prérequis Docker Compose ;
2. la commande de démarrage depuis `infra/docker/` ;
3. la commande d’arrêt ;
4. la commande de réinitialisation du volume ;
5. les paramètres de connexion locaux.

## Critères d’acceptation

- `infra/docker/docker-compose.yml` est versionné.
- PostgreSQL démarre avec `docker compose up -d` depuis `infra/docker/`.
- Le service devient sain après son initialisation.
- Les données persistent entre deux redémarrages ordinaires.
- Le démarrage est documenté.
- Aucun secret ou donnée sensible n’est commité.

## Étapes d’implémentation

1. Ajouter le compose PostgreSQL et son healthcheck.
2. Ajouter la section de démarrage local dans le README.
3. Valider la syntaxe du compose et le cycle de démarrage/arrêt local.
