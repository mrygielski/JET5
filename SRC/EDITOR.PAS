
uses mouse, rcrt, games, crt;

type
    Tmap = array[1..560,1..50] of record ascii, color : byte; end;
    Timage = array[1..17,1..15] of record ascii, color : byte; end;
    Txy = array[1..50] of record x, y : integer; nr : byte; end;

var
   map : Tmap;
   f : file of Tmap;

   nrch, nrcol : byte;
   pos : word;

procedure init;
begin
  init3h;
  cursor(false);
  disablebgcolor(false);
  initnewkeyint;
  setmousepos(40,25);
  setmousewindow(1,1,80,50);
  nrch:=176; nrcol:=1;
  pos:=0;
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
  for x:= 1 to 80 do
  for y:= 1 to 50 do
  begin
    map[x,y].color:=0;
    map[x,y].ascii:=0;
  end;
end;

procedure draw_terrain(pos : integer);
var x, y : integer;
begin
  for x:= 1 to 80 do
  for y:= 1 to 50 do if map[x+pos,y].ascii<>0 then
                          putchar(x,y,map[x+pos,y].color,map[x+pos,y].ascii);
end;

procedure fill;
var x, y : integer;
begin
  for x:= 1 to 80 do
  begin
    y:=51;
    repeat
      y:=y-1;
      map[x+pos,y].ascii:=nrch;
      map[x+pos,y].color:=nrcol;
    until map[x+pos,y-1].ascii<>0;
  end;
end;

procedure del;
var x, y : integer;
begin
  for x:= 1 to 80 do
  for y:= 1 to 50 do
  begin
      if (map[x+pos,y].ascii=nrch)and(map[x+pos,y].color=nrcol) then map[x+pos,y].ascii:=0;
  end;
end;

procedure draw_image(x, y : integer; var img : Timage);
var i, j : integer;
begin
  for i:= 1 to 17 do
  for j:= 1 to 15 do if img[i,j].ascii<>0 then
  begin
                              putchar(i+x,j+y,img[i,j].color,img[i,j].ascii);
  rcrt.window(1,1,80,50);
                              end;
end;


procedure load_image(path : string; var img : Timage);
var f : file of Timage;
begin
  assign(f,path);
  reset(f);
  read(f,img);
  close(f);
end;

var
   enemy : array[1..7] of ^Timage;
   f2 : file of Txy;
   enemy_pos : Txy;
   nr, nr_typ : byte;
   i : integer;

procedure new_images;
var i : integer;
begin
 for i:= 1 to 7 do new(enemy[i]);
end;

procedure dispose_images;
var i : integer;
begin
  for i:= 1 to 7 do dispose(enemy[i]);
end;

begin
  new_images;
  load_image('gfx\enemy1.img',enemy[1]^);
  load_image('gfx\enemy2.img',enemy[2]^);
  load_image('gfx\energy.img',enemy[3]^);
  load_image('gfx\health.img',enemy[4]^);
  load_image('gfx\enemy3.img',enemy[5]^);
  load_image('gfx\tree1.img',enemy[6]^);
  load_image('gfx\tree2.img',enemy[7]^);
  init;
  assign(f,'maps\level6.map');
  reset(f);
  read(f,map);
  close(f);
  nr:=1;
  nr_typ:=1;

  for i:= 1 to 50 do
  begin
    enemy_pos[i].x:=-20;
    enemy_pos[i].y:=80;
    enemy_pos[i].nr:=1;
  end;


  assign(f2,'maps\level6.npc');
  reset(f2);
  read(f2,enemy_pos);
  close(f2);

  repeat
        draw_terrain(pos);

        for i:= 1 to 50 do
        begin
          draw_image(enemy_pos[i].x-pos,enemy_pos[i].y,enemy[enemy_pos[i].nr]^);
          printxy(enemy_pos[i].x-pos,enemy_pos[i].y,12,num2str(i));
        end;

        draw_image(2,40,enemy[nr_typ]^);
        printxy(2,2,nrcol,'WYBRANY ZNAK='+chr(nrch)+'('+num2str(nrch)+')');
        printxy(2,3,15,'POZYCJA MAPY='+num2str(pos));
        printxy(2,48,15,'TYP PRZECIWNIKA='+num2str(nr_typ));
        printxy(2,49,15,'NR PRZECIWNIKA='+num2str(nr));
        putchar(mousex,mousey,64+getcolor(mousex,mousey) xor 7,getchar(mousex,mousey));
        refresh;
        cls(1);

        if keydown[scanof('z')] then
        begin
          enemy_pos[nr].x:=mousex+pos;
          enemy_pos[nr].y:=mousey;
          enemy_pos[nr].nr:=nr_typ;
        end;

        if keydown[scanof('+')] then if nr_typ<7 then begin nr_typ:=nr_typ+1; delay(200); end;
        if keydown[scanof('-')] then if nr_typ>1 then begin nr_typ:=nr_typ-1; delay(200); end;
        if keydown[scanof(']')] then begin if nr<50 then nr:=nr+1; delay(200); end;
        if keydown[scanof('[')] then begin if nr>1 then nr:=nr-1; delay(200); end;

        if keydown[f1scan] then fill;
        if keydown[f2scan] then del;

        if leftbutton then
        begin
          map[mousex+pos,mousey].color:=nrcol;
          map[mousex+pos,mousey].ascii:=nrch;
        end;
        if rightbutton then
        begin
          map[mousex+pos,mousey].color:=0;
          map[mousex+pos,mousey].ascii:=0;
        end;

        if keydown[scanof('q')] then
        begin
          if nrch<255 then inc(nrch);
          delay(100);
        end;
        if keydown[scanof('a')] then
        begin
          if nrch>1 then dec(nrch);
          delay(100);
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

        if keydown[rightscan] then
        begin
          if pos<480 then inc(pos);
          delay(50);
        end;
        if keydown[leftscan] then
        begin
          if pos>0 then dec(pos);
          delay(50);
        end;

  until keydown[escscan];
  done;

  assign(f2,'maps\level6.npc');
  rewrite(f2);
  write(f2,enemy_pos);
  close(f2);

  assign(f,'maps\level6.map');
  rewrite(f);
  write(f,map);
  close(f);
  dispose_images;
end.