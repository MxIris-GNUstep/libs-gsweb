/** GSWDefaultAdaptor.m - <title>GSWeb: Class GSWDefaultAdaptor</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999

   $Revision$
   $Date$
   $Id$

   <abstract></abstract>

   This file is part of the GNUstep Web Library.

   <license>
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
   </license>
**/

#include "config.h"

RCS_ID("$Id$")

#include "GSWeb.h"

#if HAVE_LIBWRAP
#include <tcpd.h>
#include <syslog.h>
#endif

#if HAVE_LIBWRAP
int deny_severity = LOG_WARNING;
int allow_severity = LOG_INFO;
/*static*/ void twist_option(char   *value,struct request_info *request)
{
};
#endif
       



//====================================================================
@implementation GSWDefaultAdaptor

-(id)initWithName:(NSString*)name
        arguments:(NSDictionary*)arguments
{
  NSDebugMLog(@"Init");
  if ((self=[super initWithName:name
                   arguments:arguments]))
    {
      _fileHandle=nil;
      _threads=[NSMutableArray new];
      _waitingThreads=[NSMutableArray new];
      _selfLock=[NSLock new];
      _port=[[arguments objectForKey:GSWOPT_Port[GSWebNamingConv]] intValue];
      ASSIGN(_host,[arguments objectForKey:GSWOPT_Host[GSWebNamingConv]]);
      //  [self setInstance:_instance];
      _queueSize=[[arguments objectForKey:GSWOPT_ListenQueueSize[GSWebNamingConv]] intValue];
      _workerThreadCount=[[arguments objectForKey:GSWOPT_WorkerThreadCount[GSWebNamingConv]] intValue];
      _workerThreadCountMin=[[arguments objectForKey:GSWOPT_WorkerThreadCountMin[GSWebNamingConv]] intValue];
      _workerThreadCountMax=[[arguments objectForKey:GSWOPT_WorkerThreadCountMax[GSWebNamingConv]] intValue];
      _isMultiThreadEnabled=[[arguments objectForKey:GSWOPT_MultiThreadEnabled] boolValue];
      ASSIGN(_adaptorHost,[arguments objectForKey:GSWOPT_AdaptorHost[GSWebNamingConv]]);
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  GSWLogMemC("Dealloc GSWDefaultAdaptor");
  //TODO? DESTROY(listenPortObject);
  GSWLogMemC("Dealloc GSWDefaultAdaptor: host");
  DESTROY(_host);
  GSWLogMemC("Dealloc GSWDefaultAdaptor: adaptorHost");
  DESTROY(_adaptorHost);
  GSWLogMemC("Dealloc GSWDefaultAdaptor: fileHandle");
  DESTROY(_fileHandle);
  GSWLogMemC("Dealloc GSWDefaultAdaptor: threads");
  DESTROY(_threads);
  GSWLogMemC("Dealloc GSWDefaultAdaptor: waitingThreads");
  DESTROY(_waitingThreads);
  GSWLogMemC("Dealloc GSWDefaultAdaptor: selfLock");
  DESTROY(_selfLock);
  GSWLogMemC("Dealloc GSWDefaultAdaptor Super");
  [super dealloc];
  GSWLogMemC("End Dealloc GSWDefaultAdaptor");
};

//--------------------------------------------------------------------
-(void)registerForEvents
{
  NSDebugDeepMLog(@"START registerForEvents - %@",
		  GSCurrentThread());
  NSAssert(!_fileHandle,@"fileHandle already exists");
  NSDebugDeepMLLog(@"info",@"registerForEvents port=%d",_port);
  NSDebugDeepMLLog(@"info",@"registerForEvents host=%@",_host);
  if (!_host)
    {
      ASSIGN(_host,[[NSHost currentHost] name]);
    };
  _fileHandle=[[NSFileHandle fileHandleAsServerAtAddress:_host
			    service:[NSString stringWithFormat:@"%d",_port]
			    protocol:@"tcp"] retain];
  NSDebugDeepMLLog(@"info",@"fileHandle=%p",(void*)_fileHandle);
  [[NSNotificationCenter defaultCenter] addObserver:self
					selector: @selector(announceNewConnection:)
					name: NSFileHandleConnectionAcceptedNotification
					object:_fileHandle];
/*  [NotificationDispatcher addObserver:self
    selector: @selector(announceNewConnection:)
    name: NSFileHandleConnectionAcceptedNotification
    object:fileHandle];
*/
  [_fileHandle acceptConnectionInBackgroundAndNotify];
  NSDebugDeepMLog(@"%@ - B readInProgress=%d",
		  GSCurrentThread(),(int)[_fileHandle readInProgress]);
  [GSWApplication statusLogWithFormat:
		    @"Thread %@: Waiting for connections on %@:%d.",
                  GSCurrentThread(),
                  _host,
                  _port];
  NSDebugDeepMLog(@"STOP registerForEvents");
};

//--------------------------------------------------------------------
-(void)unregisterForEvents
{
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                        name:NSFileHandleConnectionAcceptedNotification
                                        object:_fileHandle];
/*  [NotificationDispatcher removeObserver:self
						  name: NSFileHandleConnectionAcceptedNotification
						  object:fileHandle];
*/
  DESTROY(_fileHandle);
};

//--------------------------------------------------------------------
-(void)logWithFormat:(NSString*)format,...
{
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
+(void)logWithFormat:(NSString*)format,...
{
  LOGClassFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(void)runOnce
{
  //call doesBusyRunOnce
  LOGObjectFnNotImplemented();	//TODOFN
};

//--------------------------------------------------------------------
-(BOOL)doesBusyRunOnce
{
  //call _runOnce
  LOGObjectFnNotImplemented();	//TODOFN
  return NO;
};

//--------------------------------------------------------------------
-(BOOL)dispatchesRequestsConcurrently
{
  return YES;
};

//--------------------------------------------------------------------
-(int)port
{
  return _port;
};

//--------------------------------------------------------------------
-(NSString*)host
{
  return _host;
};


//--------------------------------------------------------------------
-(void)setWorkerThreadCountMin:(id)workerThreadCount
{
  if ([self tryLock])
    {
      NS_DURING
        {
          _workerThreadCountMin=[workerThreadCount intValue];
          if (_workerThreadCountMin<1)
            _workerThreadCountMin=1;
        }
      NS_HANDLER
        {
          LOGException(@"%@ (%@)",
                       localException,
                       [localException reason]);
        }
      NS_ENDHANDLER;
      [self unlock];
    }
  else
    {
      //TODO
    };
};

//--------------------------------------------------------------------
-(id)workerThreadCountMin
{
  return [NSNumber numberWithInt:_workerThreadCountMin];
};

//--------------------------------------------------------------------
-(void)setWorkerThreadCountMax:(id)workerThreadCount
{
  if ([self tryLock])
    {
      NS_DURING
        {
          _workerThreadCountMax=[workerThreadCount intValue];
          if (_workerThreadCountMax<1)
            _workerThreadCountMax=1;
        }
      NS_HANDLER
        {
          LOGException(@"%@ (%@)",
                       localException,
                       [localException reason]);
        }
      NS_ENDHANDLER;
      [self unlock];
    }
  else
    {
      //TODO
    };
};

//--------------------------------------------------------------------
-(id)workerThreadCountMax
{
  return [NSNumber numberWithInt:_workerThreadCountMax];
};

//--------------------------------------------------------------------
-(BOOL)isMultiThreadEnabled
{
  return _isMultiThreadEnabled;
};

//--------------------------------------------------------------------
-(void)setListenQueueSize:(id)listenQueueSize
{
  if ([self tryLock])
    {
      NS_DURING
        {
          _queueSize=[listenQueueSize intValue];
          if (_queueSize<1)
            _queueSize=1;
        }
      NS_HANDLER
        {
          LOGException(@"%@ (%@)",
                       localException,
                       [localException reason]);
        }
      NS_ENDHANDLER;
      [self unlock];
    }
  else
    {
      //TODO
    };
};

//--------------------------------------------------------------------
//NDFN
-(id)announceNewConnection:(NSNotification*)notification
{
  GSWDefaultAdaptorThread* newThread=nil;
  NSFileHandle* listenHandle=nil;
  NSFileHandle* inStream = nil;
  NSCalendarDate* requestDate=nil;
  NSString* requestDateString=nil;
  NSString* connRefusedMessage=nil;
  LOGObjectFnStart();
  listenHandle=[notification object];
  requestDate=[NSCalendarDate calendarDate];
  requestDateString=[NSString stringWithFormat:@"%@: New Request %@",
			      GSCurrentThread(),requestDate];
  [GSWApplication statusLogWithFormat:@"%@",requestDateString];
  NSDebugDeepMLLog(@"info",@"listenHandle=%p",(void*)listenHandle);
  inStream = [[notification userInfo]objectForKey:@"NSFileHandleNotificationFileHandleItem"];
  NSDebugDeepMLog(@"%@ announceNewConnection notification=%@ "
		  @"socketAddress=%@ [notification userInfo]=%p",
                   GSCurrentThread(),
                   notification,
                   [inStream socketAddress],
                   [notification userInfo]);
  if (![self isConnectionAllowedWithHandle:inStream
             returnedMessage:&connRefusedMessage])
    {
      NSDebugDeepMLog(@"DESTROY the connection: conn refused - "
		      @"%@ - A1 readInProgress=%d",
                       GSCurrentThread(),
                       (int)[_fileHandle readInProgress]);
      [GSWDefaultAdaptorThread sendConnectionRefusedResponseToStream:inStream
                               withMessage:connRefusedMessage];
      inStream=nil;
    }
  else
    {
      NSDebugDeepMLLog(@"info",@"notification userInfo=%@",
                       [notification userInfo]);
      NSDebugDeepMLog(@"%@ - A1 readInProgress=%d",
                      GSCurrentThread(),
                      (int)[_fileHandle readInProgress]);
      NSDebugDeepMLLog(@"%@ - A1 readInProgress=%d",
                       GSCurrentThread(),
                       (int)[_fileHandle readInProgress]);
      NSDebugDeepMLog(@"NEW CONN APP _selfLockn=%d _selfLock_thread_id=%@ "
		      @"_globalLockn=%d _globalLock_thread_id=%@ "
		      @"threads count=%d waitingThreads count=%d blocked=%d",
		      (int)([GSWApplication application]->_selfLockn),
		      ([GSWApplication application]->_selfLock_thread_id),
		      (int)([GSWApplication application]->_globalLockn),
		      ([GSWApplication application]->_globalLock_thread_id),
		      [_threads count],
		      [_waitingThreads count],
		      _blocked);
      NSDebugDeepMLog(@"[waitingThreads count]=%d queueSize=%d",
		      [_waitingThreads count],_queueSize);
      if ([_waitingThreads count]>=_queueSize)
	{
          //remove expired thread
          if ([self tryLock])
            {
              NSDebugMLog0(@"locked !");
              NS_DURING
                {
                  int i=0;
                  GSWDefaultAdaptorThread* thread=nil;
                  for(i=0;i<[_waitingThreads count];)
                    {
                      thread=[_waitingThreads objectAtIndex:i];
                      if ([thread isExpired])
                        {
//                          [GSWDefaultAdaptorThread sendRetryLasterResponseToStream:[thread stream]];
                          [_waitingThreads removeObjectAtIndex:i];
                        }
                      else
                        i++;
                    };
                }
              NS_HANDLER
                {
                  LOGException(@"%@ (%@)",
                               localException,[localException reason]);
                  //TODO
                  [self unlock];
                  [localException raise];
                }
              NS_ENDHANDLER;
              [self unlock];
            };
        };                  
      if ([_waitingThreads count]>=_queueSize)
        {
          NSDebugDeepMLog(@"DESTROY the connection: too many conn - "
			  @"%@ - A1 readInProgress=%d",
                           GSCurrentThread(),
                           (int)[_fileHandle readInProgress]);
          [GSWDefaultAdaptorThread sendRetryLasterResponseToStream:inStream];
          inStream=nil;
        }
      else
	{
	  //release done after lock !
	  newThread=[[GSWDefaultAdaptorThread alloc] initWithApp:[GSWApplication application]
                                                      withAdaptor:self
                                                      withStream:inStream];
	  if (newThread)
            {
              NSDebugLockMLog0(@"_newThread !");
              if ([self tryLock])
                {
                  NSDebugLockMLog0(@"locked !");
                  NS_DURING
                    {
                      NSDebugLockMLLog(@"low",
                                       @"[waitingThreads count]=%d [threads count]=%d",
                                       [_waitingThreads count],
                                       [_threads count]);
                      if ([_threads count]<_workerThreadCount)
                        {
                          [_threads addObject:newThread];
                          NSDebugLockMLLog(@"trace",@"isMultiThreadEnabled=%d",
                                           _isMultiThreadEnabled);
                          if (_isMultiThreadEnabled)
                            {
                              requestDate=[NSCalendarDate calendarDate];
                              requestDateString
				=[NSString stringWithFormat:@"%@ : "
					   @"Lauch Thread (Multi) %@",
					   GSCurrentThread(),
					   requestDate];
                              [GSWApplication statusLogWithFormat:@"%@",
					      requestDateString];
                              NSDebugLockMLLog(@"info",
                                               @"%@ : "
					       @"Lauch Thread (Multi) %p",
                                               GSCurrentThread(),
                                               (void*)newThread);
                              [NSThread detachNewThreadSelector:@selector(run:)
                                        toTarget:newThread
                                        withObject:nil];
                              DESTROY(newThread);
                            }
                          else
                            {
                              //Runit after
                              /*
                                [GSWApplication statusLogWithFormat:@"Lauch Thread (Mono)"];
                                NSDebugMLLog(@"info",
                                @"Lauch Thread (Mono) %p",
                                (void*)_newThread);
                                [_newThread run:nil];
                              */
                            };
                        }
                      else
                        {
                          [GSWApplication statusLogWithFormat:@"Set Thread to wait"];
                          NSDebugLockMLLog(@"info",
                                           @"Set Thread to wait %p",
                                           (void*)newThread);
                          [_waitingThreads addObject:newThread];
                          DESTROY(newThread);
                        };
                    }
                  NS_HANDLER
                    {
                      LOGException(@"%@ (%@)",
                                   localException,[localException reason]);
                      //TODO
                      [self unlock];
                      [localException raise];
                    }
                  NS_ENDHANDLER;
                  [self unlock];
                }
              else
                {
                  DESTROY(newThread);
                };
            };
	  if (!_isMultiThreadEnabled && newThread)
            {
              requestDate=[NSCalendarDate calendarDate];
              requestDateString=[NSString stringWithFormat:@"Lauch Thread (Mono) %@",requestDate];
              [GSWApplication statusLogWithFormat:@"%@",requestDateString];
              NSDebugLockMLLog(@"info",
                               @"%@ %p",
                               requestDateString,
                               (void*)newThread);
              [newThread run:nil];
              DESTROY(newThread);
              requestDate=[NSCalendarDate calendarDate];
              requestDateString=[NSString stringWithFormat:@"Stop Thread (Mono) %@",requestDate];
              [GSWApplication statusLogWithFormat:@"%@",requestDateString];
              NSDebugLockMLLog0(@"info",
                                requestDateString);
            };
        };
    };
  NSDebugLockMLLog(@"trace",@"Try Lock");
  if ([self tryLock])
    {
      BOOL accept=YES;//NEW[waitingThreads count]<queueSize;
      NSDebugLockMLLog(@"trace",@"Accept=%d",accept);
      NS_DURING
        {
          if (accept)
            {
              [listenHandle acceptConnectionInBackgroundAndNotify];
              _blocked=NO;
              NSDebugDeepMLog(@"ACCEPT %@ A2 readInProgress=%d",
                               GSCurrentThread(),
			      (int)[_fileHandle readInProgress]);
            }
          else
            {
              NSDebugDeepMLog(@"NOT ACCEPT %@ A2 readInProgress=%d",
                              GSCurrentThread(),
			      (int)[_fileHandle readInProgress]);
            };
          NSDebugLockMLog(@"%@ A2 readInProgress=%d",
                          GSCurrentThread(),
			  (int)[_fileHandle readInProgress]);
        }
      NS_HANDLER
        {
          LOGException(@"%@ (%@)",
                       localException,[localException reason]);
          //TODO
          _blocked=!accept;
          [self unlock];
          [localException raise];
        }
      NS_ENDHANDLER;
      _blocked=!accept;		  
      printf("blocked=%d",_blocked);
      [self unlock];
    };
  NSDebugLockMLLog(@"trace",@"end announceNewConnection");
  NSDebugDeepMLog(@"END NEWCONN APP _selfLockn=%d _selfLock_thread_id=%@ "
		  @"_globalLockn=%d _globalLock_thread_id=%@ "
		  @"threads count=%d waitingThreads count=%d "
		  @"blocked=%d acceptOK",
		  (int)([GSWApplication application]->_selfLockn),
		  ([GSWApplication application]->_selfLock_thread_id),
		  (int)([GSWApplication application]->_globalLockn),
		  ([GSWApplication application]->_globalLock_thread_id),
		  [_threads count],
		  [_waitingThreads count],
		  _blocked);
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)adaptorThreadExited:(GSWDefaultAdaptorThread*)adaptorThread
{
  LOGObjectFnStart();
//  NSDebugMLLog(@"trace",@"adaptorThreadExited");
  NSDebugDeepMLog0(@"adaptorThreadExited");
  NSDebugDeepMLog(@"EXIT APP _selfLockn=%d _selfLock_thread_id=%@ "
		  @"_globalLockn=%d _globalLock_thread_id=%@ "
		  @"threads count=%d waitingThreads count=%d blocked=%d",
		  (int)([GSWApplication application]->_selfLockn),
		  ([GSWApplication application]->_selfLock_thread_id),
		  (int)([GSWApplication application]->_globalLockn),
		  ([GSWApplication application]->_globalLock_thread_id),
		  [_threads count],
		  [_waitingThreads count],
		  _blocked);
  
  if ([self tryLock])
    {
      NSAutoreleasePool* pool=nil;
#ifndef NDEBUG
      pool=[NSAutoreleasePool new];
      GSWLogMemCF("New NSAutoreleasePool: %p",pool);
      NSDebugLockMLLog(@"low",
                       @"remove thread %p",
                       (void*)adaptorThread);
      GSWLogMemCF("Destroy NSAutoreleasePool: %p",pool);
      DESTROY(pool);
#endif
      NS_DURING
        {
          [adaptorThread retain];
          [adaptorThread autorelease];
          [_threads removeObject:adaptorThread];
        }
      NS_HANDLER
        {
          pool=[NSAutoreleasePool new];
          GSWLogMemCF("New NSAutoreleasePool: %p",pool);
          LOGException(@"%@ (%@)",
                       localException,
                       [localException reason]);
          GSWLogMemCF("Destroy NSAutoreleasePool: %p",pool);
          DESTROY(pool);
          //TODO
          //		  [self unlock];
          //		  [localException raise];
        }
      NS_ENDHANDLER;
#ifndef NDEBUG
      pool=[NSAutoreleasePool new];
      GSWLogMemCF("New NSAutoreleasePool: %p",pool);
      NSDebugLockMLLog(@"low",
                       @"[waitingThreads count]=%d [threads count]=%d",
                       [_waitingThreads count],
                       [_threads count]);
      GSWLogMemCF("Destroy NSAutoreleasePool: %p",pool);
      DESTROY(pool);
#endif
      if ([_threads count]==0)
        {
          BOOL isApplicationRequestHandlingLocked=[[GSWApplication application] isRequestHandlingLocked];
          if (isApplicationRequestHandlingLocked)
            {
              pool=[NSAutoreleasePool new];
              GSWLogMemCF("New NSAutoreleasePool: %p",pool);
              LOGSeriousError0(@"Application RequestHandling is LOCKED !!!");
              NSAssert(NO,@"Application RequestHandling is LOCKED !!!");//TODO-NOW
              [[GSWApplication application] terminate];
              GSWLogMemCF("Destroy NSAutoreleasePool: %p",pool);
              DESTROY(pool);
            };
        };
      if ([_waitingThreads count]>0 && [_threads count]<_workerThreadCount)
        {
          NS_DURING
            {
              GSWDefaultAdaptorThread* thread=nil;
              while(!thread && [_waitingThreads count]>0)
                {
                  thread=[_waitingThreads objectAtIndex:0];
                  if ([thread isExpired])
                    {
                      //[GSWDefaultAdaptorThread sendRetryLasterResponseToStream:[_thread stream]];
                      thread=nil;
                    }
                  else
                    [_threads addObject:thread];
                  [_waitingThreads removeObjectAtIndex:0];
                };
              if (thread)
                {
#ifndef NDEBUG
                  pool=[NSAutoreleasePool new];
                  GSWLogMemCF("New NSAutoreleasePool: %p",pool);
                  [GSWApplication statusLogWithFormat:@"Lauch waiting Thread"];
                  NSDebugLockMLLog(@"info",
                                   @"Lauch waiting Thread %p",
                                   (void*)thread);
                  GSWLogMemCF("Destroy NSAutoreleasePool: %p",pool);
                  DESTROY(pool);
#endif
                  if (_isMultiThreadEnabled)
                    [NSThread detachNewThreadSelector:@selector(run:)
                              toTarget:thread
                              withObject:nil];
                  else
                    [thread run:nil];
                };
            }
          NS_HANDLER
            {
              pool=[NSAutoreleasePool new];
              GSWLogMemCF("New NSAutoreleasePool: %p",pool);
              LOGException(@"%@ (%@)",
                           localException,
                           [localException reason]);
              GSWLogMemCF("Destroy NSAutoreleasePool: %p",pool);
              DESTROY(pool);
              //TODO
              //			  [self unlock];
              //			  [localException raise];
            }
          NS_ENDHANDLER;
        };
      
      NS_DURING
        {
          BOOL accept=[_waitingThreads count]<_queueSize;
          if (_blocked && accept)
            {
              NSDebugDeepMLog(@"ACCEPT AGAIN %@ A2 readInProgress=%d",
                               GSCurrentThread(),
			      (int)[_fileHandle readInProgress]);
              [_fileHandle acceptConnectionInBackgroundAndNotify];
              _blocked=NO;
            };
        }
      NS_HANDLER
        {
          pool=[NSAutoreleasePool new];
          GSWLogMemCF("New NSAutoreleasePool: %p",pool);
          LOGException(@"%@ (%@)",
                       localException,
                       [localException reason]);
          GSWLogMemCF("Destroy NSAutoreleasePool: %p",pool);
          DESTROY(pool);
          //TODO
          //		  [self unlock];
          //		  [localException raise];
        }
      NS_ENDHANDLER;
      
      [self unlock];
    };
  NSDebugDeepMLog(@"END EXIT APP _selfLockn=%d _selfLock_thread_id=%@ "
		  @"_globalLockn=%d _globalLock_thread_id=%@ "
		  @"threads count=%d waitingThreads count=%d blocked=%d",
		  (int)([GSWApplication application]->_selfLockn),
		  ([GSWApplication application]->_selfLock_thread_id),
		  ([GSWApplication application]->_globalLockn),
		  ([GSWApplication application]->_globalLock_thread_id),
		  [_threads count],
		  [_waitingThreads count],
		  _blocked);
  //         (int)(((UnixFileHandle*)fileHandle)->acceptOK));
  NSDebugLockMLog(@"%@ B2 readInProgress=%d",
                  GSCurrentThread(),(int)[_fileHandle readInProgress]);
  LOGObjectFnStop();
};

-(NSFileHandle*)fileHandle
{
  return _fileHandle;
};
//--------------------------------------------------------------------
//NDFN
-(id)announceBrokenConnection:(id)notification
{
  LOGObjectFnNotImplemented();	//TODOFN
  NSDebugMLLog(@"trace",@"announceBrokenConnection");
//  [self shutDownConnectionWithSocket:[in_port _port_socket]];
  return self;
};

//--------------------------------------------------------------------
//	lock
-(BOOL)tryLock
{
  BOOL locked=NO;
  LOGObjectFnStart();
  NSDebugLockMLog(@"self=%p %@ TRYLOCK",
                   self, GSCurrentThread());
  locked=LoggedTryLockBeforeDate(_selfLock,
				 [NSDate dateWithTimeIntervalSinceNow:90]);
  NSDebugLockMLog(@"self=%p %@ TRYLOCK LOCKED ?",
                   self, GSCurrentThread());
  LOGObjectFnStop();
  return locked;
};

//--------------------------------------------------------------------
//	unlock
-(void)unlock
{
  LOGObjectFnStart();
  NSDebugLockMLog(@"self=%p %@ UNLOCK",
         self, GSCurrentThread());
  LoggedUnlock(_selfLock);
  NSDebugLockMLog(@"self=%p %@ UNLOCK UNLOCKED ?",
                   self, GSCurrentThread());
  LOGObjectFnStop();
};

-(BOOL)isConnectionAllowedWithHandle:(NSFileHandle*)handle
                     returnedMessage:(NSString**)retMessage
{
  BOOL allowed=YES;
  if ([_adaptorHost length]>0)
    {
      NSString* connAddress=[handle socketAddress];
      NSDebugMLog(@"HANDLE connAddress: %@ _adaptorHost=%@",connAddress,_adaptorHost);
      if ([connAddress isEqualToString:_adaptorHost])
        {
          [GSWApplication statusDebugWithFormat:@"ACCEPTED connection from: %@ (Allowed: %@)",
                          connAddress,_adaptorHost];
        }
      else
        {
          [GSWApplication statusLogErrorWithFormat:@"REFUSED connection from: %@ (Allowed: %@)",
                          connAddress,_adaptorHost];
          allowed=NO;
          if (retMessage)
            *retMessage=@"host denied";//TODO
          //TODO
        };
    }
  else
    {
#if HAVE_LIBWRAP
      NSString* appName=nil;
      struct request_info libwrapRequestInfo;
      memset(&libwrapRequestInfo,0,sizeof(libwrapRequestInfo));

      appName=[[GSWApplication application]name];
      request_init(&libwrapRequestInfo, RQ_DAEMON,[appName cString], RQ_FILE, [handle fileDescriptor], 0);
      
      fromhost(&libwrapRequestInfo);      
      if (STR_EQ(eval_hostname(libwrapRequestInfo.client), paranoid) || !hosts_access(&libwrapRequestInfo)) 
        {
          allowed=NO;
          if (retMessage)
            *retMessage=@"libwrap denied";//TODO
          [GSWApplication statusDebugWithFormat:@"libwrap app: %@ REFUSED connection from: %s (%s)",
                          appName,
                          libwrapRequestInfo.client[0].name,
                          libwrapRequestInfo.client[0].addr];
        }
      else
        {
          [GSWApplication statusDebugWithFormat:@"libwrap app: %@ ACCEPTED connection from: %s (%s)",
                          appName,
                          libwrapRequestInfo.client[0].name,
                          libwrapRequestInfo.client[0].addr];
        }
#endif
    };
  return allowed;
};

@end


//====================================================================
@implementation GSWDefaultAdaptor (GSWDefaultAdaptorA)
-(void)stop
{
  LOGObjectFnNotImplemented();	//TODOFN
};

-(void)run
{
  LOGObjectFnNotImplemented();	//TODOFN
};

-(void)_runOnce
{
  LOGObjectFnNotImplemented();	//TODOFN
};


@end
