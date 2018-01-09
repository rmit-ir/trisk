#!/bin/bash

QRELS="/research/remote/petabyte/users/rodger/adcs-risk-fusion-qe/dat/qrels/qrels.rob04"
TRECEVAL="/research/remote/petabyte/users/rodger/tools/eval-trec/trec_eval"

RBC1="/research/remote/petabyte/users/rodger/adcs-risk-fusion-qe/dat/fused_runs/no_param_fusion_goldrob04bm25/goldrob04bm25-rrf.run"
TITLERUN="/research/remote/petabyte/users/rodger/fdmexp/title-only/bm25/robust.bm25.run"

$TRECEVAL -q -M 1000 $QRELS $RBC1 | grep -E "^map" > /tmp/rbc1
$TRECEVAL -q -M 1000 $QRELS $TITLERUN | grep -E "^map" > /tmp/titlerun

rm -f /tmp/rbc1clean
echo "topic,ap" >> /tmp/rbc1clean
cat /tmp/rbc1 | awk '{print $2","$3}' >> /tmp/rbc1clean
sed -i '/all/d' /tmp/rbc1clean

rm -f /tmp/titlerunclean
echo "topic,ap" >> /tmp/titlerunclean
cat /tmp/titlerun | awk '{print $2","$3}' >> /tmp/titlerunclean
sed -i '/all/d' /tmp/titlerunclean

./trisk.rb /tmp/rbc1clean /tmp/titlerunclean ap 2
