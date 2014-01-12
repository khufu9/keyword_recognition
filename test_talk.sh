#!/bin/bash
FILEPATH=./features/*.json

./record_and_process_speech.sh

for f in $FILEPATH; do
	python2 dtw.py ./mfcc_features.json $f
done
