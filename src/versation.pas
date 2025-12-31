//{$mode FPC}
{$H+}

program Versation;

uses
	Math,
	SysUtils,
	Raylib,
	Raymath;

type
	TEntityType = (
		ENTITY_ALIEN,
		ENTITY_COW,
		ENTITY_FARMER,
		ENTITY_GUN,
		ENTITY_BULLET
	);

	TEntity = record
		Id: UInt64;
		EntityType: TEntityType;

		RenderProcedure: procedure (const Entity: TEntity);

		Body: TRectangle;
		Origin: TVector2;
		Velocity, Acceleration: TVector2;
		Rotation: Single;

		Texture: TTexture2D;
		Color: TColor;

		Gravity: Boolean;
		OnGround: Boolean;

		Score: Integer;
		ScoreStr: AnsiString;
		Timer: Single;

		Bullets: Array of TEntity;
		BulletsCount: UInt64;
		BulletsSize: UInt64;
	end;
	PEntity = ^TEntity;

var
	i, j: Int64;
	Width, Height: Integer;
	Title: PChar;
	BackgroundColor: TColor;

	DTime: Double;

	CowTexture: TTexture2D;
	// AlienTexture: TTexture2D;
	// FarmerTexture: TTexture2D;
	// GunTexture: TTexture2D;

	Font: TFont;

{ ENTITY }

procedure EntityUpdateGeneric(var E: TEntity);
const
	G = 500;
	FRICTION = 1.0;
	BOUNCE_VELOCITY_LOSS = 0.7;
begin
	if E.Gravity then
	begin
		E.Velocity.Y += G * DTime;
	end
	else
		E.Velocity.X *= 1 - FRICTION * DTime;

	E.Velocity.X += E.Acceleration.X * DTime;
	E.Velocity.Y += E.Acceleration.Y * DTime;

	E.Body.X += E.Velocity.X * DTime;
	E.Body.Y += E.Velocity.Y * DTime;

	if E.Body.Y + E.Body.Height >= Height then
	begin
		E.OnGround := true;

		E.Body.Y := Height - E.Body.Height;
		// E.Velocity.Y := 0.0;
		E.Velocity.Y *= -1 * (1 - BOUNCE_VELOCITY_LOSS);

		E.Velocity.X *= 1 - (FRICTION * DTime);
	end
	else
		E.OnGround := false;

	if E.Body.X <= 0 then
	begin
		E.Body.X := 0;
		E.Velocity.X *= -1 * (1 - BOUNCE_VELOCITY_LOSS);
	end
	else if E.Body.X + E.Body.Width >= Width then
	begin
		E.Body.X := Width - E.Body.Width;
		E.Velocity.X *= -1 * (1 - BOUNCE_VELOCITY_LOSS);
	end;
end;

procedure EntityRenderColor(const E: TEntity);
begin
	DrawRectangleRec(E.Body, E.Color);
end;

procedure EntityRenderColorOrigin(const E: TEntity);
begin
	DrawRectanglePro(E.Body, E.Origin, E.Rotation, E.Color);
end;

procedure EntityRenderScore(const E: TEntity);
const
	Position: TVector2 = (X: 0; Y: 0);
begin
	DrawTextEx(Font, PChar(E.ScoreStr), Position, 32, 1.0, GetColor($FFFFFFFF));
end;

procedure EntityRenderTexture(const E: TEntity);
const
	Origin: TVector2 = (X: 0; Y: 0);
var
	Source: TRectangle;
begin
	with Source do
	begin
		X := 0;
		Y := 0;

		Width := E.Texture.Width;

		Height := Single(E.Texture.Height);
	end;

	if E.Velocity.X >= 0 then
		Source.Width *= -1;

	DrawTexturePro(E.Texture, Source, E.Body, Origin, E.Rotation, E.Color);
end;

{ ALIEN }

function AlienCreate(X, Y: Single): TEntity;
const
	ALIEN_WIDTH = 100;
	ALIEN_HEIGHT = 30;
	ALIEN_COLOR = $99FF33FF;
begin
	AlienCreate := Default(TEntity);
	with AlienCreate do
	begin
		RenderProcedure := @EntityRenderColor;

		EntityType := ENTITY_ALIEN;
		Body.X := X;
		Body.Y := Y;
		Body.Width := ALIEN_WIDTH;
		Body.Height := ALIEN_HEIGHT;

		ScoreStr := 'Score: 0';

		Color := GetColor(ALIEN_COLOR);
		// Texture := AlienTexture;
	end;
end;

procedure AlienUpdate(var A: TEntity; var CowsArray: Array of TEntity; var CowsCount: UInt64);
const
	ACC = 1000.0;
	VELX_MAX = 1000.0;
	COW_ACC = 600.0;
var
	Cow: PEntity;
	AlienCowPosDifference: TVector2;
begin
	i := 0;
	while i < CowsCount do
	begin
		Cow := @CowsArray[i];

		if CheckCollisionRecs(A.Body, Cow^.Body) then
		begin
			A.Score += 10;
			A.ScoreStr := Format('Score: %d', [A.Score]);

			Cow^ := CowsArray[CowsCount - 1];
			CowsCount -= 1;

			continue;
		end;

		i += 1;

		if not IsKeyDown(KEY_SPACE) then
			continue;

		if (Cow^.Body.X + Cow^.Body.Width < A.Body.X) or
			(Cow^.Body.X > A.Body.X + A.Body.Width) or
			(Cow^.Body.Y < A.Body.Y + A.Body.Height) then
			continue;

		with AlienCowPosDifference do
		begin
			X := (A.Body.X + (A.Body.Width / 2)) - (Cow^.Body.X + (Cow^.Body.Width / 2));
			Y := (A.Body.Y + (A.Body.Height / 2)) - (Cow^.Body.Y + (Cow^.Body.Height / 2));
		end;

		Cow^.Velocity := Vector2Add(
			Cow^.Velocity,
			Vector2Scale(
				Vector2Normalize(AlienCowPosDifference),
				COW_ACC * DTime
			)
		);
	end;

	if IsKeyDown(KEY_A) then
		A.Velocity.X -= ACC * DTime;

	if IsKeyDown(KEY_D) then
		A.Velocity.X += ACC * DTime;

	if Abs(A.Velocity.X) >= VELX_MAX then
	begin
		A.Velocity.X := Sign(A.Velocity.X) * VELX_MAX;
	end;

	EntityUpdateGeneric(A);
end;

{ FARMER }

function GunCreate(X, Y: Single): TEntity;
const
	GUN_WIDTH = 50;
	GUN_HEIGHT = 10;
	GUN_COLOR = $FFFFFFFF;
begin
	GunCreate := Default(TEntity);

	with GunCreate do
	begin
		EntityType := ENTITY_GUN;

		Origin.Y := GUN_HEIGHT / 2;
		Body.X := X;
		Body.Y := Y;
		Body.Width := GUN_WIDTH;
		Body.Height := GUN_HEIGHT;

		BulletsSize := 32;
		SetLength(Bullets, BulletsSize);

		Color := GetColor(GUN_COLOR);

		// Texture := GunTexture;

		RenderProcedure := @EntityRenderColorOrigin;
	end;
end;

procedure GunShootBullet(var Gun: TEntity);
begin
	//WriteLn('Bullet Shot');
end;

procedure GunUpdate(var Gun: TEntity);
begin
	Gun.Timer += DTime;
	if Gun.Timer >= 1 then
	begin
		Gun.Timer := 0;
		GunShootBullet(Gun);
	end;
end;

function FarmerCreate(X: Single): TEntity;
const
	FARMER_WIDTH = 40;
	FARMER_HEIGHT = 100;
	FARMER_COLOR = $1133CCFF;

begin
	FarmerCreate := Default(TEntity);

	with FarmerCreate do
	begin
		EntityType := ENTITY_FARMER;
		Body.X := X;
		Body.Y := Height - FARMER_HEIGHT;
		Body.Width := FARMER_WIDTH;
		Body.Height := FARMER_HEIGHT;

		Gravity := true;

		Color := GetColor(FARMER_COLOR);

		// Texture := FarmerTexture;

		RenderProcedure := @EntityRenderColor;
	end;
end;

procedure FarmerUpdate(var F: TEntity; var Gun: TEntity; const Alien: TEntity);
const
	FARMER_VELOCITY_FACTOR = 1 / 6;
	GUN_ANGLE_VELOCITY_FACTOR = 1 / 25;
var
	AlienGunAngle: Single;
	AlienFarmerPosXDifference: Single;
begin
	EntityUpdateGeneric(F);

	AlienFarmerPosXDifference := (Alien.Body.X + (Alien.Body.Width / 2)) - (F.Body.X + (F.Body.Width / 2));

	F.Velocity.X := AlienFarmerPosXDifference * FARMER_VELOCITY_FACTOR;

	Gun.Body.X := F.Body.X + F.Body.Width / 2;
	Gun.Body.Y := F.Body.Y + F.Body.Height / 2;

	AlienGunAngle := FMod(ArcTan2(Alien.Body.Y - F.Body.Y, Alien.Body.X - F.Body.X), 2.0 * System.Pi);
	AlienGunAngle *= (180 / System.Pi);
	Gun.Rotation += (AlienGunAngle - Gun.Rotation) * GUN_ANGLE_VELOCITY_FACTOR;
end;

{ COW }

function CowCreate(X: Single): TEntity;
const
	COW_WIDTH = 115;
begin
	CowCreate := Default(TEntity);
	with CowCreate do
	begin
		RenderProcedure := @EntityRenderTexture;

		EntityType := ENTITY_COW;
		Body.Width := COW_WIDTH;
		Body.Height := COW_WIDTH * (CowTexture.Height / CowTexture.Width);
		Body.X := X;
		Body.Y := Height - Body.Height;

		Gravity := true;
		Color := GetColor($FFFFFFFF);
		Texture := CowTexture;
	end;
end;

procedure CowUpdate(var Cow: TEntity; SelfIndexInArray: UInt64; var CowsArray: Array of TEntity; CowsCount: UInt64);
const
	COW_STEP_VEL = 100;
	STEP_DELAY_SEC = 1.0;
begin
	Cow.Timer += DTime;
	if Cow.OnGround and (Cow.Timer >= 1 + Random(100) / 10) then
	begin
		Cow.Timer := 0;
		Cow.Velocity.X += COW_STEP_VEL * (-1 + Random(3));
	end;

	EntityUpdateGeneric(Cow);
end;

const
	COW_TEXTURE_PATH = 'assets/textures/cow.png';
	FONT_PATH = 'assets/fonts/Ac437_IBM_VGA_8x16.ttf';
	COWS_INITIAL_COUNT = 10;
	ALIEN_Y = 10.0;
var
	RefreshRate: Integer;
	Alien: TEntity;
	Farmer: TEntity;
	Gun: TEntity;

	Cows: Array of TEntity;
	CowsCount: UInt64;
	CowsSize: UInt64;
begin
	Randomize;

	Width  := 1280;
	Height := 720;
	Title  := 'Versation';

	BackgroundColor := GetColor($000000FF);

	RefreshRate := GetMonitorRefreshRate(GetCurrentMonitor());
	if RefreshRate > 0 then
	begin
		SetTargetFPS(RefreshRate);
	end
	else
		SetTargetFPS(60);

	CowsCount := 0;
	CowsSize := 16;
	SetLength(Cows, CowsSize);

	Alien := AlienCreate(Random(Width - 100), ALIEN_Y);
	Gun := GunCreate(Random(Width), Random(Height));
	Farmer := FarmerCreate(Gun.Body.X);

	// SetConfigFlags(FLAG_MSAA_4X_HINT); // Anti-Aliasing
	InitWindow(Width, Height, Title);

	CowTexture := LoadTexture(PChar(AnsiString(COW_TEXTURE_PATH)));
	Font := LoadFont(PChar(AnsiString(FONT_PATH)));

	while CowsCount < COWS_INITIAL_COUNT do
	begin
		CowsCount += 1;

		if CowsCount = CowsSize then
		begin
			CowsSize *= 2;
			SetLength(Cows, CowsSize);
		end;

		Cows[CowsCount - 1] := CowCreate(Random(Width));
	end;

	while not WindowShouldClose() do
	begin
		{ UPDATE }
		DTime := GetFrameTime();

		AlienUpdate(Alien, Cows, CowsCount);
		FarmerUpdate(Farmer, Gun, Alien);
		GunUpdate(Gun);

		for i := 0 to CowsCount - 1 do
		begin
			CowUpdate(Cows[i], i, Cows, CowsCount);
		end;

		{ REDNER }
		BeginDrawing();
		ClearBackground(BackgroundColor);

		Alien.RenderProcedure(Alien);

		for i := 0 to CowsCount - 1 do
			Cows[i].RenderProcedure(Cows[i]);

		Farmer.RenderProcedure(Farmer);
		Gun.RenderProcedure(Gun);

		// HUD
		EntityRenderScore(Alien);

		// DrawFPS(0, 0);

		EndDrawing();
	end;

	UnloadFont(Font);
	UnloadTexture(CowTexture);

	CloseWindow();
end.
