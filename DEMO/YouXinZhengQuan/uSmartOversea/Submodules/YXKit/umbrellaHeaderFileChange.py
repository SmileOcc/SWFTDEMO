#!/usr/bin/python
#coding:utf-8

import os
try:
  import xml.etree.cElementTree as ET
except ImportError:
  import xml.etree.ElementTree as ET

# 读取头文件准备生成 umbrella file
umbrellaHeaderFileName = 'YXKit-umbrella.h'
umbrellaHeaderFilePath = str(os.getenv('SRCROOT')) + '/Support Files/' + umbrellaHeaderFileName
print 'umbrella change: umbrellaHeaderFilePath = ' + umbrellaHeaderFilePath
umbrellaFileContent = '''
#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#if __has_include("<QMUIKit/QMUIKit.h>")
#import "<QMUIKit/QMUIKit.h>"
#endif

FOUNDATION_EXPORT double YXKitVersionNumber;
FOUNDATION_EXPORT const unsigned char YXKitVersionString[];

'''

umbrellaFileContent = umbrellaFileContent.strip()

f = open(umbrellaHeaderFilePath, 'r+')
f.seek(0)
oldFileContent = f.read().strip()
if oldFileContent == umbrellaFileContent:
  print 'umbrella creator: ' + umbrellaHeaderFileName + '的内容没有变化，不需要重写'
else:
  print 'umbrella creator: ' + umbrellaHeaderFileName + '的内容发生变化，开始重写'
  print 'umbrella creator: umbrellaFileContent = ' + umbrellaFileContent

  f.seek(0)
  f.write(umbrellaFileContent)
  f.truncate()

f.close()

