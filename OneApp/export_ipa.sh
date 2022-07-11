#!/bin/sh
APP_CONFIG="Debug"
APP_SCHEME="Adorawe"

# 获取当前脚本所在目录
APP_PROJECT_DIR="$( cd "$( dirname "$0"  )" && pwd  )"
echo "工程根目录: ${APP_PROJECT_DIR}"

# info.plist路径
APP_PROJECT_INFO_PLIST="${APP_PROJECT_DIR}/${APP_SCHEME}/Info.plist"
echo "APP_PROJECT_INFO_PLIST: ${APP_PROJECT_INFO_PLIST}"
#取版本号
#bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" "${project_infoplist_path}")
#取build值
#bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" "${project_infoplist_path}")
#echo "=================bundleShortVersion bundleVersion================="
#echo "${bundleShortVersion} --- ${bundleVersion}"


DATE="$(date +%Y%m%d%H%M%s)"
IPA_NAME="${APP_SCHEME}_${APP_CONFIG}_${DATE}"
#编译路径
BUILD_PATH="$HOME/Documents/ExportIpa/$APP_SCHEME"
#导出IPA路径
EXPORT_IPA_PATH="${BUILD_PATH}/${IPA_NAME}"
#archivePath
ARCHIVE_PATH="${EXPORT_IPA_PATH}${IPA_NAME}.xcarchive"
#导出ipa 所需plist路径 （方式一：项目路径有文件，使用这个）
#EXPORT_OPTIONS_PATH="./ExportOptions.plist"
EXPORT_OPTIONS_PATH="${APP_PROJECT_DIR}/ExportOptions.plist"
# 指定输出文件目录不存在则创建
if [ -d "$BUILD_PATH" ] ; then
    echo $BUILD_PATH
else
    mkdir -pv $BUILD_PATH
fi


echo "\n\n"
echo "\033[32m+++++++++++++++++开始创建：export_options_plist+++++++++++++++++\033[0m"

#导出ipa 所需plist路径 （方式二：这个使用脚本代码创建）
EXPORT_OPTIONS_PATH="$BUILD_PATH/ExportOptions.plist"

# 先删除export_options_plist文件
if [ -f "${EXPORT_OPTIONS_PATH}" ] ; then
    #echo "${EXPORT_OPTIONS_PATH}文件存在，进行删除"
    rm -f "${EXPORT_OPTIONS_PATH}"
fi


# method，打包的方式。方式分别为 development, ad-hoc, app-store, enterprise 。必填
method="development"

# 项目的bundleID，手动管理Profile时必填
bundle_identifier="com.starlink.adorawe"
bundle_identifier_Notification="com.starlink.adorawe.NotificationService"

# (跟method对应的)mobileprovision文件名，需要先双击安装.mobileprovision文件.手动管理Profile时必填
mobileprovision_name="devAdorawe"
mobileprovision_name_Notification="devAdoraweNotification"

# 根据参数生成export_options_plist文件
/usr/libexec/PlistBuddy -c  "Add :method String ${method}"  $EXPORT_OPTIONS_PATH
/usr/libexec/PlistBuddy -c  "Add :provisioningProfiles:"  $EXPORT_OPTIONS_PATH
/usr/libexec/PlistBuddy -c  "Add :provisioningProfiles:${bundle_identifier} String ${mobileprovision_name}"  $EXPORT_OPTIONS_PATH
/usr/libexec/PlistBuddy -c  "Add :provisioningProfiles:${bundle_identifier_Notification} String ${mobileprovision_name_Notification}"  $EXPORT_OPTIONS_PATH


#签名方式 automatic/manual
/usr/libexec/PlistBuddy -c  "Add :signingStyle String automatic"  $EXPORT_OPTIONS_PATH

# 导出ipa包
# compileBitcode字段的值必须与项目中Build Setting中的bitcode的值一致
#if [ $packageIpaType ] && [ $packageIpaType = "app-store" ] ; then
#    /usr/libexec/PlistBuddy -c  "Add :compileBitcode bool true"  $EXPORT_OPTIONS_PATH
#else
    /usr/libexec/PlistBuddy -c  "Add :compileBitcode bool false"  $EXPORT_OPTIONS_PATH
#fi

echo "\n\n"
echo "\033[32m+++++++++++++++++第一步：clean+++++++++++++++++\033[0m"
xcodebuild -workspace "${APP_SCHEME}.xcworkspace" -scheme "${APP_SCHEME}"  -configuration "${APP_CONFIG}" clean

echo "\n\n"
echo "\033[32m+++++++++++++++++第二步：build+++++++++++++++++\033[0m"
beginTime=`date +%s`

xcodebuild archive -workspace "${APP_SCHEME}.xcworkspace" -scheme "${APP_SCHEME}" -configuration "${APP_CONFIG}" -archivePath "${ARCHIVE_PATH}"

#  检查是否构建成功
#  xcarchive 实际是一个文件夹不是一个文件所以使用 -d 判断
if [ -d "$ARCHIVE_PATH" ] ; then
    echo "\033[32;1m项目构建成功 🚀 🚀 🚀  \033[0m"
else
    echo "\033[31;1m项目构建失败 😢 😢 😢  \033[0m"
    exit 1
fi
endTime=`date +%s`
ArchiveTime="构建编译时间：$[ endTime - beginTime ]秒"
beginTime=`date +%s`

echo "\n\n"
echo "\033[32m+++++++++++++++++第三步：开始导出ipa文件 ++++++++++++++++ \033[0m"
xcodebuild -exportArchive -archivePath "${ARCHIVE_PATH}" -exportPath "${EXPORT_IPA_PATH}" -exportOptionsPlist "${EXPORT_OPTIONS_PATH}"

echo "~~~~~~~~~~~~~~~~检查是否成功导出  ipa~~~~~~~~~~~~~~~~~~~"
EXPORT_IPA_PATH_FILE=${EXPORT_IPA_PATH}/${APP_SCHEME}.ipa

if [ -f "$EXPORT_IPA_PATH_FILE" ]; then
     echo "\033[32m导出ipa成功🚀 🚀 🚀 \033[0m"
else
     echo "\033[32m导出ipa失败😢 😢 😢 \033[0m"
     exit 1
fi
# 结束时间
endTime=`date +%s`
echo "\n\n"
echo "$ArchiveTime"
echo "导出ipa时间：$[ endTime - beginTime ]秒"

echo "\n\n"
echo "\033[32m+++++++++++++++++获取：git 提交记录 ++++++++++++++++ \033[0m"

#蒲公英版本更新描述，这里取git最后一条提交记录作为描述
#Last_MSG=`git log -1 --pretty=%B`
#echo "git last msg: $Last_MSG"
#
###从2021-06-05->2021-06-08
#Log_MSG=`git log --oneline --no-merges --since="2021-06-05" --until="2021-06-08" | awk '{$1="";print $0}'`
#Log_MSG="[jenkins]-----$Log_MSG-----[jenkins]"
#echo "从2021-06-05->2021-06-08: $Log_MSG"
#
###一秒之前，48小时之内
#Log_MSG=`git log --oneline --no-merges --before={1.seconds.ago} --after={48.hours.ago} | awk '{$1="";print $0}'`
#echo "一秒之前，48小时之内:$Log_MSG"
#
###一秒之前，2021-06-07之后
#Log_MSG=`git log --oneline --no-merges --before={1.seconds.ago} --after={2021-06-07} | awk '{$1="";print $0}'`
#echo "一秒之前，2021-06-07之后:$Log_MSG"

##一天之前
#Log_MSG=`git log --oneline --no-merges --before={1.days} | awk '{$1="";print $0}'`
#echo "一天之前:$Log_MSG"

##三天之内
Log_MSG=`git log --oneline --no-merges --after={3.days} | awk '{$1="";print $0}'`
echo "三天之内:$Log_MSG"

##最近一天的代码提交情况
#Log_MSG=`git log --since=1.days`
#echo "最近一天的代码提交情况:$Log_MSG"

##最近一周的代码提交情况
#Log_MSG=`git log --since=1.weeks`
#echo "最近一周的代码提交情况:$Log_MSG"

##最近两次的代码提交情况
#Log_MSG=`git log -p -2`
#echo "最近两次的代码提交情况:$Log_MSG"

echo "\n\n"
echo "\033[32m+++++++++++++++++ 开始上传到蒲公英 ++++++++++++++++ \033[0m"
echo "上传ipa文件路径：${EXPORT_IPA_PATH_FILE}"
#上传到蒲公英
#蒲公英aipKey
MY_PGY_API_K="399cedfde855c67ff5393fd95d0340a1"
#蒲公英uKey
MY_PGY_UK="de20cf81a02f12b2577b6c6fca70ab98"

curl -F "file=@$EXPORT_IPA_PATH_FILE" -F "uKey=$MY_PGY_UK" -F "_api_key=$MY_PGY_API_K" -F "updateDescription=$Log_MSG"  https://www.pgyer.com/apiv1/app/upload

echo "\n\n"
echo "\033[32m+++++++++++++++++ 已运行完毕 ++++++++++++++++ \033[0m"

echo "\n\n"
echo "================= 删除文件 ================="

#删除归档文件 ExportOptions.plist (使用方式二时，可以打开）
#rm -r -f "${EXPORT_OPTIONS_PATH}"

#删除归档文件 xxx.xcarchive
rm -r -f "${ARCHIVE_PATH}"

# 删除文件 Packaging.log
rm -r -f "${EXPORT_IPA_PATH}"
echo "\033[32m+++++++++++++++++ 删除文件完毕 ++++++++++++++++ \033[0m"

echo "\n\n"

exit 0

