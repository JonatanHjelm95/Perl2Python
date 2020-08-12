import csv
from datetime import datetime, timedelta
import requests

# Reads CSV and returns list of dicts
def read_CSV(filename):
    content = open(filename)
    # Creating iterable IOT skip 1st line
    itercontent = iter(content)
    next(itercontent)
    contents = []
    for c in itercontent:
        contents.append(create_dict(c))
    return contents

# Writes list of dicts to CSV  
def write_csv(contents):
    keys  = contents[1].keys()
    with open('reference_metadata_python.csv', 'w') as output_file:
        dict_writer = csv.DictWriter(output_file, keys, lineterminator='\n', delimiter=',')
        dict_writer.writeheader()
        dict_writer.writerows(contents)
        output_file.close()

# Support function -> creates dictionary for ea/line
def create_dict(content):
    lag = "50100"
    camsn = "Pegasus"
    row = {}
    content_split = content.split('\t')
    row['#0:imgID'] = str(content_split[1])
    row['1:Uniqe_id'] = str(content_split[1])+'-'+lag
    row['1:camSN'] = camsn
    row['2:lat'] = str(content_split[2])
    row['3:lon'] = str(content_split[3])
    row['4:height'] = str(content_split[4])
    row['5:roll'] = '0'
    row['6:pitch'] = '0'
    #row['5:roll'] = str(content_split[5])
    #row['6:pitch'] = str(content_split[6])
    row['7:heading'] = str(content_split[7])
    row['8:AcquisitionTime'] = convert_gps(content_split[0])
    row['9:projectedX'] = str(content_split[8])
    row['10:projectedY'] = str(content_split[9])
    row['11:projectedZ'] = float(content_split[10])
    #row['12:Region'] = 'REGION'
    row['12:Region'] = get_region_from_coords(row['2:lat'], row['3:lon'])
    row['13:Roll_Original']= str(content_split[5])
    row['14:Pitch_Original']= str(content_split[6])
    return row

# Support function -> converts GPS time
def convert_gps(gps):
    return datetime(1980, 1, 6) + timedelta(seconds=float(gps) - (38 - 19))

# Requests opencagedata.com to get region from lat/lon
# Rate limit: 2500 requests/day (Free api key)
def get_region_from_coords(lat, lon):
    APIKEY = '5aa69067018f49c1afc09789ade0c69c'
    r = requests.get('https://api.opencagedata.com/geocode/v1/json?q='+str(lat)+'+'+str(lon)+'&key='+APIKEY)
    result = r.json()
    region = str(result['results'][0]['components']['postal_city'])+'-'+str(result['results'][0]['components']['road'])
    #print(region)
    return region.replace('ø','oe').replace('Ø','Oe').replace('æ','ae').replace('Æ','Ae').replace('å','aa').replace('Å', 'Aa')


if __name__ == "__main__":
    #print(get_region_from_coords('55.7164299','12.5807628'))
    contents = read_CSV('reference.csv')
    write_csv(contents)