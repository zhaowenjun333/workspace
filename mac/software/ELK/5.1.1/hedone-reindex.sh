#!/bin/sh  chmod 700

curl --user elastic:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-user-*';

curl --user elastic:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-school-*';

curl --user elastic:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-ugcengin-*';

curl --user elastic:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-search-*';

curl --user elastic:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-classsquare-*';

curl --user elastic:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-wwshow-*';

curl --user elastic:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-order-*';

curl --user elastic:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-topic-*';

curl --user elastic:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-live-*';

curl --user elastic:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-question-*';

curl --user elastic:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-system-*';

curl --user elastic:wawa2016 -XDELETE 'http://10.173.35.136:9201/hedone-message-*';

