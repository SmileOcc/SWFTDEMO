//
//  H5ShareModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface H5ShareModel : NSObject

@property (nonatomic, assign) BOOL isShare; // 是否分享
@property (nonatomic, copy) NSString *shareImageURL; // 分享小图片链接
@property (nonatomic, copy) NSString *shareLinkURL; // 分享地址
@property (nonatomic,copy) NSString *shareTitle; // 分享标题
@property (nonatomic,copy) NSString *shareContent; // 分享内容（后台配置）

@end
