#!/bin/bash
source ~/.bash_profile

export LC_CTYPE=en_US.UTF-8

#获取项目路径
PROJECT_DIR=$(cd `dirname $0`;cd ..;pwd)
cd ${PROJECT_DIR}

buildPath="${PROJECT_DIR}/oclint/build"
compilecommandsJsonFolderPath="${PROJECT_DIR}/oclint"
compilecommandsJsonFilePath="${PROJECT_DIR}/oclint/compile_commands.json"

rm -rf "$compilecommandsJsonFolderPath/build"

#xcodebuild SYMROOT=$buildPath -scheme YouXinZhengQuan -workspace YouXinZhengQuan.xcworkspace clean
xcodebuild SYMROOT=$buildPath -scheme YouXinZhengQuan -workspace YouXinZhengQuan.xcworkspace build | xcpretty -r json-compilation-database --output $compilecommandsJsonFilePath

cd $compilecommandsJsonFolderPath

#oclint-json-compilation-database -exclude Pods -exclude build -exclude Internal -exclude ThirdParties -- -report-type html -o report.html

oclint-json-compilation-database -e Pods -- -report-type html -o report.html \
-rc CYCLOMATIC_COMPLEXITY=10 \
-rc LONG_CLASS=1000 \
-rc LONG_METHOD=50 \
-rc LONG_LINE=140 \
-rc LONG_VARIABLE_NAME=30 \
-rc SHORT_VARIABLE_NAME=1 \
-rc MAXIMUM_IF_LENGTH=5 \
-rc MINIMUM_CASES_IN_SWITCH=2 \
-rc NCSS_METHOD=30 \
-rc NESTED_BLOCK_DEPTH=5 \
-rc TOO_MANY_METHOD=30 \
-rc TOO_MANY_PARAMETERS=5 \
-max-priority-1 0 \
-max-priority-2 5 \
-max-priority-3 10
