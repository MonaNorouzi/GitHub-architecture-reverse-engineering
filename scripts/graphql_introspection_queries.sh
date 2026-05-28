#!/bin/bash

# ==============================================================================
# Script Name: graphql_introspection_queries.sh
# Description: Shell script to execute GraphQL queries against the GitHub API v4
#              for the purpose of reverse-engineering the underlying relational 
#              database schema, focusing on Node/Edge relationships and 
#              Issue/PullRequest Polymorphism.
# ==============================================================================

# Ensure GitHub Personal Access Token (PAT) is set in the environment
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: GITHUB_TOKEN environment variable is not set."
  echo "Usage: export GITHUB_TOKEN='your_token_here' && ./graphql_introspection_queries.sh"
  exit 1
fi

GRAPHQL_ENDPOINT="https://api.github.com/graphql"

echo "----------------------------------------------------------------------"
echo "Executing Query 1: Graph Traversal (Nodes and Edges Analysis)"
echo "Objective: Reveal the data-centric architecture by querying the central"
echo "Repository node and its relational edges (PullRequests, Commits)."
echo "----------------------------------------------------------------------"

curl -s -X POST -H "Authorization: bearer $GITHUB_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "query": "query { repository(owner: \"octocat\", name: \"Hello-World\") { databaseId nameWithOwner pullRequests(first: 5) { edges { node { databaseId number state title commits(first: 1) { edges { node { commit { oid message } } } } } } } } }"
     }' $GRAPHQL_ENDPOINT | jq .

echo -e "\n\n----------------------------------------------------------------------"
echo "Executing Query 2: Single Table Inheritance (Polymorphism) Discovery"
echo "Objective: Demonstrate that Issues and Pull Requests share a unified ID"
echo "space by fetching generic Issue nodes and interrogating their specific"
echo "GraphQL __typename. This confirms the underlying STI database pattern."
echo "----------------------------------------------------------------------"

curl -s -X POST -H "Authorization: bearer $GITHUB_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "query": "query { repository(owner: \"octocat\", name: \"Hello-World\") { issues(first: 10, states: OPEN) { nodes { __typename databaseId number title ... on Issue { state } ... on PullRequest { mergeable headRefName } } } } }"
     }' $GRAPHQL_ENDPOINT | jq .

echo -e "\n\n----------------------------------------------------------------------"
echo "Executing Query 3: Git DAG Object Resolution"
echo "Objective: Query the underlying Git Tree and Blob objects directly via API,"
echo "bypassing the relational database to hit the Content-Addressable File System."
echo "----------------------------------------------------------------------"

curl -s -X POST -H "Authorization: bearer $GITHUB_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "query": "query { repository(owner: \"octocat\", name: \"Hello-World\") { object(expression: \"master:\") { ... on Tree { oid entries { name type oid } } } } }"
     }' $GRAPHQL_ENDPOINT | jq .