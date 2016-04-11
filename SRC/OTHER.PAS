function limit(x, y, x1, y1, x2, y2 : integer) : boolean;
begin
  limit:=false;
  if (x>x1-1)and(x<x2+1)and(y>y1-1)and(y<y2+1) then limit:=true;
end;

function limit_map(x, y : integer; x1, y1, x2, y2 : integer) : boolean;
var i, j : integer;
begin
  limit_map:=false;
  for i:= x1 to x2 do
  for j:= y1 to y2 do
  begin
    if map^[i+x,j+y].color>0 then limit_map:=true;
  end;
end;

function inside_in_inside(x, y, x1, y1, x2, y2, xx1,
                          yy1, xx2, yy2 : integer): boolean;
var i, j : integer;
begin
  inside_in_inside:=false;
  for i:= x1 to x2 do
  for j:= y1 to y2 do
  begin
    if (x+i>xx1-1)and(x+i<xx2+1)and(y+j>yy1-1)and(y+j<yy2+1)
    then inside_in_inside:=true;
  end;
end;

procedure load_image_big(name : string; var img : Timage_big);
var f : file of Timage_big;
begin
  assign(f,name);
  reset(f);
  read(f,img);
  close(f);
end;

procedure load_image_large(name : string; var img : Timage_large);
var f : file of Timage_large;
begin
  assign(f,name);
  reset(f);
  read(f,img);
  close(f);
end;

procedure Hline(x, y1, y2 : integer; col, ch : byte);
var i : integer;
begin
  for i:= y1 to y2 do putchar(x,i,col,ch);
end;

procedure draw_image_big(i, j : integer; var img : Timage_big);
var x, y, c : integer;
begin
  for y:= 1 to 20 do
  for x:= 1 to 40 do
  begin
    if img[x,y].ascii<>0 then
    begin
      putchar(x+i,y+j,img[x,y].color,img[x,y].ascii);
    end;
  end;
end;

procedure draw_image_large(var img : Timage_large);
var x, y, c : integer;
begin
  for x:= 1 to 80 do
  for y:= 1 to 50 do putchar(x,y,img[x,y].color,img[x,y].ascii);
end;

procedure draw_image_intro(i, j : integer; var img : Timage_big);
var x, y, c : integer;
begin
  for y:= 1 to 20 do
  for x:= 1 to 40 do
  begin
    putchar(x+i,y+j,img[x,y].color,img[x,y].ascii);
    hline(x+i,y+j,50,img[x,y].color,img[x,y].ascii);
    refresh;
  end;
end;

procedure insert_sort;
var
   i, j, temp, powtorz : integer;
   temp2 : string[10];
begin
     for powtorz:= 1 to 10 do
     begin
          j:=powtorz;
          temp:=hiscore[powtorz].score;
          temp2:=hiscore[powtorz].name;
          while (hiscore[j-1].score<temp)and(j>1) do
          begin
                hiscore[j].score:=hiscore[j-1].score;
                hiscore[j].name:=hiscore[j-1].name;
                j:=j-1;
          end;
          hiscore[j].score:=temp;
          hiscore[j].name:=temp2;
     end;
end;