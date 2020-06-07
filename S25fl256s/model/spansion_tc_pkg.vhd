-------------------------------------------------------------------------------
--  File name : spansion_tc_pkg.vhd
-------------------------------------------------------------------------------
--  Copyright (C) 2012 Spansion, LLC.
--
--  MODIFICATION HISTORY :
--
--  version: |    author:      |  mod date: | changes made:
--    V1.0      R.Prokopovic     09 Nov 16   Initial release
--              V. Mancev
--    V1.1      V.Mancev         10 Oct 29   Latest datasheet aligned
--              B.Colakovic
--    V1.2      B.Colakovic      11 July 05  Latest datasheet aligned
--    V1.3      S.Petrovic       12 Aug  28  QPP Instruction is allowed on
--                                           previously programmed page
--    V1.4      V. Mancev        13 Feb 13   Reverted restriction for QPP
--                                           on programmed page and added
--                                           clearing with sector erase
--    V1.5      M.Stojanovic     16 May 11   During QPP and QPP4 commands
--                                           the same page must not be
--                                           programmed more than once. However
--                                           do not generate P_ERR if this
--                                           occurs.
--    V1.6      M.Krneta         19 May 07   Updated according to the rev *P
--                                           (QPP and QPP4 commands changed,
--                                           ECCRD command added,
--                                           LOCK bit removed)
-------------------------------------------------------------------------------
--  PART DESCRIPTION:
--
--  Description:
--              Generic test environment for verification of flash memory
--              VITAL models.
--              For models:
--                  S25FL256S
--
-------------------------------------------------------------------------------
--  Known Bugs:
--
-------------------------------------------------------------------------------
LIBRARY IEEE;
                USE IEEE.std_logic_1164.ALL;
                USE STD.textio.ALL;

LIBRARY FMF;
                USE FMF.gen_utils.all;
                USE FMF.conversions.all;
-------------------------------------------------------------------------------
-- ENTITY DECLARATION
-------------------------------------------------------------------------------
PACKAGE spansion_tc_pkg IS
    ---------------------------------------------------------------------------
    --Values specified in this section determine wait periods of programming,
    --erase and internal device operation
    --Min, typ and max SDF parameters should all be supported for all timing
    --models.When FTM or SDF values change,and are not supported
    --these values may need to be updated.
    ---------------------------------------------------------------------------

    SHARED VARIABLE   tPP      : time;  -- page program time
    SHARED VARIABLE   tBP      : time;  -- byte program time
    SHARED VARIABLE   tSE      : time;  -- sector erase time
    SHARED VARIABLE   tBE      : time;  -- bulk (chip) erase time
    SHARED VARIABLE   tW       : time;  -- WRR cycle time
    SHARED VARIABLE   tESL     : time;  -- erase suspend/resume time
    SHARED VARIABLE   tPSL     : time;  -- program suspend/resume time
    SHARED VARIABLE   tPU      : time;  -- VCC (min) to CS# Low time

    SHARED VARIABLE   tRPH     : time;  -- RESET# low to next instruction time
    SHARED VARIABLE   tRP      : time;  -- RESET# Pulse Width
    SHARED VARIABLE   tPPBE    : time;  -- PPB Erase time
    SHARED VARIABLE   tPULCK   : time;  -- Password unlock time
    SHARED VARIABLE   tPACC    : time;  -- Ready to accept PASSU command

    SHARED VARIABLE   PageSize : integer;
    ---------------------------------------------------------------------------
    --TC type
    ---------------------------------------------------------------------------
    TYPE TC_type IS RECORD
                        SERIES   : NATURAL RANGE 1 TO 45;
                        TESTCASE : NATURAL RANGE 1 TO 15;
                    END RECORD;
    ---------------------------------------------------------------------------
    -- commands to the device
    ---------------------------------------------------------------------------
    TYPE cmd_type IS (  done,
                        idle,
                        w_enable,
                        w_disable,
                        h_reset,
                        w_sr,
                        rd_sr1,
                        rd_sr2,
                        clr_sr,
                        w_scr,
                        rd_scr,
                        rd,
                        rd_4,
                        fast_rd,
                        fast_rd4,
                        dual_rd,
                        dual_rd_4,
                        dual_high_rd,
                        dual_high_rd_4,
                        quad_rd,
                        quad_rd_4,
                        quad_high_rd,
                        quad_high_rd_4,
                        fast_ddr_rd,
                        fast_ddr_rd4,
                        dual_high_ddr_rd,
                        dual_high_ddr_rd4,
                        quad_high_ddr_rd,
                        quad_high_ddr_rd_4,
                        read_ID,
                        read_JID,
                        read_ES,
                        sector_erase,
                        sector_erase_4,
                        p4_erase,
                        p4_erase_4,
                        bulk_erase,
                        ers_susp,
                        ers_resume,
                        pg_prog,
                        pg_prog4,
                        quad_pg_prog,
                        quad_pg_prog4,
                        prg_susp,
                        prg_resume,
                        otp_prog,
                        otp_read,
                        ppbacc_rd,
                        w_ppb,
                        ppb_ers,
                        dybacc_rd,
                        w_dyb,
                        autoboot_rd,
                        w_autoboot,
                        bank_rd,
                        w_bank,
                        bank_acc,
                        asp_reg_rd,
                        w_asp,
                        pass_reg_rd,
                        w_password,
                        psw_unlock,
                        ppbl_reg_rd,
                        w_ppbl_reg,
                        rst,
                        mbr,
                        wt,
                        inv_write,
                        rd_dlp,
                        w_nvldr,
                        w_wvdlr,
                        ecc_rd
                     );

    ---------------------------------------------------------------------------
    -- condition to be verified
    ---------------------------------------------------------------------------
    -- list of data/ status to be veriied by checker
    TYPE status_type IS ( none,
                          read,
                          read_4,
                          read_fast,
                          read_fast_4,
                          read_dual,
                          read_dual_4,
                          rd_quad,
                          rd_quad_4,
                          read_dual_hi,
                          read_dual_hi4,
                          rd_cont_dualIO,
                          rd_cont_dualIO4,
                          read_quad_hi,
                          read_quad_hi4,
                          rd_cont_quadIO,
                          rd_cont_quadIO4,
                          read_ddr_fast,
                          read_ddr_fast4,
                          rd_cont_fddr,
                          rd_cont_fddr4,
                          read_ddr_dual_hi,
                          read_ddr_dual_hi4,
                          rd_cont_dddr,
                          rd_cont_dddr4,
                          read_ddr_quad_hi,
                          read_ddr_quad_hi4,
                          rd_cont_qddr,
                          rd_cont_qddr4,
                          rd_HiZ,
                          rd_U,
                          read_otp,
                          rd_JID,
                          rd_res,
                          rd_ID,
                          read_sr1,
                          read_sr2,
                          read_config,
                          read_autoboot,
                          read_bank,
                          read_asp,
                          read_pass_reg,
                          read_ppbl,
                          rd_ecc,
                          read_ppbar,
                          read_dybar,
                          rd_ppblock_0,
                          rd_ppblock_1,
                          rd_wip_0,
                          rd_wip_1,
                          rd_wel_0,
                          rd_wel_1,
                          erase_succ,
                          erase_nosucc,
                          pgm_succ,
                          pgm_nosucc,
                          rd_ps_0,
                          rd_ps_1,
                          rd_es_0,
                          rd_es_1,
                          read_dlp,
                          read_dlp_dual_ddr,
                          read_dlp_quad_ddr,
                          read_dlp_fast_ddr,
                          err
                        );
    ---------------------------------------------------------------------------
    --
    ---------------------------------------------------------------------------
    TYPE Aux_type IS (  valid,
                        hold_op,   --hold mode during opcode phase
                        hold_add,  --hold mode during address phase
                        hold_dum,  --hold mode during dummy phase
                        hold_mod,  --hold mode during mode phase
                        hold_dat,  --hold mode during data phase
                        violate,
                        clock_num,
                        break,
                        PowerUp
                     );

    TYPE DEVICE_MODE IS ( DEFAULT_PROTECTION,
                          PERSISTENT_PROTECTION,
                          PASSWORD_PROTECTION,
                          READ_PASSWORD_PROTECTION
                         );

    TYPE cmd_rec IS
        RECORD
            cmd      :   cmd_type;
            status   :   status_type;
            byte_num :   NATURAL RANGE 0 TO 600;
            data4    :   NATURAL ;
            data3    :   NATURAL ;
            data2    :   NATURAL ;
            data1    :   NATURAL ;
            sect     :   INTEGER RANGE 0 TO 541;
            addr     :   INTEGER RANGE 0 TO 16#1FFFFFF#;
            aux      :   Aux_type;
            wtime    :   time;
        END RECORD;

    --number of testcases per testseries
    TYPE tc_list IS  ARRAY (1 TO 45) OF NATURAL;
    CONSTANT tc : tc_list :=
    --0                 1                    2                   3                   4
    --1-2-3-4-5-6-7-8-9-0 -1-2-3-4-5-6-7-8-9-0-1-2-3-4-5-6-7-8-9-0-1-2-3-4-5-6-7-8-9-0-1-2-3-4-5
     (1,1,2,2,3,1,5,5,1,10,1,3,4,2,2,1,1,1,3,1,2,1,1,1,1,2,3,2,2,5,4,2,2,6,4,1,1,5,3,1,4,1,3,2,5);

    --TC command sequence
    TYPE cmd_seq_type IS ARRAY(0 TO 250) OF cmd_rec;

    ---------------------------------------------------------------------------
    --PUBLIC
    --PROCEDURE to generate command sequence
    ---------------------------------------------------------------------------
    PROCEDURE   Generate_TC
         (  Model       : IN  STRING  ;
            Series      : IN  NATURAL RANGE 1 TO 45;
            TestCase    : IN  NATURAL RANGE 1 TO 15;
            Sec_Arch    : IN  BOOLEAN  ;
            command_seq : OUT cmd_seq_type
         );
    ---------------------------------------------------------------------------
    --PUBLIC
    --PROCEDURE to set DUT dependant parameters
    ---------------------------------------------------------------------------
    PROCEDURE   TestInit (
            Model        : IN  STRING;
            LongTimming  : IN  boolean);
    ---------------------------------------------------------------------------
    --PUBLIC
    -- CHECKER PROCEDURES
    ---------------------------------------------------------------------------
    PROCEDURE   Check_read (
        DQ       :  IN std_logic_vector(7 downto 0);
        DQ_reg0  :  IN std_logic_vector(7 downto 0);
        DQ_reg1  :  IN std_logic_vector(7 downto 0);
        DQ_reg2  :  IN std_logic_vector(7 downto 0);
        DQ_reg3  :  IN std_logic_vector(7 downto 0);
        D_mem    :  IN NATURAL;
        DLP_reg  :  IN NATURAL;
        D_dlp_act:  IN std_logic_vector(1 downto 0);
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE   Check_Z (
        DQ   :  IN std_logic;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE   Check_U (
        DQ   :  IN std_logic;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE   Check_X (
        DQ   :  IN std_logic;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE   Check_otp_read (
        DQ   :  IN std_logic_vector(7 downto 0);
        otp_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE   Check_read_JID (
        DQ               :  IN std_logic_vector(7 downto 0);
        VDATA            :  IN NATURAL;
        byte_no          :  IN NATURAL;
        SIGNAL check_err :  OUT std_logic);

    PROCEDURE   Check_read_ES (
        DQ               :  IN std_logic_vector(7 downto 0);
        SIGNAL check_err :  OUT std_logic);

    PROCEDURE   Check_read_ID (
        DQ               :  IN std_logic_vector(7 downto 0);
        ADDR_BIT         :  IN std_logic;
        SIGNAL check_err :  OUT std_logic);

    PROCEDURE   Check_read_sr1 (
        DQ   :  IN std_logic_vector(7 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE   Check_read_sr2 (
        DQ   :  IN std_logic_vector(7 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE   Check_read_config (
        DQ   :  IN std_logic_vector(7 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE   Check_read_dlp (
        DQ     :  IN std_logic_vector(7 downto 0);
        DLP_reg:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE   Check_read_autoboot (
        DQ   :  IN std_logic_vector(31 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE   Check_read_bank (
        DQ   :  IN std_logic_vector(7 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE   Check_read_asp (
        DQ   :  IN std_logic_vector(15 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE   Check_read_pass_reg (
        DQ   :  IN std_logic_vector(63 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic);
        
    PROCEDURE   Check_rd_ecc (
        DQ   :  IN std_logic_vector(7 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE   Check_read_ppbl (
        DQ   :  IN std_logic_vector(7 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE   Check_read_ppbar (
        DQ   :  IN std_logic_vector(7 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE   Check_read_dybar (
        DQ   :  IN std_logic_vector(7 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE   Check_PPBLOCK_bit (
        DQ   :  IN std_logic;
        sts  :  IN  status_type;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE   Check_WIP_bit (
        DQ   :  IN std_logic;
        sts  :  IN  status_type;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE   Check_WEL_bit (
        DQ   :  IN std_logic;
        sts  :  IN  status_type;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE   Check_eers_bit (
        DQ   :  IN std_logic;
        sts  :  IN  status_type;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE   Check_epgm_bit (
        DQ   :  IN std_logic;
        sts  :  IN  status_type;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE Check_PS_bit (
        DQ   :  IN std_logic;
        sts  :  IN  status_type;
        SIGNAL check_err:  OUT std_logic);

    PROCEDURE Check_ES_bit (
        DQ   :  IN std_logic;
        sts  :  IN  status_type;
        SIGNAL check_err:  OUT std_logic);

END PACKAGE  spansion_tc_pkg;

PACKAGE BODY spansion_tc_pkg IS

    PROCEDURE   TestInit ( Model       : IN  STRING;
                           LongTimming  : IN  BOOLEAN  )
    IS
    BEGIN
        IF LongTimming THEN
            -- page program time
            IF Model(16) = '0' THEN
                tPP := 750 us;
            ELSIF Model(16) = '1' THEN
                tPP := 750 us;
            END IF;
            -- byte program time
            tBP := 400 us;
            -- sector erase time
            IF Model(16) = '0' THEN
                tSE := 650 ms;
            ELSIF Model(16) = '1' THEN
                tSE := 1875 ms;
            END IF;
            -- bulk (chip) erase time
            tBE := 330 sec;
            -- WRR cycle time
            tW  := 200 ms;
            -- erase suspend time
            tESL := 45 us;
            -- program suspend time
            tPSL := 40 us;
            -- VCC (min) to CS# Low time
            tPU := 300 us;
            -- RESET# low to next instruction time
            tRPH := 35 us;
            -- RESET# Pulse Width
            tRP := 201 ns;
            -- PPB Erase time
            tPPBE := 15 ms;
            -- Password unlock time
            tPULCK := 1 us;
            -- Ready to accept PASSU command
            tPACC  := 100 us;
        ELSE
            IF Model(16) = '0' THEN
                tPP := 750 us;
            ELSIF Model(16) = '1' THEN
                tPP := 750 us;
            END IF;
            -- byte program time
            tBP := 400 us;
            -- sector erase time
            IF Model(16) = '0' THEN
                tSE := 6.5 ms;
            ELSIF Model(16) = '1' THEN
                tSE := 18.75 ms;
            END IF;
            -- bulk (chip) erase time
            tBE := 330 ms;
            -- WRR cycle time
            tW  := 2 ms;
            -- erase suspend time
            tESL := 45 us;
            -- program suspend time
            tPSL := 40 us;
            -- VCC (min) to CS# Low time
            tPU := 300 us;
            -- RESET# low to next instruction time
            tRPH := 35 us;
            -- RESET# Pulse Width
            tRP := 201 ns;
            -- PPB Erase time
            tPPBE := 15 ms;
            -- Password unlock time
            tPULCK := 1 us;
            -- Ready to accept PASSU command
            tPACC  := 100 us;
        END IF;

        IF Model(16) = '0' THEN
            PageSize := 256;
        ELSIF Model(16) = '1' THEN
            PageSize := 512;
        END IF;
    END PROCEDURE TestInit;
    ---------------------------------------------------------------------------
    --Public PROCEDURE to generate command sequence
    ---------------------------------------------------------------------------
    PROCEDURE   Generate_TC
         (  Model       : IN  STRING;
            Series      : IN  NATURAL RANGE 1 TO 45;
            TestCase    : IN  NATURAL RANGE 1 TO 15;
            Sec_Arch    : IN  BOOLEAN;
            command_seq : OUT cmd_seq_type
         )
    IS

    BEGIN

        FOR i IN 1 TO 200 LOOP
            --cmd,sts,byte_num,data4,data3,data2,data1,sect,addr,aux_t,time
            command_seq(i) :=(done,none,0,0,0,0,0,0,0,valid,0 ns);
        END LOOP;

        REPORT "------------------------------------------------------" ;
        REPORT "------------------------------------------------------" ;
        REPORT "TestSeries : "& to_int_str(Series )&"   "&
               "TC         : "& to_int_str(TestCase);
        REPORT "------------------------------------------------------" ;
        CASE Series IS
            WHEN 1  =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "POWERUP negative test";
                    -- warning is generated if device is selected on PowerUp
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,200 ns);
                    command_seq(3) :=(rd     ,rd_HiZ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPU);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(rd_sr1 ,read_sr1,3,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_sr1 ,read_sr1,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 2  =>
                REPORT "POWERUP positive test";
                --cmd,sts,byte_num,data4,data3,data2,data1,sect,addr,aux_t,time
                command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                command_seq(2) :=(rd     ,read  ,2,0,0,0,0,0,0,valid,0 ns);
                command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                command_seq(4) :=(rd_sr1 ,read_sr1,2,0,0,0,0,0,0,valid,0 ns);
                command_seq(5) :=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                command_seq(6) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                command_seq(7) :=(mbr   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                command_seq(8):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                command_seq(9) :=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

            WHEN 3  =>  --write enable/write disable positive tests
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "WREN positive test";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(rd_sr1 ,rd_wel_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "WRDI positive test";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_disable,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(rd_sr1 ,rd_wel_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 4  =>  --Initial configuration test (TBPARM) for TopBoot Sector Architecture
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "TBPARM bit positive test";
                    IF Model(16) = '0' AND Sec_Arch = FALSE THEN
                        --The desired state of TBPARM must be selected during the initial
                        --configuration of the device during system manufacture;
                        --before the first program or erase operation on the main Flash array.
                        --TBPARM must not be programmed after programming or erasing is done in
                        --the main Flash array.
                        command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(4) :=(w_scr  ,none     ,2,0,0,0,16#04#,0,0,valid,0 ns);
                        command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(7) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(8) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(9) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(10):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(11):=(done   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;

                    WHEN 2  =>
                    REPORT "TBPARM bit negative test";
                    IF Model(16) = '0' AND Sec_Arch = FALSE THEN
                        --If TBPARM is programmed to 1, an attempt to change it back
                        --to zero will fail and set the Program Error bit (P_ERR in SR1[6]).
                        command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(4) :=(w_scr  ,err      ,2,0,0,0,16#00#,0,0,valid,0 ns);
                        command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Verify that operation is not accepted
                        command_seq(6) :=(rd_sr1 ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(7) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Verify that P_ERR bit is set
                        command_seq(8) :=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(9) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Verify that TBPARM did not change its value
                        command_seq(10):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(11):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(12):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(14):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 5  =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "Block protection, positive test";
                    -- TBPROT = '0'
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_bank ,none    ,1,0,0,0,1,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,read_sr1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(bank_rd,read_bank,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(16):=(w_scr  ,none     ,2,0,0,0,16#04#,0,0,valid,0 ns);
                    ELSE
                        command_seq(16):=(w_scr  ,none     ,2,0,0,0,16#00#,0,0,valid,0 ns);
                    END IF;
                    command_seq(17) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(20) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(w_sr  ,none      ,1,0,0,0,16#04#,0,0,valid,0 ns);
                    command_seq(26):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(30):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' THEN
                        --Sectors 126 and 127 are locked
                        command_seq(34):=(pg_prog,none    ,5,0,0,0,16#99#,127,20,valid,0 ns);
                        command_seq(35):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(36):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(37):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(38):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(39):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(40):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(41):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(42):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(43):=(pg_prog,none    ,5,0,0,0,16#99#,126,0,valid,0 ns);
                        command_seq(44):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(45):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(46):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(47):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(48):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(49):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --Sectors from 124 to 127 are locked
                        command_seq(50):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(51):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(52):=(w_sr  ,none      ,1,0,0,0,16#08#,0,0,valid,0 ns);
                        command_seq(53):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(54):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(55):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(56):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(57):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(58):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(59):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(60):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(61):=(pg_prog,none    ,5,0,0,0,16#99#,127,20,valid,0 ns);
                        command_seq(62):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(63):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(64):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(65):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(66):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(67):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(68):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(69):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(70):=(pg_prog,none    ,5,0,0,0,16#99#,124,0,valid,0 ns);
                        command_seq(71):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(72):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(73):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(74):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(75):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(76):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(77):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(78):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Sectors from 120 to 127 are locked
                        command_seq(79):=(w_sr  ,none      ,1,0,0,0,16#0C#,0,0,valid,0 ns);
                        command_seq(80):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(81):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(82):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(83):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(84):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(85):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(86):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(87):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(88):=(pg_prog,none    ,5,0,0,0,16#99#,127,20,valid,0 ns);
                        command_seq(89):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(90):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(91):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(92):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(93):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(94):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(95):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(96):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(97):=(pg_prog,none    ,5,0,0,0,16#99#,120,0,valid,0 ns);
                        command_seq(98):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(99):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(100):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(101):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(102):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(103):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(104):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(105):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Sectors from 112 to 127 are locked
                        command_seq(106):=(w_sr  ,none      ,1,0,0,0,16#10#,0,0,valid,0 ns);
                        command_seq(107):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(108):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(109):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(110):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(111):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(112):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(113):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(114):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(115):=(pg_prog,none    ,5,0,0,0,16#99#,127,20,valid,0 ns);
                        command_seq(116):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(117):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(118):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(119):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(120):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(121):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(122):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(123):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(124):=(pg_prog,none    ,5,0,0,0,16#99#,112,0,valid,0 ns);
                        command_seq(125):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(126):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(127):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(128):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(129):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(130):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(131):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(132):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Sectors from 96 to 127 are locked
                        command_seq(133):=(w_sr  ,none      ,1,0,0,0,16#14#,0,0,valid,0 ns);
                        command_seq(134):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(135):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(136):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(137):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(138):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(139):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(140):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(141):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(142):=(pg_prog,none    ,5,0,0,0,16#99#,127,20,valid,0 ns);
                        command_seq(143):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(144):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(145):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(146):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(147):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(148):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(149):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(150):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(151):=(pg_prog,none    ,5,0,0,0,16#99#,96,0,valid,0 ns);
                        command_seq(152):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(153):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(154):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(155):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(156):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(157):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(158):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(159):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Sectors from 64 to 127 are locked
                        command_seq(160):=(w_sr  ,none      ,1,0,0,0,16#18#,0,0,valid,0 ns);
                        command_seq(161):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(162):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(163):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(164):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(165):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(166):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(167):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(168):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(169):=(pg_prog,none    ,5,0,0,0,16#99#,127,20,valid,0 ns);
                        command_seq(170):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(171):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(172):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(173):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(174):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(175):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(176):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(177):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(178):=(pg_prog,none    ,5,0,0,0,16#99#,64,0,valid,0 ns);
                        command_seq(179):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(180):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(181):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(182):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(183):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(184):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        IF Sec_Arch = FALSE THEN
                            --Sectors from 504 to 541 are locked
                            command_seq(34):=(pg_prog,none    ,5,0,0,0,16#99#,541,20,valid,0 ns);
                            command_seq(35):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(36):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(37):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(38):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(39):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(40):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(41):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(42):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(43):=(pg_prog,none    ,5,0,0,0,16#99#,504,0,valid,0 ns);
                            command_seq(44):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(45):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(46):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(47):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(48):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(49):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            --Sectors from 496 to 541 are locked
                            command_seq(50):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(51):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(52):=(w_sr  ,none      ,1,0,0,0,16#08#,0,0,valid,0 ns);
                            command_seq(53):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(54):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(55):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(56):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(57):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(58):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(59):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(60):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(61):=(pg_prog,none    ,5,0,0,0,16#99#,541,20,valid,0 ns);
                            command_seq(62):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(63):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(64):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(65):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(66):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(67):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(68):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(69):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(70):=(pg_prog,none    ,5,0,0,0,16#99#,496,0,valid,0 ns);
                            command_seq(71):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(72):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(73):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(74):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(75):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(76):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(77):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(78):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            --Sectors from 480 to 541 are locked
                            command_seq(79):=(w_sr  ,none      ,1,0,0,0,16#0C#,0,0,valid,0 ns);
                            command_seq(80):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(81):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(82):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(83):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(84):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(85):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(86):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(87):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(88):=(pg_prog,none    ,5,0,0,0,16#99#,541,20,valid,0 ns);
                            command_seq(89):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(90):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(91):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(92):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(93):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(94):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(95):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(96):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(97):=(pg_prog,none    ,5,0,0,0,16#99#,480,0,valid,0 ns);
                            command_seq(98):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(99):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(100):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(101):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(102):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(103):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(104):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(105):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            --Sectors from 448 to 541 are locked
                            command_seq(106):=(w_sr  ,none      ,1,0,0,0,16#10#,0,0,valid,0 ns);
                            command_seq(107):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(108):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(109):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(110):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(111):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(112):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(113):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(114):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(115):=(pg_prog,none    ,5,0,0,0,16#99#,541,20,valid,0 ns);
                            command_seq(116):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(117):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(118):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(119):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(120):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(121):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(122):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(123):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(124):=(pg_prog,none    ,5,0,0,0,16#99#,448,0,valid,0 ns);
                            command_seq(125):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(126):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(127):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(128):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(129):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(130):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(131):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(132):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            --Sectors from 384 to 541 are locked
                            command_seq(133):=(w_sr  ,none      ,1,0,0,0,16#14#,0,0,valid,0 ns);
                            command_seq(134):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(135):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(136):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(137):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(138):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(139):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(140):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(141):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(142):=(pg_prog,none    ,5,0,0,0,16#99#,541,20,valid,0 ns);
                            command_seq(143):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(144):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(145):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(146):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(147):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(148):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(149):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(150):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(151):=(pg_prog,none    ,5,0,0,0,16#99#,384,0,valid,0 ns);
                            command_seq(152):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(153):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(154):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(155):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(156):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(157):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(158):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(159):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            --Sectors from 256 to 541 are locked
                            command_seq(160):=(w_sr  ,none      ,1,0,0,0,16#18#,0,0,valid,0 ns);
                            command_seq(161):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(162):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(163):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(164):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(165):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(166):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(167):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(168):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(169):=(pg_prog,none    ,5,0,0,0,16#99#,541,20,valid,0 ns);
                            command_seq(170):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(171):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(172):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(173):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(174):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(175):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(176):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(177):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(178):=(pg_prog,none    ,5,0,0,0,16#99#,256,0,valid,0 ns);
                            command_seq(179):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(180):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(181):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(182):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(183):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(184):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        ELSE
                             --Sectors from 534 to 541 are locked
                            command_seq(34):=(pg_prog,none    ,5,0,0,0,16#99#,541,20,valid,0 ns);
                            command_seq(35):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(36):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(37):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(38):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(39):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(40):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(41):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(42):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(43):=(pg_prog,none    ,5,0,0,0,16#99#,534,0,valid,0 ns);
                            command_seq(44):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(45):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(46):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(47):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(48):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(49):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            --Sectors from 526 to 541 are locked
                            command_seq(50):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(51):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(52):=(w_sr  ,none      ,1,0,0,0,16#08#,0,0,valid,0 ns);
                            command_seq(53):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(54):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(55):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(56):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(57):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(58):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(59):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(60):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(61):=(pg_prog,none    ,5,0,0,0,16#99#,541,20,valid,0 ns);
                            command_seq(62):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(63):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(64):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(65):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(66):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(67):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(68):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(69):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(70):=(pg_prog,none    ,5,0,0,0,16#99#,526,0,valid,0 ns);
                            command_seq(71):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(72):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(73):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(74):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(75):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(76):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(77):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(78):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            --Sectors from 510 to 541 are locked
                            command_seq(79):=(w_sr  ,none      ,1,0,0,0,16#0C#,0,0,valid,0 ns);
                            command_seq(80):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(81):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(82):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(83):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(84):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(85):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(86):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(87):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(88):=(pg_prog,none    ,5,0,0,0,16#99#,541,20,valid,0 ns);
                            command_seq(89):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(90):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(91):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(92):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(93):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(94):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(95):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(96):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(97):=(pg_prog,none    ,5,0,0,0,16#99#,510,0,valid,0 ns);
                            command_seq(98):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(99):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(100):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(101):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(102):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(103):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(104):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(105):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            --Sectors from 478 to 541 are locked
                            command_seq(106):=(w_sr  ,none      ,1,0,0,0,16#10#,0,0,valid,0 ns);
                            command_seq(107):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(108):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(109):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(110):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(111):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(112):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(113):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(114):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(115):=(pg_prog,none    ,5,0,0,0,16#99#,541,20,valid,0 ns);
                            command_seq(116):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(117):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(118):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(119):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(120):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(121):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(122):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(123):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(124):=(pg_prog,none    ,5,0,0,0,16#99#,478,0,valid,0 ns);
                            command_seq(125):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(126):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(127):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(128):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(129):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(130):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(131):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(132):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            --Sectors from 414 to 541 are locked
                            command_seq(133):=(w_sr  ,none      ,1,0,0,0,16#14#,0,0,valid,0 ns);
                            command_seq(134):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(135):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(136):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(137):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(138):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(139):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(140):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(141):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(142):=(pg_prog,none    ,5,0,0,0,16#99#,541,20,valid,0 ns);
                            command_seq(143):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(144):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(145):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(146):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(147):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(148):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(149):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(150):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(151):=(pg_prog,none    ,5,0,0,0,16#99#,414,0,valid,0 ns);
                            command_seq(152):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(153):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(154):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(155):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(156):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(157):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(158):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(159):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            --Sectors from 286 to 541 are locked
                            command_seq(160):=(w_sr  ,none      ,1,0,0,0,16#18#,0,0,valid,0 ns);
                            command_seq(161):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(162):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(163):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(164):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(165):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(166):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(167):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(168):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(169):=(pg_prog,none    ,5,0,0,0,16#99#,541,20,valid,0 ns);
                            command_seq(170):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(171):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(172):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(173):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(174):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(175):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(176):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(177):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(178):=(pg_prog,none    ,5,0,0,0,16#99#,286,0,valid,0 ns);
                            command_seq(179):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(180):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(181):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(182):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(183):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(184):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        END IF;
                    END IF;
                    command_seq(185):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(186) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(187) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(188) :=(w_bank ,none    ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(189) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(190) :=(rd_sr1 ,read_sr1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(191) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(192) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(193) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(194):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(195):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(196):=(bank_rd,read_bank,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(197):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(198):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "Block protection, positive test";
                    -- TBPROT = '1'
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#24#,0,0,valid,0 ns);
                    ELSE
                        command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#20#,0,0,valid,0 ns);
                    END IF;
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(8) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' THEN
                        --Sectors 0 and 1 are locked
                        command_seq(13):=(w_sr  ,none      ,1,0,0,0,16#04#,0,0,valid,0 ns);
                        command_seq(14):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(15):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(16):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(17):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(18):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(19):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(20):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(21):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(22):=(pg_prog,none    ,5,0,0,0,16#99#,0,0,valid,0 ns);
                        command_seq(23):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(24):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(25):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(26):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(27):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(28):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(29):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(30):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(31):=(pg_prog,none    ,5,0,0,0,16#99#,1,0,valid,0 ns);
                        command_seq(32):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(33):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(34):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(35):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(36):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(37):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(38):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(39):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Sectors from 0 to 3 are locked
                        command_seq(40):=(w_sr  ,none      ,1,0,0,0,16#08#,0,0,valid,0 ns);
                        command_seq(41):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(42):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(43):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(44):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(45):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(46):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(47):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(48):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(49):=(pg_prog,none    ,5,0,0,0,16#99#,0,0,valid,0 ns);
                        command_seq(50):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(51):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(52):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(53):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(54):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(55):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(56):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(57):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(58):=(pg_prog,none    ,5,0,0,0,16#99#,3,0,valid,0 ns);
                        command_seq(59):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(60):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(61):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(62):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(63):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(64):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(65):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(66):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Sectors from 0 to 7 are locked
                        command_seq(67):=(w_sr  ,none      ,1,0,0,0,16#0C#,0,0,valid,0 ns);
                        command_seq(68):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(69):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(70):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(71):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(72):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(73):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(74):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(75):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(76):=(pg_prog,none    ,5,0,0,0,16#99#,1,0,valid,0 ns);
                        command_seq(77):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(78):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(79):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(80):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(81):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(82):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(83):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(84):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(85):=(pg_prog,none    ,5,0,0,0,16#99#,7,0,valid,0 ns);
                        command_seq(86):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(87):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(88):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(89):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(90):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(91):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(92):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(93):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Sectors from 0 to 15 are locked
                        command_seq(94):=(w_sr  ,none      ,1,0,0,0,16#10#,0,0,valid,0 ns);
                        command_seq(95):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(96):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(97):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(98):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(99):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(100):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(101):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(102):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(103):=(pg_prog,none    ,5,0,0,0,16#99#,2,0,valid,0 ns);
                        command_seq(104):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(105):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(106):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(107):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(108):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(109):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(110):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(111):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(112):=(pg_prog,none    ,5,0,0,0,16#99#,15,0,valid,0 ns);
                        command_seq(113):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(114):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(115):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(116):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(117):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(118):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(119):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(120):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Sectors from 0 to 31 are locked
                        command_seq(121):=(w_sr  ,none      ,1,0,0,0,16#14#,0,0,valid,0 ns);
                        command_seq(122):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(123):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(124):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(125):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(126):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(127):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(128):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(129):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(130):=(pg_prog,none    ,5,0,0,0,16#99#,0,0,valid,0 ns);
                        command_seq(131):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(132):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(133):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(134):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(135):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(136):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(137):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(138):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(139):=(pg_prog,none    ,5,0,0,0,16#99#,31,0,valid,0 ns);
                        command_seq(140):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(141):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(142):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(143):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(144):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(145):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(146):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(147):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Sectors from 0 to 63 are locked
                        command_seq(148):=(w_sr  ,none      ,1,0,0,0,16#18#,0,0,valid,0 ns);
                        command_seq(149):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(150):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(151):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(152):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(153):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(154):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(155):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(156):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(157):=(pg_prog,none    ,5,0,0,0,16#99#,0,0,valid,0 ns);
                        command_seq(158):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(159):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(160):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(161):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(162):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(163):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(164):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(165):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(166):=(pg_prog,none    ,5,0,0,0,16#99#,63,0,valid,0 ns);
                        command_seq(167):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(168):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(169):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(170):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(171):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(172):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(173):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(174):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --All sectors are locked
                        command_seq(175):=(w_sr  ,none      ,1,0,0,0,16#1C#,0,0,valid,0 ns);
                        command_seq(176):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(177):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(178):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(179):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(180):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(181):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(182):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(183):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(184):=(pg_prog,none    ,5,0,0,0,16#99#,0,0,valid,0 ns);
                        command_seq(185):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(186):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(187):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(188):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(189):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(190):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(191):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(192):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(193):=(pg_prog,none    ,5,0,0,0,16#99#,63,0,valid,0 ns);
                        command_seq(194):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(195):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(196):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(197):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(198):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(199):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(200):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(201):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(202):=(w_scr  ,none     ,2,0,0,0,16#24#,0,0,valid,0 ns);
                        command_seq(203):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(204):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(205):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(206):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(207):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(208):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        IF Sec_Arch = FALSE THEN
                            --Sectors 0 and 7 are locked
                            command_seq(13):=(w_sr  ,none      ,1,0,0,0,16#04#,0,0,valid,0 ns);
                            command_seq(14):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(15):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(16):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(17):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(18):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(19):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(20):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(21):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(22):=(pg_prog,none    ,5,0,0,0,16#99#,0,0,valid,0 ns);
                            command_seq(23):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(24):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(25):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(26):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(27):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(28):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(29):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(30):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(31):=(pg_prog,none    ,5,0,0,0,16#99#,7,0,valid,0 ns);
                            command_seq(32):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(33):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(34):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(35):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(36):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(37):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(38):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(39):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            --Sectors from 0 to 15 are locked
                            command_seq(40):=(w_sr  ,none      ,1,0,0,0,16#08#,0,0,valid,0 ns);
                            command_seq(41):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(42):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(43):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(44):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(45):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(46):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(47):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(48):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(49):=(pg_prog,none    ,5,0,0,0,16#99#,0,0,valid,0 ns);
                            command_seq(50):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(51):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(52):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(53):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(54):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(55):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(56):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(57):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(58):=(pg_prog,none    ,5,0,0,0,16#99#,15,0,valid,0 ns);
                            command_seq(59):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(60):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(61):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(62):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(63):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(64):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(65):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(66):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            --Sectors from 0 to 31 are locked
                            command_seq(67):=(w_sr  ,none      ,1,0,0,0,16#0C#,0,0,valid,0 ns);
                            command_seq(68):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(69):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(70):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(71):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(72):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(73):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(74):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(75):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(76):=(pg_prog,none    ,5,0,0,0,16#99#,1,0,valid,0 ns);
                            command_seq(77):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(78):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(79):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(80):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(81):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(82):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(83):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(84):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(85):=(pg_prog,none    ,5,0,0,0,16#99#,31,0,valid,0 ns);
                            command_seq(86):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(87):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(88):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(89):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(90):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(91):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(92):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(93):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            --Sectors from 0 to 63 are locked
                            command_seq(94):=(w_sr  ,none      ,1,0,0,0,16#10#,0,0,valid,0 ns);
                            command_seq(95):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(96):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(97):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(98):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(99):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(100):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(101):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(102):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(103):=(pg_prog,none    ,5,0,0,0,16#99#,2,0,valid,0 ns);
                            command_seq(104):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(105):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(106):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(107):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(108):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(109):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(110):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(111):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(112):=(pg_prog,none    ,5,0,0,0,16#99#,63,0,valid,0 ns);
                            command_seq(113):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(114):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(115):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(116):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(117):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(118):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(119):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(120):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            --Sectors from 0 to 127 are locked
                            command_seq(121):=(w_sr  ,none      ,1,0,0,0,16#14#,0,0,valid,0 ns);
                            command_seq(122):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(123):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(124):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(125):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(126):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(127):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(128):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(129):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(130):=(pg_prog,none    ,5,0,0,0,16#99#,0,0,valid,0 ns);
                            command_seq(131):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(132):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(133):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(134):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(135):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(136):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(137):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(138):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(139):=(pg_prog,none    ,5,0,0,0,16#99#,127,0,valid,0 ns);
                            command_seq(140):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(141):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(142):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(143):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(144):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(145):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(146):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(147):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            --Sectors from 0 to 255 are locked
                            command_seq(148):=(w_sr  ,none      ,1,0,0,0,16#18#,0,0,valid,0 ns);
                            command_seq(149):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(150):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(151):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(152):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(153):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(154):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(155):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(156):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(157):=(pg_prog,none    ,5,0,0,0,16#99#,0,0,valid,0 ns);
                            command_seq(158):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(159):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(160):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(161):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(162):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(163):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(164):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(165):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(166):=(pg_prog,none    ,5,0,0,0,16#99#,255,0,valid,0 ns);
                            command_seq(167):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(168):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(169):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(170):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(171):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(172):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(173):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(174):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            --All sectors are locked
                            command_seq(175):=(w_sr  ,none      ,1,0,0,0,16#1C#,0,0,valid,0 ns);
                            command_seq(176):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(177):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(178):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(179):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(180):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(181):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(182):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(183):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(184):=(pg_prog,none    ,5,0,0,0,16#99#,0,0,valid,0 ns);
                            command_seq(185):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(186):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(187):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(188):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(189):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(190):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(191):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(192):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(193):=(pg_prog,none    ,5,0,0,0,16#99#,255,0,valid,0 ns);
                            command_seq(194):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(195):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(196):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(197):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(198):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(199):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(200):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(201):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(202):=(w_scr  ,none     ,2,0,0,0,16#24#,0,0,valid,0 ns);
                            command_seq(203):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(204):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(205):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(206):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(207):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(208):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        ELSE
                            --Sectors 0 and 37 are locked
                            command_seq(13):=(w_sr  ,none      ,1,0,0,0,16#04#,0,0,valid,0 ns);
                            command_seq(14):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(15):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(16):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(17):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(18):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(19):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(20):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(21):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(22):=(pg_prog,none    ,5,0,0,0,16#99#,0,0,valid,0 ns);
                            command_seq(23):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(24):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(25):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(26):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(27):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(28):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(29):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(30):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(31):=(pg_prog,none    ,5,0,0,0,16#99#,37,0,valid,0 ns);
                            command_seq(32):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(33):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(34):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(35):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(36):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(37):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(38):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(39):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            --Sectors from 0 to 45 are locked
                            command_seq(40):=(w_sr  ,none      ,1,0,0,0,16#08#,0,0,valid,0 ns);
                            command_seq(41):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(42):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(43):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(44):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(45):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(46):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(47):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(48):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(49):=(pg_prog,none    ,5,0,0,0,16#99#,0,0,valid,0 ns);
                            command_seq(50):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(51):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(52):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(53):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(54):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(55):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(56):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(57):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(58):=(pg_prog,none    ,5,0,0,0,16#99#,45,0,valid,0 ns);
                            command_seq(59):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(60):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(61):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(62):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(63):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(64):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(65):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(66):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            --Sectors from 0 to 61 are locked
                            command_seq(67):=(w_sr  ,none      ,1,0,0,0,16#0C#,0,0,valid,0 ns);
                            command_seq(68):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(69):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(70):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(71):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(72):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(73):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(74):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(75):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(76):=(pg_prog,none    ,5,0,0,0,16#99#,1,0,valid,0 ns);
                            command_seq(77):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(78):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(79):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(80):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(81):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(82):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(83):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(84):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(85):=(pg_prog,none    ,5,0,0,0,16#99#,61,0,valid,0 ns);
                            command_seq(86):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(87):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(88):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(89):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(90):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(91):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(92):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(93):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            --Sectors from 0 to 93 are locked
                            command_seq(94):=(w_sr  ,none      ,1,0,0,0,16#10#,0,0,valid,0 ns);
                            command_seq(95):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(96):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(97):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(98):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(99):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(100):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(101):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(102):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(103):=(pg_prog,none    ,5,0,0,0,16#99#,2,0,valid,0 ns);
                            command_seq(104):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(105):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(106):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(107):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(108):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(109):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(110):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(111):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(112):=(pg_prog,none    ,5,0,0,0,16#99#,93,0,valid,0 ns);
                            command_seq(113):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(114):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(115):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(116):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(117):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(118):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(119):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(120):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            --Sectors from 0 to 157 are locked
                            command_seq(121):=(w_sr  ,none      ,1,0,0,0,16#14#,0,0,valid,0 ns);
                            command_seq(122):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(123):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(124):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(125):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(126):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(127):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(128):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(129):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(130):=(pg_prog,none    ,5,0,0,0,16#99#,0,0,valid,0 ns);
                            command_seq(131):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(132):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(133):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(134):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(135):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(136):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(137):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(138):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(139):=(pg_prog,none    ,5,0,0,0,16#99#,157,0,valid,0 ns);
                            command_seq(140):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(141):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(142):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(143):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(144):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(145):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(146):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(147):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            --Sectors from 0 to 285 are locked
                            command_seq(148):=(w_sr  ,none      ,1,0,0,0,16#18#,0,0,valid,0 ns);
                            command_seq(149):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(150):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(151):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(152):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(153):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(154):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(155):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(156):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(157):=(pg_prog,none    ,5,0,0,0,16#99#,0,0,valid,0 ns);
                            command_seq(158):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(159):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(160):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(161):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(162):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(163):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(164):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(165):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(166):=(pg_prog,none    ,5,0,0,0,16#99#,285,0,valid,0 ns);
                            command_seq(167):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(168):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(169):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(170):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(171):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(172):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(173):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(174):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            --All sectors are locked
                            command_seq(175):=(w_sr  ,none      ,1,0,0,0,16#1C#,0,0,valid,0 ns);
                            command_seq(176):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(177):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(178):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(179):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(180):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(181):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(182):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(183):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(184):=(pg_prog,none    ,5,0,0,0,16#99#,0,0,valid,0 ns);
                            command_seq(185):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(186):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(187):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(188):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(189):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(190):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(191):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(192):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(193):=(pg_prog,none    ,5,0,0,0,16#99#,285,0,valid,0 ns);
                            command_seq(194):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(195):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(196):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(197):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(198):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(199):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(200):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(201):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(202):=(w_scr  ,none     ,2,0,0,0,16#20#,0,0,valid,0 ns);
                            command_seq(203):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(204):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(205):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                            command_seq(206):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(207):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                            command_seq(208):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        END IF;
                    END IF;
                    command_seq(209):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(210):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --All sectors are unlocked
                    command_seq(211):=(w_sr  ,none      ,1,0,0,0,16#00#,0,0,valid,0 ns);
                    command_seq(212):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(213):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(214):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(215):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(216):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(217):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(218):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                WHEN 3 =>
                REPORT " PPB bits protect sector when programmed";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(ppbacc_rd,read_ppbar,2,0,0,0,0,38,19,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    -- PPB Program command is issued
                    command_seq(4) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(5) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(w_ppb  ,none    ,1,0,0,0,0,38,0,valid,0 ns);
                    command_seq(8) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(12):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(ppbacc_rd,read_ppbar,2,0,0,0,0,38,19,valid,0 ns);
                    command_seq(16):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Verify that Erase Operation is rejected
                    command_seq(17):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(sector_erase_4,none,0,0,0,0,0,38,0,valid,0 ns);
                    command_seq(20):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(rd_sr1 ,erase_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(rd_4   ,read_4,7,0,0,0,0,38,0,valid,0 ns);
                    command_seq(25):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 6  =>  --Initial configuration test (TBPROT)
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "TBPROT bit negative test";
                    --If TBPROT is programmed to 1, an attempt to change it back
                    --to zero will fail and set the Program Error bit (P_ERR in SR1[6]).
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(4) :=(w_scr  ,err      ,2,0,0,0,16#04#,0,0,valid,0 ns);
                    ELSE
                        command_seq(4) :=(w_scr  ,err      ,2,0,0,0,16#00#,0,0,valid,0 ns);
                    END IF;
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Verify that operation is not accepted
                    command_seq(6) :=(rd_sr1 ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Verify that P_ERR bit is set
                    command_seq(8) :=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Verify that TBPROT did not change its value
                    command_seq(10):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 7  =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "READ, positive tests";
                    -- 3 Bytes address and EXTADD = '0'
                    -- Bank Register = "00000000";
                    -- Normal Read
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(rd     ,read     ,5,0,0,0,0,63,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(rd     ,read     ,5,0,0,0,0,63,5,clock_num,0 ns);
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Fast Read
                    command_seq(6) :=(fast_rd,read_fast,5,0,0,0,0,63,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(fast_rd,read_fast,5,0,0,0,0,63,5,clock_num,0 ns);
                    command_seq(9) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Dual Output Read Mode
                    command_seq(10):=(dual_rd,read_dual,5,0,0,0,0,63,5,valid,0 ns);
                    command_seq(11):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(dual_rd,read_dual,5,0,0,0,0,63,5,clock_num,0 ns);
                    command_seq(13):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Dual I/O High Performance Read Mode
                    command_seq(14):=(dual_high_rd,read_dual_hi,5,0,0,0,0,63,5,valid,0 ns);
                    command_seq(15):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(dual_high_rd,read_dual_hi,5,0,0,0,0,63,5,clock_num,0 ns);
                    command_seq(17):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Quad Output Read Mode
                    command_seq(18):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(20) :=(w_scr  ,none      ,2,0,0,0,16#26#,0,0,valid,0 ns);
                    ELSE
                        command_seq(20) :=(w_scr  ,none      ,2,0,0,0,16#22#,0,0,valid,0 ns);
                    END IF;
                    command_seq(21):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(24):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(quad_rd,rd_quad  ,5,0,0,0,0,1,0,valid,0 ns);
                    command_seq(28):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29):=(quad_rd,rd_quad  ,5,0,0,0,0,1,0,clock_num,0 ns);
                    command_seq(30):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Quad I/O High Performance Read Mode
                    command_seq(31):=(quad_high_rd,read_quad_hi,5,0,0,0,0,1,0,valid,0 ns);
                    command_seq(32):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33):=(quad_high_rd,read_quad_hi,5,0,0,0,0,1,0,clock_num,0 ns);
                    --Disabling QUAD mode
                    command_seq(34):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(35) :=(w_scr  ,none      ,2,0,0,0,16#24#,0,0,valid,0 ns);
                    ELSE
                        command_seq(35) :=(w_scr  ,none      ,2,0,0,0,16#20#,0,0,valid,0 ns);
                    END IF;
                    command_seq(36):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(38):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Bank Register = "00000001";
                    command_seq(39):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(42):=(w_bank ,none    ,1,0,0,0,1,0,0,valid,0 ns);
                    command_seq(43):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(44):=(rd_sr1 ,read_sr1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(45):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(46):=(wt     ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(47):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(48):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(49):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(50):=(bank_rd,read_bank,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(51):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Normal Read
                    IF Model(16) = '1' THEN
                    -- Reading from the top of memory array (verify that when the
                    -- highest address is reached, the address counter will wrap
                    -- around and roll back to 000000h, allowing the read sequence
                    -- to be continued indefinitely.
                        command_seq(52):=(rd     ,read     ,5,0,0,0,0,127,16#3FFFC#,valid,0 ns);
                        command_seq(53):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(54):=(rd     ,read     ,5,0,0,0,0,65,0,clock_num,0 ns);
                        command_seq(55):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Fast Read
                        command_seq(56):=(fast_rd,read_fast,5,0,0,0,0,127,16#3FFFC#,valid,0 ns);
                        command_seq(57):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(58):=(fast_rd,read_fast,5,0,0,0,0,65,5,clock_num,0 ns);
                        command_seq(59):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Dual Output Read Mode
                        command_seq(60):=(dual_rd,read_dual,5,0,0,0,0,127,16#3FFFC#,valid,0 ns);
                        command_seq(61):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(62):=(dual_rd,read_dual,5,0,0,0,0,65,0,clock_num,0 ns);
                        command_seq(63):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Dual I/O High Performance Read Mode
                        command_seq(64):=(dual_high_rd,read_dual_hi,5,0,0,0,0,127,16#3FFFC#,valid,0 ns);
                        command_seq(65):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(66):=(dual_high_rd,read_dual_hi,5,0,0,0,0,65,0,clock_num,0 ns);
                        command_seq(67):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSIF Model(16) = '0' AND Sec_Arch = FALSE THEN
                        command_seq(52):=(rd     ,read     ,5,0,0,0,0,541,16#FFC#,valid,0 ns);
                        command_seq(53):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(54):=(rd     ,read     ,5,0,0,0,0,256,0,clock_num,0 ns);
                        command_seq(55):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Fast Read
                        command_seq(56):=(fast_rd,read_fast,5,0,0,0,0,541,16#FFC#,valid,0 ns);
                        command_seq(57):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(58):=(fast_rd,read_fast,5,0,0,0,0,256,5,clock_num,0 ns);
                        command_seq(59):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Dual Output Read Mode
                        command_seq(60):=(dual_rd,read_dual,5,0,0,0,0,541,16#FFC#,valid,0 ns);
                        command_seq(61):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(62):=(dual_rd,read_dual,5,0,0,0,0,256,0,clock_num,0 ns);
                        command_seq(63):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Dual I/O High Performance Read Mode
                        command_seq(64):=(dual_high_rd,read_dual_hi,5,0,0,0,0,541,16#FFC#,valid,0 ns);
                        command_seq(65):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(66):=(dual_high_rd,read_dual_hi,5,0,0,0,0,256,0,clock_num,0 ns);
                        command_seq(67):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(52):=(rd     ,read     ,5,0,0,0,0,541,16#FFFC#,valid,0 ns);
                        command_seq(53):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(54):=(rd     ,read     ,5,0,0,0,0,286,0,clock_num,0 ns);
                        command_seq(55):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Fast Read
                        command_seq(56):=(fast_rd,read_fast,5,0,0,0,0,541,16#FFFC#,valid,0 ns);
                        command_seq(57):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(58):=(fast_rd,read_fast,5,0,0,0,0,286,5,clock_num,0 ns);
                        command_seq(59):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Dual Output Read Mode
                        command_seq(60):=(dual_rd,read_dual,5,0,0,0,0,541,16#FFFC#,valid,0 ns);
                        command_seq(61):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(62):=(dual_rd,read_dual,5,0,0,0,0,286,0,clock_num,0 ns);
                        command_seq(63):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Dual I/O High Performance Read Mode
                        command_seq(64):=(dual_high_rd,read_dual_hi,5,0,0,0,0,541,16#FFFC#,valid,0 ns);
                        command_seq(65):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(66):=(dual_high_rd,read_dual_hi,5,0,0,0,0,286,0,clock_num,0 ns);
                        command_seq(67):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    -- Quad Output Read Mode
                    command_seq(68):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(69):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(70) :=(w_scr  ,none      ,2,0,0,0,16#26#,0,0,valid,0 ns);
                    ELSE
                        command_seq(70) :=(w_scr  ,none      ,2,0,0,0,16#22#,0,0,valid,0 ns);
                    END IF;
                    command_seq(71):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(72):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(73):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(74):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(75):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(76):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' THEN
                    -- Reading from the top of memory array (verify that when the
                    -- highest address is reached, the address counter will wrap
                    -- around and roll back to 000000h, allowing the read sequence
                    -- to be continued indefinitely.
                        command_seq(77):=(quad_rd,rd_quad  ,5,0,0,0,0,127,16#3FFFC#,valid,0 ns);
                        command_seq(78):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(79):=(quad_rd,rd_quad  ,5,0,0,0,0,65,0,clock_num,0 ns);
                        command_seq(80):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Quad I/O High Performance Read Mode
                        command_seq(81):=(quad_high_rd,read_quad_hi,5,0,0,0,0,127,16#3FFFC#,valid,0 ns);
                        command_seq(82):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(83):=(quad_high_rd,read_quad_hi,5,0,0,0,0,65,0,clock_num,0 ns);
                        command_seq(84):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSIF Model(16) = '0' AND Sec_Arch = FALSE THEN
                        command_seq(77):=(quad_rd,rd_quad  ,5,0,0,0,0,541,16#FFC#,valid,0 ns);
                        command_seq(78):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(79):=(quad_rd,rd_quad  ,5,0,0,0,0,256,0,clock_num,0 ns);
                        command_seq(80):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Quad I/O High Performance Read Mode
                        command_seq(81):=(quad_high_rd,read_quad_hi,5,0,0,0,0,541,16#FFC#,valid,0 ns);
                        command_seq(82):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(83):=(quad_high_rd,read_quad_hi,5,0,0,0,0,256,0,clock_num,0 ns);
                        command_seq(84):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(77):=(quad_rd,rd_quad  ,5,0,0,0,0,541,16#FFFC#,valid,0 ns);
                        command_seq(78):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(79):=(quad_rd,rd_quad  ,5,0,0,0,0,286,0,clock_num,0 ns);
                        command_seq(80):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Quad I/O High Performance Read Mode
                        command_seq(81):=(quad_high_rd,read_quad_hi,5,0,0,0,0,541,16#FFFC#,valid,0 ns);
                        command_seq(82):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(83):=(quad_high_rd,read_quad_hi,5,0,0,0,0,286,0,clock_num,0 ns);
                        command_seq(84):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    command_seq(85):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(86):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(87):=(w_bank ,none     ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(88):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(89):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(90):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(91):=(wt     ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(92):=(rd_sr1 ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(93):=(rd_sr1 ,pgm_succ ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(94):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(95):=(bank_rd,read_bank,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(96):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --If given address is outside of defined bank, warning is generated
                    IF Model(16) = '1' THEN
                        command_seq(97):=(quad_rd,err      ,5,0,0,0,0,127,5,valid,0 ns);
                        command_seq(98):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(97):=(quad_rd,err      ,5,0,0,0,0,541,5,valid,0 ns);
                        command_seq(98):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    --Setting up EXTADD bit to '1'
                    command_seq(99):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(100):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(101):=(w_bank ,none     ,1,0,0,0,16#80#,0,0,valid,0 ns);
                    command_seq(102):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(103):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(104):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(105):=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(106):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(107):=(wt     ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(108):=(rd_sr1 ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(109):=(rd_sr1 ,pgm_succ ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(110):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(111):=(bank_rd,read_bank,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(112):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(113):=(done   ,none    ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "READ, positive tests";
                    -- 3 Bytes address and EXTADD = '1'
                    -- Normal Read
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Setting up QUAD bit to '0'
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#24#,0,0,valid,0 ns);
                    ELSE
                        command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#20#,0,0,valid,0 ns);
                    END IF;
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(8) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(rd     ,read     ,5,0,0,0,0,1,0,valid,0 ns);
                    command_seq(12):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(rd     ,read     ,5,0,0,0,0,1,0,clock_num,0 ns);
                    command_seq(14):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Fast Read
                    command_seq(15) :=(fast_rd,read_fast,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(16) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17) :=(fast_rd,read_fast,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(18) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Dual Output Read Mode
                    command_seq(19):=(dual_rd,read_dual,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(20):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(dual_rd,read_dual,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(22):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Dual I/O High Performance Read Mode
                    command_seq(23):=(dual_high_rd,read_dual_hi,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(24):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(dual_high_rd,read_dual_hi,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(26):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Quad Output Read Mode
                    command_seq(27):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(29):=(w_scr  ,none     ,2,0,0,0,16#26#,0,0,valid,0 ns);
                    ELSE
                        command_seq(29):=(w_scr  ,none     ,2,0,0,0,16#22#,0,0,valid,0 ns);
                    END IF;
                    command_seq(30):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(33):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36):=(quad_rd,rd_quad  ,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(37):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38):=(quad_rd,rd_quad  ,5,0,0,0,0,3,5,clock_num,0 ns);
                    command_seq(39):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Quad I/O High Performance Read Mode
                    IF Model(16) = '1' THEN
                    -- Reading from the top of memory array (verify that when the
                    -- highest address is reached, the address counter will wrap
                    -- around and roll back to 000000h, allowing the read sequence
                    -- to be continued indefinitely.
                        command_seq(40):=(quad_high_rd,read_quad_hi,5,0,0,0,0,127,16#3FFFC#,valid,0 ns);
                        command_seq(41):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(42):=(quad_high_rd,read_quad_hi,5,0,0,0,0,127,16#3FFFC#,clock_num,0 ns);
                        command_seq(43):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSIF Model(16) = '0' AND Sec_Arch = FALSE THEN
                        command_seq(40):=(quad_high_rd,read_quad_hi,5,0,0,0,0,541,16#FFC#,valid,0 ns);
                        command_seq(41):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(42):=(quad_high_rd,read_quad_hi,5,0,0,0,0,541,16#FFC#,clock_num,0 ns);
                        command_seq(43):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(40):=(quad_high_rd,read_quad_hi,5,0,0,0,0,541,16#FFFC#,valid,0 ns);
                        command_seq(41):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(42):=(quad_high_rd,read_quad_hi,5,0,0,0,0,541,16#FFFC#,clock_num,0 ns);
                        command_seq(43):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    --Setting up EXTADD bit to '0'
                    command_seq(44):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(45):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(46):=(w_bank ,none     ,1,0,0,0,16#00#,0,0,valid,0 ns);
                    command_seq(47):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(48):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(49):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(50):=(wt     ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(51):=(rd_sr1 ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(52):=(rd_sr1 ,pgm_succ ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(53):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(54):=(bank_rd,read_bank,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(55):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(56):=(done   ,none     ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 3  =>
                    REPORT "READ, positive tests";
                    -- 4 Bytes address
                    -- Normal Read
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#24#,0,0,valid,0 ns);
                    ELSE
                        command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#20#,0,0,valid,0 ns);
                    END IF;
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(8) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(rd_4   ,read_4     ,5,0,0,0,0,1,0,valid,0 ns);
                    command_seq(12):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(rd_4   ,read_4   ,5,0,0,0,0,1,0,clock_num,0 ns);
                    command_seq(14):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Fast Read
                    command_seq(15) :=(fast_rd4,read_fast_4,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(16) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17) :=(fast_rd4,read_fast_4,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(18) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Dual Output Read Mode
                    command_seq(19):=(dual_rd_4,read_dual_4,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(20):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(dual_rd_4,read_dual_4,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(22):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Dual I/O High Performance Read Mode
                    command_seq(23):=(dual_high_rd_4,read_dual_hi4,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(24):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(dual_high_rd_4,read_dual_hi4,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(26):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Quad Output Read Mode
                    command_seq(27):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(29):=(w_scr  ,none     ,2,0,0,0,16#26#,0,0,valid,0 ns);
                    ELSE
                        command_seq(29):=(w_scr  ,none     ,2,0,0,0,16#22#,0,0,valid,0 ns);
                    END IF;
                    command_seq(30):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(33):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36):=(quad_rd_4,rd_quad_4,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(37):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38):=(quad_rd_4,rd_quad_4,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(39):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Quad I/O High Performance Read Mode
                    IF Model(16) = '1' THEN
                    -- Reading from the top of memory array (verify that when the
                    -- highest address is reached, the address counter will wrap
                    -- around and roll back to 000000h, allowing the read sequence
                    -- to be continued indefinitely.
                        command_seq(40):=(quad_high_rd_4,read_quad_hi4,5,0,0,0,0,127,16#3FFFC#,valid,0 ns);
                        command_seq(41):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(42):=(quad_high_rd_4,read_quad_hi4,5,0,0,0,0,127,16#3FFFC#,clock_num,0 ns);
                        command_seq(43):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSIF Model(16) = '0' AND Sec_Arch = FALSE THEN
                        command_seq(40):=(quad_high_rd_4,read_quad_hi4,5,0,0,0,0,541,16#FFC#,valid,0 ns);
                        command_seq(41):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(42):=(quad_high_rd_4,read_quad_hi4,5,0,0,0,0,541,16#FFC#,clock_num,0 ns);
                        command_seq(43):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(40):=(quad_high_rd_4,read_quad_hi4,5,0,0,0,0,541,16#FFFC#,valid,0 ns);
                        command_seq(41):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(42):=(quad_high_rd_4,read_quad_hi4,5,0,0,0,0,541,16#FFFC#,clock_num,0 ns);
                        command_seq(43):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    command_seq(44):=(done   ,none     ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 4  =>
                    REPORT "READ, positive tests";
                    IF (Model(15) = '0' OR Model(15) = '2' OR Model(15) = '3' OR Model(15) = 'R' OR
                        Model(15) = 'A' OR Model(15) = 'B' OR Model(15) = 'C' OR Model(15) = 'D' OR
                        Model(15) = 'Y' OR Model(15) = 'Z' OR Model(15) = 'S' OR Model(15) = 'T' OR
                        Model(15) = 'K' OR Model(15) = 'L') THEN
                    -- Continuous read
                        command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                            command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#24#,0,0,valid,0 ns);
                        ELSE
                            command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#20#,0,0,valid,0 ns);
                        END IF;
                        command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(7) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(8) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(9) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(10):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- 3 Bytes address and EXTADD = '0'
                        -- dual high performance read - Initial access, mode bits are Axh
                        command_seq(11):=(dual_high_rd,read_dual_hi,5,0,0,0,16#A0#,0,0,valid,0 ns);
                        command_seq(12):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Continuous dual high performance read - Subsequent access
                        command_seq(13):=(dual_high_rd,rd_cont_dualIO,5,0,0,0,0,0,1,break,0 ns);
                        command_seq(14):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- 4 Bytes address
                        -- dual high performance read - Initial access, mode bits are Axh
                        command_seq(15):=(dual_high_rd_4,read_dual_4,5,0,0,0,16#A0#,0,0,valid,0 ns);
                        command_seq(16):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(17):=(dual_high_rd_4,rd_cont_dualIO4,5,0,0,0,0,0,1,break,0 ns);
                        command_seq(18):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- 3 Bytes address and EXTADD = '0'
                        -- Quad I/O High Performance Read Mode
                        command_seq(19):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(20):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                            command_seq(21):=(w_scr  ,none     ,2,0,0,0,16#26#,0,0,valid,0 ns);
                        ELSE
                            command_seq(21):=(w_scr  ,none     ,2,0,0,0,16#22#,0,0,valid,0 ns);
                        END IF;
                        command_seq(22):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(23):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(24):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(25):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(26):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(27):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- quad high performance read - Initial access, mode bits are Axh
                        command_seq(28):=(quad_high_rd,read_quad_hi,5,0,0,0,16#A0#,1,0,valid,0 ns);
                        command_seq(29):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Continuous quad high performance read - Subsequent access
                        command_seq(30):=(quad_high_rd,rd_cont_quadIO,5,0,0,0,0,1,0,break,0 ns);
                        command_seq(31):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- 4 Bytes address
                        -- quad high performance read - Initial access, mode bits are Axh
                        command_seq(32):=(quad_high_rd_4,read_quad_hi4,5,0,0,0,16#A0#,1,0,valid,0 ns);
                        command_seq(33):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Continuous quad high performance read - Subsequent access
                        command_seq(34):=(quad_high_rd_4,rd_cont_quadIO4,5,0,0,0,0,1,0,break,0 ns);
                        command_seq(35):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(36):=(done   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        REPORT("Continuous read mode exists only in EHPLC models");
                    END IF;

                    WHEN 5  =>
                    REPORT "READ, positive tests";
                    -- 3 Bytes address and EXTADD = '0'
                    -- Read memory array for different values of Latency code
                    -- LC1 = '0' and LC0 = '1'
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#64#,0,0,valid,0 ns);
                    ELSE
                        command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#60#,0,0,valid,0 ns);
                    END IF;
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(8) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Dual I/O High Performance Read Mode
                    command_seq(11):=(dual_high_rd,read_dual_hi,5,0,0,0,0,1,0,valid,0 ns);
                    command_seq(12):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(dual_high_rd,read_dual_hi,5,0,0,0,0,1,0,clock_num,0 ns);
                    command_seq(14):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Quad I/O High Performance Read Mode
                    command_seq(15):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(17):=(w_scr  ,none     ,2,0,0,0,16#66#,0,0,valid,0 ns);
                    ELSE
                        command_seq(17):=(w_scr  ,none     ,2,0,0,0,16#62#,0,0,valid,0 ns);
                    END IF;
                    command_seq(18):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(21):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(quad_high_rd,read_quad_hi,5,0,0,0,0,1,0,valid,0 ns);
                    command_seq(25):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(quad_high_rd,read_quad_hi,5,0,0,0,0,1,0,clock_num,0 ns);
                    command_seq(27):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- LC1 = '1' and LC0 = '0'
                    command_seq(28) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(30):=(w_scr  ,none     ,2,0,0,0,16#A4#,0,0,valid,0 ns);
                    ELSE
                        command_seq(30):=(w_scr  ,none     ,2,0,0,0,16#A0#,0,0,valid,0 ns);
                    END IF;
                    command_seq(31) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(34) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Dual I/O High Performance Read Mode
                    command_seq(37):=(dual_high_rd,read_dual_hi,5,0,0,0,0,1,0,valid,0 ns);
                    command_seq(38):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39):=(dual_high_rd,read_dual_hi,5,0,0,0,0,1,0,clock_num,0 ns);
                    command_seq(40):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(42):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(43):=(w_scr  ,none     ,2,0,0,0,16#A6#,0,0,valid,0 ns);
                    ELSE
                        command_seq(43):=(w_scr  ,none     ,2,0,0,0,16#A2#,0,0,valid,0 ns);
                    END IF;
                    command_seq(44):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(45):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(46):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(47):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(48):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(49):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Quad I/O High Performance Read Mode
                    command_seq(50):=(quad_high_rd,read_quad_hi,5,0,0,0,0,1,0,valid,0 ns);
                    command_seq(51):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(52):=(quad_high_rd,read_quad_hi,5,0,0,0,0,1,0,clock_num,0 ns);
                    command_seq(53):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- LC1 = '1' and LC0 = '1'
                    command_seq(54) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(55) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(56):=(w_scr  ,none     ,2,0,0,0,16#E4#,0,0,valid,0 ns);
                    ELSE
                        command_seq(56):=(w_scr  ,none     ,2,0,0,0,16#E0#,0,0,valid,0 ns);
                    END IF;
                    command_seq(57) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(58) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(59) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(60) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(61) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(62) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Fast Read
                    command_seq(63) :=(fast_rd,read_fast,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(64) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(65) :=(fast_rd4,read_fast_4,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(66) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Dual I/O High Performance Read Mode
                    command_seq(67):=(dual_high_rd,read_dual_hi,5,0,0,0,0,1,0,valid,0 ns);
                    command_seq(68):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(69):=(dual_high_rd,read_dual_hi,5,0,0,0,0,1,0,clock_num,0 ns);
                    command_seq(70):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(71):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(72):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(73):=(w_scr  ,none     ,2,0,0,0,16#E6#,0,0,valid,0 ns);
                    ELSE
                        command_seq(73):=(w_scr  ,none     ,2,0,0,0,16#E2#,0,0,valid,0 ns);
                    END IF;
                    command_seq(74):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(75):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(76):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(77):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(78):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(79):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Quad I/O High Performance Read Mode
                    command_seq(80):=(quad_high_rd,read_quad_hi,5,0,0,0,0,1,0,valid,0 ns);
                    command_seq(81):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(82):=(quad_high_rd,read_quad_hi,5,0,0,0,0,1,0,clock_num,0 ns);
                    command_seq(83):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(84):=(done   ,none     ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 8  =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "DDR READ, positive tests";
                    -- 3 Bytes address and EXTADD = '0'
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#24#,0,0,valid,0 ns);
                    ELSE
                        command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#20#,0,0,valid,0 ns);
                    END IF;
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(8) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Fast DDR Read Mode
                    command_seq(11) :=(fast_ddr_rd,read_ddr_fast,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(12) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13) :=(fast_ddr_rd,read_ddr_fast,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(14) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Dual I/O DDR Read Mode
                    command_seq(15):=(dual_high_ddr_rd,read_ddr_dual_hi,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(16):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(dual_high_ddr_rd,read_ddr_dual_hi,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(18):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Quad I/O DDR Read Mode
                    command_seq(19):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(21):=(w_scr  ,none     ,2,0,0,0,16#26#,0,0,valid,0 ns);
                    ELSE
                        command_seq(21):=(w_scr  ,none     ,2,0,0,0,16#22#,0,0,valid,0 ns);
                    END IF;
                    command_seq(22):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(25):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(quad_high_ddr_rd,read_ddr_quad_hi,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(29):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(quad_high_ddr_rd,read_ddr_quad_hi,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(31):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(done   ,none     ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "DDR READ, positive tests";
                    -- 3 Bytes address and EXTADD = '1'
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --QUAD := '0'
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#24#,0,0,valid,0 ns);
                    ELSE
                        command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#20#,0,0,valid,0 ns);
                    END IF;
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(8) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --EXTADD := '1'
                    command_seq(13):=(w_bank ,none     ,1,0,0,0,16#80#,0,0,valid,0 ns);
                    command_seq(14):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(wt     ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(rd_sr1 ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(rd_sr1 ,pgm_succ ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(bank_rd,read_bank,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Fast DDR Read Mode
                    command_seq(23) :=(fast_ddr_rd,read_ddr_fast,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(24) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25) :=(fast_ddr_rd,read_ddr_fast,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(26) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Dual I/O DDR Read Mode
                    command_seq(27):=(dual_high_ddr_rd,read_ddr_dual_hi,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(28):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29):=(dual_high_ddr_rd,read_ddr_dual_hi,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(30):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Quad I/O DDR Read Mode
                    command_seq(31):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(33):=(w_scr  ,none     ,2,0,0,0,16#26#,0,0,valid,0 ns);
                    ELSE
                        command_seq(33):=(w_scr  ,none     ,2,0,0,0,16#22#,0,0,valid,0 ns);
                    END IF;
                    command_seq(34):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(37):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40):=(quad_high_ddr_rd,read_ddr_quad_hi,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(41):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(42):=(quad_high_ddr_rd,read_ddr_quad_hi,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(43):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Setting up EXTADD bit to '0'
                    command_seq(44):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(45):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(46):=(w_bank ,none     ,1,0,0,0,16#00#,0,0,valid,0 ns);
                    command_seq(47):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(48):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(49):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(50):=(wt     ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(51):=(rd_sr1 ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(52):=(rd_sr1 ,pgm_succ ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(53):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(54):=(bank_rd,read_bank,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(55):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(56):=(done   ,none     ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 3  =>
                    REPORT "DDR READ, positive tests";
                    -- 4 Bytes address
                    -- Normal Read
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#24#,0,0,valid,0 ns);
                    ELSE
                        command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#20#,0,0,valid,0 ns);
                    END IF;
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(8) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Fast DDR Read Mode
                    command_seq(11) :=(fast_ddr_rd4,read_ddr_fast4,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(12) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13) :=(fast_ddr_rd4,read_ddr_fast4,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(14) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Dual I/O DDR Read Mode
                    command_seq(15):=(dual_high_ddr_rd4,read_ddr_dual_hi4,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(16):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(dual_high_ddr_rd4,read_ddr_dual_hi4,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(18):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Quad I/O DDR Read Mode
                    command_seq(19):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(21):=(w_scr  ,none     ,2,0,0,0,16#26#,0,0,valid,0 ns);
                    ELSE
                        command_seq(21):=(w_scr  ,none     ,2,0,0,0,16#22#,0,0,valid,0 ns);
                    END IF;
                    command_seq(22):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(25):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(quad_high_ddr_rd_4,read_ddr_quad_hi4,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(29):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(quad_high_ddr_rd_4,read_ddr_quad_hi4,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(31):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(done   ,none     ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 4  =>
                    REPORT "DDR READ, positive tests";
                    -- Continuous read
                    IF (Model(15) = '0' OR Model(15) = '2' OR Model(15) = '3' OR Model(15) = 'R' OR
                        Model(15) = 'A' OR Model(15) = 'B' OR Model(15) = 'C' OR Model(15) = 'D' OR
                        Model(15) = 'Y' OR Model(15) = 'Z' OR Model(15) = 'S' OR Model(15) = 'T' OR
                        Model(15) = 'K' OR Model(15) = 'L') THEN
                        command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                            command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#24#,0,0,valid,0 ns);
                        ELSE
                            command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#20#,0,0,valid,0 ns);
                        END IF;
                        command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(7) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(8) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(9) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(10):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- 3 Bytes address and EXTADD = '0'
                        -- fast ddr read - Initial access, mode bits are A5h
                        command_seq(11):=(fast_ddr_rd,read_ddr_fast,5,0,0,0,16#A5#,0,0,valid,0 ns);
                        command_seq(12):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Continuous fast ddr read - Subsequent access
                        command_seq(13):=(fast_ddr_rd,rd_cont_fddr,5,0,0,0,0,0,1,break,0 ns);
                        command_seq(14):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- fast ddr read - Initial access, mode bits are F0h
                        command_seq(15):=(fast_ddr_rd,read_ddr_fast,5,0,0,0,16#F0#,0,0,valid,0 ns);
                        command_seq(16):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Initiate MBR command to release from Fast DDR Read
                        command_seq(17):=(mbr   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(18):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- 4 Bytes address
                        -- fast ddr read - Initial access, mode bits are 5Ah
                        command_seq(19):=(fast_ddr_rd4,read_ddr_fast4,5,0,0,0,16#5A#,0,0,valid,0 ns);
                        command_seq(20):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Continuous fast ddr read - Subsequent access
                        command_seq(21):=(fast_ddr_rd4,rd_cont_fddr4,5,0,0,0,0,0,1,break,0 ns);
                        command_seq(22):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- 3 Bytes address and EXTADD = '0'
                        -- Dual I/O DDR Read Mode - Initial access, mode bits are A5h
                        command_seq(23):=(dual_high_ddr_rd,read_ddr_dual_hi,5,0,0,0,16#A5#,0,0,valid,0 ns);
                        command_seq(24):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Continuous Dual I/O DDR Read Mode - Subsequent access
                        command_seq(25):=(dual_high_ddr_rd,rd_cont_dddr,5,0,0,0,0,0,1,break,0 ns);
                        command_seq(26):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- 4 Bytes address
                        -- Dual I/O DDR Read Mode - Initial access, mode bits are A5h
                        command_seq(27):=(dual_high_ddr_rd4,read_ddr_dual_hi4,5,0,0,0,16#A5#,0,0,valid,0 ns);
                        command_seq(28):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Continuous Dual I/O DDR Read Mode - Subsequent access
                        command_seq(29):=(dual_high_ddr_rd4,rd_cont_dddr4,5,0,0,0,0,0,1,break,0 ns);
                        command_seq(30):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- 3 Bytes address and EXTADD = '0'
                        -- Quad I/O DDR Read Mode
                        command_seq(31):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(32):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                            command_seq(33):=(w_scr  ,none     ,2,0,0,0,16#26#,0,0,valid,0 ns);
                        ELSE
                            command_seq(33):=(w_scr  ,none     ,2,0,0,0,16#22#,0,0,valid,0 ns);
                        END IF;
                        command_seq(34):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(35):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(36):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(37):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(38):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(39):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- quad high performance read - Initial access, mode bits are 5Ah
                        command_seq(40):=(quad_high_ddr_rd,read_ddr_quad_hi,5,0,0,0,16#5A#,1,0,valid,0 ns);
                        command_seq(41):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Continuous quad high performance read - Subsequent access
                        command_seq(42):=(quad_high_ddr_rd,rd_cont_qddr,5,0,0,0,0,1,0,break,0 ns);
                        command_seq(43):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- 4 Bytes address
                    -- quad high performance read - Initial access, mode bits are 5Ah
                        command_seq(44):=(quad_high_ddr_rd_4,read_ddr_quad_hi4,5,0,0,0,16#5A#,1,0,valid,0 ns);
                        command_seq(45):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Continuous quad high performance read - Subsequent access
                        command_seq(46):=(quad_high_ddr_rd_4,rd_cont_qddr4,5,0,0,0,0,1,0,break,0 ns);
                        command_seq(47):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(48):=(done   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        REPORT("Continuous read mode exists only in EHPLC models");
                    END IF;

                    WHEN 5  =>
                    REPORT "DDR READ, positive tests";
                    -- 3 Bytes address and EXTADD = '0'
                    -- Read memory array for different values of Latency code
                    -- LC1 = '0' and LC0 = '1'
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#64#,0,0,valid,0 ns);
                    ELSE
                        command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#60#,0,0,valid,0 ns);
                    END IF;
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(8) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Fast DDR Read Mode
                    command_seq(11) :=(fast_ddr_rd,read_ddr_fast,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(12) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13) :=(fast_ddr_rd,read_ddr_fast,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(14) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Dual I/O DDR Read Mode
                    command_seq(15):=(dual_high_ddr_rd,read_ddr_dual_hi,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(16):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(dual_high_ddr_rd,read_ddr_dual_hi,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(18):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Quad I/O DDR Read Mode
                    command_seq(19):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(21):=(w_scr  ,none     ,2,0,0,0,16#66#,0,0,valid,0 ns);
                    ELSE
                        command_seq(21):=(w_scr  ,none     ,2,0,0,0,16#62#,0,0,valid,0 ns);
                    END IF;
                    command_seq(22):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(25):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(quad_high_ddr_rd,read_ddr_quad_hi,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(29):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(quad_high_ddr_rd,read_ddr_quad_hi,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(31):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- LC1 = '1' and LC0 = '0'
                    command_seq(32) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(34):=(w_scr  ,none     ,2,0,0,0,16#A4#,0,0,valid,0 ns);
                    ELSE
                        command_seq(34):=(w_scr  ,none     ,2,0,0,0,16#A0#,0,0,valid,0 ns);
                    END IF;
                    command_seq(35) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(38) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Fast DDR Read Mode
                    command_seq(41) :=(fast_ddr_rd,read_ddr_fast,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(42) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(43) :=(fast_ddr_rd,read_ddr_fast,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(44) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Dual I/O DDR Read Mode
                    command_seq(45):=(dual_high_ddr_rd,read_ddr_dual_hi,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(46):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(47):=(dual_high_ddr_rd,read_ddr_dual_hi,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(48):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Quad I/O DDR Read Mode
                    command_seq(49):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(50):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(51):=(w_scr  ,none     ,2,0,0,0,16#A6#,0,0,valid,0 ns);
                    ELSE
                        command_seq(51):=(w_scr  ,none     ,2,0,0,0,16#A2#,0,0,valid,0 ns);
                    END IF;
                    command_seq(52):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(53):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(54):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(55):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(56):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(57):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(58):=(quad_high_ddr_rd,read_ddr_quad_hi,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(59):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(60):=(quad_high_ddr_rd,read_ddr_quad_hi,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(61):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- LC1 = '1' and LC0 = '1'
                    command_seq(62) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(63) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(64):=(w_scr  ,none  ,2,0,0,0,16#E4#,0,0,valid,0 ns);
                    ELSE
                        command_seq(64):=(w_scr  ,none  ,2,0,0,0,16#E0#,0,0,valid,0 ns);
                    END IF;
                    command_seq(65) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(66) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(67) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(68) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(69) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(70) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Fast DDR Read Mode
                    command_seq(71) :=(fast_ddr_rd,read_ddr_fast,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(72) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(73) :=(fast_ddr_rd,read_ddr_fast,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(74) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Dual I/O DDR Read Mode
                    command_seq(75):=(dual_high_ddr_rd,read_ddr_dual_hi,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(76):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(77):=(dual_high_ddr_rd,read_ddr_dual_hi,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(78):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Quad I/O DDR Read Mode
                    command_seq(79):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(80):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(81):=(w_scr  ,none     ,2,0,0,0,16#E6#,0,0,valid,0 ns);
                    ELSE
                        command_seq(81):=(w_scr  ,none     ,2,0,0,0,16#E2#,0,0,valid,0 ns);
                    END IF;
                    command_seq(82):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(83):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(84):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(85):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(86):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(87):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(88):=(quad_high_ddr_rd,read_ddr_quad_hi,5,0,0,0,0,1,5,valid,0 ns);
                    command_seq(89):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(90):=(quad_high_ddr_rd,read_ddr_quad_hi,5,0,0,0,0,1,5,clock_num,0 ns);
                    command_seq(91):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(92):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(93):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(94):=(w_scr  ,none     ,2,0,0,0,16#24#,0,0,valid,0 ns);
                    ELSE
                        command_seq(94):=(w_scr  ,none     ,2,0,0,0,16#20#,0,0,valid,0 ns);
                    END IF;
                    command_seq(95):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(96):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(97):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(98):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(99):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(100):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(101):=(done   ,none     ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 9  =>
                REPORT "QUAD READ, negative tests";
                 --cmd,sts,byte_num,data4,data3,data2,data1,sect,addr,aux_t,time
                --disable Quad mode (Quad bit is not set)
                command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                    command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#24#,0,0,valid,0 ns);
                ELSE
                    command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#20#,0,0,valid,0 ns);
                END IF;
                command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                command_seq(7) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                command_seq(8) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                command_seq(9) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                command_seq(10):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                -- Quad Output Read Mode (3 Bytes address)
                command_seq(11):=(quad_rd,rd_HiZ   ,5,0,0,0,0,63,16#01#,valid,0 ns);
                command_seq(12):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                -- Quad Output Read Mode (4 Bytes address)
                command_seq(13):=(quad_rd_4,rd_HiZ ,5,0,0,0,0,63,16#01#,valid,0 ns);
                command_seq(14):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                -- Quad I/O High Performance Read Mode (3 Bytes address)
                command_seq(15):=(quad_high_rd,rd_HiZ   ,5,0,0,0,0,63,16#01#,valid,0 ns);
                command_seq(16):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                -- Quad I/O High Performance Read Mode (4 Bytes address)
                command_seq(17):=(quad_high_rd_4,rd_HiZ ,5,0,0,0,0,63,16#01#,valid,0 ns);
                command_seq(18):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                -- Quad I/O DDR Read Mode (3 Bytes address)
                command_seq(19):=(quad_high_ddr_rd,rd_HiZ,5,0,0,0,0,63,16#01#,valid,0 ns);
                command_seq(20):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                -- Quad I/O DDR Read Mode (4 Bytes address)
                command_seq(21):=(quad_high_ddr_rd_4,rd_HiZ,5,0,0,0,0,63,16#01#,valid,0 ns);
                command_seq(22):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                command_seq(23):=(done   ,none     ,0,0,0,0,0,0,0,valid,0 ns);

            WHEN 10  =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "READ Status Register1, positive tests";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(rd_sr1 ,read_sr1,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(rd_sr1 ,read_sr1,2,0,0,0,0,0,0,clock_num,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "READ Status Register2, positive tests";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,clock_num,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 3  =>
                    REPORT "READ Configuration Register, positive tests";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(rd_scr ,read_config,2,0,0,0,0,0,0,clock_num,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 4  =>
                    REPORT "READ Autoboot Register, positive tests";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(autoboot_rd,read_autoboot,3,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(autoboot_rd,read_autoboot,3,0,0,0,0,0,0,clock_num,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 5  =>
                    REPORT "READ Bank Address Register, positive tests";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(bank_rd,read_bank,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(bank_rd,read_bank,2,0,0,0,0,0,0,clock_num,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 6  =>
                    REPORT "READ ASP Register, positive tests";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(asp_reg_rd,read_asp,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(asp_reg_rd,read_asp,2,0,0,0,0,0,0,clock_num,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 7  =>
                    REPORT "READ Password Register, positive tests";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(pass_reg_rd,read_pass_reg,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(pass_reg_rd,read_pass_reg,2,0,0,0,0,0,0,clock_num,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 8  =>
                    REPORT "READ PPB Lock Register, positive tests";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,clock_num,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 9  =>
                    REPORT "READ Access Registers, positive tests";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(ppbacc_rd,read_ppbar,2,0,0,0,0,1,19,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(ppbacc_rd,read_ppbar,2,0,0,0,0,1,19,clock_num,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(dybacc_rd,read_dybar,2,0,0,0,0,1,19,valid,0 ns);
                    command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(dybacc_rd,read_dybar,2,0,0,0,0,1,19,clock_num,0 ns);
                    command_seq(9) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 11  =>
                REPORT "OTP READ, positive test";
                command_seq(1):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                command_seq(2):=(otp_read,read_otp ,3,0,0,0,0,0,16#020#,valid,0 ns);
                command_seq(3):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                command_seq(4):=(otp_read,read_otp,3,0,0,0,0,0,16#3FC#,valid,0 ns);
                command_seq(5):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                command_seq(6):=(otp_read,rd_U ,1,0,0,0,0,0,16#400#,valid,0 ns);
                command_seq(7):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                command_seq(8):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

            WHEN 12  =>
                CASE Testcase IS
                    -- Read ID Tests
                    WHEN 1  =>
                    REPORT "READ Jedec ID, positive test";
                    command_seq(1)  :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2)  :=(read_JID,rd_JID ,81,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3)  :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4)  :=(read_JID,rd_JID ,85,0,0,0,0,0,0,clock_num,0 ns);
                    command_seq(5)  :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6)  :=(done   ,none    ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "READ ID, positive test";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(read_ID,rd_ID ,5,0,0,0,0,0,16#AA2#,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(read_ID,rd_ID ,5,0,0,0,0,0,16#AA1#,valid,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(read_ID,rd_ID ,3,0,0,0,0,0,0,clock_num,0 ns);
                    command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 3  =>
                    REPORT "READ Electronic Signature, positive test";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(read_ES,rd_res,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' OR (Model(16) = '0' AND Sec_Arch = FALSE) THEN
                        command_seq(6):=(w_scr  ,none     ,2,0,0,0,16#24#,0,0,valid,0 ns);
                    ELSE
                        command_seq(6):=(w_scr  ,none     ,2,0,0,0,16#20#,0,0,valid,0 ns);
                    END IF;
                    command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(10):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(idle   ,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 13 =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "Hold condition, positive tests, HOLDNeg asserted during opcode cycle";
                     --cmd, sts, byte_num, data, sect, addr, aux_t, time
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,hold_op,10 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(rd_sr1 ,read_sr1,1,0,0,0,0,0,0,hold_op,0 ns);
                    command_seq(5) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(rd     ,read  ,2,0,0,0,0,0,5,hold_op,10 ns);
                    command_seq(8) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "Hold condition, positive tests, HOLDNeg asserted during address bytes cycle";
                     --cmd, sts, byte_num, data, sect, addr, aux_t, time
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(pg_prog,none  ,1,0,0,0,16#01#,0,16#3F#,hold_add,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(9) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(rd     ,read  ,1,0,0,0,0,0,16#3F#,hold_add,0 ns);
                    command_seq(12):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 3  =>
                    REPORT "Hold condition, positive tests, HOLDNeg asserted during dummy bytes cycle";
                    --cmd, sts, byte_num, data, sect, addr, aux_t, time
                    command_seq(1):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2):=(fast_rd,read_fast,1,0,0,0,0,0,0,hold_dum,0 ns);
                    command_seq(3):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 4  =>
                    REPORT "Hold condition, positive tests, HOLDNeg asserted during data bytes cycle";
                     --cmd, sts, byte_num, data, sect, addr, aux_t, time
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(pg_prog,none  ,1,0,0,0,16#AA#,0,16#40#,hold_dat,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(9) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(rd     ,read  ,1,0,0,0,0,0,16#AA#,hold_dat,0 ns);
                    command_seq(12):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS  =>  null;
                END CASE;

            WHEN 14  =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "OTP program positive test";
                    --Single Byte Programming
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(otp_prog,none ,1,0,0,0,16#AA#,0,16#300#,valid,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(9) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(otp_read ,read_otp ,1,0,0,0,0,0,16#300#,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --  programming one byte, only in diferent location
                    command_seq(14) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16) :=(otp_prog,none ,1,0,0,0,16#88#,0,16#2E1#,valid,0 ns);
                    command_seq(17) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(21) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(otp_read ,read_otp ,1,0,0,0,0,0,16#2E1#,valid,0 ns);
                    command_seq(25):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    -- locking programed otp region
                    command_seq(26) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28) :=(otp_prog,none ,1,0,0,0,16#CC#,0,16#1C1#,valid,0 ns);
                    command_seq(29) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32) :=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(35) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38):=(otp_read ,read_otp ,1,0,0,0,0,0,16#1C1#,valid,0 ns);
                    command_seq(39):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(42) :=(otp_prog,none ,1,0,0,0,16#9F#,0,16#11#,valid,0 ns);
                    command_seq(43) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(44) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(45) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(46) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(47) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(48):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(49):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(50):=(otp_read ,read_otp ,1,0,0,0,0,0,16#1C1#,valid,0 ns);
                    command_seq(51):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(52):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "OTP program positive test";
                    --OTP Page Programming
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(otp_prog,none ,200,0,0,0,16#01#,0,16#200#,valid,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Status Register1 during OTP Page Program operation
                    command_seq(6) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Configuration Register during OTP Page Program operation
                    command_seq(8) :=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Bank Register Read command is not allowed during OTP Program
                    command_seq(10):=(bank_rd,rd_HiZ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(13):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(otp_read ,read_otp ,5,0,0,0,0,0,16#2A0#,valid,0 ns);
                    command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS  =>  null;
                END CASE;

            WHEN 15  =>-- programming locked region
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "OTP program negative test";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(otp_prog,err  ,1,0,0,0,16#99#,0,16#0A1#,valid,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(clr_sr ,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>--programming over address limit in OTP
                    REPORT "OTP program negative test";
                    --programmed bytes will cross over 1024 byte limit
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(otp_prog,none,5,0,0,0,16#DD#,0,16#3FD#,valid,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --adrress is out of range
                    command_seq(10) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12) :=(otp_prog,err,1,0,0,0,16#DD#,0,16#400#,valid,0 ns);
                    command_seq(13) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16) :=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20) :=(otp_prog,err,1,0,0,0,16#DD#,0,16#5#,valid,0 ns);
                    command_seq(21) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24) :=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26) :=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS  =>  null;
                END CASE;

            WHEN 16 => -- page program positive test
                   REPORT "Page program positive test";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(pg_prog,none  ,1,0,0,0,16#BF#,7,16#A#,valid,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(9) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(rd     ,read  ,1,0,0,0,0,7,16#A#,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(pg_prog,none  ,3,0,0,0,16#AB#,4,16#11#,valid,0 ns);
                    command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(21):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(rd     ,read  ,3,0,0,0,0,4,16#11#,valid,0 ns);
                    command_seq(25):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(pg_prog,none  ,PageSize+5,0,0,0,16#AB#,14,16#CC#,valid,0 ns);
                    command_seq(29):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,clock_num,0 ns);
                    command_seq(35):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36):=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Bank Register Read command is not allowed during Page Program
                    command_seq(38):=(bank_rd,rd_HiZ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(41):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(42):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(43):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(44):=(rd     ,read  ,6,0,0,0,0,14,16#CC#,valid,0 ns);
                    command_seq(45):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(46):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

           WHEN 17  =>
               REPORT "Page programming (4 bytes address)";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(pg_prog4,none  ,1,0,0,0,16#77#,16,16#A#,valid,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(9) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(rd_4     ,read_4,1,0,0,0,0,16,16#A#,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(pg_prog4,none ,3,0,0,0,16#AB#,17,16#11#,valid,0 ns);
                    command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(21):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(rd_4     ,read_4,3,0,0,0,0,17,16#11#,valid,0 ns);
                    command_seq(25):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(pg_prog4,none ,PageSize+5,0,0,0,16#AB#,18,16#CC#,valid,0 ns);
                    command_seq(29):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,clock_num,0 ns);
                    command_seq(35):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(37):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40):=(rd     ,read  ,6,0,0,0,0,18,16#CC#,valid,0 ns);
                    command_seq(41):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(42):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

            WHEN 18  =>
                REPORT "Page programming: negative test";
                    -- programming locked sector
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_sr   ,none     ,1,0,0,0,16#0C#,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(8) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(w_sr   ,none     ,1,0,0,0,16#1C#,0,0,valid,0 ns);
                    command_seq(14):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(18):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(pg_prog4,none    ,1,0,0,0,16#BF#,126,16#A#,valid,0 ns);
                    command_seq(24):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(rd_sr1 ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(rd     ,read     ,1,0,0,0,0,59,16#A#,valid,0 ns);
                    command_seq(29):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(clr_sr ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(done   ,none     ,0,0,0,0,0,0,0,valid,0 ns);

            WHEN 19  =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "QUAD PROGRAMMING: positive test";
                    command_seq(1) :=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_scr   ,none      ,2,0,0,0,16#26#,0,0,valid,0 ns);
                    command_seq(5) :=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1  ,rd_wip_1  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(wt      ,none      ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(8) :=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(w_enable,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(quad_pg_prog,none  ,3,0,0,0,16#11#,0,16#0#,valid,0 ns);
                    command_seq(12):=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(rd_sr1  ,rd_wip_1  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(rd_sr2  ,read_sr2  ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(rd_sr2  ,read_sr2  ,2,0,0,0,0,0,0,clock_num,0 ns);
                    command_seq(18):=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(wt      ,none      ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(20):=(rd_sr1  ,rd_wip_0  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(rd_sr1  ,pgm_succ  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(quad_rd ,rd_quad   ,3,0,0,0,0,0,16#0#,valid,0 ns);
                    command_seq(24):=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    --2
                    command_seq(25) :=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27) :=(quad_pg_prog,none ,10,0,0,0,16#55#,0,16#4#,valid,0 ns);
                    command_seq(28):=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29):=(rd_sr1  ,rd_wip_1  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31) :=(wt      ,none     ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(32) :=(rd_sr1  ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33) :=(rd_sr1  ,pgm_succ ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35) :=(quad_rd ,rd_quad  ,10,0,0,0,0,0,16#4#,valid,0 ns);
                    command_seq(36) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --3
                    command_seq(37) :=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39) :=(quad_pg_prog,none ,10,0,0,0,16#AA#,0,16#C#,valid,0 ns);
                    command_seq(40):=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41):=(rd_sr1  ,rd_wip_1  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(42) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(43) :=(wt      ,none     ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(44) :=(rd_sr1  ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(45) :=(rd_sr1  ,pgm_succ ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(46) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(47) :=(quad_rd ,rd_quad  ,10,0,0,0,0,0,16#C#,valid,0 ns);
                    command_seq(48) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --4
                    command_seq(49) :=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(50) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(51) :=(quad_pg_prog,none ,10,0,0,0,16#BB#,0,16#48D0#,valid,0 ns);
                    command_seq(52):=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(53):=(rd_sr1  ,rd_wip_1  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(54) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(55) :=(wt      ,none     ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(56) :=(rd_sr1  ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(57) :=(rd_sr1  ,pgm_succ ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(58) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(59) :=(quad_rd ,rd_quad  ,10,0,0,0,0,0,16#48D0#,valid,0 ns);
                    command_seq(60) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --5
                    command_seq(61) :=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(62) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(63) :=(quad_pg_prog,none ,10,0,0,0,16#CC#,0,16#159E0#,valid,0 ns);
                    command_seq(64):=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(65):=(rd_sr1  ,rd_wip_1  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(66) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(67) :=(wt      ,none     ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(68) :=(rd_sr1  ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(69) :=(rd_sr1  ,pgm_succ ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(70) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(71) :=(quad_rd ,rd_quad  ,10,0,0,0,0,0,16#159E0#,valid,0 ns);
                    command_seq(72) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --6
                    command_seq(73) :=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(74) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(75) :=(quad_pg_prog,none ,10,0,0,0,16#DD#,0,16#1E268#,valid,0 ns);
                    command_seq(76):=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(77):=(rd_sr1  ,rd_wip_1  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(78) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(79) :=(wt      ,none     ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(80) :=(rd_sr1  ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(81) :=(rd_sr1  ,pgm_succ ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(82) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(83) :=(quad_rd ,rd_quad  ,10,0,0,0,0,0,16#1E268#,valid,0 ns);
                    command_seq(84) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
--                     command_seq(85):=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(85):=(ecc_rd  ,rd_ecc  ,1,0,0,0,0,0,16#12340#,valid,0 ns);
                    command_seq(86):=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(87):=(done    ,none      ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "QUAD PROGRAMMING (4bytes address): positive test";
                    command_seq(1)  :=(idle     ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2)  :=(w_enable ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3)  :=(idle     ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4)  :=(w_scr    ,none     ,2,0,0,0,16#26#,0,0,valid,0 ns);
                    command_seq(5)  :=(idle     ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6)  :=(rd_sr1   ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7)  :=(wt       ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(8)  :=(idle     ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9)  :=(w_enable ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10) :=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11) :=(quad_pg_prog4,none ,5,0,0,0,16#10#,20,16#200#,valid,0 ns);
                    command_seq(12) :=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13) :=(rd_sr1  ,rd_wip_1  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14) :=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15) :=(rd_sr2  ,read_sr2  ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16) :=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17) :=(rd_sr2  ,read_sr2  ,2,0,0,0,0,0,0,clock_num,0 ns);
                    command_seq(18) :=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19) :=(wt      ,none      ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(20) :=(rd_sr1  ,rd_wip_0  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21) :=(rd_sr1  ,pgm_succ  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22) :=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23) :=(quad_rd,rd_quad    ,5,0,0,0,0,20,16#200#,valid,0 ns);
                    command_seq(24) :=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25) :=(quad_rd_4,rd_quad_4,50,0,0,0,16#10#,64,16#200#,valid,0 ns);
                    command_seq(26) :=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27) :=(w_enable,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28) :=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29) :=(quad_pg_prog4,none ,50,0,0,0,16#10#,64,16#200#,valid,0 ns);
                    command_seq(30) :=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31) :=(rd_sr1  ,rd_wip_1  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32) :=(wt      ,none      ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(33) :=(rd_sr1  ,rd_wip_0  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34) :=(rd_sr1  ,pgm_succ  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35) :=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36) :=(quad_rd_4,rd_quad_4,50,0,0,0,16#56#,64,16#200#,valid,0 ns);
                    command_seq(37) :=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40) :=(done    ,none      ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 3  =>
                    REPORT "QUAD PROGRAMMING: positive test";
                    --programming more bytes then Page size is
                    command_seq(1)  :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2)  :=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3)  :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4)  :=(w_scr   ,none     ,2,0,0,0,16#26#,0,0,valid,0 ns);
                    command_seq(5)  :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6)  :=(rd_sr1  ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7)  :=(rd_sr2  ,read_sr2 ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8)  :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9)  :=(wt      ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(10) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11) :=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13) :=(quad_pg_prog,none,PageSize+5,0,0,0,16#10#,23,16#01#,valid,0 ns);
                    command_seq(14) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15) :=(rd_sr1  ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17) :=(rd_sr2  ,read_sr2 ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19) :=(rd_sr2  ,read_sr2 ,2,0,0,0,0,0,0,clock_num,0 ns);
                    command_seq(20) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21) :=(wt      ,none     ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(22) :=(rd_sr1  ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23) :=(rd_sr1  ,pgm_succ ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25) :=(quad_rd ,rd_quad  ,4,0,0,0,0,23,16#01#,valid,0 ns);
                    command_seq(26) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27) :=(done    ,none     ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

           WHEN 20  =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "QUAD PROGRAMMING: negative test";
                    --QPP requires programming to be done one full page at a time.
                    --While less than a full page of data may be loaded for programming,
                    --the entire page is considered programmed,any locations not filled
                    --with data will be left as ones,the same page must not be programmed
                    --more than once.
                    command_seq(1)  :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2)  :=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3)  :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4)  :=(w_scr   ,none     ,2,0,0,0,16#26#,0,0,valid,0 ns);
                    command_seq(5)  :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6)  :=(rd_sr1  ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7)  :=(rd_sr2  ,read_sr2 ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8)  :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9)  :=(wt      ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(10) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11) :=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13) :=(quad_pg_prog,none ,10,0,0,0,16#10#,23,16#200#,valid,0 ns);
                    command_seq(14) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15) :=(wt      ,none     ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(16) :=(rd_sr1  ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17) :=(rd_sr1  ,pgm_succ ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19) :=(quad_rd ,rd_quad  ,10,0,0,0,0,23,16#200#,valid,0 ns);
                    command_seq(20) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Another QPP operation is issued on the same page
                    command_seq(21) :=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23) :=(quad_pg_prog,none ,10,0,0,0,16#10#,23,16#220#,valid,0 ns);
                    REPORT "****************************************************" & lf &
                           "         QPP command on programmed should generate warning from model" & lf &
                           "         Testseries  : 19" & lf &
                           "         Testcase    : 01" & lf &
                           "         command_cnt : 24" & lf &
                           "         ****************************************************";
                    command_seq(24) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Verify that QPP operation is not rejected; warning is generated
                    -- (Quad Page Program forbids writing the same page more than once, but
                    -- does not specify that error should be generated)
                    command_seq(25) :=(rd_sr1  ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26) :=(wt      ,none     ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(27) :=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29) :=(clr_sr  ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Verify that memory locations have new values (match with real memory behavior)
                    -- (Quad Page Program forbids writing the same page more than once, but
                    -- does not specify that error should be generated)
                    command_seq(31) :=(quad_rd ,rd_quad  ,10,0,0,0,0,23,16#220#,valid,0 ns);
                    command_seq(32) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);

                    -- erase the program page sector
                    command_seq(33):=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35):=(sector_erase,none ,0,0,0,0,0,23,0,valid,0 ns);
                    command_seq(36):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37):=(wt      ,none     ,0,0,0,0,0,0,0,valid,tSE);
                    command_seq(38):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39):=(quad_rd ,rd_quad   ,4,0,0,0,0,23,16#220#,valid,0 ns);
                    --Another QPP operation is issued on the same page
                    command_seq(40) :=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(42) :=(quad_pg_prog,none ,5,0,0,0,16#20#,23,16#220#,valid,0 ns);
                    command_seq(43) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(44) :=(wt      ,none     ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(45) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Verify programmed data
                    command_seq(46) :=(quad_rd ,rd_quad  ,5,0,0,0,0,23,16#220#,valid,0 ns);
                    command_seq(47) :=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);

                    command_seq(48) :=(done    ,none     ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

           WHEN 21  =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "Program suspend, positive test";
                    command_seq(1) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_scr  ,none    ,2,0,0,0,16#26#,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(wt     ,none    ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(8) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(pg_prog,none    ,50,0,0,0,16#99#,60,0,valid,0 ns);
                    command_seq(14):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    --When the Program Suspend command is written during a
                    --program operation, the device requires a maximum
                    --of tPGSUSP to suspend the program operation.
                    command_seq(17):=(prg_susp,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tPSL);
                    command_seq(20):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(rd_sr2 ,rd_ps_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Array during Program Suspend -QUAD READ
                    IF Model(16) = '1' THEN
                    -- Reading from the top of memory array (verify that when the
                    -- highest address is reached, the address counter will wrap
                    -- around and roll back to 000000h, allowing the read sequence
                    -- to be continued indefinitely.
                        command_seq(23):=(quad_rd_4,rd_quad_4 ,2,0,0,0,0,127,16#3FFFF#,valid,0 ns);
                        command_seq(24):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSIF Model(16) = '0' AND Sec_Arch = FALSE THEN
                        command_seq(23):=(quad_rd_4,rd_quad_4 ,2,0,0,0,0,541,16#FFF#,valid,0 ns);
                        command_seq(24):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(23):=(quad_rd_4,rd_quad_4 ,2,0,0,0,0,541,16#FFFF#,valid,0 ns);
                        command_seq(24):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    --Read Array from Program Suspended sector
                    command_seq(25):=(quad_rd,rd_U    ,2,0,0,0,0,60,5,valid,0 ns);
                    command_seq(26):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(wt     ,none    ,0,0,0,0,0,0,0,valid,10 ns);
                    --Read Array during Program Suspend -QUAD DDR READ
                    IF Model(16) = '1' THEN
                    -- Reading from the top of memory array (verify that when the
                    -- highest address is reached, the address counter will wrap
                    -- around and roll back to 000000h, allowing the read sequence
                    -- to be continued indefinitely.
                        command_seq(28):=(quad_high_ddr_rd_4,read_ddr_quad_hi4,2,0,0,0,0,127,16#3FFFF#,valid,0 ns);
                        command_seq(29):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSIF Model(16) = '0' AND Sec_Arch = FALSE THEN
                        command_seq(28):=(quad_high_ddr_rd_4,read_ddr_quad_hi4,2,0,0,0,0,541,16#FFF#,valid,0 ns);
                        command_seq(29):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(28):=(quad_high_ddr_rd_4,read_ddr_quad_hi4,2,0,0,0,0,541,16#FFFF#,valid,0 ns);
                        command_seq(29):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    --Read Array from Program Suspended sector
                    command_seq(30):=(quad_high_ddr_rd,rd_U,2,0,0,0,0,60,5,valid,0 ns);
                    command_seq(31):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(wt     ,none    ,0,0,0,0,0,0,0,valid,10 ns);
                    -- Read Configuration Register in Program Suspend
                    command_seq(33):=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --ASP Register Read command is not allowed during Program Suspend
                    command_seq(35):=(asp_reg_rd,rd_HiZ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --The system must write the Program Resume command
                    --to exit the program suspend mode and continue the
                    --program operation.
                    command_seq(37):=(prg_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    --Program Resume to next Program Suspend
                    --Typical period of 100 us is needed for Program to progress
                    --to completion. If PGSP command is issued during tPRS time
                    --warning is generated
                    command_seq(40):=(prg_susp,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(42):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPSL);
                    --Verify that PRSP command is accepted
                    command_seq(43):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(44):=(rd_sr2 ,rd_ps_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(45):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --The system must write the Program Resume command
                    --to exit the program suspend mode and continue the
                    --program operation.
                    command_seq(46):=(prg_resume,none ,0,0,0,0,0,0,0,violate,0 ns);
                    command_seq(47):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(48):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(49):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(50):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(51):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(52):=(rd     ,read    ,3,0,0,0,0,60,0,valid,0 ns);
                    command_seq(53):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(54):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(55):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(56):=(w_scr  ,none    ,2,0,0,0,16#24#,0,0,valid,0 ns);
                    command_seq(57):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(58):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(59):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(60):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(61):=(done   ,none    ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "Program suspend, positive test";
                    command_seq(1)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2)  :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4)  :=(pg_prog,none  ,50,0,0,0,16#99#,50,0,valid,0 ns);
                    command_seq(5)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6)  :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --When the Program Suspend command is written during a
                    --program operation, the device requires a maximum
                    --of tPGSUSP to suspend the program operation.
                    command_seq(8)  :=(prg_susp,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPSL);
                    command_seq(11) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12) :=(rd_sr2 ,rd_ps_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Array during Program Suspend - NORMAL READ
                    IF Model(16) = '1' THEN
                    -- Reading from the top of memory array (verify that when the
                    -- highest address is reached, the address counter will wrap
                    -- around and roll back to 000000h, allowing the read sequence
                    -- to be continued indefinitely.
                        command_seq(14) :=(rd_4     ,read_4  ,2,0,0,0,0,127,16#3FFFF#,valid,0 ns);
                        command_seq(15) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSIF Model(16) = '0' AND Sec_Arch = FALSE THEN
                        command_seq(14) :=(rd_4     ,read_4  ,2,0,0,0,0,541,16#FFF#,valid,0 ns);
                        command_seq(15) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(14) :=(rd_4     ,read_4  ,2,0,0,0,0,541,16#FFFF#,valid,0 ns);
                        command_seq(15) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    --Read Array from Program Suspended page
                    command_seq(16) :=(rd     ,rd_U  ,2,0,0,0,0,50,5,valid,0 ns);
                    command_seq(17) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,10 ns);
                    --Read Array during Program Suspend -FAST READ
                    IF Model(16) = '1' THEN
                    -- Reading from the top of memory array (verify that when the
                    -- highest address is reached, the address counter will wrap
                    -- around and roll back to 000000h, allowing the read sequence
                    -- to be continued indefinitely.
                        command_seq(19) :=(fast_rd4,read_fast_4,2,0,0,0,0,127,16#3FFFF#,valid,0 ns);
                        command_seq(20) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSIF Model(16) = '0' AND Sec_Arch = FALSE THEN
                        command_seq(19) :=(fast_rd4,read_fast_4,2,0,0,0,0,541,16#FFF#,valid,0 ns);
                        command_seq(20) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(19) :=(fast_rd4,read_fast_4,2,0,0,0,0,541,16#FFFF#,valid,0 ns);
                        command_seq(20) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    --Read Array from Program Suspended page
                    command_seq(21) :=(fast_rd,rd_U  ,2,0,0,0,0,50,5,valid,0 ns);
                    command_seq(22) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,10 ns);
                    --Read Array during Program Suspend -FAST DDR READ
                    IF Model(16) = '1' THEN
                    -- Reading from the top of memory array (verify that when the
                    -- highest address is reached, the address counter will wrap
                    -- around and roll back to 000000h, allowing the read sequence
                    -- to be continued indefinitely.
                        command_seq(24) :=(fast_ddr_rd4,read_ddr_fast4,2,0,0,0,0,127,16#3FFFF#, valid,0 ns);
                        command_seq(25) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSIF Model(16) = '0' AND Sec_Arch = FALSE THEN
                        command_seq(24) :=(fast_ddr_rd4,read_ddr_fast4,2,0,0,0,0,541,16#FFF#, valid,0 ns);
                        command_seq(25) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(24) :=(fast_ddr_rd4,read_ddr_fast4,2,0,0,0,0,541,16#FFFF#, valid,0 ns);
                        command_seq(25) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    --Read Array from Program Suspended page
                    command_seq(26) :=(fast_ddr_rd,rd_U,2,0,0,0,0,50,5,valid,0 ns);
                    command_seq(27) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28) :=(wt     ,none ,0,0,0,0,0,0,0,valid,10 ns);
                    --Read Array during Program Suspend -DUAL READ
                    IF Model(16) = '1' THEN
                    -- Reading from the top of memory array (verify that when the
                    -- highest address is reached, the address counter will wrap
                    -- around and roll back to 000000h, allowing the read sequence
                    -- to be continued indefinitely.
                        command_seq(29) :=(dual_rd_4,read_dual_4,2,0,0,0,0,127,16#3FFFF#,valid,0 ns);
                        command_seq(30) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSIF Model(16) = '0' AND Sec_Arch = FALSE THEN
                        command_seq(29) :=(dual_rd_4,read_dual_4,2,0,0,0,0,541,16#FFF#,valid,0 ns);
                        command_seq(30) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(29) :=(dual_rd_4,read_dual_4,2,0,0,0,0,541,16#FFFF#,valid,0 ns);
                        command_seq(30) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    --Read Array from Program Suspended page
                    command_seq(31) :=(dual_rd,rd_U  ,2,0,0,0,0,50,5,valid,0 ns);
                    command_seq(32) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,10 ns);
                    --Read Array during Program Suspend -DUAL DDR READ
                    IF Model(16) = '1' THEN
                    -- Reading from the top of memory array (verify that when the
                    -- highest address is reached, the address counter will wrap
                    -- around and roll back to 000000h, allowing the read sequence
                    -- to be continued indefinitely.
                        command_seq(34) :=(dual_high_ddr_rd4,read_ddr_dual_hi4, 2,0,0,0,0,127,16#3FFFF#,valid,0 ns);
                        command_seq(35) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSIF Model(16) = '0' AND Sec_Arch = FALSE THEN
                        command_seq(34) :=(dual_high_ddr_rd4,read_ddr_dual_hi4, 2,0,0,0,0,541,16#FFF#,valid,0 ns);
                        command_seq(35) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(34) :=(dual_high_ddr_rd4,read_ddr_dual_hi4, 2,0,0,0,0,541,16#FFFF#,valid,0 ns);
                        command_seq(35) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    --Read Array from Program Suspended page
                    command_seq(36) :=(dual_high_ddr_rd,rd_U,2,0,0,0,0,50,5,valid,0 ns);
                    command_seq(37) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38) :=(wt     ,none ,0,0,0,0,0,0,0,valid,10 ns);
                    IF (Model(15) = '0' OR Model(15) = '2' OR Model(15) = '3' OR Model(15) = 'R' OR
                        Model(15) = 'A' OR Model(15) = 'B' OR Model(15) = 'C' OR Model(15) = 'D' OR
                        Model(15) = 'Y' OR Model(15) = 'Z' OR Model(15) = 'S' OR Model(15) = 'T' OR
                        Model(15) = 'K' OR Model(15) = 'L') THEN
                        --Continuous read and MBR command
                        --fast ddr read - Initial access, mode bits are A5h
                        command_seq(39):=(fast_ddr_rd,read_ddr_fast,5,0,0,0,16#A5#,0,0,valid,0 ns);
                        command_seq(40):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Continuous fast ddr read - Subsequent access
                        command_seq(41):=(fast_ddr_rd,rd_cont_fddr,5,0,0,0,0,0,1,break,0 ns);
                        command_seq(42):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- fast ddr read - Initial access, mode bits are F0h
                        command_seq(43):=(fast_ddr_rd,read_ddr_fast,5,0,0,0,16#F0#,0,0,valid,0 ns);
                        command_seq(44):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Initiate MBR command to release from Fast DDR Read
                        command_seq(45):=(mbr   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(46):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Bank Register write
                        command_seq(47):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(48):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(49):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(50):=(w_bank ,none     ,1,0,0,0,16#80#,0,0,valid,0 ns);
                        command_seq(51):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(52):=(rd_sr1 ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(53):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(54):=(wt     ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(55):=(rd_sr1 ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(56):=(rd_sr1 ,pgm_succ ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(57):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Bank Register Read
                        command_seq(58):=(bank_rd,read_bank,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(59):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(60):=(w_bank ,none     ,1,0,0,0,16#01#,0,0,valid,0 ns);
                        command_seq(61):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(62):=(wt     ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(63):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Bank Register Access Command followed by WRR
                        command_seq(64):=(bank_acc,none    ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(65):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --For S25FL256S BA25 is Reserved bits
                        --WRR command is issued and warning for BA25 is generated
                        command_seq(66):=(w_sr  ,none    ,1,0,0,0,16#02#,0,0,valid,0 ns);
                        command_seq(67):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        --Verify that BA24 is reseted and BA25 still has previous value
                        command_seq(68):=(bank_rd,read_bank,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(69):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Bank Register Access Command followed by command other than WRR
                        command_seq(70):=(bank_acc,none    ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(71):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(72):=(w_disable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(73):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --The system must write the Program Resume command
                        --to exit the program suspend mode and continue the
                        --program operation.
                        command_seq(74) :=(prg_resume,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(75) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(76) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(77) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(78) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(79) :=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(80) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(81) :=(rd     ,read  ,3,0,0,0,0,50,0,valid,0 ns);
                        command_seq(82) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(83) :=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        --Bank Register write
                        command_seq(39):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(40):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(41):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(42):=(w_bank ,none     ,1,0,0,0,16#80#,0,0,valid,0 ns);
                        command_seq(43):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(44):=(rd_sr1 ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(45):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(46):=(wt     ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(47):=(rd_sr1 ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(48):=(rd_sr1 ,pgm_succ ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(49):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Bank Register Read
                        command_seq(50):=(bank_rd,read_bank,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(51):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(52):=(w_bank ,none     ,1,0,0,0,16#01#,0,0,valid,0 ns);
                        command_seq(53):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(54):=(wt     ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(55):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Bank Register Access Command followed by WRR
                        command_seq(56):=(bank_acc,none    ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(57):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --For S25FL256S BA25 is Reserved bits
                        --WRR command is issued and warning for BA25 is generated
                        command_seq(58):=(w_sr  ,none    ,1,0,0,0,16#02#,0,0,valid,0 ns);
                        command_seq(59):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        --Verify that BA24 is reseted and BA25 still has previous value
                        command_seq(60):=(bank_rd,read_bank,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(61):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Bank Register Access Command followed by command other than WRR
                        command_seq(62):=(bank_acc,none    ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(63):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(64):=(w_disable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(65):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --The system must write the Program Resume command
                        --to exit the program suspend mode and continue the
                        --program operation.
                        command_seq(66) :=(prg_resume,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(67) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(68) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(69) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(70) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(71) :=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(72) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(73) :=(rd     ,read  ,3,0,0,0,0,50,0,valid,0 ns);
                        command_seq(74) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(75) :=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;

                    WHEN OTHERS => NULL;
                END CASE;

           WHEN 22  =>
                REPORT "Program Autoboot Register, positive test";
                    command_seq(1) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_autoboot,none ,1,0,0,16#FD#,0,0,0,hold_dat,0 ns);
                    command_seq(5) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Bank Register Read command is not allowed during Program Autoboot Register
                    command_seq(9) :=(bank_rd,rd_HiZ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(wt     ,none    ,0,0,0,0,0,0,0,valid,10 ns);
                    command_seq(12):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(rd_sr2 ,read_sr2,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(16):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(autoboot_rd,read_autoboot,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

           WHEN 23  =>
                REPORT "Program Password Register, positive test";
                    command_seq(1) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_password,none ,1,16#99#,0,16#99#,16#3C#,0,0,hold_dat,0 ns);
                    command_seq(5) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Status Register 2
                    command_seq(8) :=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Configuration Register
                    command_seq(10):=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Bank Register Read command is not allowed during Program Password Register
                    command_seq(12):=(bank_rd,rd_HiZ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(15):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(pass_reg_rd,read_pass_reg,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

           WHEN 24  =>
                REPORT "Program Bank Register, positive test";
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_bank ,none     ,1,0,0,0,3,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_sr1 ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(rd_sr1 ,pgm_succ ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(bank_rd,read_bank,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(w_bank ,none     ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Status Register 1
                    command_seq(17):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Status Register 2
                    command_seq(19):=(rd_sr2 ,read_sr2 ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Configuration Register
                    command_seq(21):=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(bank_rd,read_bank,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- BRAC + WRR commands
                    command_seq(26):=(bank_acc,none    ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --For S25FL256S BA25 is Reserved bits
                    --WRR command is issued and warning for BA25 is generated
                    command_seq(28):=(w_scr  ,none     ,1,0,0,0,16#02#,0,0,valid,0 ns);
                    command_seq(29):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    --Bank Register Access Command followed by command other than WRR
                    command_seq(30):=(bank_acc,none    ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(w_disable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Any command other than WRR following a BRAC command will close
                    --the access to BAR and return to the normal interpretation of a
                    --WRR command as a write to Status Register-1 and the Configuration Register.
                    command_seq(34):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36):=(w_scr  ,none     ,2,0,0,0,16#26#,0,0,valid,0 ns);
                    command_seq(37):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(40):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(42):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(43):=(w_scr  ,none     ,2,0,0,0,16#24#,0,0,valid,0 ns);
                    command_seq(44):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(45):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(46):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(47):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(48):=(done   ,none     ,0,0,0,0,0,0,0,valid,0 ns);

           WHEN 25  =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "Write PPB Lock Register, positive test";
                    --PPB bits can't be changed if PPB LOCK = '0';
                    command_seq(1) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_ppb  ,none    ,1,0,0,0,0,15,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Status Register 2
                    command_seq(8) :=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Configuration Register
                    command_seq(10) :=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Bank Register Read command is not allowed during Write PPB Lock Register
                    command_seq(12):=(bank_rd,rd_HiZ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(15):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(ppbacc_rd,read_ppbar,2,0,0,0,0,15,19,valid,0 ns);
                    command_seq(19):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

           WHEN 26  =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "PPB Program, negative test";
                    --PPB bits can't be changed if PPB LOCK = '0';
                    command_seq(1) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_ppb  ,none    ,1,0,0,0,0,15,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(11):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(ppbacc_rd,read_ppbar,2,0,0,0,0,15,19,valid,0 ns);
                    command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "PPB Program, positive test";
                    --There is no command to set PPB LOCK bit, therefore the
                    --PPB Lock bit will remain at “0” until hardware reset.
                    command_seq(1) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    -- reset device
                    command_seq(2) :=(h_reset,none   ,0,0,0,0,0,0,0,valid,250 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(wt     ,none      ,0,0,0,0,0,0,0,valid,tRPH);
                    -- confirm PPB Lock bit is set
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    -- PPB Program command is issued
                    command_seq(8) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(w_ppb  ,none    ,1,0,0,0,0,15,0,valid,0 ns);
                    command_seq(11):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(15):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(ppbacc_rd,read_ppbar,2,0,0,0,0,15,19,valid,0 ns);
                    command_seq(19):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

           WHEN 27  =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "PPB ERASE, negative test";
                    --PPB bits can't be changed if PPB LOCK = '0';
                    command_seq(1) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_ppbl_reg,none ,1,0,0,0,16#F0#,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(bank_rd,rd_HiZ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(15):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(ppb_ers,none    ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPPBE);
                    command_seq(29):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(rd_sr1  ,erase_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(ppbacc_rd,read_ppbar,2,0,0,0,0,15,0,valid,0 ns);
                    command_seq(33):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    -- reset device
                    command_seq(36):=(h_reset,none   ,0,0,0,0,0,0,0,valid,250 ns);
                    command_seq(37):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38):=(wt     ,none      ,0,0,0,0,0,0,0,valid,tRPH);
                    -- confirm PPB Lock bit is set
                    command_seq(39):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(42):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "PPB ERASE, positive test";
                    command_seq(1) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(ppb_ers,none    ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Configuration Register
                    command_seq(8) :=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Bank Register Read command is not allowed during PPB ERASE
                    command_seq(10):=(bank_rd,rd_HiZ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPPBE);
                    command_seq(13):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(rd_sr1 ,erase_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(ppbacc_rd,read_ppbar,2,0,0,0,0,15,19,valid,0 ns);
                    command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 3  =>
                    REPORT "PPB ERASE, negative test";
                    --PPB Erase command is disabled if PPBOTP = '0';
                    command_seq(1) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_ppb  ,none    ,1,0,0,0,0,39,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(11):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(ppbacc_rd,read_ppbar,2,0,0,0,0,39,0,valid,0 ns);
                    command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Setting up PPBOTP bit to '0'
                    command_seq(16):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(w_asp  ,none    ,1,0,0,0,16#FEF7#,0,0,valid,0 ns);
                    command_seq(20):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(25):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(asp_reg_rd,read_asp,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --PPB Erase command is issued
                    command_seq(30):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(ppb_ers,none    ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Verify that command is rejected
                    command_seq(34):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Verify that E_ERR bit is set to '1'
                    command_seq(36):=(rd_sr1  ,erase_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38):=(ppbacc_rd,read_ppbar,2,0,0,0,0,39,0,valid,0 ns);
                    command_seq(39):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(42):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

           WHEN 28  =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "DYB Program, positive test";
                    command_seq(1) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_dyb  ,none    ,1,0,0,0,0,15,0,hold_dat,0 ns);
                    command_seq(5) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(9) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(dybacc_rd,read_dybar,2,0,0,0,0,15,19,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --DYB[15] = '0' => Sector 15 is protected
                    command_seq(16):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(pg_prog4,none  ,1,0,0,0,16#AA#,15,19,valid,0 ns);
                    command_seq(19):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(rd_sr1  ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Setting up DYB[15] to '1'
                    command_seq(25):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(w_dyb  ,none    ,1,0,0,0,16#FF#,15,0,valid,0 ns);
                    command_seq(28):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Status Register 2
                    command_seq(31):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Configuration Register
                    command_seq(33):=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Bank Register Read command is not allowed during DYB Program
                    command_seq(35):=(bank_rd,rd_HiZ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(38):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41):=(dybacc_rd,read_dybar,2,0,0,0,0,15,19,valid,0 ns);
                    command_seq(42):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(43):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(44):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(45):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "DYB Program, negative test";
                    command_seq(1) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_dyb  ,none    ,1,0,0,0,8,15,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(9) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(dybacc_rd,read_dybar,2,0,0,0,0,15,19,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 29  =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "Program ASP Register, Illegal condition";
                    command_seq(1) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                     --PWDMLB='0' & PSTMLB='0'
                    command_seq(4) :=(w_asp  ,none    ,1,0,0,0,16#FEE1#,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(10):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(asp_reg_rd,read_asp,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "Program ASP Register test";
                    command_seq(1) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    --PPBOTP bit is OTP, it can't be programmed more than once
                    command_seq(2) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_asp  ,none    ,1,0,0,0,16#FE6F#,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    --Read Status Register 2
                    command_seq(7) :=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Configuration Register
                    command_seq(9) :=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Bank Register Read command is not allowed during ASP Register Program
                    command_seq(11):=(bank_rd,rd_HiZ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(14):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(asp_reg_rd,read_asp,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 30  =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "SECTOR ERASE: positive test (256KB/64KB)";
                    -- 3 Bytes address and EXTADD = '0'
                    -- Erasure of sector 32
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(pg_prog4,none  ,10,0,0,0,16#01#,32,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(9) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' THEN
                        command_seq(14):=(pg_prog4,none  ,16,0,0,0,16#01#,32,16#3FFF0#,valid,0 ns);
                        command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(16):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(18):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(19):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(20):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(21):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(14):=(pg_prog4,none  ,16,0,0,0,16#01#,32,16#FFF0#,valid,0 ns);
                        command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(16):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(18):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(19):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(20):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(21):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    command_seq(22):=(rd_4     ,read_4,10,0,0,0,0,32,0,valid,0 ns);
                    command_seq(23):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' THEN
                        command_seq(24):=(rd_4     ,read_4,10,0,0,0,0,32,16#3FFF0#,valid,0 ns);
                        command_seq(25):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(24):=(rd_4     ,read_4,10,0,0,0,0,32,16#FFF0#,valid,0 ns);
                        command_seq(25):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    command_seq(26):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(sector_erase,none,0,0,0,0,0,32,0,valid,0 ns);
                    command_seq(29):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Status Register 2
                    command_seq(32):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Configuration Register
                    command_seq(34) :=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Bank Register Read command is not allowed during Sector Erase
                    command_seq(36):=(bank_rd,rd_HiZ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tSE);
                    command_seq(39):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40):=(rd_sr1  ,erase_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' THEN
                        command_seq(42):=(rd_4     ,read_4,10,0,0,0,0,32,16#3FFF0#,valid,0 ns);
                        command_seq(43):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(42):=(rd_4     ,read_4,10,0,0,0,0,32,16#FFF0#,valid,0 ns);
                        command_seq(43):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    command_seq(44):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "SECTOR ERASE positive test (256KB/64KB)";
                    -- 4 Bytes address
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(pg_prog4,none  ,10,0,0,0,16#01#,60,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(9) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' THEN
                        command_seq(14):=(pg_prog4,none  ,16,0,0,0,16#01#,60,16#3FFF0#,valid,0 ns);
                        command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(16):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(18):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(19):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(20):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(21):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(14):=(pg_prog4,none  ,16,0,0,0,16#01#,60,16#FFF0#,valid,0 ns);
                        command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(16):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(18):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(19):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(20):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(21):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    command_seq(22):=(rd_4     ,read_4,10,0,0,0,0,60,0,valid,0 ns);
                    command_seq(23):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' THEN
                        command_seq(24):=(rd_4     ,read_4,10,0,0,0,0,60,16#3FFF0#,valid,0 ns);
                        command_seq(25):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(24):=(rd_4     ,read_4,10,0,0,0,0,60,16#FFF0#,valid,0 ns);
                        command_seq(25):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    command_seq(26):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(sector_erase_4,none,0,0,0,0,0,60,0,valid,0 ns);
                    command_seq(29):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tSE);
                    command_seq(35):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36):=(rd_sr1  ,erase_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' THEN
                        command_seq(38):=(rd_4     ,read_4,10,0,0,0,0,60,16#3FFF0#,valid,0 ns);
                        command_seq(39):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(38):=(rd_4     ,read_4,10,0,0,0,0,60,16#FFF0#,valid,0 ns);
                        command_seq(39):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;

                    WHEN 3  =>
                    REPORT "SECTOR ERASE : positive test";
                    -- 3 Bytes address and EXTADD = '1'
                    --Setting up EXTADD bit to '1'
                    command_seq(1) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_bank ,none    ,1,0,0,0,16#80#,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(bank_rd,read_bank,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(w_scr  ,none     ,2,0,0,0,16#24#,0,0,valid,0 ns);
                    command_seq(17):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(19):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(sector_erase,none,0,0,0,0,0,20,0,valid,0 ns);
                    command_seq(23):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tSE);
                    command_seq(29):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(rd_sr1  ,erase_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(rd     ,read  ,7,0,20,0,0,0,0,valid,0 ns);
                    command_seq(33):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Setting up EXTADD bit to '0'
                    command_seq(34):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36):=(w_bank ,none    ,1,0,0,0,16#00#,0,0,valid,0 ns);
                    command_seq(37):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40):=(wt     ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(42):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(43):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(44):=(bank_rd,read_bank,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(45):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(46):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 4  =>
                    REPORT "Sector Erase applied to a 64 KB range that includes"&
                           "4 KB sectors";
                    IF Model(16) = '0' AND Sec_Arch = FALSE THEN
                        command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --Program operation on Parameter Sector 510 is issued
                        command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(4) :=(pg_prog4,none ,5,0,0,0,16#01#,510,0,valid,0 ns);
                        command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(6) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(8) :=(rd_4   ,read_4,5,0,0,0,0,510,0,valid,0 ns);
                        command_seq(9) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --Program operation on Parameter Sector 511 is issued
                        command_seq(10):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(12):=(pg_prog4,none ,5,0,0,0,16#01#,511,0,valid,0 ns);
                        command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(14):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(16):=(rd_4   ,read_4,5,0,0,0,0,511,0,valid,0 ns);
                        command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --Program operation on Parameter Sector 512 is issued
                        command_seq(18):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(19):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(20):=(pg_prog4,none ,5,0,0,0,16#01#,512,0,valid,0 ns);
                        command_seq(21):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(22):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(23):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(24):=(rd_4   ,read_4,5,0,0,0,0,512,0,valid,0 ns);
                        command_seq(25):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --Program operation on Parameter Sector 513 is issued
                        command_seq(26):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(27):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(28):=(pg_prog4,none ,5,0,0,0,16#01#,513,0,valid,0 ns);
                        command_seq(29):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(30):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(31):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(32):=(rd_4   ,read_4,5,0,0,0,0,513,0,valid,0 ns);
                        command_seq(33):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --Program operation on Parameter Sector 520 is issued
                        command_seq(34):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(35):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(36):=(pg_prog4,none ,5,0,0,0,16#01#,520,0,valid,0 ns);
                        command_seq(37):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(38):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(39):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(40):=(rd_4   ,read_4,5,0,0,0,0,520,0,valid,0 ns);
                        command_seq(41):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(42):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(43):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --Sector Erase command is applied to a 64 KB range that includes
                        --4 KB sectors
                        command_seq(44):=(sector_erase_4,none,0,0,0,0,0,518,0,valid,0 ns);
                        command_seq(45):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(46):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(47):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(48):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                        command_seq(49):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(50):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tSE);
                        command_seq(51):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(52):=(rd_sr1  ,erase_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(53):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --Verify that all Parameter Sectors from selected 64KB region
                        --are erased
                        command_seq(54):=(rd_4   ,read_4,5,0,0,0,0,510,0,valid,0 ns);
                        command_seq(55):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(56):=(rd_4   ,read_4,5,0,0,0,0,511,0,valid,0 ns);
                        command_seq(57):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(58):=(rd_4   ,read_4,5,0,0,0,0,512,0,valid,0 ns);
                        command_seq(59):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(60):=(rd_4   ,read_4,5,0,0,0,0,513,0,valid,0 ns);
                        command_seq(61):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(62):=(rd_4   ,read_4,5,0,0,0,0,520,0,valid,0 ns);
                        command_seq(63):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(64):=(rd_4   ,read_4,5,0,0,0,0,521,0,valid,0 ns);
                        command_seq(65):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(66):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSIF Model(16) = '0' AND Sec_Arch = TRUE THEN
                        command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(2) :=(rd     ,read  ,5,0,0,0,0,0,0,valid,0 ns);
                        command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --Program operation on Parameter Sector 1 is issued
                        command_seq(4) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(6) :=(pg_prog4,none ,5,0,0,0,16#01#,1,0,valid,0 ns);
                        command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(8) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(9) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(10):=(rd     ,read  ,5,0,0,0,0,1,0,valid,0 ns);
                        command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --Program operation on Parameter Sector 2 is issued
                        command_seq(12):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(14):=(pg_prog4,none ,5,0,0,0,16#01#,2,0,valid,0 ns);
                        command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(16):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(18):=(rd     ,read  ,5,0,0,0,0,2,0,valid,0 ns);
                        command_seq(19):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --Program operation on Parameter Sector 3 is issued
                        command_seq(20):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(21):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(22):=(pg_prog4,none ,5,0,0,0,16#01#,3,0,valid,0 ns);
                        command_seq(23):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(24):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(25):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(26):=(rd     ,read  ,5,0,0,0,0,3,0,valid,0 ns);
                        command_seq(27):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --Program operation on Parameter Sector 15 is issued
                        command_seq(28):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(29):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(30):=(pg_prog4,none ,5,0,0,0,16#01#,15,0,valid,0 ns);
                        command_seq(31):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(32):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(33):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(34):=(rd     ,read  ,5,0,0,0,0,15,0,valid,0 ns);
                        command_seq(35):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --Program operation on Parameter Sector 16 is issued
                        command_seq(36):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(37):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(38):=(pg_prog4,none ,5,0,0,0,16#01#,16,0,valid,0 ns);
                        command_seq(39):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(40):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(41):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(42):=(rd     ,read  ,5,0,0,0,0,16,0,valid,0 ns);
                        command_seq(43):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(44):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(45):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --Sector Erase command is applied to a 64 KB range that includes
                        --4 KB sectors
                        command_seq(46):=(sector_erase_4,none,0,0,0,0,0,3,0,valid,0 ns);
                        command_seq(47):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(48):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(49):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(50):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                        command_seq(51):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(52):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tSE);
                        command_seq(53):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(54):=(rd_sr1  ,erase_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(55):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --Verify that all Parameter Sectors from selected 64KB region
                        --are erased
                        command_seq(56):=(rd     ,read  ,5,0,0,0,0,0,0,valid,0 ns);
                        command_seq(57):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(58):=(rd     ,read  ,5,0,0,0,0,1,0,valid,0 ns);
                        command_seq(59):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(60):=(rd     ,read  ,5,0,0,0,0,2,0,valid,0 ns);
                        command_seq(61):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(62):=(rd     ,read  ,5,0,0,0,0,3,0,valid,0 ns);
                        command_seq(63):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(64):=(rd     ,read  ,5,0,0,0,0,15,0,valid,0 ns);
                        command_seq(65):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(66):=(rd     ,read  ,5,0,0,0,0,16,0,valid,0 ns);
                        command_seq(67):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(68):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;

                    WHEN 5  =>
                    REPORT "Parameter 4 KB-sector Erase: positive test";
                    IF Model(16) = '0' AND Sec_Arch = FALSE THEN
                        -- 3 Bytes address and EXTADD = '0'
                        -- Erasure of sector 511
                        command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(4) :=(pg_prog4,none  ,10,0,0,0,16#01#,511,0,valid,0 ns);
                        command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(6) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(8) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(9) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(10):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(12):=(rd_4     ,read_4,10,0,0,0,0,511,0,valid,0 ns);
                        command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(14) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(15) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(16):=(pg_prog4,none  ,10,0,0,0,16#01#,511,16#FF0#,valid,0 ns);
                        command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(18):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(19):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(20):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(21):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(22):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(23):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(24):=(rd_4     ,read_4,10,0,0,0,0,511,16#FF0#,valid,0 ns);
                        command_seq(25):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(26):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(27):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(28):=(p4_erase_4,none,0,0,0,0,0,511,0,valid,0 ns);
                        command_seq(29):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(30):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(31):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(32):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                        command_seq(33):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(34):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tSE);
                        command_seq(35):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(36):=(rd_sr1 ,erase_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(37):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(38):=(rd_4   ,read_4,10,0,0,0,0,511,0,valid,0 ns);
                        command_seq(39):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(40):=(rd_4   ,read_4,10,0,0,0,0,511,16#FF0#,valid,0 ns);
                        command_seq(41):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        -- 4 Bytes address
                        -- Erasure of sector 512
                        command_seq(42):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(43):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(44):=(pg_prog4,none  ,10,0,0,0,16#01#,512,0,valid,0 ns);
                        command_seq(45):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(46):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(47):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(48):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(49):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(50):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(51):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(52):=(rd_4     ,read_4,10,0,0,0,0,512,0,valid,0 ns);
                        command_seq(53):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(54) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(55) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(56):=(pg_prog4,none  ,10,0,0,0,16#01#,512,16#FF0#,valid,0 ns);
                        command_seq(57):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(58):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(59):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(60):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(61):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(62):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(63):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(64):=(rd_4     ,read_4,10,0,0,0,0,512,16#FF0#,valid,0 ns);
                        command_seq(65):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(66):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(67):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(68):=(p4_erase_4,none,0,0,0,0,0,512,0,valid,0 ns);
                        command_seq(69):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(70):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(71):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(72):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                        command_seq(73):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(74):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tSE);
                        command_seq(75):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(76):=(rd_sr1 ,erase_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(77):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(78):=(rd_4   ,read_4,10,0,0,0,0,512,0,valid,0 ns);
                        command_seq(79):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(80):=(rd_4   ,read_4,10,0,0,0,0,512,16#FF0#,valid,0 ns);
                        command_seq(81):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(82):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSIF Model(16) = '0' AND Sec_Arch = TRUE THEN
                        -- 3 Bytes address and EXTADD = '0'
                        -- Erasure of sector 2
                        command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(4) :=(pg_prog4,none  ,10,0,0,0,16#01#,2,0,valid,0 ns);
                        command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(6) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(8) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(9) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(10):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(12):=(rd_4     ,read_4,10,0,0,0,0,2,0,valid,0 ns);
                        command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(14) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(15) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(16):=(pg_prog4,none  ,10,0,0,0,16#01#,2,16#FF0#,valid,0 ns);
                        command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(18):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(19):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(20):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(21):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(22):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(23):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(24):=(rd_4     ,read_4,10,0,0,0,0,2,16#FF0#,valid,0 ns);
                        command_seq(25):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(26):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(27):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(28):=(p4_erase,none,0,0,0,0,0,2,0,valid,0 ns);
                        command_seq(29):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(30):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(31):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(32):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                        command_seq(33):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(34):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tSE);
                        command_seq(35):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(36):=(rd_sr1 ,erase_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(37):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(38):=(rd_4   ,read_4,10,0,0,0,0,2,0,valid,0 ns);
                        command_seq(39):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(40):=(rd_4   ,read_4,10,0,0,0,0,2,16#FF0#,valid,0 ns);
                        command_seq(41):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        -- 4 Bytes address
                        -- Erasure of sector 3
                        command_seq(42):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(43):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(44):=(pg_prog4,none  ,10,0,0,0,16#01#,3,0,valid,0 ns);
                        command_seq(45):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(46):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(47):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(48):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(49):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(50):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(51):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(52):=(rd_4     ,read_4,10,0,0,0,0,3,0,valid,0 ns);
                        command_seq(53):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(54) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(55) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(56):=(pg_prog4,none  ,10,0,0,0,16#01#,3,16#FF0#,valid,0 ns);
                        command_seq(57):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(58):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(59):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(60):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(61):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(62):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(63):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(64):=(rd_4     ,read_4,10,0,0,0,0,3,16#FF0#,valid,0 ns);
                        command_seq(65):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(66):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(67):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(68):=(p4_erase_4,none,0,0,0,0,0,3,0,valid,0 ns);
                        command_seq(69):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(70):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(71):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(72):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                        command_seq(73):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(74):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tSE);
                        command_seq(75):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(76):=(rd_sr1 ,erase_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(77):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(78):=(rd_4   ,read_4,10,0,0,0,0,3,0,valid,0 ns);
                        command_seq(79):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(80):=(rd_4   ,read_4,10,0,0,0,0,3,16#FF0#,valid,0 ns);
                        command_seq(81):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(82):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 31  =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "SECTOR ERASE : negative test";
                    --sector is protected
                    --3byte address
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_sr   ,none      ,1,0,0,0,16#18#,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(9) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(rd_sr1 ,read_sr1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(sector_erase,none  ,0,0,0,0,0,5,0,valid,0 ns);
                    command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(rd_sr1 ,erase_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(rd     ,read    ,1,0,0,0,0,5,16#A#,valid,0 ns);
                    command_seq(20):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(clr_sr ,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(done   ,none    ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "SECTOR ERASE : negative test";
                    --4byte address
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_sr  ,none      ,1,0,0,0,16#18#,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(11):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(rd_sr1 ,read_sr1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(sector_erase_4,none  ,0,0,0,0,0,4,0,valid,0 ns);
                    command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(rd_sr1  ,erase_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(rd     ,read  ,3,0,0,0,0,4,0,valid,0 ns);
                    command_seq(22):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 3  =>
                    REPORT "Parameter 4 KB-sector Erase: negative test";
                    --3 Bytes address and EXTADD = '0'
                    --P4E instruction applied to a sector that has been
                    --Write Protected through the Block Protect Bits or ASP will
                    --not be executed and will set the E_ERR status
                    IF Model(16) = '0' THEN
                        command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(4) :=(w_sr  ,none     ,2,0,0,0,16#1C#,0,0,valid,0 ns);
                        command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(7) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(8) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(9) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(10):=(idle    ,none ,0,0,0,0,0,0,0,valid,0 ns);
                        IF Sec_Arch = FALSE THEN
                            command_seq(11):=(p4_erase_4,none ,0,0,0,0,0,515,0,valid,0 ns);
                            command_seq(12):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        ELSIF Sec_Arch = TRUE THEN
                            command_seq(11):=(p4_erase,none ,0,0,0,0,0,4,0,valid,0 ns);
                            command_seq(12):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        END IF;
                        --Verify that P4E command is rejected
                        command_seq(13):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        --Verify that E_ERR bit is set
                        command_seq(14):=(rd_sr1 ,erase_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(16):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(18):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(19):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(20):=(w_sr  ,none     ,2,0,0,0,16#00#,0,0,valid,0 ns);
                        command_seq(21):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(22):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(23):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(24):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(25):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(1):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(2):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(3):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(4):=(w_sr  ,none     ,2,0,0,0,16#00#,0,0,valid,0 ns);
                        command_seq(5):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(6):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(7):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                        command_seq(8):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(9):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;

                    WHEN 4  =>
                    REPORT "Parameter 4 KB-sector Erase: negative test";
                    --3 Bytes address and EXTADD = '0'
                    --P4E instruction applied to a sector that is larger than
                    --4KB will not be executed and will not set the E_ERR status.
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(pg_prog,none  ,10,0,0,0,16#01#,44,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(9) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(rd     ,read  ,3,0,0,0,0,44,0,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(idle    ,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(p4_erase,err ,0,0,0,0,0,44,0,valid,0 ns);
                    command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Verify that P4E command is rejected
                    --Warning is generated
                    command_seq(18):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    --Verify that E_ERR bit has value 0
                    command_seq(19) :=(rd_sr1 ,erase_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Verify that locations selected for erasure still have
                    --previous values
                    command_seq(21):=(rd     ,read  ,10,0,0,0,0,44,0,valid,0 ns);
                    command_seq(22):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 32  =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "ERASE SUSPEND: positive test";
                    --opcode is D8h and 3byte addresss
                    --erase one sector of 256/64 KBytes
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_sr  ,none     ,2,0,0,0,16#00#,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(8) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11) :=(sector_erase,none,0,0,0,0,0,18,0,valid,0 ns);
                    command_seq(12) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --When the Erase Suspend command is written during a
                    --erase operation, the device requires a maximum
                    --of tESL to suspend the erase operation.
                    command_seq(15):=(ers_susp,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tESL);
                    command_seq(18):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(rd_sr2 ,rd_es_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Array during Erase Suspend
                    IF Model(16) = '1' THEN
                    -- Reading from the top of memory array (verify that when the
                    -- highest address is reached, the address counter will wrap
                    -- around and roll back to 000000h, allowing the read sequence
                    -- to be continued indefinitely.
                        command_seq(21):=(rd_4   ,read_4 ,2,0,0,0,0,127,16#3FFFF#,valid,0 ns);
                        command_seq(22):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSIF  Model(16) = '0' AND Sec_Arch = FALSE THEN
                        command_seq(21):=(rd_4   ,read_4 ,2,0,0,0,0,541,16#FFF#,valid,0 ns);
                        command_seq(22):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(21):=(rd_4   ,read_4 ,2,0,0,0,0,541,16#FFFF#,valid,0 ns);
                        command_seq(22):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    --Read Array from Erase Suspended sector
                    command_seq(23):=(rd     ,rd_U    ,2,0,0,0,0,17,16#05#,valid,0 ns);
                    command_seq(24):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(wt     ,none    ,0,0,0,0,0,0,0,valid,10 ns);
                    ------
                    command_seq(26) :=(fast_rd,read_fast,2,0,0,0,0,14,16#FF#,valid,0 ns);
                    command_seq(27) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ------
                    command_seq(28) :=(fast_rd,rd_U  ,2,0,0,0,0,17,5,valid,0 ns);
                    command_seq(29) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,10 ns);
                    ------
                    IF Model(16) = '1' THEN
                    -- Reading from the top of memory array (verify that when the
                    -- highest address is reached, the address counter will wrap
                    -- around and roll back to 000000h, allowing the read sequence
                    -- to be continued indefinitely.
                        command_seq(31) :=(fast_ddr_rd4,read_ddr_fast4,2,0,0,0,0,127,16#3FFFF#, valid,0 ns);
                        command_seq(32) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSIF Model(16) = '0' AND Sec_Arch = FALSE THEN
                        command_seq(31) :=(fast_ddr_rd4,read_ddr_fast4,2,0,0,0,0,541,16#FFF#, valid,0 ns);
                        command_seq(32) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(31) :=(fast_ddr_rd4,read_ddr_fast4,2,0,0,0,0,541,16#FFFF#, valid,0 ns);
                        command_seq(32) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    ------
                    command_seq(33) :=(fast_ddr_rd,rd_U,2,0,0,0,0,17,5,valid,0 ns);
                    command_seq(34) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35) :=(wt     ,none ,0,0,0,0,0,0,0,valid,10 ns);
                    ------
                    IF Model(16) = '1' THEN
                    -- Reading from the top of memory array (verify that when the
                    -- highest address is reached, the address counter will wrap
                    -- around and roll back to 000000h, allowing the read sequence
                    -- to be continued indefinitely.
                        command_seq(36) :=(dual_rd_4,read_dual_4,2,0,0,0,0,127,16#3FFFF#,valid,0 ns);
                        command_seq(37) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSIF Model(16) = '0' AND Sec_Arch = FALSE THEN
                        command_seq(36) :=(dual_rd_4,read_dual_4,2,0,0,0,0,541,16#FFF#,valid,0 ns);
                        command_seq(37) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(36) :=(dual_rd_4,read_dual_4,2,0,0,0,0,541,16#FFFF#,valid,0 ns);
                        command_seq(37) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    ------
                    command_seq(38) :=(dual_rd,rd_U  ,2,0,0,0,0,17,5,valid,0 ns);
                    command_seq(39) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,10 ns);
                    ------
                    command_seq(41) :=(dual_high_ddr_rd,read_ddr_dual_hi,2,0,0,0,0,6,16#A#,valid,0 ns);
                    command_seq(42) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ------
                    command_seq(43) :=(dual_high_ddr_rd,rd_U,2,0,0,0,0,17,5,valid,0 ns);
                    command_seq(44) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(45) :=(wt     ,none ,0,0,0,0,0,0,0,valid,10 ns);
                    --Bank Register write
                    command_seq(46):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(47):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(48):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(49):=(w_bank ,none     ,1,0,0,0,16#80#,0,0,valid,0 ns);
                    command_seq(50):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(51):=(rd_sr1 ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(52):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(53):=(wt     ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(54):=(rd_sr1 ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(55):=(rd_sr1 ,pgm_succ ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(56):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Bank Register Read
                    command_seq(57):=(bank_rd,read_bank,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(58):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(59):=(w_bank ,none     ,1,0,0,0,16#00#,0,0,valid,0 ns);
                    command_seq(60):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(61):=(wt     ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(62):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --DYB Program
                    command_seq(63):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(64):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(65):=(w_dyb  ,none    ,1,0,0,0,0,5,0,valid,0 ns);
                    command_seq(66):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(67):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(68):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(69):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(70):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(71):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(72):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(73):=(dybacc_rd,read_dybar,2,0,0,0,0,5,19,valid,0 ns);
                    command_seq(74):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(75):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(76):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(77):=(w_dyb  ,none    ,1,0,0,0,16#FF#,5,0,valid,0 ns);
                    command_seq(78):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(79):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(80):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(81):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(82):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(83):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(84):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(85):=(dybacc_rd,read_dybar,2,0,0,0,0,5,19,valid,0 ns);
                    command_seq(86):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Array from Erase Suspended sector
                    command_seq(87):=(rd,rd_U         ,2,0,0,0,0,17,5,valid,0 ns);
                    command_seq(88):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(89):=(wt     ,none    ,0,0,0,0,0,0,0,valid,10 ns);
                    --Read Configuration Register
                    command_seq(90):=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(91):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --PPB Lock Register Read command is not allowed during Erase Suspend
                    command_seq(92):=(ppbl_reg_rd,rd_HiZ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(93):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --The system must write the Erase Resume command
                    --to exit the erase suspend mode and continue the
                    --erase operation.
                    command_seq(94):=(ers_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(95):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(96):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(97):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Erase Resume to next Erase Suspend
                    --Typical period of 100 us is needed for Erase to progress
                    --to completion. If ERSP command is issued during tERS time
                    --warning is generated
                    command_seq(98):=(ers_susp,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(99):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(100):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tESL);
                    --Verify that ERSP command is accepted
                    command_seq(101):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(102):=(rd_sr2 ,rd_es_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(103):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    IF (Model(15) = '0' OR Model(15) = '2' OR Model(15) = '3' OR Model(15) = 'R' OR
                        Model(15) = 'A' OR Model(15) = 'B' OR Model(15) = 'C' OR Model(15) = 'D' OR
                        Model(15) = 'Y' OR Model(15) = 'Z' OR Model(15) = 'S' OR Model(15) = 'T' OR
                        Model(15) = 'K' OR Model(15) = 'L') THEN
                        --Continuous read and MBR command
                        --fast ddr read - Initial access, mode bits are A5h
                        command_seq(104):=(fast_ddr_rd,read_ddr_fast,5,0,0,0,16#A5#,0,0,valid,0 ns);
                        command_seq(105):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Continuous fast ddr read - Subsequent access
                        command_seq(106):=(fast_ddr_rd,rd_cont_fddr,5,0,0,0,0,0,1,break,0 ns);
                        command_seq(107):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- fast ddr read - Initial access, mode bits are F0h
                        command_seq(108):=(fast_ddr_rd,read_ddr_fast,5,0,0,0,16#F0#,0,0,valid,0 ns);
                        command_seq(109):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Initiate MBR command to release from Fast DDR Read
                        command_seq(110):=(mbr   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(111):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Bank Register Access Command followed by WRR
                        command_seq(112):=(bank_acc,none    ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(113):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --For S25FL256S BA25 is Reserved bits
                        --WRR command is issued and warning for BA25 is generated
                        command_seq(114):=(w_sr  ,none    ,1,0,0,0,16#02#,0,0,valid,0 ns);
                        command_seq(115):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        --Bank Register Access Command followed by command other than WRR
                        command_seq(116):=(bank_acc,none    ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(117):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(118):=(w_disable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(119):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --PPB Read
                        command_seq(120):=(ppbacc_rd,read_ppbar,2,0,0,0,0,38,19,valid,0 ns);
                        command_seq(121):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --The system must write the Erase Resume command
                        --to exit the erase suspend mode and continue the
                        --erase operation.
                        command_seq(122):=(ers_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(123):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(124):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(125):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(126) :=(wt     ,none    ,0,0,0,0,0,0,0,valid,tSE);
                        command_seq(127):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(128):=(rd_sr1 ,erase_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(129):=(rd_sr1 ,rd_es_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(130):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(131):=(rd     ,read    ,3,0,0,0,0,17,0,valid,0 ns);
                        command_seq(132):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(133):=(done   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        --Bank Register Access Command followed by WRR
                        command_seq(104):=(bank_acc,none    ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(105):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --For S25FL256S BA25 is Reserved bits
                        --WRR command is issued and warning for BA25 is generated
                        command_seq(106):=(w_sr  ,none    ,1,0,0,0,16#02#,0,0,valid,0 ns);
                        command_seq(107):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        --Bank Register Access Command followed by command other than WRR
                        command_seq(108):=(bank_acc,none    ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(109):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(110):=(w_disable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(111):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --PPB Read
                        command_seq(112):=(ppbacc_rd,read_ppbar,2,0,0,0,0,38,19,valid,0 ns);
                        command_seq(113):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --The system must write the Erase Resume command
                        --to exit the erase suspend mode and continue the
                        --erase operation.
                        command_seq(114):=(ers_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(115):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(116):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(117):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(118) :=(wt     ,none    ,0,0,0,0,0,0,0,valid,tSE);
                        command_seq(119):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(120):=(rd_sr1 ,erase_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(121):=(rd_sr1 ,rd_es_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(122):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(123):=(rd     ,read    ,3,0,0,0,0,17,0,valid,0 ns);
                        command_seq(124):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(125):=(done   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;

                    WHEN 2  =>
                    REPORT "ERASE SUSPEND: positive test";
                    command_seq(1) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_scr  ,none      ,2,0,0,0,16#26#,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(wt     ,none      ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(8) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13) :=(sector_erase,none,0,0,0,0,0,18,0,valid,0 ns);
                    command_seq(14) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --When the Erase Suspend command is written during a
                    --erase operation, the device requires a maximum
                    --of tESL to suspend the erase operation.
                    command_seq(17) :=(ers_susp,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tESL);
                    command_seq(20):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(rd_sr2 ,rd_es_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Array during Erase Suspend -QUAD READ
                    IF Model(16) = '1' THEN
                    -- Reading from the top of memory array (verify that when the
                    -- highest address is reached, the address counter will wrap
                    -- around and roll back to 000000h, allowing the read sequence
                    -- to be continued indefinitely.
                        command_seq(23):=(quad_rd_4,rd_quad_4 ,2,0,0,0,0,127,16#3FFFF#,valid,0 ns);
                        command_seq(24):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSIF  Model(16) = '0' AND Sec_Arch = FALSE THEN
                        command_seq(23):=(quad_rd_4,rd_quad_4 ,2,0,0,0,0,541,16#FFF#,valid,0 ns);
                        command_seq(24):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(23):=(quad_rd_4,rd_quad_4 ,2,0,0,0,0,541,16#FFFF#,valid,0 ns);
                        command_seq(24):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    --Read Array from Erase Suspended sector
                    command_seq(25):=(quad_rd,rd_U    ,2,0,0,0,0,18,5,valid,0 ns);
                    command_seq(26):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(wt     ,none    ,0,0,0,0,0,0,0,valid,10 ns);
                    --Read Array during Erase Suspend -QUAD DDR READ
                    command_seq(28):=(quad_high_ddr_rd,read_ddr_quad_hi,2,0,0,0,0,50,16#11#,valid,0 ns);
                    command_seq(29):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Array from Erase Suspended sector
                    command_seq(30):=(quad_high_ddr_rd,rd_U,2,0,0,0,0,18,5,valid,0 ns);
                    command_seq(31):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(wt     ,none    ,0,0,0,0,0,0,0,valid,10 ns);
                    --Quad Page Program During Erase Suspend
                    command_seq(33):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35):=(quad_pg_prog,none,10,0,0,0,16#AA#,46,256,valid,0 ns);
                    command_seq(36):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(40):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    --Verify that WEL bit is reseted
                    command_seq(42):=(rd_sr1 ,rd_wel_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(43):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    -- QPP command is issued on programmed page
                    command_seq(44):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(45):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(46):=(quad_pg_prog,none,10,0,0,0,16#AA#,46,276,valid,0 ns);
                    REPORT "****************************************************" & lf &
                           "         QPP command on programmed should generate warning from model" & lf &
                           "         Testseries  : 32" & lf &
                           "         Testcase    : 02" & lf &
                           "         command_cnt : 46" & lf &
                           "         ****************************************************";
                    command_seq(47):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Command is not rejected, warning is generated
                    -- (Quad Page Program forbids writing the same page more than once, but
                    -- does not specify that error should be generated)
                    command_seq(48):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(49):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(50):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(51):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(52):=(quad_rd_4,rd_quad_4,8,0,0,0,0,46,256,valid,0 ns);
                    command_seq(53):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(54):=(quad_rd_4,rd_quad_4,8,0,0,0,0,46,276,valid,0 ns);
                    command_seq(55):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    --The system must write the Erase Resume command
                    --to exit the erase suspend mode and continue the
                    --erase operation.
                    command_seq(56) :=(ers_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(57):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(58):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(59):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tSE);
                    command_seq(60):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(61):=(rd_sr1 ,erase_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(62):=(rd_sr1 ,rd_es_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(63):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(64):=(rd     ,read    ,3,0,0,0,0,18,0,valid,0 ns);
                    command_seq(65):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(66):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(67):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(68):=(w_scr  ,none    ,2,0,0,0,16#0024#,0,0,valid,0 ns);
                    command_seq(69):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(70):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(71):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(72):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(73):=(done   ,none    ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 33  =>
                CASE Testcase IS
                    WHEN 1 =>
                    REPORT "PROGRAM DURING ERASE SUSPEND: positive test";
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(sector_erase,none,0,0,0,0,0,2,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --When the Erase Suspend command is written during a
                    --erase operation, the device requires a maximum
                    --of tESL to suspend the erase operation.
                    command_seq(8) :=(ers_susp,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tESL);
                    command_seq(11):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(rd_sr2 ,rd_es_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Program while erase is suspended
                    command_seq(14):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(pg_prog,none  ,10,0,0,0,16#AA#,18,0,valid,0 ns);
                    command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Status Register 2
                    command_seq(20):=(rd_sr2 ,rd_es_1,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Configuration Register
                    command_seq(22):=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Bank Register Read command is not allowed during Ers_Susp_Program
                    command_seq(24):=(bank_rd,rd_HiZ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(27):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(rd     ,read    ,8,0,0,0,0,18,0,valid,0 ns);
                    command_seq(31):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Program finished, erase will resume
                    command_seq(32):=(ers_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tSE);
                    command_seq(36):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37):=(rd_sr1 ,erase_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38):=(rd_sr2 ,rd_es_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40):=(rd     ,read    ,4,0,0,0,0,2,0,valid,0 ns);
                    command_seq(41):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(42):=(rd     ,read    ,4,0,0,0,0,2,16#AA#,valid,0 ns);
                    command_seq(43):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(44):=(rd     ,read    ,4,0,0,0,0,2,16#BFFE#,valid,0 ns);
                    command_seq(45):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' THEN
                        command_seq(46):=(rd     ,read    ,4,0,0,0,0,2,16#3FFFE#,valid,0 ns);
                        command_seq(47):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSIF Sec_Arch = FALSE THEN
                        command_seq(46):=(rd     ,read    ,4,0,0,0,0,2,16#FFFE#,valid,0 ns);
                        command_seq(47):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(46):=(rd     ,read    ,4,0,0,0,0,2,16#FFE#,valid,0 ns);
                        command_seq(47):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    command_seq(48):=(done   ,none    ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "PROGRAM SUSPEND DURING ERASE SUSPEND: positive test";
                        command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(4) :=(sector_erase,none,0,0,0,0,0,44,0,valid,0 ns);
                        command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(7) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --When the Erase Suspend command is written during a
                        --erase operation, the device requires a maximum
                        --of tESL to suspend the erase operation.
                        command_seq(8) :=(ers_susp,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(9) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(10):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tESL);
                        command_seq(11):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(12):=(rd_sr2 ,rd_es_1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(13):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Program while erase is suspended
                        command_seq(14):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(16):=(pg_prog,none  ,10,0,0,0,16#AA#,19,0,valid,0 ns);
                        command_seq(17):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(18):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(19):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);

                        --When the Program Suspend command is written during a
                        --program operation, the device requires a maximum
                        --of tPGSUSP to suspend the program operation.
                        command_seq(20):=(prg_susp,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(21):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(22):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPSL);
                        command_seq(23):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(24):=(rd_sr2 ,rd_ps_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(25):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --Read Array during Program Suspend - NORMAL READ
                        IF Model(16) = '1' THEN
                        -- Reading from the top of memory array (verify that when the
                        -- highest address is reached, the address counter will wrap
                        -- around and roll back to 000000h, allowing the read sequence
                        -- to be continued indefinitely.
                            command_seq(26):=(rd_4   ,read_4 ,2,0,0,0,0,127,16#3FFFF#,valid,0 ns);
                            command_seq(27):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            --Read Array from Program Suspended page
                            command_seq(28):=(rd     ,rd_U  ,2,0,0,0,0,19,5,valid,0 ns);
                            command_seq(29):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(30):=(wt     ,none  ,0,0,0,0,0,0,0,valid,10 ns);
                            --Read Array during Program Suspend -FAST READ
                            command_seq(31):=(fast_rd4,read_fast_4,2,0,0,0,0,127,16#3FFFF#,valid,0 ns);
                            command_seq(32):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            --Read Array from Program Suspended page
                            command_seq(33):=(fast_rd,rd_U  ,2,0,0,0,0,19,5,valid,0 ns);
                            command_seq(34):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(35):=(wt     ,none  ,0,0,0,0,0,0,0,valid,10 ns);
                            --Read Array during Program Suspend -FAST DDR READ
                            command_seq(36):=(fast_ddr_rd4,read_ddr_fast4,2,0,0,0,0,127,16#3FFFF#, valid,0 ns);
                            command_seq(37):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            --Read Array from Program Suspended page
                            command_seq(38):=(fast_ddr_rd,rd_U,2,0,0,0,0,19,5,valid,0 ns);
                            command_seq(39):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(40):=(wt     ,none ,0,0,0,0,0,0,0,valid,10 ns);
                            --Read Array during Program Suspend -DUAL READ
                            command_seq(41):=(dual_rd_4,read_dual_4,2,0,0,0,0,127,16#3FFFF#,valid,0 ns);
                            command_seq(42):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            --Read Array from Program Suspended page
                            command_seq(43):=(dual_rd,rd_U  ,2,0,0,0,0,19,5,valid,0 ns);
                            command_seq(44):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(45):=(wt     ,none  ,0,0,0,0,0,0,0,valid,10 ns);
                            --Read Array during Program Suspend -DUAL DDR READ
                            command_seq(46):=(dual_high_ddr_rd4,read_ddr_dual_hi4, 2,0,0,0,0,127,16#3FFFF#,valid,0 ns);
                            command_seq(47):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            --Read Array from Program Suspended page
                            command_seq(48):=(dual_high_ddr_rd,rd_U,2,0,0,0,0,19,5,valid,0 ns);
                            command_seq(49):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(50):=(wt     ,none ,0,0,0,0,0,0,0,valid,10 ns);
                        ELSIF Sec_Arch = FALSE THEN
                            command_seq(26):=(rd_4   ,read_4 ,2,0,0,0,0,541,16#FFF#,valid,0 ns);
                            command_seq(27):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            --Read Array from Program Suspended page
                            command_seq(28):=(rd     ,rd_U  ,2,0,0,0,0,19,5,valid,0 ns);
                            command_seq(29):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(30):=(wt     ,none  ,0,0,0,0,0,0,0,valid,10 ns);
                            --Read Array during Program Suspend -FAST READ
                            command_seq(31):=(fast_rd4,read_fast_4,2,0,0,0,0,541,16#FFF#,valid,0 ns);
                            command_seq(32):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            --Read Array from Program Suspended page
                            command_seq(33):=(fast_rd,rd_U  ,2,0,0,0,0,19,5,valid,0 ns);
                            command_seq(34):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(35):=(wt     ,none  ,0,0,0,0,0,0,0,valid,10 ns);
                            --Read Array during Program Suspend -FAST DDR READ
                            command_seq(36):=(fast_ddr_rd4,read_ddr_fast4,2,0,0,0,0,541,16#FFF#, valid,0 ns);
                            command_seq(37):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            --Read Array from Program Suspended page
                            command_seq(38):=(fast_ddr_rd,rd_U,2,0,0,0,0,19,5,valid,0 ns);
                            command_seq(39):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(40):=(wt     ,none ,0,0,0,0,0,0,0,valid,10 ns);
                            --Read Array during Program Suspend -DUAL READ
                            command_seq(41):=(dual_rd_4,read_dual_4,2,0,0,0,0,541,16#FFF#,valid,0 ns);
                            command_seq(42):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            --Read Array from Program Suspended page
                            command_seq(43):=(dual_rd,rd_U  ,2,0,0,0,0,19,5,valid,0 ns);
                            command_seq(44):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(45):=(wt     ,none  ,0,0,0,0,0,0,0,valid,10 ns);
                            --Read Array during Program Suspend -DUAL DDR READ
                            command_seq(46):=(dual_high_ddr_rd4,read_ddr_dual_hi4, 2,0,0,0,0,541,16#FFF#,valid,0 ns);
                            command_seq(47):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            --Read Array from Program Suspended page
                            command_seq(48):=(dual_high_ddr_rd,rd_U,2,0,0,0,0,19,5,valid,0 ns);
                            command_seq(49):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(50):=(wt     ,none ,0,0,0,0,0,0,0,valid,10 ns);
                        ELSE
                            command_seq(26):=(rd_4   ,read_4 ,2,0,0,0,0,541,16#FFFF#,valid,0 ns);
                            command_seq(27):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                            --Read Array from Program Suspended page
                            command_seq(28):=(rd     ,rd_U  ,2,0,0,0,0,19,5,valid,0 ns);
                            command_seq(29):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(30):=(wt     ,none  ,0,0,0,0,0,0,0,valid,10 ns);
                            --Read Array during Program Suspend -FAST READ
                            command_seq(31):=(fast_rd4,read_fast_4,2,0,0,0,0,541,16#FFFF#,valid,0 ns);
                            command_seq(32):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            --Read Array from Program Suspended page
                            command_seq(33):=(fast_rd,rd_U  ,2,0,0,0,0,19,5,valid,0 ns);
                            command_seq(34):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(35):=(wt     ,none  ,0,0,0,0,0,0,0,valid,10 ns);
                            --Read Array during Program Suspend -FAST DDR READ
                            command_seq(36):=(fast_ddr_rd4,read_ddr_fast4,2,0,0,0,0,541,16#FFFF#, valid,0 ns);
                            command_seq(37):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            --Read Array from Program Suspended page
                            command_seq(38):=(fast_ddr_rd,rd_U,2,0,0,0,0,19,5,valid,0 ns);
                            command_seq(39):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(40):=(wt     ,none ,0,0,0,0,0,0,0,valid,10 ns);
                            --Read Array during Program Suspend -DUAL READ
                            command_seq(41):=(dual_rd_4,read_dual_4,2,0,0,0,0,541,16#FFFF#,valid,0 ns);
                            command_seq(42):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            --Read Array from Program Suspended page
                            command_seq(43):=(dual_rd,rd_U  ,2,0,0,0,0,19,5,valid,0 ns);
                            command_seq(44):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(45):=(wt     ,none  ,0,0,0,0,0,0,0,valid,10 ns);
                            --Read Array during Program Suspend -DUAL DDR READ
                            command_seq(46):=(dual_high_ddr_rd4,read_ddr_dual_hi4, 2,0,0,0,0,541,16#FFFF#,valid,0 ns);
                            command_seq(47):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            --Read Array from Program Suspended page
                            command_seq(48):=(dual_high_ddr_rd,rd_U,2,0,0,0,0,19,5,valid,0 ns);
                            command_seq(49):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                            command_seq(50):=(wt     ,none ,0,0,0,0,0,0,0,valid,10 ns);
                        END IF;
                        --Bank Register write
                        command_seq(51):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(52):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(53):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(54):=(w_bank ,none     ,1,0,0,0,16#80#,0,0,valid,0 ns);
                        command_seq(55):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(56):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(57):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(58):=(wt     ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(59):=(rd_sr1 ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(60):=(rd_sr1 ,pgm_succ ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(61):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        --Bank Register Read
                        command_seq(62):=(bank_rd,read_bank,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(63):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(64):=(w_bank ,none     ,1,0,0,0,16#00#,0,0,valid,0 ns);
                        command_seq(65):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(66):=(wt     ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(67):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(68):=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                        command_seq(69):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --The system must write the Program Resume command
                        --to exit the program suspend mode and continue the
                        --sector erase suspend operation.
                        command_seq(70):=(prg_resume,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(71):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(72):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(73):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(74):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(75):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(76):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(77):=(rd     ,read  ,3,0,0,0,16#AA#,19,0,valid,0 ns);
                        command_seq(78):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Program finished, erase will resume
                        command_seq(79):=(ers_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(80):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(81):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(82):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tSE);
                        command_seq(83):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(84):=(rd_sr1 ,erase_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(85):=(rd_sr2 ,rd_es_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(86):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(87):=(rd     ,read    ,4,0,0,0,0,44,0,valid,0 ns);
                        command_seq(88):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(89):=(rd     ,read    ,4,0,0,0,0,44,16#AA#,valid,0 ns);
                        command_seq(90):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(91):=(rd     ,read    ,4,0,0,0,0,44,16#BFFE#,valid,0 ns);
                        command_seq(92):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(93):=(rd     ,read    ,4,0,0,0,0,44,16#3FFFE#,valid,0 ns);
                        command_seq(94):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(95):=(done   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 34  =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "RESET DURING PAGE PROGRAM: positive test";
                    command_seq(1)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2)  :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4)  :=(pg_prog,none  ,5,0,0,0,16#10#,38,16#01#,valid,0 ns);
                    command_seq(5)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6)  :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8)  :=(rst   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12) :=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14) :=(w_scr  ,none      ,2,0,0,0,16#0024#,0,0,valid,0 ns);
                    command_seq(15) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16) :=(rd_sr1 ,rd_wip_1  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17) :=(wt     ,none      ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(18) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19) :=(rd     ,rd_U    ,1,0,0,0,0,38,16#01#,valid,0 ns);
                    command_seq(20) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21) :=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23) :=(done   ,none    ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "RESET DURING SECTOR ERASE: positive test";
                    command_seq(1)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2)  :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4)  :=(sector_erase,none,0,0,0,0,0,40,0,valid,0 ns);
                    command_seq(5)  :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6)  :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7)  :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8)  :=(rst   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12) :=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14) :=(w_scr  ,none      ,2,0,0,0,16#0024#,0,0,valid,0 ns);
                    command_seq(15) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16) :=(rd_sr1 ,rd_wip_1  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17) :=(wt     ,none      ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(18) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19) :=(rd     ,rd_U    ,1,0,0,0,0,40,0,valid,0 ns);
                    command_seq(20) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21) :=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23) :=(done   ,none    ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 3  =>
                    REPORT "RESET DURING PROGRAM SUSPEND: positive test";
                    command_seq(1)  :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2)  :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3)  :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4)  :=(pg_prog,none    ,50,0,0,0,16#99#,41,0,valid,0 ns);
                    command_seq(5)  :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6)  :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7)  :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8)  :=(prg_susp,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9)  :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10) :=(wt     ,none    ,0,0,0,0,0,0,0,valid,tPSL);
                    command_seq(11) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12) :=(rd_sr2 ,rd_ps_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14) :=(rst   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18) :=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20) :=(w_scr  ,none      ,2,0,0,0,16#0024#,0,0,valid,0 ns);
                    command_seq(21) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22) :=(rd_sr1 ,rd_wip_1  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23) :=(wt     ,none      ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(24) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25) :=(rd     ,rd_U    ,5,0,0,0,0,41,16#10#,valid,0 ns);
                    command_seq(26) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27) :=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30) :=(done   ,none    ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 4  =>
                    REPORT "RESET DURING ERASE SUSPEND: positive test";
                    command_seq(1)  :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2)  :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3)  :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(sector_erase,none,0,0,0,0,0,60,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(ers_susp,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tESL);
                    command_seq(11):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(rd_sr2 ,rd_es_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14) :=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16) :=(rst   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20) :=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22) :=(w_scr  ,none      ,2,0,0,0,16#24#,0,0,valid,0 ns);
                    command_seq(23) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24) :=(rd_sr1 ,rd_wip_1  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25) :=(wt     ,none      ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(26) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27) :=(rd     ,rd_U    ,5,0,0,0,0,60,16#10#,valid,0 ns);
                    command_seq(28) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29) :=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32) :=(done   ,none    ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 5  =>
                    REPORT "RESET DURING PROGRAM IN ERASE SUSPEND: positive test";
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(sector_erase,none,0,0,0,0,0,42,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);

                    command_seq(8) :=(ers_susp,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tESL);
                    command_seq(11):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(rd_sr2 ,rd_es_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);

                    command_seq(14):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(pg_prog,none  ,10,0,0,0,16#AA#,43,0,valid,0 ns);
                    command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);

                    command_seq(19) :=(rst   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);

                    command_seq(23) :=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25) :=(rd     ,rd_U    ,5,0,0,0,0,42,0,valid,0 ns);
                    command_seq(26) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27) :=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29):=(done   ,none    ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 6  =>--Reset Condition when BPNV = '1'
                    REPORT "Reset Condition when BPNV = '1', positive tests";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --BPNV bit set to 1
                    command_seq(6) :=(w_scr  ,none   ,2,0,0,0,16#2C#,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(10):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    --BPNV bit is OTP, once set to 1 there isn't way to clear it
                    command_seq(14):=(w_scr  ,err      ,2,0,0,0,16#24#,0,0,valid,0 ns);
                    command_seq(15):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Verify that operation is not accepted
                    command_seq(16):=(rd_sr1 ,rd_wip_0 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Verify that P_ERR bit is set
                    command_seq(18):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Verify that BPNV did not change its value
                    command_seq(20):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --When BPNV is set to a “1” the BP2-0 bits in the Status Register
                    --are volatile and will be reset to binary “111” after hardware
                    --reset or command reset
                    -- Software reset command
                    command_seq(24):=(rst    ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(rd_sr1 ,read_sr1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Changing values of BP bits
                    command_seq(28):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(w_sr   ,none  ,1,0,0,0,16#00#,0,0,valid,0 ns);
                    command_seq(31):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(34):=(rd_sr1 ,read_sr1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Hardware reset
                    command_seq(36):=(h_reset,none     ,0,0,0,0,0,0,0,valid,tRP);
                    command_seq(37):=(wt     ,none      ,0,0,0,0,0,0,0,valid,tRPH);
                    command_seq(38):=(wt     ,none      ,0,0,0,0,0,0,0,valid,100 ns);
                    command_seq(39):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40):=(rd_sr1  ,read_sr1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Checking RESET conditions when BPNV = '1'
                    -- RESET DURING PAGE PROGRAM
                    command_seq(42):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(43):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(44):=(w_sr  ,none      ,1,0,0,0,16#00#,0,0,valid,0 ns);
                    command_seq(45):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(46):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(47):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(48):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(49):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(50):=(rd_sr1 ,read_sr1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(51):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(52):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(53):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(54):=(pg_prog,none  ,5,0,0,0,16#10#,55,16#01#,valid,0 ns);
                    command_seq(55):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(56):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(57):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(58):=(rst   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(59):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(60):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(61):=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(62):=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(63):=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(64):=(w_scr  ,none      ,2,0,0,0,16#002C#,0,0,valid,0 ns);
                    command_seq(65):=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(66):=(rd_sr1 ,rd_wip_1  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(67):=(wt     ,none      ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(68):=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(69):=(rd     ,rd_U    ,1,0,0,0,0,55,16#01#,valid,0 ns);
                    command_seq(70):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(71):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(72):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(73):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(74):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(75):=(w_sr  ,none      ,1,0,0,0,16#00#,0,0,valid,0 ns);
                    command_seq(76):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(77):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(78):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(79):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(80):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(81):=(rd_sr1 ,read_sr1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(82):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- "RESET DURING SECTOR ERASE";
                    command_seq(83) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(84) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(85) :=(sector_erase,none,0,0,0,0,0,54,0,valid,0 ns);
                    command_seq(86) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(87) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(88) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(89) :=(rst   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(90) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(91) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(92) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(93) :=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(94) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(95) :=(w_scr  ,none      ,2,0,0,0,16#002C#,0,0,valid,0 ns);
                    command_seq(96) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(97) :=(rd_sr1 ,rd_wip_1  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(98) :=(wt     ,none      ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(99) :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(100):=(rd     ,rd_U    ,1,0,0,0,0,54,0,valid,0 ns);
                    command_seq(101):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(102):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(103):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(104):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(105):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(106):=(w_sr  ,none      ,1,0,0,0,16#00#,0,0,valid,0 ns);
                    command_seq(107):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(108):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(109):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(110):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(111):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(112):=(rd_sr1 ,read_sr1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(113) :=(done   ,none    ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 35  =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "HARDWARE RESET, positive test";
                    command_seq(1)  :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2)  :=(h_reset,none      ,0,0,0,0,0,0,0,valid,500 ns);
                    command_seq(3)  :=(wt     ,none      ,0,0,0,0,0,0,0,valid, 200 ns);
                    command_seq(4)  :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(5)  :=(wt     ,none      ,0,0,0,0,0,0,0,valid,tRPH);
                    command_seq(6)  :=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7)  :=(rd     ,read      ,5,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8)  :=(idle    ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9)  :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11) :=(w_sr  ,none      ,1,0,0,0,16#00#,0,0,valid,0 ns);
                    command_seq(12) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(16) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17) :=(rd_sr1 ,read_sr1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19) :=(done   ,none      ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "HARDWARE RESET during program, positive test";
                    command_seq(1)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2)  :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4)  :=(pg_prog,none   ,5,0,0,0,16#10#,38,16#01#,violate,0 ns);
                    command_seq(5)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --If next command is assigned while tCS is in progress,
                    --warning is generated
                    command_seq(6)  :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8)  :=(h_reset,none     ,0,0,0,0,0,0,0,valid,tRP);
                    command_seq(9)  :=(wt     ,none      ,0,0,0,0,0,0,0,valid,tRPH);
                    command_seq(10)  :=(wt     ,none      ,0,0,0,0,0,0,0,valid, 200 ns);
                    command_seq(11) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13) :=(rd_sr1  ,rd_wel_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14) :=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15) :=(rd      ,rd_U    ,5,0,0,0,0,38,16#01#,valid,0 ns);
                    command_seq(16) :=(idle    ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17) :=(clr_sr  ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21) :=(w_sr  ,none      ,1,0,0,0,16#00#,0,0,valid,0 ns);
                    command_seq(22) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(26) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27) :=(rd_sr1 ,read_sr1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29) :=(done    ,none    ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 3  => --reset during erase, positive test
                    REPORT "HARDWARE RESET during erase, positive test";
                    command_seq(1)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2)  :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4)  :=(pg_prog,none  ,5,0,0,0,16#10#,36,16#01#,valid,0 ns);
                    command_seq(5)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6)  :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8)  :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(9)  :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10) :=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12) :=(rd     ,read  ,5,0,0,0,16#10#,36,16#01#,valid,0 ns);
                    command_seq(13) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16) :=(sector_erase,none,0,0,0,0,0,36,0,violate,0 ns);
                    command_seq(17) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --If next command is assigned while tCS is in progress,
                    --warning is generated
                    command_seq(18) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20) :=(h_reset,none     ,0,0,0,0,0,0,0,valid,tRP);
                    command_seq(21) :=(wt     ,none      ,0,0,0,0,0,0,0,valid,tRPH);
                    command_seq(22) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24) :=(rd_sr1  ,rd_wel_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25) :=(idle    ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26) :=(rd      ,rd_U    ,5,0,0,0,0,36,16#01#,valid,0 ns);
                    command_seq(27) :=(idle    ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28) :=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32) :=(w_sr  ,none      ,1,0,0,0,16#00#,0,0,valid,0 ns);
                    command_seq(33) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(37) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38) :=(rd_sr1 ,read_sr1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40) :=(done    ,none    ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 4  =>
                    REPORT "HARDWARE RESET during program, negative test";
                    command_seq(1)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2)  :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4)  :=(pg_prog,none   ,5,0,0,0,16#10#,40,16#01#,valid,0 ns);
                    command_seq(5)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6)  :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8)  :=(h_reset,none     ,0,0,0,0,0,0,0,valid,50 ns);
                    command_seq(9)  :=(wt     ,none      ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(10) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11) :=(rd     ,read  ,5,0,0,0,16#10#,40,16#01#,valid,0 ns);
                    command_seq(12) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13) :=(h_reset,none     ,0,0,0,0,0,0,0,valid,tRP);
                    command_seq(14) :=(wt     ,none      ,0,0,0,0,0,0,0,valid,121 ns);
                    --RESET# must return high for greater than tRS before returning low to
                    --initiate hardware reset.
                    --If this condition is not met, warning is generated
                    command_seq(15) :=(h_reset,none     ,0,0,0,0,0,0,0,valid,200 ns);
                    command_seq(16) :=(wt     ,none      ,0,0,0,0,0,0,0,valid,tRPH - 50 ns);
                    command_seq(17) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18) :=(done    ,none    ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 36  =>
                CASE TestCase IS
                WHEN 1=>
                REPORT "BULK ERASE: negative test";
                --sectors are locked
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_sr  ,none      ,2,0,0,0,16#24#,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(8) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(w_sr  ,none      ,1,0,0,0,16#14#,0,0,valid,0 ns);
                    command_seq(14):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(18):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(rd_sr1 ,read_sr1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(bulk_erase,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    --Verify that E_ERR is not set
                    command_seq(26):=(rd_sr1 ,erase_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(rd     ,read  ,4,0,0,0,0,18,16#CC#,valid,0 ns);
                    command_seq(29):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 37  =>
                REPORT "BULK ERASE: positive test";
                    --sectors are unlocked
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_scr  ,none     ,2,0,0,0,16#2C#,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(8) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(w_sr  ,none      ,1,0,0,0,16#00#,0,0,valid,0 ns);
                    command_seq(14):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(18):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(rd_sr1 ,read_sr1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(pg_prog,none  ,20,0,0,0,16#01#,40,0,valid,0 ns);
                    command_seq(24):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(28):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33):=(pg_prog,none  ,20,0,0,0,16#01#,60,0,valid,0 ns);
                    command_seq(34):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(38):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    -- PPB Program command is issued
                    command_seq(41):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(42):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(43):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(44):=(w_ppb  ,none    ,1,0,0,0,0,40,0,valid,0 ns);
                    command_seq(45):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(46):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(47):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(48):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(49):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(50):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(51):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(52):=(ppbacc_rd,read_ppbar,2,0,0,0,0,40,19,valid,0 ns);
                    command_seq(53):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    -- DYB Program command is issued
                    command_seq(54):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(55):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(56):=(w_dyb  ,none    ,1,0,0,0,0,60,0,hold_dat,0 ns);
                    command_seq(57):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(58):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(59):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(60):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(61):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(62):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(63):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(64):=(dybacc_rd,read_dybar,2,0,0,0,0,60,19,valid,0 ns);
                    command_seq(65):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Bulk Erase command is issued
                    command_seq(66):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(67):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(68):=(bulk_erase,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(69):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(70):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(71):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Status Register 2
                    command_seq(72):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(73):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Configuration Register
                    command_seq(74) :=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(75) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Bank Register Read command is not allowed during Bulk Erase
                    command_seq(76):=(bank_rd,rd_HiZ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(77):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(78):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tBE);
                    command_seq(79):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    --Verify that E_ERR is not set
                    command_seq(80):=(rd_sr1 ,erase_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(81):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(82):=(rd     ,read  ,3,0,0,0,0,7,0,valid,0 ns);
                    command_seq(83):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(84):=(rd     ,read  ,3,0,0,0,0,16,0,valid,0 ns);
                    command_seq(85):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Verify that BE command skipped sectors protected by PPB and DYB bits
                    command_seq(86):=(rd     ,read  ,10,0,0,0,0,40,0,valid,0 ns);
                    command_seq(87):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(88):=(rd     ,read  ,10,0,0,0,0,60,0,valid,0 ns);
                    command_seq(89):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(90):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(91):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(92):=(pg_prog,none  ,20,0,0,0,16#01#,0,0,valid,0 ns);
                    command_seq(93):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(94):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(95):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(96):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(97):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(98):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(99):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(100):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(101):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    IF Model(16) = '1' THEN
                        command_seq(102):=(pg_prog4,none ,20,0,0,0,16#01#,127,16#3FFF0#,valid,0 ns);
                        command_seq(103):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSIF Sec_Arch = FALSE THEN
                        command_seq(102):=(pg_prog4,none ,20,0,0,0,16#01#,541,16#FF0#,valid,0 ns);
                        command_seq(103):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        command_seq(102):=(pg_prog4,none ,20,0,0,0,16#01#,541,16#FFF0#,valid,0 ns);
                        command_seq(103):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;
                    command_seq(104):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(105):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(106):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(107):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(108):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(109):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(110):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(111):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(112):=(pg_prog,none  ,20,0,0,0,16#01#,62,0,valid,0 ns);
                    command_seq(113):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(114):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(115):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(116):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(117):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(118):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(119):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(120):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(121):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(122):=(pg_prog,none  ,20,0,0,0,16#01#,61,0,valid,0 ns);
                    command_seq(123):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(124):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(125):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(126):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(127):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(128):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(129):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Setting up DYB[60] to '1'
                    command_seq(130):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(131):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(132):=(w_dyb  ,none    ,1,0,0,0,16#FF#,60,0,valid,0 ns);
                    command_seq(133):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(134):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(135):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(136):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(137):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(138):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(139):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(140):=(dybacc_rd,read_dybar,2,0,0,0,0,60,19,valid,0 ns);
                    command_seq(141):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(142):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

            WHEN 38  =>
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "AUTOBOOT MODE";
                    --ABE(Autoboot Enable) bit set to '1'
                    command_seq(1) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_autoboot,none ,1,0,0,16#0102#,0,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(wt     ,none    ,0,0,0,0,0,0,0,valid,10 ns);
                    command_seq(8) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_sr2 ,read_sr2,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(12):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(autoboot_rd,read_autoboot,1,0,0,0,0,0,0,valid,0 ns);
                    --AUTOBOOT MODE AFTER RESET DURING PROGRAM OPERATION
                    command_seq(16):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(pg_prog,none  ,100,0,0,0,16#01#,35,16#00#,valid,0 ns);
                    command_seq(20):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(rst    ,read  ,10,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(w_scr  ,none     ,2,0,0,0,16#2C#,0,0,valid,0 ns);
                    command_seq(28):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(31):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --AUTOBOOT MODE AFTER RESET IN IDLE STATE
                    command_seq(34):=(rst    ,read  ,10,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38):=(w_scr  ,none     ,2,0,0,0,16#2C#,0,0,valid,0 ns);
                    command_seq(39):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(42):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(43):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "AUTOBOOT MODE AFTER RESET DURING PROGRAM SUSPEND";
                    command_seq(1)  :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2)  :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3)  :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4)  :=(pg_prog,none    ,50,0,0,0,16#01#,34,0,valid,0 ns);
                    command_seq(5)  :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6)  :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7)  :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8)  :=(prg_susp,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9)  :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10) :=(wt     ,none    ,0,0,0,0,0,0,0,valid,tPSL);
                    command_seq(11) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12) :=(rd_sr2 ,rd_ps_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14) :=(rst    ,read    ,10,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18) :=(w_scr  ,none     ,2,0,0,0,16#2C#,0,0,valid,0 ns);
                    command_seq(19) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(22) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25) :=(done   ,none    ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 3  =>
                    REPORT "AUTOBOOT MODE AFTER RESET DURING SECTOR ERASE";
                    command_seq(1)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2)  :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4)  :=(sector_erase,none,0,0,0,0,0,51,0,valid,0 ns);
                    command_seq(5)  :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6)  :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7)  :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8)  :=(rst   ,read  ,10,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9)  :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12) :=(w_scr  ,none     ,2,0,0,0,16#2E#,0,0,valid,0 ns);
                    command_seq(13) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(16) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18) :=(done   ,none    ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 4  =>
                    REPORT "AUTOBOOT MODE AFTER RESET DURING ERASE SUSPEND";
                    command_seq(1)  :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2)  :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3)  :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4)  :=(sector_erase,none,0,0,0,0,0,61,0,valid,0 ns);
                    command_seq(5)  :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6)  :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7)  :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8)  :=(ers_susp,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9)  :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10) :=(wt     ,none    ,0,0,0,0,0,0,0,valid,tESL);
                    command_seq(11) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12) :=(rd_sr2 ,rd_es_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14) :=(rst    ,read    ,10,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18) :=(w_scr  ,none     ,2,0,0,0,16#2C#,0,0,valid,0 ns);
                    command_seq(19) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(22) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27) :=(w_autoboot,none ,1,0,0,16#0207#,0,0,0,valid,0 ns);
                    command_seq(28) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(31) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32) :=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34) :=(autoboot_rd,read_autoboot,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36) :=(done   ,none    ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 5  =>
                    REPORT "AUTOBOOT MODE AFTER RESET DURING ERASE SUSPEND PROGRAM";
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(sector_erase,none,0,0,0,0,0,62,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(ers_susp,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tESL);
                    command_seq(11):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(rd_sr2 ,rd_es_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(pg_prog,none  ,10,0,0,0,16#AA#,60,0,valid,0 ns);
                    command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18) :=(rst    ,none    ,10,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22) :=(w_scr  ,none     ,2,0,0,0,16#2C#,0,0,valid,0 ns);
                    command_seq(23) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25) :=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(26) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31) :=(w_autoboot,none ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(35) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36) :=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38) :=(autoboot_rd,read_autoboot,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(42) :=(pg_prog,none  ,20,0,0,0,16#F0#,2,0,valid,0 ns);
                    command_seq(43) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(44) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(45) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(46) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(47) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(48) :=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(49) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(50) :=(done   ,none      ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

           WHEN 39  =>  --Programming NVDLR/VDLR plus reading VDLR
                CASE Testcase IS
                    WHEN 1  =>
                    REPORT "Programming NVDLR/VDLR,";
                    REPORT "reading VDLR and reading memory data in DLP mode";
                    command_seq(1) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(rd_dlp ,read_dlp ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(w_nvldr,none     ,1,0,0,0,16#44#,0,0,hold_dat,0 ns);
                    command_seq(7) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Read Status Register 2
                    command_seq(10) :=(rd_sr2 ,read_sr2 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Read Configuration Register
                    command_seq(12) :=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Bank Register Read command is not allowed during Programming NVDLR
                    command_seq(14):=(bank_rd,rd_HiZ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tBP);
                    command_seq(17):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(rd_dlp ,read_dlp ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(w_wvdlr,none     ,1,0,0,0,16#55#,0,0,valid,0 ns);
                    command_seq(24):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(rd_sr1 ,read_sr1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(rd_dlp ,read_dlp ,2,0,0,0,0,0,0,valid,0 ns);
                    --After Reset vdlr value becomes nvldr value
                    command_seq(28):=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29):=(h_reset,none      ,0,0,0,0,0,0,0,valid,500 ns);
                    command_seq(30):=(wt     ,none      ,0,0,0,0,0,0,0,valid,tRPH);
                    command_seq(31):=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(rd     ,read      ,5,0,0,0,0,10,0,valid,0 ns);
                    command_seq(33):=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34):=(rd_dlp ,read_dlp  ,2,0,0,0,0,0,0,valid,0 ns);
                    -- 4 Bytes address
                    command_seq(35):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38):=(w_scr  ,none     ,2,0,0,0,16#6C#,0,0,valid,0 ns);
                    command_seq(39):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(42):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(43):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(44):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Fast DDR Read Mode
                    command_seq(45):=(fast_ddr_rd4,read_ddr_fast4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(46):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    --4 Bytes address
                    command_seq(47):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(48):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(49):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(50):=(w_scr  ,none     ,2,0,0,0,16#AC#,0,0,valid,0 ns);
                    command_seq(51):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(52):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(53):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(54):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(55):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(56):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Fast DDR Read Mode
                    command_seq(57):=(fast_ddr_rd4,read_ddr_fast4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(58):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- 4 Bytes address
                    command_seq(59):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(60):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(61):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(62):=(w_scr  ,none     ,2,0,0,0,16#2C#,0,0,valid,0 ns);
                    command_seq(63):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(64):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(65):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(66):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(67):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(68):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Fast DDR Read Mode
                    command_seq(69):=(fast_ddr_rd4,read_ddr_fast4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(70):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- 4 Bytes address
                    command_seq(71):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(72):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(73):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Dual I/O DDR Read Mode
                    command_seq(74):=(dual_high_ddr_rd4,read_ddr_dual_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(75):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(76):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(77):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(78):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(79):=(w_scr  ,none     ,2,0,0,0,16#6C#,0,0,valid,0 ns);
                    command_seq(80):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(81):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(82):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(83):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(84):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(85):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Dual I/O DDR Read Mode
                    command_seq(86):=(dual_high_ddr_rd4,read_ddr_dual_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(87):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(88):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(89):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(90):=(w_scr  ,none     ,2,0,0,0,16#AC#,0,0,valid,0 ns);
                    command_seq(91):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(92):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(93):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(94):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(95):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(96):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Dual I/O DDR Read Mode
                    command_seq(97):=(dual_high_ddr_rd4,read_ddr_dual_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(98):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(99):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(100):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(101):=(w_scr  ,none     ,2,0,0,0,16#EC#,0,0,valid,0 ns);
                    command_seq(102):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(103):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(104):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(105):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(106):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(107):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Dual I/O DDR Read Mode
                    command_seq(108):=(dual_high_ddr_rd4,read_ddr_dual_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(109):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(110):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(111):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(112):=(w_scr  ,none     ,2,0,0,0,16#2E#,0,0,valid,0 ns);
                    command_seq(113):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(114):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(115):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(116):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(117):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(118):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Quad I/O DDR Read Mode
                    command_seq(119):=(quad_high_ddr_rd_4,read_ddr_quad_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(120):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(121):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(122):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(123):=(w_scr  ,none     ,2,0,0,0,16#6E#,0,0,valid,0 ns);
                    command_seq(124):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(125):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(126):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(127):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(128):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(129):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Quad I/O DDR Read Mode
                    command_seq(130):=(quad_high_ddr_rd_4,read_ddr_quad_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(131):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(132):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(133):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(134):=(w_scr  ,none     ,2,0,0,0,16#AE#,0,0,valid,0 ns);
                    command_seq(135):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(136):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(137):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(138):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(139):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(140):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Quad I/O DDR Read Mode
                    command_seq(141):=(quad_high_ddr_rd_4,read_ddr_quad_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(142):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(143):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(144):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(145):=(w_scr  ,none     ,2,0,0,0,16#EE#,0,0,valid,0 ns);
                    command_seq(146):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(147):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(148):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(149):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(150):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(151):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Quad I/O DDR Read Mode
                    command_seq(152):=(quad_high_ddr_rd_4,read_ddr_quad_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(153):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(154):=(done   ,none      ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>
                    REPORT "Reading memory data in DLP mode during pgms suspend";
                    -- 4 Bytes address
                    command_seq(1):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#6C#,0,0,valid,0 ns);
                    command_seq(5):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(8):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(pg_prog,none    ,50,0,0,0,16#99#,60,0,valid,0 ns);
                    command_seq(16):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(prg_susp,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tPSL);
                    command_seq(22):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(rd_sr2 ,rd_ps_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(fast_ddr_rd4,read_ddr_fast4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(26):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(dual_high_ddr_rd4,read_ddr_dual_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(28):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29):=(prg_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(31):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34):=(w_scr  ,none     ,2,0,0,0,16#AC#,0,0,valid,0 ns);
                    command_seq(35):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(38):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(42):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(43):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(44):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(45):=(pg_prog,none    ,50,0,0,0,16#99#,60,0,valid,0 ns);
                    command_seq(46):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(47):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(48):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(49):=(prg_susp,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(50):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(51):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tPSL);
                    command_seq(52):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(53):=(rd_sr2 ,rd_ps_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(54):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(55):=(fast_ddr_rd4,read_ddr_fast4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(56):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(57):=(dual_high_ddr_rd4,read_ddr_dual_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(58):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(59):=(prg_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(60):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(61):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(62):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(63):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(64):=(w_scr  ,none     ,2,0,0,0,16#2C#,0,0,valid,0 ns);
                    command_seq(65):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(66):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(67):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(68):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(69):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(70):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(71):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(72):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(73):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(74):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(75):=(pg_prog,none    ,50,0,0,0,16#99#,60,0,valid,0 ns);
                    command_seq(76):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(77):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(78):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(79):=(prg_susp,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(80):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(81):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tPSL);
                    command_seq(82):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(83):=(rd_sr2 ,rd_ps_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(84):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(85):=(fast_ddr_rd4,read_ddr_fast4,1,0,0,0,0,2,5,valid,0 ns);
                    command_seq(86):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(87):=(dual_high_ddr_rd4,read_ddr_dual_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(88):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(89):=(prg_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(90):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(91):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(92):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(93):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(94):=(w_scr  ,none     ,2,0,0,0,16#EC#,0,0,valid,0 ns);
                    command_seq(95):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(96):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(97):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(98):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(99):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(100):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(101):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(102):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(103):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(104):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(105):=(pg_prog,none    ,50,0,0,0,16#99#,60,0,valid,0 ns);
                    command_seq(106):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(107):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(108):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(109):=(prg_susp,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(110):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(111):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tPSL);
                    command_seq(112):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(113):=(rd_sr2 ,rd_ps_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(114):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(115):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(116):=(dual_high_ddr_rd4,read_ddr_dual_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(117):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(118):=(prg_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(119):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(120):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(121):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(122):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(123):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(124):=(w_scr  ,none     ,2,0,0,0,16#2E#,0,0,valid,0 ns);
                    command_seq(125):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(126):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(127):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(128):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(129):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(130):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(131):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(132):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(133):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(134):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(135):=(pg_prog,none    ,50,0,0,0,16#99#,60,0,valid,0 ns);
                    command_seq(136):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(137):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(138):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(139):=(prg_susp,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(140):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(141):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tPSL);
                    command_seq(142):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(143):=(rd_sr2 ,rd_ps_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(144):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(145):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(146):=(quad_high_ddr_rd_4,read_ddr_quad_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(147):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(148):=(prg_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(149):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(150):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(151):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(152):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(153):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(154):=(w_scr  ,none     ,2,0,0,0,16#6E#,0,0,valid,0 ns);
                    command_seq(155):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(156):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(157):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(158):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(159):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(160):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(161):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(162):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(163):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(164):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(165):=(pg_prog,none    ,50,0,0,0,16#99#,60,0,valid,0 ns);
                    command_seq(166):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(167):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(168):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(169):=(prg_susp,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(170):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(171):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tPSL);
                    command_seq(172):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(173):=(rd_sr2 ,rd_ps_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(174):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(175):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(176):=(quad_high_ddr_rd_4,read_ddr_quad_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(177):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(178):=(prg_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(179):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(180):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(181):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(182):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(183):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(184):=(w_scr  ,none     ,2,0,0,0,16#AE#,0,0,valid,0 ns);
                    command_seq(185):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(186):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(187):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(188):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(189):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(190):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(191):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(192):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(193):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(194):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(195):=(pg_prog,none    ,50,0,0,0,16#99#,60,0,valid,0 ns);
                    command_seq(196):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(197):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(198):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(199):=(prg_susp,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(200):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(201):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tPSL);
                    command_seq(202):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(203):=(rd_sr2 ,rd_ps_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(204):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(205):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(206):=(quad_high_ddr_rd_4,read_ddr_quad_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(207):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(208):=(prg_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(209):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(210):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(211):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(212):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(213):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(214):=(w_scr  ,none     ,2,0,0,0,16#EE#,0,0,valid,0 ns);
                    command_seq(215):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(216):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(217):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(218):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(219):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(220):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(221):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(222):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(223):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(224):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(225):=(pg_prog,none    ,50,0,0,0,16#99#,60,0,valid,0 ns);
                    command_seq(226):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(227):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(228):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(229):=(prg_susp,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(230):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(231):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tPSL);
                    command_seq(232):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(233):=(rd_sr2 ,rd_ps_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(234):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(235):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(236):=(quad_high_ddr_rd_4,read_ddr_quad_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(237):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(238):=(prg_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(239):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(240):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(241):=(done   ,none      ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 3  =>
                    REPORT "Reading memory data in DLP mode during ers suspend";
                    -- 4 Bytes address
                    command_seq(1):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4):=(w_scr  ,none     ,2,0,0,0,16#6C#,0,0,valid,0 ns);
                    command_seq(5):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(8):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(sector_erase,none,0,0,0,0,0,17,0,valid,0 ns);
                    command_seq(16):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(ers_susp,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tESL);
                    command_seq(22):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(rd_sr2 ,rd_es_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(fast_ddr_rd4,read_ddr_fast4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(26):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(dual_high_ddr_rd4,read_ddr_dual_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(28):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29):=(ers_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tSE);
                    command_seq(32):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35):=(w_scr  ,none     ,2,0,0,0,16#AC#,0,0,valid,0 ns);
                    command_seq(36):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(39):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(42):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(43):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(44):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(45):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(46):=(sector_erase,none,0,0,0,0,16#99#,60,0,valid,0 ns);
                    command_seq(47):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(48):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(49):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(50):=(ers_susp,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(51):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(52):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tESL);
                    command_seq(53):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(54):=(rd_sr2 ,rd_es_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(55):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(56):=(fast_ddr_rd4,read_ddr_fast4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(57):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(58):=(dual_high_ddr_rd4,read_ddr_dual_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(59):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(60):=(ers_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(61):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tSE);
                    command_seq(62):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(63):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(64):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(65):=(w_scr  ,none     ,2,0,0,0,16#2C#,0,0,valid,0 ns);
                    command_seq(66):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(67):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(68):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(69):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(70):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(71):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(72):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(73):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(74):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(75):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(76):=(sector_erase,none,0,0,0,0,16#99#,60,0,valid,0 ns);
                    command_seq(77):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(78):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(79):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(80):=(ers_susp,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(81):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(82):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tESL);
                    command_seq(83):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(84):=(rd_sr2 ,rd_es_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(85):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(86):=(fast_ddr_rd4,read_ddr_fast4,1,0,0,0,0,2,5,valid,0 ns);
                    command_seq(87):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(88):=(dual_high_ddr_rd4,read_ddr_dual_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(89):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(90):=(ers_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(91):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tSE);
                    command_seq(92):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(93):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(94):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(95):=(w_scr  ,none     ,2,0,0,0,16#EC#,0,0,valid,0 ns);
                    command_seq(96):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(97):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(98):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(99):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(100):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(101):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(102):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(103):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(104):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(105):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(106):=(sector_erase,none,0,0,0,0,16#99#,60,0,valid,0 ns);
                    command_seq(107):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(108):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(109):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(110):=(ers_susp,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(111):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(112):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tESL);
                    command_seq(113):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(114):=(rd_sr2 ,rd_es_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(115):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(116):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(117):=(dual_high_ddr_rd4,read_ddr_dual_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(118):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(119):=(ers_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(120):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tSE);
                    command_seq(121):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(122):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(123):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(124):=(w_scr  ,none     ,2,0,0,0,16#2E#,0,0,valid,0 ns);
                    command_seq(125):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(126):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(127):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(128):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(129):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(130):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(131):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(132):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(133):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(134):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(135):=(sector_erase,none,0,0,0,0,16#99#,60,0,valid,0 ns);
                    command_seq(136):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(137):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(138):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(139):=(ers_susp,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(140):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(141):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tESL);
                    command_seq(142):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(143):=(rd_sr2 ,rd_es_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(144):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(145):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(146):=(quad_high_ddr_rd_4,read_ddr_quad_hi4,1,0,0,0,0,2,5,valid,0 ns);
                    command_seq(147):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(148):=(ers_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(149):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tSE);
                    command_seq(150):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(151):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(152):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(153):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(154):=(w_scr  ,none     ,2,0,0,0,16#6E#,0,0,valid,0 ns);
                    command_seq(155):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(156):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(157):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(158):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(159):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(160):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(161):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(162):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(163):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(164):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(165):=(sector_erase,none,0,0,0,0,16#99#,60,0,valid,0 ns);
                    command_seq(166):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(167):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(168):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(169):=(ers_susp,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(170):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(171):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tESL);
                    command_seq(172):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(173):=(rd_sr2 ,rd_es_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(174):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(175):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(176):=(quad_high_ddr_rd_4,read_ddr_quad_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(177):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(178):=(ers_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(179):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tSE);
                    command_seq(180):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(181):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(182):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(183):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(184):=(w_scr  ,none     ,2,0,0,0,16#AE#,0,0,valid,0 ns);
                    command_seq(185):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(186):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(187):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(188):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(189):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(190):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(191):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(192):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(193):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(194):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(195):=(sector_erase,none,0,0,0,0,16#99#,60,0,valid,0 ns);
                    command_seq(196):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(197):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(198):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(199):=(ers_susp,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(200):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(201):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tESL);
                    command_seq(202):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(203):=(rd_sr2 ,rd_es_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(204):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(205):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(206):=(quad_high_ddr_rd_4,read_ddr_quad_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(207):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(208):=(ers_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(209):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tSE);
                    command_seq(210):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(211):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(212):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(213):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(214):=(w_scr  ,none     ,2,0,0,0,16#EE#,0,0,valid,0 ns);
                    command_seq(215):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(216):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(217):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(218):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(219):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(220):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(221):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(222):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(223):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(224):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(225):=(sector_erase,none,0,0,0,0,16#99#,60,0,valid,0 ns);
                    command_seq(226):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(227):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(228):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(229):=(ers_susp,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(230):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(231):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tESL);
                    command_seq(232):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(233):=(rd_sr2 ,rd_es_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(234):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(235):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(236):=(quad_high_ddr_rd_4,read_ddr_quad_hi4,3,0,0,0,0,2,5,valid,0 ns);
                    command_seq(237):=(idle    ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(238):=(ers_resume,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(239):=(wt     ,none    ,0,0,0,0,0,0,0,valid,tSE);
                    command_seq(240):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(241):=(done   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 40  =>
                REPORT "RESET DURING BULK ERASE";
                CASE Testcase IS
                    WHEN 1  =>
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(pg_prog,none  ,15,0,0,0,16#BF#,10,16#01#,valid,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(9) :=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(rd     ,read  ,5,0,0,0,0,10,16#01#,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(pg_prog,none  ,10,0,0,0,16#AB#,20,16#01#,valid,0 ns);
                    command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(21):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(rd_sr1  ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(rd     ,read  ,5,0,0,0,0,20,16#01#,valid,0 ns);
                    command_seq(25):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(w_sr  ,none      ,1,0,0,0,16#00#,0,0,valid,0 ns);
                    command_seq(29):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(wt     ,none     ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(33):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34):=(rd_sr1 ,read_sr1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36):=(w_enable,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38):=(bulk_erase,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(40):=(rd_sr1 ,rd_wip_1 ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(42):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(43):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(44):=(rst   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(45):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(46):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(47):=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(48):=(w_enable,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(49):=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(50):=(w_scr  ,none      ,2,0,0,0,16#2C#,0,0,valid,0 ns);
                    command_seq(51):=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(52):=(rd_sr1 ,rd_wip_1  ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(53):=(wt     ,none      ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(54):=(idle   ,none      ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(55):=(rd     ,rd_U    ,5,0,0,0,0,10,16#01#,valid,0 ns);
                    command_seq(56):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(57):=(rd     ,rd_U    ,5,0,0,0,0,20,16#01#,valid,0 ns);
                    command_seq(58):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(59):=(rd     ,rd_U    ,5,0,0,0,0,30,16#10#,valid,0 ns);
                    command_seq(60):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(61):=(rd     ,rd_U    ,5,0,0,0,0,42,16#10#,valid,0 ns);
                    command_seq(62):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(63):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(64):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(65):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 41  =>
                CASE Testcase IS

                    WHEN 1  =>
                    REPORT "WRITE STATUS negative test";
                    --Status Register can not be altered while SRWD = '1'
                    --and WP# = '0'
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_sr   ,none  ,1,0,0,0,16#80#,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(8) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Verify that SRWD bit is set
                    command_seq(10):=(rd_sr1 ,read_sr1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    -- SRWD = '1', asserts WP# low
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,violate,0 ns);
                    command_seq(14):=(w_sr   ,none  ,1,0,0,0,16#7F#,0,0,valid,0 ns);
                    command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,violate,0 ns);
                    -- Verify that WEL = '0'
                    command_seq(16):=(rd_sr1 ,rd_wel_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Verify that WRSR command is ignored
                    command_seq(18):=(rd_sr1 ,read_sr1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 2  =>--FREEZE bit setting
                    REPORT "FREEZE bit, positive tests";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --FREEZE bit set to 1
                    command_seq(6) :=(w_scr  ,none   ,2,0,0,0,16#2D#,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(10):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    --freeze bit cannot be cleared to 0 until a hardware-reset
                    command_seq(12):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(w_scr  ,none  ,0,0,0,0,16#2C#,0,0,valid,0 ns);
                    command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(18):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    --Verify that Configuration register didn't change its value
                    command_seq(19):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --freeze bit set to 1 locks the BP2-0 in Status Register
                    --BP0 = 1, BP1 = 1, BP2 = 0
                    command_seq(23):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(w_sr   ,none  ,1,0,0,0,16#0C#,0,0,valid,0 ns);
                    command_seq(26):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(29):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31):=(rd_sr1 ,read_sr1,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Hardware reset resets Freeze bit
                    command_seq(33):=(h_reset,none     ,0,0,0,0,0,0,0,valid,tRP);
                    command_seq(34):=(wt     ,none      ,0,0,0,0,0,0,0,valid,tRPH);
                    command_seq(35):=(wt     ,none      ,0,0,0,0,0,0,0,valid,100 ns);
                    command_seq(36):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37):=(rd_scr  ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN 3  =>--FREEZE bit setting
                    REPORT "FREEZE bit, positive tests";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --FREEZE bit set to 1
                    command_seq(6) :=(w_scr  ,none   ,2,0,0,0,16#2D#,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(10):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    --freeze bit cannot be cleared to 0 until a hardware-reset
                    command_seq(12):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(w_scr  ,none  ,0,0,0,0,16#2C#,0,0,valid,0 ns);
                    command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16) :=(rd_sr1  ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(17) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(18):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    --Verify that Configuration register didn't change its value
                    command_seq(19):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --The configuration register FREEZE (CR1[0]) bit protects
                    --the entire OTP memory space from programming when set to “1”.
                    command_seq(23):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(otp_read ,read_otp ,5,0,0,0,0,0,16#0B0#,valid,0 ns);
                    command_seq(26):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29):=(otp_prog,none ,5,0,0,0,16#AA#,0,16#0B0#,valid,0 ns);
                    command_seq(30):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Verify that operation is rejected
                    command_seq(31):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    --Verify that P_ERR bit is set to '1'
                    command_seq(32):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34):=(otp_read ,read_otp ,5,0,0,0,0,0,16#0B0#,valid,0 ns);
                    command_seq(35):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Software reset command does not affect Freeze bit
                    command_seq(36):=(rst   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38):=(rd_scr  ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Hardware reset resets Freeze bit
                    command_seq(40):=(h_reset,none     ,0,0,0,0,0,0,0,valid,tRP);
                    command_seq(41):=(wt     ,none      ,0,0,0,0,0,0,0,valid,tRPH);
                    command_seq(42):=(wt     ,none      ,0,0,0,0,0,0,0,valid,100 ns);
                    command_seq(43):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(44):=(rd_scr  ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(45):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(46):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                     WHEN 4  =>--LOCK bit setting
                     REPORT "LOCK bit, positive tests";
                         --cmd, sts, byte_num, data, sect, addr, aux_t, time
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --LOCK bit set to 1
                    command_seq(4) :=(w_scr   ,none ,0,0,0,0,16#3C#,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(8) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    --LOCK bit is OTP, once set to 1 there isn't way to clear it
                    command_seq(10):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(w_scr  ,none  ,0,0,0,0,16#2C#,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tW);
                    command_seq(16):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    --Verify that Configuration register didn't change its value
                    command_seq(17):=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                     --LOCK bit set to 1 permanently locks the BP2-0 in the Status Register
                     command_seq(21):=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                     command_seq(22):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                     command_seq(23):=(w_sr   ,none  ,1,0,0,0,16#18#,0,0,valid,0 ns);
                     command_seq(24):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                     command_seq(25):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                     command_seq(26):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tW);
                     command_seq(27):=(rd_sr1 ,read_sr1,1,0,0,0,0,0,0,valid,0 ns);
                     command_seq(28):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                     command_seq(29):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 42 => -- Persistent protection mode
                CASE TestCase IS
                WHEN 1 =>
                REPORT " Enter Persistent Protection mode-PPB Lock is set"&
                       " after reset";
                     command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                     command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                     command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                     -- enter Persistent Protection mode
                    command_seq(4) :=(w_asp  ,none   ,1,0,0,0,16#FEDD#,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(wt     ,none   ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(8) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(asp_reg_rd,read_asp,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(idle   ,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    --Setting up PPB Lock bit to value '0;
                    command_seq(16):=(w_ppbl_reg,none ,1,0,0,0,16#F0#,0,0,valid,0 ns);
                    command_seq(17):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Status Register 2
                    command_seq(20):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(21):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Read Configuration Register
                    command_seq(22) :=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    --Bank Register Read command is not allowed during Page Program
                    command_seq(24):=(bank_rd,rd_HiZ,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(25):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(27):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(31):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    -- reset device
                    command_seq(32):=(h_reset,none   ,0,0,0,0,0,0,0,valid,250 ns);
                    command_seq(33):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(34):=(wt     ,none      ,0,0,0,0,0,0,0,valid,tRPH);
                    command_seq(35):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- confirm PPB Lock bit is set
                    command_seq(36):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(38):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,clock_num,0 ns);
                    command_seq(40):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(41):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 43 => -- password positive tests
                CASE Testcase IS
                WHEN 1 =>
                REPORT " POSITIVE Password program: program and verify " ;
                    command_seq(1) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_password,none,1,16#FFFF#,0,16#9999#,16#FFFF#,0,0, valid,0 ns);
                    command_seq(5) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(9) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(pass_reg_rd,read_pass_reg,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                WHEN 2 =>
                REPORT " Enter Password Protection mode- PPB Lock is cleared"&
                       " after reset";
                    command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    -- enter Password Protection mode
                    command_seq(4) :=(w_asp  ,none   ,1,0,0,0,16#FEDB#,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(wt     ,none   ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(8) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(idle   ,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(11):=(asp_reg_rd,read_asp,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(idle   ,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    -- reset device
                    command_seq(13):=(h_reset,none   ,0,0,0,0,0,0,0,valid,250 ns);
                    command_seq(14):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(wt     ,none      ,0,0,0,0,0,0,0,valid,tRPH);
                    command_seq(16):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                    -- confirm PPB Lock bit is cleared
                    command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,clock_num,0 ns);
                    command_seq(21):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                WHEN 3 =>
                REPORT "Password Unlock command sequence";
                    command_seq(1) :=(idle   ,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    -- confirm PPB lock bit is cleared
                    command_seq(2) :=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(wt     ,none   ,0,0,0,0,0,0,0,valid,100 ns);
                    -- initiate password unlock sequence
                    command_seq(5) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(psw_unlock,none,0,16#FFFF#,0,16#9999#,16#FFFF#,0,0,valid,0 ns);
                    command_seq(8) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    --Read Status Register 2
                    command_seq(10):=(rd_sr2 ,read_sr2,1,0,0,0,0,0,0,valid,0 ns);
                    --Read Configuration Register
                    command_seq(11) :=(rd_scr ,read_config,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(13):=(wt     ,none   ,0,0,0,0,0,0,0,valid,tPULCK);
                    command_seq(14):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    -- confirm PPB lock bit is set
                    command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,clock_num,0 ns);
                    command_seq(21):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    -- Initiate PLBWR command to clear PPB Lock bit
                    command_seq(22):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(24):=(w_ppbl_reg,none ,1,0,0,0,16#F0#,0,0,valid,0 ns);
                    command_seq(25):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(26):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(27):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(28):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(29):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(30):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                    command_seq(31):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(32):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(33):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    -- confirm PPB Lock bit is cleared
                    command_seq(34):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(35):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(36):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(37):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,clock_num,0 ns);
                    command_seq(38):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(39):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 44 => -- password negative tests
                CASE Testcase IS
                WHEN 1 =>
                REPORT " NEGATIVE Password read and program"&
                       " if Password protection set ";
                    command_seq(1) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(2) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(w_password,none ,1,0,0,0,16#FFFF#,0,0,valid,0 ns);
                    command_seq(5) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(6) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    -- After the Password Protection Mode is selected,
                    -- the PASSRD command is ignored.
                    command_seq(8) :=(pass_reg_rd,none,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                WHEN 2 =>
                REPORT " NEGATIVE Password unlock: wrong password entered ";
                    command_seq(1) :=(idle   ,none   ,0,0,0,0,0,0,0,valid,0 ns);
                    -- confirm PPB lock bit is cleared
                    command_seq(2) :=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(4) :=(wt     ,none   ,0,0,0,0,0,0,0,valid,100 ns);
                    -- initiate password unlock sequence
                    command_seq(5) :=(psw_unlock,err,0,0,0,0,16#FFFF#,0,0,valid,0 ns);
                    command_seq(6) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(7) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(8) :=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(9) :=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(10):=(wt     ,none   ,0,0,0,0,0,0,0,valid,tPULCK);
                    --If the PASSU command supplied password does not match the hidden
                    --password in the Password Register,an error is reported by setting
                    --the P_ERR bit to 1. The WIP bit also remains set to 1.
                    command_seq(11):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(12):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    -- confirm PPB lock bit is still cleared
                    command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(14):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,valid,0 ns);
                    command_seq(15):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(16):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,clock_num,0 ns);
                    command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(18):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(19):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(20):=(wt     ,none   ,0,0,0,0,0,0,0,valid,tPACC);
                    -- The model is ready to accept a new password command
                    command_seq(21):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                    command_seq(22):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    command_seq(23):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN 45 => -- read password mode positive tests
                CASE Testcase IS
                WHEN 1 =>
                REPORT " POSITIVE Password program: program and verify " ;
                    IF(Model(15) = 'Z' OR Model(15) = 'S' OR Model(15) = 'T' OR
                       Model(15) = 'K' OR Model(15) = 'L' OR Model(15) = 'Y') THEN
                        command_seq(1) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(2) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(3) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(4) :=(w_password,none,1,16#A00A#,16#F00F#,16#9966#,16#3CC3#,0,0, valid,0 ns);
                        command_seq(5) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(6) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(7) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(8) :=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(9) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(10):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(11):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(12):=(pass_reg_rd,read_pass_reg,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    ELSE
                        REPORT " ***WARNING***: Read Password Protection mode is not"&
                               " supported for selected OPN";
                    END IF;

                WHEN 2 =>
                REPORT " Enter Read Password Protection mode- PPB Lock is cleared"&
                       " after reset";
                    IF(Model(15) = 'Z' OR Model(15) = 'S' OR Model(15) = 'T' OR
                       Model(15) = 'K' OR Model(15) = 'L' OR Model(15) = 'Y') THEN
                        command_seq(1) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(2) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        -- enter Read Password Protection mode
                        command_seq(4) :=(w_asp  ,none   ,1,0,0,0,16#FEDB#,0,0,valid,0 ns);
                        command_seq(5) :=(idle   ,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(6) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(7) :=(wt     ,none   ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(8) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(9) :=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(10):=(idle   ,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(11):=(asp_reg_rd,read_asp,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(12):=(idle   ,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        -- reset device
                        command_seq(13):=(h_reset,none   ,0,0,0,0,0,0,0,valid,250 ns);
                        command_seq(14):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(15):=(wt     ,none      ,0,0,0,0,0,0,0,valid,tRPH);
                        command_seq(16):=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        -- confirm PPB Lock bit is cleared
                        command_seq(17):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(18):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,valid,0 ns);
                        command_seq(19):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(20):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,clock_num,0 ns);
                        command_seq(21):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --programming is not allowed in Read Password Mode
                        command_seq(22):=(w_enable,err   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(23):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(24):=(pg_prog,err    ,5,0,0,0,16#99#,0,2,valid,0 ns);
                        command_seq(25):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(26):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(27):=(rd_sr1 ,rd_wel_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(28):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        -- read within sector 37 returns data from zero sector,
                        -- because TBPROT = '0'
                        command_seq(29):=(rd     ,read  ,5,0,0,0,0,37,2,valid,0 ns);
                        command_seq(30):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Reading the OTP, DYB, and PPB address space returns undefined data
                        command_seq(31):=(dybacc_rd,rd_U,2,0,0,0,0,1,19,valid,0 ns);
                        command_seq(32):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(33):=(otp_read,rd_U ,3,0,0,0,0,0,16#020#,valid,0 ns);
                        command_seq(34):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(35):=(ppbacc_rd,rd_U,2,0,0,0,0,37,19,valid,0 ns);
                        command_seq(36):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(37):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;

                WHEN 3 =>
                REPORT "Password Unlock command sequence";
                    IF(Model(15) = 'Z' OR Model(15) = 'S' OR Model(15) = 'T' OR
                       Model(15) = 'K' OR Model(15) = 'L' OR Model(15) = 'Y') THEN
                        command_seq(1) :=(idle   ,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        -- confirm PPB lock bit is cleared
                        command_seq(2) :=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,valid,0 ns);
                        command_seq(3) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(4) :=(wt     ,none   ,0,0,0,0,0,0,0,valid,100 ns);
                        -- initiate password unlock sequence
                        command_seq(5) :=(w_enable,none ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(6) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(7) :=(psw_unlock,none,0,16#A00A#,16#F00F#,16#9966#,16#3CC3#,0,0,valid,0 ns);
                        command_seq(8) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(9) :=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(10):=(wt     ,none   ,0,0,0,0,0,0,0,valid,tPULCK);
                        -- Exit Read Password Mode
                        command_seq(11):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(12):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(13):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        -- programming is allowed
                        -- because no more Read Password Mode
                        command_seq(14):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(15):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(16):=(pg_prog,none    ,5,0,0,0,16#99#,0,2,valid,0 ns);
                        command_seq(17):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(18):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(19):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(20):=(wt     ,none  ,0,0,0,0,0,0,0,valid,tPP);
                        command_seq(21):=(rd_sr1  ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(22):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        -- read within sector 37 returns real data from 37 sector,
                        -- because no more Read Password Mode
                        command_seq(23):=(rd     ,read  ,5,0,0,0,0,37,2,valid,0 ns);
                        command_seq(24):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Reading the OTP, DYB, and PPB address space returns real data
                        command_seq(25):=(dybacc_rd,read_dybar,2,0,0,0,0,1,19,valid,0 ns);
                        command_seq(26):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(27):=(otp_read,read_otp ,3,0,0,0,0,0,16#020#,valid,0 ns);
                        command_seq(28):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(29):=(ppbacc_rd,read_ppbar,2,0,0,0,0,57,19,valid,0 ns);
                        command_seq(30):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(31):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        -- confirm PPB lock bit is set
                        command_seq(32):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(33):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,valid,0 ns);
                        command_seq(34):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(35):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,clock_num,0 ns);
                        command_seq(36):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Initiate PLBWR command to clear PPB Lock bit
                        -- PLBWR command has undefined results if sent when Read Password
                        -- Protection Mode is in use. The PPB Lock bit may only be returned
                        -- to "0" by a hardware reset or POR.
                        command_seq(37):=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(38):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(39):=(w_ppbl_reg,err ,1,0,0,0,16#F0#,0,0,valid,0 ns);
                        command_seq(40):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        --Verify that command is rejected
                        command_seq(41):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(42):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        -- Verify that PPB Lock bit still has previous value
                        command_seq(43):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(44):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,valid,0 ns);
                        command_seq(45):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(46):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,clock_num,0 ns);
                        command_seq(47):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(48):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;

                WHEN 4 =>
                REPORT " NEGATIVE Password read and program"&
                       " if Password protection set ";
                    IF(Model(15) = 'Z' OR Model(15) = 'S' OR Model(15) = 'T' OR
                       Model(15) = 'K' OR Model(15) = 'L' OR Model(15) = 'Y') THEN
                        command_seq(1) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(2) :=(w_enable,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(3) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(4) :=(w_password,err ,1,0,0,0,16#FFFF#,0,0,valid,0 ns);
                        command_seq(5) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(6) :=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(7) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        -- After the Password Protection Mode is selected,
                        -- the PASSRD command is ignored.
                        command_seq(8) :=(pass_reg_rd,none,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(9) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;

                WHEN 5 =>
                REPORT " NEGATIVE Password unlock: wrong password entered ";
                    IF(Model(15) = 'Z' OR Model(15) = 'S' OR Model(15) = 'T' OR
                       Model(15) = 'K' OR Model(15) = 'L' OR Model(15) = 'Y') THEN
                        command_seq(1) :=(idle   ,none   ,0,0,0,0,0,0,0,valid,0 ns);
                        --Initiate Hardware Reset to clear PPB Lock bit
                        command_seq(2) :=(h_reset,none   ,0,0,0,0,0,0,0,valid,250 ns);
                        command_seq(3) :=(idle   ,none     ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(4) :=(wt     ,none      ,0,0,0,0,0,0,0,valid,tRPH);
                        -- confirm PPB lock bit is cleared
                        command_seq(5) :=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,valid,0 ns);
                        command_seq(6) :=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(7) :=(wt     ,none   ,0,0,0,0,0,0,0,valid,100 ns);
                        -- initiate password unlock sequence
                        command_seq(8) :=(psw_unlock,err,0,0,0,0,16#FFFF#,0,0,valid,0 ns);
                        command_seq(9) :=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(10):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(11):=(rd_sr2 ,read_sr2,2,0,0,0,0,0,0,valid,0 ns);
                        command_seq(12):=(rd_scr ,read_config,2,0,0,0,0,0,0,valid,0 ns);
                        command_seq(13):=(wt     ,none   ,0,0,0,0,0,0,0,valid,tPULCK);
                        --Verify that WIP bit remains set
                        command_seq(14):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        --Verify that P_ERR bit is set
                        command_seq(15):=(rd_sr1 ,pgm_nosucc,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(16):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(17):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(18):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        -- confirm PPB lock bit is still "0"
                        command_seq(19):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(20):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,valid,0 ns);
                        command_seq(21):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(22):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,clock_num,0 ns);
                        command_seq(23):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        --Another PASSU command is issued with correct password
                        command_seq(24):=(psw_unlock,err,0,16#A00A#,16#F00F#,16#9966#,16#3CC3#,0,0,valid,0 ns);
                        command_seq(25):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        --The PASSU command cannot be accepted any faster than once every 100us
                        --Verify that command is rejected and WIP is still "1"
                        command_seq(26):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(27):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        -- confirm PPB lock bit is still "0"
                        command_seq(28):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,valid,0 ns);
                        command_seq(29):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(30):=(clr_sr  ,none,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(31):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(32):=(wt     ,none   ,0,0,0,0,0,0,0,valid,tPACC);
                        -- The model is ready to accept a new password command
                        command_seq(33):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(34):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        -- initiate password unlock sequence
                        command_seq(35):=(psw_unlock,none,0,16#A00A#,16#F00F#,16#9966#,16#3CC3#,0,0,valid,0 ns);
                        command_seq(36):=(idle   ,none    ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(37):=(rd_sr1 ,rd_wip_1,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(38):=(wt     ,none   ,0,0,0,0,0,0,0,valid,tPULCK);
                        -- Exit Read Password Mode
                        command_seq(39):=(rd_sr1 ,rd_wip_0,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(40):=(rd_sr1 ,pgm_succ,1,0,0,0,0,0,0,valid,0 ns);
                        command_seq(41):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        -- confirm PPB lock bit is set
                        command_seq(42):=(ppbl_reg_rd,read_ppbl,2,0,0,0,0,0,0,valid,0 ns);
                        command_seq(43):=(idle   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                        command_seq(44):=(done   ,none  ,0,0,0,0,0,0,0,valid,0 ns);
                    END IF;

                    WHEN OTHERS => NULL;
                END CASE;

            WHEN OTHERS =>
        END CASE;

        REPORT "------------------------------------------------------";
    END PROCEDURE Generate_TC;
    ---------------------------------------------------------------------------
    --PUBLIC
    -- CHECKER PROCEDURES
    ---------------------------------------------------------------------------
----Check read from memory
    PROCEDURE   Check_read (
        DQ       :  IN std_logic_vector(7 downto 0);
        DQ_reg0  :  IN std_logic_vector(7 downto 0);
        DQ_reg1  :  IN std_logic_vector(7 downto 0);
        DQ_reg2  :  IN std_logic_vector(7 downto 0);
        DQ_reg3  :  IN std_logic_vector(7 downto 0);
        D_mem    :  IN NATURAL;
        DLP_reg  :  IN NATURAL;
        D_dlp_act:  IN std_logic_vector(1 downto 0);
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        IF D_dlp_act = "01" THEN
            ASSERT to_nat(DQ_reg0) = DLP_reg
                REPORT "Read DLP Register: expected data = " &
                to_int_str(DLP_reg) & " got " & to_int_str(DQ_reg0)
                SEVERITY error;
            ASSERT to_nat(DQ_reg0) /= DLP_reg
                REPORT "Read DLP Register: OK - "& to_int_str(DQ_reg0)
                SEVERITY note;
        END IF;

        IF D_dlp_act = "10" THEN
            ASSERT to_nat(DQ_reg0) = DLP_reg
                REPORT "Read DLP Register: expected data = " &
                to_int_str(DLP_reg) & " got " & to_int_str(DQ_reg0)
                SEVERITY error;
            ASSERT to_nat(DQ_reg0) /= DLP_reg
                REPORT "Read DLP Register: OK - "& to_int_str(DQ_reg0)
                SEVERITY note;
            ASSERT to_nat(DQ_reg1) = DLP_reg
                REPORT "Read DLP Register: expected data = " &
                to_int_str(DLP_reg) & " got " & to_int_str(DQ_reg1)
                SEVERITY error;
            ASSERT to_nat(DQ_reg1) /= DLP_reg
                REPORT "Read DLP Register: OK - "& to_int_str(DQ_reg1)
                SEVERITY note;

        END IF;

        IF D_dlp_act = "11" THEN
            ASSERT to_nat(DQ_reg0) = DLP_reg
                REPORT "Read DLP Register: expected data = " &
                to_int_str(DLP_reg) & " got " & to_int_str(DQ_reg0)
                SEVERITY error;
            ASSERT to_nat(DQ_reg0) /= DLP_reg
                REPORT "Read DLP Register: OK - "& to_int_str(DQ_reg0)
                SEVERITY note;
            ASSERT to_nat(DQ_reg1) = DLP_reg
                REPORT "Read DLP Register: expected data = " &
                to_int_str(DLP_reg) & " got " & to_int_str(DQ_reg1)
                SEVERITY error;
            ASSERT to_nat(DQ_reg1) /= DLP_reg
                REPORT "Read DLP Register: OK - "& to_int_str(DQ_reg1)
                SEVERITY note;
            ASSERT to_nat(DQ_reg2) = DLP_reg
                REPORT "Read DLP Register: expected data = " &
                to_int_str(DLP_reg) & " got " & to_int_str(DQ_reg2)
                SEVERITY error;
            ASSERT to_nat(DQ_reg2) /= DLP_reg
                REPORT "Read DLP Register: OK - "& to_int_str(DQ_reg2)
                SEVERITY note;
            ASSERT to_nat(DQ_reg3) = DLP_reg
                REPORT "Read DLP Register: expected data = " &
                to_int_str(DLP_reg) & " got " & to_int_str(DQ_reg3)
                SEVERITY error;
            ASSERT to_nat(DQ_reg3) /= DLP_reg
                REPORT "Read DLP Register: OK - "& to_int_str(DQ_reg3)
                SEVERITY note;
        END IF;

        ASSERT to_nat(DQ) = D_mem
            REPORT "READ: expected data  =" &
            to_int_str(D_mem)&" got " &
            to_int_str(DQ)
            SEVERITY error;

        ASSERT to_nat(DQ)/=D_mem
            REPORT "READ: OK - "&
            to_int_str(DQ)
            SEVERITY note;

        IF to_nat(DQ)/=D_mem THEN
            check_err <= '1';
        ELSIF (D_dlp_act = "01") THEN
            IF (to_nat(DQ_reg0)/=DLP_reg) THEN
                check_err <= '1';
            END IF;
        ELSIF (D_dlp_act = "10") THEN
            IF (to_nat(DQ_reg1)/=DLP_reg OR to_nat(DQ_reg0)/=DLP_reg) THEN
                check_err <= '1';
            END IF;
        ELSIF (D_dlp_act = "11") THEN
            IF (to_nat(DQ_reg3)/=DLP_reg OR to_nat(DQ_reg2)/=DLP_reg
            OR to_nat(DQ_reg1)/=DLP_reg OR to_nat(DQ_reg0)/=DLP_reg) THEN
                check_err <= '1';
            END IF;

        ELSE
            check_err <= '0';
        END IF;
    END PROCEDURE Check_read;

----Check tristated output
    PROCEDURE   Check_Z (
        DQ   :  IN std_logic;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        ASSERT DQ = 'Z'
            REPORT "output should be HiZ"
            SEVERITY error;

        IF DQ /= 'Z' THEN
            check_err <= '1';
        ELSE
            check_err <= '0';
        END IF;

        ASSERT DQ /= 'Z'
            REPORT "Read OK - output HiZ"
            SEVERITY note;
    END PROCEDURE Check_Z;

----Check unknown
    PROCEDURE   Check_X (
        DQ   :  IN std_logic;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        ASSERT DQ = 'X'
            REPORT "output should be X"
            SEVERITY error;

        IF DQ /= 'X' THEN
            check_err <= '1';
        ELSE
            check_err <= '0';
        END IF;

        ASSERT DQ /= 'X'
            REPORT "Read OK - output X"
            SEVERITY note;
    END PROCEDURE Check_X;

    PROCEDURE   Check_U (
        DQ   :  IN std_logic;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        ASSERT DQ = 'U'
            REPORT "output should be U"
            SEVERITY error;

        IF DQ /= 'U' THEN
            check_err <= '1';
        ELSE
            check_err <= '0';
        END IF;

        ASSERT DQ /= 'U'
            REPORT "Read OK - output U"
            SEVERITY note;
    END PROCEDURE Check_U;

----Check read from OTP memory
    PROCEDURE   Check_otp_read (
        DQ     :  IN std_logic_vector(7 downto 0);
        otp_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        ASSERT to_nat(DQ) = otp_mem
            REPORT "READ: expected data  =" &
            to_int_str(otp_mem)&" got " &
            to_int_str(DQ)
            SEVERITY error;

        ASSERT to_nat(DQ)/=otp_mem
            REPORT "READ: OK - "&
            to_int_str(DQ)
            SEVERITY note;

        IF to_nat(DQ)/=otp_mem THEN
            check_err <= '1';
        ELSE
            check_err <= '0';
        END IF;
    END PROCEDURE Check_otp_read;

----Check JEDEC manuf. and device ID
    PROCEDURE   Check_read_JID (
        DQ               :  IN std_logic_vector(7 downto 0);
        VDATA            :  IN NATURAL;
        byte_no          :  IN NATURAL;
        SIGNAL check_err :  OUT std_logic) IS
    BEGIN

        ASSERT to_nat(DQ(7 downto 0)) = VDATA
            REPORT "READ CFI: expected data =" &
            to_hex_str(VDATA)&" got " &
            to_hex_str(DQ(7 downto 0))
            SEVERITY error;

        ASSERT to_nat(DQ(7 downto 0))/=VDATA
            REPORT "READ CFI: OK - "&
            to_hex_str(DQ(7 downto 0))
            SEVERITY note;

        IF to_nat(DQ(7 downto 0))/=VDATA THEN
            check_err <= '1';
        ELSE
            check_err <= '0';
        END IF;
    END PROCEDURE Check_read_JID;

----Check read electronic signature ID
    PROCEDURE   Check_read_ES (
        DQ               :  IN std_logic_vector(7 downto 0);
        SIGNAL check_err :  OUT std_logic) IS
    BEGIN
        ASSERT DQ = to_slv(16#18#,8)
            REPORT "RES: expected data  = 0x18" &
            " got " & to_int_str(DQ)
            SEVERITY error;

        ASSERT DQ /= to_slv(16#18#,8)
            REPORT "RES: OK - "&
            to_int_str(DQ)
            SEVERITY note;

        IF DQ /= to_slv(16#18#,8) THEN
            check_err <= '1';
        ELSE
            check_err <= '0';
        END IF;
    END PROCEDURE Check_read_ES;

----Check read ID
    PROCEDURE   Check_read_ID (
        DQ               :  IN std_logic_vector(7 downto 0);
        ADDR_BIT         :  IN std_logic;
        SIGNAL check_err :  OUT std_logic) IS
    BEGIN
        IF ADDR_BIT = '0' THEN
            ASSERT DQ = to_slv(16#01#,8)
                REPORT "READ Manufacturer ID: expected data  = 0x01" &
                " got " & to_int_str(DQ)
                SEVERITY error;

            ASSERT DQ /= to_slv(16#01#,8)
                REPORT "READ Manufacturer ID: OK - "&
                 to_int_str(DQ)
                SEVERITY note;

            IF DQ /= to_slv(16#01#,8) THEN
                check_err <= '1';
            ELSE
                check_err <= '0';
            END IF;

        ELSIF ADDR_BIT = '1' THEN
            ASSERT DQ = to_slv(16#18#,8)
                REPORT "READ Device ID: expected data  = 0x18" &
                " got " & to_int_str(DQ)
                SEVERITY error;

            ASSERT DQ /= to_slv(16#18#,8)
                REPORT "READ Device ID: OK - "&
                 to_int_str(DQ)
                SEVERITY note;

            IF DQ /= to_slv(16#18#,8) THEN
                check_err <= '1';
            ELSE
                check_err <= '0';
            END IF;
        END IF;
    END PROCEDURE Check_read_ID;

----Check read Status Register 1
    PROCEDURE   Check_read_sr1 (
        DQ   :  IN std_logic_vector(7 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        ASSERT to_nat(DQ) = D_mem
            REPORT "Read Status Register: expected data = " &
            to_int_str(D_mem) & " got " & to_int_str(DQ)
            SEVERITY error;

        ASSERT to_nat(DQ) /= D_mem
            REPORT "Read Status Register: OK - "& to_int_str(DQ)
            SEVERITY note;
        IF to_nat(DQ)/=D_mem THEN
            check_err <= '1';
        ELSE
            check_err <= '0';
        END IF;

    END PROCEDURE Check_read_sr1;

----Check read Status Register 2
    PROCEDURE   Check_read_sr2 (
        DQ   :  IN std_logic_vector(7 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        ASSERT to_nat(DQ) = D_mem
            REPORT "Read Status Register: expected data = " &
            to_int_str(D_mem) & " got " & to_int_str(DQ)
            SEVERITY error;

        ASSERT to_nat(DQ) /= D_mem
            REPORT "Read Status Register: OK - "& to_int_str(DQ)
            SEVERITY note;
        IF to_nat(DQ)/=D_mem THEN
            check_err <= '1';
        ELSE
            check_err <= '0';
        END IF;

    END PROCEDURE Check_read_sr2;

----Check read Configuration Register
    PROCEDURE   Check_read_config (
        DQ   :  IN std_logic_vector(7 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        ASSERT to_nat(DQ) = D_mem
            REPORT "Read Configuration Register: expected data = " &
            to_int_str(D_mem) & " got " & to_int_str(DQ)
            SEVERITY error;

        ASSERT to_nat(DQ) /= D_mem
            REPORT "Read Configuration Register: OK - "& to_int_str(DQ)
            SEVERITY note;
        IF to_nat(DQ)/=D_mem THEN
            check_err <= '1';
        ELSE
            check_err <= '0';
        END IF;

    END PROCEDURE Check_read_config;

----Check read autoboot register
    PROCEDURE   Check_read_autoboot (
        DQ   :  IN std_logic_vector(31 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        ASSERT to_nat(DQ) = D_mem
            REPORT "Read Autoboot Register: expected data = " &
            to_int_str(D_mem) & " got " & to_int_str(DQ)
            SEVERITY error;

        ASSERT to_nat(DQ) /= D_mem
            REPORT "Read Autoboot Register: OK - "& to_int_str(DQ)
            SEVERITY note;
        IF to_nat(DQ)/=D_mem THEN
            check_err <= '1';
        ELSE
            check_err <= '0';
        END IF;
    END PROCEDURE Check_read_autoboot;

----Check read Bank register
    PROCEDURE   Check_read_bank (
        DQ   :  IN std_logic_vector(7 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        ASSERT to_nat(DQ) = D_mem
            REPORT "Read Bank Register: expected data = " &
            to_int_str(D_mem) & " got " & to_int_str(DQ)
            SEVERITY error;

        ASSERT to_nat(DQ) /= D_mem
            REPORT "Read Bank Register: OK - "& to_int_str(DQ)
            SEVERITY note;
        IF to_nat(DQ)/=D_mem THEN
            check_err <= '1';
        ELSE
            check_err <= '0';
        END IF;
    END PROCEDURE Check_read_bank;

----Check read ASP register
    PROCEDURE   Check_read_asp (
        DQ   :  IN std_logic_vector(15 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        ASSERT to_nat(DQ) = D_mem
            REPORT "Read ASP Register: expected data = " &
            to_int_str(D_mem) & " got " & to_int_str(DQ)
            SEVERITY error;

        ASSERT to_nat(DQ) /= D_mem
            REPORT "Read ASP Register: OK - "& to_int_str(DQ)
            SEVERITY note;
        IF to_nat(DQ)/=D_mem THEN
            check_err <= '1';
        ELSE
            check_err <= '0';
        END IF;
    END PROCEDURE Check_read_asp;

----Check read Password Register
    PROCEDURE   Check_read_pass_reg (
        DQ   :  IN std_logic_vector(63 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        ASSERT to_nat(DQ) = D_mem
            REPORT "Read Password Register: expected data = " &
            to_hex_str(D_mem) & " got " & to_hex_str(DQ)
            SEVERITY error;

        ASSERT to_nat(DQ) /= D_mem
            REPORT "Read Password Register: OK - "& to_hex_str(DQ)
            SEVERITY note;
        IF to_nat(DQ)/=D_mem THEN
            check_err <= '1';
        ELSE
            check_err <= '0';
        END IF;
    END PROCEDURE Check_read_pass_reg;
    
    ---Check ECC statusregister
    PROCEDURE   Check_rd_ecc (
        DQ   :  IN std_logic_vector(7 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        ASSERT to_nat(DQ) = D_mem
            REPORT "Read ECC Register: expected data = " &
            to_int_str(D_mem) & " got " & to_int_str(DQ)
            SEVERITY error;

        ASSERT to_nat(DQ) /= D_mem
            REPORT "Read ECC Register: OK - "& to_int_str(DQ)
            SEVERITY note;
        IF to_nat(DQ)/=D_mem THEN
            check_err <= '1';
        ELSE
            check_err <= '0';
        END IF;
    END PROCEDURE Check_rd_ecc;

----Check PPB Lock register
    PROCEDURE   Check_read_ppbl (
        DQ   :  IN std_logic_vector(7 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        ASSERT to_nat(DQ) = D_mem
            REPORT "Read PPB Lock Register: expected data = " &
            to_int_str(D_mem) & " got " & to_int_str(DQ)
            SEVERITY error;

        ASSERT to_nat(DQ) /= D_mem
            REPORT "Read PPB Lock Register: OK - "& to_int_str(DQ)
            SEVERITY note;
        IF to_nat(DQ)/=D_mem THEN
            check_err <= '1';
        ELSE
            check_err <= '0';
        END IF;
    END PROCEDURE Check_read_ppbl;

----Check PPB Access register
    PROCEDURE   Check_read_ppbar (
        DQ   :  IN std_logic_vector(7 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        ASSERT to_nat(DQ) = D_mem
            REPORT "Read PPB Access Register: expected data = " &
            to_int_str(D_mem) & " got " & to_int_str(DQ)
            SEVERITY error;

        ASSERT to_nat(DQ) /= D_mem
            REPORT "Read PPB Access Register: OK - "& to_int_str(DQ)
            SEVERITY note;
        IF to_nat(DQ)/=D_mem THEN
            check_err <= '1';
        ELSE
            check_err <= '0';
        END IF;
    END PROCEDURE Check_read_ppbar;

----Check DYB Access register
    PROCEDURE   Check_read_dybar (
        DQ   :  IN std_logic_vector(7 downto 0);
        D_mem:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        ASSERT to_nat(DQ) = D_mem
            REPORT "Read DYB Access Register: expected data = " &
            to_int_str(D_mem) & " got " & to_int_str(DQ)
            SEVERITY error;

        ASSERT to_nat(DQ) /= D_mem
            REPORT "Read DYB Access Register: OK - "& to_int_str(DQ)
            SEVERITY note;
        IF to_nat(DQ)/=D_mem THEN
            check_err <= '1';
        ELSE
            check_err <= '0';
        END IF;
    END PROCEDURE Check_read_dybar;

----Check PPBLOCK bit
    PROCEDURE   Check_PPBLOCK_bit (
        DQ   :  IN std_logic;
        sts  :  IN  status_type;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        IF DQ = '1' THEN
            ASSERT sts = rd_ppblock_1
                REPORT "ERROR: Expected value PPBLOCK = '1' and got value '0'"
                SEVERITY error;

            IF sts /= rd_ppblock_1 THEN
                check_err <= '1';
            ELSE
                check_err <= '0';
            END IF;

            ASSERT sts /= rd_ppblock_1
                REPORT "PPBLOCK = '1', PPB array may be programmed or erased"
                SEVERITY note;
        ELSE
            ASSERT sts = rd_ppblock_0
                REPORT "ERROR: Expected value PPBLOCK = '0' and got value '1'"
                SEVERITY error;

            IF sts /= rd_ppblock_0 THEN
                check_err <= '1';
            ELSE
                check_err <= '0';
            END IF;

            ASSERT sts /= rd_ppblock_0
                REPORT "PPBLOCK = '0', PPB array is protected "
                SEVERITY note;
        END IF;
    END PROCEDURE Check_PPBLOCK_bit;

----Check WIP bit
    PROCEDURE   Check_WIP_bit (
        DQ   :  IN std_logic;
        sts  :  IN  status_type;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        IF DQ = '1' THEN
            ASSERT sts = rd_wip_1
                REPORT "Write in progress "&
                       "ERROR: command should be ignored"
                SEVERITY error;

            IF sts /= rd_wip_1 THEN
                check_err <= '1';
            ELSE
                check_err <= '0';
            END IF;

            ASSERT sts /= rd_wip_1
                REPORT "Write In progress"
                SEVERITY note;
        ELSE
            ASSERT sts = rd_wip_0
                REPORT "Write is NOT in progress "&
                       "   command NOT accepted"
                SEVERITY error;

            IF sts /= rd_wip_0 THEN
                check_err <= '1';
            ELSE
                check_err <= '0';
            END IF;

            ASSERT sts /= rd_wip_0
                REPORT "Write is NOT in progress "
                SEVERITY note;
        END IF;
    END PROCEDURE Check_WIP_bit;

----Check WEL bit
    PROCEDURE   Check_WEL_bit (
        DQ   :  IN std_logic;
        sts  :  IN  status_type;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        IF DQ = '1' THEN
            ASSERT sts = rd_wel_1
                REPORT " WEL=0 "&
                       "ERROR: command should be ignored"
                SEVERITY error;

            IF sts /= rd_wel_1 THEN
                check_err <= '1';
            ELSE
                check_err <= '0';
            END IF;

            ASSERT sts /= rd_wel_1
                REPORT "WEL = 1; Operation in progress"
                SEVERITY note;
        ELSE
            ASSERT sts = rd_wel_0
                REPORT "WEL = 1 "&
                       "ERROR: command NOT accepted"
                SEVERITY error;

            IF sts /= rd_wel_0 THEN
                check_err <= '1';
            ELSE
                check_err <= '0';
            END IF;

            ASSERT sts /= rd_wel_0
                REPORT " WEL=0; Operation completed "
                SEVERITY note;
        END IF;
    END PROCEDURE Check_WEL_bit;

----Check Erase operation bit
    PROCEDURE   Check_eers_bit (
        DQ   :  IN std_logic;
        sts  :  IN  status_type;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        IF DQ = '1' THEN
            ASSERT sts = erase_nosucc
                REPORT "Erase Operation ERROR"
                SEVERITY error;

            IF sts /= erase_nosucc THEN
                check_err <= '1';
            ELSE
                check_err <= '0';
            END IF;

            ASSERT sts /= erase_nosucc
                REPORT "Erase Operation failed"
                SEVERITY note;
        ELSE
            ASSERT sts = erase_succ
                REPORT "Erase Operation successful "
                SEVERITY error;

            IF sts /=  erase_succ THEN
                check_err <= '1';
            ELSE
                check_err <= '0';
            END IF;

            ASSERT sts /= erase_succ
                REPORT "Erase Operation OK "
                SEVERITY note;
        END IF;
    END PROCEDURE Check_eers_bit;

----Check Program operation bit
    PROCEDURE   Check_epgm_bit (
        DQ   :  IN std_logic;
        sts  :  IN  status_type;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        IF DQ = '1' THEN
            ASSERT sts = pgm_nosucc
                REPORT "Program Operation ERROR"
                SEVERITY error;

            IF sts /= pgm_nosucc THEN
                check_err <= '1';
            ELSE
                check_err <= '0';
            END IF;

            ASSERT sts /= pgm_nosucc
                REPORT "Program Operation failed"
                SEVERITY note;
        ELSE
            ASSERT sts = pgm_succ
                REPORT "Program Operation successful "
                SEVERITY error;

            IF sts /=  pgm_succ THEN
                check_err <= '1';
            ELSE
                check_err <= '0';
            END IF;

            ASSERT sts /= pgm_succ
                REPORT "Program Operation OK "

                SEVERITY note;
        END IF;
    END PROCEDURE Check_epgm_bit;

----Check Program Suspend bit
    PROCEDURE Check_PS_bit (
        DQ   :  IN std_logic;
        sts  :  IN  status_type;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        IF DQ = '1' THEN
            ASSERT sts = rd_ps_1
                REPORT "Program Suspend ERROR"
                SEVERITY error;

            IF sts /= rd_ps_1 THEN
                check_err <= '1';
            ELSE
                check_err <= '0';
            END IF;

            ASSERT sts /= rd_ps_1
                REPORT "Program Suspend mode: active"
                SEVERITY note;
        ELSE
            ASSERT sts = rd_ps_0
                REPORT "Program Suspend successful "
                SEVERITY error;

            IF sts /=  rd_ps_0 THEN
                check_err <= '1';
            ELSE
                check_err <= '0';
            END IF;

            ASSERT sts /= rd_ps_0
                REPORT "Program not in Suspend "

                SEVERITY note;
        END IF;
    END PROCEDURE Check_PS_bit;

----Check Erase Suspend bit
    PROCEDURE Check_ES_bit (
        DQ   :  IN std_logic;
        sts  :  IN  status_type;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        IF DQ = '1' THEN
            ASSERT sts = rd_es_1
                REPORT "Erase Suspend ERROR"
                SEVERITY error;

            IF sts /= rd_es_1 THEN
                check_err <= '1';
            ELSE
                check_err <= '0';
            END IF;

            ASSERT sts /= rd_es_1
                REPORT "Erase Suspend mode: active"
                SEVERITY note;
        ELSE
            ASSERT sts = rd_es_0
                REPORT "Erase Suspend successful "
                SEVERITY error;

            IF sts /=  rd_es_0 THEN
                check_err <= '1';
            ELSE
                check_err <= '0';
            END IF;

            ASSERT sts /= rd_es_0
                REPORT "Erase not in Suspend "

                SEVERITY note;
        END IF;
    END PROCEDURE Check_ES_bit;

----Check read DLP Register
    PROCEDURE   Check_read_dlp (
        DQ     :  IN std_logic_vector(7 downto 0);
        DLP_reg:  IN NATURAL;
        SIGNAL check_err:  OUT std_logic) IS
    BEGIN
        ASSERT to_nat(DQ) = DLP_reg
            REPORT "Read DLP Register: expected data = " &
            to_int_str(DLP_reg) & " got " & to_int_str(DQ)
            SEVERITY error;
        ASSERT to_nat(DQ) /= DLP_reg
            REPORT "Read DLP Register: OK - "& to_int_str(DQ)
            SEVERITY note;

        IF to_nat(DQ)/=DLP_reg THEN
            check_err <= '1';
        ELSE
            check_err <= '0';
        END IF;

    END PROCEDURE Check_read_dlp;

END PACKAGE BODY spansion_tc_pkg;