MBR=mod_bot_relay
EC=erlc
INC=-I ${EJABBERD_PATH} -W0

all: $(MBR)

$(MBR): $(MBR).erl
	$(EC) $(INC) $(MBR).erl

install: $(MBR)
	sudo cp $(MBR).beam /lib/ejabberd/ebin/$(MBR).beam

restart: install
	sudo ejabberdctl restart

clean:
	rm -rf *.beam
