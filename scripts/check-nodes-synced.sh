#!/bin/bash
# Check if all toponodes NPP are Connected and Node is Synced in clab-ai-fabric namespace
# Checks every 10 seconds, up to 60 seconds total

NAMESPACE="clab-ai-fabric"
RETRIES=10
SLEEP=15

# Check for dependencies
if ! command -v kubectl &>/dev/null; then
  echo "kubectl not found in PATH" >&2
  exit 2
fi
if ! command -v jq &>/dev/null; then
  echo "jq not found in PATH" >&2
  exit 2
fi

for attempt in $(seq 1 $RETRIES); do
  echo "[Attempt $attempt/$RETRIES] Checking node status..."
  # Get all toponodes as JSON
  nodes_json=$(kubectl get toponodes -n "$NAMESPACE" -o json)
  # Extract name, NPP, and Node fields
  not_ready=$(echo "$nodes_json" | jq -r '.items[] | select(.status["npp-state"] != "Connected" or .status["node-state"] != "Synced") | "- " + .metadata.name + ": NPP=" + (.status["npp-state"] // "<none>") + ", Node=" + (.status["node-state"] // "<none>")')

  if [[ -z "$not_ready" ]]; then
    echo "All nodes are NPP=Connected and Node=Synced."
    exit 0
  else
    echo "Nodes not ready:"
    echo "$not_ready"
    if [[ $attempt -lt $RETRIES ]]; then
      sleep $SLEEP
    fi
  fi
done

echo "Timeout: Not all nodes reached NPP=Connected and Node=Synced after $((RETRIES * SLEEP)) seconds."
exit 1 