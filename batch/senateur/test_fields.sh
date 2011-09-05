#!/bin/bash

mkdir -p out.yml test
rm -f out.yml/*

for url in `ls html`; do
  perl parse_senateur.pl html/$url 1 > out.yml/$url
done

fields=`cat out.yml/* | grep ": ." | grep -v "^    - " | sed 's/: .*$//' | sed 's/^ *//' | sort | uniq`
total=`ls out.yml/ | wc -l | awk '{print $1}'`

for field in $fields; do
  grep -r "  $field:" out.yml/ | sed 's/^.*\(.\)\.html:  '$field': //' | sort > test/$field.tmp
  stotal=`wc -l test/$field.tmp | awk '{print $1}'`
  echo "Champ $field présent dans $stotal fichiers (manque dans $(($total-$stotal)) fichiers)" > test/$field.stats
  echo  >> test/$field.stats
  uniq test/$field.tmp > test/$field.uniq
  rm test/$field.tmp
  uniqs=`wc -l test/$field.uniq | awk '{print $1}'`
  echo "$uniqs valeurs uniques :" >> test/$field.stats
  echo  >> test/$field.stats
  if [ $total -ne $uniqs ]; then
    while read line; do
      echo $line | sed 's/^/'`grep -r "$line$" out.yml/ | wc -l | awk '{print $1}'`'\t\t/' >> test/$field.stats
    done < test/$field.uniq
  else cat test/$field.uniq >> test/$field.stats
  fi
  rm test/$field.uniq
done;

grep -r "^    - " out.yml/ | sed 's/^.*\(.\)\.html:    - //' | sort | uniq > test/arrays
grep "@" test/arrays > test/emails.uniq
grep "http" test/arrays > test/sites.uniq
grep "[0-9]\+\/[0-9]\+\/[0-9]\+ \/ " test/arrays | sed 's/^.*\/.*\/ //' | sort | uniq > test/premiersmandats.uniq
grep -v "\(@\|http\|[0-9]\+\/[0-9]\+\/[0-9]\+ \/ \)" test/arrays > test/organismes
cat test/organismes | awk -F " / " '{print $1}' | sort | uniq > test/organismes.uniq
cat test/organismes | awk -F " / " '{print $2}' | sort | uniq > test/fonctions.uniq
grep -r '"groupe" : \["' out/ | sed 's/^.*"groupe" : \["//' | sed 's/","" \], ".*$//' | sort | uniq > test/groupes.uniq

echo "Vérifier les champs dans test :"
ls -lrth test

