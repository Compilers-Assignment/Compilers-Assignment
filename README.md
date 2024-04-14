# Assignment-3

Things not implemented yet:

- Keywords also not case sensitive in PASCAL for some reason, need to account for capitalized and mixed spellings of the keywords
- Not sure if ; counts as a punctuator
- Not sure if variable errors need to be checked when variables being used in the program body -- if a variable is used without declaration, do we still output that as an 'IDENTIFIER' token or do we take lite?
- Will the identifier inside Write() and read() be tokenized?
- Is the program name an Identifier?
- Brief fix required: Commas should be tokenized along with the variable before them. Separate tokenization as a punctuator may result in errors if multiple unnecessary commas present.
- Need separate class for arithmetic expressions, currently only direct numbers or vars at RHS of any assignment op
- Can semicolons be present after spaces or \n's?


