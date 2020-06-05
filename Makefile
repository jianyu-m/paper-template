# the source .tex
SRC = paper
SRCTEX = $(SRC).tex
SRCBIB = bib/*.bib

# misc dependencies
MISC = Makefile $(wildcard *.cls)
CODE := $(wildcard code/*.c code/*.cpp code/*.meta code/*.csh code/*.scala code/*.java)

# force a dependency on all data files.
TEXDEP := $(wildcard *.tex)
FIGURES := $(wildcard figures/*.pdf)
PYFIGS := $(wildcard figures/eval/*.py)

# commands
BIBTEX ?= bibtex
PDFLATEX ?= pdflatex
PYTHON3 ?= python3
PIP3 ?= pip3
PYMENT ?= pygmentize
RM ?= rm -f
WHICHLATEX = $(PDFLATEX)


.PHONY: all check_tools clean cleanall pdf

all: check_tools pdf

install-dep:
	sudo apt-get install python3 python3-pip python3-tk python-pygments -y
	pip3 install numpy matplotlib pygments

check_tools: TOOLS = $(BIBTEX) $(WHICHLATEX) $(PIP3) $(PYTHON3) $(PYMENT)
check_tools:
	@echo "Checking build tools..."
	$(foreach tool,$(TOOLS),$(if $(shell which $(tool)),,$(error You seem to be missing $(tool)!)))

code_subdir: $(CODE)
figure_subdir: $(FIGURES) $(PYFIGS)
	make -C figures

do_subdirs: code_subdir figure_subdir

pdf: do_subdirs $(SRC).pdf

$(SRC).aux: $(TEXDEP) $(SRC).bbl do_subdirs
	@echo "[$(WHICHLATEX)]: first pass to generate *.aux files"
	@$(WHICHLATEX) -shell-escape $(SRC) 2>&1 >> $(SRC).build.log

$(SRC).bbl: $(SRC).aux $(SRCBIB)
	@echo "[$(BIBTEX)] $(SRC)"
	@$(BIBTEX) $(SRC) 2>&1 >> $(SRC).build.log

$(SRC).pdf: $(SRC).bbl $(MISC)
	@echo "[$(WHICHLATEX)]: second pass to generate *.bib files"
	@$(WHICHLATEX) -shell-escape $(SRC) 2>&1 >> $(SRC).build.log
	@echo "[$(WHICHLATEX)]: third pass to get cross-referecne work"
	@$(WHICHLATEX) -shell-escape $(SRC) 2>&1 >> $(SRC).build.log

pdf: $(SRC).pdf

docker:
	sudo docker pull jyjiang/latex-paper-build
	sudo docker run -i -v ${PWD}:/paper:Z jyjiang/latex-paper-build bash -c "cd /paper; make clean;make"

# clean up everything except .pdf
clean:
	$(RM) *.aux *.dvi *.log *.bbl *.blg *.build.log *~ *.out *.fls *.fdb_latexxmk
	$(RM) $(SRC).pdfsync $(SRC).synctex.gz
	$(RM) -rf _minted-paper*

# clean up everything
cleanall: clean
	make -C figures clean
	make -C code clean
	# make -C code cleanall
	$(RM) $(SRC).pdf $(SRC).ps p.pdf
