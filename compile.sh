#!/bin/sh

set -e # Modo estricto

rst2html=$(which rst2html) || (
    echo Necesita python-docutils
    exit 1 )

wkhtmltopdf=$(which wkhtmltopdf) || (
    echo Necesita wkhtmltopdf
    exit 2 )

git=$(which git) || (
    echo Necesita git
    exit 3 )

input="$@"
basename=$(basename $input .rst)
options='--stylesheet=html4css1.css --template=template.txt'
htmloutput="html/$basename.html"
pdfoutput="pdf/$basename.pdf"

[ -e "$input" ] || (
    echo "Se debe indicar el un fichero.rst de entrada, e.g.:"
    echo "    ./compile.sh rst/comunicado12.rst"
    exit 4
    )

cat header.rst "$input" footer.rst | $rst2html $options > "$htmloutput"

$wkhtmltopdf "$htmloutput" "$pdfoutput"

git add $input $htmloutput $pdfoutput
git commit -m "Compiled $basename"
git push
