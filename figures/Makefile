
PYFILES = $(filter-out pyfigs/config.py, $(wildcard pyfigs/*.py))
PDFFILES = $(PYFILES:.py=.pdf)

all: ${PDFFILES}

%.pdf: %.py config.py
	@echo "building $@"
	@python3 $<

clean:
	rm -rf *.pdf
