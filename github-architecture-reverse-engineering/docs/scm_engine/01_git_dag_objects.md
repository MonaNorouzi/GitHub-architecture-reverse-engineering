# The Git Engine: Directed Acyclic Graphs (DAG) and Object Storage

## Introduction to the Content-Addressable File System
At the core of GitHub's Software Configuration Management (SCM) capabilities lies the Git engine, which fundamentally operates not as a traditional file system, but as a **Content-Addressable File System**. In this paradigm, data is stored and retrieved based on cryptographic hashes of its content rather than its explicit file name or directory path. This ensures absolute data integrity and native deduplication.

## The Tripartite Object Model
The state of any repository at a given point in time is mathematically represented as a **Directed Acyclic Graph (DAG)**. The vertices (nodes) of this graph consist of three primary primitive objects:

### 1. Blob Objects (Content)
A Blob (Binary Large Object) represents the raw content of a file. When a file is modified and tracked, Git compresses the content, computes a highly collision-resistant `SHA-1` cryptographic hash (acting as the object ID), and stores it. Crucially, Blobs contain zero metadata—no file names, no timestamps, and no author information. If ten identical files exist across different directories, only a single Blob is persisted on disk, optimizing storage efficiency.

### 2. Tree Objects (Structure)
To reconstruct a project's directory hierarchy, the system utilizes Tree objects. A Tree functions analogously to a directory in a standard OS. It encapsulates a list of pointers (SHA-1 hashes) mapping to Blobs (files) or other sub-Trees (sub-directories), alongside structural metadata such as file names and POSIX access permissions. 

### 3. Commit Objects (Snapshots)
A Commit object serves as an immutable snapshot of the repository's state at a specific temporal coordinate. It contains:
* A definitive pointer to the root Tree object.
* Cryptographic pointers to parent Commit(s), forming the chronological lineage of the DAG.
* Semantic metadata, including the author, committer, timestamp, and commit message.

## Algorithmic Delta Calculation
Through this architecture, the task of identifying changes—a core SCM requirement—is reduced to algorithmic graph traversal. Calculating a "diff" does not require scanning disk files; rather, it involves mathematically comparing the SHA-1 hashes of two Tree objects within memory, providing a highly performant, computationally inexpensive operation.