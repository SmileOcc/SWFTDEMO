//
//  OSSVSettisViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"

typedef void (^ShowPickerBlock)();
typedef void (^LangageSetTingBlock)();

@interface OSSVSettisViewModel : BaseViewModel<UITableViewDelegate,UITableViewDataSource,UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, weak) UIViewController        *controller;
@property (nonatomic, copy) ShowPickerBlock         showPickerBlock;
@property (nonatomic, copy) LangageSetTingBlock     langageBlock;

- (void)pickerViewDidSelected:(UIPickerView *)pickerView;

- (void)updateCurrentCurrency;

@end
