# Database Discovery via GraphQL Introspection

## The Limitations of RESTful Architectures
Historically, GitHub relied on a REST API (v3) to expose data to developers. However, REST endpoints inherently flatten complex data structures, masking the true relational nature of the underlying persistence layer. To reverse-engineer the authentic data architecture, we turn to GitHub's GraphQL API (v4).

## Graph-Based Introspection
GraphQL provides a schema-driven, deeply hierarchical lens through which we can observe the database's structural paradigm. By analyzing the introspection schema, we uncover a highly interconnected, data-centric architecture conceptualized as a mathematical graph $G = (V, E)$.

### Entities as Nodes (Vertices)
In the GraphQL schema, primary database tables are represented as `Nodes`. The `Repository` node acts as a central gravitational body in this data model. It possesses distinct identifiers and scalar fields mapping directly to relational database columns (e.g., `repository_name`, `owner_id`).

### Relationships as Edges
The complex foreign-key constraints and join tables of GitHub's relational database (predominantly MySQL/Vitess) are exposed as `Edges`. An edge connecting a `User` node to a `Repository` node represents an ownership or collaborative relationship. Similarly, edges connect the `Repository` node to thousands of `Issue` and `Commit` nodes, confirming the platform's data-centric design where the codebase is the ultimate source of truth.

By traversing these edges in a single GraphQL query, a client dynamically constructs complex SQL `JOIN` operations under the hood, revealing the highly optimized, relational nature of GitHub's persistence layer.