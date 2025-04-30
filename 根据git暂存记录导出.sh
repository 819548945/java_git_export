#!/bin/bash
ERROR_COLOR="\e[31m"
SUCCESS_COLOR="\e[32m"
INFO_COLOR="\e[34m"
RES="\e[0m"

createDir(){
    rm -rf $1;
    mkdir $1;
}
check(){
    if test -d $1;then
         if test -d $2;then
            return 0;
         else
            echo -e "${ERROR_COLOR}导出目录$2 不存在${RES}";
            return 2;
         fi
    else
        echo -e "${ERROR_COLOR}工程目录$1 不存在${RES}";
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
WORK_DIRECTORY=$2/export
LOG_FILE=${WORK_DIRECTORY}/export.log
EXPORT_JAVA_FILE_LIST=${WORK_DIRECTORY}/modified_java_files.txt
EXPORT_CLASS_FILE_LIST=${WORK_DIRECTORY}/modified_class_files.txt
if [ $# = 2 ];then
  echo -e "${INFO_COLOR}工程目录 $1 导出目录$2";
  if check $1 $2;then
     createDir ${WORK_DIRECTORY}
     java $1 ${WORK_DIRECTORY};
     class $1 ${WORK_DIRECTORY};
  fi
elif [ $# = 3 ];then
    echo -e "${INFO_COLOR}工程目录 $1 导出目录$2 类型$3${RES}";
    if check $1 $2;then
        createDir ${WORK_DIRECTORY}
        if [ $3 = 'java' ];then
            java $1 ${WORK_DIRECTORY};
        elif [ $3 = 'class' ];then
            class $1 ${WORK_DIRECTORY};
        else
            echo -e "${ERROR_COLOR}参数错误类型只允许java或class，当前为$3${RES}";
        fi
    fi
else
    echo -e "${ERROR_COLOR}参数个数错误请按照工程目录、导出目录、类型、进行传递${RES}";
fi




