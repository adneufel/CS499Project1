JAVA=/usr/lib/jvm/java-7-openjdk-amd64/bin/java

# These can be set in the command line with "make build ARFF=blah MODEL=blah"
# The input file for weka classification
ARFF=trainingdata.arff

# The resultant model file
MODEL=classifier.model

# Build the model for part 1
build1:
	echo Building arff files...
	#python constructarff.py TrainingData/loc1 -1 "true"
	#python constructarff.py TrainingData/loc2 -1 "false" 
	
	echo Building model...
	java weka.classifiers.functions.MultilayerPerceptron -L 0.3 -M 0.2 -N 500 -V 0 -S 0 -E 20 -H a -t $(ARFF) -d $(MODEL)

# Run tests
#test:
