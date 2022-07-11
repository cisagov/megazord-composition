#!/usr/bin/env pytest -vs
"""Tests for example container."""

# Standard Python Libraries
import socket
import time

# Third-Party Libraries
import dns.resolver

READY_MESSAGES = {
    "apache": "HTTP/1.1 200 OK",
    "coredns": "CoreDNS-",
}


def test_container_count(dockerc):
    """Verify the test composition and container."""
    # stopped parameter allows non-running containers in results
    assert (
        len(dockerc.containers(stopped=True)) == 2
    ), "Wrong number of containers were started."


def test_wait_for_ready_apache(apache_container):
    """Verify the apache container is running."""
    host = "localhost"
    port = 80
    ready_message = READY_MESSAGES["apache"]
    output = b""
    counter = 0

    while 1:
        if counter == 10:
            break
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(5)
            s.connect((host, port))
            s.sendall(b"GET / HTTP/1.1\r\nHost: localhost\r\n\r\n")
            output = s.recv(1024)

        except socket.error:
            pass
        counter += 1

    plain = output.decode("utf-8")

    if ready_message not in plain:
        raise Exception(
            f"Container does not seem ready.  "
            f"Expected {ready_message} got {plain}. "
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
