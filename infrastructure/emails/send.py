import json

with open('lst', 'r') as lst:
    tree = json.load(lst)

for team in tree:
    pass
    print '%s,%s,%s' % (team['poc_email'].encode('utf-8'), team['name'].encode('utf-8'), team['token'].encode('utf-8'))
