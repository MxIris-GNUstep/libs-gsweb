/** GSWMessage.m - <title>GSWeb: Class GSWMessage</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
   $Revision$
   $Date$
   $Id$

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

#include <GNUstepBase/Unicode.h>
#include "GSWeb.h"
#include "NSData+Compress.h"


static NSStringEncoding globalDefaultEncoding=GSUndefinedEncoding;
static NSString* globalDefaultURLEncoding=nil;

static SEL appendDataSel = NULL;
static SEL appendContentStringSEL = NULL;

static SEL stringByEscapingHTMLStringSEL = NULL;
static SEL stringByEscapingHTMLAttributeValueSEL = NULL;
static SEL stringByConvertingToHTMLEntitiesSEL = NULL;
static SEL stringByConvertingToHTMLSEL = NULL;

// Site size of Ascii characters to data cache
#define GSWMESSGAEDATACHESIZE 128
static id GSWMessageDataCache[GSWMESSGAEDATACHESIZE];

// Default data content size
#define DEF_CONTENT_SIZE 81920

//====================================================================
#ifndef NO_GNUSTEP

@interface GSWMessage (GSWMessageCachePrivate)
-(void)_cacheAppendData:(NSData*)data;
-(void)_cacheAppendBytes:(const void*)aBuffer
                  length:(unsigned int)bufferSize;
@end

#endif

//====================================================================
#define assertContentDataADImp();		\
	{ if (!_contentDataADImp) { 		\
		_contentDataADImp=[_contentData \
			methodForSelector:appendDataSel]; }; };

#define assertCurrentCacheDataADImp();		\
	{ if (!_currentCacheDataADImp) { 		\
		_currentCacheDataADImp=[_currentCacheData \
			methodForSelector:appendDataSel]; }; };

//====================================================================

// Initialize Ascii string to data cache
void initGSWMessageDataCache(void)
{
  int i=0;
  char cstring[2];
  NSString *myNSString;
  NSData   *myData;
  
  cstring[1] = 0;
  
  for (i=0;i<GSWMESSGAEDATACHESIZE;i++)
    {
      cstring[0] = (char)i;
      myNSString = [NSString stringWithCString:cstring
                             length:1];
      myData = [myNSString dataUsingEncoding:NSASCIIStringEncoding
                           allowLossyConversion:YES];
      [myData retain];
      GSWMessageDataCache[i] = myData;
    };
}

//====================================================================
@implementation GSWMessage

static __inline__ NSMutableData *_checkBody(GSWMessage *self) {
  if (self->_contentData == nil) {
    self->_contentData = [[NSMutableData alloc] initWithCapacity:DEF_CONTENT_SIZE];
  }
  if (!self->_contentDataADImp) { 		
		self->_contentDataADImp=[self->_contentData methodForSelector:appendDataSel]; 
		}
  return self->_contentData;
}

//--------------------------------------------------------------------
+ (void) initialize
{
  if (self == [GSWMessage class])
    {
      appendDataSel = @selector(appendData:);
      appendContentStringSEL = @selector(appendContentString:);

      stringByEscapingHTMLStringSEL = @selector(stringByEscapingHTMLString:);
      stringByEscapingHTMLAttributeValueSEL = @selector(stringByEscapingHTMLAttributeValue:);
      stringByConvertingToHTMLEntitiesSEL = @selector(stringByConvertingToHTMLEntities:);
      stringByConvertingToHTMLSEL = @selector(stringByConvertingToHTML:);
           
      globalDefaultEncoding = WOStrictFlag ? NSISOLatin1StringEncoding : GetDefEncoding();
      initGSWMessageDataCache();
    };
};

//--------------------------------------------------------------------
//	init

-(id)init 
{
  LOGObjectFnStart();
  if ((self=[super init]))
    {
      _selfClass=[self class];
      _appendContentStringIMP=[self methodForSelector:@selector(appendContentString:)]; 

      _stringByEscapingHTMLStringIMP = [_selfClass methodForSelector:stringByEscapingHTMLStringSEL];
      NSAssert(_stringByEscapingHTMLStringIMP,@"No IMP for stringByEscapingHTMLString:");

      _stringByEscapingHTMLAttributeValueIMP = [_selfClass methodForSelector:stringByEscapingHTMLAttributeValueSEL];
      NSAssert(_stringByEscapingHTMLAttributeValueIMP,@"No IMP for stringByEscapingHTMLAttributeValue:");

      _stringByConvertingToHTMLEntitiesIMP = [_selfClass methodForSelector:stringByConvertingToHTMLEntitiesSEL];
      NSAssert(_stringByConvertingToHTMLEntitiesIMP,@"No IMP for stringByConvertingToHTMLEntities:");

      _stringByConvertingToHTMLIMP = [_selfClass methodForSelector:stringByConvertingToHTMLSEL];
      NSAssert(_stringByConvertingToHTMLIMP,@"No IMP for stringByConvertingToHTML:");

      ASSIGN(_httpVersion,@"HTTP/1.0");
      _headers=[NSMutableDictionary new];
      _contentEncoding=[_selfClass defaultEncoding];
      _checkBody(self);
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
//  GSWLogAssertGood(self);
//  NSDebugFLog(@"dealloc Message %p",self);
//  NSDebugFLog0(@"Release Message httpVersion");
  DESTROY(_httpVersion);
//  NSDebugFLog0(@"Release Message headers");
  DESTROY(_headers);
//  NSDebugFLog0(@"Release Message contentString");
//  DESTROY(_contentString);
//  NSDebugFLog0(@"Release Message contentData");
  DESTROY(_contentData);
//  NSDebugFLog0(@"Release Message userInfo");
  DESTROY(_userInfo);
  //NSDebugFLog0(@"Release Message cookies");
  DESTROY(_cookies);
//  NSDebugFLog0(@"Release Message");
#ifndef NO_GNUSTEP
  DESTROY(_cachesStack);
#endif
  [super dealloc];
};

//--------------------------------------------------------------------
-(id)copyWithZone:(NSZone*)zone
{
  GSWMessage* clone = [[isa allocWithZone:zone] init];
  if (clone)
    {
      ASSIGNCOPY(clone->_httpVersion,_httpVersion);

      DESTROY(clone->_headers);
      clone->_headers=[_headers mutableCopyWithZone:zone];

      clone->_contentEncoding=_contentEncoding;
      ASSIGNCOPY(clone->_userInfo,_userInfo);
      ASSIGNCOPY(clone->_cookies,_cookies);

//      DESTROY(clone->_contentString);
//      clone->_contentString=[_contentString mutableCopyWithZone:zone];
//      clone->_contentStringASImp=NULL;

      DESTROY(clone->_contentData);
      clone->_contentData=[_contentData mutableCopyWithZone:zone];
      clone->_contentDataADImp=NULL;

#ifndef NO_GNUSTEP
      DESTROY(clone->_cachesStack);
      clone->_cachesStack=[_cachesStack mutableCopyWithZone:zone];
      if ([clone->_cachesStack count]>0)
        {
          clone->_currentCacheData=[clone->_cachesStack lastObject];
          clone->_currentCacheDataADImp=NULL;
        };
#endif
    };
  return clone;
};

//--------------------------------------------------------------------
// Used in transactions
-(BOOL)isEqual:(id)anObject
{
  BOOL isEqual=NO;

  if (anObject==self)
    isEqual=YES;
  else if ([anObject isKindOfClass:[GSWMessage class]])
    {
      GSWMessage* aMessage=(GSWMessage*)anObject;
      if ((_headers == aMessage->_headers
           || [_headers isEqual:aMessage->_headers])
          && [_contentData isEqual:aMessage->_contentData])
        isEqual=YES;
    };
          
  return isEqual;
}

//--------------------------------------------------------------------
//	setHTTPVersion:

//sets the http version (like @"HTTP/1.0"). 
-(void)setHTTPVersion:(NSString*)version
{
  ASSIGN(_httpVersion,version);
};

//--------------------------------------------------------------------
//	httpVersion

//return http version like @"HTTP/1.0"

-(NSString*)httpVersion
{
  return _httpVersion;
};

//--------------------------------------------------------------------
//	setUserInfo:

-(void)setUserInfo:(NSDictionary*)userInfo
{
  ASSIGN(_userInfo,userInfo);
};

//--------------------------------------------------------------------
//	userInfo

-(NSDictionary*)userInfo 
{
  return _userInfo;
};


//--------------------------------------------------------------------
//	setHeader:forKey:

// Should replace, not append. FIXME later
-(void)setHeader:(NSString*)header
          forKey:(NSString*)key
{
  //OK
  id object=nil;
  NSAssert(header,@"No header");
  NSAssert(key,@"No header key");
  object=[_headers objectForKey:key];
  if (object)
    [self setHeaders:[object arrayByAddingObject:header]
          forKey:key];
  else
    [self setHeaders:[NSArray arrayWithObject:header]
          forKey:key];
};

//--------------------------------------------------------------------
-(void)appendHeader:(NSString*)header
             forKey:(NSString*)key
{
  [self appendHeaders:[NSArray arrayWithObject:header]
        forKey:key];
}


//--------------------------------------------------------------------
//	setHeaders:forKey:

-(void)setHeaders:(NSArray*)headers
           forKey:(NSString*)key
{
  NSAssert(headers,@"No headers");
  NSAssert(key,@"No header key");

  NSDebugMLLog(@"GSWMessage",@"_headers=%@",_headers);

  if (!_headers)
    _headers=[NSMutableDictionary new];

  NSDebugMLLog(@"GSWMessage",@"key=%@ headers=%@",key,headers);

  [_headers setObject:headers
            forKey:key];
};


//--------------------------------------------------------------------
-(void)appendHeaders:(NSArray*)headers
              forKey:(NSString*)key
{
  id object=nil;
  NSAssert(headers,@"No headers");
  NSAssert(key,@"No header key");

  object=[_headers objectForKey:key];
  if (object)
    [self setHeaders:[object arrayByAddingObjectsFromArray:headers]
          forKey:key];
  else
    [self setHeaders:headers
          forKey:key];
};

//--------------------------------------------------------------------
//	setHeaders:
 
-(void)setHeaders:(NSDictionary*)headerDictionary
{
  NSDebugMLLog(@"GSWMessage",@"headerDictionary=%@",headerDictionary);

  NSDebugMLLog(@"GSWMessage",@"_headers=%@",_headers);

  if (!_headers && [headerDictionary count]>0)
    _headers=[NSMutableDictionary new];
  
  if (headerDictionary)
    {
      NSEnumerator* keyEnum=nil;
      id	    headerName=nil;
    
      keyEnum = [headerDictionary keyEnumerator];
      while ((headerName = [keyEnum nextObject]))
        {
          id value=[headerDictionary objectForKey:headerName];
          if (![value isKindOfClass:[NSArray class]])
            value=[NSArray arrayWithObject:value];
          [self setHeaders:value
                forKey:headerName];
 	};
    };

  NSDebugMLLog(@"GSWMessage",@"_headers=%@",_headers);
};
 
//--------------------------------------------------------------------
//	headers

-(NSMutableDictionary*)headers
{
  return _headers;
};

//--------------------------------------------------------------------
//	headerForKey:

//  return:
//  	nil: if no header for key_
//	1st header: if multiple headers for key_
//	header: otherwise

-(NSString*)headerForKey:(NSString*)key
{
  id object=[_headers objectForKey:key];

  if (object && [object isKindOfClass:[NSArray class]])
    return [object objectAtIndex:0];
  else
    return (NSString*)object;
};

//--------------------------------------------------------------------
//	headerKeys

// return array of header keys or nil if no header
-(NSArray*)headerKeys 
{
  return [_headers allKeys];
};

//--------------------------------------------------------------------
//	headersForKey:

//return array of headers of key_
-(NSArray*)headersForKey:(NSString*)key
{
  id object=[_headers objectForKey:key];

  if (!object || [object isKindOfClass:[NSArray class]])
    return (NSArray*)object;
  else
    return [NSArray arrayWithObject:object];
};

//--------------------------------------------------------------------
-(void)removeHeader:(NSString*)header
             forKey:(NSString*)key
{
  id object=[_headers objectForKey:key];

  if (object)
    {
      if ([object isKindOfClass:[NSArray class]])
        {
          int index=[object indexOfObject:header];
          if (index!=NSNotFound)
            {
              if ([object count]==1)
                [_headers removeObjectForKey:key];
              else
                {                  
                  object=[[object mutableCopy]autorelease];
                  [object removeObjectAtIndex:index];
                  [self setHeaders:object
                        forKey:key];
                };
            }
        }
      else if ([object isEqual:header])
        {
          [_headers removeObjectForKey:key];
        };
    };
};

//--------------------------------------------------------------------
-(void)removeHeaderForKey:(NSString*)key
{
  [self removeHeadersForKey:key];
}

//--------------------------------------------------------------------
-(void)removeHeadersForKey:(NSString*)key
{
  [_headers removeObjectForKey:key];
}

//--------------------------------------------------------------------
/** Set content with contentData
**/
-(void)setContent:(NSData*)contentData
{
  LOGObjectFnStart();
  DESTROY(_contentData);
  [self appendContentData:contentData];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	content
-(NSData*)content
{
  LOGObjectFnStart();

  LOGObjectFnStop();

  return _contentData;
};

//--------------------------------------------------------------------
-(NSString*)contentString
{
  NSString* contentString=nil;

  LOGObjectFnStart();

  NS_DURING
    {
      contentString=AUTORELEASE([[NSString alloc] initWithData:_contentData
                                                  encoding:[self contentEncoding]]);
    }
  NS_HANDLER
    {
      NSWarnLog(@"Can't convert contentData to Strong: %@",localException);
    }
  NS_ENDHANDLER;

  return contentString;
};

//--------------------------------------------------------------------
-(void)appendContentData:(NSData*)contentData
{
  LOGObjectFnStart();

  NSDebugMLLog(@"low",@"contentData:%@",contentData);

  if (contentData)
    {
      _checkBody(self);
      (*_contentDataADImp)(_contentData,appendDataSel,contentData);

#ifndef NO_GNUSTEP
      // Caching management
      if (_currentCacheData)
        {
          assertCurrentCacheDataADImp();
          (*_currentCacheDataADImp)(_currentCacheData,appendDataSel,contentData);
        };
#endif
    };

  LOGObjectFnStop();
}

//--------------------------------------------------------------------
- (void)appendContentString:(NSString *)aValue 
{
  LOGObjectFnStart();

  // checking [aValue length] takes too long!  
  if (aValue)
    {
      NSData *myData = [aValue dataUsingEncoding:_contentEncoding
                               allowLossyConversion:NO];

      if (!myData)
        {
          NSLog(aValue);
          [NSException raise:NSInvalidArgumentException 
                       format:@"%s: could not convert '%s' non-lossy to encoding %i",
                       __PRETTY_FUNCTION__, [aValue lossyCString],_contentEncoding];  
        }

      _checkBody(self);
      (*_contentDataADImp)(_contentData,appendDataSel,myData);

#ifndef NO_GNUSTEP
      // Caching management
      if (_currentCacheData)
        {
          assertCurrentCacheDataADImp();
          (*_currentCacheDataADImp)(_currentCacheData,appendDataSel,myData);
        };
#endif
    };

  LOGObjectFnStop();
}

//--------------------------------------------------------------------
-(void)_appendContentAsciiString:(NSString*) aValue
{
  LOGObjectFnStart();

  // checking [aValue length] takes too long!  
  if (aValue)
    {
      NSData *myData = nil;
      const char *lossyCString = NULL;
      int    length = 0;
      int    i = 0;
      int    ch = 0;
        
      lossyCString = [aValue lossyCString];
      length = strlen(lossyCString);

      _checkBody(self);
  
      for (i=0; i<length;i++)
        {
          ch = lossyCString[i];
          myData=GSWMessageDataCache[ch];
          (*_contentDataADImp)(_contentData,appendDataSel,myData);

#ifndef NO_GNUSTEP
          // Caching management
          if (_currentCacheData)
            {
              assertCurrentCacheDataADImp();
              (*_currentCacheDataADImp)(_currentCacheData,appendDataSel,myData);
            };
#endif
        }
    };

  LOGObjectFnStop();
}

//--------------------------------------------------------------------
//	appendContentCharacter:
// append one ASCII char
-(void)appendContentCharacter:(char)aChar
{
  NSData *myData = nil;
  int i = aChar;

  LOGObjectFnStart();
  
  myData=GSWMessageDataCache[i];
  
  if (!myData)
    {
      NSString* string=[NSString stringWithCString:&aChar
                                 length:1];
      if (string)
        {
          (*_appendContentStringIMP)(self,appendContentStringSEL,string);
        }
    }
  else
    {
      _checkBody(self);
      (*_contentDataADImp)(_contentData,appendDataSel,myData);

#ifndef NO_GNUSTEP
      // Caching management
      if (_currentCacheData)
        {
          assertCurrentCacheDataADImp();
          (*_currentCacheDataADImp)(_currentCacheData,appendDataSel,myData);
        };
#endif
    }

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(int)_contentLength
{
  return [_contentData length];
}

//--------------------------------------------------------------------
//	contentEncoding

-(NSStringEncoding)contentEncoding 
{
  return _contentEncoding;
};

//--------------------------------------------------------------------
//	setContentEncoding:

-(void)setContentEncoding:(NSStringEncoding)encoding
{
  NSDebugMLLog(@"low",@"setContentEncoding:%d",(int)encoding);
  _contentEncoding=encoding;
};


@end

//====================================================================
@implementation GSWMessage (GSWContentConveniences)

//--------------------------------------------------------------------
//	appendContentBytes:length:

-(void)appendContentBytes:(const void*)bytes
                   length:(unsigned)length
{
  LOGObjectFnStart();
  if ((length>0) && (bytes != NULL))
    {
      [_contentData appendBytes:bytes
                    length:length];

#ifndef NO_GNUSTEP
      // Caching management
      if (_currentCacheData)
        {
          [_currentCacheData appendBytes:bytes
                             length:length];
        };
#endif
    };
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	appendDebugCommentContentString:

-(void)appendDebugCommentContentString:(NSString*)aString
{
#ifndef NDEBUG
  if (GSDebugSet(@"debugComments") == YES)
    {
      (*_appendContentStringIMP)(self,appendContentStringSEL,@"\n<!-- ");
      (*_appendContentStringIMP)(self,appendContentStringSEL,aString);
      (*_appendContentStringIMP)(self,appendContentStringSEL,@" -->\n");      
    };
#endif
};

//--------------------------------------------------------------------
-(void)replaceContentData:(NSData*)replaceData
                   byData:(NSData*)byData
{
  LOGObjectFnStart();
  if ([replaceData length]>0) // is there something to replace ?
    {
      NSDebugMLog(@"[_contentData length]=%d",[_contentData length]);
      if ([_contentData length]>0)
        {
          [_contentData replaceOccurrencesOfData:replaceData
                        withData:byData
                        range:NSMakeRange(0,[_contentData length])];
        };
    };
  LOGObjectFnStop();
};

@end


//====================================================================
@implementation GSWMessage (GSWHTMLConveniences)

//--------------------------------------------------------------------
//	appendContentHTMLAttributeValue:

-(void)appendContentHTMLAttributeValue:(NSString*)value
{
  LOGObjectFnStart();

  NSDebugMLLog(@"low",@"response=%p value=%@",self,value);

  (*_appendContentStringIMP)(self,appendContentStringSEL,
                             (*_stringByEscapingHTMLAttributeValueIMP)
                             (_selfClass,stringByEscapingHTMLAttributeValueSEL,value));

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
//	appendContentHTMLString:

-(void)appendContentHTMLString:(NSString*)aString
{
  LOGObjectFnStart();

  NSDebugMLLog(@"low",@"aString=%@",aString);

  (*_appendContentStringIMP)(self,appendContentStringSEL,
                             (*_stringByEscapingHTMLStringIMP)
                             (_selfClass,stringByEscapingHTMLStringSEL,aString));

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)appendContentHTMLConvertString:(NSString*)aString
{
  LOGObjectFnStart();

  NSDebugMLLog(@"low",@"aString=%@",aString);

  (*_appendContentStringIMP)(self,appendContentStringSEL,
                             (*_stringByConvertingToHTMLIMP)
                             (_selfClass,stringByConvertingToHTMLSEL,aString));

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)appendContentHTMLEntitiesConvertString:(NSString*)aString
{
  LOGObjectFnStart();

  NSDebugMLLog(@"low",@"aString=%@",aString);

  (*_appendContentStringIMP)(self,appendContentStringSEL,
                             (*_stringByConvertingToHTMLEntitiesIMP)
                             (_selfClass,stringByConvertingToHTMLEntitiesSEL,aString));

  LOGObjectFnStop();
};

//--------------------------------------------------------------------
+(NSString*)stringByEscapingHTMLString:(NSString*)aString
{
  return [NSStringWithObject(aString) stringByEscapingHTMLString];
};

//--------------------------------------------------------------------
+(NSString*)stringByEscapingHTMLAttributeValue:(NSString*)aString
{
  return [NSStringWithObject(aString) stringByEscapingHTMLAttributeValue];
};

//--------------------------------------------------------------------
+(NSString*)stringByConvertingToHTMLEntities:(NSString*)aString
{
  return [NSStringWithObject(aString) stringByConvertingToHTMLEntities];
};

//--------------------------------------------------------------------
+(NSString*)stringByConvertingToHTML:(NSString*)aString
{
  return [NSStringWithObject(aString) stringByConvertingToHTML];
};

@end

//====================================================================
@implementation GSWMessage (Cookies)

//--------------------------------------------------------------------
-(NSString*)_formattedCookiesString
{
  LOGObjectFnNotImplemented();	//TODOFN
  return nil;
};

//--------------------------------------------------------------------
-(NSMutableArray*)_initCookies
{
  if (!_cookies)
    _cookies=[NSMutableArray new];
  return _cookies;
};

//--------------------------------------------------------------------
-(void)addCookie:(GSWCookie*)cookie
{
  //OK
  NSMutableArray* cookies=nil;
  LOGObjectFnStart();
  cookies=[self _initCookies];
  if (cookie)
    [cookies addObject:cookie];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(void)removeCookie:(GSWCookie*)cookie
{
  NSMutableArray* cookies=nil;
  LOGObjectFnStart();
  cookies=[self _initCookies];
  if (cookie)
    [cookies removeObject:cookie];
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(NSArray*)cookies
{
  NSMutableArray* cookies=[self _initCookies];
  return cookies;
};

//--------------------------------------------------------------------
//NDFN
-(NSArray*)cookiesHeadersValues
{
  NSMutableArray* strings=nil;
  NSArray* cookies=[self cookies];
  if ([cookies count]>0)
    {
      int i=0;
      int count=[cookies count];
      GSWCookie* cookie=nil;
      NSString* cookieString=nil;
      strings=[NSMutableArray array];
      for(i=0;i<count;i++)
        {
          cookie=[cookies objectAtIndex:i];
          cookieString=[cookie headerValue];
          NSAssert(cookieString,@"No cookie HeaderValue");
          [strings addObject:cookieString];
        };
    };
  return (strings ? [NSArray arrayWithArray:strings] : nil);
};

//--------------------------------------------------------------------
-(void)_finalizeCookiesInContext:(GSWContext*)aContext
{
  NSArray* cookieHeader=nil;
  NSArray* cookies=nil;
  NSString* cookiesKey=nil;
  BOOL isRequest=NO;
  
  isRequest=[self isKindOfClass:[GSWRequest class]];

  if (isRequest)
    cookiesKey=GSWHTTPHeader_Cookie;
  else
    cookiesKey=GSWHTTPHeader_SetCookie;

  cookieHeader=[self headersForKey:cookiesKey];
  if (cookieHeader)
    {
      ExceptionRaise(@"GSWResponse",
                     @"%@ header already exists",
                     GSWHTTPHeader_SetCookie);
    };
  cookies=[self cookies];
  if ([cookies count]>0)
    {
      id cookiesHeadersValues=[self cookiesHeadersValues];
      NSDebugMLLog(@"low",@"cookiesHeadersValues=%@",cookiesHeadersValues);
      [self setHeaders:cookiesHeadersValues
            forKey:cookiesKey];
    };
};

@end



//====================================================================
@implementation GSWMessage (KeyValueCoding)

+(BOOL)canAccessFieldsDirectly
{
  return YES;
}

@end

//====================================================================
@implementation GSWMessage (GSWMessageDefaultEncoding)

//--------------------------------------------------------------------
+(void)setDefaultEncoding:(NSStringEncoding)encoding
{
  globalDefaultEncoding=encoding;
};

//--------------------------------------------------------------------
+(NSStringEncoding)defaultEncoding
{
  return globalDefaultEncoding;
};

//--------------------------------------------------------------------
-(void)setDefaultURLEncoding:(NSString*)enc
{
  ASSIGN(globalDefaultURLEncoding,enc);
}

//--------------------------------------------------------------------
-(NSString*)defaultURLEncoding
{
  return globalDefaultURLEncoding;
}


@end


//====================================================================
#ifndef NO_GNUSTEP

@implementation GSWMessage (GSWMessageCache)

//--------------------------------------------------------------------
-(int)startCache
{
  int index=0;
  LOGObjectFnStart();

  if (!_cachesStack)
    {
      _cachesStack=[NSMutableArray new];
    };

  _currentCacheData=(NSMutableData*)[NSMutableData data];
  _currentCacheDataADImp=NULL;

  [_cachesStack addObject:_currentCacheData];

  index=[_cachesStack count]-1;

  LOGObjectFnStop();
  return index;
};

//--------------------------------------------------------------------
-(id)stopCacheOfIndex:(int)cacheIndex
{
  NSMutableData* cachedData=nil;
  int cacheStackCount=0;

  LOGObjectFnStart();

  NSDebugMLLog(@"GSWCacheElement",@"cacheIndex=%d",cacheIndex);

  cacheStackCount=[_cachesStack count];

  NSDebugMLLog(@"GSWCacheElement",@"cacheStackCount=%d",cacheStackCount);

  if (cacheIndex<cacheStackCount)
    {
      cachedData=[_cachesStack objectAtIndex:cacheIndex];
      AUTORELEASE(RETAIN(cachedData));

      NSDebugMLLog(@"GSWCacheElement",@"cachedData=%@",cachedData);

      // Last one ? (normal case)
      if (cacheIndex==(cacheStackCount-1))
        {
          [_cachesStack removeObjectAtIndex:cacheIndex];          
        }
      else
        {
          // Strange case: may be an exception which avoided component to retrieve their cache ?
          cacheIndex++;
          while(cacheIndex<cacheStackCount)
            {
              NSData* tmp=[_cachesStack objectAtIndex:cacheIndex];
              NSDebugMLLog(@"GSWCacheElement",@"tmp=%@",tmp);
              [cachedData appendData:tmp];
              [_cachesStack removeObjectAtIndex:cacheIndex];
            };
        };
      cacheStackCount=[_cachesStack count];

      //Add cachedData to previous cache item data
      if (cacheStackCount>0)
        {
          _currentCacheData=[_cachesStack objectAtIndex:cacheStackCount-1];
          _currentCacheDataADImp=NULL;
          if ([cachedData length]>0)
            {
              assertCurrentCacheDataADImp();
              (*_currentCacheDataADImp)(_currentCacheData,appendDataSel,cachedData);
            };
        }
      else
        {
          _currentCacheData=nil;
          _currentCacheDataADImp=NULL;
        };
    };

  NSDebugMLLog(@"GSWCacheElement",@"cachedData=%@",cachedData);

  LOGObjectFnStop();
  
  return cachedData;
}

@end

#endif
