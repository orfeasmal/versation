program Versation;

uses
	Math,
	Raylib,
	Raymath;

type
	PEntity = ^TEntity;
	TEntity = record
		Origin: TVector2;
		Body: TRectangle;
		Velocity, Acceleration: TVector2;
		Rotation: Single;
		Gravity: Boolean;

		Texture: TTexture2D;
		Color: TColor;

		Bullets: Array of TEntity;
		BulletsCount: UInt64;
		BulletsSize: UInt64;
	end;

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

{ ENTITY }

procedure EntityUpdateGeneric(var E: TEntity);
const
	G = 500;
	FRICTION = 1.0;
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
		E.Body.Y := Height - E.Body.Height;
		E.Velocity.Y := 0.0;

		E.Velocity.X *= 1 - FRICTION * DTime;
	end;

	if E.Body.X <= 0 then
	begin
		E.Body.X := 0;
		E.Velocity.X *= -1 * 0.50;
	end
	else if E.Body.X + E.Body.Width >= Width then
	begin
		E.Body.X := Width - E.Body.Width;
		E.Velocity.X *= -1 * 0.50;
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

function AlienCreate(X: Single; Y: Single): TEntity;
const
	ALIEN_WIDTH = 100;
	ALIEN_HEIGHT = 30;
	ALIEN_COLOR = $99FF33FF;
begin
	result := Default(TEntity);
	with result do
	begin
		Body.X := X;
		Body.Y := Y;
		Body.Width := ALIEN_WIDTH;
		Body.Height := ALIEN_HEIGHT;

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
	for i := 0 to CowsCount - 1 do
	begin
		if not IsKeyDown(KEY_SPACE) then
			continue;

		Cow := @CowsArray[i];

		//if CheckCollisionRecs(A.Body, Cow^.Body) then
		//begin
			// TODO: do something
		//end;

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

	{ Gun }

function GunCreate(X, Y: Single): TEntity;
const
	GUN_WIDTH = 40;
	GUN_HEIGHT = 10;
	GUN_COLOR = $FFFFFFFF;
begin
	result := Default(TEntity);

	with result do
	begin
		Body.X := X;
		Body.Y := Y;
		Body.Width := GUN_WIDTH;
		Body.Height := GUN_HEIGHT;

		Origin.Y := GUN_HEIGHT / 2;

		Color := GetColor(GUN_COLOR);

		// Texture := GunTexture;
	end;
end;

procedure GunUpdate(var Gun: TEntity);
begin
	// TODO: Implement
end;

function FarmerCreate(X: Single): TEntity;
const
	FARMER_WIDTH = 40;
	FARMER_HEIGHT = 100;
	FARMER_COLOR = $1133CCFF;

begin
	result := Default(TEntity);

	with result do
	begin
		Body.X := X;
		Body.Y := Height - FARMER_HEIGHT;
		Body.Width := FARMER_WIDTH;
		Body.Height := FARMER_HEIGHT;

		Gravity := true;

		Color := GetColor(FARMER_COLOR);

		// Texture := FarmerTexture;
	end;
end;

procedure FarmerUpdate(var F: TEntity; var Gun: TEntity; const Alien: TEntity);
var
	GunAngle: Single;
begin
	EntityUpdateGeneric(F);

	Gun.Body.X := F.Body.X + F.Body.Width / 2;
	Gun.Body.Y := F.Body.Y + F.Body.Height / 2;

	GunAngle := FMod(ArcTan2(Alien.Body.Y - F.Body.Y, Alien.Body.X - F.Body.X), 2.0 * System.Pi);
	GunAngle *= (180 / System.Pi);
	Gun.Rotation := GunAngle;
end;

{ COW }

function CowCreate(X: Single): TEntity;
const
	COW_WIDTH = 125;
begin
	result := Default(TEntity);
	with result do
	begin
		Body.Width := COW_WIDTH;
		Body.Height := COW_WIDTH * (CowTexture.Height / CowTexture.Width);
		Body.X := X;
		Body.Y := Height - Body.Height;

		Gravity := true;
		Color := GetColor($FFFFFFFF);
		Texture := CowTexture;
	end;
end;

const
	COW_TEXTURE_PATH = 'assets/textures/cow.png';
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
	Title  := PChar('Versation');

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

	InitWindow(Width, Height, Title);

	CowTexture := LoadTexture(COW_TEXTURE_PATH);

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
			EntityUpdateGeneric(Cows[i]);
		end;

		{ REDNER }
		BeginDrawing();
		ClearBackground(BackgroundColor);

		EntityRenderColor(Alien);
		EntityRenderColor(Farmer);
		EntityRenderColorOrigin(Gun);

		for i := 0 to CowsCount - 1 do
			EntityRenderTexture(Cows[i]);

		// DrawFPS(0, 0);

		EndDrawing();
	end;

	UnloadTexture(CowTexture);

	CloseWindow();
end.
