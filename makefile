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

# We need to use filters to remove the filenames from our arff files
TEMPARFF=temp.arff

build: build1 build2

# Build the model for part 1
build1:
	@echo Building part 1 arff files...
	python constructarff.py -d $(ALPTRUE) -p 1 -c true
	python constructarff.py -d $(ALPFALSE) -p 1 -c false 
	@echo Combining part 1 arff files into $(ALPARFF)...
	python combinearffs.py -n $(ALPARFF) -f $(ALPTRUEARFF) $(ALPFALSEARFF)
	@echo Building part 1 model: $(ALPMODEL)...
	@$(JAVA) -classpath weka.jar weka.filters.unsupervised.attribute.Remove -R 1 -i $(ALPARFF) -o $(TEMPARFF)
	$(JAVA) -classpath weka.jar weka.classifiers.functions.SMO -C 1.0 -L 0.001 -P 1.0E-12 -N 0 -V -1 -W 1 -K "weka.classifiers.functions.supportVector.PolyKernel -C 250007 -E 1.0" -t $(TEMPARFF) -d $(ALPMODEL)
	@rm $(TEMPARFF) -f

build2:
	@echo Building part 2 arff files...
	python constructarff.py -d $(FOURFIVE-FOUR) -p 2 -c four
	python constructarff.py -d $(FOURFIVE-FIVE) -p 2 -c five
	python constructarff.py -d $(FOURFIVE-OTHER) -p 2 -c false
	@echo Combining part 2 arff files into $(FOURFIVEARFF)...
	python combinearffs.py -n $(FOURFIVEARFF) -f $(FOURFIVE-FOURARFF) $(FOURFIVE-FIVEARFF) $(FOURFIVE-OTHERARFF)
	@echo Building part 2 model: $(FOURFIVEMODEL)...
	$(JAVA) -classpath weka.jar weka.classifiers.functions.SMO -C 1.0 -L 0.001 -P 1.0E-12 -N 0 -V -1 -W 1 -K "weka.classifiers.functions.supportVector.PolyKernel -C 250007 -E 1.0" -t $(FOURFIVEARFF) -d $(FOURFIVEMODEL)

# Run tests
test1:
	@echo "Testing images at $(TESTDIR)"
	@#@python constructarff.py -d $(TESTDIR) -1 -t -c "?"
	@$(JAVA) -classpath weka.jar weka.filters.unsupervised.attribute.Remove -R 1 -i $(ALPARFF) -o $(TEMPARFF)
	@python classify.py $(ALPARFF) $(JAVA) -classpath weka.jar weka.classifiers.functions.SMO -T $(TEMPARFF) -l $(ALPMODEL) -p 0
	@rm $(TEMPARFF) -f
