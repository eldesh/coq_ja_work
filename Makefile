
JAVA      ?= java
JAVAFLAGS ?=

OMEGAT ?= OmegaT.jar

POS = addendum.po         \
      coq-cmdindex.po     \
      coq-exnindex.po     \
      coq-optindex.po     \
      coq-tacindex.po     \
      credits-contents.po \
      credits.po          \
      genindex.po         \
      index.po            \
      language.po         \
      license.po          \
      practical-tools.po  \
      proof-engine.po     \
      user-extensions.po  \
      zebibliography.po

TARGET_POS = $(addprefix target/, $(POS))
SOURCE_POS = $(addprefix source/, $(POS))

SPHINX_DIR = coq/doc/sphinx
POTS = $(wildcard $(SPHINX_DIR)/_build/gettext/*.pot)

all:
	@echo "target:"
	@echo "\thtml: 翻訳結果から .html ファイルを生成します."
	@echo "\tsource: 公式ドキュメントの .po ファイルを生成します."
	@echo "\ttarget: 翻訳結果 .po ファイルを生成します."


.PHONY: target
target: target_pre $(TARGET_POS)

.PHONY: target_pre
target_pre:
	@mkdir -p target


$(TARGET_POS): omegat/omegat.project $(SOURCE_POS) 
	@echo " [GEN] target po files.."
	$(JAVA) $(JAVAFLAGS) -jar $(OMEGAT) --mode=console-translate $<


.PHONY: source
source: source_pre $(SOURCE_POS)


.PHONY: source_pre
source_pre:
	if [ ! -e coq/config/coq_config.py ]; then \
		cd coq ; \
		./configure -local ; \
	fi
	if [ ! -e $(SPHINX_DIR)/index.rst ]; then \
		ln -f $(SPHINX_DIR)/index.html.rst $(SPHINX_DIR)/index.rst ; \
	fi
	$(RM) -r $(SPHINX_DIR)/_build/doctrees
	$(MAKE) -C coq refman-gettext


$(SOURCE_POS): source/%.po: $(SPHINX_DIR)/_build/gettext/%.pot
	@echo " [GEN] source .po"
	@mkdir -p $(dir $@)
	@msginit --no-translator -l ja -i $< -o $@


.PHONY: html_pre
html_pre:
	mkdir -p html/refman
	mkdir -p $(SPHINX_DIR)/locales/ja/LC_MESSAGES/
	$(RM) -r $(SPHINX_DIR)/_build/doctrees


.PHONY: html
html: html_pre target
	for pos in $(TARGET_POS); do \
		cp -f $$pos $(SPHINX_DIR)/locales/ja/LC_MESSAGES/ ; \
	done
	$(MAKE) -C coq refman-html SPHINXOPTS='-D language="ja"'
	cp -r $(SPHINX_DIR)/_build/html/* html/refman


.PHONY: clean
clean:
	-$(RM) -r html/refman
	-$(RM) -r $(SPHINX_DIR)/locales/ja/LC_MESSAGES
	-$(RM) -r target
	-$(RM) -r source

