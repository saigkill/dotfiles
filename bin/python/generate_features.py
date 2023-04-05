#!/usr/bin/python
# (c) 2009 by Jan-Simon Möller <dl9pf@opensuse.org> and Sascha Manns <saigkill@opensuse.org>
# This script just searches the opensuse-features mailinglist for posts written max 7 days ago. Then it transforms it to the Wiki Layout for using in the openSUSE Weekly News.

import datetime
import sys
import feedparser

def strip_ml_tags(in_text):
	"""Description: Removes all HTML/XML-like tags from the input text.
	Inputs: s --> string of text
	Outputs: text string without the tags
	
	# doctest unit testing framework

	>>> test_text = "Keep this Text <remove><me /> KEEP </remove> 123"
	>>> strip_ml_tags(test_text)
	'Keep this Text  KEEP  123'
	"""
	# convert in_text to a mutable object (e.g. list)
	s_list = list(in_text)
	i,j = 0,0
	
	while i < len(s_list):
		# iterate until a left-angle bracket is found
		if s_list[i] == '<':
			while s_list[i] != '>':
				# pop everything from the the left-angle bracket until the right-angle bracket
				s_list.pop(i)
				
			# pops the right-angle bracket, too
			s_list.pop(i)
		else:
			i=i+1
			
	# convert the list back into text
	join_char=''
	return join_char.join(s_list)


timenow = datetime.datetime.utcnow()

day1 = timenow.day
day2 = timenow.strftime("%d")
month1 = timenow.month
month2 = timenow.strftime("%m")
year4 = timenow.year
myday = day1
mymonth = month1
myyear = year4

print "Jahr:  "+str(year4)," Monat: "+str(month1)," Tag:   "+str(day1)

URL = "http://lists.opensuse.org/opensuse-features/mailinglist.rss"

d = feedparser.parse(URL)

entr = d['entries']

for i in entr:
# print i
# print
# print i['summary_detail']
 if i['summary_detail'].has_key('value'):
  value = i['summary_detail']['value']
#  print value
# print
# print

data = {}
for i in entr:
 data[i['id']] = [i['updated_parsed'],i['title'],i['summary'] , ]



articles = {}
rang = range(1,7)
#print rang
rang.reverse()
#print rang
myindex = 0
for k in data.keys():
    for i in rang:
        #print k
        #print data[k][1]
        #print data[k][2]
#        print data[k][0]
        thisyear = data[k][0][0]
        thismonth = data[k][0][1]
        thisday = data[k][0][2]
#        print "%s.%s.%s" % (thisyear, thismonth, thisday)
        if not thisyear == myyear:
            continue
#        if int(myday) in range(1,10):
#            mynewmonth = int(mymonth)-1
#            if thismonth == mynewmonth:
#                diff = int(myday)-int(thisday)
#                if diff == i:
#                    articles[k]=[data[k][0], data[k][1], strip_ml_tags(data[k][2])]
        else:
#            print (int(thismonth)-int(mymonth))
            if not thismonth == mymonth:
                continue
            else:
                diff = int(myday)-int(thisday)
                if diff == i:
                    articles[k]=[data[k][0], data[k][1], strip_ml_tags(data[k][2]), k]
    myindex = myindex+1
#print data[k][2]
#print articles
iterate=articles.keys()
iterate.sort()
#iterate.reverse()
for k in iterate:
# print k
 date=articles[k][0]
 subj=articles[k][1]
 url=articles[k][3]
 #print articles[k][2]
# print date
 x=articles[k][2].splitlines()
#print "====["+str(url)+" "+str(str(subj).split("]")[1].strip())+"]===="
 print '<listitem>'
 print '<para><ulink url="'+str(url)+'">'+str(str(subj).split("]")[1].strip())+'</ulink></para>'
 print '</listitem>'
#print "#####################"
 y = []
 for line in range(0,10):
   y.append(x[line])
 short = "".join(y)
 #print short
 #print "*''\""+short+"\"''"
   
#for n in articles.values():
# print n

#print strip_ml_tags(data[k][2])