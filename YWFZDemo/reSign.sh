#!/bin/bash

# 签名脚本用法: 脚本带一个需要签名的ipa地址
# 注意: (签名之前必须先安装相应企业证书的p12文件),需要在当前脚本同级目录下放两个(.mobileprovision)描述文件如下:
# 1. embedded.mobileprovision -> (用于项目主Target签名, 注意文件名字不能变)
# 2. notification.mobileprovision -> (用于通知Target签名, 注意文件名字不能变)
# 使用示例: sh reSign.sh /Users/xin610582/Documents/Zaful.ipa

# ipa包路径
ipaPath=$1

# 企业重签名证书名称 (可配置不同证书)
ReSign_Distribution_Name="iPhone Distribution: Shenzhen Jun Meirui Mdt InfoTech Ltd"


if [ $1 ] ; then

    if [ -f "$1" ]; then
        fileSuffix=${ipaPath##*.}
        if [ $fileSuffix="ipa" ]; then
            echo "====== 重签包路径: ${ipaPath} ========"
        else
            echo "====== 传入的文件为非ipa安装包,请检查文件是否正确 ========"
            exit 4
        fi

    else
        echo "====== 文件目录不存在, 请检查文件目录是否正确 ========"
        exit 4
    fi

else
    echo "\033[31;1m ========= 企业包重签名失败,缺少ipa包路径参数 😢 😢 😢 ========= \033[0m"
    exit 4
fi


# 获取当前脚本所在目录
currentScriptDir="$( cd "$( dirname "$0"  )" && pwd  )"


echo "企业重签名: ${ReSign_Distribution_Name}"


ipaFinderPath=${ipaPath%/*}
cd ${ipaFinderPath}
echo "当前目录: $PWD "


# 解压ipa包
unzip ${ipaPath}


#Payload目录
rootPath=${ipaFinderPath}/Payload
echo "Payload目录: ${rootPath} "


#.app名称
appName=${rootPath##*/}
for file in `ls ${rootPath}`
do
    echo $file
    appName=$file
done
echo ".app名称: ${appName} "


#.app包内容路径
ipaPayloadFolderPath=${rootPath}/${appName}/
echo ".app包内容路径: ${ipaPayloadFolderPath} "



#============================== 开始重签名为企业包 ==============================
# 企业包重签名参考地址: http://www.jianshu.com/p/f4cfac861aac
echo "\033[41;36m =========================== 企业包重签名 ========================= \033[0m"


echo "\033[41;36m =========================== 开始重签项目插件 ========================= \033[0m"


# 配置文件插件生成plist的路径
PlugIn_Mobileprovision_Path="${currentScriptDir}/notification.mobileprovision"
PlugIn_Entitlements_Full_Path="PlugIn_Entitlements_Full_Path.plist"
PlugIn_Entitlements_Path="PlugIn_Entitlements_Path.plist"

# 生成plugIn_full.plist文件
security cms -D -i ${PlugIn_Mobileprovision_Path} > ${PlugIn_Entitlements_Full_Path}
# 生成plugIn.plist文件
/usr/libexec/PlistBuddy -x -c 'Print:Entitlements' ${PlugIn_Entitlements_Full_Path} > ${PlugIn_Entitlements_Path}


## 插件文件夹路径
PlugInsFolderPath=${ipaPayloadFolderPath}/PlugIns/NotificationService.appex

# 拷贝notification.mobileprovision配置文件到解压包中(替换embedded文件)
cp "${PlugIn_Mobileprovision_Path}" ${PlugInsFolderPath}/embedded.mobileprovision

# 删除plugIn的签名信息文件
rm -rf ${PlugInsFolderPath}//_CodeSignature/

# 进行插件重签名
/usr/bin/codesign -f -s "${ReSign_Distribution_Name}" --entitlements "${PlugIn_Entitlements_Path}" ${PlugInsFolderPath}



echo "\033[41;36m =========================== 开始重签 ${ipaPath} ========================= \033[0m"

# 删除Taget的签名信息文件
rm -rf ${ipaPayloadFolderPath}//_CodeSignature/

# 配置文件mobileprovision生成plist的路径
Taget_Mobileprovision_Path="${currentScriptDir}/embedded.mobileprovision"
Taget_Entitlements_Full_Path="Taget_Entitlements_Full_Path.plist"
Taget_Entitlements_Path="Taget_Entitlements_Path.plist"

# 生成taget_full.plist文件
security cms -D -i ${Taget_Mobileprovision_Path} > ${Taget_Entitlements_Full_Path}
# 生成taget.plist文件
/usr/libexec/PlistBuddy -x -c 'Print:Entitlements' ${Taget_Entitlements_Full_Path} > ${Taget_Entitlements_Path}


# 拷贝embedded.mobileprovision配置文件到解压包中(替换embedded文件)
cp "${Taget_Mobileprovision_Path}" ${ipaPayloadFolderPath}/


# 遍历第三方动态库Frameworks文件夹进行重签名
FrameworksPath=${ipaPayloadFolderPath}/Frameworks

for file in $FrameworksPath/*; do
    # echo "遍历第三方库文件夹== ${file}"

    # 删除动态库的签名信息文件
    rm -rf ${file}//_CodeSignature/

    # 动态库重新签名 （如果没有其他动态库可以跳过，多个就逐个签吧）
    /usr/bin/codesign -f -s "${ReSign_Distribution_Name}" --entitlements "${Taget_Entitlements_Path}" ${file}/
done


# 最后进行App重签名
/usr/bin/codesign -f -s "${ReSign_Distribution_Name}" --entitlements "${Taget_Entitlements_Path}" ${ipaPayloadFolderPath}


#ipa包名字
ipaName=${ipaPath##*/}

# 压缩文件
zip -r reSign_${ipaName} Payload

# 删除Payload解压后的文件夹
rm -r -f ./Payload

# 删除所有entitlements.plist临时文件
rm -r -f ${Taget_Entitlements_Full_Path}
rm -r -f ${Taget_Entitlements_Path}
rm -r -f ${PlugIn_Entitlements_Full_Path}
rm -r -f ${PlugIn_Entitlements_Path}


#提示重签名状态
if [ $? == 0 ] ; then
    echo "\033[41;36m ================== 🎉 🎉 🎉 恭喜: 企业包重签名成功 ================== \033[0m"

    echo " ======================== 正在上传到fir.im内测平台 ======================== "
    #Fir内测平台Token
    Fir_token="abd8ef25ffa7b620f2e8130ac91dee40"
    #上传到fir, -->上传的是重签名之后的包
    fir publish reSign_${ipaName} -T "${Fir_token}" -c "ZAFUL企业安装包,注意: 此安装包无法测试推送功能"

    echo "\033[41;36m ================== 🎉 🎉 🎉 恭喜: 企业安装包上传fir.im成功 ================== \033[0m"
    open https://fir.im/ZAFULqiye

else
    echo "\033[41;36m ================== 😰😰😰 糟糕, 企业包重签名失败, 请检查原因重试 ================== \033[0m"
    exit 1
fi









