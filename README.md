keyword_recognition
===================

Keyword recognition is a speech recognition tool for whole-word or short-scentence recognition. 
Speech is processed to featues using Mel-Frequency Cepstral Coefficients (MFCCs) and recognition 
is performed using Dynamic Time Warping. 

The software have relative good accuracy for different speakers and is moderately sensitive to noise. 
I use this tool to control for example my music player (pausing, playing, next track etc.) with good results.

Installation
============

The feature-extractor is written in the Julia Languge. It requires two packages to be added which 
is installed from the Julia command-line:

```
julia> Pkg.add("JSON")
julia> Pkg.add("WAV")
```

Recognition requires the Machine Learning Python package to be installed. See [http://mlpy.sourceforge.net/docs/3.5/install.html]

Example
=======

The speech processor outputs a file called `mfcc_features.json` which you copy to the directory `features` and give it a proper name.

First, run the speech processor to record some words:
```
login> ./record_and_process_speech
login> cp mfcc_features.json features/left.json
login> ./record_and_process_speech
login> cp mfcc_features.json features/right.json
```

Then, use the test-script to try to recognize speech:

```
login> ./test_speech.sh
```

Contact 
=======

Feedback and feature requests are much welcome! Please visit my homepage [www.indrome.com]
