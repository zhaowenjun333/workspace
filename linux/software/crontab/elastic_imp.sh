#!/bin/sh

#说明
#1、修改说明：连接配置和jdk路径
#2、执行说明：elastic_imp.sh user 10000  user为索引名称，10000为每次循环导入数量


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
bin=${DIR}/../bin
lib=${DIR}/../lib


#jdbc连接参数
jdbc_url="jdbc:postgresql://10.163.15.131:5432/wwxiu"
jdbc_user="postgres"
jdbc_pass="pk2014"
#elas参数
elas_cluster="wawatest"
elas_host="10.173.35.136"
elas_port="9300"
elas_url="http://test.wawachina.cn:9200"

#修改jdk路径
export JAVA_HOME=/opt/wwxiu/elasticsearch/jdk1.8.0_91
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$JAVA_HOME/bin:$PATH

#日志路径
curdate=`date +%Y-%m-%d`
#curdate="2016-06-15"
logfile="logs/ela-imp-${curdate}.log"

#每次导入数量
limitnum=10000

cur_index_name=""
cur_import_sql=""
#导入sql缓存。这个sql不会在每次循环中替换。
cur_import_sql_cache=""

max_id=-1
#系统异常，100=查询max_id异常(暂时未用)
sys_error=0


#从elasticsearch中按ID倒序查询当前最大ID 
function queryCurElasticMaxId(){
        #解析最大索引ID，默认为0
        elas_cur_max_id=0
        #sh rm -rf temp_file
        #echo "从elasticsearch中按ID倒序查询max_id,并缓存到临时文件temp_file中">>${logfile}
        cur_els_url=${elas_url}"/"${cur_index_name}
        echo "查询最大ID的cur_els_url=${cur_els_url}">>${logfile}
        curl -o temp_file  -XPOST ''${cur_els_url}'/_search?pretty' -d '{"query":{"bool":{"must":[{"range":{"id":{"gt":"1"}}}],"must_not":[],"should":[]}},"from":0,"size":1,"sort":{ "id" : {"order" : "desc"}},"aggs":{}}'
        last_line=`echo $?`
        if [ $last_line -eq 0 ]
        then
                echo "查询最新max_id成功">>${logfile}
        else
                echo "查询最新max_id失败">>${logfile}
                sys_error=100
        fi
        #echo "开始解析临时文件，获取字段名称和值">>${logfile}

        #解析临时文件，获取字段名称和值  
        arr=(`awk '/"id"/{print $1,$NF}' temp_file`)
        col_name=${arr[0]}
        col_value=${arr[1]}
        #echo "检索的字段名称col_name=$col_name">>${logfile}
        #echo "检索的字段数值col_value=$col_value">>${logfile}


        if [ -z "$col_value" ]
        then
                echo "当前最大索引ID为空，设为0">>${logfile}
                elas_cur_max_id=0
        else
                elas_cur_max_id=${col_value%%,}
        fi    
        echo "查询最新max_id=${elas_cur_max_id}">>${logfile}
        echo $elas_cur_max_id
}

#从DB导入到elasticsearch，接收参数依次是：循环次数、当前最大max_id
function importDataFromDB(){
        #本次导入最大max_id,第二个参数
        cur_max_id=$2
        echo "第$1次导入,limitnum=${limitnum},max_id=${cur_max_id}">>${logfile}

        cur_import_sql=$(setCurImportSQL ${cur_max_id} ${limitnum})
        echo "第$1次导入,执行导入时cur_import_sql=${cur_import_sql}">>${logfile}
	
        #导入数据
	echo "开始导入数据。。。">>${logfile}
        echo '{
                "type" : "jdbc",
                "jdbc" : {
                        "url" : "'${jdbc_url}'",
                        "user" : "'${jdbc_user}'",
                        "password" : "'${jdbc_pass}'",
                        sql :  "'${cur_import_sql}'",
                locale:"zh_CN",
                        elasticsearch : {
                                 "cluster" : "'${elas_cluster}'",
                                 "host" : "'${elas_host}'",
                                 "port" : '${elas_port}'
                        },
                        index : "'${cur_index_name}'",
                        type : "'${cur_index_name}'"
                }
        }
        ' | java \
                -cp "${lib}/*" \
                -Dlog4j.configurationFile=${bin}/log4j2.xml \
                org.xbib.tools.Runner \
                org.xbib.tools.JDBCImporter


}

#循环导入
function startLoopImport(){
        echo "  ">>${logfile}
        echo "开始循环导入">>${logfile}

        #当前导入索引
        #cur_index_name=$1
        #当前导入sql
        #cur_import_sql_a=$2
        #cur_import_sql_b=$3
        echo "当前导入索引cur_index_name=${cur_index_name}">>${logfile}
        echo "当前导入cur_import_sql=${cur_import_sql}">>${logfile}
		
        #从elasticsearch中按ID倒序查询当前最大ID
        cur_loop_max_id=$(queryCurElasticMaxId $cur_index_name)
        
        #当前循环次数
        cur_loop_num=0;

        #上次循环最大max_id
        pre_loop_max_id=-1
        echo "循环导入前,pre_loop_max_id=${pre_loop_max_id},cur_loop_max_id=${cur_loop_max_id}">>${logfile} 
        while [ $pre_loop_max_id -lt $((cur_loop_max_id)) ];
        do
                #累计循环次数
                let ++cur_loop_num;
                echo "  ">>${logfile}
                #开始导入，参数依次是：循环次数、当前最大max_id
                echo "**********************开始第${cur_loop_num}次导入 `date '+%Y-%m-%d %H:%M:%S'`**********************">>${logfile} 
                echo "第$cur_loop_num次导入,pre_loop_max_id=${pre_loop_max_id},cur_loop_max_id=${cur_loop_max_id}">>${logfile} 
                importDataFromDB $cur_loop_num $cur_loop_max_id

                #保存本次cur_loop_max_id到
                pre_loop_max_id=${cur_loop_max_id}

                #从新查询最大max_id
                cur_loop_max_id=$(queryCurElasticMaxId)
                echo "结束本次导入时，pre_loop_max_id=${pre_loop_max_id},cur_loop_max_id=${cur_loop_max_id}">>${logfile}
                echo "**********************结束第${cur_loop_num}次导入 `date '+%Y-%m-%d %H:%M:%S'`**********************">>${logfile} 
                echo "  ">>${logfile}
                #sleep 1;
        done
        return 0;

}

#动态拼接sql
function setCurImportSQLBySplit(){
        sql_max_id=" ${cur_table_id}>"$1
        sql_limitnum="limit "$2
        #echo "sql_max_id=${sql_max_id}">>${logfile}
        #echo "sql_limitnum=${sql_limitnum}  ">>${logfile}
        #echo "cur_import_sql_a=${cur_import_sql_a}">>${logfile}
        #echo "cur_import_sql_b=${cur_import_sql_b}">>${logfile}
        cur_import_sql=${cur_import_sql_a}${sql_max_id}" and "${cur_import_sql_b}" "${sql_limitnum}
        #echo "cur_import_sql=${cur_import_sql}">>${logfile}
}

#动态替换sql
function setCurImportSQL(){
 	 #参数$1为id最大值，参数$2为limitnum
	 sql_max_id=$1
 	 sql_limitnum=$2
	#echo "setCurImportSQL时sql_max_id=${sql_max_id}">>${logfile}
	#注意，cur_import_sql会在每次循环中动态替换，必须用cur_import_sql_cache
	cur_import_sql=${cur_import_sql_cache//param_max_id/${sql_max_id}}
	cur_import_sql=${cur_import_sql//param_limitnum/${sql_limitnum}}
	#echo "setCurImportSQL替换后cur_import_sql=${cur_import_sql}">>${logfile}
	echo ${cur_import_sql}
}

function setLimitNum(){
        #echo "  ">>${logfile}
        if [ -z $1 ]
        then
                echo "第一个参数每次循环最大导入数量参数为空，取默认值为${limitnum}。(设置示例**.sh 100)">>${logfile}
        else
                limitnum=$1
                echo "设置每次循环最大导入数量为limitnum=${limitnum}">>${logfile}
        fi


}

echo "  ">>${logfile}
echo "=======================================开始本次导入索引${index_name} `date '+%Y-%m-%d %H:%M:%S'`=======================================">>${logfile}


#每次导入数量设置，$2为第二个参数
setLimitNum $2

#sql_appad为测试索引。供参考用
#param_max_id、param_limitnum为占位符，在执行中会替换
sql_appad="select id as _id,id,picture,url from fo_app_ad faa where id>param_max_id and deleted = false order by id asc limit param_limitnum"

sql_user="select id as _id,id, picture, display_name from fo_user fu where id>param_max_id and deleted = false order by id asc limit param_limitnum"

sql_child="select id as _id,id, picture, display_name from fo_child fu where id>param_max_id and deleted = false order by id asc limit param_limitnum"

sql_topic="select ftp.id as _id,ftp.id, ppic.picture, ftp.title, ftp.content, ftp.create_time from fo_topic_post ftp left join "
sql_topic=${sql_topic}"(select post_id,picture from fo_topic_post_picture where id in (select min(id) from fo_topic_post_picture where deleted = false group by post_id)) "
sql_topic=${sql_topic}"as ppic on ftp.id = ppic.post_id where ftp.id>param_max_id and ftp.deleted = false order by ftp.id asc limit param_limitnum"

sql_childrecord="select c.id as _id, c.id, d.picture, c.content, c.create_time from ( "
sql_childrecord=${sql_childrecord}"select id,content,create_time from fo_child_record where deleted = false and purview=1 and id>param_max_id order by id limit param_limitnum"
sql_childrecord=${sql_childrecord}") as c left join ( "
sql_childrecord=${sql_childrecord}"select id,child_record_id,picture from fo_child_record_picture where id in( "
sql_childrecord=${sql_childrecord}"select a.id from ( "
sql_childrecord=${sql_childrecord}"select min(id) as id ,t.child_record_id from fo_child_record_picture t where t.child_record_id in( "
sql_childrecord=${sql_childrecord}"select id from fo_child_record where deleted = false and purview=1 and id>param_max_id order by id limit param_limitnum "
sql_childrecord=${sql_childrecord}")  group by t.child_record_id "
sql_childrecord=${sql_childrecord}") as a "
sql_childrecord=${sql_childrecord}") "
sql_childrecord=${sql_childrecord}") as d on c.id = d.child_record_id order by c.id "

case $1 in
appad)
        echo "获取索引参数值为 appad ">>${logfile}        
        cur_index_name="appad"
        cur_import_sql=${sql_appad}
	cur_import_sql_cache=${sql_appad}
        echo "配置文件中import_sql=${cur_import_sql} ">>${logfile}
        startLoopImport
        ;;
child)
        echo "获取索引参数值为 child ">>${logfile}
        cur_index_name="child"
        cur_import_sql=${sql_child}
	cur_import_sql_cache=${sql_child}
        echo "配置文件中import_sql=${cur_import_sql} ">>${logfile}
	startLoopImport
        ;;
user)
        echo "获取索引参数值为 user ">>${logfile}
        cur_index_name="user"
        cur_import_sql=${sql_user}
	cur_import_sql_cache=${sql_user}
        echo "配置文件中import_sql=${cur_import_sql} ">>${logfile}
	startLoopImport
        ;;
childrecord)
        echo "获取索引参数值为 childrecord ">>${logfile}
        cur_index_name="childrecord"
        cur_import_sql=${sql_childrecord}
	cur_import_sql_cache=${sql_childrecord}
        echo "配置文件中import_sql=${cur_import_sql} ">>${logfile}
	startLoopImport
        ;;
topic)
        echo "获取索引参数值为 topic ">>${logfile}
        cur_index_name="topic"
        cur_import_sql=${sql_topic}
	cur_import_sql_cache=${sql_topic}
        echo "配置文件中import_sql=${cur_import_sql} ">>${logfile}
	startLoopImport
        ;;
all)
        echo " index_name=all 会执行import.sh本次，依次会导入child、user、topic、childrecord">>${logfile}
        sh elastic_imp.sh child $2
        sh elastic_imp.sh user $2
        sh elastic_imp.sh topic $2
        sh elastic_imp.sh childrecord $2
        ;;
*)
        echo "请输入导入参数"
        echo "示例：./import.sh child 10000。 child为索引名称，10000为每次导入数量。"
        echo "索引名称可为child、user、topic、childrecord、all。all代表导入所有"
esac

echo "=======================================结束本次导入索引${index_name} `date '+%Y-%m-%d %H:%M:%S'`=======================================">>${logfile}


