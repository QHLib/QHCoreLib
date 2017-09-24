//
//  QHHintBadge.m
//  QQHouse
//
//  Created by changtang on 16/3/8.
//
//

#import "QHHintBadge.h"
#import "UIKit+QHCoreLib.h"
#import "CGFunctions.h"

@implementation QHHintBadge

- (instancetype)initWithDiameter:(CGFloat)diameter
{
    self = [super initWithFrame:CGRectMake(0, 0, diameter, diameter)];
    if (self) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setDiameter:(CGFloat)diameter
{
    if (diameter != self.frame.size.height ||
        diameter != self.frame.size.width) {
        self.size = CGSizeMake(diameter, diameter);
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat radius = CGRectGetHeight(rect) / 2.0;
    CGContextAddRoundedRect(context, radius, CGRectMake(0, 0, 2 * radius, 2 * radius));
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextFillPath(context);
}

@end
