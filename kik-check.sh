#!/bin/bash
NPM_DEPS_FILE=".npm-deps-parseable.txt"
NPM_DEPS_FILE_PARSED=".npm-deps-parseable.parsed.txt"
KIK_MODULES_FILE=".kik-modules.txt"
LOG_FILE=".kik-check.log"

clean_files () {
  [ -f $KIK_MODULES_FILE ] && rm $KIK_MODULES_FILE
  [ -f $NPM_DEPS_FILE ] && rm $NPM_DEPS_FILE
  [ -f $NPM_DEPS_FILE_PARSED ] && rm $NPM_DEPS_FILE_PARSED
}

download_module_list () {
  echo -ne "[ ] Downloading kik incident modules list..."\\r
  wget https://gist.githubusercontent.com/azer/db27417ee84b5f34a6ea/raw/50ab7ef26dbde2d4ea52318a3590af78b2a21162/gistfile1.txt -q -O $KIK_MODULES_FILE
  wait $!
  echo -e "[x] Downloading kik incident modules list."\\r
}

clean_files

# we want to delete this just at the beginning
[ -f $LOG_FILE ] && rm $LOG_FILE

[ -f $HOME/$KIK_MODULES_FILE ] && cp $HOME/$KIK_MODULES_FILE .
[ -f $KIK_MODULES_FILE ] || download_module_list

echo -ne "[ ] Building dependency list..."\\r
npm ls --parseable > $NPM_DEPS_FILE
wait $!
echo -e "[x] Building dependency list."\\r

echo -ne "[ ] Cleaning dependency list..."\\r
while IFS= read -r row
do
  basename $row >> $NPM_DEPS_FILE_PARSED.raw
done < $NPM_DEPS_FILE
cat $NPM_DEPS_FILE_PARSED.raw | sort | uniq > $NPM_DEPS_FILE_PARSED
rm $NPM_DEPS_FILE_PARSED.raw
wait $!
echo -e "[x] Cleaning dependency list."\\r

echo -ne "[ ] Searching for positive matches..."\\r
while IFS= read -r row
do
  echo "Checking: $row" >> $LOG_FILE
  GREP_RESULT=`grep "^$row$" $NPM_DEPS_FILE_PARSED`
  [ $? == 0 ] && echo "Found: $row" >> $LOG_FILE && echo $GREP_RESULT >> $LOG_FILE
done < $KIK_MODULES_FILE
echo -e "[x] Searching for positive matches."\\r

clean_files

cat $LOG_FILE
