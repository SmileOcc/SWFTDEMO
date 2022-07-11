//
//  CellTextfield.h
// XStarlinkProject
//
//  Created by fan wang on 2021/5/18.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailTextField.h"
#import "STLBindCountryModel.h"

NS_ASSUME_NONNULL_BEGIN

@class CellTextfield;
@protocol CellTextFieldDelegate <DetailTextFieldDelegate>
-(void)didtapedSelectCountryButton:(id)currentCountry;
@end


@interface CellTextfield : DetailTextField
@property (weak,nonatomic) STLBindCountryModel *countryModel;
@property (assign,nonatomic) BOOL canSelectCountry;
///区号
@property (weak,nonatomic) UILabel *regionCodeLbl;
@end

NS_ASSUME_NONNULL_END
