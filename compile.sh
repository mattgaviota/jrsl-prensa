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
compiledrst="rst/$basename-compiled.rst"
htmloutput="html/$basename.html"
pdfoutput="pdf/$basename.pdf"
modifydate=$(stat "$input" | awk '
    /^Modify/{system("date --date=\"" $2 "\" \"+%d de %B de %Y\"")}')

echo "Acortando enlaces url"
htmlurl="https://github.com/pointtonull/jrsl-prensa/blob/master/$compiledrst"
htmlshorturl=$(echo $htmlurl|shorturl)
pdfurl="https://github.com/pointtonull/jrsl-prensa/raw/master/$pdfoutput"
pdfshorturl=$(echo $pdfurl|shorturl)

echo "Compilando rst final"
rst2htmloptions='--stylesheet=html4css1.css --template=template.txt'
awk -v pdfshorturl="$pdfshorturl"\
    -v htmlshorturl="$htmlshorturl"\
    -v modifydate="$modifydate" '
    {
        gsub("\\|pdfshorturl\\|", pdfshorturl)
        gsub("\\|htmlshorturl\\|", htmlshorturl)
        gsub("\\|modifydate\\|", modifydate)
        print $0
    }
' header.rst "$input" footer.rst > $compiledrst

echo "Generando documento html"
$rst2html $rst2htmloptions "$compiledrst" > "$htmloutput"

echo "Generando documento pdf"
wkhtmltopdfoptions="\
       --margin-bottom 9\
       --margin-left 10\
       --margin-right 10\
       --margin-top 9\
"
$wkhtmltopdf $wkhtmltopdfoptions "$htmloutput" "$pdfoutput"

echo "Preparando posible envío masivo"
awk '/^\*\*/{pub=1}pub' $compiledrst > mensaje.txt
cp $htmloutput mensaje.html

echo "Publicando documentos en el sitio"
git add $input $compiledrst $htmloutput $pdfoutput mensaje.txt mensaje.html
git commit -m "compiled $basename $modifydate"
git push

echo "Todo salió, aparentemente, bien xD"
