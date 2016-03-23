
#!/bin/bash
NPM_DEPS_FILE=".npm-deps-parseable.txt"
KIK_MODULES_FILE=".kik-modules.txt"

echo "Downloading kik incident modules list..."
wget https://gist.githubusercontent.com/azer/db27417ee84b5f34a6ea/raw/50ab7ef26dbde2d4ea52318a3590af78b2a21162/gistfile1.txt -O $KIK_MODULES_FILE
wait $!

echo "Building dependency list..."
npm ls --parseable > $NPM_DEPS_FILE
wait $!

# TODO ignore false positives or do a second-pass cleaning
while IFS= read -r row
do
  echo "Checking: $row"
  GREP_RESULT=`grep $row $NPM_DEPS_FILE`
  [ $? == 0 ] && echo "Found: $row" && echo $GREP_RESULT
done < $KIK_MODULES_FILE

rm $NPM_DEPS_FILE $KIK_MODULES_FILE
