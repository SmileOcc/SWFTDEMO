#!/bin/sh

# 脚本打包用法: <相应参数不传(可都不传)则使用默认参数, 注意参数之间有空格>
# 第一个参数为: 打包的分支名称 <例如: master 。。。>
# 第二个参数为: 打包的方式 <例如: development(默认, 开发期间使用), 或者 app-store(发布上架使用) >
#
# 使用实例: sh export_ipa.sh master development



# 如果脚本传了第一个参数(打包的分支名) 则切换到相应分支代码
if [ $1 ] ; then

    pickIpaBranch=$1

    # 使代码切换到相应分支
    git checkout $pickIpaBranch

    if [ $? == 0 ] ; then
        echo "-------------------- ✅✅✅切换到 ${pickIpaBranch} 分支成功 --------------------"
    else
        echo "-------------------- ❌❌❌切换到 ${pickIpaBranch} 分支成功失败, 请手动解决错误 --------------------"
        osascript -e 'display notification "😰😰😰 糟糕, 切换到 ${pickIpaBranch} 分支成功失败, 请手动解决错误" with title "提示"'
        exit 0
    fi

    echo "-------------------- 开始拉取 ${pickIpaBranch} 分支代码 --------------------"

    # 更新相应分支最新代码
    git pull origin $pickIpaBranch

    if [ $? == 0 ] ; then
        echo "-------------------- ✅✅✅拉取 ${pickIpaBranch} 分支最新代码成功, 开始打包 --------------------"
    else
        echo "-------------------- ❌❌❌拉取 ${pickIpaBranch} 分支最新代码失败, 请手动解决错误 --------------------"
        osascript -e 'display notification "😰😰😰 糟糕, 拉取 ${pickIpaBranch} 分支最新代码失败, 请手动解决冲突" with title "提示"'
        exit 0
    fi

else
    echo "\033[41;36m ======================== 开始本地代码打包 ======================== \033[0m"
fi


# 使用方法:
# step1: 将该脚本放在工程的根目录下（跟.xcworkspace文件or .xcodeproj文件同目录）
# step2: 根据情况修改下面的参数
# step3: 打开终端，执行脚本。（输入sh ，然后将脚本文件拉到终端，会生成文件路径，然后enter就可）

# =============项目自定义部分(自定义好下列参数后再执行该脚本)=================== #

# 是否编译工作空间 (例:若是用Cocopods管理的.xcworkspace项目,赋值true;用Xcode默认创建的.xcodeproj,赋值false)
is_workspace="true"

# .xcworkspace的名字，如果is_workspace为true，则必须填。否则可不填
workspace_name="Zaful"

# .xcodeproj的名字，如果is_workspace为false，则必须填。否则可不填
project_name="Zaful"

# 指定项目的scheme名称（也就是工程的target名称），必填
scheme_name="Zaful"

# 指定要打包编译的方式 : Release,Debug。一般用Release。必填
build_configuration="Release"

# 项目的bundleID，手动管理Profile时必填
bundle_identifier="com.zaful.Zaful"

# App版本号
AppVersion=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ./Zaful/Supporting\ Files/Info.plist`

## build版本号
#BuildVersion=`/usr/libexec/PlistBuddy -c "Print ZAFULBuildNum" ./Zaful/Supporting\ Files/Info.plist`
#BuildVersion=$(($BuildVersion+1))
###这行代码会让ZAFULBuildNum也自增1 (前提是build号必须为整数)
#/usr/libexec/PlistBuddy -c "Set :ZAFULBuildNum $BuildVersion" ./Zaful/Supporting\ Files/Info.plist


##输出git提交日志到gitlog.txt文件 #https://git-scm.com/book/zh/v1/Git-基础-查看提交历史
#git log --oneline > gitlog.txt
git log -41  --pretty=format:"%cn: %s - %ad -%h" > gitlog.txt

##删除Upgrade_desc.txt中含"Merge"的行
sed -e '/Merge/d'  gitlog.txt > configlog.txt

##行首增加行号
awk '$0=""NR"."$0' configlog.txt > Upgrade_desc.txt

##删除文件 gitlog.txt
rm -r -f gitlog.txt
rm -r -f configlog.txt



# method，打包的方式。方式分别为 development, ad-hoc, app-store, enterprise 。必填
method="development"

#  下面两个参数只是在手动指定Pofile文件的时候用到，如果使用Xcode自动管理Profile,直接留空就好
# (跟method对应的)mobileprovision文件名，需要先双击安装.mobileprovision文件.手动管理Profile时必填
mobileprovision_name="ea211f12-b691-4b8a-b9b5-b13b256f9913"

# 打包脚本第二个参数, 不传参数默认为开发测试包, 传app-store则为生产发布包
packageIpaType=$2


# 根据打包脚本参数类型打包
if [ $packageIpaType ] && [ $packageIpaType = "app-store" ] ; then
    method="app-store"
    mobileprovision_name="20656842-b4ad-4ad4-9cfb-89bc697ce303"
fi

echo "--------------------开始打包类型: ${method} --------------------"
echo "--------------------脚本配置参数检查--------------------"
echo "\033[33;1mis_workspace=${is_workspace} "
echo "workspace_name=${workspace_name}"
echo "project_name=${project_name}"
echo "scheme_name=${scheme_name}"
echo "App_version=${AppVersion}"
echo "build_configuration=${build_configuration}"
echo "bundle_identifier=${bundle_identifier}"
echo "method=${method}"
echo "mobileprovision_name=${mobileprovision_name} \033[0m"


# =======================脚本的一些固定参数定义(无特殊情况不用修改)====================== #

# 获取当前脚本所在目录
script_dir="$( cd "$( dirname "$0"  )" && pwd  )"
# 工程根目录
project_dir=$script_dir

# 时间
date=`date '+%Y%m%d'`
date_time=`date '+%Y%m%d_%H%M%S'`
# 指定输出导出文件夹路径
export_path="$HOME/Documents/ExportIpa/$scheme_name-V$AppVersion/$scheme_name-$date"
# 指定输出归档文件路径
export_archive_path="$export_path/$scheme_name.xcarchive"
# 指定输出ipa文件夹路径
export_ipa_path="$export_path"
# 指定输出ipa名称
ipa_name="${scheme_name}_V${AppVersion}_${date_time}_${method}"
# 指定导出ipa包需要用到的plist配置文件的路径
export_options_plist_path="$project_dir/ExportOptions.plist"


echo "--------------------脚本固定参数检查--------------------"
echo "\033[33;1mproject_dir=${project_dir}"
echo "DATE=${DATE}"
echo "export_path=${export_path}"
echo "export_archive_path=${export_archive_path}"
echo "export_ipa_path=${export_ipa_path}"
echo "export_options_plist_path=${export_options_plist_path}"
echo "ipa_name=${ipa_name} \033[0m"

# =======================自动打包部分(无特殊情况不用修改)====================== #

echo "------------------------------------------------------"
echo "\033[32m开始构建项目  \033[0m"
# 进入项目工程目录
cd ${project_dir}

# 指定输出文件目录不存在则创建
if [ -d "$export_path" ] ; then
    echo $export_path
else
    mkdir -pv $export_path
fi

# 判断编译的项目类型是workspace还是project
if $is_workspace ; then
    # 编译前清理工程
    xcodebuild clean -workspace ${workspace_name}.xcworkspace \
    -scheme ${scheme_name} \
    -configuration ${build_configuration}

    xcodebuild archive -workspace ${workspace_name}.xcworkspace \
    -scheme ${scheme_name} \
    -configuration ${build_configuration} \
    -archivePath ${export_archive_path}
else
    # 编译前清理工程
    xcodebuild clean -project ${project_name}.xcodeproj \
    -scheme ${scheme_name} \
    -configuration ${build_configuration}

    xcodebuild archive -project ${project_name}.xcodeproj \
    -scheme ${scheme_name} \
    -configuration ${build_configuration} \
    -archivePath ${export_archive_path}
fi


#  检查是否构建成功
#  xcarchive 实际是一个文件夹不是一个文件所以使用 -d 判断
if [ -d "$export_archive_path" ] ; then
    echo "\033[32;1m项目构建成功 🚀 🚀 🚀  \033[0m"
else
    echo "\033[31;1m项目构建失败 😢 😢 😢  \033[0m"
    exit 1
fi

echo "------------------------------------------------------"

echo "\033[32m开始导出ipa文件 \033[0m"

# 先删除export_options_plist文件
if [ -f "${export_options_plist_path}" ] ; then
    #echo "${export_options_plist_path}文件存在，进行删除"
    rm -f "${export_options_plist_path}"
fi

# 根据参数生成export_options_plist文件
/usr/libexec/PlistBuddy -c  "Add :method String ${method}"  $export_options_plist_path
/usr/libexec/PlistBuddy -c  "Add :provisioningProfiles:"  $export_options_plist_path
/usr/libexec/PlistBuddy -c  "Add :provisioningProfiles:${bundle_identifier} String ${mobileprovision_name}"  $export_options_plist_path

#签名方式 automatic/manual
#/usr/libexec/PlistBuddy -c  "Add :signingStyle String automatic"  $export_options_plist_path


# 导出ipa包
# xcode10以后需要标明Bitcode否则会导出失败
if [ $packageIpaType ] && [ $packageIpaType = "app-store" ] ; then
    /usr/libexec/PlistBuddy -c  "Add :compileBitcode bool true"  $export_options_plist_path
else
    /usr/libexec/PlistBuddy -c  "Add :compileBitcode bool false"  $export_options_plist_path
fi


xcodebuild -exportArchive \
-archivePath ${export_archive_path} \
-exportPath ${export_ipa_path} \
-exportOptionsPlist ${export_options_plist_path} \
-allowProvisioningUpdates

# 检查ipa文件是否存在
if [ -f "$export_ipa_path/$scheme_name.ipa" ] ; then
    echo "\033[32;1mexportArchive ipa包成功,准备进行重命名\033[0m"
else
    echo "\033[31;1mexportArchive ipa包失败 😢 😢 😢     \033[0m"
    exit 1
fi

# 修改ipa文件名称
mv $export_ipa_path/$scheme_name.ipa $export_ipa_path/$ipa_name.ipa

# 检查文件是否存在
if [ -f "$export_ipa_path/$ipa_name.ipa" ] ; then
    echo "\033[32;1m导出 ${ipa_name}.ipa 包成功 🎉  🎉  🎉   \033[0m"
    open $export_path
else
    echo "\033[31;1m导出 ${ipa_name}.ipa 包失败 😢 😢 😢     \033[0m"
    exit 1
fi

# 删除归档文件 ExportOptions.plist
rm -r -f "${export_options_plist_path}"

# 删除归档文件 Zaful.xcarchive
rm -r -f "${export_archive_path}"

# 删除文件 Packaging.log
rm -r -f "${export_archive_path}"



# 输出打包总用时
echo "\033[36;1m使用AutoPackageScript打包总用时: ${SECONDS}s \033[0m"

# 根据打包脚本参数类型打包
if [ $packageIpaType ] && [ $packageIpaType = "app-store" ] ; then

    #==============================发布到iTunesConnect分两步 ==============================
    #学习上传命令: http://help.apple.com/itc/apploader/#/apdATD1E53-D1E1A1303-D1E53A1126
    echo "\033[41;36m ================= 正在iTunesConnect中验证ipa。。。 =================\033[0m"

    #altool工具路径 (这个是系统altool路径,是固定的)
    AltoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
    #需要上传至iTunes Connect的本地ipa包地址
    Upload_IpaPath="${export_ipa_path}/${ipa_name}.ipa"
    #开发者账号（邮箱）
    AppleId="wiseon@zaful.com"
    #开发者账号的密码
    ApplePassword="HQYGzaful@2018"

    #======1、验证ipa包是否成功 ======
    "$AltoolPath" --validate-app -f "${Upload_IpaPath}" -u "${AppleId}" -p "${ApplePassword}" --output-format xml

    #弹框通知提示验证ipa包结果状态
    if [ $? == 0 ] ; then
        echo "\033[41;36m ============ 🎉🎉🎉 恭喜 iTunesConnect验证ipa成功, 正在上传ipa包至iTunes Connect。。。============ \033[0m"
        echo "\033[41;36m  。。。✈️ \033[0m"
        echo "\033[41;36m  。。。✈️。。。✈️ \033[0m"
        echo "\033[41;36m  。。。✈️。。。✈️。。。✈️ \033[0m"
    else
        say '糟糕, iTunes Connect验证ipa包失败!'
        osascript -e 'display notification "😰😰😰 糟糕, 验证ipa包失败!!!" with title "提示"'
        exit 1
    fi


    #======2、上传ipa包到iTunes Connect ======
    "$AltoolPath" --upload-app -f "${Upload_IpaPath}" -u "${AppleId}" -p "${ApplePassword}" --output-format xml

    #弹框通知提示上传结果状态
    if [ $? == 0 ] ; then
        say '恭喜,上传iTunes Connect成功!'
        osascript -e 'display notification "🎉🎉🎉 恭喜,上传iTunes Connect成功!!!" with title "提示"'
        echo "\033[41;36m ==========脚本执行结束正常退出, 此次打包类型: ${method}, 路径为:${Upload_IpaPath} ========== \033[0m"
    else
        echo "\033[41;36m ============ 🎉🎉🎉 糟糕 iTunesConnect验证ipa失败, 请检查错误============ \033[0m"
        say '糟糕, 上传iTunes Connect失败!'
        osascript -e 'display notification "😰😰😰 糟糕, 上传iTunes Connect失败!!!" with title "提示"'
    fi

else

    echo "\033[41;36m ======================== 正在上传到fir.im内测平台 ======================== \033[0m"

    #Fir内测平台Token
    Fir_token="38dc649ff78591313e24905c098e61e1"
    #版本更新信息 (Upgrade_desc.txt 此文件为版本的更新描述,需要放在项目的.xcodeproj的同一级)
    UpgradeDesc=$(<Upgrade_desc.txt)
    #上传到fir, -->上传的是未重签名之后的包
    fir publish "${export_ipa_path}/${ipa_name}.ipa" -T "${Fir_token}" -c "${UpgradeDesc}"

    #弹框通知提示验证ipa包结果状态
    if [ $? == 0 ] ; then

        #打开web扫码下载页面
        open https://fir.im/ZAFUL
        echo "\033[41;36m  🎉 🎉 🎉 恭喜: 上传fir.im成功！请到App主页内部点击安装或从Web端(https://fir.im/ZAFUL)扫码下载最新版App  \033[0m "
        osascript -e 'display notification "🎉 🎉 🎉 恭喜: 上传fir.im成功！请到App主页内部点击安装或从Web端(https://fir.im/ZAFUL)扫码下载最新版App" with title "提示"'

        #发送邮件
        sh sendEmail.sh $Re_Ipa_Path

        # 删除多余的Upgrade_desc.txt文件
        ###rm -r -f Upgrade_desc.txt #暂时不要删除每次脚本打包会上传打包记录

    else
        echo "\033[41;36m ============ 🎉🎉🎉 糟糕 上传fir.im失败, 请检查错误============ \033[0m"
        say '糟糕, 上传fir.im失败!!!'
        osascript -e 'display notification "😰😰😰 糟糕, 上传fir.im失败!!!" with title "提示"'
        # exit 1 //上传失败也做企业签名
    fi

    # 执行企业重签名脚本
    sh reSign.sh "${export_ipa_path}/${ipa_name}.ipa"

fi

exit 0

