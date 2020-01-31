import os 
import json
print(os.environ)

data = {
    "subscription_id": "",
    "resource_group": "",
    "workspace_name": ""
}

with open('config.json', 'w') as outfile:
    json.dump(data, outfile)