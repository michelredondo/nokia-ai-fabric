#!/bin/bash

NAMESPACE="ai-fabric-be"
PATCH='{"spec":{"encapType":"dot1q"}}'
LABEL_KEY="eda.nokia.com/role"
LABEL_VALUE="edge"

echo "Fetching interfaces in namespace: $NAMESPACE and filtering for label '$SKIP_LABEL_KEY=$SKIP_LABEL_VALUE'..."


interfaces_to_patch=$(kubectl -n "$NAMESPACE" get interface -o json | \
  #jq -r ".items[] | select(.metadata.labels.\"$LABEL_KEY\" == \"$LABEL_VALUE\" or .metadata.labels.\"$LABEL_KEY\" == null) | .metadata.name")
  jq -r ".items[] | select(.metadata.labels.\"$LABEL_KEY\" == \"$LABEL_VALUE\" ) | .metadata.name")

if [ -z "$interfaces_to_patch" ]; then
  echo "No interfaces found to patch after filtering."
  exit 0
fi

for intf in $interfaces_to_patch; do
  echo "Patching interface: $intf"
    kubectl -n "$NAMESPACE" patch interface "$intf" --type=merge -p "$PATCH"

done

echo "Patching process complete."