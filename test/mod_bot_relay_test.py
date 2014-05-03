#!/usr/bin/env python

import json
import sleekxmpp as sx
import sys


class ListenerBot(sx.ClientXMPP):
    def __init__(self, jid, password, log_path):
        sx.ClientXMPP.__init__(self, jid, password)
        self.add_event_handler("session_start", self.session_start)
        self.add_event_handler("message", self.process_message)
        self.log_path = log_path

    def session_start(self, event):
        pass

    def process_message(self, msg):
        print msg


def read_config(config_path):
    to_user     = "to_user"
    from_user   = "from_user"
    jid         = "jid"
    pw          = "password"
    server_ip   = "server_ip"
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


class SendBot(sx.ClientXMPP):
    def __init__(self, jid, password, to_jid):
        sx.ClientXMPP.__init__(self, jid, password)
        self.to_jid = to_jid

    def benchmark_standard(self):
        pass

    def benchmark_relay(self):
        pass



if len(sys.argv) != 2:
    error_msg = "Expected: ./mod_bot_relay_test.py <config file>"
    print error_msg
else:
    config_path = sys.argv[1]
    from_j, from_p, to_j, to_p, ip, port = read_config(config_path)

    send_bot = SendBot(from_j, from_p, to_j)
    listener_bot = ListenerBot(to_j, to_p, "out.log")
    listener_bot.connect(ip, port)
