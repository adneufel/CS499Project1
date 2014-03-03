JAVA=/usr/lib/jvm/java-7-openjdk-amd64/bin/java

# These can be set in the command line with "make build ARFF=blah MODEL=blah"
# The input file for weka classification
ARFF=trainingdata.arff

# The resultant model file
ALPMODEL=arff.model
FOURFIVEMODEL=4or5.arff

# Folders!
ALPTRUE=SortedImages/ALP-Yes
ALPFALSE=SortedImages/ALP-No

FOURFIVE-FOUR=SortedImages/4or5-4
FOURFIVE-FIVE=SortedImages/4or5-5
FOURFIVE-OTHER=SortedImages/4or5-No

# arff files
ALPARFF=ALP.arff
ALPTRUEARFF=$(ALPTRUE)/SortedImagesALP-Yes.arff
ALPFALSEARFF=$(ALPFALSE)/SortedImagesALP-No.arff
FOURFIVEARFF=4or5.arff
FOURFIVE-FOURARFF=$(FOURFIVE-FOUR)/SortedImages4or5-4.arff
FOURFIVE-FIVEARFF=$(FOURFIVE-FIVE)/SortedImages4or5-5.arff
FOURFIVE-OTHERARFF=$(FOURFIVE-OTHER)/SortedImages4or5-No.arff

build: build1 build2

# Build the model for part 1
build1:
	echo Building part 1 arff files...
	python constructarff.py -d $(ALPTRUE) -p 1 -c true
	python constructarff.py -d $(ALPFALSE) -p 1 -c false 
	echo Combining part 1 arff files into $(ALPARFF)...
	python combinearffs.py -n $(ALPARFF) -f $(ALPTRUEARFF) $(ALPFALSEARFF)
	echo Building part 1 model: $(ALPMODEL)...
	$(JAVA) -classpath weka.jar weka.classifiers.functions.MultilayerPerceptron -L 0.3 -M 0.2 -N 500 -V 0 -S 0 -E 20 -H a -t $(ALPARFF) -d $(ALPMODEL)

build2:
	echo Building part 2 arff files...
	python constructarff.py -d $(FOURFIVE-FOUR) -p 2 -c four
	python constructarff.py -d $(FOURFIVE-FIVE) -p 2 -c five
	python constructarff.py -d $(FOURFIVE-OTHER) -p 2 -c false
	echo Combining part 2 arff files into $(FOURFIVEARFF)...
	python combinearffs.py -n $(FOURFIVEARFF) -f $(FOURFIVE-FOURARFF) $(FOURFIVE-FIVEARFF) $(FOURFIVE-OTHERARFF)
	echo Building part 2 model: $(FOURFIVEMODEL)...
	$(JAVA) -classpath weka.jar weka.classifiers.functions.MultilayerPerceptron -L 0.3 -M 0.2 -N 500 -V 0 -S 0 -E 20 -H a -t $(FOURFIVEARFF) -d $(FOURFIVEMODEL)

# Run tests
test1:
	#python constructarff.py -d $(TESTDIR) -1 -t -c "?"
	#java weka.classifiers.functions.MultilayerPerceptron -T $(TESTFILE) -l $(MODEL) -p 0
