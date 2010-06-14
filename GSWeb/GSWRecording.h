/** GSWRecording.h - <title>GSWeb: Class GSWRecording</title>

   Copyright (C) 2003 Free Software Foundation, Inc.
   
   Written by:  Manuel Guesdon <mguesdon@orange-concept.com>
   Date:        Aug 2003

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

// $Id$

#ifndef _GSWRecording_h__
	#define _GSWRecording_h__

@interface GSWRecording : NSObject
{
  long _recordingStep;
  GSWRequest* _request;
  NSString* _recordingPath;
  NSString* _wildcards;
}

@end


#endif // _GSWRecording_h__
