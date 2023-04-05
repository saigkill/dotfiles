#!/usr/bin/python2
# -*- coding: utf-8 -*-
# (c) 2009 by Jan-Simon Möller <dl9pf@opensuse.org> and Sascha Manns <saigkill@opensuse.org>
# This script just searches the opensuse-events mailinglist for posts written max 7 days ago. Then it transforms it to the Wiki Layout for using in the openSUSE Weekly News.
import datetime
from icalendar import Calendar, Event
import httplib
import sys


conn = httplib.HTTPConnection("news.opensuse.org")
conn.request("GET", "/?ec3_ical")
r1 = conn.getresponse()
if not r1.status == 200:
 print "Http connetion failure"
 sys.exit(0)
data1 = r1.read()
cal = Calendar.from_string(data1)
x = []
for calobject in cal.walk():
 x.append(calobject)

datedict = {}

for i in range(1,x.__len__()):
 k=x[i]
 s=k['SUMMARY'].__str__()
 u=k['URL'].__str__()
 tstr=k['DTSTART'].dt.strftime("%B %d, %Y")
 t=k['DTSTART'].dt.strftime("%Y%m%d")
 datedict[t]=[u, s, tstr]

#print datedict

timenow = datetime.datetime.utcnow()
stringnow = timenow.strftime("%Y%m%d")
intnow = int(stringnow)

last10 = []
#last 10 days
#print "LAST 10 DAYS"
#print "############"
ra = range(0,10)
ra.reverse()
for n in ra:
    for i in datedict.keys():
     intthen = int(i)
#     print intnow
#     print intthen
     a = (intnow - intthen)
     if a == n:
#         print n
#         print datedict[i]
         last10.append(datedict[i])


next10 = []
#print "NEXT 20 DAYS"
#print "############"

# next 20 days
for n in range(0,20):
    for i in datedict.keys():
     intthen = int(i)
#     print intnow
#     print intthen
     a = (intthen - intnow)
     if a == n:
#         print n
#         print datedict[i]
         next10.append(datedict[i])
print "################### LAST ###########################################>"

for i in last10:
    u,s,tstr = i
    print "<listitem>"
    print '<para><ulink url="'+str(u)+'">'+str(tstr)+' : '+str(s)+'</ulink></para>'
    print "</listitem>"
print "################### NEXT ###########################################"

for i in next10:
    u,s,tstr = i
    print "<listitem>"
    print '<para><ulink url="'+str(u)+'">'+str(tstr)+' : '+str(s)+'</ulink></para>'
    print "</listitem>"

 
