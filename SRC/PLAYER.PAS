procedure player_init;
var loop : integer;
begin
  slow:=0;
  s1:=0;
  s2:=0;
  s3:=0;
  s4:=0;
  playerX:=3;
  playerY:=2;
  bomb:=false;
  for loop:= 1 to 15 do p[loop].rocket:=false;
  nr:=0;
  ps:=0;
  level_completed:=false;
  done_level:=false;
  pos:=0;
  player_live:=100;
  down_terrain:=0;
  out_screen:=false;
  max_r:=3;
  delay_:=55;
end;

procedure Crocket.rocket_fly;
var i, j : integer;
begin
  slwP:=slwP+1;
  if slwP=3 then begin rocketX:=rocketX+1; slwP:=0; end;
  putchar(rocketX-pos,rocketY,30,ord('ú'));
  if (map^[rocketX+1,rocketY].color>0) then
  begin
    for i:= 1 to 3 do
    for j:= 0 to 2 do
    begin
      if sounds then sound(500);
      map^[i+rocketX,j+rocketY-1].color:=0;
      map^[i+rocketX,j+rocketY-1].ascii:=0;
    end;
    rocket:=false;
  end;
  if (rocketX-pos>80) then rocket:=false;
end;

procedure draw_image(x, y : integer; var img : Timage);
var i, j : integer;
begin
  for i:= 1 to 17 do
  for j:= 1 to 15 do if img[i,j].ascii<>0 then
  begin
    putchar(i+x,j+y,img[i,j].color,img[i,j].ascii);
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

procedure bomb_fly;
var i, j : integer;
begin
  slwB:=slwB+1;
  if slwB=5 then begin bombY:=bombY+1; slwB:=0; end;

  if limit(bombX-pos,bombY,1,1,80,50) then
  putchar(bombX-pos,bombY,7,219);

  if (map^[bombX,bombY+1].color>0)or(bombY>50) then
  begin
    randomize;
    for i:= 1 to 5 do
    for j:= 1 to 3 do
    begin
      if sounds then sound(500);
      map^[i+bombX-3,j+bombY].ascii:=0;
      map^[i+bombX-3,j+bombY].color:=0;
    end;
    bomb:=false;
  end;
end;

procedure player_keyboard;
var loop : integer;
begin
  (* sterowanie statkiem - BEGIN *)

  if not out_screen then
  begin

    if keydown[downscan] then
    begin
      inc(s1);
      if s1=15 then
      begin
        if(playerY<45) then playerY:=playerY+1;
        s1:=0;
      end;
    end;
    if keydown[upscan] then
    begin
      inc(s2);
      if s2=15 then
      begin
        if (playerY>0) then playerY:=playerY-1;
        s2:=0;
      end;
    end;
    if keydown[rightscan] then
    begin
      inc(s3);
      if s3=15 then
      begin
        if (playerX<70) then playerX:=playerX+1;
        s3:=0;
      end;
    end;
    if keydown[leftscan] then
    begin
      inc(s4);
      if s4=15 then
      begin
        if (playerX>-1) then playerX:=playerX-1;
        s4:=0;
      end;
    end;

    (* sterowanie statkiem - END *)

    (* strzelanie pociskami *)
    ps:=ps+1;
    for loop:= 1 to max_r do
    begin
      if keydown[scanof(' ')] and (not p[loop].rocket) and (ps>delay_)
      and (player_ammo>0) then
      begin
        player_ammo:=player_ammo-1;
        if nr=max_r then nr:=0;
        nr:=nr+1;
        p[nr].rocketX:=pos+playerX+9;
        p[nr].rocketY:=playerY+3;
        p[nr].rocket:=true;
        ps:=0;
      end;
    end;

    (* wyrzucanie bomby *)
    if keydown[ctrlscan] and not bomb then
    begin
      bomb:=true;
      bombX:=pos+playerX+4;
      bombY:=playerY+3;
    end;

  end;

  if playerX+8<0 then out_screen:=true;
end;

procedure draw_b_r;
var loop : integer;
begin
  (* rysowanie bomby *)
  if bomb then bomb_fly;
  (* rysowanie pociskow  *)
  for loop:= 1 to max_r do if p[loop].rocket then p[loop].rocket_fly;
end;

procedure player_collision;
begin
  (* kolizje gracza z terenem *)
  ground:=false;
  if (limit_map(playerX+pos,playerY,1,1,9,5)) then ground:=true;

  if pos<480 then
  begin
    if (limit_map(playerX+pos+1,playerY,2,1,8,4)) then playerX:=playerX-1;
    if (limit_map(playerX+pos-1,playerY,3,1,9,4)) then playerX:=playerX+1;
    if (limit_map(playerX+pos,playerY+1,2,1,9,3)) then playerY:=playerY-1;
    if (limit_map(playerX+pos,playerY-1,2,2,9,4)) then playerY:=playerY+1;
  end;
end;