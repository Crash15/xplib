{$IFDEF TREConsts}
	 {$DEFINE DEBUG_UNIT}
{$ENDIF}
{$I TRELib.inc}

unit TREConsts;

interface

const
    //Informa��es inferidas pelo nome do computador 
    CMPNAME_LOCAL_ZONE     = 'Z';
    CMPNAME_LOCAL_CENTRAL  = 'C';
    CMPNAME_LOCAL_REGIONAL = 'R';
    CMPNAME_LOCAL_POS      = 4;  //Inicio da localiza��o do computador, podendo ser numero da zona ou central
    CMPNAME_TYPE_LENGHT    = 3;  //Refere-se aos tipos abaixo
    CMPNAME_TYPE_WORKGROUP = 'STD';
    CMPNAME_TYPE_DOMAIN    = 'WKS';
    CMPNAME_TYPE_DOMAIN_CONTROLLER = 'PDC';



    CMPNAME_LOCAL_LENGHT: Integer    = 3;  //Comprimento do identificador da zona no nome do computador
    CMPNAME_LOCAL_ANY: Integer       = 0;
    CMPNAME_LOCAL_ALL: Integer       = -1;
    CMPNAME_LOCAL_MIN_VALUE: Integer = 1;
    CMPNAME_LOCAL_MAX_VALUE: Integer = 77;

    CMPNAME_ID_ANY: Integer = 0;
    CMPNAME_ID_ALL: Integer = -1;
    CMPNAME_ID_MIN_VALUE    = 1;
    CMPNAME_ID_MAX_VALUE    = 999999; //Lembrar das virtuais do TRE relacionadas com o patrimonio



type
    TTREComputerType = (
        ctUnknow,        //Desconhecido
        ctCentralPDC,    //Controlador de central/dominio
        ctCentralWKS,    //Esta��o de central
        ctZonePDC,       //Controlador de dominio zona
		 ctZoneWKS,       //Esta��o de trabalho zona em dom�nio
		 ctZoneSTD,       //Esta��o de trabalho zona em grupo de trabalho
        ctTREWKS,        //Esta��o de trabalho TRE
        ctNATT,          //Esta��o de NATT
        ctNATU,          //Esta��o de NATT
        ctDFE,           //Esta��o de Diretoria de f�rum eleitoral
		 ctVirtual,       //Esta��o de m�quina virtual (prefixo RPBW)
		 ctAny            //todos os tipos anteriores
		 );

    TTRENetType      = (ntUnknow, ntWorkGroup, ntDomain);
    TTREAccessMedium = (treamNone, treamVSAT, treamDialled, treamFrameRelay, treamAny);


implementation

end.
