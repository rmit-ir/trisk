# TRisk 

This tool computes URisk, TRisk and p-values for either trec_eval outputs or gdeval outputs. It requires Ruby and R.

The TRisk measure was first introduced in the 2014 SIGIR paper *Hypothesis Testing for the Risk-sensitive Evaluation of Retrieval Systems* written by B. Taner Dinçer, Craig Macdonald and Iadh Ounis. This tool was built and used to report figures in the 2017 ADCS paper *Risk-reward trade-offs in Rank Fusion* by Rodger Benham and J. Shane Culpepper.

The tool supports outputting TRisk values in both *inferential* mode (across all topics), and *exploratory* mode (per-topic).

## Changelog
22/01/2018 - Fixed issue where the absolute value of negative t-values was not taken, resulting in probabilities outside of [0,1]. Fixed issue where script would not work without executing inside the folder.

## Usage

### trec_eval

To calculate the TRisk scores for a run compared to a baseline using the AP value reported in trec_eval:

```
trec_eval -q -M 1000 $QRELS $RUN | grep -E "^map" > run.trec
trec_eval -q -M 1000 $QRELS $BASELINE | grep -E "^map" > baseline.trec
./trisk_trec.sh run.trec baseline.trec > out.txt
```

Where `out.txt` now appears as something similar:

```
alpha,urisk,trisk,pvalue
0.0,0.0767,8.8167,0.0
1.0,0.0615,5.8329,0.0
2.0,0.0462,3.6263,0.0003
3.0,0.031,2.0425,0.0422
4.0,0.0157,0.888,0.375
5.0,0.0005,0.0231,0.982
6.0,-0.0148,-0.643,1.48
7.0,-0.03,-1.1688,1.76
8.0,-0.0453,-1.5932,1.89
9.0,-0.0605,-1.942,1.95
10.0,-0.0758,-2.2334,1.97
```

The default mode is inferential mode, i.e. TRisk values are formulated across all topics. To get per-topic values supply `--per-topic` as the final argument:

```
./trisk_trec.sh run.trec baseline.trec --per-topic
alpha,topic,trisk,pvalue
0.0,301,0.988,0.324
0.0,302,0.484,0.629
0.0,303,-0.015,1.01
0.0,304,0.146,0.884
...
```

### gdeval

To calculate the TRisk scores for a run compared to a baseline using the NDCG@10 evaluation metric:

```
perl gdeval.pl -k 10 -j 4 $QRELS $RUN > run.gdeval
perl gdeval.pl -k 10 -j 4 $QRELS $BASELINE > baseline.gdeval
./trisk_gdeval.sh run.gdeval baseline.gdeval ndcg@10 > out.txt
```

Similarly, supply `--per-topic` as the final argument as above to get exploratory values.

## License

This tool is licensed under the MIT open-source. See LICENSE.txt for more details.
