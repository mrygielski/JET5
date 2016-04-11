
(* JET 5                       *)
(* autor: Michal Rygielski     *)
(* regi007@o2.pl               *)
(*!WSZELKIE PRAWA ZASTRZERZONE!*)

uses rcrt, games;

{$I CLASS.PAS}
{$I OTHER.PAS}
{$I TERRAIN.PAS}
{$I PLAYER.PAS}
{$I ENEMY.PAS}
{$I INIT.PAS}

begin

  init;

  if system.pos('nosound',paramstr(1))=1 then sounds:=false else sounds:=true;

  loadImages;

  introGAME;

  GAMEMENU;

  done;

end.