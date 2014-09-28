{$IFDEF VCLHnd}
{$DEFINE DEBUG_UNIT}
{$ENDIF}
{$I XPLib.inc}
unit VCLHnd;

interface

uses
  SysUtils, Classes, TypInfo, ComCtrls, consts, StrHnd; // NOTAS: DsgnIntf removido pelo pacote DesignIDE

function IntArrayIndexOf(Arr: array of integer; Value: integer): integer;
procedure SetPropValueAsString(Instance: TObject; const PropName, PropValue: string);
function StrToOrdinalValue(ATypeInfo: PTypeInfo; const EnumValue: string): longint;
function StrToSetValue(SetInfo: PTypeInfo; const Value: string): TIntegerSet;

function TreeNodeFindChildText(Parent: TTreeNode; const Text: string; IgnoreCase: boolean = True): TTreeNode;

implementation

function IntArrayIndexOf(Arr: array of integer; Value: integer): integer;
// ----------------------------------------------------------------------------------------------------------------------------------
// Retorna o primeiro indice do vetor cujo valor equivale ao passado
var
  i: integer;
begin
  Result := low(Arr) - 1; // Valor invalido
  for i := low(Arr) to high(Arr) do begin
	if Value = Arr[i] then begin
	  Result := i;
	  Exit;
	end;
  end;
end;

procedure SetPropValueAsString(Instance: TObject; const PropName, PropValue: string);
// ----------------------------------------------------------------------------------------------------------------------
// Altera propriedade pelo seu nome
var
  PropInfo: PPropInfo;
  PropType: PTypeInfo;
  IntValue: longint;
  CharValue: char;
  FloatValue: Extended;
  Int64Value: Int64;
begin
  PropInfo := GetPropInfo(Instance.ClassInfo, PropName);
  if Assigned(PropInfo) then begin
	{$WARN UNSAFE_CODE OFF}
	PropType := PPropInfo(PropInfo)^.PropType^;
	case PropInfo^.PropType^.Kind of
	  tkInteger: begin
		  IntValue := StrToInt(PropValue);
		  SetOrdProp(Instance, PropInfo, IntValue);
		end;
	  tkChar: begin
		  CharValue := PropValue[1];
		  SetOrdProp(Instance, PropInfo, Ord(CharValue));
		end;
	  tkEnumeration: begin
		  SetOrdProp(Instance, PropInfo, StrToOrdinalValue(PropType, PropValue));
		end;
	  tkFloat: begin
		  FloatValue := StrToFloat(PropValue);
		  SetFloatProp(Instance, PropInfo, FloatValue);
		end;
	  tkString, tkLString, tkWString: begin
		  SetStrProp(Instance, PropInfo, PropValue);
		end;
	  tkSet: begin
		  IntValue := integer(StrToSetValue(PropType, PropValue));
		  SetOrdProp(Instance, PropInfo, IntValue);
		end;
	  { //Nao ha forma 100% segura de importar class e metodo de texto livre
		tkClass :   begin
		end;
		tkMethod    :   begin
		end;
		//Dispensado o suporte a Variants
		tkVariant   :   begin
		ReadVariantProp;
		end;
	  }
	  tkInt64: begin
		  Int64Value := StrToInt64(PropValue);
		  SetInt64Prop(Instance, PropInfo, Int64Value);
		end;
	end;
	{$WARN UNSAFE_CODE ON}
  end else begin
	raise Exception.CreateFmt('Propriedade "%s" n�o localizada', [PropName]);
  end;
end;

function StrToOrdinalValue(ATypeInfo: PTypeInfo; const EnumValue: string): longint;
// ----------------------------------------------------------------------------------------------------------------------
// Retorna o indice do elemento da numeracao dada a string que o compoe
// *** USO
// type
// TMyType =   ( Element1, Element2, Element3, ..., ElementN );
// ...
// var
// AVar : TMyType;
// begin
// ...
// AVar:=TMyType(StrToOrdinalValue( TypeInfo(TMyType), 'ElementX' ));
const
  INV_TYPE_PARAM = 'Valor passado para tipo � inv�lido';
var
  E: Exception;
begin
  try
	Result := GetEnumValue(ATypeInfo, EnumValue);
  except
	raise Exception.Create(INV_TYPE_PARAM);
  end;
  if Result = -1 then begin
	try
	  {$WARN UNSAFE_CODE OFF} {$WARN EXPLICIT_STRING_CAST OFF}
	  E := Exception.Create('Erro lendo valor da enumera��o ' + string(ATypeInfo^.Name));
	  {$WARN UNSAFE_CODE ON} {$WARN EXPLICIT_STRING_CAST ON}
	except
	  raise Exception.Create(INV_TYPE_PARAM);
	end;
	raise E;
  end;
end;

function StrToSetValue(SetInfo: PTypeInfo; const Value: string): TIntegerSet;
// ----------------------------------------------------------------------------------------------------------------------
// Forma de uso semelhante a StrToOrdinalValue(), devido ao tipo de retorno a tribuicao deve ser geralmente feita por
// ponteiros
// Ex.:
// Type
// TMySet  = Set of TMyEnum;
// PMySet  = ^TMySet;
// ....
// var
// AVar : TMySet;
// Ret : TIntegerSet;
// begin
// Ret:=StrToSetValue( TypeInfo( TMySet ), '[ ???, ??? ]' );
// AVar:=PMySet(@Ret)^;
// ....
var
  Left, EnumName: string;
  Data, EnumValue: longint;
  EnumInfo: PTypeInfo;
  // ......................................................................................................................
  function NextWord: string;
  // grab the next enum name
  begin
	Result := EmptyStr;
	while not CharInSet(Left[1], [',', ' ']) do begin
	  Result := Result + Left[1];
	  Delete(Left, 1, 1);
	  if Left = EmptyStr then begin
		Exit;
	  end;
	end;
	while CharInSet(Left[1], [',', ' ']) do begin // skip any whitespace
	  Delete(Left, 1, 1);
	end;
  end;

// ......................................................................................................................
begin
  // bracket reduction
  Left := Value;
  if Left[1] = '[' then begin
	Delete(Left, 1, 1);
  end;
  if Left[Length(Left)] = ']' then begin
	Delete(Left, Length(Left), 1);
  end;

  // loop it dude!
  Data := 0;

  {$WARN UNSAFE_CODE OFF}
  // EnumInfo := GetTypeData(PropInfo^.PropType^)^.CompType^;
  EnumInfo := GetTypeData(SetInfo)^.CompType^;
  {$WARN UNSAFE_CODE ON}

  while Left <> EmptyStr do begin
	EnumName := NextWord();
	if EnumName = EmptyStr then begin
	  Break;
	end;
	EnumValue := GetEnumValue(EnumInfo, EnumName);
	if EnumValue < 0 then begin
	  raise EPropertyConvertError.CreateFmt('Elemento inv�lido para a propriedade: %s', [EnumName]);
	end;
	Include(TIntegerSet(Data), EnumValue);
  end;
  Result := TIntegerSet(Data);
end;

function TreeNodeFindChildText(Parent: TTreeNode; const Text: string; IgnoreCase: boolean = True): TTreeNode;
// ----------------------------------------------------------------------------------------------------------------------------------
var
  Sub: TTreeNode;
begin
  Result := nil;
  Sub := Parent.getFirstChild;
  if IgnoreCase then begin
	while Assigned(Sub) do begin
	  if SameText(Sub.Text, Text) then begin
		Result := Sub;
		Break;
	  end else begin
		Sub := Sub.getNextSibling;
	  end;
	end;
  end else begin
	while Assigned(Sub) do begin
	  if SameText(Sub.Text, Text) then begin
		Result := Sub;
		Break;
	  end else begin
		Sub := Sub.getNextSibling;
	  end;
	end;
  end;
end;

end.
