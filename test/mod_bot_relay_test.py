#!/usr/bin/env python

import json
import logging
import numpy as np
import os
import re
import sleekxmpp as sx
import sys
import time


def log_result(tag, time):
    logging.debug("mod_bot_relay %s %f" % (tag, time))


def read_config(config_path):
    to_user = "to_user"
    from_user = "from_user"
    jid = "jid"
    pw = "password"
    server_ip = "server_ip"
    server_port = "server_port"

    config_dict = None
    with open(config_path) as config:
        config_data = config.read()
        config_dict = json.loads(config_data)
    if config_dict is None:
        return None
    from_jid = str(config_dict[from_user][jid])
    from_user_pass = str(config_dict[from_user][pw])
    to_jid = str(config_dict[to_user][jid])
    to_user_pass = str(config_dict[to_user][pw])
    ip = str(config_dict[server_ip])
    port = str(config_dict[server_port])

    return from_jid, from_user_pass, to_jid, to_user_pass, ip, port


class ListenerBot(sx.ClientXMPP):
    def __init__(self, jid, password, log_path):
        sx.ClientXMPP.__init__(self, jid, password)
        self.add_event_handler("session_start", self.session_start)
        self.add_event_handler("message", self.process_message)
        self.log_path = log_path

    def session_start(self, event):
        self.send_presence()

    def process_message(self, msg):
        t = time.time()
        log_result('received', t)


class SendBot(sx.ClientXMPP):
    def __init__(self, jid, password, to_jid, iterations):
        sx.ClientXMPP.__init__(self, jid, password)
        self.to_jid = to_jid
        self.add_event_handler("session_start", self.session_start)
        self.iterations = iterations

    def session_start(self, event):
        self.send_presence()
        for i in range(self.iterations):
            t = time.time()
            log_result('sent', t)
            self.send_message(self.to_jid, "Test: %d" % i)
            time.sleep(1)
        self.disconnect(wait=False)


def prepare_log(log_path):
    if os.path.isfile(log_path):
        os.remove(log_path)
    elif os.path.isdir(log_path):
        os.remove_dirs(log_path)
    logging.basicConfig(level=logging.DEBUG,
                        format='%(levelname)-8s %(message)s',
                        filename=log_path)


def process_log(log_path):
    diffs = []
    sent = True
    prev = 0.0
    sent_re = 'DEBUG\s+mod_bot_relay\s+sent\s+(\d+\.\d+)'
    rec_re = 'DEBUG\s+mod_bot_relay\s+received\s+(\d+\.\d+)'
    with open(log_path, 'r') as log:
        for line in log:
            if sent:
                m = re.search(sent_re, line)
                if m is not None:
                    t = float(m.group(1))
                    prev = t
                    sent = False
            else:
                m = re.search(rec_re, line)
                if m is not None:
                    t = float(m.group(1))
                    diffs.append(t - prev)
                    sent = True
    return diffs


if len(sys.argv) != 3:
    error_msg = "Expected: ./mod_bot_relay_test.py <config file> <log_file>"
    print error_msg
else:
    config_path = sys.argv[1]
    log_path = sys.argv[2]
    prepare_log(log_path)

    from_j, from_p, to_j, to_p, ip, port = read_config(config_path)

    listener_bot = ListenerBot(to_j, to_p, "out.log")
    listener_bot.connect(address=(ip, port))
    listener_bot.process(block=False)

    time.sleep(5)
    send_bot = SendBot(from_j, from_p, to_j, 1)
    send_bot.connect(address=(ip, port))
    send_bot.process(block=True)
    listener_bot.disconnect(wait=False)
    diffs = process_log(log_path)
    print '%f %f %f %f %f' % (np.mean(diffs), np.median(diffs), np.std(diffs),
                              np.mininum(diffs), np.max(diffs))
