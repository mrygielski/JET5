procedure draw_terrain(pos : integer);
var x, y, tt : integer;
begin
  for x:= 1 to 80 do
  for y:= 1 to 50 do
  begin
    if map^[x+pos,y].ascii<>0 then
    putchar(x,y,map^[x+pos,y].color,map^[x+pos,y].ascii);
  end;
  for x:= 1 to 80 do
  for y:= 1 to 49 do
  begin
    if (map^[x+pos,y].color>0) then
    begin
      if (map^[x+pos,y+1].ascii=0)and
              (not inside_in_inside(x+pos,y+1,1,1,1,1,
                            playerX+3,playerY+2,playerX+9,playerY+4))
      then
          begin
            down_terrain:=down_terrain+1;
            if down_terrain=5 then
            begin
              if sounds then sound(400);
              map^[x+pos,y+1].color:=map^[x+pos,y].color;
              map^[x+pos,y+1].ascii:=map^[x+pos,y].ascii;
              map^[x+pos,y].color:=0;
              map^[x+pos,y].ascii:=0;
              down_terrain:=0;
            end;
          end;
    end;
  end;
end;
