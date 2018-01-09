#!/bin/bash

# Accepts three arguments, the gdeval output of 
# the run you're interested in evaluating, the 
# baseline run you're interested in evaluating against,
# and the column header of the target metric
# e.g. ./trisk_gdeval.sh run.gdeval baseline.gdeval ndcg@10

# If you would like to get the per-topic TRisk scores,
# pass in the optional flag --per-topic.

RUN="$1"
BL="$2"
METRIC="$3"
MODE=1

if [ "$4" == "--per-topic" ]; then
    MODE=2
fi

run_clean=$(mktemp)
cp $RUN $run_clean
sed -i '/amean/d' $run_clean

baseline_clean=$(mktemp)
cp $BL $baseline_clean
sed -i '/amean/d' $baseline_clean

./trisk.rb $run_clean $baseline_clean $METRIC $MODE 
