#!/bin/sh

set -e # Modo estricto

rst2html=$(which rst2html) || (
    echo Necesita python-docutils
    exit 1 )
wkhtmltopdf=$(which wkhtmltopdf) || (
    echo Necesita wkhtmltopdf
    exit 2 )

input="$@"
basename=$(basename $input .rst)
options='--stylesheet=html4css1.css --template=template.txt'
htmloutput="html/$basename.html"
pdfoutput="pdf/$basename.pdf"

cat header.rst "$input" footer.rst | $rst2html $options > "$htmloutput"
$wkhtmltopdf "$htmloutput" "$pdfoutput"
