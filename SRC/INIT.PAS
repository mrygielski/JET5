
procedure files;
procedure check(name : string);
begin
  if find_file(name) then writeln('- ',name,' OK') else
  begin writeln('- ',name,' BRAK PLIKU'); halt(1); end;
end;
begin
  writeln;
  writeln('sprawdzanie plikow:');
  check('hiscore.dat');
  check('GFX\gameover.img');
  check('gfx\victory.img');
  check('gfx\regi.img');
  check('gfx\intro.img');
  check('gfx\outro.img');
  check('gfx\menu.img');
  check('gfx\enemy1.img');
  check('gfx\enemy2.img');
  check('gfx\enemy3.img');
  check('gfx\tree1.img');
  check('gfx\tree2.img');
  check('gfx\energy.img');
  check('gfx\health.img');
  check('gfx\player.img');
  check('maps\level1.map');
  check('maps\level1.npc');
  check('maps\level2.map');
  check('maps\level2.npc');
  check('maps\level3.map');
  check('maps\level3.npc');
  check('maps\level4.map');
  check('maps\level4.npc');
  check('maps\level5.map');
  check('maps\level5.npc');
  check('maps\level6.map');
  check('maps\level6.npc');
  writeln('ALL OK');writeln;
end;

procedure init;
begin
  files;
  init3h;
  cursor(false);
  disablebgcolor(false);
  initnewkeyint;
  pos:=0;
  score:=0;
  down_terrain:=0;
end;

procedure done;
begin
  if sounds then nosound;
  setoldkeyint;
  close3h;
  writeln('JET 5 by Michal Rygielski /REGi/');
  writeln('COMPO GAME 11.02.2005-20.02.2005');
  writeln('http://ggate.prv.pl');
  writeln('email:regi007@o2.pl');
end;

procedure loading_enemies(name : string);
var
   i : integer;
   f : file of Txy;
   enemy_pos : Txy;
begin
  assign(f,name);
  reset(f);
  read(f,enemy_pos);
  close(f);

  for i:= 1 to 50 do
  begin
    enemy[i].load_image('GFX\'+image_files[enemy_pos[i].nr]);

    enemy[i].enemyX:=enemy_pos[i].x;
    enemy[i].enemyY:=enemy_pos[i].y;
    enemy[i].enslow:=0;
    enemy[i].ai:=0;
    enemy[i].enemy_rocket:=false;
    enemy[i].enemy_hide:=true;
    enemy[i].slwE:=0;
    enemy[i].sleES:=0;
    enemy[i].moveE:=9;
    enemy[i].enemy_rocketX:=0;
    enemy[i].enemy_rocketY:=0;

    if enemy_pos[i].nr=1 then
    begin
      enemy[i].enemy_type:=1;
      enemy[i].width:=6;
      enemy[i].height:=4;
      enemy[i].enemy_live:=100;
    end;
    if enemy_pos[i].nr=2 then
    begin
      enemy[i].enemy_type:=2;
      enemy[i].width:=8;
      enemy[i].height:=3;
      enemy[i].enemy_live:=100;
    end;
    if enemy_pos[i].nr=3 then
    begin
      enemy[i].enemy_type:=3;
      enemy[i].width:=3;
      enemy[i].height:=3;
      enemy[i].enemy_live:=1;
    end;
    if enemy_pos[i].nr=4 then
    begin
      enemy[i].enemy_type:=4;
      enemy[i].width:=3;
      enemy[i].height:=3;
      enemy[i].enemy_live:=1;
    end;
    if enemy_pos[i].nr=5 then
    begin
      enemy[i].enemy_type:=5;
      enemy[i].width:=6;
      enemy[i].height:=4;
      enemy[i].enemy_live:=100;
    end;
    if enemy_pos[i].nr=6 then
    begin
      enemy[i].enemy_type:=6;
      enemy[i].width:=5;
      enemy[i].height:=6;
      enemy[i].enemy_live:=100;
    end;
    if enemy_pos[i].nr=7 then
    begin
      enemy[i].enemy_type:=7;
      enemy[i].width:=3;
      enemy[i].height:=6;
      enemy[i].enemy_live:=100;
    end;
  end;

end;

procedure load_map(path : string);
begin
  new(map);
  assign(f,path+'.map');
  reset(f);
  read(f,map^);
  close(f);
  loading_enemies(path+'.npc');
end;

procedure hiscore_up;
begin
  insert_sort;
  if score>hiscore[10].score then
  begin
    cls(1);
    bar(30,20,50,28,9);
    printxy(35,22,16*9,'PODAJ IMIE:');
    refresh;
    setoldkeyint;
    readtext(32,25,16*9+14,9,10,name);
    initnewkeyint;
    hiscore[10].score:=score;
    hiscore[10].name:=name;
    insert_sort;
    assign(fh,'hiscore.dat');
    rewrite(fh);
    write(fh,hiscore);
    close(fh);
    nr_level:=1;
  end;
end;

(******************* NAJWAZNIEJSZA PROCEDURA *****************************)
procedure play_level(path : string);
begin
  load_map(path);
  load_image('GFX\player.img',player);
  player_init;
  repeat
        draw_terrain(pos);

        draw_all_enemies;

        if limit(playerX+8,playerY+2,1,1,80,50) then
        if player_live>0 then draw_image(playerX,playerY,player) else
        out_screen:=true;

        if out_screen then
        begin
          draw_image_big(22,7,big_img[1]);
          printxy(31,28,30,'PRESS ENTER KEY...');
        end;
        { PRZESOWANIE TERENU }
        if pos<480 then
        begin
          slow:=slow+1;
          if slow=20 then begin pos:=pos+1; slow:=0; end;
        end else
        if (player_live>0) then
        begin
          slow:=slow+1;
          if slow=5 then begin if playerX<85 then playerX:=playerX+1; slow:=0; end;
          if (playerX>=85) then
          begin
            level_completed:=true;
            draw_image_big(22,7,big_img[2]);
            printxy(33,26,30,'PRESS ENTER KEY...');
          end;
        end;

        printxy(2,2,25,'PUNKTY='+num2str(score));
        printxy(80-length('POZIOM '+num2str(nr_level)+'/'+num2str(max_level)),
        2,25,'POZIOM '+num2str(nr_level)+'/'+num2str(max_level));

        if player_ammo>0 then printxy(2,46,206,'POCISKI='+num2str(player_ammo))
        else printxy(2,46,196,'POCISKI='+num2str(player_ammo)+' BRAK AMUNICJI!!');

        printxy(2,47,206,'ZYCIE='+num2str(player_live));
        bar(2,48,30,49,7);
        bar(2,48,(30*player_live) div 100,49,4);

        refresh;


        cls(1);{delay(150);}
        if sounds then nosound;

        { GRACZ }
        player_keyboard;
        player_collision;
        draw_b_r;

        { FIZYKA PRZECIWNIKA }
        for loop:= 1 to 50 do enemy[loop].physics;

        if level_completed and keydown[entscan] then
        begin
          nr_level:=nr_level+1;
          done_level:=true;
        end;
        if out_screen and keydown[entscan] then
        begin
         nr_level:=1;
         dead:=true;
        end;
        if keydown[escscan] then
        begin
          nr_level:=1;
          done_level:=true;
        end;
  until done_level or dead;
  if dead then hiscore_up; {sprawdz czy wpisac na liste wynikow}
  loop:=0;
  repeat inc(loop); cls(0); refresh; until loop=200;
  dispose(map);
end;

procedure loadImages;
begin
  load_image_big('gfx\gameover.img',big_img[1]);
  load_image_big('gfx\victory.img',big_img[2]);
  load_image_big('gfx\regi.img',big_img[3]);
  load_image_large('gfx\intro.img',intro);
  load_image_large('gfx\outro.img',outro);
  load_image_large('gfx\menu.img',menu);
end;

procedure introGAME;
var i : integer;
begin
  draw_image_intro(20,10,big_img[3]);
  printxy(33,30,14,'przedstawia');
  i:=0;
  repeat i:=i+1; refresh; until i=2000;
  draw_image_large(intro);
  i:=0;
  repeat i:=i+1; refresh; until i=2000;
end;

procedure outroGAME;
var i : integer;
begin
  i:=0;
  draw_image_large(outro);
  repeat i:=i+1; refresh; until i=2000;
end;

procedure GAMEMENU;

procedure show_hi;
begin
  bar(50,6,75,18,1);
  printxy(60,6,28,'TOP 10');

  for loop:= 1 to 10 do
  begin
    if loop<10 then printxy(51,7+loop,30,'0'+num2str(loop)+'. '+hiscore[loop].name) else
    printxy(51,7+loop,30,num2str(loop)+'. '+hiscore[loop].name);
    printxy(75-length(num2str(hiscore[loop].score)),7+loop,30,num2str(hiscore[loop].score));
  end;
end;
var
   ymenu, t1, t2 : byte;
begin

  assign(fh,'hiscore.dat');
  reset(fh);
  read(fh,hiscore);
  close(fh);

  draw_image_large(menu);
  show_hi;
  ymenu:=0;
  t1:=0;
  t2:=0;
  exit_game:=false;

  nr_level:=1;
  repeat
    printxy(10,22+ymenu*7+2,94,'>>');
    refresh;
    printxy(10,22+ymenu*7+2,16*9+1,'±±');
    if (ymenu=0)and(keydown[entscan]) then
    begin
      score:=0;
      player_ammo:=150;
      level_completed:=false;
      done_level:=false;
      dead:=false;
      exit_game:=false;
      max_level:=6;
      if nr_level=1 then play_level('MAPS\level1');
      if nr_level=2 then play_level('MAPS\level2');
      if nr_level=3 then play_level('MAPS\level3');
      if nr_level=4 then play_level('MAPS\level4');
      if nr_level=5 then play_level('MAPS\level5');
      if nr_level=6 then play_level('MAPS\level6');
      if nr_level=7 then begin hiscore_up; outroGAME; end;
      draw_image_large(menu);
      show_hi;
    end;
    if (ymenu=2)and(keydown[entscan]) then exit_game:=true;
    if (ymenu=1)and(keydown[entscan]) then
    begin
      bar(53,28,72,36,1);
      printxy(60,29,16*1+12,'AUTOR');
      printxy(55,31,16*1+11,'Michal Rygielski');
      printxy(60,32,16*1+11,'/REGi/');
      printxy(54,34,16*1+9,'regi007@o2.pl');
      printxy(54,35,16*1+9,'ggate.prv.pl');
    end;
    if keydown[upscan] then
    begin
      inc(t1);
      if t1=80 then
        if ymenu>0 then
        begin
          dec(ymenu);
          t1:=0;
        end;
    end;
    if keydown[downscan] then
    begin
      inc(t2);
      if t2=80 then
        if ymenu<2 then
        begin
          inc(ymenu);
          t2:=0;
        end;
    end;
  until exit_game;
end;