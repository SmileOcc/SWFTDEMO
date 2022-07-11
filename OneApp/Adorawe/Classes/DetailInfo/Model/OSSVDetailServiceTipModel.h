//
//  OSSVDetailServiceTipModel.h
// XStarlinkProject
//
//  Created by Kevin on 2021/3/26.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface OSSVDetailServiceTipModel : NSObject
@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, copy) NSString *contentString;
@property (nonatomic, copy) NSString *titleExt;  //标题尾部
@property (nonatomic, copy) NSString *contentExt;   //内容尾部

@end

