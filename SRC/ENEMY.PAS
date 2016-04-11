procedure Cenemy.load_image(path : string);
var f : file of Timage;
begin
  assign(f,path);
  reset(f);
  read(f,image);
  close(f);
end;

procedure Cenemy.draw_image(x, y : integer);
var i, j : integer;
begin
  for i:= 1 to 17 do
  for j:= 1 to 15 do if image[i,j].ascii<>0 then
                           putchar(i+x,j+y,image[i,j].color,image[i,j].ascii);
end;

procedure Cenemy.enemyrocket_type1;
var i, j : integer;
begin
  slwE:=slwE+1;
  if slwE=15 then begin enemy_rocketY:=enemy_rocketY-1; slwE:=0; end;

  if limit(enemy_rocketX-pos,enemy_rocketY,1,1,80,50) then
  putchar(enemy_rocketX-pos,enemy_rocketY,30,ord('Ý'));

  if (map^[enemy_rocketX,enemy_rocketY-1].color>0)or(enemy_rocketY<0) then
  begin
    enemy_rocket:=false;
    sleES:=0;
  end;
end;

procedure Cenemy.enemyrocket_type2;
var i, j : integer;
begin
  slwE:=slwE+1;
  if slwE=5 then begin enemy_rocketX:=enemy_rocketX-1; slwE:=0; end;
  putchar(enemy_rocketX-pos,enemy_rocketY,30,ord('-'));

  if (map^[enemy_rocketX+1,enemy_rocketY].color>0) then
  begin
    for i:= 1 to 3 do
    for j:= 0 to 2 do
    begin
      if sounds then sound(500);
      map^[i+enemy_rocketX,j+enemy_rocketY-1].color:=0;
      map^[i+enemy_rocketX,j+enemy_rocketY-1].ascii:=0;
    end;
    enemy_rocket:=false;
    sleES:=0;
  end;
  if (enemy_rocketX-pos<0) then begin enemy_rocket:=false; sleES:=0; end;
end;

procedure Cenemy.physics;
var i : integer;
begin
  if limit(enemyX-pos,enemyY,1,1,80,50) then
  begin {POCZATEK}

  (* ATAK NA PRZECIWNIKA i inne jednoskie    - BEGIN *)

    (* obrazenia od bomby <-- gracza atakuje *)
    if limit(bombX,bombY,enemyX+1,enemyY+1,enemyX+width,enemyY+height)
    and (bomb) and (enemy_live>0) and (enemy_type in[1..7]) then
    begin
      if (enemy_type=1) then
      begin
        enemy_live:=enemy_live-60;
        score:=score+20;
      end;
      if (enemy_type=2) then
      begin
        enemy_live:=enemy_live-80;
        score:=score+40;
      end;
      if (enemy_type=3) then enemy_live:=enemy_live-40;
      if (enemy_type=4) then enemy_live:=enemy_live-60;
      if (enemy_type=5) then
      begin
        enemy_live:=enemy_live-60;
        score:=score+30;
      end;
      if (enemy_type in[6..7]) then enemy_live:=enemy_live-50;
      if sounds then sound(1000);
      bomb:=false;
    end;
    (* obrazenia od rakiety <-- gracza atakuje  *)
    for i:= 1 to max_r do
    if limit(p[i].rocketX,p[i].rocketY,enemyX+1,enemyY+1,enemyX+width,enemyY+height)
    and (p[i].rocket) and (enemy_live>0) and (enemy_type in[1..7]) then
    begin
      if (enemy_type=1) then
      begin
        enemy_live:=enemy_live-20;
        score:=score+10;
      end;
      if (enemy_type=2) then
      begin
        enemy_live:=enemy_live-30;
        score:=score+15;
      end;
      if (enemy_type=3) then enemy_live:=enemy_live-10;
      if (enemy_type=4) then enemy_live:=enemy_live-40;
      if (enemy_type=5) then
      begin
        enemy_live:=enemy_live-40;
        score:=score+25;
      end;
      if (enemy_type in[6..7]) then enemy_live:=enemy_live-30;
      if sounds then sound(1000);
      p[i].rocket:=false;
    end;

  (* ATAK NA PRZECIWNIKA i inne jednoskie     - END *)


    (* obrazenie gracza po zderzeniu z pociskiem przeciwnika *)
    if limit(enemy_rocketX-pos,enemy_rocketY,playerX,playerY+1,playerX+9,playerY+4)
    and (enemy_rocket) and (player_live>0) then
    begin
      player_live:=player_live-10;
      if sounds then sound(1200);
      enemy_rocket:=false;
      sleES:=0;
    end;

    (* grawitacja dla przeciwnika *)
    if (not limit_map(enemyX,enemyY-1,1,2,width,height+2))
    and (not inside_in_inside(enemyX-pos,enemyY+1,1,1,7,5,
    playerX+3,playerY+2,playerX+9,playerY+4))
    and ((enemy_type=1)or(enemy_type in[5..7]))
    then
    begin
      enslow:=enslow+1;
      if enslow=20 then
      begin
        enemyY:=enemyY+1;
        down:=down+1;
        enslow:=0;
      end;
      (* jak spadnie z wysoka na ziemie *)
      if limit_map(enemyX,enemyY-1,1,2,6,6) then
        if (down>4) then
        begin
          enemy_live:=enemy_live-50;
          down:=0;
        end else down:=0;
    end;

    (* grawitacja dla przeciwnika 2 *)
    (* lot (samolot) *)
    if enemy_type=2 then
    begin
      moveE:=moveE+1;
      if moveE=20 then
      begin
        enemyX:=enemyX-1;
        moveE:=0;
      end;
    end;

    (* kolozja gracza z przeciwnikiem *)
    if enemy_live>0 then
    begin
      if (enemy_type in[1..2])or(enemy_type in[5..7]) then
      begin
        (*dol*)
        if inside_in_inside(playerX+pos,playerY+1,2,1,9,3,enemyX+1,enemyY+1,
        enemyX+width,enemyY+height) then playerY:=playerY-1;
        (*gora*)
        if inside_in_inside(playerX+pos,playerY-1,2,2,9,4,enemyX+1,enemyY+1,
        enemyX+width,enemyY+height) then playerY:=playerY+1;
        (*lewo*)
        if inside_in_inside(playerX+pos+1,playerY,2,1,8,4,enemyX+1,enemyY+1,
        enemyX+width,enemyY+height) then playerX:=playerX-1;
        (*prawo*)
        if inside_in_inside(playerX+pos-1,playerY,3,1,9,4,enemyX+1,enemyY+1,
        enemyX+width,enemyY+height) then playerX:=playerX+1;
      end;
      {paczka za z amunicja}
      if enemy_type in[3..4] then
      begin
        if inside_in_inside(playerX+pos,playerY,1,1,9,4,enemyX+1,enemyY+1,
        enemyX+width,enemyY+height) then
        begin
          enemy_live:=0;
          if sounds then sound(300);
          if enemy_type=3 then inc(player_ammo,30);
          if enemy_type=4 then
          begin
            player_liveTMP:=100-player_live;
            if 30<player_liveTMP then player_live:=player_live+30
                                 else player_live:=player_live+player_liveTMP;
          end;
        end;
      end;
    end;

    (* strzelanie przeciwnika - POCZATEK *)

    sleES:=sleES+1;

    if (enemy_type=1) then
    begin
      if (sleES=1) and not enemy_rocket and (enemy_live>0) then
      begin
        if sounds then sound(800);
        enemy_rocket:=true;
        enemy_rocketX:=enemyX+4;
        enemy_rocketY:=enemyY;
      end;

      if enemy_rocket then enemyrocket_type1;
    end;

    if (enemy_type=2)or(enemy_type=5) then
    begin
      if (sleES=1) and not enemy_rocket and (enemy_live>0) then
      begin
        if sounds then sound(800);
        enemy_rocket:=true;
        enemy_rocketX:=enemyX;
        if enemy_type=2 then enemy_rocketY:=enemyY+2;
        if enemy_type=5 then enemy_rocketY:=enemyY+1;
      end;

      if enemy_rocket then enemyrocket_type2;
    end;

    (* strzelanie przeciwnika - KONIEC *)

    (* celowanie w gracza *)
    if (enemyX-pos>playerX) and (not ground) and (enemy_type=2) then
    begin
      if (enemyY>playerY)and(enemyY>1) then
      begin
        inc(ai,1);
        if ai=60 then begin enemyY:=enemyY-1; ai:=0; end;
      end;
      if enemyY<playerY then
      begin
        inc(ai,1);
        if ai=60 then begin enemyY:=enemyY+1; ai:=0; end;
      end;

    end;

    if (limit_map(enemyX,enemyY,1,1,width,height)) and (enemy_type=2) then
    enemyX:=enemyX+1;

  end; {KONIEC}
end;

procedure draw_all_enemies;
var loop : integer;
begin
  for loop:= 1 to 50 do
  begin
    if limit(enemy[loop].enemyX-pos+enemy[loop].width,enemy[loop].enemyY+2,1,1,80+enemy[loop].width,50) then
    if enemy[loop].enemy_live>0 then enemy[loop].draw_image(enemy[loop].enemyX-pos,enemy[loop].enemyY);
  end;
end;