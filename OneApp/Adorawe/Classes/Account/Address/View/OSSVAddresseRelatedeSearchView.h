//
//  OSSVAddresseRelatedeSearchView.h
// XStarlinkProject
//
//  Created by Kevin on 2021/9/6.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^SuccessUpdateCountryAndProviceAndCity)(NSString *countryCode,
                                                      NSString *countryName,
                                                      NSString *proviceName,
                                                      NSString *cityName,
                                                      NSString *latitude,
                                                      NSString *longitude,
                                                      NSString *address,
                                                      NSString *areaName,
                                                      BOOL     isSuccess);
typedef void (^SelectAddressDetail)(NSString *addressString);

@interface OSSVAddresseRelatedeSearchView : UIView
@property (nonatomic, copy) SuccessUpdateCountryAndProviceAndCity updateCountryAndCity;  //选中每条地址，所对应的信息，用户保存地址时候提交给后台收集
@property (nonatomic, copy) SelectAddressDetail  selectAddressDetail;                    //选中地址时候，传出用于详细地址的textFild的内容
@property (nonatomic, strong) NSArray *dataArray; //搜索关联出的总数据
@property (nonatomic, strong) NSString *keyWord;
@end

NS_ASSUME_NONNULL_END
