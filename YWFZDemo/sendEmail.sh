
#首先需要安装sendemail，使用命令：brew install sendemail

#命令主程序
#/usr/local/bin/sendEmail

#发件人邮箱的用户名,(不知道这里为什么用户名一定要写邮箱地址，否则发送失败)
SendUserName="xx@xx.com"
#发件人邮箱
SendAddress="xx@xx.com"
#发件人邮箱密码
SendAddressPwd="xx"
#发件人邮箱的smtp服务器:（例如: smtp.163.com）
EmailServer="newmailf.xx.com"

#收件箱
ReceiveAddress="xx@xx.com,aa@aa.com"


#邮件内容格式
EmailType="message-content-type=html"
#邮件内容编码
EmailCharset="message-charset=utf-8"
#邮件的标题
EmailTitle="Zaful iOS端发Beta版新测试包啦"

#解决SendEmail标题中文乱码问题  http://blog.chinaunix.net/uid-29787409-id-5607573.html
Email_Title_gb2312=`iconv -t GB2312 -f UTF-8 << EOF
$EmailTitle`
[ $? -eq 0 ] && Email_Title="$Email_Title_gb2312"

#邮件的具体内容
EmailContent="此次修复具体内容见附件txt文件, 可直接在App首页顶部点击 [安装最新内测版] 直接安装, 也可扫码安装点击链接: https://xxx \n \n \n 备注:这是打包自动发送邮件,如有打扰请忽略,谢谢!"

#脚本参数传入附件地址
Ipa_path=$1
if [ $Ipa_path ] ; then
    Attachment_path=$Ipa_path
else
    Attachment_path="./Upgrade_desc.txt"
fi

#开始发送邮件
/usr/local/bin/sendEmail \
-xu "${SendUserName}" \
-f "${SendAddress}" \
-xp "${SendAddressPwd}" \
-s "${EmailServer}" \
-t "${ReceiveAddress}" \
-o "${EmailType}" \
-m "${EmailContent}" \
-o "${EmailCharset}" \
-u "${Email_Title}" \
-a "${Attachment_path}"

echo "====== ☕️ ☕️ ☕️ 正在发送邮件中 。。。======"

#提示邮件是否发送成功
if [ $? == 0 ] ; then

    echo "====== 🎉 🎉 🎉  邮件发送成功 ======"

else
    echo "====== 😰😰😰  邮件发送失败 ======"
    osascript -e 'display notification "😰😰😰 糟糕, 发送邮件失败！！" with title "提示"'
fi
