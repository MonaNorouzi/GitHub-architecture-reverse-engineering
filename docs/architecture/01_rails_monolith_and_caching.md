# The Monolithic Core and Caching Infrastructure

## The Ruby on Rails Monolith
Despite its massive global scale, GitHub's architectural genesis—and still a significant portion of its contemporary core—is a majestic monolith built on the **Ruby on Rails** framework. This monolithic design handles the vast majority of synchronous HTTP requests, UI rendering, routing, and primary business logic.

The Rails application utilizes the Active Record ORM to interface with the sharded relational database layer. While microservices are trendy, the monolith provides GitHub with unparalleled developmental velocity, a unified codebase, and straightforward transactional integrity for core platform features.

## The Critical Caching Optimization Layer
A pure data-centric monolith directly querying a relational database cannot mathematically survive the read-heavy traffic of millions of concurrent developers. To prevent database saturation, GitHub employs an aggressive, multi-tiered caching architecture relying heavily on in-memory datastores like **Redis** and **Memcached**.

### Caching Modalities
1. **Markdown Rendering Cache:** Converting developer Markdown to HTML is CPU-intensive. Once rendered, the HTML string is aggressively cached in Memcached. Subsequent page loads bypass the Rails rendering engine entirely.
2. **Access Control & Permissions:** Verifying if a user has read/write access to a private repository occurs on almost every request. These authorization matrices are cached in low-latency Redis clusters to ensure $O(1)$ lookup times.
3. **Git Tree Caching:** Exploring the file structure of a repository via the UI relies on cached representations of Git Tree objects, sparing the underlying file servers from redundant I/O operations.

Cache invalidation is handled via Active Record callbacks, ensuring that when an entity is mutated, its corresponding cache keys are instantly expired.