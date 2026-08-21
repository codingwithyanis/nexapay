# NexaPay

Plateforme de traitement de paiements conçue comme un projet Java 25 / Spring Boot 4.1 de niveau production.

Le développement débute en **modular monolith** : PostgreSQL est la source de vérité des états transactionnels et financiers. Les priorités absolues sont l'idempotence des commandes financières, l'intégrité du ledger et l'isolation multi-tenant.

## État du projet

Niveau 0 — bootstrap et standards. Le build Maven multi-modules et le bootstrap Spring Boot sont prêts ; les cas d'usage métier commencent ensuite au niveau 1.

## Organisation

- `apps/nexapay-monolith/` : point d'entrée Spring Boot et bounded contexts internes sous `dev.nexapay`.
- `libs/` : réservé à d'éventuelles primitives ou contrats réellement partagés et stables ; aucun bounded context métier n'y est publié.
- `infra/` : Docker, Kubernetes et Terraform.
- `docs/` : documentation d'architecture, ADR, API, sécurité, runbooks et preuves.
- `tests/` : tests end-to-end, de charge et de chaos.
- `observability/` : dashboards et alertes versionnés.

## Principes non négociables

- Les montants sont exprimés en unités mineures, jamais en flottants.
- Toute commande financière est idempotente.
- Le ledger est append-only et équilibré par transaction.
- Les secrets, données carte et données personnelles inutiles ne sont jamais versionnés ni journalisés.
- Kafka et les microservices sont introduits seulement quand une décision d'architecture le justifie.

Consulter le cahier des charges pour la spécification complète : `NexaPay_Cahier_des_Charges_Production_Grade.pdf`.

## Démarrage

Les commandes de développement sont disponibles depuis la racine du dépôt :

```bash
make help
```

Le Makefile requiert GNU Make, Java 25 et, pour les commandes d'infrastructure, Docker Compose.

Les commandes Maven restent aussi accessibles directement :

```bash
./mvnw verify
./mvnw -pl apps/nexapay-monolith spring-boot:run
```

### PostgreSQL local

Un PostgreSQL local est disponible pour les prochaines étapes de développement. Il est réservé au poste de développement : les identifiants ci-dessous sont publics et ne doivent jamais être réutilisés hors de cet environnement.

```bash
cd infra/docker
docker compose up -d
docker compose ps
```

Paramètres de connexion locaux : hôte `localhost`, port `5432`, base `nexapay`, utilisateur `nexapay` et mot de passe `nexapay`.

Si le port `5432` est déjà utilisé, choisir un port hôte libre sans modifier le compose :

```bash
NEXAPAY_POSTGRES_PORT=5433 make infra-up
```

Dans cet exemple, la base reste accessible sur `localhost:5433`.

Pour arrêter le service sans supprimer ses données :

```bash
docker compose down
```

Pour consulter les logs :

```bash
docker compose logs -f postgres
```

Pour supprimer définitivement les données locales et repartir d'une base vide :

```bash
docker compose down -v
```

Depuis la racine du dépôt, les mêmes opérations sont disponibles avec `make infra-up`, `make infra-down`, `make infra-logs` et `make infra-reset`. Cette dernière commande supprime définitivement les données PostgreSQL locales.
