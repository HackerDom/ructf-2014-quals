#!/usr/bin/python3

import sys

from urllib.request import urlopen, Request
import re
import hashlib
from os.path import join

CATEGORY = 'stegano'
SCORE = 500
NAME = "Echo"

#TODO: Fill!
SHOUTCAST_SERVER = 'http://172.16.16.1:8000/'
SONG_TITLE_REGEX = r'Current Song:</td><td class="streamdata">(?:.+?) - (.+?)</b>'

TIMEOUT = 120

HTML_EN = ''' Don't expect anything original from <a href="http://myradiostream.com/ructf">an echo</a>. '''
HTML_RU = ''' Не ожидайте что-то оригинального от <a href="http://myradiostream.com/ructf">эхо</a>. '''

sys.stdout = open(1, 'w', encoding='utf-8', closefd=False)

if len(sys.argv) < 2:
    print("You need to provide at least one argument", file=sys.stderr)
    exit(1)

action = sys.argv[1].lower()


def md5(mess):
    h = hashlib.md5()
    h.update(mess.encode())
    return h.hexdigest()


def check_task(answer):
    req = Request(SHOUTCAST_SERVER)
    req.add_header('User-Agent', 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.146 Safari/537.36')
    page = urlopen(req).read().decode('utf-8')
    m = re.search(SONG_TITLE_REGEX, page)
    if not m:
        print('Failed to find pattern!')
        return False
    else:
        print('Title: %s' % m.group(1))
        corrent_ans = 'RUCTF_' + md5(m.group(1))
        return corrent_ans == answer



if action == 'id':
    print("{}:{}".format(CATEGORY, SCORE))
elif action == 'series':
    print(CATEGORY)
elif action == 'name':
    print(NAME)
elif action == 'create':
    print("html[en]:{}".format(HTML_EN))
    print("html[ru]:{}".format(HTML_RU))
    print("timeout:" + str(TIMEOUT))
elif action == 'user':
    answer = sys.stdin.readline().strip()
    status = check_task(answer)
    stat = 0 if status else 1
    print("Exiting with " + str(status))
    exit(stat)
else:
    print("No such action: '{}' available actions are: id, series, name, create, user".format(action), file=sys.stderr)
    exit(1)

exit(0)