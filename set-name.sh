#!/bin/bash
# Usage: bash set-name.sh PREFIX "Full Name" STUDENT_ID GITHUB_URL
set -e
[ $# -eq 4 ] || { echo "usage: bash set-name.sh PREFIX \"Full Name\" STUDENT_ID GITHUB_URL"; exit 1; }
export OLD=Surname_Firstname_StudentID NEW="$1" FN="$2" SID="$3" URL="$4"
find . -type f -name "${OLD}_*" | while read -r f; do
  mv "$f" "$(dirname "$f")/$(basename "$f" | sed "s/^${OLD}_/${NEW}_/")"
done
find . -type f \( -name '*.md' -o -name '*.sql' -o -name '*.js' \) -print0 | xargs -0 perl -pi -e 's/\Q$ENV{OLD}\E/$ENV{NEW}/g; s/\{\{FULL_NAME\}\}/$ENV{FN}/g; s/\{\{STUDENT_ID\}\}/$ENV{SID}/g; s/\{\{GITHUB_URL\}\}/$ENV{URL}/g'
echo "Done."
