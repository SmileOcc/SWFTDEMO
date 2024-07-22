//
//  ZFAddressSectionKeyHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2019/5/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAddressSectionKeyHeaderView.h"
#import "ZFThemeManager.h"
#import "Constants.h"
#import "UIView+ZFViewCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"

@interface ZFAddressSectionKeyHeaderView ()

@property (nonatomic, strong) UILabel     *keyLabel;
@property (nonatomic, strong) UIView      *bgView;


@end
@implementation ZFAddressSectionKeyHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self.bgView addSubview:self.keyLabel];
        self.backgroundView = self.bgView;
    }
    return self;
}

- (void)sectionHeader:(NSArray *)keyList section:(NSInteger)section {
    
    NSString *key = @"";
    if (ZFJudgeNSArray(keyList)) {
        if (keyList.count > section) {
            key = ZFToString(keyList[section]);
        }
    }
    self.keyLabel.text = key;
}


- (UIView *)bgView {
    if (!_bgView) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 24)];
        bgView.backgroundColor = ZFC0xF4F4F4();
        _bgView = bgView;
    }
    return _bgView;
}

- (UILabel *)keyLabel {
    if (!_keyLabel) {
        UILabel *keyLabel = [[UILabel alloc] init];
        keyLabel.font = ZFFontSystemSize(14);
        keyLabel.textColor = ZFC0x999999();
        keyLabel.text = @"";
        [keyLabel sizeToFit];
        [keyLabel convertTextAlignmentWithARLanguage];
        keyLabel.frame = CGRectMake(18, 0, KScreenWidth-18*2, 24);
        _keyLabel = keyLabel;
    }
    return _keyLabel;
}
@end
