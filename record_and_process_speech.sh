#!/bin/bash


if [[ $# -gt 0 ]]
then
	duration=$1
else
	duration=2
fi

echo "Now recording for $duration seconds"
arecord --file-type wav --format=S16 --rate=16000 --channels=1 --duration="$duration" sample.wav
#arecord --device=hw:0,1 --file-type wav --format=S16 --rate=16000 --channels=1 --duration=2 sample.wav
aplay sample.wav &
echo "Running Julia script"
julia speech_processor.jl  `readlink -f sample.wav`
