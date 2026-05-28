# Pull Request State Transitions: A Transactional Lifecycle

## The Pull Request as a State Machine
In the context of GitHub's distributed architecture, a Pull Request (PR) is not merely a static UI element; it is a complex, asynchronous state machine. The lifecycle of a PR encompasses distributed coordination between the primary relational database, background background workers, and external CI/CD microservices.

## Phase 1: Instantiation and Pending States
When a developer initiates a PR, the API Gateway routes the payload to the monolithic core. A database transaction is executed to insert the baseline entity.
* **Initial State:** The database records the entity with `state: open` and `mergeable: null`. The `mergeable` field remains null because the operation of calculating Git tree differences is computationally expensive and cannot block the synchronous HTTP response.
* **Asynchronous Offloading:** The core system enqueues a background job to evaluate potential merge conflicts by traversing the Git DAG. Concurrently, a Webhook event (`pull_request`) is dispatched to the CI/CD pipeline.

## Phase 2: Asynchronous Resolution
While the user interacts with the UI, several state transitions occur in the background:
* **Mergeability Resolution:** The background worker completes the diff calculation. A write operation updates the database, transitioning `mergeable: null` to either `true` (clean) or `false` (conflict).
* **CI/CD Callbacks:** External systems (like GitHub Actions) execute their pipelines. Upon completion, they utilize an internal API to patch the commit status, transitioning it from `status: pending_ci` to `status: success` (or `failure`). This triggers cache invalidation for the UI layer to reflect the new state.

## Phase 3: The Terminal Merge Transaction
When a repository maintainer authorizes the merge, a critical, distributed transaction is orchestrated:
1. The Rails core instructs the lower-level Git file servers to execute a physical `git merge` operation.
2. Upon cryptographic confirmation from the file servers, a relational database transaction commits the final state.
3. The PR transitions to `state: merged`.
4. The underlying polymorphic Issue entity transitions to `state: closed`.
5. Finally, asynchronous notifications (emails, UI web-sockets) are broadcasted to the involved actors.