//
//  QHTableViewCellTestController.m
//  QHCoreLibDemo
//
//  Created by Tony Tang on 2017/11/26.
//  Copyright © 2017年 TCTONY. All rights reserved.
//

#import "QHTableViewCellTestController.h"

typedef NS_ENUM(NSInteger, QHTableViewCellTestType) {
    QHTableViewCellTestTypePrivate = QHTableViewCellTypePrivateBegin,

    QHTableViewCellTestTypeOne = QHTableViewCellTypeCustomBegin,
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

QH_TABLEVIEW_CELL_DATA_DECL(my, NSString);

@end

@interface QHTableViewCellTestController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UITableViewCell *staticCell;

@property (nonatomic, strong) QHListSimpleData *listData;

@end

static QHTableViewCellFactory *cellFactory = nil;

@implementation QHTableViewCellTestController

+ (void)initialize
{
    QHTableViewCellFactoryRegistry([QHTableViewCellOne class], QHTableViewCellTestTypeOne);

    QHTableViewCellFactoryRegistry([QHTableViewCellOne class], QHTableViewCellTestTypeTwo);
    // warn and overwrite
    QHTableViewCellFactoryRegistry([QHTableViewCellTwo class], QHTableViewCellTestTypeTwo);
    // no warn
    QHTableViewCellFactoryRegistry([QHTableViewCellTwo class], QHTableViewCellTestTypeTwo);

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

    cellFactory = [QHTableViewCellFactory privateFactory];
}

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
    self.staticCell.qh_seperatorLineHeight = 10;
    [self.staticCell.qh_bottomSeperatorLine qh_setLockedBackgroundColor:[UIColor grayColor]];
    self.staticCell.qh_bottomSeperatorLineInsets = UIEdgeInsetsMake(-15, 10, 20, 10);
    
    QHTableViewSeperatorConfig *sepConfig = [QHTableViewSeperatorConfig new];
    sepConfig.height = 3;
    sepConfig.backgroundColor = [UIColor blackColor];
    sepConfig.insets = UIEdgeInsetsMake(1, 10, 1, 10);
    
    self.listData = [[QHListSimpleData alloc] initWithListData:({
        @[
          QHTableViewCellItemMake(QHTableViewCellTypeStatic, nil),
          QHTableViewCellItemMake(QHTableViewCellTypePlaceholder, nil),
          QHTableViewCellItemMake(QHTableViewCellTypeSeperator, sepConfig),
          QHTableViewCellItemMake(QHTableViewCellTypePlaceholder, @(100)),
          QHTableViewCellItemMake(QHTableViewCellTypeSeperator, sepConfig),
          QHTableViewCellItemMake(QHTableViewCellTypeDefault, @"default one"),
          QHTableViewCellItemMake(QHTableViewCellTypeSeperator, sepConfig),
          QHTableViewCellItemMake(QHTableViewCellTypeDefault, @"default two"),
          QHTableViewCellItemMake(QHTableViewCellTypeSeperator, sepConfig),
          QHTableViewCellItemMake(QHTableViewCellTestTypeOne, nil),
          QHTableViewCellItemMake(QHTableViewCellTypeSeperator, sepConfig),
          QHTableViewCellItemMake(QHTableViewCellTestTypeTwo, nil),
          QHTableViewCellItemMake(QHTableViewCellTypeSeperator, sepConfig),
          QHTableViewCellItemMake(QHTableViewCellTestTypeResolve1, nil),
          QHTableViewCellItemMake(QHTableViewCellTypeSeperator, sepConfig),
          QHTableViewCellItemMake(QHTableViewCellTestTypeResolve2, nil),
          ];
    })];
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
    
    return [cellFactory heightForItem:item
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
    
    UITableViewCell *cell = [cellFactory cellForItem:item
                                             context:context];

    if (item.type == QHTableViewCellTypeDefault) {
        QH_AS(item.data, NSString, title)
        cell.textLabel.text = title ?: @"";
        cell.textLabel.backgroundColor = [UIColor yellowColor];
    }

    if (context.isLast) {
        cell.backgroundColor = [UIColor orangeColor];
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

QH_TABLEVIEW_CELL_DATA_IMPL(my, NSString)

@end
