# Object-Relational Mapping: Polymorphism in Issues and Pull Requests

## The Dual Identity Conundrum
From a User Interface perspective, "Issues" and "Pull Requests" (PRs) appear as distinct functionalities. Issues are utilized for bug tracking and feature requests, whereas PRs represent proposed code mutations. However, reverse-engineering the database architecture reveals a sophisticated Object-Relational Mapping (ORM) optimization: **Polymorphism**.

## Single Table Inheritance (STI)
In the architectural underpinning of GitHub, every Pull Request is fundamentally an Issue. This design pattern closely mirrors Single Table Inheritance (STI) or a heavily optimized polymorphic association within the relational database schema.

### Shared ID Space and Core Attributes
If you observe a GitHub repository, you will notice that an Issue and a PR can never share the same numerical identifier. If Issue `#1` exists, the next PR created will invariably be `#2`. This occurs because both entities share a foundational base table (e.g., `issues_table`). Core metadata—such as the author ID, creation timestamp, tags, comments, and the open/closed state—are stored in this unified table.

### The Pull Request Extension
A Pull Request is merely a specialized extension of an Issue. When a PR is instantiated, the system creates the base Issue record, and subsequently generates an associative record in a secondary table (e.g., `pull_requests_table`). This specialized table encapsulates data exclusive to code modifications:
* `head_branch` and `base_branch` references.
* Pointers to the specific cryptographic Git Commit hashes.
* `mergeable_status` boolean flags.

This polymorphic architecture ensures DRY (Don't Repeat Yourself) principles at the database level, allowing unified search querying, commenting, and tagging mechanics across both concepts simultaneously.