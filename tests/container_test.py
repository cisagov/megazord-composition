#!/usr/bin/env pytest -vs
"""Tests for example container."""

# Standard Python Libraries
import time

# Third-Party Libraries
import dns.resolver

READY_MESSAGES = {
    "apache": "resuming normal operations",
    "coredns": "CoreDNS-",
    "cobalt": "Team server is up on",
}


def test_container_count(dockerc):
    """Verify the test composition and container."""
    # stopped parameter allows non-running containers in results
    assert (
        len(dockerc.containers(stopped=True)) == 3
    ), "Wrong number of containers were started."


def test_wait_for_ready_apache(apache_container):
    """Verify the apache container is running."""
    TIMEOUT = 30
    ready_message = READY_MESSAGES["apache"]
    for i in range(TIMEOUT):
        if ready_message in apache_container.logs().decode("utf-8"):
            break
        time.sleep(1)
    else:
        raise Exception(
            f"Container does not seem ready. "
            f"Expected {ready_message} in log within {TIMEOUT} seconds."
        )


def test_wait_for_ready_coredns(coredns_container):
    """Verify the coredns container is running."""
    TIMEOUT = 30
    ready_message = READY_MESSAGES["coredns"]
    for i in range(TIMEOUT):
        if ready_message in coredns_container.logs().decode("utf-8"):
            break
        time.sleep(1)
    else:
        raise Exception(
            f"Container does not seem ready.  "
            f"Expected {ready_message} in the log within {TIMEOUT} seconds."
        )


def test_dns_query(coredns_container):
    """Verify the coredns container is working."""
    resolver = dns.resolver.Resolver()
    resolver.nameservers = ["172.19.0.3"]

    try:
        resolver.query("google.com")
    except dns.resolver.NoNameservers as err:
        print(err)


def test_wait_for_ready_cobalt(cobalt_container):
    """Verify the cobalt strike container is running."""
    TIMEOUT = 20
    ready_message = READY_MESSAGES["cobalt"]
    for i in range(TIMEOUT):
        if ready_message in cobalt_container.logs().decode("utf-8"):
            break
        time.sleep(1)

    else:
        raise Exception(
            f"Container does not seem ready.  "
            f"Expected {ready_message} in the log within {TIMEOUT} seconds."
        )
