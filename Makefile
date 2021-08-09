.PHONY: run_bochs
.PHONY: run_qemu
.PHONY: __bin
.PHONY: __merge
.PHONY: clean

run_bochs: clean __bin __merge
	bochs
run_qemu: clean __bin __merge
	qemu-system-i386 -drive format=raw,file=bin/OS.bin,if=ide,index=0,media=disk

ASMDIR = asm
BINDIR = bin

__merge: 
	@for file in $(BINDIR/*.bin) ; do \
		echo $${file} ; \
		cat $${file} >> bin/OS.bin ; \
	done

__bin: $(ASMDIR)/*.s
	@for file in $^ ; do \
		fasm $${file} ; \
	done
	mv asm/*.bin bin/
	@for file in $(BINDIR)/* ; do \
		cat $${file} >> bin/OS.bin ; \
	done

clean:
	rm -f bin/*.bin
