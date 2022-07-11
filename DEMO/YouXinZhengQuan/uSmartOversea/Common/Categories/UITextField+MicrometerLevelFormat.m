
#import "UITextField+MicrometerLevelFormat.h"
#import <objc/runtime.h>
@interface UITextField ()
@property (retain, nonatomic) UITextRange * textrange;
@property (retain, nonatomic) NSString * preString;
@end

@implementation UITextField (MicrometerLevelFormat)

static char kTextRange;
static char kPreString;

#pragma mark - method swizzle
- (void)setTextrange:(UITextRange *)textrange{
    objc_setAssociatedObject(self, &kTextRange, textrange, OBJC_ASSOCIATION_COPY);
}
- (UITextRange *)textrange{
   return objc_getAssociatedObject(self, &kTextRange);
}

- (void)setPreString:(NSString *)preString{
    objc_setAssociatedObject(self, &kPreString, preString, OBJC_ASSOCIATION_COPY);
}

- (NSString *)preString{
    return objc_getAssociatedObject(self, &kPreString);
}

#pragma mark - 千分位
//开启千分位模式
- (void)openMicrometerLevelFormat {
    [self addTarget:self action:@selector(reformatAsMicrometerLevel:) forControlEvents:UIControlEventEditingChanged];
    [self configSelectedRange];
}

#pragma mark - private method
//千分位校验
- (void)reformatAsMicrometerLevel:(UITextField *)textField {
    NSString *replaceString = [textField.text stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh"];
    numberFormatter.positiveFormat = @"###,##0";

    NSUInteger loc = [replaceString rangeOfString:@"."].location;
    NSString *formattedNumberString = @"";
    if (replaceString.length > 0) {
        formattedNumberString = [numberFormatter stringFromNumber:@(floor(replaceString.doubleValue))];
        if (loc != NSNotFound && ![replaceString isEqualToString:@"."]) {
            formattedNumberString = [formattedNumberString stringByAppendingString:[replaceString substringFromIndex:loc]];
        }
        textField.text = formattedNumberString;
    }

    NSString * beforeString = self.preString;
    NSString * afterString = formattedNumberString;
    
    if (afterString.length != beforeString.length) {
        NSInteger off = afterString.length - beforeString.length;
        UITextPosition *newPos = [textField positionFromPosition:self.textrange.start offset:off];
        textField.selectedTextRange = [textField textRangeFromPosition:newPos toPosition:newPos];
    } else {
        textField.selectedTextRange = self.textrange;   //保证光标在逗号后时，删除功能正常
    }
    
    self.preString = formattedNumberString;//把修改之后的赋值给prestring
}

- (void)configSelectedRange{
    UITextRange *selectedRange = [self selectedTextRange];
    [self textRange:selectedRange];
}
//传回光标的位置
- (void)textRange:(UITextRange *)range {
    self.textrange = range;
}


@end
