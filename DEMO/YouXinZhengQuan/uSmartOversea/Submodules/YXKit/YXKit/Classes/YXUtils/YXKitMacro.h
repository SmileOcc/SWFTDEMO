//
//  YXKitMacro.h
//  Pods
//
//  Created by ellison on 2019/4/17.
//

#ifndef YXConstant_h
#define YXConstant_h

///------------
/// TOOL
///------------

#define YX_IMAGE_NAMED(name) [UIImage imageNamed:name]
///适配
#define yxsize(x) ((x)*([UIScreen mainScreen].bounds.size.width/375.0))

typedef void (^VoidBlock)(void);
typedef void (^VoidBlock_int)(int);

///------
/// NSString format
///------
#define NSSTRING(title,message)           [NSString stringWithFormat:@"%@%@", title,message]
#define NSSTRING_FORMAT(formart,...)      [NSString stringWithFormat:formart,##__VA_ARGS__]
#define NSSTRING_INT(int)                 [NSString stringWithFormat:@"%d",int]
#define NSSTRING_NSINTEGER(integer)       [NSString stringWithFormat:@"%ld",integer]
#define NSSTRING_FLOAT(float)             [NSString stringWithFormat:@"%f",float]
#endif /* YXConstant_h */
