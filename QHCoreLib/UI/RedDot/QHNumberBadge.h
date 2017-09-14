//
//  QHNumberBadge.h
//  QQHouse
//
//  Created by changtang on 16/3/7.
//
//

#import <UIKit/UIKit.h>

@interface QHNumberBadgeConfiguration : NSObject <NSCopying>

@property (nonatomic, assign) CGFloat diameter;

@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, strong) UIFont *font;

@property (nonatomic, assign) CGFloat horPadding;

@property (nonatomic, assign) NSUInteger maxNumber;
@property (nonatomic,   copy) NSString *tooMuchString;

+ (instancetype)defaultConfiguration;

@end

@interface QHNumberBadge : UIView

- (instancetype)initWithConfiguration:(QHNumberBadgeConfiguration *)configuration;

- (void)setBadgeNumber:(NSUInteger)number;

@end
