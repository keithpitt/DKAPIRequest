//
//  DKAPILogger.h
//  DKAPIRequest
//
//  Created by Keith Pitt on 21/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef DKAPIRequest_DKAPILogger_h
#define DKAPIRequest_DKAPILogger_h

#define DKAPIRequestLogDEBUG 0

#ifdef DEBUG

    #define DKAPIRequestLog(level, ...)    LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"DKAPIRequest",level,__VA_ARGS__)

#else

    #define DKAPIRequestLog(...)    do{}while(0)

#endif

#endif
