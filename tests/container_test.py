#!/usr/bin/env pytest -vs
"""Tests for example container."""

# Standard Python Libraries
import time

READY_MESSAGES = {
    "apache": "Apache container started",
    "coredns": "CoreDNS container started",
}


def test_container_count(dockerc):
    """Verify the test composition and container."""
    # stopped parameter allows non-running containers in results
    assert (
        len(dockerc.containers(stopped=True)) == 2
    ), "Wrong number of containers were started."


def test_wait_for_ready_apache(apache_container):
    """Verify the apache container is running."""
    TIMEOUT = 20
    ready_message = READY_MESSAGES["apache"]
    print("AAAA", apache_container.logs().decode("utf-8"))
    for i in range(TIMEOUT):
        if ready_message in apache_container.logs().decode("utf-8"):
            return
        time.sleep(1)

    raise Exception(
        f"Container does not seem ready.  "
        f'Expected "{ready_message} in the log within {TIMEOUT} seconds.'
    )
