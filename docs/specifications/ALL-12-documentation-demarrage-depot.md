# ALL-12 — Documentation de démarrage du dépôt

## Vue d’ensemble

Finaliser le README racine afin qu’un développeur puisse comprendre NexaPay, préparer son environnement local et exécuter les premières commandes sans consulter le code source.

## Objectifs

- Expliquer la vision de NexaPay et ses garanties métier essentielles.
- Présenter brièvement l’architecture du modular monolith, conformément à ADR-001.
- Lister les prérequis de développement local.
- Fournir un quickstart reproductible fondé sur le Makefile, Maven Wrapper et Docker Compose.
- Rendre facilement accessibles le cahier des charges et l’ADR-001.

## Hors périmètre

- Documenter les API métier, les décisions de sécurité détaillées ou les procédures d’exploitation.
- Modifier le code Java, Maven, Docker Compose ou le Makefile.
- Créer une documentation de déploiement cloud ou Kubernetes.

## Architecture à documenter

NexaPay est un modular monolith déployé comme une application Spring Boot unique dans `apps/nexapay-monolith/`. Les bounded contexts sont des packages internes de cette application, notamment `merchant`, `payment`, `ledger`, `identity`, `outbox`, `notification` et `fraud`.

`libs/` est réservé aux primitives ou contrats réellement partagés, en particulier `nexapay-shared-kernel`. Il ne contient pas les domaines métier comme unités de déploiement. Toute évolution vers des microservices nécessite une décision d’architecture documentée.

## Quickstart attendu

1. Installer Java 25, Docker Compose et GNU Make.
2. Cloner le dépôt et exécuter `make help`.
3. Démarrer PostgreSQL avec `make infra-up`.
4. Vérifier le build et les tests avec `make test`.
5. Lancer l’application avec `make run`.
6. Arrêter l’infrastructure avec `make infra-down`.

Le README indique également l’alternative `NEXAPAY_POSTGRES_PORT=5433 make infra-up` lorsqu’un port local est occupé.

## Liens attendus

- Le cahier des charges `NexaPay_Cahier_des_Charges_Production_Grade.pdf`.
- `docs/adr/ADR-001-modular-monolith.md`.
- Les commandes `make help` et la configuration Docker locale.

## Critères d’acceptation

- La vision et l’architecture courte sont présentes et conformes à ADR-001.
- Java 25 est indiqué explicitement comme prérequis.
- Le quickstart Maven est accessible par les commandes standardisées.
- Le cahier des charges et l’ADR-001 sont liés depuis le README.
- Les instructions ne requièrent aucun secret.

## Étapes d’implémentation

1. Synchroniser la section d’architecture du README avec ADR-001.
2. Réorganiser le démarrage autour du quickstart Makefile.
3. Ajouter les liens de référence et vérifier les commandes et chemins documentés.
