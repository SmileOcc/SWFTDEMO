//
//  STLPinterestCtrl.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/16.
//  Copyright (c) 2016 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  STLPinterestDelegate
-(void)dismissPinterest;
@end

@interface STLPinterestCtrl : UIViewController 
/*!
 *  @brief 分享链接
 */
@property (nonatomic,strong) NSString *url;
/*!
 *  @brief 图片地址
 */
@property (nonatomic,strong) NSString *image;
/*!
 *  @brief 分享内容
 */
@property (nonatomic,strong) NSString *content;
@property (nonatomic,assign) id<STLPinterestDelegate> delegate;

@end
