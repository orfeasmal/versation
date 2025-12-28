unit Raymath;

interface

uses Raylib;

function Vector2Zero: TVector2; cdecl; external;
function Vector2Add(V1: TVector2; V2: TVector2): TVector2; cdecl; external;
function Vector2Scale(V: TVector2; Scale: Single): TVector2; cdecl; external;
function Vector2Normalize(V: TVector2): TVector2; cdecl; external;

implementation

{$linklib c}
{$linklib m}
{$linklib raylib}

end.
