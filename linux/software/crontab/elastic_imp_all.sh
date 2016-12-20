#!/bin/sh

#crontab 参考配置。示例每10分钟执行一次
#*/10 * * * * /opt/wwxiu/elasticsearch/elasticsearch-jdbc-master/elasticimport/elastic_imp_all.sh >> /opt/wwxiu/elasticsearch/elasticsearch-jdbc-master/elasticimport/logs/crontab.log

echo ""
echo "==========定时导入任务开始 `date '+%Y-%m-%d %H:%M:%S'`=========="
echo "执行elastic_imp.sh all 10 每次导入10条数据"
sh elastic_imp.sh all 10
echo "==========定时导入任务结束 `date '+%Y-%m-%d %H:%M:%S'`=========="
