
all:	draft.txt

.SUFFIXES:
.SUFFIXES: .mkd .xml

.mkd.xml:
	pandoc -t docbook -s $< |xsltproc transform.xsl - > $@

draft.txt: abstract.xml middle.xml back.xml template.xml transform.xsl
	xml2rfc template.xml -o draft.txt --text

.PHONY: clean
clean:
	rm -f abstract.xml middle.xml back.xml draft.txt
