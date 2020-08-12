### HOW TO USE ###

# EXAMPLE USAGE: python vejdir_index2metadata.py fileinput.csv outputname -l lag -R København -c cameraname -r 1 -p 1 
#Mandatory args
# -f = fileinput
# -o = fileoutput
# -l = lag
#Optional args
# -R = Region string
# -c = camera
# -r = roll
# -p = pitch
##################

import csv
import argparse
from datetime import datetime, timedelta
import requests

# Reads CSV and returns list of dictionaries
def read_CSV(filename, args):
    content = open(filename)
    # Creating iterable IOT skip 1st line
    itercontent = iter(content)
    next(itercontent)
    contents = []
    for c in itercontent:
        contents.append(create_dict(c, args))
    return contents

# Writes list of dicts to CSV  
def write_csv(contents, output):
    keys  = contents[1].keys()
    if '.csv' not in str(output):
        output = str(output)+'.csv'
    with open(output, 'w') as output_file:
        dict_writer = csv.DictWriter(output_file, keys, lineterminator='\n', delimiter=',')
        dict_writer.writeheader()
        dict_writer.writerows(contents)
        output_file.close()

# Support function -> creates dictionary for ea/line
def create_dict(content, args):
    # setting arguments
    lag, roll, pitch, camsn, region = set_args(args)
    # Creating dictionary object
    row = {}
    # Splitting on \t
    content_split = content.split('\t')
    # Setting values
    row['#0:imgID'] = str(content_split[1])
    row['1:Uniqe_id'] = str(content_split[1])+'-'+lag
    row['1:camSN'] = camsn
    row['2:lat'] = str(content_split[2])
    row['3:lon'] = str(content_split[3])
    row['4:height'] = str(content_split[4])
    row['5:roll'] = roll
    row['6:pitch'] = pitch
    row['7:heading'] = str(content_split[7])
    row['8:AcquisitionTime'] = convert_gps(content_split[0])
    row['9:projectedX'] = str(content_split[8])
    row['10:projectedY'] = str(content_split[9])
    row['11:projectedZ'] = float(content_split[10])
    row['12:Region'] = region
    row['13:Roll_Original']= str(content_split[5])
    row['14:Pitch_Original']= str(content_split[6])
    return row

# Support function -> returns lag, roll, pitch, camsn and region with default values if empty
def set_args(args):
    #Roll
    if args.roll is not None:
        roll = args.roll
    else:
        roll = '0'
    #Pitch
    if args.pitch is not None:
        pitch = args.pitch
    else:
        pitch = '0'
    #Camsn
    if args.cam is not None:
        camsn = args.cam
    else:
        camsn = 'CAM'
    #Region
    if args.region is not None:
        region = convert_special_letters(str(args.region))
    else:
        region = 'REGION'
    return args.lag, roll, pitch, camsn, region 


# Support function -> converts æ,ø,å
def convert_special_letters(region):
    return region.replace('ø','oe').replace('Ø','Oe').replace('æ','ae').replace('Æ','Ae').replace('å','aa').replace('Å', 'Aa')


# Support function -> converts GPS time
def convert_gps(gps):
    # Converts date to string and returns anything before '.'
    return str(datetime(1980, 1, 6) + timedelta(seconds=float(gps) - (38 - 19))).split('.')[0]

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    #Mandatory 
    parser.add_argument('fileinput', help='fileinput path')
    parser.add_argument('fileoutput', help='fileoutput path')
    parser.add_argument('-l', '--lag', help='lag', required=True)
    #Optionals
    parser.add_argument('-R', '--region', help='region', required=False)
    parser.add_argument('-c', '--cam', help='cameraname', required=False)
    parser.add_argument('-r', '--roll', help='roll, Default value=0', required=False)
    parser.add_argument('-p', '--pitch', help='pitch, Default value=0', required=False)

    args = parser.parse_args()
    filename = args.fileinput
    output = args.fileoutput
    contents = read_CSV(filename=filename, args=args)
    write_csv(contents, output)