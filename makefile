# The U of A lab machines have Java 7 installed, but the java command runs java 6.
# This must be updated to the location of Java 7 on your machine, or uncomment the
# line below if Java 7 is the default.
JAVA=/usr/lib/jvm/java-7-openjdk-amd64/bin/java
#JAVA=java

# The resultant model file
ALPMODEL=alp.model
FOURFIVEMODEL=4or5.model

# Folders!
ALPTRUE=SortedImages/ALP-Yes
ALPFALSE=SortedImages/ALP-No

FOURFIVE-FOUR=SortedImages/4or5-4
FOURFIVE-FIVE=SortedImages/4or5-5
FOURFIVE-OTHER=SortedImages/4or5-No

TESTDIR1=Testing\ Part\ 1
TESTDIR2=Testing\ Part\ 2

# arff files
ALPARFF=ALP.arff
ALPTRUEARFF=$(ALPTRUE)/SortedImagesALP-Yes.arff
ALPFALSEARFF=$(ALPFALSE)/SortedImagesALP-No.arff
FOURFIVEARFF=4or5.arff
FOURFIVE-FOURARFF=$(FOURFIVE-FOUR)/SortedImages4or5-4.arff
FOURFIVE-FIVEARFF=$(FOURFIVE-FIVE)/SortedImages4or5-5.arff
FOURFIVE-OTHERARFF=$(FOURFIVE-OTHER)/SortedImages4or5-No.arff

TESTARFF=testing.arff

# SMO complexity values
ALP-C=0.21842105263157896
4or5-C=0.26389473684210524

# We need to use filters to remove the filenames from our arff files
TEMPARFF=temp.arff

build: build1 build2

# Build the model
build1:
	@echo Building part 1 arff files...
	python constructarff.py -j $(JAVA) -d $(ALPTRUE) -p 1 -c true
	python constructarff.py -j $(JAVA) -d $(ALPFALSE) -p 1 -c false 
	@echo Combining part 1 arff files into $(ALPARFF)...
	python combinearffs.py -n $(ALPARFF) -f $(ALPTRUEARFF) $(ALPFALSEARFF)
	@echo Building part 1 model: $(ALPMODEL)...
	@$(JAVA) -classpath weka.jar weka.filters.unsupervised.attribute.Remove -R 1 -i $(ALPARFF) -o $(TEMPARFF)
	$(JAVA) -classpath weka.jar weka.classifiers.functions.SMO -C $(ALP-C) -L 0.001 -P 1.0E-12 -N 0 -V -1 -W 1 -K "weka.classifiers.functions.supportVector.PolyKernel -C 250007 -E 1.0" -t $(TEMPARFF) -d $(ALPMODEL)
	@rm $(TEMPARFF) -f

build2:
	@echo Building part 2 arff files...
	python constructarff.py -j $(JAVA) -d $(FOURFIVE-FOUR) -p 2 -c four
	python constructarff.py -j $(JAVA) -d $(FOURFIVE-FIVE) -p 2 -c five
	python constructarff.py -j $(JAVA) -d $(FOURFIVE-OTHER) -p 2 -c other
	@echo Combining part 2 arff files into $(FOURFIVEARFF)...
	python combinearffs.py -n $(FOURFIVEARFF) -f $(FOURFIVE-FOURARFF) $(FOURFIVE-FIVEARFF) $(FOURFIVE-OTHERARFF)
	@echo Building part 2 model: $(FOURFIVEMODEL)...
	@$(JAVA) -classpath weka.jar weka.filters.unsupervised.attribute.Remove -R 1 -i $(FOURFIVEARFF) -o $(TEMPARFF)
	$(JAVA) -classpath weka.jar weka.classifiers.functions.SMO -C $(4or5-C) -L 0.001 -P 1.0E-12 -N 0 -V -1 -W 1 -K "weka.classifiers.functions.supportVector.PolyKernel -C 250007 -E 1.0" -t $(TEMPARFF) -d $(FOURFIVEMODEL)
	@rm $(TEMPARFF) -f

# Run tests
test1:
	@echo Testing images at $(TESTDIR1)
	@python constructarff.py -j $(JAVA) -d $(TESTDIR1) -p 1 -t -c "?"
	@$(JAVA) -classpath weka.jar weka.filters.unsupervised.attribute.Remove -R 1 -i $(TESTARFF) -o $(TEMPARFF)
	@python classify.py $(TESTARFF) $(JAVA) -classpath weka.jar weka.classifiers.functions.SMO -T $(TEMPARFF) -l $(ALPMODEL) -p 0
	@rm $(TEMPARFF) $(TESTARFF) -f

test2:
	@echo Testing images at $(TESTDIR2)
	@python constructarff.py -j $(JAVA) -d $(TESTDIR2) -p 2 -t -c "?"
	@$(JAVA) -classpath weka.jar weka.filters.unsupervised.attribute.Remove -R 1 -i $(TESTARFF) -o $(TEMPARFF)
	@python classify.py $(TESTARFF) $(JAVA) -classpath weka.jar weka.classifiers.functions.SMO -T $(TEMPARFF) -l $(FOURFIVEMODEL) -p 0
	@rm $(TEMPARFF) $(TESTARFF) -f
