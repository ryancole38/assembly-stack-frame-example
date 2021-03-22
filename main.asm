.model small
.stack 100h
.data
	HELLO_MSG	db "Hello, world!!", 0
.code
main proc
	mov	ax, SEG HELLO_MSG
	mov	ds, ax
	
	mov	dx, OFFSET HELLO_MSG
	push	dx
	call	print_string
	pop	bx

	call	exit

;; END MAIN


	;;	Subroutine: exit
	;;	Description: immediately exit the program
	;;	Parameters: none
	;;	Returns: none
	exit:
		mov 	ax, 4c00h
		int	21h

	;;	Macro: allocate_stack_space
	;;	Description: Allocate space on the stack for variables and registers
	;;	Parameters: extra
	;;		The amount of extra bytes to allocate on the stack
	allocate_stack_space	MACRO extra
		push	bp
		mov	bp, sp
		sub	bp, 8
		sub	bp, extra
		mov	sp, bp
	ENDM

	;;	Macro: 	free_stack_space
	;;	Description: Free the space on the stack that was allocated
	;;	Parameters: extra
	;;		The amount of extra space that was allocated on the stack
	free_stack_space	MACRO	extra
		add	bp, 8
		add	bp, extra
		mov	sp, bp
		pop	bp
	ENDM

	;;	Macro:	push_registers
	;;	Description: push the current contents of registers to the stack
	;;	Parameters: offset
	;;		The number of bytes that were allocated for other variables
	push_registers		MACRO	offset
		add	bp, offset
		mov	[bp + 0], ax
		mov	[bp + 2], bx
		mov	[bp + 4], cx
		mov	[bp + 6], dx
		sub	bp, offset
	ENDM

	;;	Macro:	pop_registers
	;;	Description: pop the registers that were saved by push_registers
	;;	Parameters: offset
	;;		The number of bytest that were allocated for other variables
	pop_registers		MACRO	offset
		add	bp, offset
		mov	ax, [bp + 0]
		mov	bx, [bp + 2]
		mov	cx, [bp + 4]
		mov	dx, [bp + 6]
		sub	bp, offset
	ENDM

	;;	Subroutine: print_string
	;;	Depscription: prints a zero-delimited string
	;;	Parameters:	2 byte pointer to string
	;;	Returns:	none
	;;	STACK LAYOUT
	;;	[bp + 12] 	Parameter 1
	;;	[bp + 10]	Return Address
	;;	[bp + 8]	BP Register
	;;	[bp + 6]	DX Register
	;;	[bp + 4]	CX Register
	;;	[bp + 2]	BX Register
	;;	[bp + 0]	AX Register
	print_string:
		allocate_stack_space 0		;; allocate space on the stack for 0 local variables
		push_registers 0		;; push registers, assuming no local variables
		
		mov	bl, 0
		mov	ah, 06h
		mov	bx, [bp + 12]		;; Get pointer to string 
		mov	dl, [bx]		;; Move first charater of string into dl
		print_loop:
			int 	21h		;; Print first character
			inc	bx		;; Increment string pointer
			mov	dl, [bx]	;; Get next character
			cmp	dl, 0		;; Check if character is null
			jne	print_loop	;; Print until zero 

		pop_registers 0			;; pop registers, assuming no local variables
		free_stack_space 0		;; reset the stack to how it was before
		ret

	;;	Subroutine: multiply
	;;	Description: multiply and return A by B
	;;	Parameters: word a, word b 
	;;	Returns: word
	;;	STACK LAYOUT
	;;	[bp + 15]	B
	;;	[bp + 13]	A
	;;	[bp + 11]	return address
	;;	[bp + 9]	bp
	;;	[bp + 7]	dx
	;;	[bp + 5]	cx
	;;	[bp + 3]	bx
	;;	[bp + 1]	ax
	;;	[bp + 0]	byte counter	
	multiply:
		allocate_stack_space 1
		push_registers 1

		mov	ax, 0000h	;; while we save registers, we can't assume they're 0
		mov	bx, [bp + 15]	;; get B		

		mov	[bp + 0], bl	;; move B to our local variable

		multiply_loop:
			mov	bl, [bp + 0]	;; get counter
			cmp	bl, 0
			je	multiply_end	;; return if our counter is zero
			sub	bl, 1
			mov	[bp + 0], bl	;; store our counter
			mov	bx, [bp + 13]	;; get A
			add	ax, bx		;; add A to our total
			jmp multiply_loop

		multiply_end:
		mov	ax, [bp + 15]	;; store return value at the top of the stack
		pop_registers 1		;; pop the registers, remembering we used a local variable
		free_stack_space 1	;; reset the stack, again remembering that a local variable was used	












main endp
end main
