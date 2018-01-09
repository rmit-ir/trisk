#!/bin/bash

# Accepts two arguments, the TREC_EVAL output of 
# the run you're interested in evaluating, and the 
# baseline run you're interested in evaluating against.
# e.g. ./trisk_trec.sh run.trec baseline.trec

# Note that you should filter the TREC run file to match
# your target metric before running this file.
# E.g. trec_eval -q -M 1000 $QRELS $RUNFILE | grep -E "^map" > run.trec

RUN="$1"
BL="$2"

run_clean=$(mktemp)
echo "topic,score" >> $run_clean
cat $RUN | awk '{print $2","$3}' >> $run_clean
sed -i '/all/d' $run_clean

baseline_clean=$(mktemp)
echo "topic,score" >> $baseline_clean
cat $BL | awk '{print $2","$3}' >> $baseline_clean
sed -i '/all/d' $baseline_clean

./trisk.rb $run_clean $baseline_clean score 1
