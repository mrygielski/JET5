
uses supergfx, rcrt, games, crt;

type
    Timage = array[1..17,1..15] of record ascii, color : byte; end;
    Timage2 = array[0..18,0..16] of record ascii, color : byte; end;

var
   image, tmp : Timage;
   temp, temp2 : Timage2;
   f : file of Timage;

   nrch, nrcol : byte;
   px, py : integer;

procedure init;
begin
  init3h;
  cursor(false);
  disablebgcolor(false);
  initnewkeyint;
  setmousepos(getmaxx div 2,getmaxy div 2);
  setmousewindow(1,1,80,50);
  nrch:=176; nrcol:=1;
end;

procedure done;
begin
  setmousewindow(1,1,319,199);
  setmousepos(0,0);
  setoldkeyint;
  close3h;
end;

procedure init_terrain;
var x, y : integer;
begin
  for x:= 1 to 17 do
  for y:= 1 to 15 do
  begin
    image[x,y].color:=0;
    image[x,y].ascii:=0;
  end;
end;

procedure right_sc;
var
   i, j : integer;
begin
  delay(20);
  for i:= 1 to 18 do
  for j:= 1 to 16 do
  begin
    tmp[i-1,j]:=image[i,j];
  end;
  for i:= 1 to 17 do
  for j:= 1 to 15 do
  begin
    image[i,j]:=tmp[i,j];
  end;
end;

procedure up_sc;
var
   i, j : integer;
begin
  delay(20);
  for i:= 1 to 17 do
  for j:= 1 to 16 do
  begin
    tmp[i,j-1]:=image[i,j];
  end;
  for i:= 1 to 17 do
  for j:= 1 to 15 do
  begin
    image[i,j]:=tmp[i,j];
  end;
end;

procedure draw_image;
var x, y : integer;
begin
  for x:= 1 to 17 do
  for y:= 1 to 15 do if image[x+px,y+py].ascii<>0 then
                              putchar(x,y,image[x+px,y+py].color,image[x+px,y+py].ascii);
end;

begin
  init;
{  assign(f,'test.map');
  reset(f);
  read(f,map);
  close(f);}
  assign(f,'player.img');
  reset(f);
  read(f,image);
  close(f);
  repeat
        bar(1,1,17,15,0);
        draw_image;
        printxy(2,20,nrcol,'WYBRANY ZNAK ('+numstr(nrcol)+') ='+chr(nrch)+'('+num2str(nrch)+')');
        putchar(mousex,mousey,64+getcolor(mousex,mousey) xor 7,getchar(mousex,mousey));
        refresh;
        cls(8);

        if mousein(mousex,mousey,1,1,17,15) then
        begin
        if leftbutton then
        begin
          image[mousex,mousey].color:=nrcol;
          image[mousex,mousey].ascii:=nrch;
        end;
        if rightbutton then
        begin
          image[mousex,mousey].color:=0;
          image[mousex,mousey].ascii:=0;
        end;
        end;

        if keydown[scanof('q')] then
        begin
          if nrch<255 then inc(nrch);
          delay(70);
        end;
        if keydown[scanof('a')] then
        begin
          if nrch>1 then dec(nrch);
          delay(70);
        end;
        if keydown[scanof('w')] then
        begin
          if nrcol<255 then inc(nrcol);
          delay(100);
        end;
        if keydown[scanof('s')] then
        begin
          if nrcol>0 then dec(nrcol);
          delay(100);
        end;
        if keydown[rightscan] and keydown[ctrlscan] then right_sc;
        if keydown[upscan] and keydown[ctrlscan] then up_sc;

  until keydown[escscan];
  done;
  assign(f,'player.img');
  rewrite(f);
  write(f,image);
  close(f);
end.