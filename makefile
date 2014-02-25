JAVA=/usr/lib/jvm/java-7-openjdk-amd64/bin/java

# These can be set in the command line with "make build ARFF=blah MODEL=blah"
# The input file for weka classification
ARFF=trainingdata.arff

# The resultant model file
MODEL=classifier.model

# Folders!
ALPTRUE=SortedImages/ALP-Yes
ALPFALSE=SortedImages/ALP-No

FOURFIVE-FOUR=SortedImages/4or5-4
FOURFIVE-FIVE=SortedImages/4or5-5
FOURFIVE-OTHER=SortedImages/4or5-No

# Build the model for part 1
build1:
	echo Building arff files...
	#python constructarff.py -d $(ALPTRUE) -p 1 -c true
	#python constructarff.py -d $(ALPFALSE) -p 1 -c false 

	echo Combining arff files...
	# ?
	# Should create the file specified in ARFF
	
	echo Building model...
	java weka.classifiers.functions.MultilayerPerceptron -L 0.3 -M 0.2 -N 500 -V 0 -S 0 -E 20 -H a -t $(ARFF) -d $(MODEL)

build2:
	echo Building arff files...
	#python constructarff.py -d $(FOURFIVE-FOUR) -p 2 -c four
	#python constructarff.py -d $(FOURFIVE-FIVE) -p 2 -c five
	#python constructarff.py -d $(FOURFIVE-OTHER) -p 2 -c false

	echo Combining arff files...
	# ?
	# should create the file specified in ARFF

	echo Building model...
	java weka.classifiers.functions.MultilayerPerceptron -L 0.3 -M 0.2 -N 500 -V 0 -S 0 -E 20 -H a -t $(ARFF) -d $(MODEL)

# Run tests
test1:
	#python constructarff.py -d $(TESTDIR) -1 -t -c "?"
	java weka.classifiers.functions.MultilayerPerceptron -T $(TESTFILE) -l $(MODEL) -p 0
