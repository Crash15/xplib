 XML, o qual pode ser baixado de um local comum a todos os usu�rios por exemplo da base de dados imediamente ap�s o login do operador.
 comum a todos os usu�rios( DB por exemplo ).
 mais detalhes.
"appendada"
"appendados"
'');
(abstract).
.. 
ADefaultVal
ADefaultValue
ADefaultValue : Referencia para TDefaultSettingValue a ser usado se a entrada nao puder ser lida. Este mesmo valor sera usado se AutoCreate for habilitado. Se nil o da instancia ser� usado. Apos a chamada se o valor retornado foi o contido em ADefaultVal
ADefaultValue : TDefaultSettingValue contendo o valor padrao para falha de leitura. Caso ADefaultValue = nil, o Default ser� o da instancia. Se o valor retornado foi obtido pelo valor padrao seu atributo Used sera verdadeiro. Ver TDefaultSettingValue par
AKeyPrefix
AKeyPrefix : Prefixo a ser usado antes de todos os caminhos passados para as chamadas de acesso aos elementos de configuracao.
AfterConstruction method
Apaga
Apaga entrada com o nome desejado Name : Caminho da entrada
Apos
AppSettings
AppSettings unit
Applies to
AsBoolean property
AsDateTime property
AsFloat property
AsInteger property
AsString property
AutoCreate
AutoCreate property
BDELocalDataDir property
BDENetDir property
BDEPrivateDir property
BeforeDestruction method
BinStream
BinStream : TStreamer do qual ser�o lidos os bytes a serem gravados
Boolean
Boolean);
Boolean;
Caminho
Caso
Classe de acesso as configuracoes de preferencias do usu�rio. Um exemplo seria a corzinha daquela �rea da janela, etc. A persistencia destas configura��es s�o mantidas no registro do computador, preferencialmente na chave HKCU
Classe de acesso as configuracoes for�adas pelo sistema ajustadas pelo administrador/instalador. Um exemplo seria os direitos de acesso a determinada opera��o e/ou carga de m�dulo funcional. A persistencia destas configura��es s�o mantidas em um document
Classe de acesso as configuracoes globais impostas pelo sistema. Por exemplo o valor padr�o para um determinado campo, uma lista de feriados da unidade de negocio, etc. Seus dados s�o acessados mediante um documento XML baixado pelo aplicativo de um loca
Classe de acesso as configuracoes locais gerenciadas pelo operador e/ou administrador/instalador. Um exemplo seria se este aplicativo pode ou n�o ter multiplas instancias neste computador. A persistencia destas configura��es s�o mantidas no registro da m
Classes
ConfigurationLayer
ConfigurationLayer unit
Create
Create method
Create(const
Create;
Create[1]
Create[1] method
Cria um valor default especifico para esta leitura
Cuidado
DOMOwnerComponent method
DateTime.
Declaration
DefaultValue property
Denominador comum para todos os tipos de armazenagem desej�veis:
Descendente
Description
Destroy
Destroy method
Destroy;
Digitalsys:
EConfigException
Eleva a excess�o EConfigException informando que a entrada n�o foi encontrada.
EraseKey
EraseKey method
EraseKey(const
EraseValue
EraseValue method
EraseValue(const
Esta classe � a ancestral para os tipos de configura��es gerais de um aplicativo padr�o Digitalsys:
FAutoCreate
FDefaultValue
FGlobalSettings
FIni field
FKeyPrefix
FLocalSettings
FOwnedData
FRefCount
FReg field
FRootNode
FStartupSettings
FUsed field
FUserPrefs
FUserSettings
FValue field
False.
Falso
Faz releitura do streamer xml com os dados, caso qualquer informacao tenha sido alterada serah perdida.
Fields
FileName
Float.
FullName
GetAsBoolean
GetAsBoolean method
GetAsDateTime
GetAsDateTime method
GetAsFloat
GetAsFloat method
GetAsInteger
GetAsInteger method
GetAsString
GetAsString method
GetAttributeValue method
GetBDE
GetBDELocalDataDir
GetBDELocalDataDir method
GetBDENetDir
GetBDEPrivateDir
GetValue
GetValue method
GetVersion
GetVersion method
GetVersion:
GlobalSettings
HKCU
Help for Model StFLib unit
HowMany
HowMany : quantidade de bytes a serem gravados( -1 ) todos at� o final do streamer.
IBDEStartupSettings
IMPORTANTE : Caso este valor seja n�o vazio sempre finalizar com "
IXMLNode);
IXMLNode;
Implica
IniFiles, Registry e XML.
Iniciar
Instancia
Integer
Integer):
Integer);
Integer;
KeyExists
KeyExists method
KeyExists(const
KeyPrefix property
ListSubKeys
ListSubKeys method
ListSubKeys(const
ListValuesNames
ListValuesNames method
ListValuesNames(const
LocalSettings
LocalSettings property
Methods
NIL):
NOTAS: EConfigException sera elevada se falha na leitura. Todas as implementacoes de Readxxx de TRegistryBasedSettings sao identicas em estrutura.
NOTAS: O valor padrao para falha de leitura sera -1. As estrutura dos metodos TBaseStartSettings.Readxxx sao identicas
Name
Name : Nome composto da chave + nome do valor a ser lido para o Streamer dado.
Name : Nome da chave a ter suas sub-chaves carregadas. SubKeys : TStrings na qual ser� a lista de nomes das sub-chaves.
Name : Nome da entrada a ser escrita.
Name : Nome da entrada a ser lida.
Name : Nome da entrada a ser testada.
Name : Nome da entrada ser lisda.
Name : Nome do valor a ser lido.
Name. Nome da chave a ser verificada
NewInstance method
Nome
Nota: As sub-chaves sem permiss�o de acesso podem n�o ser listadas.
Nota: As sub-chaves sem permiss�o de acesso podem n�o ser listadas. Subkeys ser� "appendada" � miss�o do chamador pass�-la vazia se desejavel.
Nota: Valores sem permiss�o de acesso podem ser omitidos.
OpenNode method
OwnedData property
Prefixo
Properties
Quantidade
QueryInterface method
RaiseEntryNotFound method
RaiseKeyNotFound method
ReadBinary
ReadBinary method
ReadBinary(const
ReadBoolean
ReadBoolean method
ReadBoolean(const
ReadBooleanDefault method
ReadDateTime
ReadDateTime method
ReadDateTime(const
ReadInteger
ReadInteger method
ReadInteger(const
ReadIntegerDefault method
ReadString
ReadString method
ReadString(const
ReadStringDefault method
Readxxx
RefCount property
Referencia
Refresh
Refresh method
Refresh;
Registry
Returns: Quantidade de bytes efetivamente salvos.
Returns: Quantidade de bytes repassados para o streamer.
Returns: String contida na entrada.
Returns: Valor booleano contido na entrada.
Returns: Valor da date do tipo TDateTime.
Returns: Valor da entrada.
Returns: Verdadeiro se esta chave existe, Falso caso contrario. Cuidado para o caso do acesso a essa chave ser negado e o resultado retorne valor enganoso.
Returns: Verdadeiro se o valor for encontrado, Falso caso contr�rio. Se as permiss�es falhem no acesso a essa entrada.
RootNode property
SetAs
SetAsBoolean method
SetAsDateTime method
SetAsFloat method
SetAsInteger method
SetAsString method
SetAttributeValue method
SetBDE
SetBDELocalDataDir method
SetKeyPrefix method
SetRootNode method
SetUserPrefs method
SetValue method
Seta
SplitNames method
StFLib
StartupSettings
StartupSettings property
Stream
Stream : Descendente de TStream, no qual ser� carregado a totalidade do conte�do dos dados contidos na entrada. A posi��o do stream n�o ser� resetada nesta opera��o nem o mesmo ser� retornado a posicao original.
Streamer
String):
SubKeys
TBaseConfiguration
TBaseGlobalSettings
TBaseGlobalSettings TBaseLocalSettings TBaseStartSettings TBaseUserPreferences TBaseUserSettings
TBaseGlobalSettings;
TBaseLocalSettings
TBaseLocalSettings;
TBaseSettings
TBaseStartSettings
TBaseStartSettings.Readxxx
TBaseStartSettings;
TBaseUserPreferences
TBaseUserPreferences;
TBaseUserSettings
TDateTime
TDateTime);
TDateTime.
TDateTime;
TDefaultSettingValue
TDefaultSettingValue.
TRegistryBasedSettings
TStream):
TStream,
TStream;
TStreamer
TStrings
TStrings);
TXMLBasedSettings
Update
Update method
Update;
Used
Used property
UserPrefs
UserPrefs property
UserSettings
UserSettings property
Value
Value : Valor booleano a ser escrito.
Value : Valor do string a ser escrita.
Value : Valor do tipo TDateTime a ser escrito.
Value : Valor inteiro a escrito.
Value property
Value:
ValueExists
ValueExists method
ValueExists(const
Values
Variant);
Variant;
Ver
Write
WriteBinary
WriteBinary method
WriteBinary(const
WriteBoolean
WriteBoolean method
WriteBoolean(const
WriteDateTime
WriteDateTime method
WriteDateTime(const
WriteInteger
WriteInteger method
WriteInteger(const
WriteString
WriteString method
WriteString(const
XML
XML.
_AddRef method
_Release method
abstract;
acessados
acesso
administrador/instalador.
ajustadas
alteracoes
alterada
ancestral
and
antes
aos
apagada.
aplicativo
aplicativo.
armazenagem
arquivo
atributo
atributos
baixado
base
boolean.
booleano
bytes
caminhos
campo,
carregadas.
carregado
chamada
chamadas
chamador
chave
chave.
classe
com
como
composto
computador,
computador.
comum
configuracao.
configuracoes
configura��es
const
constructor Create(const AKeyPrefix : String = ''); override;
construtor
contendo
conte�do
contida
contido
contidos
contidos.
contrario.
contr�rio.
corrente
corretamente.
corzinha
criado
dado.
dados
dados,
dados.
daquela
das
date
default
deseja
desejado
desejavel.
desej�veis:
destas
destructor Destroy; override;
detalhes.
determinada
determinado
direitos
document
documento
dos
e o atributo sera marcado como usado. Ver TDefaultSettingValue para maiores detalhes.
e/ou
efetivamente
elementos
elevada
encontrada.
encontrado,
enganoso.
entrada
entrada.
escrita.
escrito.
especifico
essa
esta
este
estrutura
estrutura.
etc.
excess�o
exemplo
existe,
falha
falhem
feriados
ficara
field
filhos
final
finalizar
flag
foi
for
for�adas
funcional.
function
function GetVersion: string; override;
function KeyExists(const Name : String): Boolean; override;
function ReadBinary(const Name : String; Stream : TStream): Integer; override;
function ReadBoolean(const Name : String; ADefaultValue : TDefaultSettingValue = NIL): Boolean; override;
function ReadDateTime(const Name : String; ADefaultValue : TDefaultSettingValue = NIL): TDateTime; override;
function ReadInteger(const Name : String; ADefaultValue : TDefaultSettingValue = NIL): Integer; override;
function ReadString(const Name : String; ADefaultValue : TDefaultSettingValue = NIL): string; override;
function ValueExists(const Name : String): Boolean; override;
function WriteBinary(const Name : String; BinStream : TStream; HowMany : Integer): Integer; override;
gerais
gerenciadas
globais
gravados
gravados(
habilitado.
houver
identicas
imediamente
implementacoes
impostas
informacao
informando
instancia.
instancias
integer.
inteiro
janela,
leitura
leitura.
lida.
lido
lido.
lidos
lisda.
lista
listadas.
locais
local,
maiores
mantidas
marcado
mediante
mesmo
method
metodos
miss�o
montados
multiplas
m�dulo
nao
negado
negocio,
nesta
nil,
nomes
n�o
obtido
omitidos.
only.
operador
operador.
opera��o
original.
overload;
override;
padrao
padr�o
para
para que os valores sejam montados corretamente.
passado.
passados
pass�-la
pelo
perdida.
permiss�o
permiss�es
persistencia
pode
podem
por
posicao
posicionado
posi��o
preferencialmente
preferencias
private
procedure EraseKey(const Name : String); override;
procedure EraseValue(const Name : string); override;
procedure ListSubKeys(const Name : String; SubKeys : TStrings); override;
procedure ListValuesNames(const Name : String; Values : TStrings); override;
procedure Refresh;
procedure Update;
procedure WriteBoolean(const Name : String; Value : Boolean); override;
procedure WriteDateTime(const Name : String; Value : TDateTime); override;
procedure WriteInteger(const Name : String; Value : Integer); override;
procedure WriteString(const Name : String; Value : String); override;
property
property.
protected
public
puder
qual
qualquer
que
quina local, preferencialmente na chave HKLM
read
recebe
registro
reintroduce;
releitura
repassados
resetada
resultado
retornado
retorne
run
salvos.
sao
seja
sejam
sem
sempre
ser
sera
serao
serem
seria
ser�
ser�o
seu
seus
sistema
sistema.
state
stdcall;
streamer.
string
string);
string.
string;
string]:
suas
sub-chaves
sub-chaves.
s�o
tambem.
ter
testada.
the
time
tipo
tipos
todas
todos
totalidade
unidade
unit
usado
usado.
uso
usu�rio.
usu�rios
usu�rios(
valor
valores
variant.
vazio
verdadeiro
verdadeiro.
verificada
virtual;
write
�rea
