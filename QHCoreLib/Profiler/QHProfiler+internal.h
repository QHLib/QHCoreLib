//
//  QHProfiler+internal.h
//  QHCoreLib
//
//  Created by Tony Tang on 2019/8/31.
//  Copyright © 2019 TCTONY. All rights reserved.
//

#ifndef QHProfiler_internal_h
#define QHProfiler_internal_h

#import "QHProfiler.h"

#if _QHCoreLibDebug && DEBUG
#define QHDebugProfilerStart(_module, _event)                                                       \
    {                                                                                               \
        QHProfilerStart(_module, _event);                                                           \
    }
#define QHDebugProfilerCheck(_module, _event, _point) QHProfilerCheck(_module, _event, _point)
#define QHDebugProfilerEnd(_module, _event) QHProfilerEnd(_module, _event)
#else
#define QHDebugProfilerStart(_module, _event)                                                       \
    do {                                                                                            \
    } while (0)
#define QHDebugProfilerCheck(_module, _event, _point)                                               \
    do {                                                                                            \
    } while (0)
#define QHDebugProfilerEnd(_module, _event)                                                         \
    do {                                                                                            \
    } while (0)
#endif


#endif /* QHProfiler_internal_h */
