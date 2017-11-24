//
//  QHTableViewCellTestController.m
//  QHCoreLibDemo
//
//  Created by Tony Tang on 2017/11/26.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHTableViewCellTestController.h"

typedef NS_ENUM(NSInteger, QHTableViewCellTestType) {
    QHTableViewCellTestTypeOne = 1,
    QHTableViewCellTestTypeTwo,
    QHTableViewCellTestTypeResolve1,
    QHTableViewCellTestTypeResolve2,
};

@interface QHTableViewCellOne : UITableViewCell

@end

@interface QHTableViewCellTwo : UITableViewCell

@end

@interface QHTableViewCellResolve1 : UITableViewCell

@end

@interface QHTableViewCellResolve2 : UITableViewCell

@end

@interface QHTableViewCellTestController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UITableViewCell *staticCell;

@property (nonatomic, strong) QHListSimpleData *listData;

@end

@implementation QHTableViewCellTestController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds
                                                  style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.staticCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:nil];
    self.staticCell.height = 100;
    self.staticCell.backgroundColor = [UIColor greenColor];
    self.staticCell.textLabel.text = @"static cell";
    self.staticCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.listData = [[QHListSimpleData alloc] initWithListData:({
        @[
          QHTableViewCellItemMake(QHTableViewCellTypeStatic, nil),
          QHTableViewCellItemMake(QHTableViewCellTypeDefault, @"default one"),
          QHTableViewCellItemMake(QHTableViewCellTypeDefault, @"default two"),
          QHTableViewCellItemMake(QHTableViewCellTestTypeOne, nil),
          QHTableViewCellItemMake(QHTableViewCellTestTypeTwo, nil),
          QHTableViewCellItemMake(QHTableViewCellTestTypeResolve1, nil),
          QHTableViewCellItemMake(QHTableViewCellTestTypeResolve2, nil),
          ];
    })];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[QHTableViewCellFactory sharedInstance] registryCellClass:[QHTableViewCellOne class]
                                                           forType:QHTableViewCellTestTypeOne];
        [[QHTableViewCellFactory sharedInstance] registryCellClass:[QHTableViewCellTwo class]
                                                           forType:QHTableViewCellTestTypeTwo];
        
        [[QHTableViewCellFactory sharedInstance] registryCellClassResolver:({
            ^Class _Nullable(QHTableViewCellItem * _Nonnull item,
                             QHTableViewCellContext * _Nonnull context) {
                if (item.type == QHTableViewCellTestTypeResolve1) {
                    return [QHTableViewCellResolve1 class];
                } else if (item.type == QHTableViewCellTestTypeResolve2) {
                    return [QHTableViewCellResolve2 class];
                }
                return nil;
            };
        })];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listData.numberOfItems;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QHTableViewCellItem *item = [self.listData listItemAtIndex:indexPath.row];
    QHTableViewCellContext *context = QHTableViewCellContextMake(tableView, indexPath);
    
    if (item.type == QHTableViewCellTypeStatic) {
        if (indexPath.row == 0) {
            context.opaque = self.staticCell;
        }
    }
    
    return [[QHTableViewCellFactory sharedInstance] heightForItem:item
                                                          context:context];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QHTableViewCellItem *item = [self.listData listItemAtIndex:indexPath.row];
    QHTableViewCellContext *context = QHTableViewCellContextMake(tableView, indexPath);
    
    if (item.type == QHTableViewCellTypeStatic) {
        if (indexPath.row == 0) {
            context.opaque = self.staticCell;
        }
    }
    
    UITableViewCell *cell = [[QHTableViewCellFactory sharedInstance] cellForItem:item
                                                                         context:context];

    if (item.type == QHTableViewCellTypeDefault) {
        QH_AS(item.data, NSString, title)
        cell.textLabel.text = title ?: @"";
        cell.textLabel.backgroundColor = [UIColor yellowColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

@implementation QHTableViewCellOne

+ (CGFloat)qh_heightForItem:(QHTableViewCellItem *)item context:(QHTableViewCellContext *)context
{
    return 100;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        self.textLabel.text = @"type one";
    }
    return self;
}

@end

@implementation QHTableViewCellTwo

+ (CGFloat)qh_heightForItem:(QHTableViewCellItem *)item context:(QHTableViewCellContext *)context
{
    return 100;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        self.textLabel.text = @"type two";
    }
    return self;
}

@end

@implementation QHTableViewCellResolve1

+ (CGFloat)qh_heightForItem:(QHTableViewCellItem *)item context:(QHTableViewCellContext *)context
{
    return 100;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        self.textLabel.text = @"resolve one";
    }
    return self;
}

@end

@implementation QHTableViewCellResolve2

+ (CGFloat)qh_heightForItem:(QHTableViewCellItem *)item context:(QHTableViewCellContext *)context
{
    return 100;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        self.textLabel.text = @"resolve two";
    }
    return self;
}

@end
