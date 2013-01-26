all: html

SPEC_HTML = Qantor-Reloaded-Spec.html
SPEC_POD = Qantor-Reloaded-Spec.pod

html: $(SPEC_HTML)

$(SPEC_HTML): $(SPEC_POD)
	pod2xhtml -o $@ < $<

upload: html
	rsync -a -v --progress --inplace $(SPEC_HTML) $(SPEC_POD) $$__HOMEPAGE_REMOTE_PATH/temp-Qantor-Reloaded-Spec-v0.2.x/

