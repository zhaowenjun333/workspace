#!/bin/sh  chmod 700

curl --user logstash:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-user-${nDaysago}';

curl --user logstash:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-school-${nDaysago}';

curl --user logstash:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-ugcengin-${nDaysago}';

curl --user logstash:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-search-${nDaysago}';

curl --user logstash:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-classsquare-${nDaysago}';

curl --user logstash:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-wwshow-${nDaysago}';

curl --user logstash:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-order-${nDaysago}';

curl --user logstash:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-topic-${nDaysago}';

curl --user logstash:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-live-${nDaysago}';

curl --user logstash:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-question-${nDaysago}';

curl --user logstash:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-system-${nDaysago}';

curl --user logstash:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-message-${nDaysago}';


