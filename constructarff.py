import subprocess
import os
import csv
import sys
import argparse

# full path to java for dumb lab machines
#javapath = "/usr/lib/jvm/java-7-openjdk-amd64/bin/"
javapath = ""

#alpAlgos = [ "AutoColorCorrelogram", "Gabor", "CEDD", "PHOG"]
#digitAlgos = [ "AutoColorCorrelogram", "Gabor", "CEDD", "PHOG"]
alpAlgos = [ "CEDD", "PHOG", "ColorHistogram", "ReferenceColorSimilarity"]
digitAlgos = [ "CEDD", "PHOG", "ReferenceColorSimilarity"]

# paths/dirs for image folders
testDir = 'Test-Dir'
alpYesDir = 'ALP-Yes'
alpNoDir = 'ALP-No'
digitNoDir = '4or5-No'
digit4Dir = '4or5-4'
digit5Dir = '4or5-5'
sortedImgsPath = os.path.join('.', 'SortedImages')

# class string
alpClassList = " { true,false }"
digitClassList = " { four,five,other }"

# bad global to set whether test or not
isTest = False

def writeNewLine(fout):
    fout.write('\n')

def writeLine(fout, str):
    fout.write(str + '\n')
 
# attrList is the names of the attributes in valueRows
# valueRows is a list of rows of values
def writeArff(directory, arffname, relationName, attrList, valueRows, classString):
    dirpath = os.path.join(directory, arffname)
    arff = open(dirpath, "w")
    writeLine(arff, "@RELATION " + relationName)
    writeNewLine(arff)
    # print the numeric attributes
    writeLine(arff, "@ATTRIBUTE " + attrList[0] + '\t' + "STRING")
    for attr in attrList[1:-1]:
        writeLine(arff, "@ATTRIBUTE " + attr + '\t' + "NUMERIC")
    # ... then print the mode attribute
    if not isTest:
        writeLine(arff, "@ATTRIBUTE " + attrList[-1] + classString)
    writeNewLine(arff)
    writeLine(arff, "@DATA")
    #writeNewLine(arff)
    for row in valueRows:
        if isTest:
            writeLine(arff, ",".join(row[:-1]))
        else:
            writeLine(arff, ",".join(row))
    
    arff.close()

def genCSV(dirpath, algorithm, classStr):
    cmd = "java -jar JFeatureLib-Full.jar --threads 12 -D [algo] -c [class] -d [directory] -o [outfile.csv]"
    
    # split above command into a list. 
    #   [6] is [algo], [8] is [class]
    #   [10] is [directory], [12] is [outfile.csv]
    cmdlist = cmd.split()
    
    # now set the relevant values in the list
    cmdlist[6] = algorithm
    cmdlist[8] = classStr
    cmdlist[10] = dirpath
    cmdlist[12] = os.path.join(dirpath, algorithm + ".csv") # save file into dir of images as [dirname.csv]
    
    if os.name == "posix": 
        cmdlist[0] = javapath
    
    # Now execute the command!
    subprocess.call(cmdlist)
    
    return cmdlist[12]

def preprocessDir(directory, partNum, classStr):
    
    classList = ""
    algorithms = []
    if partNum == "1":
        algorithms = alpAlgos
        classList = alpClassList
    else:
        algorithms = digitAlgos
        classList = digitClassList
    
    # create a csv file for each algorithm type
    csvFiles = []
    for algo in algorithms:
        filename = genCSV(directory, algo, classStr)
        csvFiles.append(filename)
 
    # now load those csv files and combine them into an arff
    loadedFiles = []
    for file in csvFiles:
        rows = []
        csvfile = open(file, 'rb')
        try:
            reader = csv.reader(csvfile)
            for row in reader:
                if len(row) > 0:
                    rows.append([x.strip() for x in row])   # append row with weird whitespaces removed
            loadedFiles.append(rows)
        finally:
            csvfile.close()
    
    # update the attribute names to be unique for ARFF conversion
    for i in xrange(0, len(loadedFiles)):
        file = loadedFiles[i]
        algoname = algorithms[i]
        attrRow = file[0]   # this row in csv holds attributes names of all rows
        
        for j in xrange(2, len(attrRow)):
            attrRow[j] = algoname + attrRow[j]
    
    # remove unneeded filename values and move true/false to end
    for file in loadedFiles:
        for row in file:
            row.append(row[0])
            del row[0]
    
    name = directory.replace('/', '').replace('\\', '')
    arffname = name + ".arff"
    
    # create attribute list and values list from all the loaded files
    attrList = []
    valueRows = []
    
        # init the valueRows as list of lists
    for i in xrange(0, len(loadedFiles[0])-1):
        valueRows.append([])
        
        # convert from list of files into list of lists
    attrList.extend(loadedFiles[0][0][:-1])
    for j in xrange(1, len(loadedFiles[0])):
            valueRows[j-1].extend(loadedFiles[0][j][:-1])
    for i in xrange(1, len(loadedFiles)):
        file = loadedFiles[i]
        # concatenate all the attributes from diff files into a single long list
        attrList.extend(file[0][1:-1])
        # concatenate all values for each data point into their respective lists
        for j in xrange(1, len(file)):
            valueRows[j-1].extend(file[j][1:-1])
    
    for list in valueRows:
        list.append(classStr)
    attrList.append("class")
    
    writeArff(directory, arffname, name, attrList, valueRows, classList)

def main():
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument("-p", help="the type of processing; part [1, 2]",
                        dest="part", type=str, required=True, choices="12")
    parser.add_argument("-d", help="the directory of images to process",
                        dest="dir", type=str, required=True)
    parser.add_argument("-c", help="the class type of the images",
                        dest="classtype", type=str, required=True)
    parser.add_argument("-t", help="state that this processing is to create a test .arff",
                        action="store_true", dest="test", required=False)
    parser.add_argument("-j", help="the path to the java 1.7 binaries",
                        dest="javapath", type=str, required=True)
    
    args = parser.parse_args(sys.argv[1:])

    global isTest
    isTest = args.test

    global javapath
    javapath = args.javapath

    preprocessDir(args.dir, args.part, args.classtype)

if __name__ == "__main__":
    main()
