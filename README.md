# eLAMP - Electronic LAMP: virtual Loop–mediated isothermal AMPlification

**COMMAND LINE USAGE

´´´
eLAMP.pl -f in–file.fasta -p in–file.csv [-A ###] [-a ###] [-s ##] [-l ##] [-I #] [-M #] [-O #] [-i ###] [-m ###] [-o ###] [-r] [-c]
´´´

"in–file.fasta" contains template sequences in fasta format, and "in–file.csv" LAMP primers in a csv format. In the latter, each cell corresponds to a primer and each line to a primer set. Primer pairs are ordered from the innermost to the outermost. Within each primer pair, the forward (left) primer should be followed by the reverse (right). A heading line is optional. The alternative FIB/BIP primer format can be used, but linkers must be delimited by hyphens (e.g. "-TTTTT-"). 


OPTIONS

-f	is a fasta formated input file
-p	is a comma separated value (.csv) file containing four or six primer sequences per line (first six columns; inner forward, inner reverse, middle forward, middle reverse, outer forward, outer reverse)
-A	maximum amplicon size (bp; default = 280)
-a	maximum interloop spacing (bp; default = 51)
-s	minimum space between inner primers (bp; default = 1)
-l	minimum space between inner and middle primers (bp; default = 25)
-I	the number of exact matches at the 3' ends of the inner primer pair (1–3; default = 3)
-M	the number of exact matches at the 3' ends of the middle primer pair (1–3; default = 3)
-O	the number of exact matches at the 3' ends of the outer primer pair (1–3; default = 3)
-i	percent of matching bases for the inner primer pair (excluding the 3' bases set with -I; default = 100)
-m	percent of matching bases for the middle primer pair (excluding the 3' bases set with -M; default = 100)
-o	percent of matching bases for the outer primer pair (excluding the 3' bases set with -O; default = 100)
-r	activate "relaxed" mode, primer GC content is not checked
-c	evaluate template sequences in both possible orientations


GRAPHICAL INTERFACE INVOCATION

gui.pl 

Both scripts ("eLAMP.pl" and "gui.pl") should be stored in the same folder or be found in PATH, otherwise the graphical interface will not be able to electronically amplify sequences. 


REQUIREMENTS

PERL interpreter (http://www.perl.org/)
Tre library (http://laurikari.net/tre/)
Perl/Tk module (http://search.cpan.org/~ni-s/Tk-804.027/)


CITATION

Salinas, N. R. & D. P. Little. 2011. eLAMP: virtual Loop–mediated isothermal AMPlification. Program distributed by the authors (http://www.nybg.org/files/scientists/dlittle/eLAMP.html). 


EXAMPLE

Example input and output files are included with the download.

eLAMP.pl -f x.fst -p x.csv -A 300 -a 100 -s 1 -l 20 -r -I 3 -M 3 -O 3 -i 80 -m 80 -o 80 -c > x-out.csv
