// PPExpression.h   P.Herber 2011-09-23
//  Historic:   XFEXPR.H		P.Herber 2002/10/03

//#define UNARY_FIX 0

#define TOKLEN          2048              /* Max token length */

enum {
    PPCT_UNDEF = 0,
    PPCT_VAR,
    PPCT_DEL,
    PPCT_NUM,
    PPCT_STR,
    PPCT_FUNK,
    PPCT_XML,
    PPCT_ARG_MAX_LENGTH = 2048
};
typedef NSInteger PPCharacterType;

//==============================================

/* Codes returned from the evaluator */
#define E_OK           		0        /* Successful evaluation */
#define E_SYNTAX       		1        /* Syntax error */
#define E_UNBALAN      		2        /* Unbalanced parenthesis */
#define E_DIVZERO      		3        /* Attempted division by zero */
#define E_UNKNOWN      		4        /* Reference to unknown variable */
#define E_MAXVARS      		5        /* Maximum variables exceeded */
#define E_BADFUNC      		6        /* Unrecognised function */
#define E_NUMARGS      		7        /* Wrong number of arguments to funtion */
#define E_NOARG        		8        /* Missing an argument to a funtion */
#define E_EMPTY        		9        /* Empty expression */
#define E_NO_CALLB			10		/* Trying to evaluate XML without callback function*/
#define E_UNHANDL			11		/* Unhandled exception */
#define E_NT_STR			12		/* Non terminated string */
#define E_GENERIK_FUNK		13		/* Generic user function parameter error */
#define E_WATCHDOG			14		/* Generic user function parameter error */
#define E_SYNTAX1       		15        /* Syntax error */
#define E_SYNTAX2       		16        /* Syntax error */
#define E_SYNTAX3       		17        /* Syntax error */
#define E_SYNTAX4       		18        /* Syntax error */
#define E_SYNTAX5       		19        /* Syntax error */
#define E_SYNTAX6       		20        /* Syntax error */
#define E_SYNTAX7       		21        /* Syntax error */
#define E_SYNTAX8       		22        /* Syntax error */
#define E_SYNTAX9       		23       /* Syntax error */


static char* ErrMsg[] =
{
   "",
   "Syntax error",
   "Unbalanced parenthesis",
   "Division by zero",
   "Unknown variable",
   "Maximum variables exceeded",
   "Unrecognised funtion",
   "Wrong number of arguments to funtion",
   "Missing an argument",
   "Empty expression",
   "Trying to evaluate XML without callback function",
   "Unhandled exception",
   "Non terminated string",
   "Generic user function parameter error",
   "WatchDog expired",
   "Syntax error [1]",
   "Syntax error [2]",
   "Syntax error [3]",
   "Syntax error [4]",
   "Syntax error [5 - Parse]",
   "Syntax error [6 - lt/gt]",
   "Syntax error [7 - Funktionsanrop]",
   "Syntax error [8 - Okänd funktion]",
   "Syntax error [9 - Parentes eller fnutt saknas]"
};
typedef NSInteger PPExpressionErrorCode;

//==============================================
enum { EXPR_NONE=0,EXPR_DOUBLE,EXPR_BOOL,EXPR_STRING };
typedef NSInteger PPExpressionType;

@interface PPExpressionResult : NSObject {
@private
    double _mDouble;
    BOOL _mBool;
    NSMutableString* _mString;
    PPExpressionType _mType;
    PPExpressionErrorCode _mErrorCode;
}
- (id) init;
- (void) copyFrom: (PPExpressionResult*) expression;
- (void) appendString: (NSString*) s;
- (PPExpressionType) isType; 
- (NSString*) errorText;

- (void) setDouble: (double) d;
- (void) setBool: (BOOL) b;
- (void) setString: (NSString*) s;
- (double) doubleValue;
- (BOOL) boolValue;
- (NSString*) stringValue;

- (void) setErrorCode: (PPExpressionErrorCode) ec;
- (PPExpressionErrorCode) errorCode;

@end 


//==============================================
// class LXFormsExpr
//==============================================

static NSInteger WATCHDOGLIMIT = 1000;

@interface PPExpression : NSObject {
@private
    NSString* _mExpression;
    NSMutableString* _mToken;
    NSInteger _mType;
    NSInteger _mLevel;
    BOOL _mSkip[256];
    NSInteger _mWatchDog;
}

//- (id) init;
- (NSInteger) evaluate: (NSString*) e toResult: (PPExpressionResult*) result skip: (BOOL) skip;

- (BOOL) isWhite: (unichar) c;
- (BOOL) isNumeric: (unichar) c;
- (BOOL) isAlpha: (unichar) c;
- (BOOL) isAlphaEx: (unichar) c;
- (BOOL) isDelim: (unichar) c;
- (BOOL) isComp: (unichar) c;
- (BOOL) isDelOper: (unichar) c;
- (BOOL) isInteger: (unichar) c;

- (void) Level1: (PPExpressionResult*) r;
- (void) Level2: (PPExpressionResult*) r;
- (void) Level3: (PPExpressionResult*) r;
- (void) Level4: (PPExpressionResult*) r;
- (void) Level5: (PPExpressionResult*) r;
@end

/*
{
public:
	LXFormsExpr(){ mWatchDog = 0; xpathFunc=(xpathCallback)0;modifyFunc=(modifyCallback)0;fillFuncs();};
	int		Evaluate( char* e, expResultType* result, bool skip = false);
	void		SetCallbackFunc(xpathCallback x, void* u) {xpathFunc=x;usrData=u; };
	void		SetModifyCallbackFunc(modifyCallback m, void* u) {modifyFunc=m;modUsrData=u; };
	void		SetGenericCallbackFunc(genericCallback g, void* u) {genericFunc=g;genUsrData=u; };

protected:
	void		Parse();
	int		Level1( expResultType* r );
	void		Level2( expResultType* r );
	void		Level3( expResultType* r );
	void		Level4( expResultType* r );
	void		Level5( expResultType* r );
	void		strlwr( char* s );
#if UNARY_FIX	
	void	        ParseOperator();
	void	        ParseLParen();
	void	        ParseRParen();
	void	        ParseOperand();
#endif

	unsigned char*  expression;          // Pointer to the user's expression 
	unsigned char   token[TOKLEN + 1];   // Holds the current token 
	int             type;                // Type of the current token 
	char		stringParam[ARG_MAX_LENGTH];
	xpathCallback	xpathFunc;
	modifyCallback	modifyFunc;
	genericCallback genericFunc;
	void*		usrData;
	void*		modUsrData;
	void*		genUsrData;
	int		mLevel;
	bool		mSkip[256];
	int		mWatchDog;
	///----------The Functions ------------------
	vector<FUNCTION> Funcs;
	void		fillFuncs();

};

*/





