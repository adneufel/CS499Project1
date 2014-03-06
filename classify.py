import subprocess
import sys

# Reads an arff file and return a list of the filenames used to create it
def readarff(filename):
	arff = open(filename, "r")

	results = []

	reachedData = False
	while True:
		line = arff.readline()
		if not line:
			break
		else:
			if not reachedData:
				if "@DATA" in line:
					reachedData = True
			else:
				parts = line.split(',')
				if len(parts) > 0:
					results.append(parts[0])

	return results

def main():
	args = sys.argv

	# The first argument is the arff file before filtering
	arff = readarff(args[1])

	args.remove(args[0])
	args.remove(args[0])

	proc = subprocess.Popen(args, stdout = subprocess.PIPE)

	print "Image                   Result"
	
	while True:
		line = proc.stdout.readline()
		if not line:
			break
		else:
			# Filter the output so we can display the nice, purdy results.
			parts = line.split()
			if len(parts) == 4 and parts[0] != "inst#":

				# The class is normally in the form "num:class"
				# This strips off the prefix
				classification = parts[2][parts[2].index(':') + 1:]
				filename = arff[int(parts[0]) - 1].lstrip('\"').rstrip('\"')

				# Lazy formatting				
				numspaces = 24 - len(filename)
				whitespace = ""
				while numspaces > 0:
					whitespace += " "
					numspaces -= 1

				print filename + ":" + whitespace + classification
				

if __name__ == "__main__":
    main()
