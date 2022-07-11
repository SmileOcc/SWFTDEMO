//
//  OSSVDetailsActivityFullReductionView.h
// XStarlinkProject
//
//  Created by odd on 2020/12/23.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVDetailsActivityFullReductionView : UIView

@property (nonatomic, strong) UIView      *tempView;
@property (nonatomic, strong) UIView      *backgroundView;
@property (nonatomic, strong) UILabel     *tipLabel;

@property (nonatomic, copy) NSString       *tipMessage;

- (void)updateTipMasWidth:(BOOL)isFull;
@end

NS_ASSUME_NONNULL_END
