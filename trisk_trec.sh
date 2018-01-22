#!/bin/bash

# Accepts two arguments, the TREC_EVAL output of 
# the run you're interested in evaluating, and the 
# baseline run you're interested in evaluating against.
# e.g. ./trisk_trec.sh run.trec baseline.trec

# If you would like to get the per-topic TRisk scores,
# pass in the optional flag --per-topic.

# Note that you should filter the TREC run file to match
# your target metric before running this file.
# E.g. trec_eval -q -M 1000 $QRELS $RUNFILE | grep -E "^map" > run.trec

RUN="$1"
BL="$2"
MODE=1

if [ "$3" == "--per-topic" ]; then
    MODE=2
fi

run_clean=$(mktemp)
echo "topic,score" >> $run_clean
cat $RUN | awk '{print $2","$3}' >> $run_clean
sed -i '/all/d' $run_clean

baseline_clean=$(mktemp)
echo "topic,score" >> $baseline_clean
cat $BL | awk '{print $2","$3}' >> $baseline_clean
sed -i '/all/d' $baseline_clean

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ruby $DIR/trisk.rb $run_clean $baseline_clean score $MODE
