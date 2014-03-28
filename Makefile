MBR=mod_bot_relay
EC=erlc
INC=-I /home/riley/carrierpigeon/ejabberd_src/ejabberd/src

all: $(MBR)

$(MBR): $(MBR).erl
	$(EC) $(INC) $(MBR).erl

link: $(MBR)
	sudo cp $(MBR).beam /usr/lib/ejabberd/ebin/$(MBR).beam

restart: link
	sudo service ejabberd restart

clean:
	rm -rf *.beam
