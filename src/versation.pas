//{$mode FPC}
{$H+}

program Versation;

uses
	Math,
	SysUtils,
	Raylib,
	Raymath;

type
	TGameState = (
		GAME_STATE_PLAYING,
		GAME_STATE_OVER
	);

	TEntityType = (
		ENTITY_BACKGROUND,
		ENTITY_ALIEN,
		ENTITY_COW,
		ENTITY_FARMER,
		ENTITY_GUN,
		ENTITY_BULLET
	);

	TEntityState = (
		ENTITY_STATE_NORMAL,
		ENTITY_STATE_BEING_SUCKED
	);

	TEntity = record
		Id: UInt32;
		EntityType: TEntityType;
		State: TEntityState;

		RenderProcedure: procedure (const Entity: TEntity);

		Body: TRectangle;
		Origin: TVector2;
		Velocity, Acceleration: TVector2;
		Rotation: Single;

		Texture: TTexture2D;
		Color: TColor;
		Timer: Single;

		Health: Integer;
		Score: UInt32;
		ScoreStr: AnsiString;

		OnGround, Gravity, MarkedForRemoval: Boolean;
	end;
	PEntity = ^TEntity;

	TEntityArray = record
		MarkedForRemoval: Array of UInt32;
		Data: Array of TEntity;
		Count: UInt32;
		MarkedCount: UInt32;
	end;

const
	HEALTH_MIN = 0;
	HEALTH_MAX = 100;
var
	i, j: Int64;
	Width, Height: Integer;
	BackgroundColor: TColor;

	DTime: Double;

	BackgroundTexture: TTexture2D;
	CowTexture: TTexture2D;
	// AlienTexture: TTexture2D;
	// FarmerTexture: TTexture2D;
	// GunTexture: TTexture2D;

	Font: TFont;

{ ENTITY ARRAY }

function EntityArrayCreate(InitialSize: UInt32): TEntityArray;
begin
	EntityArrayCreate := Default(TEntityArray);
	with EntityArrayCreate do
	begin
		SetLength(Data, InitialSize);
		SetLength(MarkedForRemoval, InitialSize);
	end;
end;

procedure EntityArrayAdd(var Arr: TEntityArray; Entity: TEntity);
begin
	with Arr do
	begin
		if Count >= High(Data) + 1 then
		begin
			SetLength(Data, Count * 2);
			SetLength(MarkedForRemoval, Count * 2);
		end;

		Data[Count] := Entity;
		Count += 1;
	end;
end;

procedure EntityArrayRemove(var Arr: TEntityArray; Index: UInt32);
begin
	with Arr do
	begin
		if Index > High(Data) then
		begin
			WriteLn('internal error: attempting to remove index of entity array that does not exist');
			Exit;
		end;

		if Index <> Count - 1 then
		begin
			Data[Index] := Data[Count - 1];
		end;

		Count -= 1;
	end;
end;

procedure EntityArrayRemoveMarked(var Arr: TEntityArray);
begin
	with Arr do
	begin
		i := 0;
		while i < Count do
		begin
			if Data[i].MarkedForRemoval then
			begin
				Data[i] := Data[Count - 1];
				Count -= 1;
			end;
			
			i += 1;
		end;
	end;
end;

{
procedure EntityArrayMarkForRemoval(var Arr: TEntityArray; Index: UInt32);
begin
	with Arr do
	begin
		if Index > High(Data) then
		begin
			WriteLn('internal error: attempting to remove index of entity array that does not exist');
			Exit;
		end;

		MarkedForRemoval[MarkedCount] := Index;
		MarkedCount += 1;
	end;
end;
}

{
procedure EntityArrayRemoveMarked(var Arr: TEntityArray);
begin
	with Arr do
	begin
		i := 0;
		while i < Arr.MarkedCount do
		begin
			Data[MarkedForRemoval[i]] := Data[Count - 1];
			Count -= 1;
		end;

		Arr.MarkedCount := 0;
	end;
end;
}

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

procedure RenderScore(ScoreStr: PChar);
const
	FONT_SIZE = 32;
	FONT_SPACING = 1.0;
var
	Position: TVector2;
begin
	with Position do
	begin
		X := Width - MeasureTextEx(Font, ScoreStr, FONT_SIZE, FONT_SPACING).X;
		Y := 0;
	end;

	DrawTextEx(Font, ScoreStr, Position, FONT_SIZE, FONT_SPACING, GetColor($FFFFFFFF));
end;

procedure RenderHealth(Health: Integer);
const
	HEALTH_X = 5;
	HEALTH_Y = 5;
	HEALTH_WIDTH = 200;
	HEALTH_HEIGHT = 40;
	HEALTH_BORDER_THICK = 2.0;
	HEALTH_COLOR = $00FF00AA;
var
	Rectangle: TRectangle;
begin
	with Rectangle do
	begin
		X := HEALTH_X;
		Y := HEALTH_Y;
		Width := HEALTH_WIDTH * (Health / HEALTH_MAX);
		Height := HEALTH_HEIGHT;
	end;

	DrawRectangleRec(Rectangle, GetColor(HEALTH_COLOR));

	Rectangle.Width := HEALTH_WIDTH;
	DrawRectangleLinesEx(Rectangle, HEALTH_BORDER_THICK, GetColor($000000FF));
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

{ BULLET }

function BulletCreate(X, Y: Single; StartVelocity: TVector2): TEntity;
const
	BULLET_WIDTH = 10;
	BULLET_HEIGHT = 10;
begin
	BulletCreate := Default(TEntity);
	with BulletCreate do
	begin
		EntityType := ENTITY_BULLET;
		RenderProcedure := @EntityRenderColor;

		Body.X := X;
		Body.Y := Y;
		Body.Width := BULLET_WIDTH;
		Body.Height := BULLET_HEIGHT;
		Velocity := StartVelocity;

		Color := GetColor($FFFFFFFF);
	end;
end;

procedure BulletUpdate(var B: TEntity; var Target: TEntity);
const
	BULLET_DAMAGE = HEALTH_MAX div 10;
begin
	EntityUpdateGeneric(B);

	if B.Body.Y + B.Body.Height <= 0 then
		B.MarkedForRemoval := true;

	if CheckCollisionRecs(B.Body, Target.Body) then
	begin
		B.MarkedForRemoval := true;
		if Target.Health > 0 then
			Target.Health -= BULLET_DAMAGE;
	end;
end;

{ GUN }

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

		Color := GetColor(GUN_COLOR);

		// Texture := GunTexture;

		RenderProcedure := @EntityRenderColorOrigin;
	end;
end;

procedure GunUpdate(var G: TEntity; Bullets: TEntityArray);
var
	Bullet: PEntity;
begin
end;

procedure GunShootBullet(var G: TEntity; var Bullets: TEntityArray);
const
	UnitVector: TVector2 = (X: 1.0; Y: 0.0);
	BULLET_SPEED = 1000;
var
	Bullet: TEntity;
begin
	Bullet := BulletCreate(
		G.Body.X,
		G.Body.Y,
		Vector2Scale(
			Vector2Rotate(UnitVector, G.Rotation * (System.Pi / 180)),
			BULLET_SPEED
		)
	);
	EntityArrayAdd(Bullets, Bullet);
end;

{ FARMER }

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

procedure FarmerUpdate(var F: TEntity; var Gun: TEntity; var Bullets: TEntityArray; const Alien: TEntity);
const
	FARMER_VELOCITY_FACTOR = 1 / 6;
	GUN_ANGLE_VELOCITY_FACTOR = 1 / 10;
	GUN_SHOOT_DELAY = 0.75;
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
	AlienGunAngle *= 180 / System.Pi;
	Gun.Rotation += (AlienGunAngle - Gun.Rotation) * GUN_ANGLE_VELOCITY_FACTOR;

	F.Timer += DTime;
	if F.Timer >= GUN_SHOOT_DELAY then
	begin
		GunShootBullet(Gun, Bullets);
		F.Timer := 0;
	end;
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

procedure CowUpdate(var Cow: TEntity; SelfIndexInArray: UInt64; var Cows: TEntityArray);
const
	SUCKING_SPEED = 300;
	SUCK_LOWER_SIZE_LIMIT = 25;
	COW_STEP_VEL = 100;
var
	SuckAmount: Single;
	Cow2: PEntity;
	Cow1Cow2PosDifference: TVector2;
begin
	EntityUpdateGeneric(Cow);

	if Cow.State = ENTITY_STATE_BEING_SUCKED then
	begin
		Cow.Velocity.Y := 0;

		SuckAmount := SUCKING_SPEED * DTime;

		Cow.Body.Height -= SuckAmount;
		Cow.Body.Width  -= SuckAmount;

		Cow.Body.X += SuckAmount / 2;

		if Cow.Body.Width < SUCK_LOWER_SIZE_LIMIT then
			Cow.MarkedForRemoval := true;

		Exit;
	end;

	{
	for i := SelfIndexInArray + 1 to Cows.Count - 1 do
	begin
		Cow2 := @Cows.Data[i];

		with Cow1Cow2PosDifference do
		begin
			X := Cow.Body.X - Cow2^.Body.X;
			Y := Cow.Body.Y - Cow2^.Body.Y;
		end;
	end;
	}

	Cow.Timer += DTime;
	if Cow.OnGround and (Cow.Timer >= 1 + Random(100) / 10) then // Random delay time
	begin
		Cow.Timer := 0;
		Cow.Velocity.X += COW_STEP_VEL * (-1 + Random(3));
	end;
end;

{ ALIEN }

procedure AlienRender(const Alien: TEntity);
const
	RAY_COLOR = $0000FF88;
var
	Vertex1, Vertex2, Vertex3: TVector2;
begin
	if IsKeyDown(KEY_SPACE) then
	begin
		with Vertex1 do
		begin
			X := Alien.Body.X + Alien.Body.Width / 2;
			Y := Alien.Body.Y + Alien.Body.Height / 2;
		end;

		with Vertex2 do
		begin
			X := Vertex1.X - Alien.Body.Width;
			Y := Height;
		end;

		with Vertex3 do
		begin
			X := Vertex1.X + Alien.Body.Width;
			Y := Height;
		end;

		DrawTriangle(Vertex1, Vertex2, Vertex3, GetColor(RAY_COLOR));
	end;

	EntityRenderColor(Alien);
end;


function AlienCreate(X, Y: Single): TEntity;
const
	ALIEN_WIDTH = 100;
	ALIEN_HEIGHT = 30;
	ALIEN_COLOR = $99FF33FF;
begin
	AlienCreate := Default(TEntity);
	with AlienCreate do
	begin
		RenderProcedure := @AlienRender;

		EntityType := ENTITY_ALIEN;
		Body.X := X;
		Body.Y := Y;
		Body.Width := ALIEN_WIDTH;
		Body.Height := ALIEN_HEIGHT;

		ScoreStr := 'Score: 0';
		Health := HEALTH_MAX;

		Color := GetColor(ALIEN_COLOR);
		// Texture := AlienTexture;
	end;
end;

procedure AlienUpdate(var A: TEntity; var Cows: TEntityArray);
const
	SCORE_PER_COW = 100;
	ACC = 1000.0;
	VELX_MAX = 1000.0;
	COW_ACC = 600.0;
var
	Cow: PEntity;
	AlienCowPosDifference: TVector2;
begin
	if A.Health = 0 then
	begin
		A.MarkedForRemoval := true;
		Exit;
	end;

	for i := 0 to Cows.Count - 1 do
	begin
		Cow := @Cows.Data[i];

		if Cow^.State = ENTITY_STATE_BEING_SUCKED then
			continue;

		if CheckCollisionRecs(A.Body, Cow^.Body) then
		begin
			A.Score += SCORE_PER_COW;
			A.ScoreStr := Format('Score: %d', [A.Score]);

			Cow^.State := ENTITY_STATE_BEING_SUCKED;

			continue;
		end;

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

	EntityArrayRemoveMarked(Cows);

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

function BackgroundCreate: TEntity;
begin
	BackgroundCreate := Default(TEntity);
	with BackgroundCreate do
	begin
		Body.Width := Width;
		Body.Height := Height;
		Texture := BackgroundTexture;
		Color := GetColor($FFFFFFFF);
	end;
end;

const
	TITLE_RAW = 'Versation';

	BACKGROUND_TEXTURE_PATH = 'assets/textures/background.png';
	COW_TEXTURE_PATH = 'assets/textures/cow.png';
	FONT_PATH = 'assets/fonts/Ac437_IBM_VGA_8x16.ttf';

	COWS_INITIAL_COUNT = 100;
	ALIEN_Y = 10.0;
var
	State: TGameState;

	Title: AnsiString;
	TitleFPSTimer: Single;

	Background: TEntity;

	Alien: TEntity;
	Farmer: TEntity;
	Gun: TEntity;
	Bullets: TEntityArray;

	Cows: TEntityArray;
begin
	Randomize;

	State := GAME_STATE_PLAYING;

	Width  := 1280;
	Height := 720;
	Title  := TITLE_RAW;
	TitleFPSTimer := 1.0;

	SetConfigFlags(Integer(FLAG_MSAA_4X_HINT) or Integer(FLAG_VSYNC_HINT)); // Anti-Aliasing
	InitWindow(Width, Height, PChar(Title));

	BackgroundTexture := LoadTexture(BACKGROUND_TEXTURE_PATH);
	CowTexture := LoadTexture(COW_TEXTURE_PATH);
	Font := LoadFont(FONT_PATH);

	Background := BackgroundCreate();

	Alien := AlienCreate(Random(Width - 100), ALIEN_Y);
	Gun := GunCreate(Random(Width), Random(Height));
	Farmer := FarmerCreate(Gun.Body.X);
	Bullets := EntityArrayCreate(16);

	Cows := EntityArrayCreate(16);

	for i := 0 to COWS_INITIAL_COUNT - 1 do
		EntityArrayAdd(Cows, CowCreate(Random(Width)));

	while not WindowShouldClose() do
	begin
		{ UPDATE }
		DTime := GetFrameTime();

		AlienUpdate(Alien, Cows);
		if Alien.MarkedForRemoval then
			State := GAME_STATE_OVER;

		FarmerUpdate(Farmer, Gun, Bullets, Alien);
		GunUpdate(Gun, Bullets);
		for i := 0 to Bullets.Count - 1 do
			BulletUpdate(Bullets.Data[i], Alien);
		EntityArrayRemoveMarked(Bullets);

		for i := 0 to Cows.Count - 1 do
			CowUpdate(Cows.Data[i], i, Cows);

		{ REDNER }
		TitleFPSTimer += DTime;
		if TitleFPSTimer >= 1.0 then
		begin
			TitleFPSTimer := 0;
			Title := Format('%s FPS: %d', [TITLE_RAW, GetFPS()]);
			SetWindowTitle(PChar(Title));
		end;

		BeginDrawing();
		EntityRenderTexture(Background);

		for i := 0 to Cows.Count - 1 do
			Cows.Data[i].RenderProcedure(Cows.Data[i]);

		Alien.RenderProcedure(Alien);

		Farmer.RenderProcedure(Farmer);
		for i := 0 to Bullets.Count - 1 do
			Bullets.Data[i].RenderProcedure(Bullets.Data[i]);
		Gun.RenderProcedure(Gun);

		// HUD
		RenderHealth(Alien.Health);
		RenderScore(PChar(Alien.ScoreStr));

		// DrawFPS(0, 0);

		EndDrawing();
	end;

	UnloadFont(Font);
	UnloadTexture(CowTexture);
	UnloadTexture(BackgroundTexture);

	CloseWindow();
end.
