import subprocess
__author__="Quarknova"

import os
import csv

#alpAlgos = [ "CEDD", "PHOG", "ColorHistogram", "ReferenceColorSimilarity"]
alpAlgos = [ "AutoColorCorrelogram", "Gabor", "CEDD", "PHOG"]
digitAlgos = [ "AutoColorCorrelogram", "Gabor", "CEDD", "PHOG"]

# paths/dirs for image folders
testDir = 'Test-Dir'
alpYesDir = 'ALP-Yes'
alpNoDir = 'ALP-No'
digitNoDir = '4or5-No'
digitYesDir = '4or5-Yes'
sortedImgsPath = os.path.join('.', 'SortedImages')

def writeNewLine(fout):
    fout.write('\n')

def writeLine(fout, str):
    fout.write(str + '\n')

# attrList is the names of the attributes in valueRows
# valueRows is a list of rows of values
def writeArff(directory, filename, relationName, attrList, valueRows):
    dirpath = os.path.join(sortedImgsPath, directory, filename)
    
    arff = open(dirpath, "w")
    
    writeLine(arff, "@RELATION " + relationName)
    writeNewLine(arff)
    # print the numeric attributes
    for attr in attrList[:-1]:
        writeLine(arff, "@ATTRIBUTE " + attr + '\t' + "NUMERIC")
    # ... then print the mode attribute
    writeLine(arff, "@ATTRIBUTE " + attrList[-1] + " { true,false }")
    writeNewLine(arff)
    writeLine(arff, "@DATA")
    writeNewLine(arff)
    for row in valueRows:
        writeLine(arff, ",".join(row))
    
    arff.close()

def genCSV(dirpath, algorithm, classType):
    cmd = "java -jar JFeatureLib-Full.jar --threads 12 -D [algo] -c [class] -d [directory] -o [outfile.csv]"
    
    # split above command into a list. 
    #   [6] is [algo], [8] is [class]
    #   [10] is [directory], [10] is [outfile.csv]
    cmdlist = cmd.split()
    
    # now set the relevant values in the list
    cmdlist[6] = algorithm
    cmdlist[8] = "true" if classType else "false"
    cmdlist[10] = dirpath
    cmdlist[12] = os.path.join(dirpath, algorithm + ".csv") # save file into dir of images as [dirname.csv]
    
    # Now execute the command!
    subprocess.call(cmdlist)
    
    return cmdlist[12]

def preprocessDir(directory, algorithms, classType):
    dirpath = os.path.join(sortedImgsPath, directory)
    # create a csv file for each algorithm type
    csvFiles = []
    for algo in algorithms:
        filename = genCSV(dirpath, algo, classType)
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
        
        '''
        # ensure there is numbered attributes here
        num = 0
        while len(attrRow) < len(file[1]):
            attrRow.append(str(num))
            num += 1
        '''
        
        for j in xrange(2, len(attrRow)):
            attrRow[j] = algoname + attrRow[j]
    
    # remove unneeded filename values and move true/false to end
    for file in loadedFiles:
        for row in file:
            del row[1]  # remove filename vals
            row.append(row[0])
            del row[0]
    # writeArff(filename, relationName, attrList, valueRows):
    arffname = directory + ".arff"
    
    # create attribute list and values list from all the loaded files
    attrList = []
    valueRows = []
    
        # init the valueRows as list of lists
    for i in xrange(0, len(loadedFiles[0])-1):
        valueRows.append([])
        
        # convert from list of files into list of lists
    for i in xrange(0, len(loadedFiles)):
        file = loadedFiles[i]
        # concatenate all the attributes from diff files into a single long list
        attrList.extend(file[0][:-1])
        # concatenate all values for each data point into their respective lists
        for j in xrange(1, len(file)):
            valueRows[j-1].extend(file[j][:-1])
    for list in valueRows:
        list.append(str(classType).lower())
    attrList.append("class")
    
    writeArff(directory, arffname, directory, attrList, valueRows)

def preprocess():
    preprocessDir(alpYesDir, alpAlgos, True)
    preprocessDir(alpNoDir, alpAlgos, False)
    preprocessDir(digitYesDir, digitAlgos, True)
    preprocessDir(digitNoDir, digitAlgos, False)

def main():
    preprocess()
    print "Complete"

if __name__ == "__main__":
    main()