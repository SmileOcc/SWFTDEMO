
#encoding:utf-8

import getpass
import time
import os
import xlrd

# 解决编码报错，详情见https://www.cnblogs.com/yuyu666/p/10509453.html
import sys
reload(sys)
sys.setdefaultencoding('utf8')

# 当前文件的上级目录路径
path = os.path.dirname(os.getcwd())
allLines = []

# 打开excel表格
workbook = xlrd.open_workbook("keyvalue.xlsx")

# 获取sheet
sheet = workbook.sheet_by_index(0)

# 获取行数
rows = sheet.nrows

for row in range(rows):
    rowValues = sheet.row_values(rowx=row)
    valueArray = []
    if len(rowValues) == 4:
        for col in range(4):
            valueArray.append(sheet.cell_value(rowx=row,colx=col).strip())
        allLines.append(valueArray)
    else:
        for i in range(len(rowValues)):
            if i == 0:
                print("key:", sheet.cell_value(rowx=row,colx=i))
            else:
                print("value" + i + ": " + sheet.cell_value(rowx=row,colx=i))
        raise ValueError('解析第' + str(row) + '行出错,' +'无法将此行解析成1个key，3个value，请检查表格第' + str(row) + '行')



def writeToFile(filePath):
    oldText = ''
    with open(filePath, 'r') as r:
        oldText = r.read()

    index = 0

    if isEnglish(filePath):
        print('######英文######\n')
        index = 2
    elif isSimplified(filePath):
        print('######简体######\n')
        index = 3
    elif isTraditional(filePath):
        print('######繁体######\n')
        index = 1

    newString = ''
    for strs in allLines:
        if (strs[0] in oldText):
            key = strs[0] + "_mark"
            newString = newString + '/* 此key与已有的key重复，已在key后添加_mark做区别 */\n"' + key + '"' + '=' + '"' + strs[index] + '";' + '\n'
        else:
            newString = newString + '"' + strs[0] + '"' + '=' + '"' + strs[index] + '";' + '\n'

    print(newString)

    with open(filePath, 'a+') as f:
     f.write('\n/************' + getpass.getuser() + '于' + time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time())) + '写入开始*********/\n')
     f.write(newString)
     f.write('/*^^^^^^^^^^^' + getpass.getuser() + '于' + time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time())) + '写入结束^^^^^^^^*/\n')
    

def isEnglish(path):
    return '/en.lproj/Localizable.strings' in path

def isSimplified(path):
    return '/zh-Hans.lproj/Localizable.strings' in path

def isTraditional(path):
    return '/zh-Hant.lproj/Localizable.strings' in path

def writeTemplateCode():
    templateCode = ''
    for strs in allLines:
        templateCode = templateCode + strs[3] + ': ' + 'YXLanguageUtility.kLang(key: "' + strs[0] + '")' + '\n'
    
    print('模板代码\n')
    print(templateCode)

    with open('templateCode.txt', 'w') as f:
        f.write(templateCode)

# 写入英文
writeToFile(path + '/en.lproj/Localizable.strings')
#写入简体
writeToFile(path + '/zh-Hans.lproj/Localizable.strings')
#写入繁体
writeToFile(path + '/zh-Hant.lproj/Localizable.strings')


#写入模板代码YXLanguageUtility.kLang(key: "xxx")
writeTemplateCode()