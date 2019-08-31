//
//  QHTaskQueueController.m
//  QHCoreLibDemo
//
//  Created by Tony Tang on 2019/8/30.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#import "QHTaskQueueController.h"
#import <QHCoreLib/QHTaskQueue.h>

@interface QHTaskQueueController () {
    QHBlockQueue *m_blockQueue;
}

@end

@implementation QHTaskQueueController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor lightGrayColor];

    m_blockQueue = [QHBlockQueue blockQueue];

    [self testTaskQueue];
}

- (void)testTaskQueue {
    QHClockEntry *clock = [QHClockEntry new];
    [clock start];
    __block int count = 0;
    [m_blockQueue pushBlock:^{
        ++count;
    } delay:0.2];
    [m_blockQueue pushBlock:^{
        ++count;
    } delay:0.2];
    [m_blockQueue pushBlock:^{
        ++count;
    } delay:0.2];
    [m_blockQueue pushBlock:^{
        ++count;
    } delay:0.2];
    [m_blockQueue pushBlock:^{
        ++count;
        [clock end];
        NSLog(@"cost: %d", [clock spentTimeInMiliseconds]);
    } delay:0.2];
}

@end
