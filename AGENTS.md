# NexaPay — Instructions agents

## Contexte produit

NexaPay est une plateforme de traitement de paiements conçue comme un projet de démonstration production-grade. Elle permet aux marchands d'intégrer une API unique pour créer et suivre des Payment Intents, confirmer des paiements, effectuer des remboursements, recevoir des webhooks et consulter un historique financier auditable.

Le cahier des charges de référence est `NexaPay_Cahier_des_Charges_Production_Grade.pdf`. Le README en est un résumé ; en cas de divergence, le cahier des charges et les ADR validés prévalent.

### Périmètre fonctionnel

- Onboarding et cycle de vie des marchands ; clés API, scopes et endpoints webhook.
- Payment Intent, confirmation, autorisation/capture et remboursements partiels ou totaux.
- Intégration provider via une abstraction, Stripe sandbox et MockProvider.
- Webhooks entrants signés et dédupliqués ; webhooks sortants signés, avec retry et DLQ.
- Ledger simplifié à double entrée, append-only, audit, recherche et réconciliation.
- Évaluation de fraude temps réel avec un modèle pré-entraîné versionné.

Hors périmètre initial : stockage de numéros de carte ou CVV, acquisition bancaire réelle, chargebacks complets, devises/treasury avancés, abonnements et application mobile grand public.

### Invariants métier et sécurité

- PostgreSQL est l'unique source de vérité transactionnelle et financière ; Redis et Kafka ne le remplacent jamais.
- Tout montant est un entier en unités mineures avec une devise explicite ; `float` et `double` sont interdits.
- Toute commande financière est idempotente dans le périmètre d'un marchand, à partir d'une `Idempotency-Key` et d'un fingerprint de requête.
- Aucun double débit, double écriture de ledger ou sur-remboursement ne doit être possible, y compris sous concurrence ou retry.
- Le ledger est équilibré par transaction, immuable après commit et corrigé uniquement par écritures compensatoires.
- Les états de paiement sont monotones : un paiement réussi ne régresse pas ; les événements provider tardifs ou dupliqués ne doivent pas écraser un état avancé.
- L'isolation multi-tenant est obligatoire : une identité marchand ne peut accéder à aucune ressource d'un autre marchand.
- Les clés API sont hashées, limitées par scopes, révocables et rotatives ; aucun secret, token, numéro de carte ou PII inutile ne doit être commité ou journalisé.

### Architecture et exploitation

- L'application commence et reste un modular monolith ; les modules métier communiquent par interfaces explicites et ne lisent pas directement les tables privées des autres modules.
- Les événements de domaine locaux et les événements Kafka sont distincts. Kafka arrive avec l'outbox transactionnelle ; les consumers sont idempotents, avec retry, DLQ et schémas versionnés.
- Toute dépendance externe est lente et faillible : timeout explicite, retry uniquement sûr, circuit breaker/bulkhead si pertinent, et comportement de repli documenté.
- Les API sont versionnées sous `/v1`, utilisent JSON UTF-8, des identifiants opaques préfixés, des Problem Details et un `traceId` corrélé.
- Toute fonctionnalité importante doit être testable, observable (métriques, logs structurés, traces) et documentée ; les migrations restent backward compatibles lorsque des données sont affectées.

### Roadmap

- Niveau 0 : bootstrap, standards, CI, Docker local, README et ADR.
- Niveau 1 : modular monolith, Merchant, Payment Intent, REST, validation, erreurs, Flyway, PostgreSQL et tests.
- Niveau 2 : transactions, concurrence, idempotence durable, remboursements et performances SQL.
- Niveau 3 : provider de paiement, Stripe sandbox, MockProvider, state machine et webhooks entrants.
- Niveau 4 : OIDC/JWT, RBAC, API keys, scopes, audit et rate limiting.
- Niveau 5 : ledger double entrée, invariants et réconciliation.
- Niveau 6 : outbox, Kafka, consumers idempotents, retry/DLQ et contrats versionnés.
- Niveaux 7 à 14 : extraction conditionnée par ADR, résilience Redis, fraude ML, observabilité, performance/chaos, cloud/Kubernetes, hardening production et livraison portfolio.

Chaque niveau se termine par des tests reproductibles, une démonstration, une note de conception ou ADR si nécessaire, une documentation à jour et un tag de version. Les issues Linear du projet NexaPay constituent le découpage de référence par niveau.

## Stack

- Java 25, Spring Boot 4.1, Maven multi-modules.
- Le système reste un modular monolith jusqu'à décision documentée contraire.

## Règles essentielles

- PostgreSQL est la source de vérité des données transactionnelles et financières.
- Les montants utilisent des unités mineures entières ; jamais `float` ou `double`.
- Toute commande financière doit être idempotente.
- Ne jamais commiter de secrets, données carte ou données sensibles dans les logs.
- Ajouter ou adapter les tests nécessaires à chaque comportement métier.
- Créer un ADR dans `docs/adr/` pour toute décision architecturale structurante.

## Langue

- Les commits, pull requests et issues sont rédigés en français.
- Les commentaires de code et les messages de logs sont rédigés en français.
- Le code reste en anglais : identifiants, classes, méthodes, packages, fichiers et contrats d'API.

## Skills

- Avant de rédiger ou modifier du code, consulter et appliquer le skill disponible le plus pertinent pour la tâche.
- Pour toute évolution Spring Boot, consulter et appliquer les recommandations de `spring-boot-best-practices.md` avant de modifier le code.

## Workflow Git et Linear

- Linear est la source de vérité du backlog. Chaque branche et pull request correspond à une seule issue Linear.
- Utiliser l'identifiant réellement attribué par Linear ; ne jamais inventer ou laisser un placeholder tel que `NEX-1`.
- Nommer les branches selon le format `<IDENTIFIANT_LINEAR>/<type>-<objectif-concret-en-français>`.
  Exemple : `ALL-42/ci-verification-maven-quality-gates`.
- Les commits suivent Conventional Commits, avec un message français et l'identifiant Linear : `ci: ajouter la vérification Maven et les quality gates (ALL-42)`.
- Le titre de la pull request commence par l'identifiant Linear et décrit le résultat livré : `ALL-42 — Ajouter la vérification Maven et les quality gates`.
- Éviter les noms vagues tels que `setup`, `update`, `fix`, `test` ou `work` sans préciser le périmètre livré.
