#ifndef INC_GSWPageDefLexer_h_
#define INC_GSWPageDefLexer_h_

/*
 * ANTLR-generated file resulting from grammar /tmp/PageDef.g
 * 
 * Terence Parr, MageLang Institute
 * with John Lilley, Empathy Software
 * and Manuel Guesdon, Software Builders
 * ANTLR Version 2.5.0; 1996,1997,1998,1999
 */


#include "GSWeb.h"


#include "gsantlr/ANTLRCommon.h"
#include "gsantlr/ANTLRCommonToken.h"
#include "gsantlr/ANTLRCharBuffer.h"
#include "gsantlr/ANTLRBitSet.h"
#include "gsantlr/ANTLRCharScanner.h"
@interface GSWPageDefLexer : ANTLRCharScanner
 {
 };
	-(void) initLiterals;
	-(BOOL)getCaseSensitiveLiterals;
	-(id)initWithTextStream:(ANTLRDefTextInputStream)_in;
	-(id)initWithCharBuffer:(ANTLRCharBuffer*)_buffer;
	-(ANTLRDefToken) nextToken;
	/*public: */-(void) mSL_COMMENTWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mML_COMMENTWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mINCLUDEWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mIDENTWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mLETTERWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mDIGITWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mPIDENTWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mPOINTWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mSTRINGWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mIDENTREFWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mPIDENTREFWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mINTWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mYESWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mNOWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mLCURLYWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mRCURLYWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mSEMIWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mCIRCWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mTILDEWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mCOLUMNWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mASSIGNWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mQUESTIONMARKWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mEXCLAMATIONMARKWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mWSWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mESCWithCreateToken:(BOOL)_createToken ;
	/*public: */-(void) mHEXNUMWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mHEXINTWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mHEXDIGITWithCreateToken:(BOOL)_createToken ;
	/*protected: */-(void) mLCLETTERWithCreateToken:(BOOL)_createToken ;
@end



GSWEB_EXPORT CONST unsigned long GSWPageDefLexer___tokenSet_0_data_[];
GSWEB_EXPORT ANTLRBitSet* GSWPageDefLexer___tokenSet_0;
GSWEB_EXPORT CONST unsigned long GSWPageDefLexer___tokenSet_1_data_[];
GSWEB_EXPORT ANTLRBitSet* GSWPageDefLexer___tokenSet_1;
GSWEB_EXPORT CONST unsigned long GSWPageDefLexer___tokenSet_2_data_[];
GSWEB_EXPORT ANTLRBitSet* GSWPageDefLexer___tokenSet_2;
GSWEB_EXPORT CONST unsigned long GSWPageDefLexer___tokenSet_3_data_[];
GSWEB_EXPORT ANTLRBitSet* GSWPageDefLexer___tokenSet_3;
GSWEB_EXPORT CONST unsigned long GSWPageDefLexer___tokenSet_4_data_[];
GSWEB_EXPORT ANTLRBitSet* GSWPageDefLexer___tokenSet_4;
GSWEB_EXPORT CONST unsigned long GSWPageDefLexer___tokenSet_5_data_[];
GSWEB_EXPORT ANTLRBitSet* GSWPageDefLexer___tokenSet_5;
GSWEB_EXPORT CONST unsigned long GSWPageDefLexer___tokenSet_6_data_[];
GSWEB_EXPORT ANTLRBitSet* GSWPageDefLexer___tokenSet_6;
GSWEB_EXPORT CONST unsigned long GSWPageDefLexer___tokenSet_7_data_[];
GSWEB_EXPORT ANTLRBitSet* GSWPageDefLexer___tokenSet_7;
GSWEB_EXPORT CONST unsigned long GSWPageDefLexer___tokenSet_8_data_[];
GSWEB_EXPORT ANTLRBitSet* GSWPageDefLexer___tokenSet_8;

#endif /*INC_GSWPageDefLexer_h_*/
