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
	Title: String;

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

procedure EntityRenderGeneric(const E: TEntity);
begin
	DrawRectangleRec(E.Body, E.Color);
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

		Velocity.X     := 0;
		Velocity.Y     := 0;
		Acceleration.X := 0;
		Acceleration.Y := 0;

		Color := WHITE;
	end;


	CowsCount := 0;
	CowsSize := 16;
	SetLength(Cows, CowsSize);

	InitWindow(Width, Height, PChar(Title));

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

		EntityRenderGeneric(Alien);

		for i := 0 to CowsCount - 1 do
			EntityRenderGeneric(Cows[i]);

		EndDrawing();
	end;

	CloseWindow();
end;

begin
	Width  := 1280;
	Height := 720;
	Title  := 'Versation';

	Run();
end.
