#!/bin/sh

input="$@"
basename=$(basename $input .rst)
options='--stylesheet=html4css1.css --template=template.txt'
output="html/$basename.html"

cat header.rst "$input" footer.rst | rst2html $options > "$output"
