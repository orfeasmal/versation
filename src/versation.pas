program Versation;

uses
	Math,
	Raylib,
	Raymath;

type
	TEntity = record
		Body: TRectangle;
		Velocity, Acceleration: TVector2;
		Rotation: Single;
		Color: TColor;

		Gravity: Boolean;

		Texture: TTexture2D;
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

	Cows: array of TEntity;
	CowsCount: UInt64;
	CowsSize: UInt64;

{ ENTITY }

procedure EntityUpdateGeneric(var E: TEntity);
const
	G = 500;
begin
	if E.Gravity then
		E.Velocity.Y += G * DTime;

	E.Velocity.X += E.Acceleration.X * DTime;
	E.Velocity.Y += E.Acceleration.Y * DTime;

	E.Body.X += E.Velocity.X * DTime;
	E.Body.Y += E.Velocity.Y * DTime;

	if E.Body.Y + E.Body.Height >= Height then
	begin
		E.Body.Y := Height - E.Body.Height;
		E.Velocity.Y := 0.0;
	end;
end;

procedure EntityRenderColor(const E: TEntity);
begin
	DrawRectangleRec(E.Body, E.Color);
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
		Width := Single(E.Texture.Width);
		Height := Single(E.Texture.Height);
	end;

	DrawTexturePro(E.Texture, Source, E.Body, Origin, E.Rotation, E.Color);
end;

{ ALIEN }

function AlienCreate(): TEntity;
begin
	with result do
	begin
		with Body do
		begin
			X      := 0;
			Y      := 0;
			Width  := 100;
			Height := 50;
		end;

		Velocity := Vector2Zero();
		Acceleration := Vector2Zero();

		Rotation := 0;

		Gravity := false;

		Color := GetColor($FFFFFFFF);
		// Texture := AlienTexture;
	end;
end;

procedure AlienUpdate(var A: TEntity);
const
	FRICTION = 1.0;
	ACC = 1000.0;
	VELX_MAX = 1000.0;
	COW_ACC = 400.0;
var
	Cow: PEntity;
	AlienCowPosDifference: TVector2;
begin
	for i := 0 to CowsCount - 1 do
	begin
		if not IsKeyDown(KEY_SPACE) then
			continue;

		Cow := @Cows[i];

		if CheckCollisionRecs(A.Body, Cow^.Body) then
		begin
			// TODO: do something
		end;

		if (Cow^.Body.X + Cow^.Body.Width < A.Body.X) or
			(Cow^.Body.X > A.Body.X + A.Body.Width) or
			(Cow^.Body.Y < A.Body.Y + A.Body.Height) then
			continue;

		with AlienCowPosDifference do
		begin
			X := (A.Body.X + (A.Body.Width / 2)) - (Cow^.Body.X + (Cow^.Body.Width / 2));
			Y := (A.Body.Y + (A.Body.Height / 2)) - (Cow^.Body.Y + (Cow^.Body.Height / 2));
		end;

		Cow^.Velocity.Y -= COW_ACC * DTime;

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

	A.Velocity := Vector2Scale(A.Velocity, 1 - FRICTION * DTime);
end;

{ FARMER }

function FarmerCreate(X: Single; Y: Single): TEntity;
const
	FARMER_WIDTH = 25;
	FARMER_HEIGHT = 75;
begin
	with result do
	begin
		Body.X := X;
		Body.Y := Y;
		Body.Width := FARMER_WIDTH;
		Body.Height := FARMER_HEIGHT;

		Velocity := Vector2Zero();
		Acceleration := Vector2Zero();

		Rotation := 0;
		Gravity := true;

		Color := GetColor($1133CCFF);

		// Texture := FarmerTexture;
	end;
end;

{ COW }

function CowCreate(X: Single; Y: Single): TEntity;
const
	COW_WIDTH = 100;
	COW_HEIGHT = 50;
begin
	with result do
	begin
		Body.X := X;
		Body.Y := Y;
		Body.Width := COW_WIDTH;
		Body.Height := COW_HEIGHT;

		Velocity := Vector2Zero();
		Acceleration := Vector2Zero();

		Rotation := 0.0;

		Gravity := true;

		Color := GetColor($FFFFFFFF);

		Texture := CowTexture;
	end;
end;

const
	COWS_AMOUNT = 100;
	COW_TEXTURE_PATH = 'assets/textures/cow.png';
var
	Alien: TEntity;
begin
	Randomize;

	Width  := 1280;
	Height := 720;
	Title  := PChar('Versation');

	BackgroundColor := GetColor($000000FF);

	Alien := AlienCreate();

	CowsCount := 0;
	CowsSize := 16;
	SetLength(Cows, CowsSize);

	InitWindow(Width, Height, Title);

	CowTexture := LoadTexture(COW_TEXTURE_PATH);

	for i := 0 to COWS_AMOUNT - 1 do
	begin
		if CowsCount = CowsSize then
		begin
			CowsSize *= 2;
			SetLength(Cows, CowsSize);
		end;

		Cows[i] := CowCreate(Random(Width), Random(Height));
		CowsCount += 1;
	end;

	while not WindowShouldClose() do
	begin
		{ UPDATE }
		DTime := GetFrameTime();

		AlienUpdate(Alien);

		for i := 0 to CowsCount - 1 do
		begin
			EntityUpdateGeneric(Cows[i]);
		end;

		{ REDNER }
		BeginDrawing();
		ClearBackground(BackgroundColor);

		EntityRenderColor(Alien);

		for i := 0 to CowsCount - 1 do
			EntityRenderTexture(Cows[i]);

		EndDrawing();
	end;

	UnloadTexture(CowTexture);

	CloseWindow();
end.
