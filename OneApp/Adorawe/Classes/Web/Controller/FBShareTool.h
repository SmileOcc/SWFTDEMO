//
//  FBShareTool.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBShareTool : UIViewController

/*!
 *  @brief 分享内容
 */
@property (nonatomic,copy) NSString *shareContent;
/*!
 *  @brief 分享图片
 */
@property (nonatomic,copy) NSString *shareImage;
/*!
 *  @brief 分享链接
 */
@property (nonatomic,copy) NSString *shareURL;
/*!
 *  @brief 分享标题（Facebook专享）
 */
@property (nonatomic,copy) NSString *shareTitle;

- (void)shareToFacebook;


@end
