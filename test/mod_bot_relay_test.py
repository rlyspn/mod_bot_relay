#!/usr/bin/env python

import json
import sys

def read_config(config_path):
    to_user = "to_user"
    from_user = "from_user"
    user_name = "user_name"
    pw = "password"

    config_dict = None
    with open(config_path) as config:
        config_data = config.read()
        config_dict = json.loads(config_data)
    if config_dict is None:
        return None
    from_user_name = str(config_dict[from_user][user_name])
    from_user_pass = str(config_dict[from_user][pw])
    to_user_name = str(config_dict[to_user][user_name])
    to_user_pass = str(config_dict[to_user][pw])

    return from_user_name, from_user_pass, to_user_name, to_user_pass

if len(sys.argv) != 2:
    error_msg = "Expected: ./mod_bot_relay_test.py <config file>"
    print error_msg
else:
    config_path = sys.argv[1]
    print read_config(config_path)
