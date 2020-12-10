//
//  QHNetworkStreamController.m
//  QHCoreLibDemo
//
//  Created by changtang on 2020/12/10.
//  Copyright © 2020 TCTONY. All rights reserved.
//

#import "QHNetworkStreamController.h"

#import <QHCoreLib/QHCoreLib.h>

@interface QHNetworkStreamController ()

@property (nonatomic, strong) QHNetworkStreamApi *fileStream;
@property (nonatomic, assign) int length;

@end

@implementation QHNetworkStreamController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.fileStream = [[QHNetworkStreamApi alloc] initWithUrl:@"https://tctony.com/file/one_mega_zero.txt"];
    @weakify(self);
    [self.fileStream setStreamDataBlock:^(QHNetworkStreamApi * _Nonnull api, NSData * _Nonnull data) {
        @strongify(self);
        self.length += (int)data.length;
        NSLog(@"delta %d, total %d", (int)data.length, self.length);
    }];
    [self.fileStream startWithSuccess:^(QHNetworkStreamApi * _Nonnull api, QHNetworkStreamApiResult * _Nonnull result) {
        // do nothing
    } fail:^(QHNetworkStreamApi * _Nonnull api, NSError * _Nonnull error) {
        // do nothing
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
