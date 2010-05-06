{$IFDEF HKStreamRoutines}
	{$DEFINE DEBUG_UNIT}
{$ENDIF}
{$I StFLib.inc}
 {$TYPEDADDRESS OFF} //{$T-}

{ TODO -oRoger -cLIB : Remover problemas de compatibilidade }
//**********************************************************************
{$WARNINGS OFF}
//**********************************************************************

unit HKStreamRoutines;

{
----------------------------------------------------------------
THKStreams v1.7 by Harry Kakoulidis 01/2002
prog@xarka.com
http://www.xarka.com/prog/

This is Freeware. Please copy HKStrm17.zip unchanged.
If you find bugs, have options etc. Please send at my e-mail.

The use of this component is at your own risk.
I do not take any responsibility for any damages.

----------------------------------------------------------------

This unit contains code for compressing (LHA) and encrypting
(BLOWFISH). 90% Of this file wasn't written by me, but I copyed it
from other freeware units. I Just added code mostly to make them
usefull for streams (The blowfish implementation needed some work;
LHA Compression routines where ready.

*** LHA Compression

 Source File Name              :  X2000fc.PAS (original lh5unit.pas)
 Author (Modified by)          :  Gregory L. Bullock
 The algorithm was created by  :  Haruhiko Okomura and Haruyasu Yoshizaki.

*** Blowfish

- designed by Bruce Schneier
- adaption to Delphi by Steffen Kirbach and Others
    kirbach@t-online.de
    home.t-online.de/home/kirbach

}


{$DEFINE PERCOLATE}
{.$B-,R-,S-}
{.$A-,D-,I-,L-,O+,Q-,R-,S-,W-,Y-,Z1}

interface

uses
    SysUtils, Classes;

procedure LHACompress(InStr, OutStr : TStream);
procedure LHAExpand(InStr, OutStr : TStream);
procedure EncryptStream(MS : TMemoryStream; const Key : string);
procedure DecryptStream(ms : TmemoryStream; const Key : string);



function Blowfish_Init(pKey : Pointer; unKeySize : Byte; pBoxes : Pointer; unRounds : Byte) : Boolean;
procedure Blowfish_Done;
procedure Blowfish_ECBEncrypt(pBuffer : Pointer; unCount : Integer);
procedure Blowfish_ECBDecrypt(pBuffer : Pointer; unCount : Integer);
procedure Blowfish_CBCEncrypt(pBuffer : Pointer; unCount : Integer; var ulCBCLeft, ulCBCRight : LongInt);
procedure Blowfish_CBCDecrypt(pBuffer : Pointer; unCount : Integer; var ulCBCLeft, ulCBCRight : LongInt);
function Blowfish_GetBoxPointer : Pointer;

implementation

uses HKStreamCol;

{ *************************************************************** }

type
    TBoxes = record
        PBox: array[1..34] of LongInt;
        SBox1: array[1..$100] of LongInt;
        SBox2: array[1..$100] of LongInt;
        SBox3: array[1..$100] of LongInt;
        SBox4: array[1..$100] of LongInt;
    end;



type
    T64BitArray = array[1..(MaxInt div 8), 0..1] of LongInt;

const
    Pi_Boxes: TBoxes = (PBox: ($243f6a88, $85a308d3, $13198a2e, $03707344,
        $a4093822, $299f31d0, $082efa98, $ec4e6c89,
        $452821e6, $38d01377, $be5466cf, $34e90c6c,
        $c0ac29b7, $c97c50dd, $3f84d5b5, $b5470917,
        $9216d5d9, $8979fb1b, $B83ACB02, $2002397A,
        $6EC6FB5B, $FFCFD4DD, $4CBF5ED1, $F43FE582,
        $3EF4E823, $2D152AF0, $E718C970, $59BD9820,
        $1F4A9D62, $E7A529BA, $89E1248D, $3BF88656,
        $C5114D0E, $BC4CEE16);

        SBox1: ($d1310ba6, $98dfb5ac, $2ffd72db, $d01adfb7,
        $b8e1afed, $6a267e96, $ba7c9045, $f12c7f99,
        $24a19947, $b3916cf7, $0801f2e2, $858efc16,
        $636920d8, $71574e69, $a458fea3, $f4933d7e,
        $0d95748f, $728eb658, $718bcd58, $82154aee,
        $7b54a41d, $c25a59b5, $9c30d539, $2af26013,
		$c5d1b023, $286085f0, $ca417918, $b8db38ef,
        $8e79dcb0, $603a180e, $6c9e0e8b, $b01e8a3e,
        $d71577c1, $bd314b27, $78af2fda, $55605c60,
        $e65525f3, $aa55ab94, $57489862, $63e81440,
        $55ca396a, $2aab10b6, $b4cc5c34, $1141e8ce,
        $a15486af, $7c72e993, $b3ee1411, $636fbc2a,
        $2ba9c55d, $741831f6, $ce5c3e16, $9b87931e,
        $afd6ba33, $6c24cf5c, $7a325381, $28958677,
        $3b8f4898, $6b4bb9af, $c4bfe81b, $66282193,
        $61d809cc, $fb21a991, $487cac60, $5dec8032,
        $ef845d5d, $e98575b1, $dc262302, $eb651b88,
        $23893e81, $d396acc5, $0f6d6ff3, $83f44239,
        $2e0b4482, $a4842004, $69c8f04a, $9e1f9b5e,
        $21c66842, $f6e96c9a, $670c9c61, $abd388f0,
        $6a51a0d2, $d8542f68, $960fa728, $ab5133a3,
        $6eef0b6c, $137a3be4, $ba3bf050, $7efb2a98,
        $a1f1651d, $39af0176, $66ca593e, $82430e88,
        $8cee8619, $456f9fb4, $7d84a5c3, $3b8b5ebe,
        $e06f75d8, $85c12073, $401a449f, $56c16aa6,
        $4ed3aa62, $363f7706, $1bfedf72, $429b023d,
        $37d0d724, $d00a1248, $db0fead3, $49f1c09b,
        $075372c9, $80991b7b, $25d479d8, $f6e8def7,
        $e3fe501a, $b6794c3b, $976ce0bd, $04c006ba,
        $c1a94fb6, $409f60c4, $5e5c9ec2, $196a2463,
        $68fb6faf, $3e6c53b5, $1339b2eb, $3b52ec6f,
        $6dfc511f, $9b30952c, $cc814544, $af5ebd09,
        $bee3d004, $de334afd, $660f2807, $192e4bb3,
        $c0cba857, $45c8740f, $d20b5f39, $b9d3fbdb,
        $5579c0bd, $1a60320a, $d6a100c6, $402c7279,
        $679f25fe, $fb1fa3cc, $8ea5e9f8, $db3222f8,
        $3c7516df, $fd616b15, $2f501ec8, $ad0552ab,
        $323db5fa, $fd238760, $53317b48, $3e00df82,
        $9e5c57bb, $ca6f8ca0, $1a87562e, $df1769db,
        $d542a8f6, $287effc3, $ac6732c6, $8c4f5573,
        $695b27b0, $bbca58c8, $e1ffa35d, $b8f011a0,
        $10fa3d98, $fd2183b8, $4afcb56c, $2dd1d35b,
        $9a53e479, $b6f84565, $d28e49bc, $4bfb9790,
        $e1ddf2da, $a4cb7e33, $62fb1341, $cee4c6e8,
        $ef20cada, $36774c01, $d07e9efe, $2bf11fb4,
        $95dbda4d, $ae909198, $eaad8e71, $6b93d5a0,
        $d08ed1d0, $afc725e0, $8e3c5b2f, $8e7594b7,
        $8ff6e2fb, $f2122b64, $8888b812, $900df01c,
        $4fad5ea0, $688fc31c, $d1cff191, $b3a8c1ad,
        $2f2f2218, $be0e1777, $ea752dfe, $8b021fa1,
        $e5a0cc0f, $b56f74e8, $18acf3d6, $ce89e299,
		$b4a84fe0, $fd13e0b7, $7cc43b81, $d2ada8d9,
        $165fa266, $80957705, $93cc7314, $211a1477,
        $e6ad2065, $77b5fa86, $c75442f5, $fb9d35cf,
        $ebcdaf0c, $7b3e89a0, $d6411bd3, $ae1e7e49,
        $00250e2d, $2071b35e, $226800bb, $57b8e0af,
        $2464369b, $f009b91e, $5563911d, $59dfa6aa,
        $78c14389, $d95a537f, $207d5ba2, $02e5b9c5,
        $83260376, $6295cfa9, $11c81968, $4e734a41,
        $b3472dca, $7b14a94a, $1b510052, $9a532915,
        $d60f573f, $bc9bc6e4, $2b60a476, $81e67400,
        $08ba6fb5, $571be91f, $f296ec6b, $2a0dd915,
        $b6636521, $e7b9f9b6, $ff34052e, $c5855664,
        $53b02d5d, $a99f8fa1, $08ba4799, $6e85076a);

        SBox2: ($4b7a70e9, $b5b32944, $db75092e, $c4192623,
        $ad6ea6b0, $49a7df7d, $9cee60b8, $8fedb266,
        $ecaa8c71, $699a17ff, $5664526c, $c2b19ee1,
        $193602a5, $75094c29, $a0591340, $e4183a3e,
        $3f54989a, $5b429d65, $6b8fe4d6, $99f73fd6,
        $a1d29c07, $efe830f5, $4d2d38e6, $f0255dc1,
        $4cdd2086, $8470eb26, $6382e9c6, $021ecc5e,
        $09686b3f, $3ebaefc9, $3c971814, $6b6a70a1,
        $687f3584, $52a0e286, $b79c5305, $aa500737,
        $3e07841c, $7fdeae5c, $8e7d44ec, $5716f2b8,
        $b03ada37, $f0500c0d, $f01c1f04, $0200b3ff,
        $ae0cf51a, $3cb574b2, $25837a58, $dc0921bd,
        $d19113f9, $7ca92ff6, $94324773, $22f54701,
        $3ae5e581, $37c2dadc, $c8b57634, $9af3dda7,
        $a9446146, $0fd0030e, $ecc8c73e, $a4751e41,
        $e238cd99, $3bea0e2f, $3280bba1, $183eb331,
        $4e548b38, $4f6db908, $6f420d03, $f60a04bf,
        $2cb81290, $24977c79, $5679b072, $bcaf89af,
        $de9a771f, $d9930810, $b38bae12, $dccf3f2e,
        $5512721f, $2e6b7124, $501adde6, $9f84cd87,
        $7a584718, $7408da17, $bc9f9abc, $e94b7d8c,
        $ec7aec3a, $db851dfa, $63094366, $c464c3d2,
        $ef1c1847, $3215d908, $dd433b37, $24c2ba16,
        $12a14d43, $2a65c451, $50940002, $133ae4dd,
        $71dff89e, $10314e55, $81ac77d6, $5f11199b,
        $043556f1, $d7a3c76b, $3c11183b, $5924a509,
        $f28fe6ed, $97f1fbfa, $9ebabf2c, $1e153c6e,
        $86e34570, $eae96fb1, $860e5e0a, $5a3e2ab3,
        $771fe71c, $4e3d06fa, $2965dcb9, $99e71d0f,
        $803e89d6, $5266c825, $2e4cc978, $9c10b36a,
        $c6150eba, $94e2ea78, $a5fc3c53, $1e0a2df4,
		$f2f74ea7, $361d2b3d, $1939260f, $19c27960,
        $5223a708, $f71312b6, $ebadfe6e, $eac31f66,
        $e3bc4595, $a67bc883, $b17f37d1, $018cff28,
        $c332ddef, $be6c5aa5, $65582185, $68ab9802,
        $eecea50f, $db2f953b, $2aef7dad, $5b6e2f84,
        $1521b628, $29076170, $ecdd4775, $619f1510,
        $13cca830, $eb61bd96, $0334fe1e, $aa0363cf,
        $b5735c90, $4c70a239, $d59e9e0b, $cbaade14,
        $eecc86bc, $60622ca7, $9cab5cab, $b2f3846e,
        $648b1eaf, $19bdf0ca, $a02369b9, $655abb50,
        $40685a32, $3c2ab4b3, $319ee9d5, $c021b8f7,
        $9b540b19, $875fa099, $95f7997e, $623d7da8,
        $f837889a, $97e32d77, $11ed935f, $16681281,
        $0e358829, $c7e61fd6, $96dedfa1, $7858ba99,
        $57f584a5, $1b227263, $9b83c3ff, $1ac24696,
        $cdb30aeb, $532e3054, $8fd948e4, $6dbc3128,
        $58ebf2ef, $34c6ffea, $fe28ed61, $ee7c3c73,
        $5d4a14d9, $e864b7e3, $42105d14, $203e13e0,
        $45eee2b6, $a3aaabea, $db6c4f15, $facb4fd0,
        $c742f442, $ef6abbb5, $654f3b1d, $41cd2105,
        $d81e799e, $86854dc7, $e44b476a, $3d816250,
        $cf62a1f2, $5b8d2646, $fc8883a0, $c1c7b6a3,
        $7f1524c3, $69cb7492, $47848a0b, $5692b285,
        $095bbf00, $ad19489d, $1462b174, $23820e00,
        $58428d2a, $0c55f5ea, $1dadf43e, $233f7061,
        $3372f092, $8d937e41, $d65fecf1, $6c223bdb,
        $7cde3759, $cbee7460, $4085f2a7, $ce77326e,
        $a6078084, $19f8509e, $e8efd855, $61d99735,
        $a969a7aa, $c50c06c2, $5a04abfc, $800bcadc,
        $9e447a2e, $c3453484, $fdd56705, $0e1e9ec9,
        $db73dbd3, $105588cd, $675fda79, $e3674340,
        $c5c43465, $713e38d8, $3d28f89e, $f16dff20,
        $153e21e7, $8fb03d4a, $e6e39f2b, $db83adf7);

        SBox3: ($e93d5a68, $948140f7, $f64c261c, $94692934,
        $411520f7, $7602d4f7, $bcf46b2e, $d4a20068,
        $d4082471, $3320f46a, $43b7d4b7, $500061af,
        $1e39f62e, $97244546, $14214f74, $bf8b8840,
        $4d95fc1d, $96b591af, $70f4ddd3, $66a02f45,
        $bfbc09ec, $03bd9785, $7fac6dd0, $31cb8504,
        $96eb27b3, $55fd3941, $da2547e6, $abca0a9a,
        $28507825, $530429f4, $0a2c86da, $e9b66dfb,
        $68dc1462, $d7486900, $680ec0a4, $27a18dee,
        $4f3ffea2, $e887ad8c, $b58ce006, $7af4d6b6,
        $aace1e7c, $d3375fec, $ce78a399, $406b2a42,
		$20fe9e35, $d9f385b9, $ee39d7ab, $3b124e8b,
        $1dc9faf7, $4b6d1856, $26a36631, $eae397b2,
        $3a6efa74, $dd5b4332, $6841e7f7, $ca7820fb,
        $fb0af54e, $d8feb397, $454056ac, $ba489527,
        $55533a3a, $20838d87, $fe6ba9b7, $d096954b,
        $55a867bc, $a1159a58, $cca92963, $99e1db33,
        $a62a4a56, $3f3125f9, $5ef47e1c, $9029317c,
        $fdf8e802, $04272f70, $80bb155c, $05282ce3,
        $95c11548, $e4c66d22, $48c1133f, $c70f86dc,
        $07f9c9ee, $41041f0f, $404779a4, $5d886e17,
        $325f51eb, $d59bc0d1, $f2bcc18f, $41113564,
        $257b7834, $602a9c60, $dff8e8a3, $1f636c1b,
        $0e12b4c2, $02e1329e, $af664fd1, $cad18115,
        $6b2395e0, $333e92e1, $3b240b62, $eebeb922,
        $85b2a20e, $e6ba0d99, $de720c8c, $2da2f728,
        $d0127845, $95b794fd, $647d0862, $e7ccf5f0,
        $5449a36f, $877d48fa, $c39dfd27, $f33e8d1e,
        $0a476341, $992eff74, $3a6f6eab, $f4f8fd37,
        $a812dc60, $a1ebddf8, $991be14c, $db6e6b0d,
        $c67b5510, $6d672c37, $2765d43b, $dcd0e804,
        $f1290dc7, $cc00ffa3, $b5390f92, $690fed0b,
        $667b9ffb, $cedb7d9c, $a091cf0b, $d9155ea3,
        $bb132f88, $515bad24, $7b9479bf, $763bd6eb,
        $37392eb3, $cc115979, $8026e297, $f42e312d,
        $6842ada7, $c66a2b3b, $12754ccc, $782ef11c,
        $6a124237, $b79251e7, $06a1bbe6, $4bfb6350,
        $1a6b1018, $11caedfa, $3d25bdd8, $e2e1c3c9,
        $44421659, $0a121386, $d90cec6e, $d5abea2a,
        $64af674e, $da86a85f, $bebfe988, $64e4c3fe,
        $9dbc8057, $f0f7c086, $60787bf8, $6003604d,
        $d1fd8346, $f6381fb0, $7745ae04, $d736fccc,
        $83426b33, $f01eab71, $b0804187, $3c005e5f,
        $77a057be, $bde8ae24, $55464299, $bf582e61,
        $4e58f48f, $f2ddfda2, $f474ef38, $8789bdc2,
        $5366f9c3, $c8b38e74, $b475f255, $46fcd9b9,
        $7aeb2661, $8b1ddf84, $846a0e79, $915f95e2,
        $466e598e, $20b45770, $8cd55591, $c902de4c,
        $b90bace1, $bb8205d0, $11a86248, $7574a99e,
        $b77f19b6, $e0a9dc09, $662d09a1, $c4324633,
        $e85a1f02, $09f0be8c, $4a99a025, $1d6efe10,
        $1ab93d1d, $0ba5a4df, $a186f20f, $2868f169,
        $dcb7da83, $573906fe, $a1e2ce9b, $4fcd7f52,
        $50115e01, $a70683fa, $a002b5c4, $0de6d027,
        $9af88c27, $773f8641, $c3604c06, $61a806b5,
        $f0177a28, $c0f586e0, $006058aa, $30dc7d62,
		$11e69ed7, $2338ea63, $53c2dd94, $c2c21634,
        $bbcbee56, $90bcb6de, $ebfc7da1, $ce591d76,
        $6f05e409, $4b7c0188, $39720a3d, $7c927c24,
        $86e3725f, $724d9db9, $1ac15bb4, $d39eb8fc,
        $ed545578, $08fca5b5, $d83d7cd3, $4dad0fc4,
        $1e50ef5e, $b161e6f8, $a28514d9, $6c51133c,
        $6fd5c7e7, $56e14ec4, $362abfce, $ddc6c837,
        $d79a3234, $92638212, $670efa8e, $406000e0);

        SBox4: ($3a39ce37, $d3faf5cf, $abc27737, $5ac52d1b,
        $5cb0679e, $4fa33742, $d3822740, $99bc9bbe,
        $d5118e9d, $bf0f7315, $d62d1c7e, $c700c47b,
        $b78c1b6b, $21a19045, $b26eb1be, $6a366eb4,
        $5748ab2f, $bc946e79, $c6a376d2, $6549c2c8,
        $530ff8ee, $468dde7d, $d5730a1d, $4cd04dc6,
        $2939bbdb, $a9ba4650, $ac9526e8, $be5ee304,
        $a1fad5f0, $6a2d519a, $63ef8ce2, $9a86ee22,
        $c089c2b8, $43242ef6, $a51e03aa, $9cf2d0a4,
        $83c061ba, $9be96a4d, $8fe51550, $ba645bd6,
        $2826a2f9, $a73a3ae1, $4ba99586, $ef5562e9,
        $c72fefd3, $f752f7da, $3f046f69, $77fa0a59,
        $80e4a915, $87b08601, $9b09e6ad, $3b3ee593,
        $e990fd5a, $9e34d797, $2cf0b7d9, $022b8b51,
        $96d5ac3a, $017da67d, $d1cf3ed6, $7c7d2d28,
        $1f9f25cf, $adf2b89b, $5ad6b472, $5a88f54c,
        $e029ac71, $e019a5e6, $47b0acfd, $ed93fa9b,
        $e8d3c48d, $283b57cc, $f8d56629, $79132e28,
        $785f0191, $ed756055, $f7960e44, $e3d35e8c,
        $15056dd4, $88f46dba, $03a16125, $0564f0bd,
        $c3eb9e15, $3c9057a2, $97271aec, $a93a072a,
        $1b3f6d9b, $1e6321f5, $f59c66fb, $26dcf319,
        $7533d928, $b155fdf5, $03563482, $8aba3cbb,
        $28517711, $c20ad9f8, $abcc5167, $ccad925f,
        $4de81751, $3830dc8e, $379d5862, $9320f991,
        $ea7a90c2, $fb3e7bce, $5121ce64, $774fbe32,
        $a8b6e37e, $c3293d46, $48de5369, $6413e680,
        $a2ae0810, $dd6db224, $69852dfd, $09072166,
        $b39a460a, $6445c0dd, $586cdecf, $1c20c8ae,
        $5bbef7dd, $1b588d40, $ccd2017f, $6bb4e3bb,
        $dda26a7e, $3a59ff45, $3e350a44, $bcb4cdd5,
        $72eacea8, $fa6484bb, $8d6612ae, $bf3c6f47,
        $d29be463, $542f5d9e, $aec2771b, $f64e6370,
        $740e0d8d, $e75b1357, $f8721671, $af537d5d,
        $4040cb08, $4eb4e2cc, $34d2466a, $0115af84,
        $e1b00428, $95983a1d, $06b89fb4, $ce6ea048,
		$6f3f3b82, $3520ab82, $011a1d4b, $277227f8,
        $611560b1, $e7933fdc, $bb3a792b, $344525bd,
        $a08839e1, $51ce794b, $2f32c9b7, $a01fbac9,
        $e01cc87e, $bcc7d1f6, $cf0111c3, $a1e8aac7,
        $1a908749, $d44fbd9a, $d0dadecb, $d50ada38,
        $0339c32a, $c6913667, $8df9317c, $e0b12b4f,
        $f79e59b7, $43f5bb3a, $f2d519ff, $27d9459c,
        $bf97222c, $15e6fc2a, $0f91fc71, $9b941525,
        $fae59361, $ceb69ceb, $c2a86459, $12baa8d1,
        $b6c1075e, $e3056a0c, $10d25065, $cb03a442,
        $e0ec6e0e, $1698db3b, $4c98a0be, $3278e964,
        $9f1f9532, $e0d392df, $d3a0342b, $8971f21e,
        $1b0a7441, $4ba3348c, $c5be7120, $c37632d8,
        $df359f8d, $9b992f2e, $e60b6f47, $0fe3f11d,
        $e54cda54, $1edad891, $ce6279cf, $cd3e7e6f,
        $1618b166, $fd2c1d05, $848fd2c5, $f6fb2299,
        $f523f357, $a6327623, $93a83531, $56cccd02,
        $acf08162, $5a75ebb5, $6e163697, $88d273cc,
        $de966292, $81b949d0, $4c50901b, $71c65614,
        $e6c6c7bd, $327a140a, $45e1d006, $c3f27b9a,
        $c9aa53fd, $62a80f00, $bb25bfe2, $35bdd2f6,
        $71126905, $b2040222, $b6cbcf7c, $cd769c2b,
        $53113ec0, $1640e3d3, $38abbd60, $2547adf0,
        $ba38209c, $f746ce76, $77afa1c5, $20756060,
        $85cbfe4e, $8ae88dd8, $7aaaf9b0, $4cf9aa7e,
        $1948c25c, $02fb8a8c, $01c36ae4, $d6ebe1f9,
        $90d4f869, $a65cdea0, $3f09252d, $c208e69f,
        $b74e6132, $ce77e25b, $578fdfe3, $3ac372e6));

var
    Boxes : TBoxes;
    Rounds : LongInt;

procedure BLOWFISH_ENCIPHER(var XR, XL : LongInt);
asm
    push    ebx
    push    ecx
    push    esi
    push    edi
    push  eax
    push  edx
    mov   eax, [XR]
    mov   edx, [XL]
    mov   ebx, 0
    mov   esi, 0
	mov    edi, rounds
    shl    edi, 2
    @:xor   edx, [esi*1   + offset boxes.pbox]
    ror    edx, 16
    mov    bl, dh
    mov    ecx, [ebx*4 + offset boxes.sbox1]
    mov    bl, dl
    add    ecx, [ebx*4 + offset boxes.sbox2]
    rol    edx, 16
    mov   bl, dh
    xor   ecx, [ebx*4 + offset boxes.sbox3]
    mov   bl, dl
    add   ecx, [ebx*4 + offset boxes.sbox4]
    xor    eax, ecx
    xchg    eax, edx
    add    esi, 4
    cmp    esi, edi
    jne    @
    xchg  eax, edx
    xor   eax, [esi*1   + offset boxes.pbox]
    xor   edx, [esi+4 + offset boxes.pbox]
    mov   ebx, edx
    pop   edx
    mov[XL], ebx
    mov   ebx, eax
    pop   eax
    mov[XR], ebx
    pop    edi
    pop    esi
    pop    ecx
    pop    ebx
    ret
end;

procedure BLOWFISH_DECIPHER(var XR, XL : LongInt);
asm
    push    ebx
    push    ecx
    push    esi
    push  eax
    push  edx
    mov   eax, [XR]
    mov   edx, [XL]
    mov   ebx, 0
    mov    esi, rounds
	inc   esi
    shl    esi, 2
    @:xor   edx, [esi*1   + offset boxes.pbox]
    ror    edx, 16
    mov    bl, dh
    mov    ecx, [ebx*4 + offset boxes.sbox1]
    mov    bl, dl
    add    ecx, [ebx*4 + offset boxes.sbox2]
    rol    edx, 16
    mov   bl, dh
    xor   ecx, [ebx*4 + offset boxes.sbox3]
    mov   bl, dl
    add   ecx, [ebx*4 + offset boxes.sbox4]
    xor    eax, ecx
    xchg    eax, edx
    sub    esi, 4
    cmp    esi, 4
    jne    @
    xchg  eax, edx
    xor   eax, [4 + offset boxes.pbox]
    xor   edx, [offset boxes.pbox]
    mov   ebx, edx
    pop   edx
    mov[XL], ebx
    mov   ebx, eax
    pop   eax
    mov[XR], ebx
    pop    esi
    pop    ecx
    pop    ebx
    ret
end;

function Blowfish_Init;
type
    TpKey = array[0..53] of Byte;
    T_X = array[Pred(Low(Boxes.PBox))..Pred(High(Boxes.PBox)), 0..3] of Byte;
    TPBox = array[Low(Boxes.PBox)..High(Boxes.PBox) div 2, 0..1] of LongInt;
    TSBox = array[Low(Boxes.SBox1)..High(Boxes.SBox1) div 2, 0..1] of LongInt;
    T_Box = array[Low(Boxes.SBox1)..High(Boxes.SBox1)] of LongInt;
var
    i, j : Integer;
    XL, XR : LongInt;
begin
    Result := FALSE;

    if Assigned(pBoxes) then begin
        Boxes := TBoxes(pBoxes^);
    end else begin
        Boxes := Pi_Boxes;
    end;

    if unRounds in [2..32] then begin
        Rounds := unRounds + unRounds mod 2;
    end else begin
        Rounds := 16;
    end;

    for i := Low(T_X) to Pred((Rounds + 2) * 4) do begin
        T_X(Boxes.PBox)[i div 4, 3 - (i mod 4)] :=
            T_X(Boxes.PBox)[i div 4, 3 - (i mod 4)] xor TpKey(pKey^)[i mod unKeySize];
    end;

    XL := 0;
    XR := 0;

    for i := Low(TPBox) to ((Rounds + 2) div 2) do begin
        BLOWFISH_ENCIPHER(XR, XL);
        TPBox(Boxes.PBox)[i, 0] := XL;
        TPBox(Boxes.PBox)[i, 1] := XR;
    end;

    for i := Low(TSBox) to High(TSBox) do begin
        BLOWFISH_ENCIPHER(XR, XL);
        TSBox(Boxes.SBox1)[i, 0] := XL;
        TSBox(Boxes.SBox1)[i, 1] := XR;
    end;

    for i := Low(TSBox) to High(TSBox) do begin
        BLOWFISH_ENCIPHER(XR, XL);
        TSBox(Boxes.SBox2)[i, 0] := XL;
        TSBox(Boxes.SBox2)[i, 1] := XR;
    end;

    for i := Low(TSBox) to High(TSBox) do begin
        BLOWFISH_ENCIPHER(XR, XL);
        TSBox(Boxes.SBox3)[i, 0] := XL;
        TSBox(Boxes.SBox3)[i, 1] := XR;
    end;

	for i := Low(TSBox) to High(TSBox) do begin
        BLOWFISH_ENCIPHER(XR, XL);
        TSBox(Boxes.SBox4)[i, 0] := XL;
        TSBox(Boxes.SBox4)[i, 1] := XR;
    end;

    for i := Low(T_Box) to High(T_Box) do begin
        for j := Succ(i) to High(T_Box) do begin
            if T_Box(Boxes.SBox1)[i] = T_Box(Boxes.SBox1)[j] then begin
                Exit;
            end;
        end;
    end;

    for i := Low(T_Box) to High(T_Box) do begin
        for j := Succ(i) to High(T_Box) do begin
            if T_Box(Boxes.SBox2)[i] = T_Box(Boxes.SBox2)[j] then begin
                Exit;
            end;
        end;
    end;

    for i := Low(T_Box) to High(T_Box) do begin
        for j := Succ(i) to High(T_Box) do begin
            if T_Box(Boxes.SBox3)[i] = T_Box(Boxes.SBox3)[j] then begin
                Exit;
            end;
        end;
    end;

    for i := Low(T_Box) to High(T_Box) do begin
        for j := Succ(i) to High(T_Box) do begin
            if T_Box(Boxes.SBox4)[i] = T_Box(Boxes.SBox4)[j] then begin
                Exit;
            end;
        end;
    end;

    Result := TRUE;
end;

procedure Blowfish_Done;
begin
    Rounds := 16;
    Boxes  := Pi_Boxes;
end;

procedure Blowfish_ECBEncrypt;
var
    i : Integer;
begin
    for i := 1 to (unCount div 8) do begin
        BLOWFISH_ENCIPHER(T64BitArray(pBuffer^)[i, 1], T64BitArray(pBuffer^)[i, 0]);
    end;
end;

procedure Blowfish_ECBDecrypt;
var
    i : Integer;
begin
    for i := 1 to (unCount div 8) do begin
        BLOWFISH_DECIPHER(T64BitArray(pBuffer^)[i, 1], T64BitArray(pBuffer^)[i, 0]);
    end;
end;

procedure Blowfish_CBCEncrypt;
var
    i : Integer;
begin
    for i := 1 to (unCount div 8) do begin
        ulCBCLeft := T64BitArray(pBuffer^)[i, 0] xor ulCBCLeft;
        ulCBCRight := T64BitArray(pBuffer^)[i, 1] xor ulCBCRight;
        BLOWFISH_ENCIPHER(ulCBCRight, ulCBCLeft);
        T64BitArray(pBuffer^)[i, 0] := ulCBCLeft;
        T64BitArray(pBuffer^)[i, 1] := ulCBCRight;
    end;
end;

procedure Blowfish_CBCDecrypt;
var
    i : Integer;
    XL, XR : LongInt;
begin
    for i := 1 to (unCount div 8) do begin
        XL := T64BitArray(pBuffer^)[i, 0];
        XR := T64BitArray(pBuffer^)[i, 1];
        BLOWFISH_DECIPHER(T64BitArray(pBuffer^)[i, 1], T64BitArray(pBuffer^)[i, 0]);
        T64BitArray(pBuffer^)[i, 0] := T64BitArray(pBuffer^)[i, 0] xor ulCBCLeft;
        T64BitArray(pBuffer^)[i, 1] := T64BitArray(pBuffer^)[i, 1] xor ulCBCRight;
        ulCBCLeft := XL;
		ulCBCRight := XR;
    end;
end;

function Blowfish_GetBoxPointer;
begin
    Result := @Boxes;
end;

function SetKeyword(Value : String) : boolean;
begin
    Result := Blowfish_Init(PChar(Value), Length(Value), NIL, 16);
end;

procedure AddPadding(MS : TStream);
const
    Pad: array[1..8] of char = #1#1#1#1#1#1#1#1;
var
    num : byte;
begin
    num := 8 - ((ms.size + 1) mod 8);
    ms.Position := ms.Size;
    if num > 0 then begin
        ms.Write(pad, num);
    end;
    ms.Write(num, sizeof(num));
end;

procedure EncryptStream(MS : TMemoryStream; const Key : string);
begin
    if ms.size > 0 then begin
        if SetKeyword(Key) then begin
            AddPadding(ms);
            Blowfish_ECBEncrypt(ms.memory, ms.Size);
        end;
    end;
end;

procedure DecryptStream(ms : TmemoryStream; const Key : string);
var
    num : byte;
begin
    if ms.size > 0 then begin
        if SetKeyword(Key) then begin
            Blowfish_ECBDecrypt(ms.memory, ms.Size);
			ms.Position := ms.Size - 1;
            ms.read(num, sizeof(num));
            ms.SetSize(Ms.size - num - 1);
        end;
    end;
end;

{ *************************************************************** }
{ *************************************************************** }
{ *************************************************************** }
{ *************************************************************** }
{LZH Rourines}
{ *************************************************************** }
{ *************************************************************** }
{ *************************************************************** }
{ *************************************************************** }
{ *************************************************************** }

type
{$IFDEF WIN32}
    TwoByteInt = SmallInt;
{$ELSE}
    TwoByteInt = Integer;
{$ENDIF}
    PWord = ^TWord;
    TWord = array[0..32759] of TwoByteInt;
    PByte = ^TByte;
    TByte = array[0..65519] of Byte;

const

    BITBUFSIZ = 16;
    UCHARMAX  = 255;

    DICBIT = 13;
    DICSIZ = 1 shl DICBIT;

    MATCHBIT = 8;
    MAXMATCH = 1 shl MATCHBIT;
    THRESHOLD = 3;
    PERCFLAG = $8000;

    NC = (UCHARMAX + MAXMATCH + 2 - THRESHOLD);
    CBIT = 9;
    CODEBIT = 16;

    NP = DICBIT + 1;
    NT = CODEBIT + 3;
    PBIT = 4; {Log2(NP)}
    TBIT = 5; {Log2(NT)}
    NPT = NT; {Greater from NP and NT}

    NUL = 0;
    MAXHASHVAL = (3 * DICSIZ + (DICSIZ shr 9 + 1) * UCHARMAX);

    WINBIT = 14;
    WINDOWSIZE = 1 shl WINBIT;

    BUFBIT = 13;
    BUFSIZE = 1 shl BUFBIT;

type
    BufferArray = array[0..PRED(BUFSIZE)] of Byte;
    LeftRightArray = array[0..2 * (NC - 1)] of Word;
    CTableArray = array[0..4095] of Word;
    CLenArray = array[0..PRED(NC)] of Byte;
    HeapArray = array[0..NC] of Word;

var
    OrigSize, CompSize : Longint;
    InFile, OutFile : TStream;

    BitBuf : Word;
    n, HeapSize : TwoByteInt;
    SubBitBuf, BitCount : Word;

    Buffer : ^BufferArray;
    BufPtr : Word;

    Left, Right : ^LeftRightArray;

    PtTable : array[0..255] of Word;
    PtLen : array[0..PRED(NPT)] of Byte;
    CTable : ^CTableArray;
    CLen :  ^CLenArray;

    BlockSize : Word;

    { The following variables are used by the compression engine only }

	Heap : ^HeapArray;
    LenCnt : array[0..16] of Word;

    Freq, SortPtr : PWord;
    Len : PByte;
    Depth : Word;

    Buf : PByte;

    CFreq : array[0..2 * (NC - 1)] of Word;
    PFreq : array[0..2 * (NP - 1)] of Word;
    TFreq : array[0..2 * (NT - 1)] of Word;

    CCode : array[0..PRED(NC)] of Word;
    PtCode : array[0..PRED(NPT)] of Word;

    CPos, OutputPos, OutputMask : Word;
    Text, ChildCount : PByte;

    Pos, MatchPos, Avail : Word;
    Position, Parent, Prev, Next : PWord;

    Remainder, MatchLen : TwoByteInt;
    Level : PByte;

{********************************** File I/O **********************************}

function GetC : Byte;
begin
    if BufPtr = 0 then begin
        InFile.Read(Buffer^, BUFSIZE);
    end;
    GetC := Buffer^[BufPtr];
    BufPtr := SUCC(BufPtr) and PRED(BUFSIZE);
end;

procedure PutC(c : Byte);
begin
    if BufPtr = BUFSIZE then begin
        OutFile.Write(Buffer^, BUFSIZE);
        BufPtr := 0;
    end;
    Buffer^[BufPtr] := C;
    INC(BufPtr);
end;

function BRead(p : Pointer; n : TwoByteInt) : TwoByteInt;
begin
    BRead := InFile.Read(p^, n);
end;

procedure BWrite(p : Pointer; n : TwoByteInt);
begin
    OutFile.Write(p^, n);
end;

{**************************** Bit handling routines ***************************}

procedure FillBuf(n : TwoByteInt);
begin
    BitBuf := (BitBuf shl n);
    while n > BitCount do begin
        DEC(n, BitCount);
        BitBuf := BitBuf or (SubBitBuf shl n);
        if (CompSize <> 0) then begin
            DEC(CompSize);
            SubBitBuf := GetC;
        end else begin
            SubBitBuf := 0;
        end;
        BitCount := 8;
    end;
    DEC(BitCount, n);
    BitBuf := BitBuf or (SubBitBuf shr BitCount);
end;

function GetBits(n : TwoByteInt) : Word;
begin
    GetBits := BitBuf shr (BITBUFSIZ - n);
    FillBuf(n);
end;

procedure PutBits(n : TwoByteInt; x : Word);
begin
    if n < BitCount then begin
        DEC(BitCount, n);
        SubBitBuf := SubBitBuf or (x shl BitCount);
    end else begin
        DEC(n, BitCount);
        PutC(SubBitBuf or (x shr n));
		INC(CompSize);
        if n < 8 then begin
            BitCount := 8 - n;
            SubBitBuf := x shl BitCount;
        end else begin
            PutC(x shr (n - 8));
            INC(CompSize);
            BitCount := 16 - n;
            SubBitBuf := x shl BitCount;
        end;
    end;
end;

procedure InitGetBits;
begin
    BitBuf := 0;
    SubBitBuf := 0;
    BitCount := 0;
    FillBuf(BITBUFSIZ);
end;

procedure InitPutBits;
begin
    BitCount := 8;
    SubBitBuf := 0;
end;

{******************************** Decompression *******************************}

procedure MakeTable(nchar : TwoByteInt; BitLen : PByte; TableBits : TwoByteInt; Table : PWord);
var
    count, weight : array[1..16] of Word;
    start : array[1..17] of Word;
    p : PWord;
    i, k, Len, ch, jutbits, Avail, nextCode, mask : TwoByteInt;
begin
    for i := 1 to 16 do begin
        count[i] := 0;
    end;
    for i := 0 to PRED(nchar) do begin
        INC(count[BitLen^[i]]);
    end;
    start[1] := 0;
    for i := 1 to 16 do begin
        start[SUCC(i)] := start[i] + (count[i] shl (16 - i));
	end;
    if start[17] <> 0 then begin
        raise ECorruptFile.Create('Compressed file is corrupt');
        exit;
    end;
    jutbits := 16 - TableBits;
    for i := 1 to TableBits do begin
        start[i] := start[i] shr jutbits;
        weight[i] := 1 shl (TableBits - i);
    end;
    i := SUCC(TableBits);
    while (i <= 16) do begin
        weight[i] := 1 shl (16 - i);
        INC(i);
    end;
    i := start[SUCC(TableBits)] shr jutbits;
    if i <> 0 then begin
        k := 1 shl TableBits;
        while i <> k do begin
            Table^[i] := 0;
            INC(i);
        end;
    end;
    Avail := nchar;
    mask  := 1 shl (15 - TableBits);
    for ch := 0 to PRED(nchar) do begin
        Len := BitLen^[ch];
        if Len = 0 then begin
            CONTINUE;
        end;
        k := start[Len];
        nextCode := k + weight[Len];
        if Len <= TableBits then begin
            for i := k to PRED(nextCode) do begin
                Table^[i] := ch;
            end;
        end else begin
            p := Addr(Table^[Word(k) shr jutbits]);
            i := Len - TableBits;
            while i <> 0 do begin
                if p^[0] = 0 then begin
                    right^[Avail] := 0;
                    left^[Avail] := 0;
                    p^[0] := Avail;
                    INC(Avail);
				end;
                if (k and mask) <> 0 then begin
                    p := addr(right^[p^[0]]);
                end else begin
                    p := addr(left^[p^[0]]);
                end;
                k := k shl 1;
                DEC(i);
            end;
            p^[0] := ch;
        end;
        start[Len] := nextCode;
    end;
end;

procedure ReadPtLen(nn, nBit, ispecial : TwoByteInt);
var
    i, c, n : TwoByteInt;
    mask : Word;
begin
    n := GetBits(nBit);
    if n = 0 then begin
        c := GetBits(nBit);
        for i := 0 to PRED(nn) do begin
            PtLen[i] := 0;
        end;
        for i := 0 to 255 do begin
            PtTable[i] := c;
        end;
    end else begin
        i := 0;
        while (i < n) do begin
            c := BitBuf shr (BITBUFSIZ - 3);
            if c = 7 then begin
                mask := 1 shl (BITBUFSIZ - 4);
                while (mask and BitBuf) <> 0 do begin
                    mask := mask shr 1;
                    INC(c);
                end;
            end;
            if c < 7 then begin
                FillBuf(3);
            end else begin
                FillBuf(c - 3);
            end;
			PtLen[i] := c;
            INC(i);
            if i = ispecial then begin
                c := PRED(TwoByteInt(GetBits(2)));
                while c >= 0 do begin
                    PtLen[i] := 0;
                    INC(i);
                    DEC(c);
                end;
            end;
        end;
        while i < nn do begin
            PtLen[i] := 0;
            INC(i);
        end;
        try
            MakeTable(nn, @PtLen, 8, @PtTable);
        except
            begin
                raise;
                exit;
            end;
        end;
    end;
end;

procedure ReadCLen;
var
    i, c, n : TwoByteInt;
    mask : Word;
begin
    n := GetBits(CBIT);
    if n = 0 then begin
        c := GetBits(CBIT);
        for i := 0 to PRED(NC) do begin
            CLen^[i] := 0;
        end;
        for i := 0 to 4095 do begin
            CTable^[i] := c;
        end;
    end else begin
        i := 0;
        while i < n do begin
            c := PtTable[BitBuf shr (BITBUFSIZ - 8)];
            if c >= NT then begin
				mask := 1 shl (BITBUFSIZ - 9);
                repeat
                    if (BitBuf and mask) <> 0 then begin
                        c := right^[c];
                    end else begin
                        c := left^[c];
                    end;
                    mask := mask shr 1;
                until c < NT;
            end;
            FillBuf(PtLen[c]);
            if c <= 2 then begin
                if c = 1 then begin
                    c := 2 + GetBits(4);
                end else begin
                    if c = 2 then begin
                        c := 19 + GetBits(CBIT);
                    end;
                end;
                while c >= 0 do begin
                    CLen^[i] := 0;
                    INC(i);
                    DEC(c);
                end;
            end else begin
                CLen^[i] := c - 2;
                INC(i);
            end;
        end;
        while i < NC do begin
            CLen^[i] := 0;
            INC(i);
        end;
        try
            MakeTable(NC, PByte(CLen), 12, PWord(CTable));
        except
            begin
                raise;
                exit;
            end;
        end;
    end;
end;

function DecodeC : Word;
var
    j, mask : Word;
begin
    if BlockSize = 0 then begin
        BlockSize := GetBits(16);
        ReadPtLen(NT, TBIT, 3);
        ReadCLen;
        ReadPtLen(NP, PBIT, -1);
    end;
    DEC(BlockSize);
    j := CTable^[BitBuf shr (BITBUFSIZ - 12)];
    if j >= NC then begin
        mask := 1 shl (BITBUFSIZ - 13);
        repeat
            if (BitBuf and mask) <> 0 then begin
                j := right^[j];
            end else begin
                j := left^[j];
            end;
            mask := mask shr 1;
        until j < NC;
    end;
    FillBuf(CLen^[j]);
    DecodeC := j;
end;

function DecodeP : Word;
var
    j, mask : Word;
begin
    j := PtTable[BitBuf shr (BITBUFSIZ - 8)];
    if j >= NP then begin
        mask := 1 shl (BITBUFSIZ - 9);
        repeat
            if (BitBuf and mask) <> 0 then begin
                j := right^[j];
            end else begin
                j := left^[j];
            end;
            mask := mask shr 1;
        until j < NP;
    end;
    FillBuf(PtLen[j]);
    if j <> 0 then begin
        DEC(j);
		j := (1 shl j) + GetBits(j);
    end;
    DecodeP := j;
end;

{declared as static vars}
var
    decode_i : Word;
    decode_j : TwoByteInt;

procedure DecodeBuffer(count : Word; Buffer : PByte);
var
    c, r : Word;
begin
    r := 0;
    DEC(decode_j);
    while (decode_j >= 0) do begin
        Buffer^[r] := Buffer^[decode_i];
        decode_i := SUCC(decode_i) and PRED(DICSIZ);
        INC(r);
        if r = count then begin
            EXIT;
        end;
        DEC(decode_j);
    end;
    while TRUE do begin
        c := DecodeC;
        if c <= UCHARMAX then begin
            Buffer^[r] := c;
            INC(r);
            if r = count then begin
                EXIT;
            end;
        end else begin
            decode_j := c - (UCHARMAX + 1 - THRESHOLD);
            decode_i := (LongInt(r) - DecodeP - 1) and PRED(DICSIZ);
            DEC(decode_j);
            while decode_j >= 0 do begin
                Buffer^[r] := Buffer^[decode_i];
                decode_i := SUCC(decode_i) and PRED(DICSIZ);
                INC(r);
                if r = count then begin
                    EXIT;
                end;
                DEC(decode_j);
			end;
        end;
    end;
end;

procedure Decode;
var
    p : PByte;
    l : Longint;
    a : Word;
begin
    {Initialize decoder variables}
    GetMem(p, DICSIZ);
    InitGetBits;
    BlockSize := 0;
    decode_j := 0;
    {skip file size}
    l := OrigSize;
    DEC(compSize, 4);
    {unpacks the file}
    while l > 0 do begin
        if l > DICSIZ then begin
            a := DICSIZ;
        end else begin
            a := l;
        end;
        DecodeBuffer(a, p);
        OutFile.Write(p^, a);
        DEC(l, a);
    end;
    FreeMem(p, DICSIZ);
end;

{********************************* Compression ********************************}

{-------------------------------- Huffman part --------------------------------}

procedure CountLen(i : TwoByteInt);
begin
    if i < n then begin
        if Depth < 16 then begin
            INC(LenCnt[Depth]);
        end else begin
            INC(LenCnt[16]);
        end;
	end else begin
        INC(Depth);
        CountLen(Left^[i]);
        CountLen(Right^[i]);
        DEC(Depth);
    end;
end;

procedure MakeLen(root : TwoByteInt);
var
    i, k : TwoByteInt;
    cum :  word;
begin
    for i := 0 to 16 do begin
        LenCnt[i] := 0;
    end;
    CountLen(root);
    cum := 0;
    for i := 16 downto 1 do begin
        INC(cum, LenCnt[i] shl (16 - i));
    end;
    while cum <> 0 do begin
        DEC(LenCnt[16]);
        for i := 15 downto 1 do begin
            if LenCnt[i] <> 0 then begin
                DEC(LenCnt[i]);
                INC(LenCnt[SUCC(i)], 2);
                BREAK;
            end;
        end;
        DEC(cum);
    end;
    for i := 16 downto 1 do begin
        k := PRED(LongInt(LenCnt[i]));
        while k >= 0 do begin
            DEC(k);
            Len^[SortPtr^[0]] := i;
            asm
                ADD WORD PTR SortPtr,2; {SortPtr:=addr(SortPtr^[1]);}
            end;
        end;
    end;
end;

procedure DownHeap(i : TwoByteInt);
var
    j, k : TwoByteInt;
begin
    k := Heap^[i];
    j := i shl 1;
    while (j <= HeapSize) do begin
        if (j < HeapSize) and (Freq^[Heap^[j]] > Freq^[Heap^[SUCC(j)]]) then begin
            INC(j);
        end;
        if Freq^[k] <= Freq^[Heap^[j]] then begin
            break;
        end;
        Heap^[i] := Heap^[j];
        i := j;
        j := i shl 1;
    end;
    Heap^[i] := k;
end;

procedure MakeCode(n : TwoByteInt; Len : PByte; Code : PWord);
var
    i, k : TwoByteInt;
    start : array[0..17] of Word;
begin
    start[1] := 0;
    for i := 1 to 16 do begin
        start[SUCC(i)] := (start[i] + LenCnt[i]) shl 1;
    end;
    for i := 0 to PRED(n) do begin
        k := Len^[i];
        Code^[i] := start[k];
        INC(start[k]);
    end;
end;

function MakeTree(NParm : TwoByteInt; Freqparm : PWord; LenParm : PByte; Codeparm : PWord) : TwoByteInt;
var
    i, j, k, Avail : TwoByteInt;
begin
    n := NParm;
    Freq := Freqparm;
    Len := LenParm;
    Avail := n;
    HeapSize := 0;
    Heap^[1] := 0;
	for i := 0 to PRED(n) do begin
        Len^[i] := 0;
        if Freq^[i] <> 0 then begin
            INC(HeapSize);
            Heap^[HeapSize] := i;
        end;
    end;
    if HeapSize < 2 then begin
        Codeparm^[Heap^[1]] := 0;
        MakeTree := Heap^[1];
        EXIT;
    end;
    for i := (HeapSize div 2) downto 1 do begin
        DownHeap(i);
    end;
    SortPtr := Codeparm;
    repeat
        i := Heap^[1];
        if i < n then begin
            SortPtr^[0] := i;
            asm
                ADD WORD PTR SortPtr,2; {SortPtr:=addr(SortPtr^[1]);}
            end;
        end;
        Heap^[1] := Heap^[HeapSize];
        DEC(HeapSize);
        DownHeap(1);
        j := Heap^[1];
        if j < n then begin
            SortPtr^[0] := j;
            asm
                ADD WORD PTR SortPtr,2; {SortPtr:=addr(SortPtr^[1]);}
            end;
        end;
        k := Avail;
        INC(Avail);
        Freq^[k] := Freq^[i] + Freq^[j];
        Heap^[1] := k;
        DownHeap(1);
        Left^[k] := i;
        Right^[k] := j;
    until HeapSize <= 1;
    SortPtr := Codeparm;
    MakeLen(k);
    MakeCode(NParm, LenParm, Codeparm);
	MakeTree := k;
end;

procedure CountTFreq;
var
    i, k, n, Count : TwoByteInt;
begin
    for i := 0 to PRED(NT) do begin
        TFreq[i] := 0;
    end;
    n := NC;
    while (n > 0) and (CLen^[PRED(n)] = 0) do begin
        DEC(n);
    end;
    i := 0;
    while i < n do begin
        k := CLen^[i];
        INC(i);
        if k = 0 then begin
            Count := 1;
            while (i < n) and (CLen^[i] = 0) do begin
                INC(i);
                INC(Count);
            end;
            if Count <= 2 then begin
                INC(TFreq[0], Count);
            end else begin
                if Count <= 18 then begin
                    INC(TFreq[1]);
                end else begin
                    if Count = 19 then begin
                        INC(TFreq[0]);
                        INC(TFreq[1]);
                    end else begin
                        INC(TFreq[2]);
                    end;
                end;
            end;
        end else begin
            INC(TFreq[k + 2]);
        end;
    end;
end;

procedure WritePtLen(n, nBit, ispecial : TwoByteInt);
var
    i, k : TwoByteInt;
begin
    while (n > 0) and (PtLen[PRED(n)] = 0) do begin
        DEC(n);
    end;
    PutBits(nBit, n);
    i := 0;
    while (i < n) do begin
        k := PtLen[i];
        INC(i);
        if k <= 6 then begin
            PutBits(3, k);
        end else begin
            DEC(k, 3);
            PutBits(k, (1 shl k) - 2);
        end;
        if i = ispecial then begin
            while (i < 6) and (PtLen[i] = 0) do begin
                INC(i);
            end;
            PutBits(2, (i - 3) and 3);
        end;
    end;
end;

procedure WriteCLen;
var
    i, k, n, Count : TwoByteInt;
begin
    n := NC;
    while (n > 0) and (CLen^[PRED(n)] = 0) do begin
        DEC(n);
    end;
    PutBits(CBIT, n);
    i := 0;
    while (i < n) do begin
        k := CLen^[i];
        INC(i);
        if k = 0 then begin
            Count := 1;
            while (i < n) and (CLen^[i] = 0) do begin
                INC(i);
                INC(Count);
            end;
			if Count <= 2 then begin
                for k := 0 to PRED(Count) do begin
                    PutBits(PtLen[0], PtCode[0]);
                end;
            end else begin
                if Count <= 18 then begin
                    PutBits(PtLen[1], PtCode[1]);
                    PutBits(4, Count - 3);
                end else begin
                    if Count = 19 then begin
                        PutBits(PtLen[0], PtCode[0]);
                        PutBits(PtLen[1], PtCode[1]);
                        PutBits(4, 15);
                    end else begin
                        PutBits(PtLen[2], PtCode[2]);
                        PutBits(CBIT, Count - 20);
                    end;
                end;
            end;
        end else begin
            PutBits(PtLen[k + 2], PtCode[k + 2]);
        end;
    end;
end;

procedure EncodeC(c : TwoByteInt);
begin
    PutBits(CLen^[c], CCode[c]);
end;

procedure EncodeP(p : Word);
var
    c, q : Word;
begin
    c := 0;
    q := p;
    while q <> 0 do begin
        q := q shr 1;
        INC(c);
    end;
    PutBits(PtLen[c], PtCode[c]);
    if c > 1 then begin
        PutBits(PRED(c), p and ($ffff shr (17 - c)));
    end;
end;

procedure SendBlock;
var
    i, k, flags, root, Pos, Size : Word;
begin
    root := MakeTree(NC, @CFreq, PByte(CLen), @CCode);
    Size := CFreq[root];
    PutBits(16, Size);
    if root >= NC then begin
        CountTFreq;
        root := MakeTree(NT, @TFreq, @PtLen, @PtCode);
        if root >= NT then begin
            WritePtLen(NT, TBIT, 3);
        end else begin
            PutBits(TBIT, 0);
            PutBits(TBIT, root);
        end;
        WriteCLen;
    end else begin
        PutBits(TBIT, 0);
        PutBits(TBIT, 0);
        PutBits(CBIT, 0);
        PutBits(CBIT, root);
    end;
    root := MakeTree(NP, @PFreq, @PtLen, @PtCode);
    if root >= NP then begin
        WritePtLen(NP, PBIT, -1);
    end else begin
        PutBits(PBIT, 0);
        PutBits(PBIT, root);
    end;
    Pos := 0;
    for i := 0 to PRED(Size) do begin
        if (i and 7) = 0 then begin
            flags := Buf^[Pos];
            INC(Pos);
        end else begin
            flags := flags shl 1;
        end;
        if (flags and (1 shl 7)) <> 0 then begin
            k := Buf^[Pos] + (1 shl 8);
            INC(Pos);
            EncodeC(k);
            k := Buf^[Pos] shl 8;
            INC(Pos);
			INC(k, Buf^[Pos]);
            INC(Pos);
            EncodeP(k);
        end else begin
            k := Buf^[Pos];
            INC(Pos);
            EncodeC(k);
        end;
    end;
    for i := 0 to PRED(NC) do begin
        CFreq[i] := 0;
    end;
    for i := 0 to PRED(NP) do begin
        PFreq[i] := 0;
    end;
end;

procedure Output(c, p : Word);
begin
    OutputMask := OutputMask shr 1;
    if OutputMask = 0 then begin
        OutputMask := 1 shl 7;
        if (OutputPos >= WINDOWSIZE - 24) then begin
            SendBlock;
            OutputPos := 0;
        end;
        CPos := OutputPos;
        INC(OutputPos);
        Buf^[CPos] := 0;
    end;
    Buf^[OutputPos] := c;
    INC(OutputPos);
    INC(CFreq[c]);
    if c >= (1 shl 8) then begin
        Buf^[CPos] := Buf^[CPos] or OutputMask;
        Buf^[OutputPos] := (p shr 8);
        INC(OutputPos);
        Buf^[OutputPos] := p;
        INC(OutputPos);
        c := 0;
        while p <> 0 do begin
            p := p shr 1;
            INC(c);
        end;
        INC(PFreq[c]);
	end;
end;

{------------------------------- Lempel-Ziv part ------------------------------}

procedure InitSlide;
var
    i : Word;
begin
    for i := DICSIZ to (DICSIZ + UCHARMAX) do begin
        Level^[i] := 1;
{$IFDEF PERCOLATE}
        Position^[i] := NUL;
{$ENDIF}
    end;
    for i := DICSIZ to PRED(2 * DICSIZ) do begin
        Parent^[i] := NUL;
    end;
    Avail := 1;
    for i := 1 to DICSIZ - 2 do begin
        Next^[i] := SUCC(i);
    end;
    Next^[PRED(DICSIZ)] := NUL;
    for i := (2 * DICSIZ) to MAXHASHVAL do begin
        Next^[i] := NUL;
    end;
end;

{ Hash function }
function Hash(p : TwoByteInt; c : Byte) : TwoByteInt;
begin
    Hash := p + (c shl (DICBIT - 9)) + 2 * DICSIZ;
end;

function Child(q : TwoByteInt; c : Byte) : TwoByteInt;
var
    r : TwoByteInt;
begin
    r := Next^[Hash(q, c)];
    Parent^[NUL] := q;
    while Parent^[r] <> q do begin
        r := Next^[r];
    end;
    Child := r;
end;

procedure MakeChild(q : TwoByteInt; c : Byte; r : TwoByteInt);
var
    h, t : TwoByteInt;
begin
    h := Hash(q, c);
    t := Next^[h];
    Next^[h] := r;
    Next^[r] := t;
    Prev^[t] := r;
    Prev^[r] := h;
    Parent^[r] := q;
    INC(ChildCount^[q]);
end;

procedure Split(old : TwoByteInt);
var
    new, t : TwoByteInt;
begin
    new := Avail;
    Avail := Next^[new];
    ChildCount^[new] := 0;
    t := Prev^[old];
    Prev^[new] := t;
    Next^[t] := new;
    t := Next^[old];
    Next^[new] := t;
    Prev^[t] := new;
    Parent^[new] := Parent^[old];
    Level^[new] := MatchLen;
    Position^[new] := Pos;
    MakeChild(new, Text^[MatchPos + MatchLen], old);
    MakeChild(new, Text^[Pos + MatchLen], Pos);
end;

procedure InsertNode;
var
    q, r, j, t : TwoByteInt;
    c : Byte;
    t1, t2 : PChar;
begin
    if MatchLen >= 4 then begin
        DEC(MatchLen);
        r := SUCC(MatchPos) or DICSIZ;
        q := Parent^[r];
		while q = NUL do begin
            r := Next^[r];
            q := Parent^[r];
        end;
        while Level^[q] >= MatchLen do begin
            r := q;
            q := Parent^[q];
        end;
        t := q;
{$IFDEF PERCOLATE}
        while Position^[t] < 0 do begin
            Position^[t] := Pos;
            t := Parent^[t];
        end;
        if t < DICSIZ then begin
            Position^[t] := Pos or PERCFLAG;
        end;
{$ELSE}
        while t < DICSIZ do begin
            Position^[t] := Pos;
            t := Parent^[t];
        end;
{$ENDIF}
    end else begin
        q := Text^[Pos] + DICSIZ;
        c := Text^[SUCC(Pos)];
        r := Child(q, c);
        if r = NUL then begin
            MakeChild(q, c, Pos);
            MatchLen := 1;
            EXIT;
        end;
        MatchLen := 2;
    end;
    while TRUE do begin
        if r >= DICSIZ then begin
            j := MAXMATCH;
            MatchPos := r;
        end else begin
            j := Level^[r];
            MatchPos := Position^[r] and not PERCFLAG;
        end;
        if MatchPos >= Pos then begin
            DEC(MatchPos, DICSIZ);
        end;
		t1 := addr(Text^[Pos + MatchLen]);
        t2 := addr(Text^[MatchPos + MatchLen]);
        while MatchLen < j do begin
            if t1^ <> t2^ then begin
                Split(r);
                EXIT;
            end;
            INC(MatchLen);
            INC(t1);
            INC(t2);
        end;
        if MatchLen >= MAXMATCH then begin
            BREAK;
        end;
        Position^[r] := Pos;
        q := r;
        r := Child(q, ORD(t1^));
        if r = NUL then begin
            MakeChild(q, ORD(t1^), Pos);
            EXIT;
        end;
        INC(MatchLen);
    end;
    t := Prev^[r];
    Prev^[Pos] := t;
    Next^[t] := Pos;
    t := Next^[r];
    Next^[Pos] := t;
    Prev^[t] := Pos;
    Parent^[Pos] := q;
    Parent^[r] := NUL;
    Next^[r] := Pos;
end;

procedure DeleteNode;
var
    r, s, t, u : TwoByteInt;
{$IFDEF PERCOLATE}
    q : TwoByteInt;
{$ENDIF}
begin
    if Parent^[Pos] = NUL then begin
        EXIT;
    end;
    r := Prev^[Pos];
	s := Next^[Pos];
    Next^[r] := s;
    Prev^[s] := r;
    r := Parent^[Pos];
    Parent^[Pos] := NUL;
    DEC(ChildCount^[r]);
    if (r >= DICSIZ) or (ChildCount^[r] > 1) then begin
        EXIT;
    end;
{$IFDEF PERCOLATE}
    t := Position^[r] and not PERCFLAG;
{$ELSE}
    t := Position^[r];
{$ENDIF}
    if t >= Pos then begin
        DEC(t, DICSIZ);
    end;
{$IFDEF PERCOLATE}
    s := t;
    q := Parent^[r];
    u := Position^[q];
    while (u and PERCFLAG) <> 0 do begin
        u := u and not PERCFLAG;
        if u >= Pos then begin
            DEC(u, DICSIZ);
        end;
        if u > s then begin
            s := u;
        end;
        Position^[q] := s or DICSIZ;
        q := Parent^[q];
        u := Position^[q];
    end;
    if q < DICSIZ then begin
        if u >= Pos then begin
            DEC(u, DICSIZ);
        end;
        if u > s then begin
            s := u;
        end;
        Position^[q] := s or DICSIZ or PERCFLAG;
    end;
{$ENDIF}
    s := Child(r, Text^[t + Level^[r]]);
    t := Prev^[s];
	u := Next^[s];
    Next^[t] := u;
    Prev^[u] := t;
    t := Prev^[r];
    Next^[t] := s;
    Prev^[s] := t;
    t := Next^[r];
    Prev^[t] := s;
    Next^[s] := t;
    Parent^[s] := Parent^[r];
    Parent^[r] := NUL;
    Next^[r] := Avail;
    Avail := r;
end;

procedure GetNextMatch;
var
    n : TwoByteInt;
begin
    DEC(Remainder);
    INC(Pos);
    if Pos = 2 * DICSIZ then begin
        move(Text^[DICSIZ], Text^[0], DICSIZ + MAXMATCH);
        n := InFile.Read(Text^[DICSIZ + MAXMATCH], DICSIZ);
        INC(Remainder, n);
        Pos := DICSIZ;
    end;
    DeleteNode;
    InsertNode;
end;

procedure Encode;
var
    LastMatchLen, LastMatchPos : TwoByteInt;
begin
    { initialize encoder variables }
    GetMem(Text, 2 * DICSIZ + MAXMATCH);
    GetMem(Level, DICSIZ + UCHARMAX + 1);
    GetMem(ChildCount, DICSIZ + UCHARMAX + 1);
{$IFDEF PERCOLATE}
    GetMem(Position, (DICSIZ + UCHARMAX + 1) * SizeOf(Word));
{$ELSE}
    GetMem(Position, (DICSIZ) * SizeOf(Word));
{$ENDIF}
    GetMem(Parent, (DICSIZ * 2) * SizeOf(Word));
	GetMem(Prev, (DICSIZ * 2) * SizeOf(Word));
    GetMem(Next, (MAXHASHVAL + 1) * SizeOf(Word));

    Depth := 0;
    InitSlide;
    GetMem(Buf, WINDOWSIZE);
    Buf^[0] := 0;
    FillChar(CFreq, sizeof(CFreq), 0);
    FillChar(PFreq, sizeof(PFreq), 0);
    OutputPos := 0;
    OutputMask := 0;
    InitPutBits;
    Remainder := InFile.Read(Text^[DICSIZ], DICSIZ + MAXMATCH);
    MatchLen := 0;
    Pos := DICSIZ;
    InsertNode;
    if MatchLen > Remainder then begin
        MatchLen := Remainder;
    end;
    while Remainder > 0 do begin
        LastMatchLen := MatchLen;
        LastMatchPos := MatchPos;
        GetNextMatch;
        if MatchLen > Remainder then begin
            MatchLen := Remainder;
        end;
        if (MatchLen > LastMatchLen) or (LastMatchLen < THRESHOLD) then begin
            Output(Text^[PRED(Pos)], 0);
        end else begin
            Output(LastMatchLen + (UCHARMAX + 1 - THRESHOLD), (Pos - LastMatchPos - 2) and PRED(DICSIZ));
            DEC(LastMatchLen);
            while LastMatchLen > 0 do begin
                GetNextMatch;
                DEC(LastMatchLen);
            end;
            if MatchLen > Remainder then begin
                MatchLen := Remainder;
            end;
        end;
    end;
    {flush buffers}
    SendBlock;
    PutBits(7, 0);
    if BufPtr <> 0 then begin
        OutFile.Write(Buffer^, BufPtr);
	end;

    FreeMem(Buf, WINDOWSIZE);
    FreeMem(Next, (MAXHASHVAL + 1) * SizeOf(Word));
    FreeMem(Prev, (DICSIZ * 2) * SizeOf(Word));
    FreeMem(Parent, (DICSIZ * 2) * SizeOf(Word));
{$IFDEF PERCOLATE}
    FreeMem(Position, (DICSIZ + UCHARMAX + 1) * SizeOf(Word));
{$ELSE}
    FreeMem(Position, (DICSIZ) * SizeOf(Word));
{$ENDIF}
    FreeMem(ChildCount, DICSIZ + UCHARMAX + 1);
    FreeMem(Level, DICSIZ + UCHARMAX + 1);
    FreeMem(Text, 2 * DICSIZ + MAXMATCH);
end;

{****************************** LH5 as Unit Procedures ************************}
procedure FreeMemory;
begin
    if CLen <> NIL then begin
        Dispose(CLen);
    end;
    CLen := NIL;
    if CTable <> NIL then begin
        Dispose(CTable);
    end;
    CTable := NIL;
    if Right <> NIL then begin
        Dispose(Right);
    end;
    Right := NIL;
    if Left <> NIL then begin
        Dispose(Left);
    end;
    Left := NIL;
    if Buffer <> NIL then begin
        Dispose(Buffer);
    end;
    Buffer := NIL;
    if Heap <> NIL then begin
        Dispose(Heap);
    end;
    Heap := NIL;
end;

procedure InitMemory;
begin
  {In should be harmless to call FreeMemory here, since it won't free
   unallocated memory (i.e., nil pointers).
   So let's call it in case an exception was thrown at some point and
   memory wasn't entirely freed.}
    FreeMemory;
    New(Buffer);
    New(Left);
    New(Right);
    New(CTable);
    New(CLen);
    FillChar(Buffer^, SizeOf(Buffer^), 0);
    FillChar(Left^, SizeOf(Left^), 0);
    FillChar(Right^, SizeOf(Right^), 0);
    FillChar(CTable^, SizeOf(CTable^), 0);
    FillChar(CLen^, SizeOf(CLen^), 0);

    decode_i := 0;
    BitBuf := 0;
    n := 0;
    HeapSize := 0;
    SubBitBuf := 0;
    BitCount := 0;
    BufPtr := 0;
    FillChar(PtTable, SizeOf(PtTable), 0);
    FillChar(PtLen, SizeOf(PtLen), 0);
    BlockSize := 0;

    { The following variables are used by the compression engine only }
    New(Heap);
    FillChar(Heap^, SizeOf(Heap^), 0);
    FillChar(LenCnt, SizeOf(LenCnt), 0);
    Depth := 0;
    FillChar(CFreq, SizeOf(CFreq), 0);
    FillChar(PFreq, SizeOf(PFreq), 0);
    FillChar(TFreq, SizeOf(TFreq), 0);
    FillChar(CCode, SizeOf(CCode), 0);
    FillChar(PtCode, SizeOf(PtCode), 0);
    CPos := 0;
    OutputPos := 0;
    OutputMask := 0;
    Pos  := 0;
    MatchPos := 0;
    Avail := 0;
	Remainder := 0;
    MatchLen := 0;
end;

{******************************** Interface Procedures ************************}
procedure LHACompress(InStr, OutStr : TStream);
begin
    InitMemory;
    try
        InFile := InStr;
        OutFile := OutStr;
        OrigSize := InFile.Size - InFile.Position;
        CompSize := 0;
        OutFile.Write(OrigSize, 4);
        Encode;
    finally
        FreeMemory;
    end;
end;

procedure LHAExpand(InStr, OutStr : TStream);
begin
    try
        InitMemory;
        InFile := InStr;
        OutFile := OutStr;
        CompSize := InFile.Size - InFile.Position;
        InFile.Read(OrigSize, 4);
        Decode;
    finally
        FreeMemory;
    end;
end;

initialization
    CLen := NIL;
    CTable := NIL;
    Right := NIL;
    Left := NIL;
    Buffer := NIL;
    Heap := NIL;
    Blowfish_Done;

finalization
    Blowfish_Done;
end.


