#!/bin/bash
if [ ! -v "ERROR_COLOR" ]; then ERROR_COLOR="\e[31m"; fi
if [ ! -v "SUCCESS_COLOR" ]; then SUCCESS_COLOR="\e[32m" ; fi
if [ ! -v "INFO_COLOR" ]; then INFO_COLOR="\e[34m"; fi
if [ ! -v "RES" ]; then RES="\e[0m"; fi


cleanFile(){
    rm -rf $1/src;
    rm -rf $1/target;
    rm -rf ${LOG_FILE}
    rm -rf ${EXPORT_JAVA_FILE_LIST}
    rm -rf ${EXPORT_CLASS_FILE_LIST}
}
check(){
    if test -d $1;then
        return 0;
    else
        echo -e "${ERROR_COLOR}目录$1 不存在${RES}";
       return 2;
    fi
}

java(){ 

    echo -en "${INFO_COLOR}导出java 文件...${RES}";
    cd $1;
    git diff --name-only --diff-filter=AM "*.java" > ${EXPORT_JAVA_FILE_LIST};
    xargs -a ${EXPORT_JAVA_FILE_LIST} cp --parents -t $2;
    echo -ne "\r";
    echo -e "${SUCCESS_COLOR}导出java文件完成${RES}";
}
class(){
    echo -en "${INFO_COLOR}导出class 文件...${RES}";
    cd $1;
    mvn clean > ${LOG_FILE};
    mvn package >> ${LOG_FILE};
    git diff --name-only --diff-filter=AM "*.java" > ${EXPORT_JAVA_FILE_LIST};
    sed 's/src\/main\/java/target\/classes/g; s/\.java/\.class/g' ${EXPORT_JAVA_FILE_LIST} > ${EXPORT_CLASS_FILE_LIST}
    xargs -a ${EXPORT_CLASS_FILE_LIST} cp --parents -t $2
    echo -ne "\r";
    echo -e "${SUCCESS_COLOR}导出class文件完成${RES}";
}
set -e
echo -e "\033[40;37m 欢迎使用lich java git修改文件导出工具${RES}"

if [ ! -v "WORK_DIRECTORY" ]; then
   if [ $# = 1 ];then
        WORK_DIRECTORY=$(pwd)/export
   else
        check $2
        WORK_DIRECTORY=$2
   fi
fi
if ! test -d $WORK_DIRECTORY;then
    mkdir $WORK_DIRECTORY;
fi
check $1
LOG_FILE=${WORK_DIRECTORY}/export.log
EXPORT_JAVA_FILE_LIST=${WORK_DIRECTORY}/modified_java_files.txt
EXPORT_CLASS_FILE_LIST=${WORK_DIRECTORY}/modified_class_files.txt
echo -e "${INFO_COLOR}工程目录 $1 导出目录$WORK_DIRECTORY";


if [ $# = 2 ] || [ $# = 1 ];then
     cleanFile ${WORK_DIRECTORY}
     java $1 ${WORK_DIRECTORY};
     class $1 ${WORK_DIRECTORY};
elif [ $# = 3 ];then
    echo -e "类型$3${RES}";
    cleanFile ${WORK_DIRECTORY}
    if [ $3 = 'java' ];then
        java $1 ${WORK_DIRECTORY};
    elif [ $3 = 'class' ];then
        class $1 ${WORK_DIRECTORY};
    else
        echo -e "${ERROR_COLOR}参数错误类型只允许java或class，当前为$3${RES}";
    fi
    
else
    echo -e "${ERROR_COLOR}参数个数错误请按照工程目录、导出目录、类型、进行传递${RES}";
fi




