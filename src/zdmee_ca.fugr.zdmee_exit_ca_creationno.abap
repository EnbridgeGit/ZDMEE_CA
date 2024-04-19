FUNCTION ZDMEE_EXIT_CA_CREATIONNO .
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_TREE_TYPE) TYPE  DMEE_TREETYPE
*"     VALUE(I_TREE_ID) TYPE  DMEE_TREEID
*"     VALUE(I_ITEM)
*"     VALUE(I_PARAM)
*"     VALUE(I_UPARAM)
*"  EXPORTING
*"     REFERENCE(O_VALUE)
*"     REFERENCE(C_VALUE)
*"     REFERENCE(N_VALUE)
*"     REFERENCE(P_VALUE)
*"  TABLES
*"      I_TAB
*"--------------------------------------------------------------------

* Template function module --------------------------------------------*

  DATA:
*    DTA_VERSION(4) TYPE C VALUE 1,     "version of table DTA_CRNO
    BEGIN OF DTA_ID,                   "Id of RFDT
      PROG(8) TYPE C VALUE 'RFFOCA_T',
      ID(14)  TYPE C VALUE 'DTADCAA-CRNO  ',
    END OF DTA_ID,
    BEGIN OF DTA_CRNO OCCURS 0,        "file number
      ORIG     LIKE DTADCAA-ORIG,
      ADEST    LIKE DTADCAA-ADEST,
      CRNO(4)  type n,
    END OF DTA_CRNO,
    lwa_item       TYPE dmee_paym_if_type,
    l_fpayhx   TYPE fpayhx,
    first_flag type c.

* SAP Special 005 - Canada
  FIELD-SYMBOLS:
    <fs_format_params> TYPE any.

  DATA:
    format_params_str TYPE fpm_selpar-param,
    lr_parameters     TYPE REF TO data,
    ls_fpm_005        TYPE fpm_005.

  CALL FUNCTION 'FI_PAYM_PARAMETERS_GET'
    IMPORTING
      e_format_params = format_params_str.

  CREATE DATA lr_parameters LIKE ls_fpm_005.
  ASSIGN lr_parameters->* TO <fs_format_params>.
  <fs_format_params> = format_params_str.
  ls_fpm_005 = <fs_format_params>.
* SAP Special 005 - Canada

* new CRNO is desired
  if first_flag is initial.
     first_flag = 'X'.
***
     lwa_item = i_item.
     l_fpayhx = lwa_item-fpayhx.
*    import and read table
     REFRESH DTA_CRNO.
     IMPORT DTA_CRNO FROM DATABASE RFDT(FZ) ID DTA_ID.

     DTA_CRNO-ORIG  = l_fpayhx-DTFIN.
     DTA_CRNO-ADEST = l_fpayhx-DTBID.
     READ TABLE DTA_CRNO WITH KEY
       ORIG  = DTA_CRNO-ORIG
       ADEST = DTA_CRNO-ADEST.

*    compute next file number
     IF SY-SUBRC NE 0.
       DTA_CRNO-CRNO = 1.
       APPEND DTA_CRNO.
     ELSE.
        IF DTA_CRNO-CRNO EQ 9999.
           DTA_CRNO-CRNO = 1.
        ELSE.
           ADD 1 TO DTA_CRNO-CRNO.
        ENDIF.
*       SAP Special 005 - Canada
        dta_crno-crno = ls_fpm_005-creat_no.

        MODIFY DTA_CRNO INDEX SY-TABIX.
     ENDIF.

     c_value = DTA_CRNO-CRNO.


*    save table
     EXPORT DTA_CRNO TO DATABASE RFDT(FZ) ID DTA_ID.
     COMMIT WORK.

  endif.

ENDFUNCTION.
