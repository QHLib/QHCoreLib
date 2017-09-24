//
//  QHNumberBadge.m
//  QQHouse
//
//  Created by changtang on 16/3/7.
//
//

#import "QHNumberBadge.h"
#import "QHBase.h"
#import "UIKit+QHCoreLib.h"
#import "CGFunctions.h"

@interface QHNumberBadge()

@property (nonatomic,   copy) QHNumberBadgeConfiguration *config;

@property (nonatomic, strong) UILabel *numberLabel;

@end

@implementation QHNumberBadge

- (instancetype)initWithConfiguration:(QHNumberBadgeConfiguration *)configuration
{
    self = [super initWithFrame:CGRectMake(0, 0, configuration.diameter, configuration.diameter)];
    if (self) {
        self.config = configuration;

        self.userInteractionEnabled = NO;

        self.backgroundColor = [UIColor clearColor];

        self.numberLabel = [[UILabel alloc] init];
        self.numberLabel.backgroundColor = [UIColor clearColor];
        self.numberLabel.textColor = [UIColor whiteColor];
        if (configuration.font) {
            self.numberLabel.font = configuration.font;
        } else {
            self.numberLabel.font = [UIFont boldSystemFontOfSize:configuration.fontSize];
        }
        [self addSubview:self.numberLabel];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat radius = CGRectGetHeight(rect) / 2.0;
    CGContextAddRoundedRect(context, radius, self.bounds);
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextFillPath(context);
}

- (void)setNeedsLayout
{
    if (self.numberLabel.needsCalculateSize) {
        [self.numberLabel sizeToFit];
        self.numberLabel.needsCalculateSize = NO;
    }

    CGFloat viewWidth = MAX(self.config.diameter,
                            self.numberLabel.width + 2 * self.config.horPadding);

    // 取整确保圆点的边不会有截断
    self.bounds = CGRectMake(0, 0, floor(viewWidth), floor(self.height));

    self.numberLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

    [self setNeedsDisplay];
}

- (void)setBadgeNumber:(NSUInteger)number
{
    self.numberLabel.text = $(@"%d", (int)number);
    if (self.config.maxNumber && number > self.config.maxNumber) {
        self.numberLabel.text = self.config.tooMuchString ?: @"...";
    }
    [self.numberLabel setNeedsCalculateSize:YES];
    [self setNeedsLayout];
}

@end

@implementation QHNumberBadgeConfiguration

+ (instancetype)defaultConfiguration
{
    return [QHNumberBadgeConfiguration new];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.diameter = 16;
        self.fontSize = 13;
        self.font = nil;
        self.horPadding = 4.0;

        self.maxNumber = 99;
        self.tooMuchString = @"99+";
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    QHNumberBadgeConfiguration *config = [[QHNumberBadgeConfiguration alloc] init];

    config.diameter = self.diameter;
    config.fontSize = self.fontSize;
    config.font = self.font;
    config.horPadding = self.horPadding;
    config.maxNumber = self.maxNumber;
    config.tooMuchString = self.tooMuchString;

    return config;
}

@end

