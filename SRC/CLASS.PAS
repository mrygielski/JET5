
const
     brand : array[1..3] of byte = (177,176,178);
     crand : array[1..3] of byte = (8,7,120);
     image_files : array[1..7] of string[12] =
     ('enemy1.img','enemy2.img','energy.img','health.img','enemy3.img',
      'tree1.img','tree2.img');

type
    Tmap = array[1..560,1..50] of record ascii, color : byte; end;
    Timage = array[1..17,1..15] of record ascii, color : byte; end;
    Timage_big = array[1..40,1..20] of record ascii, color : byte; end;
    Timage_large = array[1..80,1..50] of record ascii, color : byte; end;
    Txy = array[1..50] of record x, y : integer; nr : byte; end;
    Thiscore = array[1..10] of record name : string[10]; score : longint; end;

    Crocket = object
                private
                  slwP, rocketX, rocketY : integer;
                  rocket : boolean;

                public
                  procedure rocket_fly;
              end;

    Cenemy = object
               private
                 image : Timage;
                 enemy_type : byte;
                 enemyX, enemyY, enslow : integer;
                 enemy_hide : boolean;
                 enemy_live : integer;
                 slwE, sleES, moveE, enemy_rocketX, enemy_rocketY : integer;
                 enemy_rocket : boolean;
                 width, height : byte;
                 down : byte;
                 ai : byte;

               public
                 procedure load_image(path : string);
                 procedure draw_image(x, y : integer);
                 procedure enemyrocket_type1;
                 procedure enemyrocket_type2;
                 procedure physics;
             end;

var
   (* MAPA *)
   map : ^Tmap;
   f : file of Tmap;
   down_terrain : integer;
   pos : word;

   (* KLAWIATURA *)
   s1, s2, s3, s4, slow : integer;

   (* GRACZ *)
   player : Timage;
   playerX, playerY : integer;
   player_live, player_liveTMP, player_ammo : integer;
   nr : byte; {nr pocisku}
   p : array[1..15] of Crocket; {maxymalna ilosc pociskow}
   slwB, bombX, bombY : integer;
   nrbomb : byte;
   bomb : boolean;
   ps : byte;
   max_r : byte; {ilosc pociskow}
   delay_ : byte; {opoznienie pocisku}
   out_screen : boolean;
   ground : boolean;

   (* PRZECIWNIK *)
   enemy : array[1..50] of Cenemy;

   (* inne *)
   loop : integer;
   sounds : boolean;
   big_img : array[1..4] of Timage_big;
   intro, outro, menu : Timage_large;

   score : longint;
   fh : file of Thiscore;
   hiscore : Thiscore;
   name : string;
   level_completed, done_level, dead, exit_game : boolean;
   nr_level, max_level : byte;