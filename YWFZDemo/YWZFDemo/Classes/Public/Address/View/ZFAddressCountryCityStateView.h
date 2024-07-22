//
//  ZFAddressCountryCityStateView.h
//  ZZZZZ
//
//  Created by YW on 2019/1/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFAddressCountryCityStateItemView;

typedef void(^selectIndexBack)(NSInteger index);

@interface ZFAddressCountryCityStateView : UIView

@property (nonatomic, strong) NSArray                                      *titlesArray;
@property (nonatomic, strong) ZFAddressCountryCityStateItemView            *selectItemView;
@property (nonatomic, copy) selectIndexBack                                selectIndexBlock;

-(void)selectIndex:(NSInteger)index;

@end



@interface ZFAddressCountryCityStateItemView: UIView

@property (nonatomic, strong) UIButton            *eventButton;
@property (nonatomic, strong) UIImageView         *arrowImageView;
@property (nonatomic, copy) void (^clickBlock)(UIButton *sender);


@end
