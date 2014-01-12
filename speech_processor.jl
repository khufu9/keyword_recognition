using JSON, WAV

include("mfcc.jl")

if length(ARGS) < 1
	println("Usage: julia speech_processor.jl FILE.json")
	exit()
else
	path = ARGS[1]
end

println("The file is: ",path)

y, FS = wavread( path )

mfcc_feat = mfcc(y)
delta1 = delta_coeff(mfcc_feat)
delta2 = delta_coeff(delta1)

features = hcat(mfcc_feat,delta1,delta2)

to_file = ["features"=>features,"signal"=>y,"_comment"=>"Each row in the feature matrix contain a feature vector, delta vector and delta-delta vector"]

f = open("mfcc_features.json","w")
println(f,JSON.json(to_file))
close(f)
