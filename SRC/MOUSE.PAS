
unit mouse;

interface

function initmouse : boolean;
procedure setmousepos(x, y : integer);
function mousex : word;
function mousey : word;
procedure setmousewindow(x1, y1, x2, y2 : integer);
function mousein(x, y, x1, y1, x2, y2 : integer) : boolean;
procedure showmouse;
procedure hidemouse;
function leftbutton : boolean;
function rightbutton : boolean;

implementation

function LeftButton : boolean; assembler;
asm
	mov	ax,3
	int	$33
	mov	ax,bx
	and	ax,1
end;

function RightButton : boolean; assembler;
asm
	mov	ax,3
	int	$33
	mov	ax,bx
	shr	ax,1
	and	ax,1
end;

function InitMouse : boolean; assembler;
asm
	xor	ax,ax
	int	$33
	not	ax
	xor	ax,1
	and	ax,1
end;

procedure showmouse; assembler;
asm
	mov	ax,$0001
	int	$33
end;

procedure hidemouse; assembler;
asm
	mov	ax,$0002
	int	$33
end;

procedure SetMouseWindow(x1,y1,x2,y2 : integer);
begin
x1:=x1*2;
x2:=x2*2;
asm
	mov	ax,$0007
	mov	cx,x1
	mov	dx,x2
	int	$33
	mov	ax,$0008
	mov	cx,y1
	mov	dx,y2
	int	$33
end;
end;

function mousex_ : word;assembler;
asm
  mov ax,3; int 33h; mov ax,cx
end;

function mousex : word;
begin
     mousex:=mousex_ div 2;
end;

function mousey : word; assembler;
asm
  mov ax,3; int 33h; mov ax,dx
end;

Procedure SetMousePos(X, Y : Integer);
begin
x:=x*2;
Asm
   Mov Ax, $0004
   Mov Cx, X
   Mov Dx, Y
   Int $33
End;
end;

Function Mousein(X, Y, X1, Y1, X2, Y2 : Integer) : Boolean;
Begin
     Mousein:=False;
     If (X>X1-1) and (X<X2+1) and (Y>Y1-1) and (Y<Y2+1) then
     Mousein:=True;
End;

end.