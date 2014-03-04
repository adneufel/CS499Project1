import os
import sys
import argparse
from shutil import copyfile

def combineArffs(outfilename, argfiles):
    # create output file by copying the first argfile to output loc
    copyfile(argfiles[0], outfilename)
    
    # now concatenate all data from other argfiles to outfilename
    outfile = open(outfilename, "a")
    for filename in argfiles[1:]:
        infile = open(filename)
        filelines = infile.readlines()
        
        # find the "@DATA" line, then add 2 to get the first comma seperated list of data
        datastart = filelines.index("@DATA\n") + 2
        for line in filelines[datastart:]:
            outfile.write(line)
        
        infile.close()
    outfile.close()

def main():
    parser = argparse.ArgumentParser(description='Process some integers.')
    parser.add_argument("-n", help="name of the output file",
                        dest="output", type=str, required=True)
    parser.add_argument("-f", help="path to the files",
                        dest="files", type=str, nargs="*", required=True)
    
    args = parser.parse_args(sys.argv[1:])
    
    # ensure there are more than one arff file to combine
    if len(args.files) < 2:
        print "\nError: must pass 2 or more files to option '-f'\n"
        exit(1)
    
    # check to make sure they are all .arff files
    for item in args.files:
        filename, fileext = os.path.splitext(item)
        if fileext != ".arff":
            print "\nError: one of the files passed is not an .arff file!\n"
            exit(1)
    
    combineArffs(args.output, args.files)

if __name__ == "__main__":
    main()
