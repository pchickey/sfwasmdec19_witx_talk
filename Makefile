
default: witx_talk.html

.PHONY: setup
setup:
	npm install --save-dev @marp-team/marp-cli

witx_talk.html: witx_talk.md
	npx marp witx_talk.md -o witx_talk.html


.PHONY: preview
preview:
	npx marp -p witx_talk.md
