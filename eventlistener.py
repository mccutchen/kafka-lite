#!/usr/bin/env python3

"""
A script to handle the supervisord eventlistener protocol[1], in order to

 1. provide high-level updates on component process lifecycle and

 2. kill all processes if any one fails, so the container exits noisily rather
    than continuing to run a broken state

[1] http://supervisord.org/events.html
"""

import os
import signal
import sys


STOPPING = False


def main():
    log("starting single-node kafka cluster ...")

    while True:
        # transition from ACKNOWLEDGED to READY
        send_msg("READY")

        # parse and handle the next event
        header = parse_event(sys.stdin.readline())
        event = parse_event(sys.stdin.read(int(header["len"])))
        handle_event(header, event)

        # transition from READY to ACKNOWLEDGED
        send_msg("RESULT 2")
        send_msg("OK")


def send_msg(msg):
    """
    Sends a supervisord protocol message by writing it to stdout, followed by a
    newline.
    """
    line_end = "" if msg == "OK" else "\n"
    print(msg, flush=True, end=line_end)


def parse_event(line):
    """
    Parse an event header or data messaage in "key1:val1 key2:val2" format into
    a dict.
    """
    return dict(x.split(":") for x in line.split())


def handle_event(header, event):
    global STOPPING
    if STOPPING:
        return

    event_name = header["eventname"]
    if event_name == "SUPERVISOR_STATE_CHANGE_STOPPING":
        log("shutting down ...")
        STOPPING = True
        return

    process_name = event["processname"]

    # we don't care about events relating to our own process
    if process_name == "processes":
        return

    failure_events = {
        "PROCESS_STATE_STOPPED",
        "PROCESS_STATE_EXITED",
        "PROCESS_STATE_FATAL",
    }

    if event_name in failure_events:
        error_log(f"{process_name} service failed!")
        show_troubleshooting_logs(process_name)

        if os.environ.get("EXIT_ON_FAILURE", "").lower() in ("false", "0"):
            error_log("leaving container running for troubleshooting purposes ...")
            return

        error_log("shutting down ...")
        error_log("(set EXIT_ON_FAILURE=false leave container running)")
        os.kill(os.getppid(), signal.SIGQUIT)

    elif event_name == "PROCESS_STATE_STARTING":
        log(f"service {process_name} starting ...")

    elif event_name == "PROCESS_STATE_RUNNING":
        log(f"service {process_name} up and running ...")


def show_troubleshooting_logs(process_name, limit=50):
    # both processes log to the same file
    log_path = "/var/log/kafka/server.log"

    with open(log_path) as f:
        lines = f.readlines()

    # zookeeper starts first, so its failures tend to be at the beginning of
    # the file. kafka failures tend to be at the end.
    if process_name == "zookeeper":
        lines = lines[:limit]
    else:
        lines = lines[-limit:]

    logs = "".join(lines)
    error_log(f"to help troubleshoot, here are {limit} lines of {log_path}:\n{logs}")


def log(msg):
    print(f"[kafka-lite] {msg}", file=sys.stderr)


def error_log(msg):
    print(f"[kafka-lite][ERROR] {msg}", file=sys.stderr)


if __name__ == "__main__":
    main()
