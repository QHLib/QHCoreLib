//
//  QHUIDefines.h
//  QHCoreLib
//
//  Created by changtang on 2017/9/20.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#ifndef QHUIDefines_h
#define QHUIDefines_h

#define QH_SCREEN_SCALE             ([UIScreen mainScreen].scale)

#define QH_SCREEN_WIDTH             ([UIScreen mainScreen].bounds.size.width)
#define QH_SCREEN_HEIGHT            ([UIScreen mainScreen].bounds.size.height)

#define QH_SCREEN_PORTRAIT_WIDTH    (MIN(QH_SCREEN_WIDTH, QH_SCREEN_HEIGHT))
#define QH_SCREEN_PORTRAIT_HEIGHT   (MAX(QH_SCREEN_WIDTH, QH_SCREEN_HEIGHT))

#define QH__DP(size, _base_screen_width) ((size) / (_base_screen_width) * QH_SCREEN_PORTRAIT_WIDTH)

#define QH_DP_320(size)     QH__DP(size, 320)
#define QH_DP_375(size)     QH__DP(size, 375)
#define QH_DP_414(size)     QH__DP(size, 414)

#define QH_DP(size) QH_DP_375(size)

#endif /* QHUIDefines_h */
