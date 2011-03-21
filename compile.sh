#!/bin/sh

set -e # Modo estricto

echo "Verificando dependencias"

rst2html=$(which rst2html) || (
    echo "Necesita python-docutils"
    exit 1 )

wkhtmltopdf=$(which wkhtmltopdf) || (
    echo "Necesita wkhtmltopdf"
    exit 2 )

git=$(which git) || (
    echo "Necesita git"
    exit 3 )

git=$(which shorturl) || (
    echo "Necesita shorturl (https://github.com/pointtonull/shorturl)"
    exit 3 )

input="$@"

[ -e "$input" ] || (
    echo "Se debe indicar el un fichero.rst de entrada, e.g.:"
    echo "    ./compile.sh rst/comunicado12.rst"
    exit 4
    )

basename=$(basename $input .rst)
htmloutput="html/$basename.html"
pdfoutput="pdf/$basename.pdf"

echo "Acortando enlaces url"
htmlurl="https://github.com/pointtonull/jrsl-prensa/blob/master/$input"
htmlshorturl=$(echo $htmlurl|shorturl)
pdfurl="https://github.com/pointtonull/jrsl-prensa/raw/master/$pdfoutput"
pdfshorturl=$(echo $pdfurl|shorturl)

echo "Generando documento html"
rst2htmloptions='--stylesheet=html4css1.css --template=template.txt'
awk -v pdfshorturl="$pdfshorturl" -v htmlshorturl="$htmlshorturl" '
    {
        gsub("\\|pdfshorturl\\|", pdfshorturl)
        gsub("\\|htmlshorturl\\|", htmlshorturl)
        print $0
    }
' header.rst "$input" footer.rst | $rst2html $rst2htmloptions > "$htmloutput"

echo "Generando documento pdf"
wkhtmltopdfoptions="\
       --margin-bottom 20\
       --margin-left 20\
       --margin-right 20\
       --margin-top 20\
"
$wkhtmltopdf $wkhtmltopdfoptions "$htmloutput" "$pdfoutput"

echo "Publicando documentos en el sitio"
git add $input $htmloutput $pdfoutput
git commit -m "Compiled $basename"
git push
