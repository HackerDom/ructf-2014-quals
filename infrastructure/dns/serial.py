#!/opt/local/bin/python2.7

import datetime, pickle, sys

def get(fn):
    with open(fn, 'r') as df:
        return pickle.load(df)

def put(fn, data):
    with open(fn, 'w') as df:
        return pickle.dump(data, df)

if __name__ == '__main__':
    if len(sys.argv) != 3 or sys.argv[1] not in ['get', 'inc']:
        print >> sys.stderr, 'usage: %s {get|inc} <cache_file>' % sys.argv[0]
        sys.exit(1)
    else:
        cmd, fn = sys.argv[1:3]
        try:
            if cmd == 'inc':
                date, counter = datetime.datetime.now().strftime("%Y%m%d"), 0
                try:
                    olddate, oldcounter = get(fn)
                    if olddate == date:
                        counter = oldcounter + 1
                except:
                    pass
                if counter == 100:
                    raise Exception('overflow for this day')
                put(fn, (date, counter))
            print "%s%02d" % get(fn)
        except Exception as e:
            print >> sys.stderr, e
            sys.exit(1)
