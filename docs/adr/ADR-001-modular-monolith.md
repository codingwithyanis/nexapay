# ADR-001 — Modular monolith avant les microservices

- Statut : Accepté
- Date : 2026-08-18
- Issue Linear : ALL-8

## Contexte

NexaPay traite des opérations financières pour lesquelles l'intégrité, l'idempotence, les transitions d'état et l'audit priment sur l'ajout précoce de technologies distribuées. Au démarrage, les frontières de données, les volumes de charge et les besoins d'autonomie de déploiement ne sont pas encore suffisamment stabilisés pour justifier des microservices.

Le cahier des charges impose une progression explicite : maîtriser d'abord les garanties transactionnelles locales, puis extraire des services uniquement lorsqu'une décision d'architecture le justifie.

## Décision

NexaPay démarre comme un **modular monolith** : une seule application Spring Boot déployable dans `apps/nexapay-monolith` et une seule source de vérité transactionnelle PostgreSQL.

Les bounded contexts métier sont des modules internes de cette application :

- `merchant` ;
- `payment` ;
- `ledger` ;
- `identity` ;
- `outbox` ;
- `notification` ;
- `fraud`.

Ils seront organisés par packages métier sous `dev.nexapay`, avec Spring Modulith pour vérifier les dépendances et produire une documentation de modularité. Chaque module expose une façade publique limitée ; les packages d'implémentation et les tables privées ne sont pas accessibles directement aux autres modules.

Le dossier `libs/` ne contient que des contrats ou primitives réellement partagés et stables. Il ne doit pas contenir un bounded context métier ni devenir un contournement aux frontières de modules. La structure Maven actuelle devra donc être simplifiée avant le Niveau 1 : les modules métier seront intégrés à `nexapay-monolith` et seul un éventuel `shared-kernel` justifié restera dans `libs/`.

Les événements de domaine locaux ne constituent pas encore des événements Kafka. Kafka, Redis et les appels réseau inter-services ne sont introduits qu'aux niveaux prévus par la roadmap et par ADR.

## Alternatives considérées

### Microservices dès le démarrage

Rejeté. Cette option introduirait prématurément réseau, observabilité distribuée, cohérence éventuelle, ownership de bases, déploiements et coûts d'exploitation. Elle détournerait l'effort des invariants financiers fondamentaux.

### Monolithe sans frontières explicites

Rejeté. Une séparation uniquement par couches techniques rendrait les dépendances métier opaques et compliquerait une extraction future. Les frontières de modules doivent être visibles et testables dès le départ.

### Bounded contexts métier publiés comme bibliothèques Maven dans `libs/`

Rejeté. Cette organisation suggère des composants partagés alors qu'ils sont propriétaires de leur domaine. Elle affaiblit la notion de responsabilité et contredit l'arborescence de référence, où `apps/` accueille le monolithe puis les applications extraites.

## Conséquences

### Positives

- Les changements de paiement, remboursement et ledger restent transactionnels localement.
- Les tests d'intégration et de concurrence sont plus rapides à écrire et à diagnostiquer.
- Les frontières métier sont établies avant toute extraction.
- L'application reste simple à déployer et à observer au Niveau 0 et au Niveau 1.

### Contraintes

- Les dépendances entre modules doivent être contrôlées par Spring Modulith et des tests d'architecture.
- Un module ne lit jamais directement les tables privées d'un autre module.
- Le shared kernel reste minimal afin de ne pas devenir un couplage transversal.
- Une extraction future exige une migration de données et de contrats explicitement planifiée.

## Critères d'extraction future

Un module ne devient un microservice qu'après ADR démontrant que les bénéfices dépassent les coûts distribués, avec au minimum :

1. un profil de charge ou de scalabilité distinct ;
2. un besoin avéré d'isolation de panne ;
3. une frontière d'ownership des données stable ;
4. un besoin crédible de cycle de livraison indépendant ;
5. des contrats synchrones et asynchrones versionnés ;
6. une stratégie de cohérence, d'observabilité, de sécurité et d'exploitation démontrée.

