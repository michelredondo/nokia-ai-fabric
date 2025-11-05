#!/usr/bin/env python
"""
This script retrieves the external domain name and httpsPort from the EDA EngineConfig
and resolves the domain to an IP address, returning both values.
"""

import socket
import subprocess
from typing import Optional


def get_eda_ext_domain() -> str:
    cmd = [
        "kubectl",
        "-n",
        "eda-system",
        "get",
        "engineconfigs/engine-config",
        "-o",
        "jsonpath={.spec.cluster.external.domainName}",
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout.strip()


def get_eda_https_port() -> str:
    cmd = [
        "kubectl",
        "-n",
        "eda-system",
        "get",
        "engineconfigs/engine-config",
        "-o",
        "jsonpath={.spec.cluster.external.httpsPort}",
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout.strip()


def is_ip_address(input: str) -> bool:
    try:
        socket.inet_aton(input)
        return True
    except socket.error:
        return False


def resolve_domain(domain: str) -> Optional[str]:
    try:
        if is_ip_address(domain):
            return domain
        return socket.gethostbyname(domain)
    except socket.gaierror:
        return None


def get_ip_and_port():
    ext_domain = get_eda_ext_domain()
    https_port = get_eda_https_port()

    # Resolve the domain to an IP address
    if is_ip_address(ext_domain):
        resolved_ip = ext_domain
    else:
        resolved_ip = resolve_domain(ext_domain)

    # Return both resolved IP and httpsPort as separate variables
    return resolved_ip, https_port


def main():
    resolved_ip, https_port = get_ip_and_port()

    # Print or use both variables as needed
    print(f"{resolved_ip}:{https_port}")


if __name__ == "__main__":
    main()
