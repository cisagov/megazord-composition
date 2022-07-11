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
    web_request = b"GET / HTTP/1.1\r\nHOST:172.19.0.4\r\n\r\n"
    ready_message = READY_MESSAGES["apache"]
    host = "localhost"
    output = b""
    port = 80

    while 1:  # we loop so if a connection is reset it is re-established
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect((host, port))
            s.send(web_request)
            output = s.recv(1024)

        except socket.error as err:
            raise Exception(f"Socket error during setup: {err}.")

        else:  # if no exception is raised, exit the loop
            break

    if output == b"" or ready_message not in output.decode("utf-8"):
        raise Exception(
            f"Container does not seem ready. "
            f"Expected {ready_message} in the output. "
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
