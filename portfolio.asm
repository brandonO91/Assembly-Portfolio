TITLE Program Template     (template.asm)

; Author: Brandon Alan Oyama
; Last Modified:	12/08/2020
; OSU email address: OYAMAB@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:    6             Due Date:	12/06/2020
; Description: Program will give prompts to introduce the program and what the rules are to complete the program.  Using macros
;				to read and write string values, it will then ask the user for 10 signed numbers
;				and will validate.  If an incorrect input was give it will ask the user for a new input and alert them it was incorrect previously.
;				It will convert the inputs from strings to number arrays using the ReadVal Procedure.  Then an internal procedure will calculate the sum
;				and average of the number array.  Then WriteVal will translate the number arrays (10 number array and arrays for sum and average), giving a prompt
;				to user what is being displayed, to their ascii character representations to be displayed.

INCLUDE Irvine32.inc
;------------------------------------------------------------------------------------------------------
;	name: mGetSring (String in project is Sring lulz)
;
;	Dispalys prompt (using mDisplayString) for instuctions to user and into a memory
;	and takes in total length of string (bytes)
;
;	Preconditions: there must be a prompt to give directions to user,
;					and input address to store bytes for given input from user,
;					and an address to store the length of string for use inintereating through string
;
;	Receives:	string address for prompt
;				inValue = address of an empty string for input
;
;	Returns:	inValue = address that has been updated with inputted elements
;				inLength = number of bytes that string holds (elements)
;---------------------------------------------------------------------------------------------------------

mGetSring	MACRO	prompt, input, length ; (this is how he wanted us to spell it right???)			; takes in a string address and number of bytes for ecx
	push	ECX
	push	EDX
	PUSH	EAX
	mov		EDX,	prompt			; take an address from stack
	mDisplayString	EDX
	mov		EDX,	input			;address of empty string to use to process values
	mov		ECX,	MAXSIZE				; size of string to take in
	call	ReadString
	mov		length,	EAX				; will need to change this value
	call	CrLf
	POP		EAX
	pop		EDX
	pop		ECX
ENDM

;------------------------------------------------------------------------------------------------------
;	name: mDisplayString
;
;	Displays a string with the address passed into the macro
;
;	Preconditions: there must an address passed into the macro for it to display the string
;
;	Receives:	string address for prompt
;
;	Returns:	None
;---------------------------------------------------------------------------------------------------------
mDisplayString	MACRO	prompt
	push	EDX
	mov		EDX,	prompt
	call	writeString
	pop		EDX
ENDM


; constants
MAXSIZE = 12

.data

intro		byte		"Project Number 6:  String Primitives and Macros - Brandon Alan Oyama",0
rules1		byte		"Enter 10 signed (+-) whole numbers. This will need to fit in a 32 bit register",0 
rules2		byte		"(-2 ^ 31 to 2 ^ 31 - 1)",0
rules3		byte		"Once entered in correctly, displayed to you will be the list of numbers entered, sum, and their average.",0

prompt1		BYTE		"Enter a signed number...correctly : ",0
inValue		byte		MAXSIZE DUP(?)
inLength	DWORD		?

invalid		BYTE		"Invalid input..Try again!",0

validNum	SDWORD		40	DUP(?)
totalNum	SDWORD		40	DUP(?)
numArray	SDWORD		40	DUP(?)
tenNum		DWORD		10
oneNum		DWORD		1

prompt2		BYTE		"To the gates of Assembly and back, these are the numbers you inputted: ",0
outValue	byte		MAXSIZE DUP(?)				; string array to output to the user
outChara	DWORD		0
finalOut	BYTE		MAXSIZE	DUP(?)

theSum		BYTE		"The sum of all 'characters' is: ",0
theAve		BYTE		"The average of all these 'CHARACTERS' is:",0


currentNum	DWORD		?
sum			SDWORD		0
average		SDWORD		0
space		BYTE		32,32,32,32,0

example		BYTE		45, 48, 49, 50, 51,0

goodbyezz	byte		"Peace out Assembly.....!",0

.code
main PROC

	push	offset	rules3				; 20
	push	offset	rules2				; 16
	push	offset	rules1				; 12
	push	offset	intro			; 8
	call	introduction

	push	offset	totalNum				; 36
	push	sum				; 32
	push	offset	numArray				; 28
	push	inLength				; 24
	push	offset	invalid				; 20
	push	offset	validNum				; 16
	push	offset	inValue				; 12
	push	offset	prompt1				; 8
	call	ReadVal

	push	offset	numArray				; 16
	push	offset	average				; 12
	push	offset	sum				;8
	call	SumAverage

	push	tenNum				; 32
	push	offset	space				; 28
	push	offset	finalOut				; 24
	push	offset	outChara				;20
	push	offset	outValue				;16
	push	offset	numArray				;12
	push	offset	prompt2				; 8
	call	WriteVal

	push	oneNum
	push	offset	space
	push	offset	finalOut
	push	offset	outChara
	push	offset	outValue
	push	offset	sum
	push	offset	theSum
	call	WriteVal

	push	oneNum
	push	offset	space
	push	offset	finalOut
	push	offset	outChara
	push	offset	outValue
	push	offset	average
	push	offset	theAve
	call	WriteVal

	push	offset	goodbyezz				;8
	call	farewell


;mDisplayString	intro

; (insert executable instructions here)

	Invoke ExitProcess,0	; exit to operating system
main ENDP

;-----------------------------------------------------------------------------------------
; Name - introduction
;
; Introduces the program to the user using passed in string address and uses maco mDisplayString
; to dissplay to the user
;
; Preconditions - Strings must be defined and passed in and working macro to display the strings
; 
; Postconditions - 
;		changes register EDX
;		changes register EBP
;				
;
; Receives -
;		rules1 - address of string
;		rules2 - address of string
;		rules3 - address of string
;		intro - address of string
;		instruc- address of string
;
; Returns - None
;--------------------------------------------------------------------------------

introduction PROC
	PUSH	EBP
	mov		EBP,	ESP
	PUSHAD
	; Print out the introduction and instruction prompts
	mov		EDX,	[EBP + 8]
	mDisplayString	EDX
	call	CrLf
	mov		EDX,	[EBP + 12]
	mDisplayString	EDX
	call	CrLf
	mov		EDX,	[EBP + 16]
	mDisplayString	EDX
	call	CrLf
	mov		EDX,	[EBP + 20]
	mDisplayString	EDX
	call	CrLf

	POPAD
	POP		EBP
	RET	16
introduction ENDP

;-----------------------------------------------------------------------------------------
; Name - ReadVal
;
; Description - Will ask user for 10 inputs using macro mDisplayString to display prompt, then once 10 inputs have been stored, using macro
;				mGetString, in string the program the program using primitives will store the bits into an array converting into DWORDS.  
;				Three sections for inputs with -, +, and no sign.
;
; Preconditions - must be a defined string for input, defined array to hold converted and validated inputs, and working macro mDisplayString and
;				  mGetString
; 
; Postconditions - changes register EBX, EAX, EBP, ECX, EDI, ESI, 
;
; Receives -
;		promt1 - array address
;		sum - address of variable
;		totalNum - 
;		validNum - address of array to hold converted characters/numbers
;		inLength - address of array to hold bytes on number digits entered
;		invalid - address of string to inform user invalid input
;		inValue - address of string holding the character inputted by user
;		
; Returns -
;			numArray - an array that has been updated with converted chacters to integers
;------------------------------------------------------------------

ReadVal		PROC
	push	EBP
	mov		EBP,	ESP
	pushad
;	mov		EDI,	[EBP + 24]
	mov		ECX,	10
	; sets to edi the correct number string where converted characters will be stored (10)
	mov		EDI,	[EBP + 28]

	;outer loop for retreiving each character/ number
_getTen:
	push	ECX
	push	EDI

	; will read off prompt for user to enter in a number, take in characters, and store how many digits were entered into ECX to count
_getValue:
	mGetSring	[EBP + 8],	[EBP + 12], [EBP + 24]
	;CLD
	mov		ESI,	[EBP + 12]
	mov		EDI,	[EBP + 16]
	mov		ECX,	[EBP + 24]

	; clear direction flag to move forward through the byte array
	CLD
_checkVal:
	; loads the byte in inputted array, and extends its sign to all other bits in the full register
	LODSB
	movzx	EAX,	al
 	cmp		EAX,	45
	je		_negNum
	cmp		EAX,	43
	je		_posNum
	cmp		EAX,	48
	jb		_notNum
	cmp		EAX,	57
	ja		_notNum
	mov		EBX,	48
	sub		EAX,	EBX
	STOSD
	LOOP		_checkVal

	std
	mov		ESI,	[EBP + 16]
	mov		EAX,	[EBP + 24]
	sub		EAX,	1
	mov		EBX,	4
	mul		EBX
	add		ESI,	EAX
	mov		EDI,	[EBP + 36]
	mov		ECX,	[EBP + 24]
	mov		EBX,	1
;	mov		EDI,	[EBP + 32]				; value sum
_integer:
	LODSD
	mul		EBX
	push	EAX
	mov		EAX,	EBX
	mov		EBX,	10
	mul		EBX
	mov		EBX,	EAX
	pop		EAX
	cld
	STOSD
	std
	LOOP	_integer
	
	CLD
	mov		ESI,	[EBP + 36]
	;mov		EDI,	[EBP + 28]				; array to keep track of all 10\
	mov		ECX,	[EBP + 24]
	mov		EBX,	0
_numActually:
	lodsd
	add		EBX,	EAX
	jc		_notNum
	loop	_numActually
	mov		EAX,	EBX
;	stosd			; final converted integer into main number array
	jmp		_nextNum

_notNum:
	mDisplayString	[EBP + 20]
	call	CrLf
	jmp		_getValue

_negNum:			; if first character is '-' then jump to here to convert to a negative number ( num * -1)
	dec		ECX
_checkNegVal:
	LODSB
	movzx	EAX,	al
	cmp		EAX,	48
	jb		_notNum
	cmp		EAX,	57
	ja		_notNum
	mov		EBX,	48
	sub		EAX,	EBX
	STOSD
	LOOP		_checkNegVal

	std
	mov		ESI,	[EBP + 16]
	mov		EAX,	[EBP + 24]
	sub		EAX,	2
	mov		EBX,	4
	mul		EBX
	add		ESI,	EAX
	mov		EDI,	[EBP + 36]
	mov		ECX,	[EBP + 24]
	dec		ECX
	mov		EBX,	1
;	mov		EDI,	[EBP + 32]				; value sum
_negInteger:
	LODSD
	mul		EBX
	push	EAX
	mov		EAX,	EBX
	mov		EBX,	10
	mul		EBX
	mov		EBX,	EAX
	pop		EAX
	cld
	STOSD
	std
	LOOP	_negInteger
	
	CLD
	mov		ESI,	[EBP + 36]
	;mov		EDI,	[EBP + 28]				; array to keep track of all 10\
	mov		ECX,	[EBP + 24]
	dec		ECX
	mov		EBX,	0
_NegNumActually:
	lodsd
	add		EBX,	EAX
	jc		_notNum
	loop	_NegNumActually
	mov		EAX,	EBX
	mov		EBX,	-1
	mul		EBX
;	stosd			; final converted integer into main number array
	jmp		_nextNum

_posNum:			; if first character is '-' then jump to here to convert to a negative number ( num * -1)
	dec		ECX
_checkPosVal:
	LODSB
	movzx	EAX,	al
	cmp		EAX,	48
	jb		_notNum
	cmp		EAX,	57
	ja		_notNum
	mov		EBX,	48
	sub		EAX,	EBX
	STOSD
	LOOP		_checkPosVal

	std
	mov		ESI,	[EBP + 16]
	mov		EAX,	[EBP + 24]
	sub		EAX,	2
	mov		EBX,	4
	mul		EBX
	add		ESI,	EAX
	mov		EDI,	[EBP + 36]
	mov		ECX,	[EBP + 24]
	dec		ECX
	mov		EBX,	1
;	mov		EDI,	[EBP + 32]				; value sum
_posInteger:
	LODSD
	mul		EBX
	push	EAX
	mov		EAX,	EBX
	mov		EBX,	10
	mul		EBX
	mov		EBX,	EAX
	pop		EAX
	cld
	STOSD
	std
	LOOP	_posInteger
	
	CLD
	mov		ESI,	[EBP + 36]
	;mov		EDI,	[EBP + 28]				; array to keep track of all 10\
	mov		ECX,	[EBP + 24]
	dec		ECX
	mov		EBX,	0
_posNumActually:
	lodsd
	add		EBX,	EAX
	jc		_notNum
	loop	_posNumActually
	mov		EAX,	EBX
;	stosd			; final converted integer into main number array
	jmp		_nextNum

_nextNum:
	pop		EDI
	stosd
	pop		ECX
	dec		ECX
	cmp		ECX, 0
	jne		_getTen


	popad
	pop		EBP
	RET	32
ReadVal		ENDP

;-----------------------------------------------------------------------------------------
; Name -	SumAverage
;
; Description - Will take in three address, two to store the sum and average, and one where the newly
;				converted numbers have been stored.  Take the sum of all 10 and store at the given address
;				then divide by 10 for the average and store in the also given address for average
;
; Preconditions - 10 numbers must be stored in numArray and sum and average address must be defined and passed
;					to the procedure
; 
; Postconditions - changes register EBX, EAX, EBP, ECX, EDI, ESI, 
;
; Receives -
;		sum - address of a value defined in .data for sum of 10 numbers
;		numArray - the address of array with the 10 converted characters to numbers 
;		average - the average of the 10 numbers that have been converted to numbers
;		
; Returns -
;			sum - sum of all the 10 numbers to address
;			average - address of the stored average of all 10 numbers
;------------------------------------------------------------------

SumAverage	PROC
	push	EBP
	mov		EBP,	ESP
	pushad

	mov		ESI,	[EBP + 16]
	mov		EDI,	[EBP + 8]
	mov		ECX,	10
	mov		EBX,	0
	cld
_arraySum:
	lodsd
	add		EBX,	EAX
	loop	_arraySum
	mov		EAX,	EBX
	stosd
	jmp		_arrayAverage

_arrayAverage:
	mov		EDI,	[EBP + 12]
	cmp		EAX,	0
	jl		_negSum
	mov		EBX,	10
	mov		EDX,	0
	div		EBX
	stosd

_negSum:
	mov		EBX,	-1
	mul		EBX
	mov		EBX,	10
	mov		EDX,	0
	div		EBX
	mov		EBX,	-1
	mul		EBX
	stosd

	popad
	pop		EBP
	RET		12
SumAverage	ENDP

;-----------------------------------------------------------------------------------------
; Name -	WriteVal
;
; Description - will take an array of x numbers that were passed in by address and convert to their respective character representations...
;				if a negative number is used, it will designate it to its correct section and continue the process...
;				once a number has been converted it will be printed off using the mDisplayString macro and 
;				continue through until all given numbers have been re calculated to respective characters and printed
;				printed off.
;
; Preconditions - mmust have a defined prompt to alert user to what is to be displayed, a macro to display string,
;					and an address passed to for numbers to be converted (1 or 10).  Another string will be passed
;					to store the converted characters and another to convert the string into its right 
;					order
; 
; Postconditions - changes register EBX, EAX, EBP, ECX, EDI, ESI, 
;
; Receives -
;		value - address of a value defined in .data for how many iterations needed
;		space - address for possible use of spaces for line up
;		finalOut - address of string of final characters to be written to user
;		outChara - address of character to be determined
;		outValue - address of string holding newly converted characters
;		numArray - address of array holding the converted numbers to be re converted to characters
;		prompt - addres of prompt with descritpion of what the procedure is being used for
;		
; Returns -
;			finalOut - an array that has been updated with converted integers to characters for current number being exchanged
;------------------------------------------------------------------

WriteVal	PROC
	push	EBP
	mov		EBP,	ESP
	pushad

	mDisplayString	[EBP + 8]
	call	CrLf
	cld
	mov		ESI,	[EBP + 12]
	mov		ECX,	[EBP + 32]			; counter for main loop is dependent on number vale inputted (1 or 10)

	; main loop, will set the current number to be re - ciphered, will check if negative and if so will send to neg section
_convertTen:
	lodsd
	push	ESI
	push	ECX
	cmp		EAX,	0
	jl		_negConvert

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; outer loop
_convert:
	mov		EBX,	10
	mov		EDX,	0
	mov		EDI,	[EBP + 16]
	mov		ECX,	1

	; will take num loaded individually, divide first by 10 (which will increment by *10) to make EDX hold individual values
	; then divide by move value in ECX to EBX and EDX to EAX to get single digit for that place value..while moving
	; reg push to save current values to move through each number in array correctly...when sing digit is found, when in EAX,
	; STOSB into the the string array (will be done in revers - 123 = "3", "2", "1")..check if whole number has been
	; is done by subtracting the current num from the whole number iself until 0 has been reached
_single:
	push	EAX				; save current number
	div		EBX				; divide by 10^x
	push	EDX				; save EDX (remainder
	mov		EAX,	EDX
	push	EBX
	mov		EBX,	ECX			; ECX holds what to currently divide EDX number by (EDX will hold a number with 0..0s, and ecx will get done to single digit
	mov		EDX,	0
	div		EBX
	add		EAX,	48				; single digit converted to its correct character referrence
	stosb				; store give byte into passed string to hold characters for current number

	; restore and update the registers for next round if needed to convert current number
	pop		EBX
	mov		EAX,	EBX
	mov		EBX,	10				; will give us single current digit to convert to ascii character
	mul		EBX
	mov		EBX,	EAX
	pop		EDX
	pop		EAX
	sub		EAX,	EDX
	push	EAX
	push	EBX
	mov		EAX,	ECX
	mov		EBX,	10				; will give us correct value to mult by EDX number when converting to single digit
	mul		EBX
	mov		ECX,	EAX

	pop		EBX
	pop		EAX

	mov		EDX,	0
	cmp		EAX,	0
	jne		_single
;	once 0, means that that number is done and to focus on 

	; will determine how many digits were iterated through by dividing by 10 until equal to 1, and store in counter
_singleTotal:				; how many numbers characters in string
	mov		EAX,	EBX
	mov		EBX,	10
	mov		EDX,	0
	div		ebx
	mov		EDX,	0
	mov		ECX,	1
	; determine how many digits
_amount:
	div		EBX
	cmp		EAX,	1
	je		_reverseNum
	mov		EDX,	0
	inc		ECX
	jmp		_amount


;	set reversed string and embpty byte string 
;	use the number store in ecx (amount of digits in string) to eax and decrement for index
;	mul by 1 since its a byte, not a word(2) or DWORD(4)
_reverseNum:
	mov		ESI,	[EBP + 16]				; string address where reversed characters are stored
	mov		EDI,	[EBP + 24]				; string to input correct ordered characters
	mov		EAX,	ECX
	dec		EAX
	mov		EBX,	1
	mul		EBX
	add		ESI,	EAX					; index to last element in string to be reversed
	std				; set flag so can go in reverse (ESI)

; reverse the orginal byte string of numbers to correct order
_newReversNum:
	lodsb
	cld
	stosb
	std
	LOOP	_newReversNum

; string has been reversed into coorect order
	mDisplayString	[EBP + 24]
	call	CrLf
	CALL	CrLf
	
	
	mov		EDI,	[EBP + 16]
	mov		EAX,	0
	mov		ECX,	10
	cld

	;	clear out the reversed string to continue through numbers
_clearOutValue:
	stosb
	LOOP	_clearOutValue

	mov		EDI,	[EBP + 24]
	mov		ECX,	10

	; clear out the newly created string of character for continued use
_clearFinalOutput:
	stosb
	LOOP	_clearFinalOutput
	jmp		_nextNumber

; negative number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; convert the negative number to positive, then set EBX to 10 for first divion of number
_negConvert:
	mov		EBX, -1
	mul		EBX
	mov		EBX,	10
	mov		EDX,	0
	mov		EDI,	[EBP + 16]
	mov		ECX,	1				; ecx is used to help with caculations since when divided by 10
									; it puts mul digits into remainder (120/100 = EDX - 20...need 2 - divide by num in ECX
									; to get 2)

	; will take num loaded individually, divide first by 10 (which will increment by *10) to make EDX hold individual values
	; then divide by move value in ECX to EBX and EDX to EAX to get single digit for that place value..while moving
	; reg push to save current values to move through each number in array correctly...when sing digit is found, when in EAX,
	; STOSB into the the string array (will be done in revers - 123 = "3", "2", "1")
_negativeSingle:
push	EAX				; save current number
	div		EBX				; divide by 10^x
	push	EDX				; save EDX (remainder
	mov		EAX,	EDX
	push	EBX
	mov		EBX,	ECX			; ECX holds what to currently divide EDX number by (EDX will hold a number with 0..0s, and ecx will get done to single digit
	mov		EDX,	0
	div		EBX
	add		EAX,	48				; single digit converted to its correct character referrence
	stosb				; store give byte into passed string to hold characters for current number

	; restore and update the registers for next round if needed to convert current number
	pop		EBX
	mov		EAX,	EBX
	mov		EBX,	10				; will give us single current digit to convert to ascii character
	mul		EBX
	mov		EBX,	EAX
	pop		EDX
	pop		EAX
	sub		EAX,	EDX
	push	EAX
	push	EBX
	mov		EAX,	ECX
	mov		EBX,	10				; will give us correct value to mult by EDX number when converting to single digit
	mul		EBX
	mov		ECX,	EAX

	pop		EBX
	pop		EAX

	mov		EDX,	0
	cmp		EAX,	0
	jne		_negativeSingle
;	once 0, means that that number is done and to focus on 
	
	mov		EAX,	45
	stosb

	; block will determine how many digits have been created when going from array to string characters
_negativeSingleTotal:				; how many numbers characters in string
	mov		EAX,	EBX
	mov		EBX,	10
	mov		EDX,	0
	div		ebx
	mov		EDX,	0
	mov		ECX,	2 ; ecx set to two since for negatives there will be atleast 2 characters ("-" and num byte)
	
	; will determine the amount of digits using 10 to divide by by previous 10, 100, (so on) until 1 has been reached
_negativeAmount:
	div		EBX
	cmp		EAX,	1
	je		_negativeReverseNum
	mov		EDX,	0
	inc		ECX
	jmp		_negativeAmount

;	set reversed string and embpty byte string 
;	use the number store in ecx (amount of digits in string) to eax and decrement for index
;	mul by 1 since its a byte, not a word(2) or DWORD(4)
_negativeReverseNum:
	mov		ESI,	[EBP + 16]
	mov		EDI,	[EBP + 24]
	mov		EAX,	ECX
	dec		EAX
	mov		EBX,	1
	mul		EBX
	add		ESI,	EAX
	std

; reverse the orginal byte string of numbers to correct order, reversed string will move in revers
; and the new string to to displayed will move forward , with the bytes being inputted in their correct
; indexes
_negativeNewReversNum:
	lodsb
	cld
	stosb
	std
	LOOP	_negativeNewReversNum

; string has been reversed into coorect order
	mDisplayString	[EBP + 24]
	call	CrLf
	CALL	CrLf
	
	
	mov		EDI,	[EBP + 16]
	mov		EAX,	0
	mov		ECX,	11
	cld
	; negative input has been completed and now 0 bytes will replace current elements
_negativeClearOutValue:
	stosb
	LOOP	_negativeClearOutValue

	mov		EDI,	[EBP + 24]
	mov		ECX,	11

	; negative input has been completed and now 0 bytes will replace current elements
_negativeClearFinalOutput:
	stosb
	LOOP	_negativeClearFinalOutput
	

	



	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; moves onto to next number if there aer multiple, using ECX to determine if to finish writing values
	; or to continue down array/string
_nextNumber:
	pop		ECX
	dec		ECX
	pop		ESI
	cmp		ECX,	0
	jne		_convertTen

	popad
	pop		EBP
	RET	28
WriteVal	ENDP

;-----------------------------------------------------------------------------------------
; Name - farwell
;
; Description - will display a goodbye message to user, which in this case wll be CS 271
;
; Preconditions - and array addres must be passed in with its address and then passed into a macro to display the message
; 
; Postconditions - changes register EBP, EDX
;
; Receives - goodbyezz - address of prompt to be displayed to use
;
; Returns - None
;------------------------------------------------------------------

farewell	PROC
	push	EBP
	mov		EBP,	ESP	
	pushad

	; moves passed address into EDX to be written by macro
	call	CrLf
	mov		EDX,	[EBP + 8]
	mDisplayString	EDX


	popad
	pop		EBP
	RET	4
farewell	ENDP
END main
