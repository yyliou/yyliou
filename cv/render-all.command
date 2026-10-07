#!/bin/bash
# Double-click in Finder: render the 8 CVs and the research statements (../rs).
cd "$(dirname "$0")" || exit 1
export PATH="/usr/local/bin:/opt/homebrew/bin:/Library/Frameworks/R.framework/Resources/bin:$PATH"
Rscript render.R --rs
status=$?
echo
read -r -p "Done (exit $status). Press return to close."
exit $status
