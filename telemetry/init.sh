#!/bin/bash

function check-required-binaries {
    local missing_binaries=()
    
    if ! command -v kubectl &> /dev/null; then
        missing_binaries+=("kubectl")
    fi
    
    if ! command -v helm &> /dev/null; then
        missing_binaries+=("helm")
    fi
    
    if [ ${#missing_binaries[@]} -gt 0 ]; then
        echo "Error: Required binaries not found: ${missing_binaries[*]}"
        echo "Please install the missing binaries before running this script."
        echo "  https://github.com/eda-labs/eda-telemetry-lab?tab=readme-ov-file#requirements"
        exit 1
    fi
}


indent_out() { sed 's/^/    /'; }

# Check required binaries before proceeding
check-required-binaries

# Term colors
GREEN="\033[0;32m"
RESET="\033[0m"

# k8s and cx namespace
# this is where the telemetry stack will be installed
# and in case of CX variant, where the nodes will be created
ST_STACK_NS=eda-telemetry

EDA_CORE_NS=eda-system

EDA_URL=${EDA_URL:-""} # e.g. https://my.eda.com or https://10.1.0.1:9443

# namespace where default EDA resources are
DEFAULT_USER_NS=eda



# Install helm chart
echo -e "${GREEN}--> Installing telemetry-stack helm chart...${RESET}"

proxy_var="${https_proxy:-$HTTPS_PROXY}"
if [[ -n "$proxy_var" ]]; then
    echo "Using proxy for grafana deployment: $proxy_var"
    noproxy="localhost\,127.0.0.1\,.local\,.internal\,.svc"

    helm install telemetry-stack ./charts/telemetry-stack \
    --set https_proxy="$proxy_var" \
    --set no_proxy="$noproxy" \
    --set eda_url="${EDA_URL}" \
    --create-namespace -n ${ST_STACK_NS} | indent_out
else
    helm install telemetry-stack ./charts/telemetry-stack \
    --set eda_url="${EDA_URL}" \
    --create-namespace -n ${ST_STACK_NS} | indent_out
fi



echo -e "${GREEN}--> Waiting for alloy service be ready...${RESET}"
echo "Note: First-time deployment may take several minutes while downloading container images." | indent_out
ALLOY_IP=""
RETRY_COUNT=0
MAX_RETRIES=60  # Increased from 30 to 60 for initial deployments

# First, wait for the alloy pod to be ready
echo "Checking alloy pod status..." | indent_out
kubectl wait --for=condition=ready pod -l app=alloy -n ${ST_STACK_NS} --timeout=600s | indent_out

# Get external alloy IP when in Containerlab mode
if [[ "$IS_CX" != "true" ]]; then
    # Now wait for the service to get an external IP
    while [ -z "$ALLOY_IP" ] && [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        ALLOY_IP=$(kubectl get svc alloy -n ${ST_STACK_NS} -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
        if [ -z "$ALLOY_IP" ]; then
            echo "Waiting for external IP... (attempt $((RETRY_COUNT+1))/$MAX_RETRIES)"
            sleep 10
            RETRY_COUNT=$((RETRY_COUNT+1))
        fi
    done
    if [ -z "$ALLOY_IP" ]; then
        echo "Error: Failed to get alloy external IP after $MAX_RETRIES attempts"
        exit 1
    fi

    echo "Got alloy IP: $ALLOY_IP"


    SYSLOG_CONFIG_FILE="manifests/common/0026_syslog.yaml"


    if [[ ! -f "$SYSLOG_CONFIG_FILE" ]]; then
        echo "Error: $SYSLOG_CONFIG_FILE not found."
        exit 1
    fi

    # Update syslog.yaml with alloy IP when in Containerlab mode
    # CX mode uses the internal DNS name
    sed -i.bak -E "s/(\"host\": \")[^\"]+(\",)/\1${ALLOY_IP}\2/" "$SYSLOG_CONFIG_FILE"
    echo "--> Updated syslog host to '$ALLOY_IP' in $SYSLOG_CONFIG_FILE"

    # Fetch EDA ext domain name from engine config
    EDA_API=$(uv run ./scripts/get_eda_api.py)

    # Ensure input is not empty
    if [[ -z "$EDA_API" ]]; then
    echo "No input provided. Exiting."
    exit 1
    fi

    # save EDA API address to a file
    echo "$EDA_API" > .eda_api_address

fi


# Install apps and EDA resources
echo -e "${GREEN}--> Installing Prometheus and Kafka exporter EDA apps...${RESET}"
kubectl apply -f ./manifests/0000_apps.yaml | indent_out
kubectl -n ${EDA_CORE_NS} wait --for=jsonpath='{.status.result}'=Completed appinstallers.appstore.eda.nokia.com --all --timeout=300s | indent_out

echo -e "${GREEN}--> Creating EDA resources...${RESET}"
kubectl apply -f ./manifests/common | indent_out



echo -e "${GREEN}--> Waiting for Grafana deployment to be available...${RESET}"
kubectl -n ${ST_STACK_NS} wait --for=condition=available deployment/grafana --timeout=300s | indent_out

# Show connection details
echo ""
echo -e "${GREEN}--> Access Grafana: ${EDA_URL}/core/httpproxy/v1/grafana/d/Telemetry_Playground/${RESET}"
echo -e "${GREEN}--> Access Prometheus: ${EDA_URL}/core/httpproxy/v1/prometheus/query${RESET}"

if [[ "$IS_CX" == "true" ]]; then
    echo -e "${GREEN}--> Access Control Panel: ${EDA_URL}/core/httpproxy/v1/control-panel/${RESET}"
fi
