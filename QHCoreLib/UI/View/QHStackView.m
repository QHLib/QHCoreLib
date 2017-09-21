//
//  QHStackView.m
//  QQHouse
//
//  Created by changtang on 16/9/23.
//
//

#import "QHStackView.h"
#import "UIKit+QHCoreLib.h"

NS_ASSUME_NONNULL_BEGIN

@interface QHStackView ()


@end

@implementation QHStackView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.viewAlign = QHStackViewAlignHorizontal;
        self.verticalAlign = QHStackViewVerticalAlignCenter;
        self.horizontalAlign = QHStackViewHorizontalAlignCenter;
        self.extendItemTouchArea = NO;
        self.extendPadding = 0.0f;
    }
    return self;
}

- (void)setItemViews:(NSArray<__kindof UIView *> * _Nullable)itemViews
{
    if ([_itemViews isEqualToArray:itemViews]) return;
    
    for (UIView *subview in _itemViews) {
        [subview removeFromSuperview];
    }
    
    _itemViews = itemViews;
    
    for (UIView *subview in _itemViews) {
        [self addSubview:subview];
    }
    
    self.width = [self p_stackViewLength];
    self.height = [self p_stackViewHeight];
}

- (void)setViewAlign:(QHStackViewAlign)viewAlign
{
    if (_viewAlign != viewAlign) {
        _viewAlign = viewAlign;
        
        [self setNeedsLayout];
    }
}

- (void)setVerticalAlign:(QHStackViewVerticalAlign)verticalAlign
{
    if (_verticalAlign != verticalAlign) {
        _verticalAlign = verticalAlign;
        
        [self setNeedsLayout];
    }
}

- (void)setHorizontalAlign:(QHStackViewHorizontalAlign)horizontalAlign
{
    if (_horizontalAlign != horizontalAlign) {
        _horizontalAlign = horizontalAlign;
        
        [self setNeedsLayout];
    }
}

- (CGFloat)p_stackViewLength
{
    if (self.viewAlign == QHStackViewAlignVertical) {
        return self.width;
    }
    if ([self.itemViews count] == 0) return 0;
    
    __block CGFloat length = -self.spacing;
    [self.itemViews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        length += view.width + self.spacing;
    }];
    return length;
}

- (CGFloat)p_stackViewHeight
{
    if (self.viewAlign == QHStackViewAlignHorizontal) {
        return self.height;
    }
    
    if ([self.itemViews count] == 0) return 0;
    
    __block CGFloat height = -self.spacing;
    [self.itemViews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        height += view.height + self.spacing;
    }];
    return height;
}

- (void)layoutSubviews
{
    __block CGFloat offset = 0.0;
    [self.itemViews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (self.viewAlign == QHStackViewAlignHorizontal) {
            view.left = offset;
            switch (self.verticalAlign) {
                case QHStackViewVerticalAlignCenter:
                    view.centerY = self.height / 2.0;
                    break;
                    
                case QHStackViewVerticalAlignTop:
                    view.top = 0.0;
                    break;
                    
                case QHStackViewVerticalAlignBottom:
                    view.bottom = self.height;
                    break;
                    
                default:
                    break;
            }
            
            offset += view.width + self.spacing;
        }
        else if (self.viewAlign == QHStackViewAlignVertical) {
            view.top = offset;
            switch (self.horizontalAlign) {
                case QHStackViewHorizontalAlignCenter:
                    view.centerX = self.width / 2.0;
                    break;
                    
                case QHStackViewHorizontalAlignLeft:
                    view.left = 0.0;
                    break;
                    
                case QHStackViewHorizontalAlignRight:
                    view.right = self.width;
                    break;
                    
                default:
                    break;
            }
            
            offset += view.height + self.spacing;
        }
    }];
}

- (UIView * _Nullable)hitTest:(CGPoint)point withEvent:(UIEvent * _Nullable)event
{
    if (self.extendItemTouchArea) {
        for (UIView *view in self.itemViews) {
            
            if (point.x >= (view.left - self.spacing/2.0)
                && point.x <= (view.right + self.spacing / 2.0)
                && point.y >= MIN(self.extendPadding, view.top)
                && point.y <= MAX(self.height - self.extendPadding, view.bottom)) {
                
                return [view hitTest:[view convertPoint:point fromView:self]
                           withEvent:event];
            }
        }
        return [super hitTest:point withEvent:event];
    }
    else {
        return [super hitTest:point withEvent:event];
    }
}

- (CGSize)wrappedSize
{
    return CGSizeMake([self p_stackViewLength], [self p_stackViewHeight]);
}

@end

NS_ASSUME_NONNULL_END
