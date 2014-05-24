" NumUtils.vim - calculator with regex support
"
" Copyright: (c) 2013 by Bimba Laszlo
"            The VIM LICENSE applies to NumUtils.vim and NumUtils.txt
"            (see copyright) except use 'NumUtils' instead of 'Vim'
"            NO WARRANTY, EXPRESS OR IMPLIED.  USE AT-YOUR-OWN-RISK.
"
" Tip: if you don't know folding, then press zR
"
" ===================== BimbaLaszlo(.co.nr|gmail.com) ========== 2013.06.25 ==

"                                 VARIABLES                               {{{1
" ============================================================================

"                                   GLOBAL
" ____________________________________________________________________________

" Default values, see help for the details.

if exists( 'g:loaded_NumUtils' )
    finish
endif
let g:loaded_NumUtils = 1

if ! exists( 'g:NumUtils_format' )
    let g:NumUtils_format = ''
endif

if ! exists( 'g:NumUtils_formatPoint' )
    let g:NumUtils_formatPoint = 1
endif

if ! exists( 'g:NumUtils_formatZeros' )
    let g:NumUtils_formatZeros = 0
endif

if ! exists( 'g:NumUtils_keep' )
    let g:NumUtils_keep = 1
endif

"                                   SCRIPT
" ____________________________________________________________________________

" Expressions of NUM before and after g:NumUtils_formatPoint

let s:num_regex = [ '[+\-]\?\d\+', '\?\d*' ]

"                              SCRIPT FUNCTIONS                           {{{1
" ============================================================================

"                                   ERROR                                 {{{2
" ____________________________________________________________________________
"
" Print an error message.

function s:Error( msg )

    echohl ErrorMsg | echomsg 'NumUtils:' a:msg | echohl None

endfunction

"                                 EXPRCOUNT                               {{{2
" ____________________________________________________________________________
"
" Count all matches of {expr} in {pattern} and return with the issue.
"
" Note: function alias for s/pattern/expr/n would be better.

function s:ExprCount( pattern, expr )

    return len( split( a:pattern, a:expr, 1 ) ) - 1

endfunction

"                                 WRONGVALUE                              {{{2
" ____________________________________________________________________________
"
" Check the type of {value} and return -1 if it is not a Number or Float,
" otherwise return 0.

function s:WrongValue( value )

    let num = type( a:value )
    if (num != type( 123 )) && (num != type( 123.123 ))

        call s:Error( 'type of {value} have to be Number or Float: ' . string( a:value ) )
        return -1

    endif

    return 0

endfunction

"                                   MATH                                  {{{2
" ____________________________________________________________________________
"
" If the {operand} is a Number or Float, then returns the issue of the
" expression:
"
"   {value} {operator} {operand}
"
" If the {operand} is a List of Numbers and {operator} is '+' for example,
" then returns with the issue of the expression:
"
"   {value} * g:NumUtils_keep + {matches}[ op1 ] + {matches}[ op2 ] + ...
"
" ARGUMENTS:
"
"   operator : arithmetic operator for two operand
"   operand  : (Number or Float) or List of index Numbers of {matches}
"   value    : !NUM! found by NumUtils
"   matches  : Dictionary of matches:
"                'label' : the label String of matches that used by NumUtils
"                'sub'   : List of submatches like matchlist() does

function s:Math( operator, operand, value, matches )

    if type( a:operand ) == type( [ 'list' ] )

        let new_value = a:value * g:NumUtils_keep

        for num in a:operand

            if type( num ) != type( 123 )
                call s:Error( 'type of {index} have to be Num: ' . string( num ) )
                return 'error'
            endif

            if (num >= len( a:matches.sub )) || (num < 0)
                call s:Error( 'index is out of range: ' . string( num ) )
                return 'error'
            endif

            let submatch = str2float( (g:NumUtils_formatPoint) ? a:matches.sub[ num ] : tr( a:matches.sub[ num ], ',', '.' ) )

            exe 'let new_value = new_value' a:operator 'submatch'

        endfor

    else

        if s:WrongValue( a:operand )
            return 'error'
        endif

        exe 'let new_value = a:value' a:operator 'a:operand'

    endif

    return new_value

endfunction

"                               MATH FUNCTIONS                            {{{2
" ____________________________________________________________________________

function s:Add( operand, value, matches )
    return s:Math( '+', a:operand, a:value, a:matches )
endfunction

function s:Sub( operand, value, matches )
    return s:Math( '-', a:operand, a:value, a:matches )
endfunction

function s:Mul( operand, value, matches )
    return s:Math( '*', a:operand, a:value, a:matches )
endfunction

function s:Div( operand, value, matches )
    return s:Math( '/', a:operand, a:value, a:matches )
endfunction

"                                NUMUTILSCALL                             {{{2
" ____________________________________________________________________________
"
" Calls NumUtils on a range and handles the errors.
"
" ARGUMENTS:
"
"   first_line, last_line : range of the command
"   method                : function to call with the matches of labels
"   metharg               : argument for the method
"   ...                   : regular expressions aka labels

function s:NumUtilsCall( first_line, last_line, method, metharg, ...  )

    " If the label is not given, then find all numbers in the file separated
    " by non-digits.

    let labels = NumUtilsInit( (a:0 == 0) ? [ '^\|\D' ] : a:000 )
    if type( labels ) == type( 'string' )

        call s:Error( labels )
        return

    endif

    for linenr in range( a:first_line, a:last_line )

        let line     = getline( linenr )
        let new_line = NumUtils( line, a:method, a:metharg, labels )

        " Check for errors.

        if type( new_line ) != type( { 'dict' : 'ionary' } )
            return
        endif

        if new_line.str != line
            call setline( linenr, new_line.str )
        endif

        unlet new_line

    endfor

endfunction

"                              GLOBAL FUNCTIONS                           {{{1
" ============================================================================

"                               NUMUTILSFORMAT                            {{{2
" ____________________________________________________________________________
"
" Return with the formated {value} (Number or Float) according to the required
" format.
"
" Does not checking the type of the {value}, because NumUtils do that before
" calling this function.

function NumUtilsFormat( value )

    let value_str = printf( '%' . g:NumUtils_format . 'f', a:value )

    if (g:NumUtils_formatZeros == 0) || (g:NumUtils_formatZeros == 1)
        let value_str = substitute( value_str, '0*$', '', '' )
        let value_str = substitute( value_str, '\.$', (g:NumUtils_formatZeros) ? '.0' : '', '' )
    endif

    if ! g:NumUtils_formatPoint
        let value_str = tr( value_str, '.', ',' )
    endif

    return value_str

endfunction

"                                NUMUTILSINIT                             {{{2
" ____________________________________________________________________________
"
" Initalizing the List of regular expression Strings to use with NumUtils.
"
" RETURN:
"
"   If there is no error, it will return with the List of initialized labels,
"   otherwise the String of the error will be returned.

function NumUtilsInit( labels )

    let labels = []
    let num_regex = s:num_regex[ 0 ] . (g:NumUtils_formatPoint ? '\.' : ',') . s:num_regex[ 1 ]

    for label in a:labels

        if type( label ) != type( 'string' )
            return "type of {labels} have to be string (surround each with '')"
        endif

        let num = s:ExprCount( label, '\\(' ) - s:ExprCount( label, '\\)' )

        if num != 0
            return (num > 0) ? 'E54: unmatched \(' : 'E55: unmatched \)'
        endif

        let label_regex = substitute( label, ':NUM:', escape( num_regex, '\' ), 'g' )

        if match( label_regex, '!NUM!' ) >= 0

            if s:ExprCount( label_regex, '!NUM!' ) > 1
                return '"!NUM!" can be present only once in the expression'
            endif

            " Get the parts of label before and after !NUM!.

            let lst = split( label_regex, '!NUM!', 1 )

            let num = s:ExprCount( lst[ 0 ], '\\(' ) - s:ExprCount( lst[ 0 ], '\\)' )
            if num != 0
                return 'do not surround "!NUM!" with parenthesis'
            endif

        else

            let lst = [ label_regex, '' ]

        endif

        " Save the index of !NUM! to get the right submatch from matchlist().

        let num = s:ExprCount( lst[ 0 ], '\\(' ) + 2
        let str = '\(' . lst[ 0 ] . '\)\(' . num_regex . '\)\(' . lst[ 1 ] . '\)'

        let labels += [ { 'type' : 'NumUtilsLabel', 'name' : label, 'submatch' : num, 'regex' : str } ]

    endfor

    return labels

endfunction

"                                  NUMUTILS                               {{{2
" ____________________________________________________________________________
"
" Finding !NUM!, giving it to the {method} in the form:
"
"   {method}( {metharg}, !NUM!, { 'label': actual label, 'sub': submatches } )
"
" Method have to return Number or Float, which will sub to !NUM!.
"
" ARGUMENTS:
"
"   str     : the String to manipulate
"   method  : function name (String) to call with the found value
"   metharg : argument for the method (can be any type)
"   labels  : List of regular expressions
"
" RETURN:
"
"   If there is no error, then it returns with a Dictionary:
"
"       'str'   : the modified {str}
"       'value' : Dictionary of { labels : modified !NUM!s in the labels }
"
"   Otherwise returns with the String of the error.

function NumUtils( str, method, metharg, labels  )

    if type( a:str ) != type( 'string' )
        return 'type of {str} have to be String'
    endif

    let data = { 'str' : a:str, 'value' : {} }

    for label in a:labels

        if (type( label ) != type( { 'dict' : 'ionary' } )) || (get( label, 'type', 'wrong' ) != 'NumUtilsLabel')
            return '{labels} have to be initalized by NumUtilsInit'
        endif

        " Going to find and replace (if necessery) all matches of label.

        let next_match = match( data.str, label.regex )
        while next_match >= 0

            let matches = matchlist( data.str, label.regex, next_match )

            " Remove the submatches from the matches used by only this
            " function.

            let after_value  = remove( matches, label.submatch + 1 )
            let found_value  = str2float( tr( remove( matches, label.submatch ), ',', '.' ) )
            let before_value = remove( matches, 1 )

            let new_value = call( a:method, [ a:metharg, found_value, { 'label' : label.name, 'sub' : matches } ] )

            let num = type( new_value )
            if (num != type( 123 )) && (num != type( 123.123 ))

                return '{method} does not returned Number or Float'

            endif

            " Save the value to the give back on return.

            call extend( data.value, { label.name : new_value } )

            if new_value != found_value

                " Replace the !NUM! with the value gave from {method}. If we
                " would use substitute(), for example with the label
                " '[0-9]\+ !NUM!' on the string '123 456', and the new_value
                " is 789, then the string became '789 456' because it does not
                " know which match we want to replace.

                let new_str  = strpart( data.str, 0, next_match )
                let new_str .= before_value
                let new_str .= NumUtilsFormat( new_value )
                let new_str .= after_value
                let new_str .= strpart( data.str, next_match + len( matches[ 0 ] ) )

                " The index of the match end can be different, so we have to
                " recalculate it.

                let next_match += len( new_str ) - len( data.str )
                let modified    = 1

                let data.str    = new_str

            endif

            let next_match = match( data.str, label.regex, next_match + len( matches[ 0 ] ) )

            unlet new_value

        endwhile
    endfor

    return data

endfunction

"                                  COMMANDS                               {{{1
" ============================================================================

command  -range -nargs=*  NumUtilsCall  call <SID>NumUtilsCall( <line1>, <line2>,          <args> )
command  -range -nargs=*  NumUtilsAdd   call <SID>NumUtilsCall( <line1>, <line2>, 's:Add', <args> )
command  -range -nargs=*  NumUtilsSub   call <SID>NumUtilsCall( <line1>, <line2>, 's:Sub', <args> )
command  -range -nargs=*  NumUtilsMul   call <SID>NumUtilsCall( <line1>, <line2>, 's:Mul', <args> )
command  -range -nargs=*  NumUtilsDiv   call <SID>NumUtilsCall( <line1>, <line2>, 's:Div', <args> )
