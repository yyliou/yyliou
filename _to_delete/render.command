#!/bin/bash
# Double-click this in Finder to re-render every CV (and ../rs) with R.
cd "$(dirname "$0")" || exit 1
R="$(command -v Rscript || echo /usr/local/bin/Rscript)"
[ -x "$R" ] || { echo "Rscript not found in PATH."; read -r -p "Press return to close."; exit 1; }
"$R" render.R --rs
status=$?
echo
echo "Done (exit $status)."
exit $status
