import mlpy
import json
import sys
import numpy as np

def get_json_from_file(filepath):
	
	fp = open(filepath,"r")
	data = json.load(fp)
	fp.close()

	return np.array(data["features"])

def dtw(filepath1,filepath2):


	v1 = get_json_from_file(filepath1)
	v2 = get_json_from_file(filepath2)

	dist, cost, path = mlpy.dtw_std(v1.flatten(), v2.flatten(), dist_only=False)	

	print dist, filepath2

if __name__ == "__main__":
	
	dtw(sys.argv[1], sys.argv[2])
