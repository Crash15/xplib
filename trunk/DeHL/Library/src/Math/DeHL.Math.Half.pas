(*
* Copyright (c) 2010, Ciobanu Alexandru
* All rights reserved.
*
* Ideea based on Matt McCutchen's C++ Big Integer Library
* which was released to public domain. Site: http://mattmccutchen.net/bigint/index.html
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the <organization> nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*)

{$I ../DeHL.Defines.inc}
unit DeHL.Math.Half;
interface
uses SysUtils,
     DeHL.Base,
     DeHL.Exceptions,
     DeHL.Types,
     DeHL.Serialization,
     DeHL.Math.Types;

type
  ///  <summary>A half-float type.</summary>
  ///  <remarks><c>Half</c> is a 16-bit precision floating point type that can hold value ranging from
  ///  <c>6.10352E-05</c> to <c>65504.0</c></remarks>
  Half = packed record
  private const
    { Representations. Used by properties }
    CMax              = $7BFF;
    CMin              = $0400;
    CInfinity         = $7BFF;
    CMinusInfinity    = $FC00;
    CZero             = $0000;
    CMinusZero        = $8000;
    COne              = $3C00;
    CMinusOne         = $BC00;
    CTen              = $C900;
    CMinusTen         = $4900;

    { For property support }
    class function GetInfinity: Half; static; inline;
    class function GetMax: Half; static; inline;
    class function GetMin: Half; static; inline;
    class function GetMinusInfinity: Half; static; inline;
    class function GetMinusZero: Half; static; inline;
    class function GetZero: Half; static; inline;
    class function GetMinusOne: Half; static; inline;
    class function GetMinusTen: Half; static; inline;
    class function GetOne: Half; static; inline;
    class function GetTen: Half; static; inline;

    { For initialization of types }
    class constructor Create;
    class destructor Destroy;

  private
    FWord: Word;

  public
    ///  <summary>Overloded "Implicit" operator.</summary>
    ///  <param name="AFloat">A <c>Single</c> value to convert from.</param>
    ///  <returns>A <c>Half</c> value representing the value stored in <paramref name="AFloat"/>.</returns>
    ///  <remarks>The precision of the converted value is diminished.</remarks>
    class operator Implicit(const AFloat: Single): Half;

    ///  <summary>Overloded "Implicit" operator.</summary>
    ///  <param name="AHalf">A <c>Half</c> value to convert from.</param>
    ///  <returns>A <c>Single</c> value representing the value stored in <paramref name="AHalf"/>.</returns>
    ///  <remarks>This conversion is losless.</remarks>
    class operator Implicit(const AHalf: Half): Single;

    ///  <summary>Overloded "Implicit" operator.</summary>
    ///  <param name="AVariant">A <c>Variant</c> value to convert from.</param>
    ///  <returns>A <c>Half</c> value representing the value stored in <paramref name="AVariant"/>.</returns>
    ///  <remarks>If the <c>Variant</c> is not in the correct format exceptions may be thrown.</remarks>
    class operator Implicit(const AVariant: Variant): Half; inline;

    ///  <summary>Overloded "Implicit" operator.</summary>
    ///  <param name="AHalf">A <c>Half</c> value to convert from.</param>
    ///  <returns>A <c>Variant</c> value representing the value stored in <paramref name="AHalf"/>.</returns>
    ///  <remarks>This conversion is losless.</remarks>
    class operator Implicit(const AHalf: Half): Variant; inline;

    ///  <summary>Overloded "+" operator.</summary>
    ///  <param name="ALeft">First <c>Half</c> value.</param>
    ///  <param name="ARight">Second <c>Half</c> value.</param>
    ///  <returns>A <c>Half</c> value that contains the sum of the two values.</returns>
    class operator Add(const ALeft, ARight: Half): Half; inline;

    ///  <summary>Overloded "+" operator.</summary>
    ///  <param name="ALeft">A <c>Half</c> value.</param>
    ///  <param name="ARight">A <c>Single</c> value.</param>
    ///  <returns>A <c>Half</c> value that contains the sum of the two values.</returns>
    class operator Add(const ALeft: Half; const ARight: Single): Half; inline;

    ///  <summary>Overloded "+" operator.</summary>
    ///  <param name="ALeft">A <c>Single</c> value.</param>
    ///  <param name="ARight">A <c>Half</c> value.</param>
    ///  <returns>A <c>Half</c> value that contains the sum of the two values.</returns>
    class operator Add(const ALeft: Single; const ARight: Half): Half; inline;

    ///  <summary>Overloded "-" operator.</summary>
    ///  <param name="ALeft">First <c>Half</c> value.</param>
    ///  <param name="ARight">Second <c>Half</c> value.</param>
    ///  <returns>A <c>Half</c> value that contains the difference of the two values.</returns>
    class operator Subtract(const ALeft, ARight: Half): Half; inline;

    ///  <summary>Overloded "-" operator.</summary>
    ///  <param name="ALeft">A <c>Half</c> value.</param>
    ///  <param name="ARight">A <c>Single</c> value.</param>
    ///  <returns>A <c>Half</c> value that contains the difference of the two values.</returns>
    class operator Subtract(const ALeft: Half; const ARight: Single): Half; inline;

    ///  <summary>Overloded "-" operator.</summary>
    ///  <param name="ALeft">A <c>Single</c> value.</param>
    ///  <param name="ARight">A <c>Half</c> value.</param>
    ///  <returns>A <c>Half</c> value that contains the difference of the two values.</returns>
    class operator Subtract(const ALeft: Single; const ARight: Half): Half; inline;

    ///  <summary>Overloded "*" operator.</summary>
    ///  <param name="ALeft">First <c>Half</c> value.</param>
    ///  <param name="ARight">Second <c>Half</c> value.</param>
    ///  <returns>A <c>Half</c> value that contains the product of the two values.</returns>
    class operator Multiply(const ALeft, ARight: Half): Half; inline;

    ///  <summary>Overloded "*" operator.</summary>
    ///  <param name="ALeft">A <c>Half</c> value.</param>
    ///  <param name="ARight">A <c>Single</c> value.</param>
    ///  <returns>A <c>Half</c> value that contains the product of the two values.</returns>
    class operator Multiply(const ALeft: Half; const ARight: Single): Half; inline;

    ///  <summary>Overloded "*" operator.</summary>
    ///  <param name="ALeft">A <c>Single</c> value.</param>
    ///  <param name="ARight">A <c>Half</c> value.</param>
    ///  <returns>A <c>Half</c> value that contains the product of the two values.</returns>
    class operator Multiply(const ALeft: Single; const ARight: Half): Half; inline;

    ///  <summary>Overloded "/" operator.</summary>
    ///  <param name="ALeft">The dividend <c>Half</c> value.</param>
    ///  <param name="ARight">The divisor <c>Half</c> value.</param>
    ///  <returns>A <c>Half</c> value that contains the quotient.</returns>
    class operator Divide(const ALeft, ARight: Half): Half; inline;

    ///  <summary>Overloded "/" operator.</summary>
    ///  <param name="ALeft">The dividend <c>Half</c> value.</param>
    ///  <param name="ARight">The divisor <c>Single</c> value.</param>
    ///  <returns>A <c>Half</c> value that contains the quotient.</returns>
    class operator Divide(const ALeft: Half; const ARight: Single): Half; inline;

    ///  <summary>Overloded "/" operator.</summary>
    ///  <param name="ALeft">The dividend <c>Single</c> value.</param>
    ///  <param name="ARight">The divisor <c>Half</c> value.</param>
    ///  <returns>A <c>Half</c> value that contains the quotient.</returns>
    class operator Divide(const ALeft: Single; const ARight: Half): Half; inline;

    ///  <summary>Overloded unary "+" operator.</summary>
    ///  <param name="AHalf">A <c>Half</c> value.</param>
    ///  <returns>The same <c>Half</c> value.</returns>
    ///  <remarks>This operation is a nop.</remarks>
    class operator Positive(const AHalf: Half): Half; inline;

    ///  <summary>Overloded unary "-" operator.</summary>
    ///  <param name="AHalf">A <c>Half</c> value.</param>
    ///  <returns>A <c>Half</c> value with the same magnitude but with a different sign.</returns>
    ///  <remarks>This operation may reduce precision.</remarks>
    class operator Negative(const AHalf: Half): Half; inline;

    ///  <summary>Overloded "=" operator.</summary>
    ///  <param name="ALeft">A <c>Half</c> value to compare.</param>
    ///  <param name="ARight">The <c>Half</c> value to compare to.</param>
    ///  <returns><c>True</c> if values are equal; <c>False</c> otherwise.</returns>
    class operator Equal(const ALeft, ARight: Half): Boolean; inline;

    ///  <summary>Overloded "=" operator.</summary>
    ///  <param name="ALeft">A <c>Half</c> value to compare.</param>
    ///  <param name="ARight">The <c>Single</c> value to compare to.</param>
    ///  <returns><c>True</c> if values are equal; <c>False</c> otherwise.</returns>
    class operator Equal(const ALeft: Half; const ARight: Single): Boolean; inline;

    ///  <summary>Overloded "=" operator.</summary>
    ///  <param name="ALeft">A <c>Single</c> value to compare.</param>
    ///  <param name="ARight">The <c>Half</c> value to compare to.</param>
    ///  <returns><c>True</c> if values are equal; <c>False</c> otherwise.</returns>
    class operator Equal(const ALeft: Single; const ARight: Half): Boolean; inline;

    ///  <summary>Overloded "<>" operator.</summary>
    ///  <param name="ALeft">A <c>Half</c> value to compare.</param>
    ///  <param name="ARight">The <c>Half</c> value to compare to.</param>
    ///  <returns><c>True</c> if values are different; <c>False</c> otherwise.</returns>
    class operator NotEqual(const ALeft, ARight: Half): Boolean; inline;

    ///  <summary>Overloded "<>" operator.</summary>
    ///  <param name="ALeft">A <c>Half</c> value to compare.</param>
    ///  <param name="ARight">The <c>Single</c> value to compare to.</param>
    ///  <returns><c>True</c> if values are different; <c>False</c> otherwise.</returns>
    class operator NotEqual(const ALeft: Half; const ARight: Single): Boolean; inline;

    ///  <summary>Overloded "<>" operator.</summary>
    ///  <param name="ALeft">A <c>Single</c> value to compare.</param>
    ///  <param name="ARight">The <c>Half</c> value to compare to.</param>
    ///  <returns><c>True</c> if values are different; <c>False</c> otherwise.</returns>
    class operator NotEqual(const ALeft: Single; const ARight: Half): Boolean; inline;

    ///  <summary>Overloded "&gt;" operator.</summary>
    ///  <param name="ALeft">A <c>Half</c> value to compare.</param>
    ///  <param name="ARight">The <c>Half</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is greater than <paramref name="ARight"/>; <c>False</c> otherwise.</returns>
    class operator GreaterThan(const ALeft, ARight: Half): Boolean; inline;

    ///  <summary>Overloded "&gt;" operator.</summary>
    ///  <param name="ALeft">A <c>Half</c> value to compare.</param>
    ///  <param name="ARight">The <c>Single</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is greater than <paramref name="ARight"/>; <c>False</c> otherwise.</returns>
    class operator GreaterThan(const ALeft: Half; const ARight: Single): Boolean; inline;

    ///  <summary>Overloded "&gt;" operator.</summary>
    ///  <param name="ALeft">A <c>Single</c> value to compare.</param>
    ///  <param name="ARight">The <c>Single</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is greater than <paramref name="ARight"/>; <c>False</c> otherwise.</returns>
    class operator GreaterThan(const ALeft: Single; const ARight: Half): Boolean; inline;

    ///  <summary>Overloded "&gt;=" operator.</summary>
    ///  <param name="ALeft">A <c>Half</c> value to compare.</param>
    ///  <param name="ARight">The <c>Half</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is greater than or equal to <paramref name="ARight"/>;
    ///  <c>False</c> otherwise.</returns>
    class operator GreaterThanOrEqual(const ALeft, ARight: Half): Boolean; inline;

    ///  <summary>Overloded "&gt;=" operator.</summary>
    ///  <param name="ALeft">A <c>Half</c> value to compare.</param>
    ///  <param name="ARight">The <c>Single</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is greater than or equal to <paramref name="ARight"/>;
    ///  <c>False</c> otherwise.</returns>
    class operator GreaterThanOrEqual(const ALeft: Half; const ARight: Single): Boolean; inline;

    ///  <summary>Overloded "&gt;=" operator.</summary>
    ///  <param name="ALeft">A <c>Single</c> value to compare.</param>
    ///  <param name="ARight">The <c>Half</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is greater than or equal to <paramref name="ARight"/>;
    ///  <c>False</c> otherwise.</returns>
    class operator GreaterThanOrEqual(const ALeft: Single; const ARight: Half): Boolean; inline;

    ///  <summary>Overloded "&lt;" operator.</summary>
    ///  <param name="ALeft">A <c>Half</c> value to compare.</param>
    ///  <param name="ARight">The <c>Half</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is less than <paramref name="ARight"/>; <c>False</c> otherwise.</returns>
    class operator LessThan(const ALeft, ARight: Half): Boolean; inline;

    ///  <summary>Overloded "&lt;" operator.</summary>
    ///  <param name="ALeft">A <c>Half</c> value to compare.</param>
    ///  <param name="ARight">The <c>Single</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is less than <paramref name="ARight"/>; <c>False</c> otherwise.</returns>
    class operator LessThan(const ALeft: Half; const ARight: Single): Boolean; inline;

    ///  <summary>Overloded "&lt;" operator.</summary>
    ///  <param name="ALeft">A <c>Single</c> value to compare.</param>
    ///  <param name="ARight">The <c>Half</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is less than <paramref name="ARight"/>; <c>False</c> otherwise.</returns>
    class operator LessThan(const ALeft: Single; const ARight: Half): Boolean; inline;

    ///  <summary>Overloded "&lt;=" operator.</summary>
    ///  <param name="ALeft">A <c>Half</c> value to compare.</param>
    ///  <param name="ARight">The <c>Half</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is less than or equal to <paramref name="ARight"/>;
    ///  <c>False</c> otherwise.</returns>
    class operator LessThanOrEqual(const ALeft, ARight: Half): Boolean; inline;

    ///  <summary>Overloded "&lt;=" operator.</summary>
    ///  <param name="ALeft">A <c>Half</c> value to compare.</param>
    ///  <param name="ARight">The <c>Single</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is less than or equal to <paramref name="ARight"/>;
    ///  <c>False</c> otherwise.</returns>
    class operator LessThanOrEqual(const ALeft: Half; const ARight: Single): Boolean; inline;

    ///  <summary>Overloded "&lt;=" operator.</summary>
    ///  <param name="ALeft">A <c>Single</c> value to compare.</param>
    ///  <param name="ARight">The <c>Half</c> value to compare to.</param>
    ///  <returns><c>True</c> if <paramref name="ALeft"/> is less than or equal to <paramref name="ARight"/>;
    ///  <c>False</c> otherwise.</returns>
    class operator LessThanOrEqual(const ALeft: Single; const ARight: Half): Boolean; inline;

    ///  <summary>Returns the minimum allowed value that <c>Half</c> can store.</summary>
    ///  <returns>A <c>Half</c> value.</returns>
    class property Min: Half read GetMin;

    ///  <summary>Returns the maximum allowed value that <c>Half</c> can store.</summary>
    ///  <returns>A <c>Half</c> value.</returns>
    class property Max: Half read GetMax;

    ///  <summary>Returns the <c>Infinity</c>, as understood by the <c>Half</c> type.</summary>
    ///  <returns>A <c>Half</c> value.</returns>
    class property Infinity: Half read GetInfinity;

    ///  <summary>Returns the <c>-Infinity</c>, as understood by the <c>Half</c> type.</summary>
    ///  <returns>A <c>Half</c> value.</returns>
    class property MinusInfinity: Half read GetMinusInfinity;

    ///  <summary>Returns <c>0</c>.</summary>
    ///  <returns>A <c>Half</c> value containing zero.</returns>
    class property Zero: Half read GetZero;

    ///  <summary>Returns <c>-0</c>.</summary>
    ///  <returns>A <c>Half</c> value containing minus zero.</returns>
    class property MinusZero: Half read GetMinusZero;

    ///  <summary>Returns <c>1</c>.</summary>
    ///  <returns>A <c>Half</c> value containing one.</returns>
    class property One: Half read GetOne;

    ///  <summary>Returns <c>-1</c>.</summary>
    ///  <returns>A <c>Half</c> value containing minus one.</returns>
    class property MinusOne: Half read GetMinusOne;

    ///  <summary>Returns <c>10</c>.</summary>
    ///  <returns>A <c>Half</c> value containing ten.</returns>
    class property Ten: Half read GetTen;

    ///  <summary>Returns <c>-10</c>.</summary>
    ///  <returns>A <c>Half</c> value containing minus ten.</returns>
    class property MinusTen: Half read GetMinusTen;

    ///  <summary>Returns the DeHL type object for this type.</summary>
    ///  <returns>An <see cref="DeHL.Types|IType&lt;T&gt;">DeHL.Types.IType&lt;T&gt;</see> that represents
    ///  <see cref="DeHL.Math.Half|Half">DeHL.Math.Half.Half</see> type.</returns>
    class function GetType(): IType<Half>; static;
  end;

{ To be on the par with RTL }
const
  ///  <summary>Specifies the maximum allowed value that <c>Half</c> can store.</summary>
  ///  <returns>An <c>Extended</c> value.</returns>
  MaxHalf = 65504.0;

  ///  <summary>Specifies the minimum allowed value that <c>Half</c> can store.</summary>
  ///  <returns>An <c>Extended</c> value.</returns>
  MinHalf = 6.10352E-05;

implementation

type
  { BigInteger Support }
  THalfType = class(TRecordType<Half>)
  protected
    { Serialization }
    procedure DoSerialize(const AInfo: TValueInfo; const AValue: Half; const AContext: ISerializationContext); override;
    procedure DoDeserialize(const AInfo: TValueInfo; out AValue: Half; const AContext: IDeserializationContext); override;

  public
    { Comparator }
    function Compare(const AValue1, AValue2: Half): NativeInt; override;

    { Hash code provider }
    function GenerateHashCode(const AValue: Half): NativeInt; override;

    { Get String representation }
    function GetString(const AValue: Half): String; override;

    { Type information }
    function Family(): TTypeFamily; override;

    { Variant Conversion }
    function TryConvertToVariant(const AValue: Half; out ORes: Variant): Boolean; override;
    function TryConvertFromVariant(const AValue: Variant; out ORes: Half): Boolean; override;
  end;

  { Math extensions for the Single type }
  THalfMathExtension = class sealed(TRealMathExtension<Half>)
  public
    { Standard operations }
    function Add(const AValue1, AValue2: Half): Half; override;
    function Subtract(const AValue1, AValue2: Half): Half; override;
    function Multiply(const AValue1, AValue2: Half): Half; override;
    function Divide(const AValue1, AValue2: Half): Half; override;

    { Sign-related operations }
    function Negate(const AValue: Half): Half; override;
    function Abs(const AValue: Half): Half; override;

    { Neutral Math elements }
    function Zero: Half; override;
    function One: Half; override;
    function MinusOne: Half; override;
  end;

{
  The following arrays contain precalculed data to be used for super fast transformations between
  Single and Half. The algorithms are also based on these tables.

  The author of this solution is Jeroen van der Zijp:
  http://www.fox-toolkit.org/ftp/fasthalffloatconversion.pdf
}

const
  CMantissas: array[0 .. 2047] of Cardinal =
  (
		$00000000, $33800000, $34000000, $34400000, $34800000, $34A00000, $34C00000,
    $34E00000, $35000000, $35100000, $35200000, $35300000, $35400000, $35500000,
    $35600000, $35700000, $35800000, $35880000, $35900000, $35980000, $35A00000,
    $35A80000, $35B00000, $35B80000, $35C00000, $35C80000, $35D00000, $35D80000,
    $35E00000, $35E80000, $35F00000, $35F80000, $36000000, $36040000, $36080000,
    $360C0000, $36100000, $36140000, $36180000, $361C0000, $36200000, $36240000,
    $36280000, $362C0000, $36300000, $36340000, $36380000, $363C0000, $36400000,
    $36440000, $36480000, $364C0000, $36500000, $36540000, $36580000, $365C0000,
		$36600000, $36640000, $36680000, $366C0000, $36700000, $36740000, $36780000,
    $367C0000, $36800000, $36820000, $36840000, $36860000, $36880000, $368A0000,
    $368C0000, $368E0000, $36900000, $36920000, $36940000, $36960000, $36980000,
    $369A0000, $369C0000, $369E0000, $36A00000, $36A20000, $36A40000, $36A60000,
    $36A80000, $36AA0000, $36AC0000, $36AE0000, $36B00000, $36B20000, $36B40000,
    $36B60000, $36B80000, $36BA0000, $36BC0000, $36BE0000, $36C00000, $36C20000,
    $36C40000, $36C60000, $36C80000, $36CA0000, $36CC0000, $36CE0000, $36D00000,
    $36D20000, $36D40000, $36D60000, $36D80000, $36DA0000, $36DC0000, $36DE0000,
    $36E00000, $36E20000, $36E40000, $36E60000, $36E80000, $36EA0000, $36EC0000,
    $36EE0000, $36F00000, $36F20000, $36F40000, $36F60000, $36F80000, $36FA0000,
    $36FC0000, $36FE0000, $37000000, $37010000, $37020000, $37030000, $37040000,
    $37050000, $37060000, $37070000, $37080000, $37090000, $370A0000, $370B0000,
    $370C0000, $370D0000, $370E0000, $370F0000, $37100000, $37110000, $37120000,
    $37130000, $37140000, $37150000, $37160000, $37170000, $37180000, $37190000,
    $371A0000, $371B0000, $371C0000, $371D0000, $371E0000, $371F0000, $37200000,
    $37210000, $37220000, $37230000, $37240000, $37250000, $37260000, $37270000,
    $37280000, $37290000, $372A0000, $372B0000, $372C0000, $372D0000, $372E0000,
    $372F0000, $37300000, $37310000, $37320000, $37330000, $37340000, $37350000,
    $37360000, $37370000, $37380000, $37390000, $373A0000, $373B0000, $373C0000,
    $373D0000, $373E0000, $373F0000, $37400000, $37410000, $37420000, $37430000,
    $37440000, $37450000, $37460000, $37470000, $37480000, $37490000, $374A0000,
    $374B0000, $374C0000, $374D0000, $374E0000, $374F0000, $37500000, $37510000,
    $37520000, $37530000, $37540000, $37550000, $37560000, $37570000, $37580000,
    $37590000, $375A0000, $375B0000, $375C0000, $375D0000, $375E0000, $375F0000,
    $37600000, $37610000, $37620000, $37630000, $37640000, $37650000, $37660000,
    $37670000, $37680000, $37690000, $376A0000, $376B0000, $376C0000, $376D0000,
    $376E0000, $376F0000, $37700000, $37710000, $37720000, $37730000, $37740000,
    $37750000, $37760000, $37770000, $37780000, $37790000, $377A0000, $377B0000,
    $377C0000, $377D0000, $377E0000, $377F0000, $37800000, $37808000, $37810000,
    $37818000, $37820000, $37828000, $37830000, $37838000, $37840000, $37848000,
    $37850000, $37858000, $37860000, $37868000, $37870000, $37878000, $37880000,
    $37888000, $37890000, $37898000, $378A0000, $378A8000, $378B0000, $378B8000,
    $378C0000, $378C8000, $378D0000, $378D8000, $378E0000, $378E8000, $378F0000,
    $378F8000, $37900000, $37908000, $37910000, $37918000, $37920000, $37928000,
    $37930000, $37938000, $37940000, $37948000, $37950000, $37958000, $37960000,
    $37968000, $37970000, $37978000, $37980000, $37988000, $37990000, $37998000,
    $379A0000, $379A8000, $379B0000, $379B8000, $379C0000, $379C8000, $379D0000,
    $379D8000, $379E0000, $379E8000, $379F0000, $379F8000, $37A00000, $37A08000,
    $37A10000, $37A18000, $37A20000, $37A28000, $37A30000, $37A38000, $37A40000,
    $37A48000, $37A50000, $37A58000, $37A60000, $37A68000, $37A70000, $37A78000,
    $37A80000, $37A88000, $37A90000, $37A98000, $37AA0000, $37AA8000, $37AB0000,
    $37AB8000, $37AC0000, $37AC8000, $37AD0000, $37AD8000, $37AE0000, $37AE8000,
    $37AF0000, $37AF8000, $37B00000, $37B08000, $37B10000, $37B18000, $37B20000,
    $37B28000, $37B30000, $37B38000, $37B40000, $37B48000, $37B50000, $37B58000,
    $37B60000, $37B68000, $37B70000, $37B78000, $37B80000, $37B88000, $37B90000,
    $37B98000, $37BA0000, $37BA8000, $37BB0000, $37BB8000, $37BC0000, $37BC8000,
    $37BD0000, $37BD8000, $37BE0000, $37BE8000, $37BF0000, $37BF8000, $37C00000,
    $37C08000, $37C10000, $37C18000, $37C20000, $37C28000, $37C30000, $37C38000,
    $37C40000, $37C48000, $37C50000, $37C58000, $37C60000, $37C68000, $37C70000,
    $37C78000, $37C80000, $37C88000, $37C90000, $37C98000, $37CA0000, $37CA8000,
    $37CB0000, $37CB8000, $37CC0000, $37CC8000, $37CD0000, $37CD8000, $37CE0000,
    $37CE8000, $37CF0000, $37CF8000, $37D00000, $37D08000, $37D10000, $37D18000,
    $37D20000, $37D28000, $37D30000, $37D38000, $37D40000, $37D48000, $37D50000,
    $37D58000, $37D60000, $37D68000, $37D70000, $37D78000, $37D80000, $37D88000,
    $37D90000, $37D98000, $37DA0000, $37DA8000, $37DB0000, $37DB8000, $37DC0000,
    $37DC8000, $37DD0000, $37DD8000, $37DE0000, $37DE8000, $37DF0000, $37DF8000,
    $37E00000, $37E08000, $37E10000, $37E18000, $37E20000, $37E28000, $37E30000,
    $37E38000, $37E40000, $37E48000, $37E50000, $37E58000, $37E60000, $37E68000,
    $37E70000, $37E78000, $37E80000, $37E88000, $37E90000, $37E98000, $37EA0000,
    $37EA8000, $37EB0000, $37EB8000, $37EC0000, $37EC8000, $37ED0000, $37ED8000,
    $37EE0000, $37EE8000, $37EF0000, $37EF8000, $37F00000, $37F08000, $37F10000,
    $37F18000, $37F20000, $37F28000, $37F30000, $37F38000, $37F40000, $37F48000,
    $37F50000, $37F58000, $37F60000, $37F68000, $37F70000, $37F78000, $37F80000,
    $37F88000, $37F90000, $37F98000, $37FA0000, $37FA8000, $37FB0000, $37FB8000,
    $37FC0000, $37FC8000, $37FD0000, $37FD8000, $37FE0000, $37FE8000, $37FF0000,
    $37FF8000, $38000000, $38004000, $38008000, $3800C000, $38010000, $38014000,
    $38018000, $3801C000, $38020000, $38024000, $38028000, $3802C000, $38030000,
    $38034000, $38038000, $3803C000, $38040000, $38044000, $38048000, $3804C000,
    $38050000, $38054000, $38058000, $3805C000, $38060000, $38064000, $38068000,
    $3806C000, $38070000, $38074000, $38078000, $3807C000, $38080000, $38084000,
    $38088000, $3808C000, $38090000, $38094000, $38098000, $3809C000, $380A0000,
    $380A4000, $380A8000, $380AC000, $380B0000, $380B4000, $380B8000, $380BC000,
    $380C0000, $380C4000, $380C8000, $380CC000, $380D0000, $380D4000, $380D8000,
    $380DC000, $380E0000, $380E4000, $380E8000, $380EC000, $380F0000, $380F4000,
    $380F8000, $380FC000, $38100000, $38104000, $38108000, $3810C000, $38110000,
    $38114000, $38118000, $3811C000, $38120000, $38124000, $38128000, $3812C000,
    $38130000, $38134000, $38138000, $3813C000, $38140000, $38144000, $38148000,
    $3814C000, $38150000, $38154000, $38158000, $3815C000, $38160000, $38164000,
    $38168000, $3816C000, $38170000, $38174000, $38178000, $3817C000, $38180000,
    $38184000, $38188000, $3818C000, $38190000, $38194000, $38198000, $3819C000,
    $381A0000, $381A4000, $381A8000, $381AC000, $381B0000, $381B4000, $381B8000,
    $381BC000, $381C0000, $381C4000, $381C8000, $381CC000, $381D0000, $381D4000,
    $381D8000, $381DC000, $381E0000, $381E4000, $381E8000, $381EC000, $381F0000,
    $381F4000, $381F8000, $381FC000, $38200000, $38204000, $38208000, $3820C000,
    $38210000, $38214000, $38218000, $3821C000, $38220000, $38224000, $38228000,
    $3822C000, $38230000, $38234000, $38238000, $3823C000, $38240000, $38244000,
    $38248000, $3824C000, $38250000, $38254000, $38258000, $3825C000, $38260000,
    $38264000, $38268000, $3826C000, $38270000, $38274000, $38278000, $3827C000,
    $38280000, $38284000, $38288000, $3828C000, $38290000, $38294000, $38298000,
    $3829C000, $382A0000, $382A4000, $382A8000, $382AC000, $382B0000, $382B4000,
    $382B8000, $382BC000, $382C0000, $382C4000, $382C8000, $382CC000, $382D0000,
    $382D4000, $382D8000, $382DC000, $382E0000, $382E4000, $382E8000, $382EC000,
    $382F0000, $382F4000, $382F8000, $382FC000, $38300000, $38304000, $38308000,
    $3830C000, $38310000, $38314000, $38318000, $3831C000, $38320000, $38324000,
    $38328000, $3832C000, $38330000, $38334000, $38338000, $3833C000, $38340000,
    $38344000, $38348000, $3834C000, $38350000, $38354000, $38358000, $3835C000,
    $38360000, $38364000, $38368000, $3836C000, $38370000, $38374000, $38378000,
    $3837C000, $38380000, $38384000, $38388000, $3838C000, $38390000, $38394000,
    $38398000, $3839C000, $383A0000, $383A4000, $383A8000, $383AC000, $383B0000,
    $383B4000, $383B8000, $383BC000, $383C0000, $383C4000, $383C8000, $383CC000,
    $383D0000, $383D4000, $383D8000, $383DC000, $383E0000, $383E4000, $383E8000,
    $383EC000, $383F0000, $383F4000, $383F8000, $383FC000, $38400000, $38404000,
    $38408000, $3840C000, $38410000, $38414000, $38418000, $3841C000, $38420000,
    $38424000, $38428000, $3842C000, $38430000, $38434000, $38438000, $3843C000,
    $38440000, $38444000, $38448000, $3844C000, $38450000, $38454000, $38458000,
    $3845C000, $38460000, $38464000, $38468000, $3846C000, $38470000, $38474000,
    $38478000, $3847C000, $38480000, $38484000, $38488000, $3848C000, $38490000,
    $38494000, $38498000, $3849C000, $384A0000, $384A4000, $384A8000, $384AC000,
    $384B0000, $384B4000, $384B8000, $384BC000, $384C0000, $384C4000, $384C8000,
    $384CC000, $384D0000, $384D4000, $384D8000, $384DC000, $384E0000, $384E4000,
    $384E8000, $384EC000, $384F0000, $384F4000, $384F8000, $384FC000, $38500000,
    $38504000, $38508000, $3850C000, $38510000, $38514000, $38518000, $3851C000,
    $38520000, $38524000, $38528000, $3852C000, $38530000, $38534000, $38538000,
    $3853C000, $38540000, $38544000, $38548000, $3854C000, $38550000, $38554000,
    $38558000, $3855C000, $38560000, $38564000, $38568000, $3856C000, $38570000,
    $38574000, $38578000, $3857C000, $38580000, $38584000, $38588000, $3858C000,
    $38590000, $38594000, $38598000, $3859C000, $385A0000, $385A4000, $385A8000,
    $385AC000, $385B0000, $385B4000, $385B8000, $385BC000, $385C0000, $385C4000,
    $385C8000, $385CC000, $385D0000, $385D4000, $385D8000, $385DC000, $385E0000,
    $385E4000, $385E8000, $385EC000, $385F0000, $385F4000, $385F8000, $385FC000,
    $38600000, $38604000, $38608000, $3860C000, $38610000, $38614000, $38618000,
    $3861C000, $38620000, $38624000, $38628000, $3862C000, $38630000, $38634000,
    $38638000, $3863C000, $38640000, $38644000, $38648000, $3864C000, $38650000,
    $38654000, $38658000, $3865C000, $38660000, $38664000, $38668000, $3866C000,
    $38670000, $38674000, $38678000, $3867C000, $38680000, $38684000, $38688000,
    $3868C000, $38690000, $38694000, $38698000, $3869C000, $386A0000, $386A4000,
    $386A8000, $386AC000, $386B0000, $386B4000, $386B8000, $386BC000, $386C0000,
    $386C4000, $386C8000, $386CC000, $386D0000, $386D4000, $386D8000, $386DC000,
    $386E0000, $386E4000, $386E8000, $386EC000, $386F0000, $386F4000, $386F8000,
    $386FC000, $38700000, $38704000, $38708000, $3870C000, $38710000, $38714000,
    $38718000, $3871C000, $38720000, $38724000, $38728000, $3872C000, $38730000,
    $38734000, $38738000, $3873C000, $38740000, $38744000, $38748000, $3874C000,
    $38750000, $38754000, $38758000, $3875C000, $38760000, $38764000, $38768000,
    $3876C000, $38770000, $38774000, $38778000, $3877C000, $38780000, $38784000,
    $38788000, $3878C000, $38790000, $38794000, $38798000, $3879C000, $387A0000,
    $387A4000, $387A8000, $387AC000, $387B0000, $387B4000, $387B8000, $387BC000,
    $387C0000, $387C4000, $387C8000, $387CC000, $387D0000, $387D4000, $387D8000,
    $387DC000, $387E0000, $387E4000, $387E8000, $387EC000, $387F0000, $387F4000,
    $387F8000, $387FC000, $38000000, $38002000, $38004000, $38006000, $38008000,
    $3800A000, $3800C000, $3800E000, $38010000, $38012000, $38014000, $38016000,
    $38018000, $3801A000, $3801C000, $3801E000, $38020000, $38022000, $38024000,
    $38026000, $38028000, $3802A000, $3802C000, $3802E000, $38030000, $38032000,
    $38034000, $38036000, $38038000, $3803A000, $3803C000, $3803E000, $38040000,
    $38042000, $38044000, $38046000, $38048000, $3804A000, $3804C000, $3804E000,
    $38050000, $38052000, $38054000, $38056000, $38058000, $3805A000, $3805C000,
    $3805E000, $38060000, $38062000, $38064000, $38066000, $38068000, $3806A000,
    $3806C000, $3806E000, $38070000, $38072000, $38074000, $38076000, $38078000,
    $3807A000, $3807C000, $3807E000, $38080000, $38082000, $38084000, $38086000,
    $38088000, $3808A000, $3808C000, $3808E000, $38090000, $38092000, $38094000,
    $38096000, $38098000, $3809A000, $3809C000, $3809E000, $380A0000, $380A2000,
    $380A4000, $380A6000, $380A8000, $380AA000, $380AC000, $380AE000, $380B0000,
    $380B2000, $380B4000, $380B6000, $380B8000, $380BA000, $380BC000, $380BE000,
    $380C0000, $380C2000, $380C4000, $380C6000, $380C8000, $380CA000, $380CC000,
    $380CE000, $380D0000, $380D2000, $380D4000, $380D6000, $380D8000, $380DA000,
    $380DC000, $380DE000, $380E0000, $380E2000, $380E4000, $380E6000, $380E8000,
    $380EA000, $380EC000, $380EE000, $380F0000, $380F2000, $380F4000, $380F6000,
    $380F8000, $380FA000, $380FC000, $380FE000, $38100000, $38102000, $38104000,
    $38106000, $38108000, $3810A000, $3810C000, $3810E000, $38110000, $38112000,
    $38114000, $38116000, $38118000, $3811A000, $3811C000, $3811E000, $38120000,
    $38122000, $38124000, $38126000, $38128000, $3812A000, $3812C000, $3812E000,
    $38130000, $38132000, $38134000, $38136000, $38138000, $3813A000, $3813C000,
    $3813E000, $38140000, $38142000, $38144000, $38146000, $38148000, $3814A000,
    $3814C000, $3814E000, $38150000, $38152000, $38154000, $38156000, $38158000,
    $3815A000, $3815C000, $3815E000, $38160000, $38162000, $38164000, $38166000,
    $38168000, $3816A000, $3816C000, $3816E000, $38170000, $38172000, $38174000,
    $38176000, $38178000, $3817A000, $3817C000, $3817E000, $38180000, $38182000,
    $38184000, $38186000, $38188000, $3818A000, $3818C000, $3818E000, $38190000,
    $38192000, $38194000, $38196000, $38198000, $3819A000, $3819C000, $3819E000,
    $381A0000, $381A2000, $381A4000, $381A6000, $381A8000, $381AA000, $381AC000,
    $381AE000, $381B0000, $381B2000, $381B4000, $381B6000, $381B8000, $381BA000,
    $381BC000, $381BE000, $381C0000, $381C2000, $381C4000, $381C6000, $381C8000,
    $381CA000, $381CC000, $381CE000, $381D0000, $381D2000, $381D4000, $381D6000,
    $381D8000, $381DA000, $381DC000, $381DE000, $381E0000, $381E2000, $381E4000,
    $381E6000, $381E8000, $381EA000, $381EC000, $381EE000, $381F0000, $381F2000,
    $381F4000, $381F6000, $381F8000, $381FA000, $381FC000, $381FE000, $38200000,
    $38202000, $38204000, $38206000, $38208000, $3820A000, $3820C000, $3820E000,
    $38210000, $38212000, $38214000, $38216000, $38218000, $3821A000, $3821C000,
    $3821E000, $38220000, $38222000, $38224000, $38226000, $38228000, $3822A000,
    $3822C000, $3822E000, $38230000, $38232000, $38234000, $38236000, $38238000,
    $3823A000, $3823C000, $3823E000, $38240000, $38242000, $38244000, $38246000,
    $38248000, $3824A000, $3824C000, $3824E000, $38250000, $38252000, $38254000,
    $38256000, $38258000, $3825A000, $3825C000, $3825E000, $38260000, $38262000,
    $38264000, $38266000, $38268000, $3826A000, $3826C000, $3826E000, $38270000,
    $38272000, $38274000, $38276000, $38278000, $3827A000, $3827C000, $3827E000,
    $38280000, $38282000, $38284000, $38286000, $38288000, $3828A000, $3828C000,
    $3828E000, $38290000, $38292000, $38294000, $38296000, $38298000, $3829A000,
    $3829C000, $3829E000, $382A0000, $382A2000, $382A4000, $382A6000, $382A8000,
    $382AA000, $382AC000, $382AE000, $382B0000, $382B2000, $382B4000, $382B6000,
    $382B8000, $382BA000, $382BC000, $382BE000, $382C0000, $382C2000, $382C4000,
    $382C6000, $382C8000, $382CA000, $382CC000, $382CE000, $382D0000, $382D2000,
    $382D4000, $382D6000, $382D8000, $382DA000, $382DC000, $382DE000, $382E0000,
    $382E2000, $382E4000, $382E6000, $382E8000, $382EA000, $382EC000, $382EE000,
    $382F0000, $382F2000, $382F4000, $382F6000, $382F8000, $382FA000, $382FC000,
    $382FE000, $38300000, $38302000, $38304000, $38306000, $38308000, $3830A000,
    $3830C000, $3830E000, $38310000, $38312000, $38314000, $38316000, $38318000,
    $3831A000, $3831C000, $3831E000, $38320000, $38322000, $38324000, $38326000,
    $38328000, $3832A000, $3832C000, $3832E000, $38330000, $38332000, $38334000,
    $38336000, $38338000, $3833A000, $3833C000, $3833E000, $38340000, $38342000,
    $38344000, $38346000, $38348000, $3834A000, $3834C000, $3834E000, $38350000,
    $38352000, $38354000, $38356000, $38358000, $3835A000, $3835C000, $3835E000,
    $38360000, $38362000, $38364000, $38366000, $38368000, $3836A000, $3836C000,
    $3836E000, $38370000, $38372000, $38374000, $38376000, $38378000, $3837A000,
    $3837C000, $3837E000, $38380000, $38382000, $38384000, $38386000, $38388000,
    $3838A000, $3838C000, $3838E000, $38390000, $38392000, $38394000, $38396000,
    $38398000, $3839A000, $3839C000, $3839E000, $383A0000, $383A2000, $383A4000,
    $383A6000, $383A8000, $383AA000, $383AC000, $383AE000, $383B0000, $383B2000,
    $383B4000, $383B6000, $383B8000, $383BA000, $383BC000, $383BE000, $383C0000,
    $383C2000, $383C4000, $383C6000, $383C8000, $383CA000, $383CC000, $383CE000,
    $383D0000, $383D2000, $383D4000, $383D6000, $383D8000, $383DA000, $383DC000,
    $383DE000, $383E0000, $383E2000, $383E4000, $383E6000, $383E8000, $383EA000,
    $383EC000, $383EE000, $383F0000, $383F2000, $383F4000, $383F6000, $383F8000,
    $383FA000, $383FC000, $383FE000, $38400000, $38402000, $38404000, $38406000,
    $38408000, $3840A000, $3840C000, $3840E000, $38410000, $38412000, $38414000,
    $38416000, $38418000, $3841A000, $3841C000, $3841E000, $38420000, $38422000,
    $38424000, $38426000, $38428000, $3842A000, $3842C000, $3842E000, $38430000,
    $38432000, $38434000, $38436000, $38438000, $3843A000, $3843C000, $3843E000,
    $38440000, $38442000, $38444000, $38446000, $38448000, $3844A000, $3844C000,
    $3844E000, $38450000, $38452000, $38454000, $38456000, $38458000, $3845A000,
    $3845C000, $3845E000, $38460000, $38462000, $38464000, $38466000, $38468000,
    $3846A000, $3846C000, $3846E000, $38470000, $38472000, $38474000, $38476000,
    $38478000, $3847A000, $3847C000, $3847E000, $38480000, $38482000, $38484000,
    $38486000, $38488000, $3848A000, $3848C000, $3848E000, $38490000, $38492000,
    $38494000, $38496000, $38498000, $3849A000, $3849C000, $3849E000, $384A0000,
    $384A2000, $384A4000, $384A6000, $384A8000, $384AA000, $384AC000, $384AE000,
    $384B0000, $384B2000, $384B4000, $384B6000, $384B8000, $384BA000, $384BC000,
    $384BE000, $384C0000, $384C2000, $384C4000, $384C6000, $384C8000, $384CA000,
    $384CC000, $384CE000, $384D0000, $384D2000, $384D4000, $384D6000, $384D8000,
    $384DA000, $384DC000, $384DE000, $384E0000, $384E2000, $384E4000, $384E6000,
    $384E8000, $384EA000, $384EC000, $384EE000, $384F0000, $384F2000, $384F4000,
    $384F6000, $384F8000, $384FA000, $384FC000, $384FE000, $38500000, $38502000,
    $38504000, $38506000, $38508000, $3850A000, $3850C000, $3850E000, $38510000,
    $38512000, $38514000, $38516000, $38518000, $3851A000, $3851C000, $3851E000,
    $38520000, $38522000, $38524000, $38526000, $38528000, $3852A000, $3852C000,
    $3852E000, $38530000, $38532000, $38534000, $38536000, $38538000, $3853A000,
    $3853C000, $3853E000, $38540000, $38542000, $38544000, $38546000, $38548000,
    $3854A000, $3854C000, $3854E000, $38550000, $38552000, $38554000, $38556000,
    $38558000, $3855A000, $3855C000, $3855E000, $38560000, $38562000, $38564000,
    $38566000, $38568000, $3856A000, $3856C000, $3856E000, $38570000, $38572000,
    $38574000, $38576000, $38578000, $3857A000, $3857C000, $3857E000, $38580000,
    $38582000, $38584000, $38586000, $38588000, $3858A000, $3858C000, $3858E000,
    $38590000, $38592000, $38594000, $38596000, $38598000, $3859A000, $3859C000,
    $3859E000, $385A0000, $385A2000, $385A4000, $385A6000, $385A8000, $385AA000,
    $385AC000, $385AE000, $385B0000, $385B2000, $385B4000, $385B6000, $385B8000,
    $385BA000, $385BC000, $385BE000, $385C0000, $385C2000, $385C4000, $385C6000,
    $385C8000, $385CA000, $385CC000, $385CE000, $385D0000, $385D2000, $385D4000,
    $385D6000, $385D8000, $385DA000, $385DC000, $385DE000, $385E0000, $385E2000,
    $385E4000, $385E6000, $385E8000, $385EA000, $385EC000, $385EE000, $385F0000,
    $385F2000, $385F4000, $385F6000, $385F8000, $385FA000, $385FC000, $385FE000,
    $38600000, $38602000, $38604000, $38606000, $38608000, $3860A000, $3860C000,
    $3860E000, $38610000, $38612000, $38614000, $38616000, $38618000, $3861A000,
    $3861C000, $3861E000, $38620000, $38622000, $38624000, $38626000, $38628000,
    $3862A000, $3862C000, $3862E000, $38630000, $38632000, $38634000, $38636000,
    $38638000, $3863A000, $3863C000, $3863E000, $38640000, $38642000, $38644000,
    $38646000, $38648000, $3864A000, $3864C000, $3864E000, $38650000, $38652000,
    $38654000, $38656000, $38658000, $3865A000, $3865C000, $3865E000, $38660000,
    $38662000, $38664000, $38666000, $38668000, $3866A000, $3866C000, $3866E000,
		$38670000, $38672000, $38674000, $38676000, $38678000, $3867A000, $3867C000,
    $3867E000, $38680000, $38682000, $38684000, $38686000, $38688000, $3868A000,
    $3868C000, $3868E000, $38690000, $38692000, $38694000, $38696000, $38698000,
    $3869A000, $3869C000, $3869E000, $386A0000, $386A2000, $386A4000, $386A6000,
    $386A8000, $386AA000, $386AC000, $386AE000, $386B0000, $386B2000, $386B4000,
    $386B6000, $386B8000, $386BA000, $386BC000, $386BE000, $386C0000, $386C2000,
    $386C4000, $386C6000, $386C8000, $386CA000, $386CC000, $386CE000, $386D0000,
    $386D2000, $386D4000, $386D6000, $386D8000, $386DA000, $386DC000, $386DE000,
    $386E0000, $386E2000, $386E4000, $386E6000, $386E8000, $386EA000, $386EC000,
    $386EE000, $386F0000, $386F2000, $386F4000, $386F6000, $386F8000, $386FA000,
    $386FC000, $386FE000, $38700000, $38702000, $38704000, $38706000, $38708000,
    $3870A000, $3870C000, $3870E000, $38710000, $38712000, $38714000, $38716000,
    $38718000, $3871A000, $3871C000, $3871E000, $38720000, $38722000, $38724000,
    $38726000, $38728000, $3872A000, $3872C000, $3872E000, $38730000, $38732000,
    $38734000, $38736000, $38738000, $3873A000, $3873C000, $3873E000, $38740000,
    $38742000, $38744000, $38746000, $38748000, $3874A000, $3874C000, $3874E000,
    $38750000, $38752000, $38754000, $38756000, $38758000, $3875A000, $3875C000,
    $3875E000, $38760000, $38762000, $38764000, $38766000, $38768000, $3876A000,
    $3876C000, $3876E000, $38770000, $38772000, $38774000, $38776000, $38778000,
    $3877A000, $3877C000, $3877E000, $38780000, $38782000, $38784000, $38786000,
    $38788000, $3878A000, $3878C000, $3878E000, $38790000, $38792000, $38794000,
    $38796000, $38798000, $3879A000, $3879C000, $3879E000, $387A0000, $387A2000,
    $387A4000, $387A6000, $387A8000, $387AA000, $387AC000, $387AE000, $387B0000,
    $387B2000, $387B4000, $387B6000, $387B8000, $387BA000, $387BC000, $387BE000,
    $387C0000, $387C2000, $387C4000, $387C6000, $387C8000, $387CA000, $387CC000,
    $387CE000, $387D0000, $387D2000, $387D4000, $387D6000, $387D8000, $387DA000,
    $387DC000, $387DE000, $387E0000, $387E2000, $387E4000, $387E6000, $387E8000,
    $387EA000, $387EC000, $387EE000, $387F0000, $387F2000, $387F4000, $387F6000,
    $387F8000, $387FA000, $387FC000, $387FE000
  );

  CExponents: array[0 .. 63] of Cardinal =
  (
		$00000000, $00800000, $01000000, $01800000, $02000000, $02800000, $03000000,
    $03800000, $04000000, $04800000, $05000000, $05800000, $06000000, $06800000,
    $07000000, $07800000, $08000000, $08800000, $09000000, $09800000, $0A000000,
    $0A800000, $0B000000, $0B800000, $0C000000, $0C800000, $0D000000, $0D800000,
    $0E000000, $0E800000, $0F000000, $47800000, $80000000, $80800000, $81000000,
    $81800000, $82000000, $82800000, $83000000, $83800000, $84000000, $84800000,
    $85000000, $85800000, $86000000, $86800000, $87000000, $87800000, $88000000,
    $88800000, $89000000, $89800000, $8A000000, $8A800000, $8B000000, $8B800000,
    $8C000000, $8C800000, $8D000000, $8D800000, $8E000000, $8E800000, $8F000000,
    $C7800000
  );

  COffsets: array[0 .. 63] of Cardinal =
  (
		$00000000, $00000400, $00000400, $00000400, $00000400, $00000400, $00000400,
    $00000400, $00000400, $00000400, $00000400, $00000400, $00000400, $00000400,
    $00000400, $00000400, $00000400, $00000400, $00000400, $00000400, $00000400,
    $00000400, $00000400, $00000400, $00000400, $00000400, $00000400, $00000400,
    $00000400, $00000400, $00000400, $00000400, $00000000, $00000400, $00000400,
    $00000400, $00000400, $00000400, $00000400, $00000400, $00000400, $00000400,
    $00000400, $00000400, $00000400, $00000400, $00000400, $00000400, $00000400,
    $00000400, $00000400, $00000400, $00000400, $00000400, $00000400, $00000400,
    $00000400, $00000400, $00000400, $00000400, $00000400, $00000400, $00000400,
    $00000400
  );

  CBases: array[0 .. 511] of Cardinal =
  (
		$00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000,
    $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000,
    $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000,
    $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000,
    $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000,
    $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000,
    $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000,
    $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000,
    $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000,
    $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000,
    $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000,
    $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000,
    $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000,
    $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $00000000,
    $00000000, $00000000, $00000000, $00000000, $00000000, $00000001, $00000002,
    $00000004, $00000008, $00000010, $00000020, $00000040, $00000080, $00000100,
    $00000200, $00000400, $00000800, $00000C00, $00001000, $00001400, $00001800,
    $00001C00, $00002000, $00002400, $00002800, $00002C00, $00003000, $00003400,
    $00003800, $00003C00, $00004000, $00004400, $00004800, $00004C00, $00005000,
    $00005400, $00005800, $00005C00, $00006000, $00006400, $00006800, $00006C00,
    $00007000, $00007400, $00007800, $00007C00, $00007C00, $00007C00, $00007C00,
    $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00,
    $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00,
    $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00,
    $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00,
    $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00,
    $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00,
    $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00,
    $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00,
    $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00,
    $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00,
    $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00,
    $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00,
    $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00,
    $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00,
    $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00, $00007C00,
    $00007C00, $00007C00, $00007C00, $00007C00, $00008000, $00008000, $00008000,
    $00008000, $00008000, $00008000, $00008000, $00008000, $00008000, $00008000,
    $00008000, $00008000, $00008000, $00008000, $00008000, $00008000, $00008000,
    $00008000, $00008000, $00008000, $00008000, $00008000, $00008000, $00008000,
    $00008000, $00008000, $00008000, $00008000, $00008000, $00008000, $00008000,
    $00008000, $00008000, $00008000, $00008000, $00008000, $00008000, $00008000,
    $00008000, $00008000, $00008000, $00008000, $00008000, $00008000, $00008000,
    $00008000, $00008000, $00008000, $00008000, $00008000, $00008000, $00008000,
    $00008000, $00008000, $00008000, $00008000, $00008000, $00008000, $00008000,
    $00008000, $00008000, $00008000, $00008000, $00008000, $00008000, $00008000,
    $00008000, $00008000, $00008000, $00008000, $00008000, $00008000, $00008000,
    $00008000, $00008000, $00008000, $00008000, $00008000, $00008000, $00008000,
    $00008000, $00008000, $00008000, $00008000, $00008000, $00008000, $00008000,
    $00008000, $00008000, $00008000, $00008000, $00008000, $00008000, $00008000,
    $00008000, $00008000, $00008000, $00008000, $00008000, $00008000, $00008000,
    $00008000, $00008000, $00008001, $00008002, $00008004, $00008008, $00008010,
    $00008020, $00008040, $00008080, $00008100, $00008200, $00008400, $00008800,
    $00008C00, $00009000, $00009400, $00009800, $00009C00, $0000A000, $0000A400,
    $0000A800, $0000AC00, $0000B000, $0000B400, $0000B800, $0000BC00, $0000C000,
    $0000C400, $0000C800, $0000CC00, $0000D000, $0000D400, $0000D800, $0000DC00,
    $0000E000, $0000E400, $0000E800, $0000EC00, $0000F000, $0000F400, $0000F800,
    $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00,
    $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00,
    $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00,
    $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00,
    $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00,
    $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00,
    $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00,
    $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00,
    $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00,
    $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00,
    $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00,
    $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00,
    $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00,
    $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00,
    $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00,
    $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00, $0000FC00,
    $0000FC00
  );

  CShifts: array[0 .. 511] of Cardinal =
  (
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000017, $00000016, $00000015, $00000014, $00000013,
		$00000012, $00000011, $00000010, $0000000F, $0000000E, $0000000D,
		$0000000D, $0000000D, $0000000D, $0000000D, $0000000D, $0000000D,
		$0000000D, $0000000D, $0000000D, $0000000D, $0000000D, $0000000D,
		$0000000D, $0000000D, $0000000D, $0000000D, $0000000D, $0000000D,
		$0000000D, $0000000D, $0000000D, $0000000D, $0000000D, $0000000D,
		$0000000D, $0000000D, $0000000D, $0000000D, $0000000D, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $0000000D, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000017,
		$00000016, $00000015, $00000014, $00000013, $00000012, $00000011,
		$00000010, $0000000F, $0000000E, $0000000D, $0000000D, $0000000D,
		$0000000D, $0000000D, $0000000D, $0000000D, $0000000D, $0000000D,
		$0000000D, $0000000D, $0000000D, $0000000D, $0000000D, $0000000D,
		$0000000D, $0000000D, $0000000D, $0000000D, $0000000D, $0000000D,
		$0000000D, $0000000D, $0000000D, $0000000D, $0000000D, $0000000D,
		$0000000D, $0000000D, $0000000D, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $00000018, $00000018, $00000018, $00000018, $00000018,
		$00000018, $0000000D
  );

{ Half }

class operator Half.Add(const ALeft, ARight: Half): Half;
begin
  { Add converting to single }
  Result := Single(ALeft) + Single(ARight);
end;


class operator Half.Add(const ALeft: Half; const ARight: Single): Half;
begin
  { Add }
  Result := Single(ALeft) + ARight;
end;

class operator Half.Add(const ALeft: Single; const ARight: Half): Half;
begin
  { Add }
  Result := ALeft + Single(ARight);
end;

class constructor Half.Create;
begin
  TType<Half>.Register(THalfType);
  TMathExtension<Half>.Register(THalfMathExtension);
end;

class destructor Half.Destroy;
begin
  { Unregister DeHL stuff (math extension goes first) }
  TMathExtension<Half>.Unregister();
  TType<Half>.Unregister();
end;

class operator Half.Divide(const ALeft: Single; const ARight: Half): Half;
begin
  { Divide }
  Result := ALeft / Single(ARight);
end;

class operator Half.Equal(const ALeft: Single; const ARight: Half): Boolean;
begin
  Result := ALeft = Single(ARight);
end;

class operator Half.Equal(const ALeft: Half; const ARight: Single): Boolean;
begin
  Result := Single(ALeft) = ARight;
end;

class operator Half.Equal(const ALeft, ARight: Half): Boolean;
begin
  Result := Single(ALeft) = Single(ARight);
end;

class operator Half.Divide(const ALeft: Half; const ARight: Single): Half;
begin
  { Divide }
  Result := Single(ALeft) / ARight;
end;

class operator Half.Divide(const ALeft, ARight: Half): Half;
begin
  { Divide converting to single }
  Result := Single(ALeft) / Single(ARight);
end;

class function Half.GetInfinity: Half;
begin
  Result.FWord := CInfinity;
end;

class function Half.GetMax: Half;
begin
  Result.FWord := CMax;
end;

class function Half.GetMin: Half;
begin
  Result.FWord := CMin;
end;

class function Half.GetMinusInfinity: Half;
begin
  Result.FWord := CMinusInfinity;
end;

class function Half.GetMinusOne: Half;
begin
  Result.FWord := CMinusOne;
end;

class function Half.GetMinusTen: Half;
begin
  Result.FWord := CMinusTen;
end;

class function Half.GetMinusZero: Half;
begin
  Result.FWord := CMinusZero;
end;

class function Half.GetOne: Half;
begin
  Result.FWord := COne;
end;

class function Half.GetTen: Half;
begin
  Result.FWord := CTen;
end;

class function Half.GetType: IType<Half>;
begin
  { Simple as usual }
  Result := THalfType.Create;
end;

class function Half.GetZero: Half;
begin
  Result.FWord := CZero;
end;

class operator Half.GreaterThan(const ALeft, ARight: Half): Boolean;
begin
  Result := Single(ALeft) > Single(ARight);
end;

class operator Half.GreaterThan(const ALeft: Half; const ARight: Single): Boolean;
begin
  Result := Single(ALeft) > ARight;
end;

class operator Half.GreaterThan(const ALeft: Single; const ARight: Half): Boolean;
begin
  Result := ALeft > Single(ARight);
end;

class operator Half.GreaterThanOrEqual(const ALeft, ARight: Half): Boolean;
begin
  Result := Single(ALeft) >= Single(ARight);
end;

class operator Half.GreaterThanOrEqual(const ALeft: Half; const ARight: Single): Boolean;
begin
  Result := Single(ALeft) >= ARight;
end;

class operator Half.GreaterThanOrEqual(const ALeft: Single; const ARight: Half): Boolean;
begin
  Result := ALeft >= Single(ARight);
end;

class operator Half.Implicit(const AVariant: Variant): Half;
begin
  Result := Single(AVariant);
end;

class operator Half.Implicit(const AHalf: Half): Variant;
begin
  Result := Single(AHalf);
end;

class operator Half.Implicit(const AHalf: Half): Single;
var
  LIntFloat: Cardinal absolute Result; // You think absolute is not useful?
begin
  LIntFloat := CMantissas[COffsets[AHalf.FWord shr $000A] + (AHalf.FWord and $03FF)] + CExponents[AHalf.FWord shr $000A];
end;

class operator Half.LessThan(const ALeft: Single; const ARight: Half): Boolean;
begin
  Result := ALeft < Single(ARight);
end;

class operator Half.LessThan(const ALeft: Half; const ARight: Single): Boolean;
begin
  Result := Single(ALeft) < ARight;
end;

class operator Half.LessThan(const ALeft, ARight: Half): Boolean;
begin
  Result := Single(ALeft) < Single(ARight);
end;

class operator Half.LessThanOrEqual(const ALeft: Single;
  const ARight: Half): Boolean;
begin
  Result := ALeft <= Single(ARight);
end;

class operator Half.LessThanOrEqual(const ALeft: Half; const ARight: Single): Boolean;
begin
  Result := Single(ALeft) <= ARight;
end;

class operator Half.LessThanOrEqual(const ALeft, ARight: Half): Boolean;
begin
  Result := Single(ALeft) <= Single(ARight);
end;

class operator Half.Multiply(const ALeft: Single; const ARight: Half): Half;
begin
  { Multiply }
  Result := ALeft * Single(ARight);
end;

class operator Half.Multiply(const ALeft: Half; const ARight: Single): Half;
begin
  { Multiply }
  Result := Single(ALeft) * ARight;
end;

class operator Half.Implicit(const AFloat: Single): Half;
var
  LIntFloat: Cardinal absolute AFloat; // You think absolute is not useful?
begin
  { Use the tables for convertions }
  Result.FWord := CBases[LIntFloat shr 23] + ((LIntFloat and $007FFFFF) shr CShifts[LIntFloat shr 23]);
end;

class operator Half.Multiply(const ALeft, ARight: Half): Half;
begin
  { Multiply converting to single }
  Result := Single(ALeft) * Single(ARight);
end;

class operator Half.Negative(const AHalf: Half): Half;
begin
  Result.FWord := AHalf.FWord xor $8000; // Invert the sign bit
end;

class operator Half.NotEqual(const ALeft: Single; const ARight: Half): Boolean;
begin
  Result := (Half(ALeft).FWord <> ARight.FWord);
end;

class operator Half.NotEqual(const ALeft: Half; const ARight: Single): Boolean;
begin
  Result := (ALeft.FWord <> Half(ARight).FWord);
end;

class operator Half.NotEqual(const ALeft, ARight: Half): Boolean;
begin
  Result := (ALeft.FWord <> ARight.FWord);
end;

class operator Half.Positive(const AHalf: Half): Half;
begin
  { Do Nothing }
  Result := AHalf;
end;

class operator Half.Subtract(const ALeft: Half; const ARight: Single): Half;
begin
  { Subtract }
  Result := Single(ALeft) - ARight;
end;

class operator Half.Subtract(const ALeft: Single; const ARight: Half): Half;
begin
  { Subtract }
  Result := ALeft - Single(ARight);
end;

class operator Half.Subtract(const ALeft, ARight: Half): Half;
begin
  { Subtract converting to single }
  Result := Single(ALeft) - Single(ARight);
end;

{ THalfType }

function THalfType.Compare(const AValue1, AValue2: Half): NativeInt;
begin
  if AValue1 < AValue2 then
     Result := -1
  else if AValue1 > AValue2 then
     Result := 1
  else
     Result := 0;
end;

procedure THalfType.DoDeserialize(const AInfo: TValueInfo; out AValue: Half; const AContext: IDeserializationContext);
var
  LSingle: Single;
begin
  { Read as Single or as Word }
  if AContext.InReadableForm then
  begin
    AContext.GetValue(AInfo, LSingle);
    AValue := LSingle;
  end else
    AContext.GetValue(AInfo, AValue.FWord);
end;

procedure THalfType.DoSerialize(const AInfo: TValueInfo; const AValue: Half; const AContext: ISerializationContext);
begin
  { Either serialize as a Single or as a Word }
  if AContext.InReadableForm then
    AContext.AddValue(AInfo, Single(AValue))
  else
    AContext.AddValue(AInfo, AValue.FWord);
end;

function THalfType.Family: TTypeFamily;
begin
  Result := tfReal;
end;

function THalfType.GenerateHashCode(const AValue: Half): NativeInt;
begin
  Result := AValue.FWord;
end;

function THalfType.GetString(const AValue: Half): String;
begin
  Result := FloatToStr(Single(AValue));
end;

function THalfType.TryConvertFromVariant(const AValue: Variant; out ORes: Half): Boolean;
begin
  { Variant type-cast }
  try
    ORes := AValue;
  except
    Exit(false);
  end;

  Result := true;
end;

function THalfType.TryConvertToVariant(const AValue: Half; out ORes: Variant): Boolean;
begin
  { Simple variant assignment }
  ORes := AValue;
  Result := true;
end;

{ THalfMathExtension }

function THalfMathExtension.Abs(const AValue: Half): Half;
begin
  Result := System.Abs(AValue);
end;

function THalfMathExtension.Add(const AValue1, AValue2: Half): Half;
begin
  Result := AValue1 + AValue2;
end;

function THalfMathExtension.Divide(const AValue1, AValue2: Half): Half;
begin
  Result := AValue1 / AValue2;
end;

function THalfMathExtension.MinusOne: Half;
begin
  Result := Half.MinusOne;
end;

function THalfMathExtension.Multiply(const AValue1, AValue2: Half): Half;
begin
  Result := AValue1 * AValue2;
end;

function THalfMathExtension.Negate(const AValue: Half): Half;
begin
  Result := -AValue;
end;

function THalfMathExtension.One: Half;
begin
  Result := Half.One;
end;

function THalfMathExtension.Subtract(const AValue1, AValue2: Half): Half;
begin
  Result := AValue1 - AValue2;
end;

function THalfMathExtension.Zero: Half;
begin
  Result := Half.Zero;
end;

end.
