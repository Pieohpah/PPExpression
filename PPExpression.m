// PPExpression.cpp     P.Herber 2011-09-23
//  History: XFEXPR.CPP     P.Herber 2002/10/03


#import <Foundation/Foundation.h>
#import "PPExpression.h"


@implementation PPExpressionResult


- (id) init {
    [self setDouble:0.0];
    [self setBool:NO];
    _mString    = [[NSMutableString alloc] init];
    _mType      =EXPR_NONE;
    _mErrorCode =0;
    return self;
}

- (void) setDouble:(double) d {
	_mType=EXPR_DOUBLE;
	_mDouble=d;
	_mBool=((int)d!=0)?YES:NO;
	_mString = [NSString stringWithFormat:@"%f",d];
}
- (void) setBool:(BOOL) b {
	_mType=EXPR_BOOL;
	_mDouble=b?1.0:0.0;
	_mBool=b;
	_mString = [NSString stringWithFormat:@"%s",b?"true":"false"];
}
- (void) setString:(NSString*) s {
	_mType=EXPR_STRING;
	_mDouble= s.doubleValue;
	_mString = [NSString stringWithString: s];
    _mBool = s.boolValue;
	//mBool=((isdigit(s[0]) && atoi(s)!=0) || !strcmp(s,"true") || !strcmp(s,"yes") || !strcmp(s,"ja"))?true:false;
}

- (double) doubleValue {
    return _mDouble;
}
- (BOOL) boolValue {
    return _mBool;
}
- (NSString*) stringValue {
    return _mString;
}

- (void) copyFrom:(PPExpressionResult*) e {
	switch(e->_mType)
	{
	default:	
	case EXPR_STRING:		
            [self setString:e->_mString];
		break;
	case EXPR_BOOL:
            [self setBool:e->_mBool];
		break;
	case EXPR_DOUBLE:
            [self setDouble:e->_mDouble]; 
		break;
	}
}

- (void) appendString: (NSString*) s {
    [_mString appendString:s];
}

- (PPExpressionType) isType {
    return _mType;
}

- (void) setErrorCode: (PPExpressionErrorCode) ec {
    _mErrorCode = ec;
}
- (PPExpressionErrorCode) errorCode {
    return _mErrorCode;
}

- (NSString*) errorText {
    return [NSString stringWithFormat:@"%s", ErrMsg[_mErrorCode]];
}

@end
//==============================================




//==============================================
// class PPExpression

/*************************************************************************
**                                                                       **
** Parse()   Internal use only                                           **
**                                                                       **
** This function is used to grab the next token from the expression that **
** is being evaluated.                                                   **
**                                                                       **
*************************************************************************/

@implementation PPExpression




/*
static const char* localKeyword(const char* p)
{
	if(strncmp_nc(p,"or ",3) == 0)return "||";
	else if(strncmp_nc(p,"and ",4) == 0)return "&&";
	else if(strncmp_nc(p,"lt ",3) == 0)return "<";
	else if(strncmp_nc(p,"lte ",4) == 0)return "<=";
	else if(strncmp_nc(p,"gte ",4) == 0)return ">=";
	else if(strncmp_nc(p,"gt ",3) == 0)return ">";
	else if(strncmp_nc(p,"eq ",3) == 0)return "==";
	else if(strncmp_nc(p,"neq ",4) == 0)return "!=";
	else return (const char*)0;
}
*/
// #define iscomp(c)   (c == '&' || c == '|')
// #define isdeloper(c) (c == '=' || c=='<' || c=='>' || c=='!')

/*
#if UNARY_FIX

#define TOKEN_RESET(abct) \
	abct = (char*)token; \
	memset(stringParam,0,sizeof(stringParam)); \
	memset(token,0,sizeof(token)); \
	type = 0;
	if(mWatchDog++ > WATCHDOGLIMIT)ERR(E_WATCHDOG);
	
#define SKIP_SPACE	while(iswhite(*expression))expression++;

void LXFormsExpr::ParseOperator()
{
	char* t;
	TOKEN_RESET(t);

	// skippa blankspace: blanka och tab-tecken
	SKIP_SPACE;
		
	// om första tecken efter space är delimiter 
	const char* kw = (const char*)0;
	if(isdelim(*expression) || ((kw=localKeyword((const char*)expression)) != (const char*)0)){
		type = DEL;
		if(kw != (const char*)0){
			while(isalpha(*expression))expression++;
			strcpy(t,kw);
			t = &t[strlen(t)];
		}
		else {
			if(isdeloper(*expression) && *(expression+1)=='=')*t++ = *expression++;
			if(iscomp(*expression) && iscomp(*(expression+1)) && (*expression)==(*(expression+1)))*t++ = *expression++;
			*t++ = *expression++;
		}
	}
	else {
		*t++ = *expression++;
		*t = '\0';
		ERR(E_SYNTAX1);
		SKIP_SPACE;
	}
}

void LXFormsExpr::ParseLParen()
{
	char* t;
	TOKEN_RESET(t);
	
	// skippa blankspace: blanka och tab-tecken
	SKIP_SPACE;
		
	// om första tecken efter space är delimiter 
	if(*expression == '('){
		type = DEL;
		++expression;
		strcpy((char*)token,"(");
	}
	else {
		*t++ = *expression++;
		*t = '\0';
		ERR(E_SYNTAX2);
		SKIP_SPACE;
	}
}

void LXFormsExpr::ParseRParen()
{
	char* t;
	TOKEN_RESET(t);
	
	// skippa blankspace: blanka och tab-tecken
	SKIP_SPACE;
		
	// om första tecken efter space är delimiter 
	if(*expression == ')'){
		type = DEL;
		++expression;
		strcpy((char*)token,")");
	}
	else {
		*t++ = *expression++;
		*t = '\0';
		ERR(E_SYNTAX3);
		SKIP_SPACE;
	}
}


void LXFormsExpr::ParseOperand()
{
	char* t;
	t = (char*)token;
	memset(stringParam,0,sizeof(stringParam));
	memset(token,0,sizeof(token));

	type = 0;
	

	if(mWatchDog++ > WATCHDOGLIMIT)ERR(E_WATCHDOG);
	
	// skippa blankspace: blanka och tab-tecken
	while(iswhite(*expression))expression++;
	
	// Unary?
	bool unary = false;
	if(*expression == '-'){
		*t++ = *expression++;
		while(iswhite(*expression))expression++;
		unary = true;
	}
	else if(*expression == '+'){
		*t++ = *expression++;
		while(iswhite(*expression))expression++;
		unary = true;
	}
	
	// Nu kan vi ha 1) konstant  2) xml-path  3) funktion
	if(isnumer(*expression)){
		type = NUM;
		while(isnumer(*expression))*t++ = *expression++;
	}
	// om det är en sträng
	else if(*expression == '\'' || *expression == '\"'){
		type = STR;
		char del = *expression++;
		while(*expression && *expression != del)*t++ = *expression++;
		if(!*expression)ERR(E_NT_STR){}
		*expression++;
		if(unary == true){
			// tillårt inte unary operator framför strängen
			ERR(E_NT_STR){}
		}
	}
	else {
		// om det är en XML-path, fortsätt samla
		if((*expression) == '/'){
			type=STR;
			int pos=0;
			while(isalpha(*expression))*t++ = *expression++;
			// nu ska vi byta ut XML-path mot datat som 
			// vi hittar där.
			if(xpathFunc!=(xpathCallback)0){
				strcpy((char*)token,(*xpathFunc)(usrData,(char*)token));
				t = (char*)&token[strlen((char*)token)];	
			}
			else {
				token[0] = '\0';
				t = (char*)token;
			}
				
		}
		// om det är en variabel, fortsätt samla
		else if(isalpha(*expression)){
			type = VAR;
			while(isalpha(*expression))*t++ = *expression++;
		}
		// om det är ett funktionsanrop, fortsätt samla
		else if(*expression=='('){
			type=FUNK;
			int pos=0;
			memset(stringParam,0,sizeof(stringParam));
			*expression++;
			while(isalpha(*expression) || (*expression) == '.' || (*expression) == ','){
				stringParam[pos++]=*expression;
				*t++ = *expression++;	
			}
			token[0] = *expression++;
			token[1] = '\0';
		}
		else if(*expression){
			*t++ = *expression++;
			*t = 0;
			ERR(E_SYNTAX4);
		}
		*t = 0;
		while(iswhite(*expression))expression++;
	}
}

#endif
 
 
*/

- (BOOL) isWhite: (unichar) c {
    return (c == ' ' || c == '\t' || c == '\r' || c == '\n');
}
- (BOOL) isNumeric: (unichar) c {
    return  ((c >= '0' && c <= '9') || (c == '.') || (c == ','));
}
- (BOOL) isAlpha: (unichar) c {
    return ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') \
            || c == '_' || c == '[' || c == ']' || c == '/' || c == '@');
}
- (BOOL) isAlphaEx: (unichar) c {
    return ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') \
            || c == '_' || c == '[' || c == ']' || c == '/' || c == '@' || c == '=' || c == '\'');
}
- (BOOL) isDelim: (unichar) c {
    return (c == '+' || c == '-' || c == '*' || c == '/' || c == '%' \
            || c == '^' || c == '(' || c == ')' || c == ',' || c == '=' \
            || c=='<' || c=='>' || c=='!' || c=='&' || c=='|');
}
- (BOOL) isComp: (unichar) c {
    return  (c == '&' || c == '|');
}
- (BOOL) isDelOper: (unichar) c {
    return (c == '=' || c=='<' || c=='>' || c=='!');
}
- (BOOL) isInteger: (unichar) c {
    return ((c >= '0' && c <= '9'));
}

- (unichar) popFirstCharacter:(NSString*) s {
    if([s length]==0) {
        s = @"";
        return '\0';
    }
    unichar c = [s characterAtIndex:0];
    s = [s substringWithRange:NSMakeRange(1, [s length]-1)];
    return c;
}

// Kollar upp token: dels whitespace, dels delimitor, number string
- (void) Parse {

	_mType = 0;
	
	if(_mWatchDog++ > WATCHDOGLIMIT) {
        NSException *e = [NSException
                          exceptionWithName:[NSString stringWithFormat:@"%s",ErrMsg[E_WATCHDOG]]
                          reason:@""
                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",E_WATCHDOG] forKey:@"errorCode"]];
		@throw(e);
    }
	
	// skippa blankspace: blanka och tab-tecken
	//while(iswhite(*expression))expression++;
	
	// om fšrsta tecken efter space Šr delimiter 
	//(c == '+' || c == '-' || c == '*' || c == '/' || c == '%'  || c == '^' || c == '(' || c == ')' || c == ',' || c == '=' || c=='<' || c=='>' || c=='!' || c=='&' || c=='|')	
	//	!(((*expression) == '/') && (*(expression+1) == '*') && (*(expression+2) == '/'))

	const char* kw = (const char*)0;
	if(
		(
         [self isDelim:[_mExpression characterAtIndex:0]] && 
			(
             !(([_mExpression characterAtIndex:0]) == '/' && [self isAlpha:[_mExpression characterAtIndex:1]] && ![self isNumeric:[_mExpression characterAtIndex:1]]) &&
				!((([_mExpression characterAtIndex:0]) == '/') && ([_mExpression characterAtIndex:1] == '*') && ([_mExpression characterAtIndex:2] == '/'))
			)
		)) {
		_mType = PPCT_DEL;
		if(kw != (const char*)0){
            // lŠgger till kw till token men hoppar šver all alpha i expression
			while([self isAlpha:[_mExpression characterAtIndex:0]]) [self popFirstCharacter:_mExpression];
			//strcpy(t,kw);
			//t = &t[strlen(t)];
            //TODO: Gšr om sŒ token blir satt
		}
		else { // lŠgger till till token
			/*if([self isDelOper:[_mExpression characterAtIndex:0]] && *([_mExpression characterAtIndex:1])=='=')*t++ = *expression++;
			if(iscomp([_mExpression characterAtIndex:0]) && iscomp([_mExpression characterAtIndex:1])) && ([_mExpression characterAtIndex:0])==([_mExpression characterAtIndex:1]))*t++ = *expression++;
			*t++ = *expression++;*/
            //TODO: Gšr om pŒ rŠtt sŠtt
		}
	}
	// om det bšrjar pŒ en siffra
	else if([self isNumeric:[_mExpression characterAtIndex:0]]){
        // LŠgger till typ och alla siffror 
		_mType = PPCT_NUM;
		while([self isNumeric:[_mExpression characterAtIndex:0]]);//*t++ = *expression++;
	}
	// om det Šr en strŠng
	else if([_mExpression characterAtIndex:0]=='\'' ||[_mExpression characterAtIndex:0]=='\"'){
		// lŠgger till typ och strŠngfnutt och allt till nŠsta fnutt i token
        _mType = PPCT_STR;
		/*char del=*expression++;
		while(*expression && *expression != del)*t++ = *expression++;
		if(!*expression)ERR( E_NT_STR ){}
		*expression++; */
        //TODO: Gšr rŠtt
	}
	/* else {
		// om det är en XML-path, fortsŠtt samla
		if((*expression) == '/'){
			type=STR;
			int pos=0;
			for(;;){
				if(isalpha(*expression))*t++ = *expression++;
				else if((*expression) == '['){
					*t++ = *expression++;
					while(((*expression) != '\0') && ((*expression) != ']'))*t++ = *expression++;
					if((*expression) == '\0')break;
					if((*expression) == ']')*t++ = *expression++;
				}
				else if(((*expression) == '*') && ((*(expression+1)) == '/')){
					*t++ = *expression++;
					*t++ = *expression++;
				}
				else break;
			}
			*t = '\0';
//Logf(TRACE_LOG,"token[%s]",token);
			//while(isalpha(*expression))*t++ = *expression++;
			// nu ska vi byta ut XML-path mot datat som 
			// vi hittar där.
			if(xpathFunc!=(xpathCallback)0){
				strcpy((char*)token,(*xpathFunc)(usrData,(char*)token));
				t = (char*)&token[strlen((char*)token)];	
			}
			else {
				token[0] = '\0';
				t = (char*)token;
			}
				
		}
		// om det är en variabel, fortsŠtt samla
		else if(isalpha(*expression)){
			type = VAR;
			while(isalpha(*expression) || (*expression) == '.')*t++ = *expression++;
		}
		// om det är ett funktionsanrop, fortsŠtt samla
		else if(*expression=='('){
			type=FUNK;
			int pos=0;
			memset(stringParam,0,sizeof(stringParam));
			*expression++;
			while( isalpha( *expression ) || (*expression) == '.' || (*expression) == ','){
				stringParam[pos++]=*expression;
				*t++ = *expression++;	
			}
			token[0] = *expression++;
			token[1]='\0';
		}
		else if(*expression){
			*t++ = *expression++;
			*t = 0;
			ERR( E_SYNTAX5 );
		}
		*t = 0;
		while(iswhite(*expression))expression++;
	} */
}


/*************************************************************************
**                                                                       **
** Level1( TYPE* r )   Internal use only                                 **
**                                                                       **
** This function handles any variable assignment operations.             **
** It returns a value of 1 if it is a top-level assignment operation,    **
** otherwise it returns 0                                                **
**                                                                       **
*************************************************************************/

- (void) Level1: (PPExpressionResult*) r {
	PPExpressionResult* t = [[PPExpressionResult alloc] init];
	@try {
		[self Level2:r];
		while(([_mToken characterAtIndex:0] == '&') || ([_mToken characterAtIndex:0]  == '|')){
            
            if(_mWatchDog++ > WATCHDOGLIMIT) {
                NSException *e = [NSException
                                  exceptionWithName:[NSString stringWithFormat:@"%s",ErrMsg[E_WATCHDOG]]
                                  reason:@""
                                  userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",E_WATCHDOG] forKey:@"errorCode"]];
                @throw(e);
            }

			unichar o = [_mToken characterAtIndex:0];
			if((o == '|' && [r boolValue]) || (o == '&' && ([r boolValue] == NO))){
				self->_mSkip[_mLevel] = true;
			}

			[self Parse];
            
			if(_mType == PPCT_UNDEF)break;
			[self Level2:t];
			if(self->_mSkip[_mLevel] == NO){
				if(o=='&')
                    [r setBool:([r boolValue] && [t boolValue])];
				else 
                    if(o=='|')
                        [r setBool:([r boolValue] || [t boolValue])];
			}	
		}
        [t release];
	} @catch(NSException* e){
		[t release];
		@throw;
	} @finally {
		[t release];
        NSException *e = [NSException
                          exceptionWithName:[NSString stringWithFormat:@"%s",ErrMsg[E_UNHANDL]]
                          reason:@""
                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",E_UNHANDL] forKey:@"errorCode"]];
		@throw(e);
	}
}

/*************************************************************************
**                                                                       **
** Level2( TYPE* r )   Internal use only                                 **
**																		 **
** This function handles < > <= => != ==
**                                                                       **
*************************************************************************/

- (void) Level2: (PPExpressionResult*) r {
	PPExpressionResult* t = [[PPExpressionResult alloc] init];
	
	@try {
        [self Level3: r];
        unichar t_1 = [_mToken characterAtIndex:0];

	while(t_1=='<' || t_1=='>' || t_1=='=' || t_1=='!' ){ // Kolla om det är !=, ==, <= eller >=
        if(_mWatchDog++ > WATCHDOGLIMIT) {
            NSException *e = [NSException
                              exceptionWithName:[NSString stringWithFormat:@"%s",ErrMsg[E_WATCHDOG]]
                              reason:@""
                              userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",E_WATCHDOG] forKey:@"errorCode"]];
            @throw(e);
        }
		//char oper = token[0];
		if(([_mToken characterAtIndex:1] != '\0') && ([_mToken characterAtIndex:1] == '=')){
			// andra tecken är ett '='

			[self Parse];
            
			[self Level3:t];
            
			if(_mSkip[_mLevel] == false){
				if(([r isType] == EXPR_STRING) && ([t isType] == EXPR_STRING)){
                    NSComparisonResult sComp = [[r stringValue] compare:[t stringValue]]; 
					//int sComp= strcmp(r->getString(),(*t).getString());
					switch(t_1)
					{
					case '<':
						[r setBool:(sComp == NSOrderedAscending || sComp == NSOrderedSame) ? YES:NO];
						break;
					case '>':
						[r setBool:(sComp == NSOrderedDescending || sComp == NSOrderedSame) ? YES:NO];
						break;
					case '=':
						[r setBool:(sComp == NSOrderedSame) ? YES:NO];
						break;
					case '!':
						[r setBool:(sComp != NSOrderedSame) ? YES:NO];
						break;
					}
				}
				else {
					switch(t_1){
					case '<':
						//r->setBoolean(r->getDouble() <= (*t).getDouble());
                        [r setBool:( [r doubleValue] <= [t doubleValue] )];    
						break;
					case '>':
                        [r setBool:( [r doubleValue] >= [t doubleValue] )];
						break;
					case '=':
                        [r setBool:( [r doubleValue] == [t doubleValue] )];
						break;
					case '!':
                        [r setBool:( [r doubleValue] != [t doubleValue] )];
						break;
					default:
						[r setBool:NO];
					}
				}
			}
		}
		else { // vanlig < || >
			if((t_1 == '<') || (t_1 == '>')){
				//char oper = *token;

				[self Parse];

				[self Level3:t];

                NSComparisonResult sComp = [[r stringValue] compare:[t stringValue]];
				if(_mSkip[_mLevel] == false){
					switch([r isType]){
					case EXPR_DOUBLE:
					case EXPR_BOOL:
						if(t_1=='<')
                            [r setBool:([r doubleValue] < [t doubleValue])];
						if(t_1=='>')
                            [r setBool:([r doubleValue] > [t doubleValue])];
						break;
					case EXPR_STRING:
					default:
						if(t_1=='<')
                            [r setBool:((sComp = NSOrderedAscending) ? YES:NO)];
						if(t_1=='>')
                            [r setBool:((sComp = NSOrderedDescending) ? YES:NO)];
					}
				}
			}
			else {
                NSException *e = [NSException
                                  exceptionWithName:[NSString stringWithFormat:@"%s",ErrMsg[E_SYNTAX6]]
                                  reason:@""
                                  userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",E_SYNTAX6] forKey:@"errorCode"]];
                @throw(e);
			}
		}
	}
	[t release];
	} @catch(NSException* e){
		[t release];
		@throw;
	} @finally {
		[t release];
        NSException *e = [NSException
                          exceptionWithName:[NSString stringWithFormat:@"%s",ErrMsg[E_UNHANDL]]
                          reason:@""
                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",E_UNHANDL] forKey:@"errorCode"]];
		@throw(e);
	}
}

/*************************************************************************
**                                                                       **
** Level3( TYPE* r )   Internal use only                                 **
**                                                                       **
** This function handles any addition and subtraction operations.        **
**                                                                       **
*************************************************************************/

- (void) Level3: (PPExpressionResult*) r  {
	PPExpressionResult* t = [[PPExpressionResult alloc] init];
	unichar o;

	@try {
		[self Level4:r];
		while(((o = [_mToken characterAtIndex:0]) == '+') || (o == '-')){

			[self Parse];

			[self Level4:t];
            
			if(_mSkip[_mLevel] == false){
				if(o == '+'){
					switch([r isType]){
					case EXPR_DOUBLE:
						[r setDouble:([r doubleValue]+[t doubleValue])];
						break;
					case EXPR_BOOL:
                        [r setBool:([r boolValue] && [t boolValue])];
						break;
					case EXPR_STRING:
					default:
						if([r doubleValue]==0.0 && [t doubleValue]==0.0)
                            [r appendString:[t stringValue]];
						else
							[r setDouble:([r doubleValue]+[t doubleValue])];
						break;
		 			}
				}
				else if(o == '-'){
					switch([r isType]){
					case EXPR_DOUBLE:
						[r setDouble:([r doubleValue]-[t doubleValue])];
						break;
					case EXPR_BOOL: // ?? && !
						[r setBool:([r boolValue] && ![t boolValue])];
						break;
					case EXPR_STRING:
					default: // ersätter sträng?
						if([r doubleValue]==0.0 && [t doubleValue]==0.0)
							[r setString: [t stringValue]];
						else
							[r setDouble:([r doubleValue]-[t doubleValue])];
						break;
		 			}
		 		}
			}
		}
		[t release];
    } @catch(NSException* e){
        [t release];
        @throw;
    } @finally {
        [t release];
        NSException *e = [NSException
            exceptionWithName:[NSString stringWithFormat:@"%s",ErrMsg[E_UNHANDL]]
            reason:@""
            userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",E_UNHANDL] forKey:@"errorCode"]];
        @throw(e);
    }
//Logf(TRACE_LOG,"Level3 KLAR: r=%s",r->getString());

}

/*************************************************************************
**                                                                       **
** Level4( TYPE* r )   Internal use only                                 **
**                                                                       **
** This function handles any multiplication, division, or modulo.        **
**                                                                       **
*************************************************************************/

- (void) Level4: (PPExpressionResult*) r {
	PPExpressionResult* t = [[PPExpressionResult alloc] init];
	@try{
	char o;

        [self Level5: r];
	while(((o = [_mToken characterAtIndex:0]) == '*') ||(o == '/') || (o == '%')){
    
		// if(isalpha(*expression)&&!isnumer(*expression))	/// för XML-uttryck
		//	break;

		[self Parse];

        [self Level5: r];
		if(_mSkip[_mLevel] == false){
			if(o == '*'){
				switch([r isType]){
				case EXPR_DOUBLE:
					[r setDouble:([r doubleValue]*[t doubleValue])];
					break;
				case EXPR_BOOL: // ?? && 
					[r setBool:([r boolValue] && [t boolValue])];
					break;
				case EXPR_STRING:
				default: 
					if([r doubleValue]==0.0 && [t doubleValue]==0.0)
						[r appendString:([t stringValue])];
					else
						[r setDouble:([r doubleValue]*[t doubleValue])];
					break;
		 		}
			}
			else if(o == '/'){
				if( [t doubleValue] == 0 ){
                    [t release];
                    NSException *e = [NSException
                                      exceptionWithName:[NSString stringWithFormat:@"%s",ErrMsg[E_DIVZERO]]
                                      reason:@""
                                      userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",E_DIVZERO] forKey:@"errorCode"]];
                    @throw(e);
                }

				switch([r isType]){
				case EXPR_DOUBLE:
					[r setDouble:([r doubleValue]/[t doubleValue])];
					break;
				case EXPR_BOOL: // ?? || 
					[r setBool:([r boolValue] || [t boolValue])];
					break;
				case EXPR_STRING:
				default: // ersätter???
					if([r doubleValue]==0.0 && [t doubleValue]==0.0)
						[r setString:([t stringValue])];
					else
						[r setDouble:([r doubleValue]/[t doubleValue])];
					break;
		 		}
			}
			else if( o == '%' ){
				if( [t doubleValue] == 0 ) {   
                    [t release];
                    NSException *e = [NSException
                                  exceptionWithName:[NSString stringWithFormat:@"%s",ErrMsg[E_DIVZERO]]
                                  reason:@""
                                  userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",E_DIVZERO] forKey:@"errorCode"]];
                    @throw(e);
                }

				switch([r isType]){
				case EXPR_DOUBLE:
					[r setDouble:((double)fmod([r doubleValue],[t doubleValue]))];
					break;
				case EXPR_BOOL: // ?? || 
					[r setBool:([r boolValue] || [t boolValue])];
					break;
				case EXPR_STRING:
				default: // ersätter???
					if([r doubleValue]==0.0 && [t doubleValue]==0.0)
						[r setString:[t stringValue]];
					else
						[r setDouble:((double)fmod([r doubleValue],[t doubleValue]))];
					break;
		 		}
			}
		}
	}
    [t release];
    } @catch(NSException* e){
        [t release];
        @throw;
    } @finally {
        [t release];
        NSException *e = [NSException
                          exceptionWithName:[NSString stringWithFormat:@"%s",ErrMsg[E_UNHANDL]]
                          reason:@""
                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",E_UNHANDL] forKey:@"errorCode"]];
        @throw(e);
    }
}

/*************************************************************************
**                                                                       **
** Level5( TYPE* r )   Internal use only                                 **
**                                                                       **
** This function handles any literal numbers, variables, or functions.   **
**                                                                       **
*************************************************************************/

- (void) Level5: (PPExpressionResult*) r {
//	int  i;
//	int  n;
//	const int	aCount = 4;
//	char	genericFuncName[256];
	//expResultType* a[aCount]; //TODO: Hantera detta annorlunda
//	bool modify = false;
//	bool generic = false;

	@try {
		//for(i=0;i < aCount;++i)a[i] = NULL; //TODO: Hantera detta annorlunda

		if( [_mToken characterAtIndex:0] == '(' ){
			++_mLevel;
			_mSkip[_mLevel] = _mSkip[_mLevel-1];

			[self Parse];

			if([_mToken characterAtIndex:0] == ')') {
                NSException *e = [NSException
                                  exceptionWithName:[NSString stringWithFormat:@"%s",ErrMsg[E_NOARG]]
                                  reason:@""
                                  userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",E_NOARG] forKey:@"errorCode"]];
                @throw(e);
            }

			[self Level1:r];
            
			if([_mToken characterAtIndex:0] != ')') {
                NSException *e = [NSException
                                  exceptionWithName:[NSString stringWithFormat:@"%s",ErrMsg[E_UNBALAN]]
                                  reason:@""
                                  userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",E_UNBALAN] forKey:@"errorCode"]];
                @throw(e);
            }

			--_mLevel;

			[self Parse];
		}
		else {
            
            
            
			if(([_mToken compare:@"true" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [_mToken length])] ==  NSOrderedSame) && ([_mExpression characterAtIndex:0] != 0) && ([_mExpression characterAtIndex:0] != '(')){
				if(_mSkip[_mLevel] == true){}
				else [r setBool:YES];
                [self Parse];
			}
			else if(([_mToken compare:@"false" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [_mToken length])] ==  NSOrderedSame) && ([_mExpression characterAtIndex:0] != 0) && ([_mExpression characterAtIndex:0] != '(')){
				if(_mSkip[_mLevel] == true){}
				else [r setBool:NO];
                [self Parse];
			}
			else if([_mToken compare:@"null" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [_mToken length])] ==  NSOrderedSame){
				if(_mSkip[_mLevel] == YES){}
				else [r setDouble:0.0];
                [self Parse];
			}
			else if(_mType == PPCT_NUM ){
				if(_mSkip[_mLevel] == YES){}
				else {
					int i;
					for(i=0;[_mToken characterAtIndex:i];++i){
						if([_mToken characterAtIndex:i] == ',')
                            [_mToken replaceCharactersInRange:NSMakeRange(i,1) withString:@"."];
					}
					[r setDouble:[_mToken doubleValue]];
				}
                [self Parse];
			}
			else if(_mType == PPCT_STR){
				if(_mSkip[_mLevel] == YES){}
				else [r setString:_mToken];
                [self Parse];
			}
			else if(_mType == PPCT_VAR ){
				bool foundFunction = false;
				// function
				if([_mExpression characterAtIndex:0] == '('){
					//char* t;
					//Logf(TRACE_LOG,"%s, Funcs.size:%d, ",token,Funcs.size());
					if([_mToken compare:@"true" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [_mToken length])] !=  NSOrderedSame){
						if(_mSkip[_mLevel] == YES){}
						else [r setBool:YES];
                        [self Parse];				
						foundFunction=YES;
					}
					else if([_mToken compare:@"false" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [_mToken length])] !=  NSOrderedSame){
						if(_mSkip[_mLevel] == true){}
						else [r setBool:NO];
                        [self Parse];
                        [self Parse];
                        [self Parse];					
						foundFunction=YES;
					}
					/*else {
					    for( i=0; i<Funcs.size() && !foundFunction; i++ ){
						//Logf(TRACE_LOG,"%s == %s",token,Funcs[i].name);
						if(!strcmp((const char*)token,"modify")) modify=true;
						if((i==(Funcs.size()-1)) && (strcmp_nc((const char*)token, Funcs[i].name)!=0)){
							sprintf(genericFuncName,"%s",token);
							if(genericFunc!=(genericCallback)0)generic=true;
							else ERR( E_NO_CALLB );
						}
						if((!strcmp_nc((const char*)token, Funcs[i].name)) || modify || generic){
							n = 0;
							do {
								*expression++; // vi hoppar förbi första parentesen (efter funk-namnet)
								memset(token,0,sizeof(token));
								t=(char*)token;
								int stackP = 0;
								for(;;){
									if(expression[0] == '\0')break;	// slut på indatasträng
									else if((expression[0] == '\\') && (expression[1] != '\0')){
										*expression++;
										*t++ = *expression++;
									}
									else if(expression[0] == ','){
										if(stackP == 0)break;	// omatchad slutparentes stoppar
										else {
											stackP--;
											*t++ = *expression++;
										}
									}
									else if(expression[0] == ')'){
										if(stackP == 0)break;	// omatchad slutparentes stoppar
										else {
											stackP--;
											*t++ = *expression++;
										}
									}
									else if(expression[0] == '('){
										stackP++;
										*t++ = *expression++;
									}
									else {
										*t++ = *expression++;
									}
								}
								if(!*expression) ERR( E_SYNTAX7 );
								int y4;
								bool hasExpr = false;
								for(y4=0;token[y4];++y4){
									if(token[y4] > ' '){
										hasExpr = true;
										break;
									}
								}
								if((hasExpr == false) && (*expression == ')'))break;
								//------------------------------------
								// utvärdera token som nytt uttryck
								a[n] = new expResultType();
								LXFormsExpr FETmp;
								FETmp.SetCallbackFunc(xpathFunc,usrData);
								FETmp.SetModifyCallbackFunc(modifyFunc,modUsrData);
								FETmp.SetGenericCallbackFunc(genericFunc,genUsrData);
								int rv = FETmp.Evaluate((char*)token, a[n], mSkip[mLevel]);
								if(rv != E_OK){
									ERR(rv);
								}
								//------------------------------------
								n++;
								
								if(mWatchDog++ > WATCHDOGLIMIT)ERR(E_WATCHDOG);

							}while((n < aCount) && *expression && (*expression == ','));


							// om funken behöver XMLdata
							//if(g_xpathFunc==0 && g_xpathFunc!=xpathFunc)g_xpathFunc=xpathFunc;
							//if(g_usrData==0 && g_usrData!=usrData)g_usrData=usrData;

							if(!modify && !generic){
								if(mSkip[mLevel] == true){}
								else {
						 			expResultType* res = Funcs[i].func(a,n);
									if(res->getErrorCode() != E_OK){
										ERR(res->getErrorCode());
									}
									else r->copyFrom(res);
									
									delete res;
								}
							}
							else if(generic){
								if(mSkip[mLevel] == true){}
								else {
									if(genericFunc!=(genericCallback)0){
										void* vp = (*genericFunc)(genUsrData,genericFuncName,(expResultType**)&a, n);
										if(vp != (void*)0){
											expResultType* res = (expResultType*) vp;
											if(res->getErrorCode() != E_OK){
												ERR(res->getErrorCode());
											}
											else r->copyFrom(res);
											delete res;
										}
										else {
											ERR( E_GENERIK_FUNK );
										}
									}
									else ERR( E_NO_CALLB );
								}
							}
							else {
								if(mSkip[mLevel] == true){}
								else {
									if(n<2) ERR( E_SYNTAX8 );
									// Anropa hårt med paramerar från a[]  
									memset(stringParam,0,sizeof(stringParam));
									if(modifyFunc!=(modifyCallback)0){
										char* modified = (char*) (*modifyFunc)(modUsrData,a[0]->getString(),a[1]->getString());
										strcpy(stringParam,modified);
										LStrFree(modified);
									}
									else ERR( E_NO_CALLB );
									r->setString(stringParam);
								}
							}
							for(int y9=0;y9 < n;++y9)delete a[y9];
							*expression++;
                            [self Parse];
							foundFunction=true;

							break;
						}
				    	    }  // slut på for-loopen
					    if(!foundFunction)ERR( E_BADFUNC );
					}*/
				}
				else  {
                    NSException *e = [NSException
                                      exceptionWithName:[NSString stringWithFormat:@"%s",ErrMsg[E_SYNTAX9]]
                                      reason:@""
                                      userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",E_SYNTAX9] forKey:@"errorCode"]];
                    @throw(e);
				}
			}
		}

    } @catch(NSException* e){
			//for(int y9=0;y9 < n;++y9)delete a[y9]; // Hitta pŒ nŒgot annat
			@throw;

    } @finally {

        NSException *e = [NSException
                          exceptionWithName:[NSString stringWithFormat:@"%s",ErrMsg[E_UNHANDL]]
                          reason:@""
                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",E_UNHANDL] forKey:@"errorCode"]];
        @throw(e);
    }

}

/*************************************************************************
**                                                                       **
** Evaluate( char* e, TYPE* result, int* a )                             **
**                                                                       **
** This function is called to evaluate the expression E and return the   **
** answer in RESULT.  If the expression was a top-level assignment, a    **
** value of 1 will be returned in A, otherwise it will contain 0.        **
**                                                                       **
** Returns E_OK if the expression is valid, or an error code.            **
**                                                                       **
*************************************************************************/

- (NSInteger) evaluate: (NSString*) e toResult: (PPExpressionResult*) result skip: (BOOL) skip {

	@try {
		NSInteger ret = 0;
        
        e = [e stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([e length] == 0) {
            return 0;
        }
        
        if ( [e caseInsensitiveCompare:@"true"]==NSOrderedSame ) {
            [result setBool:YES];
            return 0;
        }
        if ( [e caseInsensitiveCompare:@"false"]==NSOrderedSame ) {
            [result setBool:NO];
            return 0;
        }
		
		_mLevel = 0;

        _mExpression = e;

		[self Parse];

        [self Level1:result];
        
        ret = [result errorCode];
        
		if(ret!=0) {
           [result setErrorCode: ret];
        }        
		return ret;
	}
	@catch(NSException* err){
        NSInteger ec = [[[err userInfo] valueForKey:@"errorCode"] intValue];
		[result setErrorCode: ec];
		return ec;
	}
	@finally{
		[result setErrorCode: E_UNHANDL];
		return E_UNHANDL;
	}
}

@end




