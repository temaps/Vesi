{
"Весы" - программа для изучения состава числа и сложения однозначных чисел

Copyright 2016 Проскурнев Артем Сергеевич

Этот файл — часть программы Весы.

Весы - свободная программа: вы можете перераспространять ее и/или
изменять ее на условиях Стандартной общественной лицензии GNU в том виде,
в каком она была опубликована Фондом свободного программного обеспечения;
либо версии 3 лицензии, либо (по вашему выбору) любой более поздней
версии.

Весы распространяется в надежде, что она будет полезной,
но БЕЗО ВСЯКИХ ГАРАНТИЙ; даже без неявной гарантии ТОВАРНОГО ВИДА
или ПРИГОДНОСТИ ДЛЯ ОПРЕДЕЛЕННЫХ ЦЕЛЕЙ. Подробнее см. в Стандартной
общественной лицензии GNU.

Вы должны были получить копию Стандартной общественной лицензии GNU
вместе с этой программой. Если это не так, см.
<http://www.gnu.org/licenses/>.

This file is part of Vesi.

Vesi is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Vesi is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Vesi.  If not, see <http://www.gnu.org/licenses/>.
}
unit vesiglav;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, LCLType, Buttons;

type
  TChashka = record
    x, y, r, k, s: integer;
    c: array[1..100] of integer;
    b: set of byte;
  end;

  { TFVesi }

  TFVesi = class(TForm)
    pole: TImage;
    SpeedButton1: TSpeedButton;
    Timer1: TTimer;
    procedure chisloMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure chisloMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure chisloMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure polePaint(Sender: TObject);
    procedure poleResize(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    ugol: real;
    cmove: boolean;
    xo, yo, xch, ych, kolc, xgc, ygc: integer;
    lchislo: TLabel;
    achislo: array[1..100] of TLabel;
    chashka, chashkap: array[1..2] of TChashka;
    { private declarations }
  public
    { public declarations }
  end;

var
  FVesi: TFVesi;

implementation

uses Math, vesiabout;

{$R *.lfm}

{ TFVesi }

procedure TFVesi.polePaint(Sender: TObject);
var
  x, y, rx, ry, xc, yc, l, xkl, ykl, xkp, ykp, i, step2, j: integer;
begin
  x := pole.Width div 2;
  y := pole.Height;
  rx := pole.Width div 25;
  if rx < 1 then
    rx := 1;
  ry := pole.Height div 20;
  if ry < 1 then
    ry := 1;
  xc := x;
  yc := pole.Height div 3;
  l := pole.Width div 4;
  xkl := round(xc + l * cos(ugol + pi));
  ykl := round(yc + l * sin(ugol + pi));
  xkp := round(xc + l * cos(ugol));
  ykp := round(yc + l * sin(ugol));

  pole.Canvas.Pen.Width := 3;
  pole.Canvas.Brush.Color:=RGBToColor(94,79,38);
  pole.Canvas.Pen.Color:=RGBToColor(94,79,38);

  pole.Canvas.Line(xc, yc, xkp, ykp);
  pole.Canvas.Line(xc, yc, xkl, ykl);

  pole.Canvas.Rectangle(x - rx,y,x + rx,yc);
  pole.Canvas.Line(x - rx, y, x + rx, y);
  pole.Canvas.Line(x - rx, y, x - rx, yc);
  pole.Canvas.Line(x + rx, y, x + rx, yc);

  pole.Canvas.Pen.Color:=RGBToColor(68,202,91);
  pole.Canvas.Ellipse(x - rx, yc - rx, x + rx, yc + rx);
  pole.Canvas.Pen.Color:=RGBToColor(94,79,38);

  pole.Canvas.Pen.Width := 1;

  chashka[1].x := xkl;
  chashka[1].y := ykl;
  chashka[1].r := ry;
  chashka[2].x := xkp;
  chashka[2].y := ykp;
  chashka[2].r := ry;
  for j := 1 to 2 do
  begin
    if chashka[j].k = 1 then
    begin
      achislo[chashka[j].c[1]].Left :=
        chashka[j].x - achislo[chashka[j].c[1]].Width div 2;
      achislo[chashka[j].c[1]].Top :=
        chashka[j].y - achislo[chashka[j].c[1]].Height div 2;
    end;
    if chashka[j].k > 1 then
    begin
      if chashka[j].k = 2 then
        step2 := 2
      else
        step2 := trunc(ln(chashka[j].k - 1) / ln(2)) + 1;
      chashka[j].r := ry * step2;
      for i := 1 to chashka[j].k do
      begin
        if (i > 0) and (i < chashka[j].k) and
          (length(achislo[chashka[j].c[i]].Caption) = 1) then
          achislo[chashka[j].c[i]].Caption := achislo[chashka[j].c[i]].Caption + '+';
        if (i < chashka[j].k) or (i mod step2=1) then
          achislo[chashka[j].c[i]].Left :=
            chashka[j].x + achislo[chashka[j].c[i]].Width *
            (((i - 1) mod step2) - (step2 div 2)) -
            (achislo[chashka[j].c[i]].Width div 2) * (step2 mod 2)
        else
          achislo[chashka[j].c[i]].Left :=
            achislo[chashka[j].c[i - 1]].Left + achislo[chashka[j].c[i - 1]].Width;
        achislo[chashka[j].c[i]].Top :=
          chashka[j].y + achislo[chashka[j].c[i]].Height *
          (((i - 1) div step2) - (step2 div 2)) -
          (achislo[chashka[j].c[i]].Height div 2) * (step2 mod 2);
      end;
    end;
    pole.Canvas.Brush.Color:=RGBToColor(219,243,246);
    pole.Canvas.Ellipse(chashka[j].x - chashka[j].r, chashka[j].y -
      chashka[j].r, chashka[j].x + chashka[j].r,
      chashka[j].y + chashka[j].r);
  end;
  if cmove then
  begin
    pole.Canvas.Font := lchislo.Font;
    //pole.Canvas.Brush.Style := bsClear;
    pole.Canvas.TextOut(xgc, ygc, lchislo.Caption);
  end;
  //pole.Canvas.Ellipse(xkp - ry, ykp - ry, xkp + ry, ykp + ry);
end;

procedure TFVesi.poleResize(Sender: TObject);
var
  i: integer;
begin
  Randomize;
  for i := 1 to kolc do
  begin
    achislo[i].Font.Size := FVesi.Height div 25;
    if not ((i in chashka[1].b) or (i in chashka[2].b)) then
    begin
      achislo[i].Top := FVesi.Height -(FVesi.Height div 20) - 46 - Random(FVesi.Height div 3);
      achislo[i].Left := Random(FVesi.Width - 30);
    end;
  end;
  pole.Invalidate;
  //pole.Canvas.Ellipse(0,0,pole.Width,pole.Height);
end;

procedure TFVesi.SpeedButton1Click(Sender: TObject);
begin
  Aboutformvesi.Show;
end;

procedure TFVesi.Timer1Timer(Sender: TObject);
begin
  if chashka[1].s = chashka[2].s then
  begin
    if ugol <> 0 then
    begin
      ugol := ugol - Sign(ugol) * pi / 180;
      if (ugol > -pi / 180) and (ugol < pi / 180) then
        ugol := 0;
      pole.Repaint;
    end;
  end
  else
  begin
    if abs(ugol) < pi / 8 then
    begin
      ugol := ugol - Sign(chashka[1].s - chashka[2].s) * pi / 180;
      pole.Repaint;
    end;
  end;
end;

procedure TFVesi.FormCreate(Sender: TObject);
var
  i: integer;
begin
  kolc := 40;
  ugol := 0;
  cmove := False;
  Randomize;
  for i := 1 to kolc do
  begin
    achislo[i] := TLabel.Create(FVesi);
    if i < 10 then
      achislo[i].Caption := IntToStr(i)
    else
      achislo[i].Caption := IntToStr(Random(10));
    achislo[i].Font.Size := FVesi.Height div 25;
    achislo[i].Font.Color := RGBToColor(random(128), random(128), random(128));
    achislo[i].Top := FVesi.Height - 46 - Random(FVesi.Height div 3);
    achislo[i].Left := Random(FVesi.Width - 30);
    achislo[i].Tag := i;
    achislo[i].Parent := FVesi;
    achislo[i].OnMouseDown := @chisloMouseDown;
    achislo[i].OnMouseMove := @chisloMouseMove;
    achislo[i].OnMouseUp := @chisloMouseUp;
  end;
end;

procedure TFVesi.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  if Key=VK_F1 then Aboutformvesi.Show;
end;

procedure TFVesi.FormResize(Sender: TObject);
var
  i: integer;
begin
{  Randomize;
  for i := 1 to kolc do
  begin
    achislo[i].Font.Size := FVesi.Height div 25;
    if not ((i in chashka[1].b) or (i in chashka[2].b)) then
    begin
      achislo[i].Top := FVesi.Height - 46 - Random(FVesi.Height div 3);
      achislo[i].Left := Random(FVesi.Width - 30);
    end;
  end;
  pole.Canvas.Ellipse(0,0,pole.Width,pole.Height);}
end;

procedure TFVesi.chisloMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  i, j: integer;
  f: boolean;
begin
  xo := X;
  yo := Y;
  lchislo := (Sender as TLabel);
  xch := lchislo.Left;
  ych := lchislo.Top;
  if length(lchislo.Caption) = 2 then
    lchislo.Caption := copy(lchislo.Caption, 1, 1);
  for j := 1 to 2 do
  begin
    if lchislo.Tag in chashka[j].b then
    begin
      chashka[j].b := chashka[j].b - [lchislo.Tag];
      f := False;
      for i := 1 to chashka[j].k - 1 do
      begin
        if chashka[j].c[i] = lchislo.Tag then
          f := True;
        if f then
          chashka[j].c[i] := chashka[j].c[i + 1];
      end;
      Dec(chashka[j].k);
      if chashka[j].k > 0 then
      begin
        if length(achislo[chashka[j].c[chashka[j].k]].Caption) = 2 then
          achislo[chashka[j].c[chashka[j].k]].Caption :=
            copy(achislo[chashka[j].c[chashka[j].k]].Caption, 1, 1);
      end;
      chashka[j].s := chashka[j].s - StrToInt(lchislo.Caption);
      ugol := ugol - Sign(ugol) * pi / 180;
    end;
  end;
  cmove := True;
end;

procedure TFVesi.chisloMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
begin
  if cmove then
  begin
    if lchislo.Visible then
      lchislo.Visible := False;
    xgc := X - xo + xch;
    ygc := Y - yo + ych;
    pole.Repaint;
    {pole.Canvas.Line(0,0,pole.Width,pole.Height);
    label1.Caption:=inttostr(pole.Canvas.Height);}
  end;
end;

procedure TFVesi.chisloMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  j: integer;
begin
  lchislo.Left := X - xo + xch;
  lchislo.Top := Y - yo + ych;
  for j := 1 to 2 do
  begin
    if sqr(x + xch - chashka[j].x) + sqr(y + ych - chashka[j].y) <=
      sqr(chashka[j].r) then
    begin
      Inc(chashka[j].k);
      chashka[j].c[chashka[j].k] := lchislo.Tag;
      chashka[j].b := chashka[j].b + [lchislo.Tag];
      chashka[j].s := chashka[j].s + StrToInt(lchislo.Caption);
      ugol := ugol - Sign(ugol) * pi / 180;
      pole.Repaint;
    end;
  end;
  lchislo.Visible := True;
  cmove := False;
end;

procedure TFVesi.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  i: integer;
begin
  {for i := 1 to kolc do
    achislo[i].Free;}
end;

end.
