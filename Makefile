.PHONY: pivot-table.csv

slides.pdf: slides.tex du.out.2001-08-17-REL7_1_3 du.out.2016-01-04-REL9_5_0
	pdflatex slides.tex
#	pdflatex slides.tex

du:
	for i in $$(awk '{print $$2}' < du.out | sort | uniq); do echo $$i ;  awk -F' ' "NR==1 {start=\$$1} NF==9 && \$$2==\"$$i\" && \$$5==\"pgbench_accounts\" && old != \$$NF {print ( \$$1 - start ) / 60 / 24, \$$NF; old=\$$NF}" < du.out > du.out.$$i ; done

pivot-table.csv:
	wget -O pivot-table.csv 'https://docs.google.com/spreadsheets/d/1HjJW-8Nn4yrfgfalT29HUbIiw6Ou3HddaP3gF1Gma0w/pub?gid=1205586927&single=true&output=csv'
