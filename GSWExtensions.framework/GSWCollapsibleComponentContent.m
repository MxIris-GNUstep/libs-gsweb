/** GSWCollapsibleComponentContent.m - <title>GSWeb: Class GSWCollapsibleComponentContent</title>

   Copyright (C) 1999-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Apr 1999
   
   $Revision$
   $Date$
   
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

#include "GSWExtWOCompatibility.h"
#include "GSWCollapsibleComponentContent.h"

//===================================================================================
@implementation GSWCollapsibleComponentContent

//-----------------------------------------------------------------------------------
-(void)dealloc
{
  GSWLogC("Dealloc GSWCollopsibleComponent");
  GSWLogC("Dealloc GSWCollopsibleComponent Super");
  DESTROY(_openedImageFileName);
  DESTROY(_closedImageFileName);
  DESTROY(_openedHelpString);
  DESTROY(_closedHelpString);
  [super dealloc];
  GSWLogC("End Dealloc GSWCollopsibleComponent");
};

//-----------------------------------------------------------------------------------
-(BOOL)synchronizesVariablesWithBindings
{
    return NO;
};

//-----------------------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext 
{
  _tmpAnchorName=[NSString stringWithString:[[self context] elementID]];
  [super appendToResponse:aResponse
         inContext:aContext];
  _tmpAnchorName=nil;
};

//-----------------------------------------------------------------------------------
-(BOOL)isVisible
{
  LOGObjectFnStart();
  NSDebugMLog(@"_isVisibleConditionPassed=%s",(_isVisibleConditionPassed ? "YES" : "NO"));
  if (!_isVisibleConditionPassed)
	{
          if ([self hasBinding:@"condition"])
            _isVisible=boolValueFor([self valueForBinding:@"condition"]);
          else if ([self hasBinding:@"visibility"])
            _isVisible=boolValueFor([self valueForBinding:@"visibility"]);
          else
            _isVisible=boolValueFor([self valueForBinding:@"condition"]);
	  _isVisibleConditionPassed=YES;
	};
  NSDebugMLog(@"_isVisible=%s",(_isVisible ? "YES" : "NO"));
  LOGObjectFnStop();
  return _isVisible;
};

//-----------------------------------------------------------------------------------
-(GSWComponent*)toggleVisibilityAction
{
  LOGObjectFnStart();
  NSDebugMLog(@"_isVisible=%s",(_isVisible ? "YES" : "NO"));
  _isVisible = ![self isVisible];
  NSDebugMLog(@"_isVisible=%s",(_isVisible ? "YES" : "NO"));
  if ([self hasBinding:@"visibility"])
	{
	  [self setValue:[NSNumber numberWithBool:_isVisible]
							   forBinding:@"visibility"];
	};
  LOGObjectFnStop();
  return nil;
};

//-----------------------------------------------------------------------------------
-(NSString*)imageFileName
{
  NSString* _image=nil;
  LOGObjectFnStart();
  if ([self isVisible])
	{
	  if (!_openedImageFileName) 
		{
		  if ([self hasBinding:@"openedImageFileName"])
			ASSIGN(_openedImageFileName,[self valueForBinding:@"openedImageFileName"]);
		  else if ([self hasBinding:@"helpString"])
			ASSIGN(_openedImageFileName,[self valueForBinding:@"helpString"]);
		  else
			ASSIGN(_openedImageFileName,@"DownTriangle.png");
		};
	  _image=_openedImageFileName;
	}
  else
	{
	  NSDebugMLog(@"_closedImageFileName=%@",_closedImageFileName);
	  if (!_closedImageFileName) 
		{
		  if ([self hasBinding:@"closedImageFileName"])
			ASSIGN(_closedImageFileName,[self valueForBinding:@"closedImageFileName"]);
		  else if ([self hasBinding:@"helpString"])
			ASSIGN(_closedImageFileName,[self valueForBinding:@"helpString"]);
		  else
			ASSIGN(_closedImageFileName,@"RightTriangle.png");
		};
	  _image=_closedImageFileName;
	};
  NSDebugMLog(@"_image=%@",_image);
  LOGObjectFnStop();
  return _image;
};

//-----------------------------------------------------------------------------------
-(NSString*)label
{
  NSString* _label=nil;
  LOGObjectFnStart();
  if ([self isVisible])
	{
	  if ([self hasBinding:@"openedLabel"])
		_label=[self valueForBinding:@"openedLabel"];
	  else if ([self hasBinding:@"label"])
		_label=[self valueForBinding:@"label"];
	}
  else
	{
	  if ([self hasBinding:@"closedLabel"])
		_label=[self valueForBinding:@"closedLabel"];
	  else if ([self hasBinding:@"label"])
		_label=[self valueForBinding:@"label"];
	};
  NSDebugMLog(@"_label=%@",_label);
  LOGObjectFnStop();
  return _label;
};

//-----------------------------------------------------------------------------------
-(NSString*)helpString
{
  NSString* _helpString=nil;
  LOGObjectFnStart();
  if ([self isVisible])
	{
	  if (!_openedHelpString)
		{
		  if ([self hasBinding:@"openedHelpString"])
			ASSIGN(_openedHelpString,[self valueForBinding:@"openedHelpString"]);
		  else if ([self hasBinding:@"helpString"])
			ASSIGN(_openedHelpString,[self valueForBinding:@"helpString"]);
		  else
			ASSIGN(_openedHelpString,@"Click to collapse");
		};
	  _helpString=_openedHelpString;
	}
  else
	{
	  if (!_closedHelpString) 
		{
		  if ([self hasBinding:@"closedHelpString"])
			ASSIGN(_closedHelpString,[self valueForBinding:@"closedHelpString"]);
		  else if ([self hasBinding:@"helpString"])
			ASSIGN(_closedHelpString,[self valueForBinding:@"helpString"]);
		  else
			ASSIGN(_closedHelpString,@"Click to expand");
		};
	  _helpString=_closedHelpString;
	};
  NSDebugMLog(@"_helpString=%@",_helpString);
  LOGObjectFnStop();
  return _helpString;
};

//-----------------------------------------------------------------------------------
-(NSString*)anchorName
{
  return _tmpAnchorName;
};

//-----------------------------------------------------------------------------------
-(BOOL)isDisabled
{
  BOOL isDisabled=NO;

  LOGObjectFnStart();

  if ([self hasBinding:@"disabled"])
    isDisabled=boolValueFor([self valueForBinding:@"disabled"]);
  else if ([self hasBinding:@"enabled"])
    {
      BOOL isEnabled=boolValueFor([self valueForBinding:@"enabled"]);
      isDisabled=(isEnabled ? NO : YES);
    };

  NSDebugMLog(@"isDisabled=%s",(isDisabled ? "YES" : "NO"));

  LOGObjectFnStop();
  
  return isDisabled;
};

//-----------------------------------------------------------------------------------
-(BOOL)shouldDisplay
{
  BOOL shouldDisplay=YES;

  LOGObjectFnStart();

  if ([self isDisabled]
      && [self hasBinding:@"displayDisabled"]
      && !boolValueFor([self valueForBinding:@"displayDisabled"]))
    shouldDisplay=NO;

  NSDebugMLog(@"shouldDisplay=%s",(shouldDisplay ? "YES" : "NO"));

  LOGObjectFnStop();
  
  return shouldDisplay;
};

@end
