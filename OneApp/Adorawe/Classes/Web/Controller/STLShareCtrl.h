//
//  STLShareCtrl.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STLShareDelegate <NSObject>

- (void)STL_dismissViewControllerAnimated:(BOOL)flag channel:(NSString *)channel success:(BOOL)isSuccess completion:(void (^)(void))completion;

- (void)STL_shareFailWithError:(NSError *)error;

@end

@interface STLShareCtrl : UIViewController
/*!
 *  @brief 分享集合（暂时没用到）
 */
@property (nonatomic,strong) NSMutableDictionary *shareParams;
/*!
 *  @brief 分享内容
 */
@property (nonatomic,copy) NSString *shareContent;
/*!
 *  @brief 分享商品ID
 */
@property (nonatomic,copy) NSString *shareGoodsID;
/*!
 *  @brief 分享商品SKU
 */
@property (nonatomic,copy) NSString *shareGoodsSKU;

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

/*!
 *  @brief 图片URL下载的图片 （Twitter专享，暂时没用）
 */
@property (nonatomic,strong) UIImage *image;

/*!
 *  @brief 用于tabbar消失
 */
@property (nonatomic,strong) UIViewController *sourceViewController;

@property (nonatomic, weak) id<STLShareDelegate> delegate;

@property (nonatomic, assign) BOOL isAddUser;



//// 分享页面标识 url goodsn activityid

@property (nonatomic, copy) NSString  *shareSourceId;
@property (nonatomic, copy) NSString  *shareSourcePageName;

//-----------1.3.8 分享拉新需求-------
@property (nonatomic, assign) NSInteger type;//1,详情页分享  2.h5页面分享
@property (nonatomic, copy) NSString *sku;//详情页分享 落地页sku
@property (nonatomic, copy) NSString *h5UrlStr;// h5页面分享 落地页h5的链接

@property (nonatomic,weak) OSSVDetailsBaseInfoModel *goodsBaseInfo;

@end
