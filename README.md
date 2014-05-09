# mod_bot_relay
CarrierPigeon routing module to rewrite packets.
* `src` - Source code for the module.
* `test` - Source code for the latency performance evaluation.

## To compile:
* Install erlang
    * On Ubuntu: `sudo apt-get install erlang`
* `cd ~/`
* `git clone https://github.com/processone/ejabberd.git`
* `git checkout -b 2.0.x origin/2.0.x`
* `export EJABBERD_PATH=$HOME/ejabberd/src`
* `cd /path/to/mod_bot_relay/src`
* `make`
