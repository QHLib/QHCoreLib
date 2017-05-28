//
//  QHCoreLibExternTest.h
//  QHCoreLib
//
//  Created by changtang on 2017/5/18.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#ifndef QHCoreLibExternTest_h
#define QHCoreLibExternTest_h

#import <QHCoreLib/QHDefines.h>

QH_EXTERN int extern_var;
QH_EXTERN void extern_function();

QH_EXTERN_C_BEGIN

void another_extern_function();

QH_EXTERN_C_END

#endif /* QHCoreLibExternTest_h */
