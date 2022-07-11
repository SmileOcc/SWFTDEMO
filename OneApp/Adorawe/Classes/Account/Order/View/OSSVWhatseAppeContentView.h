//
//  OSSVWhatseAppeContentView.h
// XStarlinkProject
//
//  Created by Kevin on 2021/9/9.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol STLWhatsAppContentViewDelegate;
@interface OSSVWhatseAppeContentView : UIView

@property (nonatomic, weak) id<STLWhatsAppContentViewDelegate>delegate;
@property (nonatomic, strong) YYAnimatedImageView *countryImageView;  //国家图标
@property (nonatomic, strong) UILabel      *phoneCode; //国家区号

@end


@protocol STLWhatsAppContentViewDelegate <NSObject>
-(void)didtapedSelectCountryButton:(id)currentCountry;
@end

NS_ASSUME_NONNULL_END
