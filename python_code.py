import json
import requests
import pandas as pd
import ast  
## new data
data = {"temperature" : [36, 35, 35.9, 37],
        "nausea": ['yes', 'no', 'no', 'yes'],
        "lumbar_pain": ['no', 'yes', 'yes', 'no'],
        "urine_pushing": ['no', 'no', 'yes', 'yes'],
        "micturition_pain": ['no', 'yes', 'yes', 'no'],
        'burning_swelling_urethra': ['yes', 'no', 'yes', 'yes']}
data = json.dumps(data)
## writing the data to disk to use it later with command line
with open('data.txt', 'w') as f:
    json.dump(ast.literal_eval(data), f)
headers = {'content-type': 'application/json'}
url = 'http://localhost:8080/diagnose'
r = requests.post(url, data = data, headers = headers)
d = json.loads(r.content)
d
## converting it to pandas DataFrame to further analysis
pd.DataFrame(d['results'])

## get method to get the importance of each variable
# url = 'http://localhost:8080/vimp'
# r = requests.get(url)
# d = json.loads(r.content)
# pd.DataFrame(d[0])
#    importance                  variable
# 0       53.52               temperature
# 1       41.02             urine_pushing
# 2       26.75               lumbar_pain
# 3       15.27                    nausea
# 4        5.98  burning_swelling_urethra
# 5        0.53          micturition_pain

