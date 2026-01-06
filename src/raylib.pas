//{$mode FPC}
{$H+}

unit Raylib;

interface

type
	TConfigFlag = (
		FLAG_MSAA_4X_HINT = $00000020,
		FLAG_VSYNC_HINT   = $00000040
	);

	TKeyboardKey = (
		KEY_NULL            := 0,
		KEY_SPACE           := 32,
		KEY_APOSTROPHE      := 39,
		KEY_COMMA           := 44,
		KEY_MINUS           := 45,
		KEY_PERIOD          := 46,
		KEY_SLASH           := 47,
		KEY_ZERO            := 48,
		KEY_ONE             := 49,
		KEY_TWO             := 50,
		KEY_THREE           := 51,
		KEY_FOUR            := 52,
		KEY_FIVE            := 53,
		KEY_SIX             := 54,
		KEY_SEVEN           := 55,
		KEY_EIGHT           := 56,
		KEY_NINE            := 57,
		KEY_SEMICOLON       := 59,
		KEY_EQUAL           := 61,
		KEY_A               := 65,
		KEY_B               := 66,
		KEY_C               := 67,
		KEY_D               := 68,
		KEY_E               := 69,
		KEY_F               := 70,
		KEY_G               := 71,
		KEY_H               := 72,
		KEY_I               := 73,
		KEY_J               := 74,
		KEY_K               := 75,
		KEY_L               := 76,
		KEY_M               := 77,
		KEY_N               := 78,
		KEY_O               := 79,
		KEY_P               := 80,
		KEY_Q               := 81,
		KEY_R               := 82,
		KEY_S               := 83,
		KEY_T               := 84,
		KEY_U               := 85,
		KEY_V               := 86,
		KEY_W               := 87,
		KEY_X               := 88,
		KEY_Y               := 89,
		KEY_Z               := 90,
		KEY_LEFT_BRACKET    := 91,
		KEY_BACKSLASH       := 92,
		KEY_RIGHT_BRACKET   := 93,
		KEY_GRAVE           := 96,
		// Function keys
		KEY_ESCAPE          := 256,
		KEY_ENTER           := 257,
		KEY_TAB             := 258,
		KEY_BACKSPACE       := 259,
		KEY_INSERT          := 260,
		KEY_DELETE          := 261,
		KEY_RIGHT           := 262,
		KEY_LEFT            := 263,
		KEY_DOWN            := 264,
		KEY_UP              := 265,
		KEY_PAGE_UP         := 266,
		KEY_PAGE_DOWN       := 267,
		KEY_HOME            := 268,
		KEY_END             := 269,
		KEY_CAPS_LOCK       := 280,
		KEY_SCROLL_LOCK     := 281,
		KEY_NUM_LOCK        := 282,
		KEY_PRINT_SCREEN    := 283,
		KEY_PAUSE           := 284,
		KEY_F1              := 290,
		KEY_F2              := 291,
		KEY_F3              := 292,
		KEY_F4              := 293,
		KEY_F5              := 294,
		KEY_F6              := 295,
		KEY_F7              := 296,
		KEY_F8              := 297,
		KEY_F9              := 298,
		KEY_F10             := 299,
		KEY_F11             := 300,
		KEY_F12             := 301,
		KEY_KP_0            := 320,
		KEY_KP_1            := 321,
		KEY_KP_2            := 322,
		KEY_KP_3            := 323,
		KEY_KP_4            := 324,
		KEY_KP_5            := 325,
		KEY_KP_6            := 326,
		KEY_KP_7            := 327,
		KEY_KP_8            := 328,
		KEY_KP_9            := 329,
		KEY_KP_DECIMAL      := 330,
		KEY_KP_DIVIDE       := 331,
		KEY_KP_MULTIPLY     := 332,
		KEY_KP_SUBTRACT     := 333,
		KEY_KP_ADD          := 334,
		KEY_KP_ENTER        := 335,
		KEY_KP_EQUAL        := 336,
		KEY_LEFT_SHIFT      := 340,
		KEY_LEFT_CONTROL    := 341,
		KEY_LEFT_ALT        := 342,
		KEY_LEFT_SUPER      := 343,
		KEY_RIGHT_SHIFT     := 344,
		KEY_RIGHT_CONTROL   := 345,
		KEY_RIGHT_ALT       := 346,
		KEY_RIGHT_SUPER     := 347,
		KEY_KB_MENU         := 348
	);

	TMouseButton = (
		MOUSE_BUTTON_LEFT,
		MOUSE_BUTTON_RIGHT,
		MOUSE_BUTTON_MIDDLE,
		MOUSE_BUTTON_SIDE,
		MOUSE_BUTTON_EXTRA,
		MOUSE_BUTTON_FORWARD,
		MOUSE_BUTTON_BACK
	);

	TVector2 = record
		X, Y: Single;
	end;

	TRectangle = record
		X, Y: Single;
		Width, Height: Single;
	end;
	PRectangle = ^TRectangle;

	TColor = record
		A, R, G, B: Byte;
	end;

	TImage = record
		Data: Pointer;
		Width, Height: Integer;
		MipMaps, Format: Integer;
	end;

	TTexture2D = record
		Id: UInt32;
		Width, Height: Integer;
		MipMaps, Format: Integer;
	end;
	TTexture = TTexture2D;

	TGlyphInfo = record
		Value: Integer;
		OffsetX, OffsetY: Integer;
		AdvanceX: Integer;
		Image: TImage;
	end;
	PGlyphInfo = ^TGlyphInfo;

	TFont = record
		BaseSize: Integer;
		GlyghCount, GlyphPadding: Integer;
		Texture: TTexture2D;
		Rectangles: PRectangle;
		GlyphInfo: PGlyphInfo;
	end;

//procedure SetConfigFlags(Flags: TConfigFlag); cdecl; external;
procedure SetConfigFlags(Flags: Integer); cdecl; external;

function  GetFrameTime: Single; cdecl; external;
function  GetTime: Double; cdecl; external;

function  GetFPS: Integer; cdecl; external;
procedure SetTargetFPS(FPS: Integer); cdecl; external;
function  GetCurrentMonitor: Integer; cdecl; external;
function  GetMonitorRefreshRate(Monitor: Integer): Integer; cdecl; external;
procedure DrawFPS(X, Y: Integer); cdecl; external;

procedure InitWindow(Width, Height: Integer; Title: PChar); cdecl; external;
procedure CloseWindow; cdecl; external;
procedure SetWindowTitle(Title: PChar); cdecl; external;
function  WindowShouldClose: Boolean; cdecl; external;

procedure BeginDrawing; cdecl; external;
procedure EndDrawing; cdecl; external;
procedure ClearBackground(Color: TColor); cdecl; external;
procedure DrawRectangle(X, Y, Width, Height: Integer; Color: TColor); cdecl; external;
procedure DrawRectangleRec(Rectangle: TRectangle; Color: TColor); cdecl; external;
procedure DrawRectanglePro(Rectangle: TRectangle; Origin: TVector2; Rotation: Single; Color: TColor); cdecl; external;
procedure DrawRectangleLines(X, Y, Width, Height: Integer; Color: TColor); cdecl; external;
procedure DrawRectangleLinesEx(Rectangle: TRectangle; LineThick: Single; Color: TColor); cdecl; external;
procedure DrawTexture(Texture: TTexture2D; X: Integer; Y: Integer; Tint: TColor); cdecl; external;
procedure DrawTextureRec(Texture: TTexture2D; Source: TRectangle; Position: TVector2; Tint: TColor); cdecl; external;
procedure DrawTexturePro(Texture: TTexture2D; Source, Dest: TRectangle; Origin: TVector2; Rotation: Single; Tint: TColor); cdecl; external;
procedure DrawText(Text: PChar; PosX, PosY, FontSize: Integer; Color: TColor); cdecl; external;
procedure DrawTextEx(Font: TFont; Text: PChar; Position: TVector2; FontSize, Spacing: Single; Tint: TColor); cdecl; external;

function  IsKeyDown(Key: TKeyboardKey): Boolean; cdecl; external;
function  IsKeyPressed(Key: TKeyboardKey): Boolean; cdecl; external;
function  IsMouseButtonDown(Button: TMouseButton): Boolean; cdecl; external;
function  IsMouseButtonPressed(Button: TMouseButton): Boolean; cdecl; external;

function  LoadImage(FileName: PChar): TImage; cdecl; external;
procedure UnloadImage(Image: TImage); cdecl; external;
function  LoadTexture(FileName: PChar): TTexture2D; cdecl; external;
function  LoadTextureFromImage(Image: TImage): TTexture2D; cdecl; external;
procedure UnloadTexture(Texture: TTexture2D); cdecl; external;
function  LoadFont(FileName: PChar): TFont; cdecl; external;
procedure UnloadFont(Font: TFont); cdecl; external;

function  GetColor(HexValue: UInt32): TColor; cdecl; external;
function  GetFontDefault: TFont; cdecl; external;
function  MeasureTextEx(Font: TFont; Text: PChar; FontSize, Spacing: Single): TVector2; cdecl; external;

function  CheckCollisionRecs(Rec1, Rec2: TRectangle): Boolean; cdecl; external;

implementation

{$linklib c}
{$linklib m}
{$linklib raylib}

end.
