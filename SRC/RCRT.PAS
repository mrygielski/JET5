{/+++++++++++++++++++++++++++++++++++++\}
{| REGi virtual CRT               2005 |}
{| wersja okrojona ;)                  |}
{+++++++++++++++++++++++++++++++++++++++}
{| autor: Michal Rygielski             |}
{| email: regi007o2.pl                 |}
{| HTTP:                               |}
{| www.ggate.prv.pl                    |}
{| www.regi.abc.pl                     |}
{\+++++++++++++++++++++++++++++++++++++/}

unit Rcrt;

interface

type
    Tscreen80x50 = array[0..7999] of byte; {80x50}

var
   bufor : ^Tscreen80x50;

procedure init3h;
procedure close3h;
procedure refresh;
procedure putchar(x, y : integer; color, chr : byte);
function getchar(x, y : integer) : byte;
function getcolor(x, y : integer) : byte;
procedure disablebgcolor(setbg : boolean);
procedure printxy(x, y : integer; color : byte; str : string);
procedure cls(color : byte);
procedure bar(x, y, x2, y2 : integer; color : byte);
procedure window(x, y, x2, y2 : word);
procedure cursor(c : boolean);
function num2str(i : longint) : string;
procedure delay(ms : word);
procedure sound(hertz : word);
procedure nosound;
function readkey : char;
procedure readtext(x, y, c1, c2, long : integer; var text : string);
function find_file(name : string) : boolean;

implementation

const
     errors : array[1..2] of string[45] =
     ('ERROR #1: tryb nie zainicjowany',
      'ERROR #2: brak pamieci do zainicjowania trybu');

var
   maxx, maxy, minx, miny : integer;
   initOK, closeOK : boolean;
   bgcolor : byte;

procedure error(nr : byte);
begin
     if nr=1 then
     begin
          if not initOK then
          begin
               writeln(errors[1]);
               halt(1);
          end;
     end;
     if nr=2 then
     begin
          if maxavail<sizeof(bufor) then
          begin
               writeln(errors[2]);
               halt(1);
          end;
     end;
end;

procedure refresh;
begin
     error(1);
     move(bufor^,mem[$b800:0],8000);
end;

procedure putchar;
begin
     {$Q-,R-}
     error(1);
     if (x<=1) then x:=1;
     if (y<=1) then y:=1;
     x:=(x*2)-2;
     y:=(y*2)-2;
     if (x>=minx) and (x<=maxx) and (y>=miny) and (y<=maxy) then
     begin
          bufor^[(y shl 6)+(y shl 4)+x]:=chr;
          bufor^[((y shl 6)+(y shl 4)+x)+1]:=color;
     end;
end;

function getchar;
begin
     error(1);
     if (x<=1) then x:=1;
     if (y<=1) then y:=1;
     x:=(x*2)-2;
     y:=(y*2)-2;
     getchar:=bufor^[y*80+x];
end;

function getcolor;
begin
     error(1);
     if (x<=1) then x:=1;
     if (y<=1) then y:=1;
     x:=(x*2)-2;
     y:=(y*2)-2;
     getcolor:=bufor^[(y*80+x)+1];
end;

procedure printxy;
var i : integer;
begin
     error(1);
     for i:= 1 to length(str) do putchar((i-1)+x,y,color+bgcolor,ord(str[i]));
end;

procedure textmode(mode : byte); assembler;
asm
     cmp  mode, 40h
     jnz  @normalset
     mov  ax,1112h
     mov  bl,00h
     jmp  @MakeItSo
   @normalset:
     mov  ah, 00h
     mov  al, mode
   @MakeItSo:
     int  10h
end;

procedure init3h;
begin
     error(2);
     textmode($40);
     new(bufor);
     fillchar(bufor^,8000,0);
     initOK:=true;
end;

procedure close3h;
begin
     error(1);
     dispose(bufor);
     closeOK:=true;
     asm
        mov ax, 3h
        int 10h
     end;
end;

procedure cls;
var i, j : integer;
begin
     error(1);
     for i:= 0 to 80 do
     for j:= 0 to 50 do putchar(i,j,color,219);
end;

procedure window;
begin
     minx:=(x*2)-2; maxx:=(x2*2)-2;
     miny:=(y*2)-2; maxy:=(y2*2)-2;
end;

procedure bar;
var i, j : integer;
begin
     for i:= x to x2 do
     for j:= y to y2 do putchar(i,j,color,219);
end;

procedure disablebgcolor; assembler;
asm
   mov  ax, $1003
   mov  bl, setbg
   int  $10
end;

procedure cursor;
begin
     if not c then
     begin
       asm
          Mov Cx,0F00H
          Mov Ah,1
          Int 10H
       end;
     end else
     begin
       asm
          Mov Cx,0F10H
          Mov Ah,1
          Int 10H
       end;
     end;
end;

function num2str;
var temp : string;
begin
     str(i,temp);
     num2str:=temp
end;

procedure delay(ms : word); Assembler;
asm
  mov ax,1000
  mul ms
  mov cx,dx
  mov dx,ax
  mov ah,$86
  int $15
end;

procedure sound(hertz : word); Assembler;
asm
  MOV    BX,SP
  MOV    BX,&hertz
  MOV    AX,34DDh
  MOV    DX,0012h
  CMP    DX,BX
  JNB    @J1
  DIV    BX
  MOV    BX,AX
  IN     AL,61h
  TEST   AL,03h
  JNZ    @J2
  OR     AL,03h
  OUT    61h,AL
  MOV    AL,-4Ah
  OUT    43h,AL
@J2:
  MOV    AL,BL
  OUT    42h,AL
  MOV    AL,BH
  OUT    42h,AL
@J1:
end;

procedure nosound; assembler;
asm
  IN     AL,61h
  AND    AL,0FCh
  OUT    61h,AL
end;

var
  scancode : byte;

function readekey: word; assembler;
asm
  mov ah, 10h
  int 16h
end;

function readkey : char;
var
  ch: word;
begin
  if scancode<>0 then
  begin
    readkey:=char(scancode);
    scancode := 0;
    exit;
  end;
  ch:=readekey;
  if lo(ch)=0 then
  begin
    scancode:=hi(ch);
    readkey:=#0;
    exit;
  end;
  readkey:=char(lo(ch));
end;

procedure readtext(x, y, c1, c2, long : integer; var text : string);
var
   t : integer;
   z : char;
begin
     text:='';
     t:=0;
     for t:=1 to long+1 do
     begin
     if t=long+1 then begin
     repeat
           z:=readkey;
     until (ord(z)=8) or (z=#13);
     end else z:=readkey;
     if (ord(z)=8) and (text<>'') then
     begin
          t:=t-1;
          delete(text,t,1);
          printxy(x+t,y,c2,'Û');
          refresh;
     end;
     if ord(z) in [32..128] then
     begin
          printxy(x+t,y,c1,Z);
          refresh;
          text:=text+z;
     end else t:=t-1;
     if z=#13 then t:=long+1;
     end;
end;

function find_file(name : string) : boolean;
var
   f : file of byte;
begin
     {$I-}
     assign(f,name);
     reset(f);
     close(f);
     {$I+}
     find_file:=IOResult=0;
end;

begin
     minx:=0;maxx:=159;
     miny:=0;maxy:=99;
     initOK:=false;
     closeOK:=false;
     bgcolor:=0;
end.