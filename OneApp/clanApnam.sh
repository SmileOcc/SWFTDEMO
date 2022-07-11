#! /bin/bash

#写一个函数，调用的时候不用带括号

sourceNameArray=("Adorawe" "Soulmia" "VIVAIA")
function r(){
echo $1
echo $2
#for循环 这个``是esc下面的，意思是调用系统命令；$1指的是传进去函数里的第一变量
    rootDir=$1
    for file in `ls $1`
    do
        #这里的判断是判断是否为目录
        if [ -d $1"/"$file ]; then

            echo "文件:"$file
           #我这里的两个判断是我需要排除对这两个目录的遍历
            if [ $file == "xxx" ]; then
                echo $file"此目录排除，不替换"
            else
                #用一种递归的方法来遍历子目录
               echo $1"/"$file"为目录"
                r $1"/"$file $2
            fi
        else
            #替换文件里的bp.datacastle.cn为bp.inedcn.com
            echo $1"/"$file "为文件"
            
            #echo'路径：'$firePath
            #mac上使用的是bsd，而linux上使用的是gnu。
            #bsd的find命令第一个参数必须指定目录路径，而gnu可以省略第一个参数
            #linux 不需要 find  -name
            # manc上需要用 find . -name
            if echo "$file" | grep -q -E '\.strings$'; then
                echo "文件名："$file"  开始替换 "
                firePath=$1"/"$file

                for(( i=0;i<${#sourceNameArray[@]};i++)) do
                    tempName=${sourceNameArray[i]}
                    echo "查找name: "$2"  --->"$tempName
                    if [ $2 != $tempName ]; then
                        if [ `grep -c "$tempName" $firePath` -ne '0' ];then
                            echo " ===Found!==  "$tempName

                            if [ $2 == "Adorawe" ]; then

                                #邮箱中有@符号，需要特殊处理
                                newAppEmail="service\@adorawe.net"
                                newAppName="Adorawe"
                                oldAppName=$tempName
#                                oldAppEmail="testcc\@cc.net"
#                                if [ $tempName == "Soulmia" ]; then
#                                    oldAppEmail="support\@soulmiacollection.com"
#                                elif [ $tempName == "VIVAIA" ]; then
#                                    oldAppEmail="support\@vivaiacollection.com"
#                                fi
                                
                                sOldAppEmail="support\@soulmiacollection.com"
                                vOldAppEmail="support\@vivaiacollection.com"

                                
                                echo "oldApp:  "$oldAppName"   newApp:  "$newAppName
                                echo "oldEami:  "$oldAppEmail"   newEmail:  "$newAppEmail
                                find $1 -name $file | xargs perl -pi -e "s|"$oldAppName"|"$newAppName"|g"
                                find $1 -name $file | xargs perl -pi -e "s|"$sOldAppEmail"|"$newAppEmail"|g"
                                find $1 -name $file | xargs perl -pi -e "s|"$vOldAppEmail"|"$newAppEmail"|g"

                            elif [ $2 == "Soulmia" ]; then

                                newAppEmail="support\@soulmiacollection.com"
                                newAppName="Soulmia"
                                oldAppName=$tempName
#                                oldAppEmail="testcc\@cc.net"
#                                if [ $tempName == "Adorawe" ]; then
#                                    oldAppEmail="service\@adorawe.net"
#                                elif [ $tempName == "VIVAIA" ]; then
#                                    oldAppEmail="support\@vivaiacollection.com"
#                                fi
                                aOldAppEmail="service\@adorawe.net"
                                vOldAppEmail="support\@vivaiacollection.com"
                                
                                echo "oldApp:  "$oldAppName"   newApp:  "$newAppName
                                echo "oldEami:  "$oldAppEmail"   newEmail:  "$newAppEmail
                                find $1 -name $file | xargs perl -pi -e "s|"$oldAppName"|"$newAppName"|g"
                                find $1 -name $file | xargs perl -pi -e "s|"$aOldAppEmail"|"$newAppEmail"|g"
                                find $1 -name $file | xargs perl -pi -e "s|"$vOldAppEmail"|"$newAppEmail"|g"


                            elif [ $2 == "VIVAIA" ]; then

                                newAppEmail="support\@vivaiacollection.com"
                                newAppName="VIVAIA"
                                oldAppName=$tempName
#                                oldAppEmail="testcc\@cc.net"
#                                if [ $tempName == "Adorawe" ]; then
#                                    oldAppEmail="service\@adorawe.net"
#                                elif [ $tempName == "Soulmia" ]; then
#                                    oldAppEmail="support\@soulmiacollection.com"
#                                fi
                                
                                aOldAppEmail="service\@adorawe.net"
                                sOldAppEmail="support\@soulmiacollection.com"
                                
                                echo "oldApp:  "$oldAppName"   newApp:  "$newAppName
                                echo "oldEami:  "$oldAppEmail"   newEmail:  "$newAppEmail
                                find $1 -name $file | xargs perl -pi -e "s|"$oldAppName"|"$newAppName"|g"
                                find $1 -name $file | xargs perl -pi -e "s|"$aOldAppEmail"|"$newAppEmail"|g"
                                find $1 -name $file | xargs perl -pi -e "s|"$sOldAppEmail"|"$newAppEmail"|g"

                            fi
                        fi
                    fi
                done

            fi
        fi
    done
}




function start(){
    if [ $1 == "" ] || [ $2 == ""]; then
        echo "dir:"$1
        echo "key:"$2
        echo "关键路径或key不能为空，示例：xxx.sh /Users/odd/Documents/DemoA/Language DemoA"
        exit
    fi
    #调用
    r $1 $2
}

start $1 $2
