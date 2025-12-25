program Versation;

uses Raylib;

type
	TEntity = record
		Body: TRectangle;
		Velocity, Acceleration: TVector2;
		Color: TColor;

		Texture: TTexture;

	end;

var
	Width, Height: Integer;
	Title: PChar;

function CowCreate(X: Single; Y: Single): TEntity;
const
	COW_WIDTH = 100;
	COW_HEIGHT = 50;
	TEXTURE_PATH = 'assets/texture/cow.png';
var
	Cow: TEntity;
	Image: TImage;
begin
	with Cow do
	begin
		Body.X := X;
		Body.Y := Y;
		Body.Width := COW_WIDTH;
		Body.Height := COW_HEIGHT;

		Velocity.X := 0;
		Velocity.Y := 0;
		Acceleration.X := 0;
		Acceleration.Y := 0;

		Color := GetColor($FFFFFFFF);

		Image := LoadImage(TEXTURE_PATH);
		Texture := LoadTextureFromImage(Image);
		UnloadImage(Image);
	end;

	result := Cow;
end;

procedure CowDestroy(var Cow: TEntity);
begin
	UnloadTexture(Cow.Texture);
end;

procedure EntityUpdateGeneric(var E: TEntity; DTime: Double);
begin
		E.Velocity.X += E.Acceleration.X * DTime;
		E.Velocity.Y += E.Acceleration.Y * DTime;

		E.Body.X += E.Velocity.X * DTime;
		E.Body.Y += E.Velocity.Y * DTime;

		if (E.Body.Y + E.Body.Height) >= Height then
		begin
			E.Body.Y := Height - E.Body.Height;
			E.Velocity.Y := 0;
		end;
end;

procedure EntityRenderColor(const E: TEntity);
begin
	DrawRectangleRec(E.Body, E.Color);
end;

procedure EntityRenderTexture(const E: TEntity);
begin
	DrawTexture(E.Texture, 0, 0, E.Color);
end;

procedure AlienUpdate(var P: TEntity; DTime: Double);
const
	SPEED = 400;
begin
	if IsKeyDown(KEY_A) then
		P.Body.X -= SPEED * DTime;

	if IsKeyDown(KEY_D) then
		P.Body.X += SPEED * DTime;

	EntityUpdateGeneric(P, DTime);
end;

procedure Run();
var
	i: Int64;

	BackgroundColor: TColor;
	DTime: Double;
	Alien: TEntity;

	Cows: array of TEntity;
	CowsCount: Int32;
	CowsSize: Int64;
begin
	BackgroundColor := GetColor($000000FF);

	with Alien do
	begin
		with Body do
		begin
			X      := 0;
			Y      := 0;
			Width  := 50;
			Height := 50;
		end;

		Velocity.X := 0;
		Velocity.Y := 0;
		Acceleration.X := 0;
		Acceleration.Y := 0;

		Color := GetColor($FFFFFFFF);
	end;


	CowsCount := 0;
	CowsSize := 16;
	SetLength(Cows, CowsSize);

	Cows[0] := CowCreate(0, 0);
	CowsCount += 1;

	InitWindow(Width, Height, Title);

	while not WindowShouldClose() do
	begin
		{ UPDATE }
		DTime := GetFrameTime();

		AlienUpdate(Alien, DTime);

		for i := 0 to CowsCount - 1 do
			EntityUpdateGeneric(Cows[i], DTime);

		{ REDNER }
		BeginDrawing();
		ClearBackground(BackgroundColor);

		EntityRenderColor(Alien);

		for i := 0 to CowsCount - 1 do
			EntityRenderTexture(Cows[i]);

		EndDrawing();
	end;

	for i := 0 to CowsCount - 1 do
		CowDestroy(Cows[i]);

	CloseWindow();
end;

begin
	Width  := 1280;
	Height := 720;
	Title  := PChar('Versation');

	Run();
end.
