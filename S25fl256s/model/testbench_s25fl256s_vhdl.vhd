-------------------------------------------------------------------------------
--  File name : testbench_s25fl256s_vhdl.vhd
-------------------------------------------------------------------------------
--  Copyright (C) 2012 Spansion, LLC.
--
--  MODIFICATION HISTORY :
--
--  version:   |     author:   |   mod date:  |  changes made:
--    V1.0          V.Mancev      09 Nov 25     Initial release
--    V1.1          V.Mancev      10 Oct 21     Latest datasheet aligned
--                 B.Colakovic
--                 R. Prokopovic
--    V1.2         V. Mancev      11 May 11    CS# High Time modifications
--    V1.3         B.Colakovic    11 July 05   Latest datasheet aligned
--    V1.4         V. Mancev      11 Nov 18    Setting of Device protection mode
--                                             is modified
--    V1.5         S.Petrovic     12 Aug 28    QPP Instruction is allowed on
--                                             previously programmed page
--    V1.6         V. Mancev      13 Feb 13    Reverted restriction for QPP
--                                             on programmed page and added
--                                             clearing with sector erase
--    V1.7         S.Petrovic     13 Dec 20    Corrected DLP read
--    V1.8         M.Stojanovic   16 May 11    During QPP and QPP4 commands
--                                             the same page must not be
--                                             programmed more than once. However
--                                             do not generate P_ERR if this
--                                             occurs.
--    V1.9         M.Krneta       19 May 07    Updated according to the rev *P
--                                             (QPP and QPP4 commands changed,
--                                             ECCRD command added,
--                                             LOCK bit removed)
--
-------------------------------------------------------------------------------
--  PART DESCRIPTION:
--
--  Description:
--             Generic test enviroment for verification of flash memory
--             VITAL models.
--
-------------------------------------------------------------------------------
--  Comments :
--      * For correct simulation, simulator resolution should be set to 1ps.
--      * When testing with different timing models, value of CONSTANT
--        Timingmodel should be changed
--      * When testing with different hybrid sector architecture, value of
--        CONSTANT BootConfig should be changed. Possible values are
--        TRUE for BottomBoot i FALSE for TopBoot
-------------------------------------------------------------------------------
--  Known Bugs:
--
-------------------------------------------------------------------------------
--  Notes:
--  Choose value for variable 'Clock_polarity' to select SPI mode
--    Clock_polarity <= '0'; for SPI mode: CPO L= 0, CPHA = 0
--    Clock_polarity <= '1'; for SPI mode: CPO L= 1, CPHA = 1
--  Set test environment - device protection mode
--    MODE <= DEFAULT_PROTECTION;
--    MODE <= PERSISTENT_PROTECTION;
--    MODE <= PASSWORD_PROTECTION;
--    MODE <= READ_PASSWORD_PROTECTION;
-------------------------------------------------------------------------------
LIBRARY IEEE;
    USE IEEE.std_logic_1164.ALL;
    USE IEEE.VITAL_timing.ALL;
    USE IEEE.VITAL_primitives.ALL;
    USE STD.textio.ALL;

LIBRARY FMF;
    USE FMF.gen_utils.all;
    USE FMF.conversions.all;

LIBRARY work;
    USE work.spansion_tc_pkg.all;
-------------------------------------------------------------------------------
-- ENTITY DECLARATION
-------------------------------------------------------------------------------
ENTITY testbench_s25fl256s_vhdl IS

END testbench_s25fl256s_vhdl;
-------------------------------------------------------------------------------
-- ARCHITECTURE DECLARATION
-------------------------------------------------------------------------------
ARCHITECTURE vhdl_behavioral of testbench_s25fl256s_vhdl IS
    COMPONENT s25fl256s IS
        GENERIC (
            -- tipd delays: interconnect path delays (delay between components)
            --    There should be one for each IN or INOUT pin in the port list
            --    They are given default values of zero delay.
            tipd_SCK                : VitalDelayType01  := VitalZeroDelay01;
            tipd_SI                 : VitalDelayType01  := VitalZeroDelay01;
            tipd_SO                 : VitalDelayType01  := VitalZeroDelay01;

            tipd_CSNeg              : VitalDelayType01  := VitalZeroDelay01;
            tipd_HOLDNeg            : VitalDelayType01  := VitalZeroDelay01;
            tipd_WPNeg              : VitalDelayType01  := VitalZeroDelay01;
            tipd_RSTNeg             : VitalDelayType01  := VitalZeroDelay01;

            -- tpd delays: propagation delays
            tpd_SCK_SO_normal       : VitalDelayType01Z := UnitDelay01Z;
            tpd_CSNeg_SO            : VitalDelayType01Z := UnitDelay01Z;
            tpd_HOLDNeg_SO          : VitalDelayType01Z := UnitDelay01Z;
            tpd_RSTNeg_SO           : VitalDelayType01Z := UnitDelay01Z;
            -- DDR operation values
            tpd_SCK_SO_DDR          : VitalDelayType01Z := UnitDelay01Z;

            -- tsetup values: setup times
            --   setup time is minimum time before the referent signal edge the
            --   input should be stable
            tsetup_CSNeg_SCK_normal_noedge_posedge
                                    : VitalDelayType    := UnitDelay; -- tCSS /
            tsetup_CSNeg_SCK_DDR_noedge_posedge
                                    : VitalDelayType    := UnitDelay; -- tCSS /
            tsetup_SI_SCK_normal_noedge_posedge: VitalDelayType
                                                        := UnitDelay;
            tsetup_WPNeg_CSNeg      : VitalDelayType    := UnitDelay;
            tsetup_HOLDNeg_SCK      : VitalDelayType    := UnitDelay;
            tsetup_RSTNeg_CSNeg     : VitalDelayType    := UnitDelay;
            -- DDR operation values
            tsetup_SI_SCK_DDR_noedge_posedge:   VitalDelayType    := UnitDelay;
            tsetup_SI_SCK_DDR_noedge_negedge:   VitalDelayType    := UnitDelay;
            tsetup_SI_SCK_DDR80_noedge_posedge: VitalDelayType    := UnitDelay;
            tsetup_SI_SCK_DDR80_noedge_negedge: VitalDelayType    := UnitDelay;

            -- thold values: hold times
            --   hold time is minimum time the input should be present stable
            --   after the referent signal edge
            thold_CSNeg_SCK_normal_noedge_posedge
                                    : VitalDelayType    := UnitDelay; -- tCSH /
            thold_CSNeg_SCK_DDR_noedge_posedge
                                    : VitalDelayType    := UnitDelay; -- tCSH /
            thold_SI_SCK_normal_noedge_posedge: VitalDelayType
                                                        := UnitDelay;--tHD:DAT/
            thold_WPNeg_CSNeg       : VitalDelayType    := UnitDelay;--tWPH /
            thold_HOLDNeg_SCK       : VitalDelayType    := UnitDelay;
            thold_CSNeg_RSTNeg      : VitalDelayType    := UnitDelay; -- tRPH
            -- DDR operation values
            thold_SI_SCK_DDR_noedge_posedge: VitalDelayType      := UnitDelay;
            thold_SI_SCK_DDR_noedge_negedge: VitalDelayType      := UnitDelay;
            thold_SI_SCK_DDR80_noedge_posedge: VitalDelayType    := UnitDelay;
            thold_SI_SCK_DDR80_noedge_negedge: VitalDelayType    := UnitDelay;

            --tpw values: pulse width
            tpw_SCK_serial_posedge  : VitalDelayType := UnitDelay;--tWH
            tpw_SCK_dual_posedge    : VitalDelayType := UnitDelay;--tWH
            --tpw_SCK_ddr80_posedge   : VitalDelayType := UnitDelay;--tWH
            tpw_SCK_fast_posedge    : VitalDelayType := UnitDelay;--tWH
            tpw_SCK_quadpg_posedge  : VitalDelayType := UnitDelay;--tWH
            tpw_SCK_serial_negedge  : VitalDelayType := UnitDelay;--tWL
            tpw_SCK_dual_negedge    : VitalDelayType := UnitDelay;--tWL
            --tpw_SCK_ddr80_negedge   : VitalDelayType := UnitDelay;--tWL
            tpw_SCK_fast_negedge    : VitalDelayType := UnitDelay;--tWL
            tpw_SCK_quadpg_negedge  : VitalDelayType := UnitDelay;--tWL
            tpw_CSNeg_read_posedge  : VitalDelayType := UnitDelay;--tCS
            tpw_CSNeg_pgers_posedge : VitalDelayType := UnitDelay;--tCS
            tpw_RSTNeg_negedge      : VitalDelayType := UnitDelay;--tRP
            tpw_RSTNeg_posedge      : VitalDelayType := UnitDelay;--tRS
            -- DDR operation values
            tpw_SCK_DDR_posedge     : VitalDelayType := UnitDelay;--tWH(66MHz)
            tpw_SCK_DDR_negedge     : VitalDelayType := UnitDelay;--tWL
            tpw_SCK_DDR80_posedge   : VitalDelayType := UnitDelay;--tWH(80MHz)
            tpw_SCK_DDR80_negedge   : VitalDelayType := UnitDelay;--tWL

            -- tperiod min (calculated as 1/max freq)
            tperiod_SCK_serial_rd   : VitalDelayType := UnitDelay;--fSCK=50MHz
            tperiod_SCK_fast_rd     : VitalDelayType := UnitDelay;--fSCK=133MHz
            tperiod_SCK_dual_rd     : VitalDelayType := UnitDelay;--fSCK=104MHz
            tperiod_SCK_quadpg      : VitalDelayType := UnitDelay; --fSCK=80MHz
            -- DDR operation values
            tperiod_SCK_DDR_rd      : VitalDelayType := UnitDelay;--fSCK=66MHz

            -- tdevice values: values for internal delays
                --timing values that are internal to the model and not
                --associated with any port.
            -- Page Program Operation (Page Size 256)
            tdevice_PP256           : VitalDelayType := 750 us;  --tPP
            -- Page Program Operation (Page Size 512)
            tdevice_PP512           : VitalDelayType := 750 us;  --tPP
            -- Typical Byte Programming Time
            tdevice_BP              : VitalDelayType := 400 us;  --tBP
                -- Sector Erase Operation(256KB Sectors)
            tdevice_SE256           : VitalDelayType := 1875 ms; --tSE
                -- Sector Erase Operation(64KB Sectors)
            tdevice_SE64            : VitalDelayType := 650 ms; --tSE
            -- Bulk Erase Operation
            tdevice_BE              : VitalDelayType := 330 sec; --tBE
            -- WRR Cycle Time
            tdevice_WRR             : VitalDelayType := 200 ms;  --tW
            -- Erase Suspend/Erase Resume Time
            tdevice_ERSSUSP         : VitalDelayType := 45 us;   --tESL
            -- Program Suspend/Program Resume Time
            tdevice_PRGSUSP         : VitalDelayType := 40 us;   --tPSL
            -- VCC (min) to CS# Low
            tdevice_PU              : VitalDelayType := 300 us;  --tPU
          -- PPB Erase Time
            tdevice_PPBERASE         :VitalDelayType := 15 ms;
          -- Password Unlock Time
            tdevice_PASSULCK         :VitalDelayType := 1 us;
          -- Password Unlock Time
            tdevice_PASSACC          :VitalDelayType := 100 us;

        -----------------------------------------------------------------------
        -- CONTROL GENERICS:
        -----------------------------------------------------------------------
        -- generic control parameters
            InstancePath    : STRING    := DefaultInstancePath;
            TimingChecksOn  : BOOLEAN   := DefaultTimingChecks;
            MsgOn           : BOOLEAN   := DefaultMsgOn;
            XOn             : BOOLEAN   := DefaultXon;
            -- memory file to be loaded
            mem_file_name   : STRING    := "s25fl256s.mem";
            otp_file_name   : STRING    := "s25fl256sOTP.mem";

            UserPreload     : BOOLEAN   := FALSE; --TRUE;
            LongTimming     : BOOLEAN   := TRUE;

            -- For FMF SDF technology file usage
            TimingModel     : STRING    := DefaultTimingModel
        );
        PORT (
            -- Data Inputs/Outputs
            SI              : INOUT std_ulogic := 'U';--serial data input/IO0
            SO              : INOUT std_ulogic := 'U';--serial data output/IO1
            -- Controls
            SCK             : IN    std_ulogic := 'U';--serial clock input
            CSNeg           : IN    std_ulogic := 'U';--chip select input
            RSTNeg          : IN    std_ulogic := 'U';--hardware reset pin
            WPNeg           : INOUT std_ulogic := 'U';--write protect input/IO2
            HOLDNeg         : INOUT std_ulogic := 'U' --hold input/IO3
    );
    END COMPONENT;

    FOR ALL: s25fl256s USE ENTITY WORK.s25fl256s(VHDL_BEHAVIORAL);

    ---------------------------------------------------------------------------
    --memory configuration
    ---------------------------------------------------------------------------
    CONSTANT MaxData       : NATURAL := 16#FF#;        --255;
    CONSTANT MemSize       : NATURAL := 16#1FFFFFF#;
    CONSTANT SecNum64      : NATURAL := 541;
    CONSTANT SecSize4      : NATURAL := 16#FFF#;
    CONSTANT SecSize64     : NATURAL := 16#FFFF#;
    CONSTANT SecSize256    : NATURAL := 16#3FFFF#;
    CONSTANT PageNum64     : NATURAL := 16#2FFFF#;
    CONSTANT PageNum256    : NATURAL := 16#FFFF#;
    CONSTANT AddrRANGE     : NATURAL := 16#1FFFFFF#;
    CONSTANT HiAddrBit     : NATURAL := 31;
    CONSTANT OTPSize       : NATURAL := 1023;
    CONSTANT OTPLoAddr     : NATURAL := 16#000#;
    CONSTANT OTPHiAddr     : NATURAL := 16#3FF#;
    ---------------------------------------------------------------------------
    --model configuration
    ---------------------------------------------------------------------------
    CONSTANT mem_file           :   STRING  := "s25fl256s.mem";
    CONSTANT otp_file           :   STRING  := "s25fl256sOTP.mem";
    CONSTANT half_period1_srl   :   TIME    := 3.76 ns;--1/(2*133MHz)
    CONSTANT half_period2_srl   :   TIME    := 10 ns;  --1/(2*50MHz)
    CONSTANT half_period_quad   :   TIME    := 4.9 ns; --1/(2*104MHz)
    CONSTANT half_period_quadpg :   TIME    := 6.25 ns;--1/(2*80MHz)
    CONSTANT half_period_ddr    :   TIME    := 7.5 ns; --1/(2*66MHz)

    CONSTANT UserPreload        :   boolean :=  TRUE;
    CONSTANT LongTimming        :   boolean :=  TRUE;
    CONSTANT TimingModel        :   STRING  :=  "S25FL256SAGMFI000_F_30pF";
    CONSTANT BootConfig         :   BOOLEAN :=  TRUE;
    ---------------------------------------------------------------------------
    --One Byte Instruction Code
    ---------------------------------------------------------------------------
    CONSTANT I_WREN           :std_logic_vector(7 downto 0) := "00000110";
    CONSTANT I_WRDI           :std_logic_vector(7 downto 0) := "00000100";
    CONSTANT I_WRR            :std_logic_vector(7 downto 0) := "00000001";
    CONSTANT I_READ           :std_logic_vector(7 downto 0) := "00000011";
    CONSTANT I_RD4            :std_logic_vector(7 downto 0) := "00010011";
    CONSTANT I_OTPR           :std_logic_vector(7 downto 0) := "01001011";
    CONSTANT I_RDSR           :std_logic_vector(7 downto 0) := "00000101";
    CONSTANT I_RDSR2          :std_logic_vector(7 downto 0) := "00000111";
    CONSTANT I_ECCRD          :std_logic_vector(7 downto 0) := "00011000";
    CONSTANT I_RDCR           :std_logic_vector(7 downto 0) := "00110101";
    CONSTANT I_REMS           :std_logic_vector(7 downto 0) := "10010000";
    CONSTANT I_RDID           :std_logic_vector(7 downto 0) := "10011111";
    CONSTANT I_RES            :std_logic_vector(7 downto 0) := "10101011";
    CONSTANT I_FSTRD          :std_logic_vector(7 downto 0) := "00001011";
    CONSTANT I_FSTRD4         :std_logic_vector(7 downto 0) := "00001100";
    CONSTANT I_FDDR           :std_logic_vector(7 downto 0) := "00001101";
    CONSTANT I_FDDR4          :std_logic_vector(7 downto 0) := "00001110";
    CONSTANT I_RDDO           :std_logic_vector(7 downto 0) := "00111011";
    CONSTANT I_RDDO4          :std_logic_vector(7 downto 0) := "00111100";
    CONSTANT I_RDDIO          :std_logic_vector(7 downto 0) := "10111011";
    CONSTANT I_RDDIO4         :std_logic_vector(7 downto 0) := "10111100";
    CONSTANT I_RDDRD          :std_logic_vector(7 downto 0) := "10111101";
    CONSTANT I_RDDRD4         :std_logic_vector(7 downto 0) := "10111110";
    CONSTANT I_RDQO           :std_logic_vector(7 downto 0) := "01101011";
    CONSTANT I_RDQO4          :std_logic_vector(7 downto 0) := "01101100";
    CONSTANT I_RDQIO          :std_logic_vector(7 downto 0) := "11101011";
    CONSTANT I_RDQIO4         :std_logic_vector(7 downto 0) := "11101100";
    CONSTANT I_RDDRQ          :std_logic_vector(7 downto 0) := "11101101";
    CONSTANT I_RDDRQ4         :std_logic_vector(7 downto 0) := "11101110";
    CONSTANT I_PP             :std_logic_vector(7 downto 0) := "00000010";
    CONSTANT I_PP4            :std_logic_vector(7 downto 0) := "00010010";
    CONSTANT I_QPP            :std_logic_vector(7 downto 0) := "00110010";
    CONSTANT I_QPP4           :std_logic_vector(7 downto 0) := "00110100";
    CONSTANT I_OTPP           :std_logic_vector(7 downto 0) := "01000010";
    CONSTANT I_PGSP           :std_logic_vector(7 downto 0) := "10000101";
    CONSTANT I_PGRS           :std_logic_vector(7 downto 0) := "10001010";
    CONSTANT I_BE             :std_logic_vector(7 downto 0) := "11000111";
    CONSTANT I_SE             :std_logic_vector(7 downto 0) := "11011000";
    CONSTANT I_SE4            :std_logic_vector(7 downto 0) := "11011100";
    CONSTANT I_P4E            :std_logic_vector(7 downto 0) := "00100000";
    CONSTANT I_P4E4           :std_logic_vector(7 downto 0) := "00100001";
    CONSTANT I_ERSP           :std_logic_vector(7 downto 0) := "01110101";
    CONSTANT I_ERRS           :std_logic_vector(7 downto 0) := "01111010";
    CONSTANT I_ABRD           :std_logic_vector(7 downto 0) := "00010100";
    CONSTANT I_ABWR           :std_logic_vector(7 downto 0) := "00010101";
    CONSTANT I_BRRD           :std_logic_vector(7 downto 0) := "00010110";
    CONSTANT I_BRWR           :std_logic_vector(7 downto 0) := "00010111";
    CONSTANT I_BRAC           :std_logic_vector(7 downto 0) := "10111001";
    CONSTANT I_ASPRD          :std_logic_vector(7 downto 0) := "00101011";
    CONSTANT I_ASPP           :std_logic_vector(7 downto 0) := "00101111";
    CONSTANT I_DYBRD          :std_logic_vector(7 downto 0) := "11100000";
    CONSTANT I_DYBWR          :std_logic_vector(7 downto 0) := "11100001";
    CONSTANT I_PPBRD          :std_logic_vector(7 downto 0) := "11100010";
    CONSTANT I_PPBP           :std_logic_vector(7 downto 0) := "11100011";
    CONSTANT I_PPBERS         :std_logic_vector(7 downto 0) := "11100100";
    CONSTANT I_PLBWR          :std_logic_vector(7 downto 0) := "10100110";
    CONSTANT I_PLBRD          :std_logic_vector(7 downto 0) := "10100111";
    CONSTANT I_PASSRD         :std_logic_vector(7 downto 0) := "11100111";
    CONSTANT I_PASSP          :std_logic_vector(7 downto 0) := "11101000";
    CONSTANT I_PASSU          :std_logic_vector(7 downto 0) := "11101001";
    CONSTANT I_RESET          :std_logic_vector(7 downto 0) := "11110000";
    CONSTANT I_MBR            :std_logic_vector(7 downto 0) := "11111111";
    CONSTANT I_CLSR           :std_logic_vector(7 downto 0) := "00110000";
    CONSTANT I_RDDLP          :std_logic_vector(7 downto 0) := "01000001";
    CONSTANT I_PNVDLR         :std_logic_vector(7 downto 0) := "01000011";
    CONSTANT I_WVDLR          :std_logic_vector(7 downto 0) := "01001010";
    ---------------------------------------------------------------------------
    --testbench parameters
    ---------------------------------------------------------------------------
    --Flash Memory Array
    TYPE MemArr IS ARRAY (0 TO AddrRANGE)      OF INTEGER RANGE -1 TO MaxData;
    --OTP Array
    TYPE OtpArr IS ARRAY (OTPLoAddr TO OTPHiAddr) OF INTEGER
                                                     RANGE -1 TO MaxData;
    --CFI Array
    TYPE CFIArr IS ARRAY (16#00# TO 16#55#)    OF INTEGER RANGE -1 TO MaxData;

    ---------------------------------------------------------------------------
    --  memory declaration
    ---------------------------------------------------------------------------
    --             -- Mem(SecAddr)(Address)....
    SHARED  VARIABLE Mem             : MemArr := (OTHERS => MaxData);
    SHARED  VARIABLE Otp             : OtpArr := (OTHERS => MaxData);
    SHARED  VARIABLE CFI_array       : CFIArr;
    SHARED  VARIABLE half_period     : TIME     := half_period1_srl;--3.76 ns

    -- quad mode
    SHARED VARIABLE quad_mode : boolean := false;

    --command sequence
    SHARED VARIABLE cmd_seq         : cmd_seq_type;

    SIGNAL status          : status_type := none;
    SIGNAL cmd             : cmd_type := idle;
    SIGNAL read_num        : NATURAL := 0;

    -- device protection mode
    TYPE protection_type IS ( DEFAULT_PROTECTION,
                              PERSISTENT_PROTECTION,
                              PASSWORD_PROTECTION,
                              READ_PASSWORD_PROTECTION
                            );

    SIGNAL MODE            : protection_type;

    SIGNAL Clock_polarity  : std_logic;
    SIGNAL PageSize        :   NATURAL :=  0 ;
    SIGNAL PageNum         :   NATURAL :=  0 ;
    SIGNAL SecSize         :   NATURAL :=  0 ;
    SIGNAL SecNum          :   NATURAL :=  0 ;
    SIGNAL SecNumMax       :   NATURAL :=  0 ;

    SIGNAL check_err       :   std_logic := '0'; -- Active high on error
    SIGNAL ErrorInTest     :   std_logic := '0';

    ---------------------------------------------------------------------------
    --Personality module:
    --
    --  instanciates the DUT module and adapts generic test signals to it
    ---------------------------------------------------------------------------
    --DUT port
    SIGNAL T_SCK                : std_logic                     := 'U';
    SIGNAL T_SI                 : std_logic                     := 'U';
    SIGNAL T_SO                 : std_logic                     := 'U';

    SIGNAL T_CSNeg              : std_logic                     := 'U';
    SIGNAL T_HOLDNeg            : std_logic                     := 'U';
    SIGNAL T_WPNeg              : std_logic                     := '1';
    SIGNAL T_RSTNeg             : std_logic                     := '1';

    --Sector Protection Status
    SHARED VARIABLE Sec_Prot     : std_logic_vector (SecNum64 downto 0) :=
                                                    (OTHERS => '0');

    SHARED VARIABLE Status_reg1  : std_logic_vector(7 downto 0) := "00000000";

    -- Status Register Write Disable Bit
    ALIAS SRWD      :std_logic IS Status_reg1(7);
    -- Status Register Programming Error Bit
    ALIAS P_ERR     :std_logic IS Status_reg1(6);
    -- Status Register Erase Error Bit
    ALIAS E_ERR     :std_logic IS Status_reg1(5);
    -- Status Register Block Protection Bits
    ALIAS BP2       :std_logic IS Status_reg1(4);
    ALIAS BP1       :std_logic IS Status_reg1(3);
    ALIAS BP0       :std_logic IS Status_reg1(2);
    -- Status Register Write Enable Latch Bit
    ALIAS WEL       :std_logic IS Status_reg1(1);
    -- Status Register Write In Progress Bit
    ALIAS WIP       :std_logic IS Status_reg1(0);

        --     ***  Status Register 2  ***
    SHARED VARIABLE Status_reg2   : std_logic_vector(7 downto 0)
                                                := (others => '0');

    -- Status Register Write Enable Latch Bit
    ALIAS ES        :std_logic IS Status_reg2(1);
    -- Status Register Write In Progress Bit
    ALIAS PS        :std_logic IS Status_reg2(0);

    SHARED VARIABLE Config_reg1   : std_logic_vector(7 downto 0) := "00000000";
    SHARED VARIABLE NVDLR_reg     : std_logic_vector(7 downto 0) := "00000000";
    SHARED VARIABLE VDLR_reg      : std_logic_vector(7 downto 0) := "00000000";

    -- Latency code
    ALIAS LC1       :std_logic IS Config_reg1(7);
    ALIAS LC0       :std_logic IS Config_reg1(6);
    -- Configuration Register TBPROT bit
    ALIAS TBPROT    :std_logic IS Config_reg1(5);
    -- Configuration Register LOCK bit
--     ALIAS LOCK      :std_logic IS Config_reg1(4); 
    -- Configuration Register BPNV bit
    ALIAS BPNV      :std_logic IS Config_reg1(3);
    -- Configuration Register TBPARM bit
    ALIAS TBPARM    :std_logic IS Config_reg1(2);
    -- Configuration Register QUAD bit
    ALIAS QUAD      :std_logic IS Config_reg1(1);
    -- Configuration Register FREEZE bit
    ALIAS FREEZE    :std_logic IS Config_reg1(0);

        --      ***  AutoBoot Register  ***
    SHARED VARIABLE AutoBoot_reg   : std_logic_vector(31 downto 0)
                                            := (others => '0');
    --AutoBoot Enable Bit
    ALIAS ABE       :std_logic IS AutoBoot_reg(0);

        --      ***  Bank Address Register  ***
    SHARED VARIABLE Bank_Addr_reg  : std_logic_vector(7 downto 0)
                                            := (others => '0');
    -- Bank Address Register EXTADD bit
    ALIAS EXTADD    :std_logic IS Bank_Addr_reg(7);

        --      ***  ASP Register  ***
    SHARED VARIABLE ASP_reg        : std_logic_vector(15 downto 0);
    --Read Password Mode Enable Bit
    ALIAS RPME      :std_logic IS ASP_reg(5);
    --PPB OTP Bit
    ALIAS PPBOTP    :std_logic IS ASP_reg(3);
    -- Password Protection Mode Lock Bit
    ALIAS PWDMLB    :std_logic IS ASP_reg(2);
    --Persistent Protection Mode Lock Bit
    ALIAS PSTMLB    :std_logic IS ASP_reg(1);

        --      ***  Password Register  ***
    SHARED VARIABLE Password_reg   : std_logic_vector(63 downto 0)
                                            := (others => '1');

        --      ***  PPB Lock Register  ***
    SHARED VARIABLE PPBL           : std_logic_vector(7 downto 0)
                                            := "00000001";  
                                            
    SHARED VARIABLE ECCSR           : std_logic_vector(7 downto 0)
                                            := "00000000"; 
    --Persistent Protection Mode Lock Bit
    ALIAS PPB_LOCK                  : std_logic IS PPBL(0);

        --      ***  PPB Access Register  ***
    SHARED VARIABLE PPBAR          : std_logic_vector(7 downto 0)
                                            := (others => '1');
    -- PPB_bits(Sec)
    SHARED VARIABLE PPB_bits       : std_logic_vector(SecNum64 downto 0)
                                            := (OTHERS => '1');
        --      ***  DYB Access Register  ***
    SHARED VARIABLE DYBAR          : std_logic_vector(7 downto 0)
                                            := (others => '1');
    -- DYB(Sec)
    SHARED VARIABLE DYB_bits       : std_logic_vector(SecNum64 downto 0)
                                            := (OTHERS => '1');

    -- WDB(Sec)
    SHARED VARIABLE WDB_bits       : std_logic_vector(SecNum64 downto 0)
                                            := (OTHERS => '1');

    -- Page number for QPP
    SHARED VARIABLE QPP_page       : std_logic_vector(PageNum64 downto 0)
                                            := (OTHERS => '0');

    -- The Lock Protection Registers for OTP Memory space
    SHARED VARIABLE LOCK_BYTE1 :std_logic_vector(7 downto 0);
    SHARED VARIABLE LOCK_BYTE2 :std_logic_vector(7 downto 0);
    SHARED VARIABLE LOCK_BYTE3 :std_logic_vector(7 downto 0);
    SHARED VARIABLE LOCK_BYTE4 :std_logic_vector(7 downto 0);

    SHARED VARIABLE SECSUSP    :INTEGER RANGE 0 TO SecNum64;

    SHARED VARIABLE start_delay  : NATURAL;

    SIGNAL Tseries     : NATURAL;
    SIGNAL Tcase       : NATURAL;

    SIGNAL count       : INTEGER RANGE -1 to 7 := -1;

    --Lock Bit is enabled for customer programming
    SIGNAL WRLOCKENABLE       : BOOLEAN   := true;
    --Flag for initial configuration
    SIGNAL INITIAL_CONFIG     : BOOLEAN   := false;
    --Flag that mark if BPNV is allready programmed
    SIGNAL ASPOTPFLAG         : BOOLEAN   := false;
    SIGNAL ASP_INIT           : NATURAL RANGE 0 TO 1;
    SIGNAL PARM_BLOCK         : BOOLEAN   := false;

    SHARED VARIABLE b_act   :   NATURAL:=0;

    SHARED VARIABLE BAR_ACC :   NATURAL RANGE 0 TO 1:=0;

    SHARED VARIABLE ts_cnt  :   NATURAL RANGE 1 TO 46:=1; -- testseries counter
    SHARED VARIABLE tc_cnt  :   NATURAL RANGE 0 TO 10:=0; -- testcase counter

    FUNCTION ReturnAddr(ADDR : NATURAL; SADDR : NATURAL) RETURN NATURAL IS
        VARIABLE result : NATURAL;
    BEGIN
        IF SADDR <= 31 AND TimingModel(16) = '0' AND BootConfig = TRUE THEN
            result := SADDR*(SecSize4+1) + ADDR;
        ELSIF TimingModel(16) = '0' AND BootConfig = TRUE THEN
            result := (SADDR-30)*(SecSize64+1) + ADDR;
        ELSIF SADDR >= 510 AND TimingModel(16) = '0' AND BootConfig = FALSE THEN
            result := 510*(SecSize64+1) + (SADDR-510)*(SecSize4+1) + ADDR;
        ELSIF TimingModel(16) = '0' AND BootConfig = FALSE THEN
            result := SADDR*(SecSize64+1) + ADDR;
        ELSE
            result := SADDR*(SecSize256+1) + ADDR;
        END IF;
        RETURN result;
    END ReturnAddr;

    FUNCTION ReturnSectorID(ADDR : NATURAL) RETURN NATURAL IS
            VARIABLE result : NATURAL;
        BEGIN
            IF TimingModel(16) = '1' THEN
                IF ADDR <= AddrRange THEN
                    result := ADDR / (SecSize256+1);
                ELSE
                    result := 128;
                END IF;
            ELSE
                IF ADDR <= AddrRange THEN
                    result := ADDR / (SecSize64+1);
                ELSE
                    result := 512;
                END IF;
            END IF;
            RETURN result;
        END ReturnSectorID;

    PROCEDURE Sesa(
        VARIABLE   AddrLOW  : INOUT NATURAL RANGE 0 to ADDRRange;
        VARIABLE   AddrHIGH : INOUT NATURAL RANGE 0 to ADDRRange;
        VARIABLE   SectorID : NATURAL) IS
    BEGIN
        IF SectorID <= 31 AND TimingModel(16) = '0' AND TBPARM = '0' THEN
            IF PARM_BLOCK THEN
                AddrLOW  := SectorID*(SecSize4+1);
                AddrHIGH := SectorID*(SecSize4+1) + SecSize4;
            ELSE
                AddrLOW  := (SectorID/16)*(SecSize64+1);
                AddrHIGH := (SectorID/16)*(SecSize64+1) + SecSize64;
            END IF;
        ELSIF TimingModel(16) = '0' AND TBPARM = '0' THEN
            AddrLOW  := (SectorID-30)*(SecSize64+1);
            AddrHIGH := (SectorID-30)*(SecSize64+1) + SecSize64;
        ELSIF SectorID >= 510 AND TimingModel(16) = '0' AND TBPARM = '1' THEN
            IF PARM_BLOCK THEN
                AddrLOW  := 510*(SecSize64+1)+(SectorID-510)*(SecSize4+1);
                AddrHIGH :=
                       510*(SecSize64+1)+(SectorID-510)*(SecSize4+1) + SecSize4;
            ELSE
                AddrLOW  := 510*(SecSize64+1)+((SectorID-510)/16)*(SecSize64+1);
                AddrHIGH :=
                510*(SecSize64+1)+((SectorID-510)/16)*(SecSize64+1) + SecSize64;
            END IF;
        ELSIF TimingModel(16) = '0' AND TBPARM = '1' THEN
            AddrLOW  := SectorID*(SecSize64+1);
            AddrHIGH := SectorID*(SecSize64+1) + SecSize64;
        ELSE
            AddrLOW  := SectorID*(SecSize256+1);
            AddrHIGH := SectorID*(SecSize256+1) + SecSize256;
        END IF;
    END Sesa;

    PROCEDURE sepa(
        VARIABLE   AddrLOW  : INOUT NATURAL RANGE 0 to ADDRRange;
        VARIABLE   AddrHIGH : INOUT NATURAL RANGE 0 to ADDRRange;
        VARIABLE   SectorID : NATURAL;
        VARIABLE   Addr     : NATURAL) IS
        VARIABLE   Page     : NATURAL;
        VARIABLE   Addr_tmp : NATURAL;
    BEGIN
        Addr_tmp := ReturnAddr(Addr,SectorID) ;--real address
        Page     := Addr_tmp/PageSize;-- page number

        AddrLOW  := Page*PageSize;
        AddrHIGH := Page*PageSize + (PageSize-1);

    END sepa;

    BEGIN
        DUT : s25fl256s
        GENERIC MAP (
            -- tipd delays: interconnect path delays (delay between components)
            tipd_SCK                => VitalZeroDelay01,
            tipd_SI                 => VitalZeroDelay01,
            tipd_SO                 => VitalZeroDelay01,

            tipd_CSNeg              => VitalZeroDelay01,
            tipd_HOLDNeg            => VitalZeroDelay01,
            tipd_WPNeg              => VitalZeroDelay01,
            tipd_RSTNeg             => VitalZeroDelay01,

            -- tpd delays
            tpd_SCK_SO_normal       => UnitDelay01Z,-- tV
            tpd_CSNeg_SO            => UnitDelay01Z,-- tDIS
            tpd_HOLDNeg_SO          => UnitDelay01Z,--
            tpd_RSTNeg_SO           => UnitDelay01Z,--
            -- DDR operation values
            tpd_SCK_SO_DDR          => UnitDelay01Z,-- tV(66MHz)

            -- tsetup values: setup times
            tsetup_CSNeg_SCK_normal_noedge_posedge => UnitDelay, -- tCSS /
            tsetup_CSNeg_SCK_DDR_noedge_posedge    => UnitDelay, -- tCSS /
            tsetup_SI_SCK_normal_noedge_posedge    => UnitDelay, -- tSU:DAT /
            tsetup_WPNeg_CSNeg      => UnitDelay, -- tWPS \
            tsetup_HOLDNeg_SCK      => UnitDelay,
            tsetup_RSTNeg_CSNeg     => UnitDelay,
            -- DDR operation values
            tsetup_SI_SCK_DDR_noedge_posedge         => UnitDelay,
            tsetup_SI_SCK_DDR_noedge_negedge         => UnitDelay,
            tsetup_SI_SCK_DDR80_noedge_posedge       => UnitDelay,
            tsetup_SI_SCK_DDR80_noedge_negedge       => UnitDelay,

            -- thold values: hold times
            thold_CSNeg_SCK_normal_noedge_posedge  => UnitDelay,--tCSH /
            thold_CSNeg_SCK_DDR_noedge_posedge     => UnitDelay,--tCSH /
            thold_SI_SCK_normal_noedge_posedge     => UnitDelay,--tHD:DAT/
            thold_WPNeg_CSNeg       => UnitDelay,--tWPH /
            thold_HOLDNeg_SCK       => UnitDelay,--
            thold_CSNeg_RSTNeg      => UnitDelay,
            -- DDR operation values
            thold_SI_SCK_DDR_noedge_posedge         => UnitDelay,
            thold_SI_SCK_DDR_noedge_negedge         => UnitDelay,
            thold_SI_SCK_DDR80_noedge_posedge       => UnitDelay,
            thold_SI_SCK_DDR80_noedge_negedge       => UnitDelay,

            --tpw values: pulse width
            tpw_SCK_serial_posedge   => UnitDelay, -- tWH
            tpw_SCK_dual_posedge     => UnitDelay, -- tWH
            --tpw_SCK_ddr80_posedge    => UnitDelay, -- tWH
            tpw_SCK_fast_posedge     => UnitDelay, -- tWH
            tpw_SCK_quadpg_posedge   => UnitDelay, -- tWH
            tpw_SCK_serial_negedge   => UnitDelay, -- tWL
            tpw_SCK_dual_negedge     => UnitDelay, -- tWL
            --tpw_SCK_ddr80_negedge    => UnitDelay, -- tWL
            tpw_SCK_fast_negedge     => UnitDelay, -- tWL
            tpw_SCK_quadpg_negedge   => UnitDelay, -- tWL
            tpw_CSNeg_read_posedge   => UnitDelay, -- tCS
            tpw_CSNeg_pgers_posedge  => UnitDelay, -- tCS
            tpw_RSTNeg_negedge       => UnitDelay, -- tRP
            tpw_RSTNeg_posedge       => UnitDelay, -- tRS
            -- DDR operation values
            tpw_SCK_DDR_posedge      => UnitDelay, -- tWH(66MHz)
            tpw_SCK_DDR_negedge      => UnitDelay, -- tWL
            tpw_SCK_DDR80_posedge    => UnitDelay, -- tWH(80MHz)
            tpw_SCK_DDR80_negedge    => UnitDelay, -- tWL

            -- tperiod min (calculated as 1/max freq)
            tperiod_SCK_serial_rd    => UnitDelay, --fSCK=50MHz
            tperiod_SCK_fast_rd      => UnitDelay, --fSCK=133MHz
            tperiod_SCK_dual_rd      => UnitDelay, --fSCK=104MHz
            tperiod_SCK_quadpg       => UnitDelay, --fSCK=80MHz
            -- DDR operation values
            tperiod_SCK_DDR_rd       => UnitDelay, --fSCK=66MHz

            -- tdevice values: values for internal delays
            -- Page Program Operation (Page Size 256)
            tdevice_PP256           => 750 us,  --tPP
            -- Page Program Operation (Page Size 512)
            tdevice_PP512           => 750 us,  --tPP
            -- Typical Byte Programming Time
            tdevice_BP              => 400 us,  --tBP
                -- Sector Erase Operation(256KB Sectors)
            tdevice_SE256           => 1875 ms, --tSE
                -- Sector Erase Operation(64KB Sectors)
            tdevice_SE64            => 650 ms,  --tSE
            -- Bulk Erase Operation
            tdevice_BE              => 330 sec, --tBE
            -- WRR Cycle Time
            tdevice_WRR             => 200 ms,  --tW
            -- Erase Suspend/Erase Resume Time
            tdevice_ERSSUSP         => 45 us,   --tESL
            -- Program Suspend/Program Resume Time
            tdevice_PRGSUSP         => 40 us,   --
            -- VCC (min) to CS# Low
            tdevice_PU              => 300 us,  --tPU
          -- PPB Erase Time
            tdevice_PPBERASE        => 15 ms,
          -- Password Unlock Time
            tdevice_PASSULCK        => 1 us,
          -- Password Unlock Time
            tdevice_PASSACC         => 100 us,

            -- generic control parameters
            InstancePath      => DefaultInstancePath,
            TimingChecksOn    => TRUE,
            MsgOn             => DefaultMsgOn,
            XOn               => DefaultXon,
            -- memory file to be loaded
            mem_file_name     => "s25fl256s.mem",
            otp_file_name     => "s25fl256sOTP.mem",

            UserPreload       => UserPreload,
            LongTimming       => LongTimming,

            -- For FMF SDF technology file usage
            TimingModel       =>  "S25FL256SAGMFI000_F_30pF"
        )
        PORT MAP(
            SCK        => T_SCK,
            SI         => T_SI,
            SO         => T_SO,
            CSNeg      => T_CSNeg,
            HOLDNeg    => T_HOLDNeg,
            WPNeg      => T_WPNeg,
            RSTNeg     => T_RSTNeg
        );

   Clock_polarity <= '0';--SPI mode: CPO L= 0, CPHA = 0
--      Clock_polarity <= '1';--SPI mode: CPO L= 1, CPHA = 1

    MODE <= DEFAULT_PROTECTION;
--    MODE <= PERSISTENT_PROTECTION;
--    MODE <= PASSWORD_PROTECTION;
 --   MODE <= READ_PASSWORD_PROTECTION;

    PageSize <= 512 WHEN TimingModel(16) = '1' ELSE 256;
    PageNum  <= PageNum256 WHEN TimingModel(16) = '1' ELSE PageNum64;
    SecSize  <= 16#3FFFF# WHEN TimingModel(16) = '1' ELSE 16#FFFF#;
    SecNum   <= 127 WHEN TimingModel(16) = '1' ELSE 511;
    SecNumMax<= 127 WHEN TimingModel(16) = '1' ELSE 541;

    clk_count: PROCESS(T_SCK)
    BEGIN
        IF rising_edge(T_SCK) THEN
            count <= (count+1)mod 8;
        END IF;
    END PROCESS clk_count;

    clk_generation: PROCESS(T_SCK, T_CSNeg)
    BEGIN
        IF T_CSNeg = '1' THEN
            T_SCK <= Clock_polarity;
        ELSE
            T_SCK <= NOT T_SCK AFTER half_period;
        END IF;
    END PROCESS clk_generation;

--At the end of the simulation, if ErrorInTest='0' there were no errors
    err_ctrl : PROCESS ( check_err  )
    BEGIN
        IF check_err = '1' THEN
            ErrorInTest <= '1';
        END IF;
    END PROCESS err_ctrl;

--ASP Register initial state
    asp_initial : PROCESS (ASP_INIT)
    BEGIN
        IF ASP_INIT = 0 THEN
            ASP_reg := to_slv(16#FE4F#,16);
        ELSE
            ASP_reg := to_slv(16#FE7F#,16);
        END IF;
    END PROCESS asp_initial;

tb  :PROCESS

    --------------------------------------------------------------------------
    --= PROCEDURE to select TC
    -- can be modified to read TC list from file, or to generate random list
    --------------------------------------------------------------------------
    PROCEDURE   Pick_TC
        (Model   :  IN  STRING  := "s25fl256s" )
    IS
    BEGIN
    CASE MODE IS
        WHEN DEFAULT_PROTECTION =>
            IF TC_cnt < tc(TS_cnt) THEN
                TC_cnt := TC_cnt+1;
            ELSE
                TC_cnt := 1;
                IF TS_cnt < 41  THEN
                    TS_cnt := TS_cnt+1;
                ELSE
                    IF ErrorInTest='0' THEN
                        REPORT "Test Ended without errors"
                        SEVERITY note;
                    ELSE
                        REPORT "There were errors in test"
                        SEVERITY note;
                    END IF;
                    WAIT;
                END IF;
            END IF;

        WHEN PERSISTENT_PROTECTION =>
            IF TC_cnt < tc(TS_cnt) THEN
                TC_cnt := TC_cnt+1;
            ELSE
                TC_cnt := 1;
                IF TS_cnt = 1 THEN
                    TS_cnt := 2;
                ELSIF TS_cnt = 2 THEN
                    TS_cnt := 42;
                ELSE
                    IF ErrorInTest='0' THEN
                        REPORT "Test Ended without errors"
                        SEVERITY note;
                    ELSE
                        REPORT "There were errors in test"
                        SEVERITY note;
                    END IF;
                    WAIT;
                END IF;
            END IF;

        WHEN PASSWORD_PROTECTION   =>
            IF TC_cnt < tc(TS_cnt) THEN
                TC_cnt := TC_cnt+1;
            ELSE
                TC_cnt := 1;
                IF TS_cnt = 1 THEN
                    TS_cnt := 2;
                ELSIF TS_cnt = 2 THEN
                    TS_cnt := 43;
                ELSIF TS_cnt = 43 THEN
                    TS_cnt := 44;
                ELSE
                    IF ErrorInTest='0' THEN
                        REPORT "Test Ended without errors"
                        SEVERITY note;
                    ELSE
                        REPORT "There were errors in test"
                        SEVERITY note;
                    END IF;
                    WAIT;
                END IF;
            END IF;
        WHEN READ_PASSWORD_PROTECTION   =>
            IF TC_cnt < tc(TS_cnt) THEN
                TC_cnt := TC_cnt+1;
            ELSE
                TC_cnt := 1;
                IF TS_cnt = 1 THEN
                    TS_cnt := 2;
                ELSIF TS_cnt = 2 THEN
                    TS_cnt := 45;
                ELSE
                    IF ErrorInTest='0' THEN
                        REPORT "Test Ended without errors"
                        SEVERITY note;
                    ELSE
                        REPORT "There were errors in test"
                        SEVERITY note;
                    END IF;
                    WAIT;
                END IF;
            END IF;
        END CASE;
    END PROCEDURE Pick_TC;

   ----------------------------------------------------------------------------
    --bus commands, device specific implementation
    ---------------------------------------------------------------------------
    TYPE bus_type IS (bus_idle,
                      bus_select,     --CS# asseretd
                      bus_deselect,   --CS# deasserted after write
                      bus_desel_read, --CS# deasserted after read
                      bus_opcode,
                      bus_reset,
                      bus_address,
                      bus_dummy_byte,
                      bus_dummy_clock,
                      bus_mode_byte,
                      bus_data_read,
                      bus_data_write,
                      bus_st_delay,
                      bus_inv_write); -- write is less then 8 bits

    --bus drive for specific command sequence cycle
    PROCEDURE bus_cycle(
        bus_cmd   :IN   bus_type := bus_idle;
        opcode    :IN   std_logic_vector(7 downto 0) := "00000000";
        data4     :IN   NATURAL RANGE 0 TO 16#FFFF# := 0;
        data3     :IN   NATURAL RANGE 0 TO 16#FFFF# := 0;
        data2     :IN   NATURAL RANGE 0 TO 16#FFFF# := 0;
        data1     :IN   NATURAL RANGE 0 TO 16#FFFF# := 0;
        address   :IN   NATURAL RANGE 0 TO AddrRANGE := 0;
        sector    :IN   INTEGER RANGE 0 TO SecNum64  := 0;
        data_num  :IN   INTEGER RANGE 0 TO AddrRANGE := 0;
        protect   :IN   boolean                      := false;
        pulse     :IN   boolean                      := false;
        pause     :IN   boolean                      := false;
        break     :IN   boolean                      := false;
        PowerUp   :IN   boolean                      := false;
        tm        :IN   TIME                         := 0 ns)
    IS
        VARIABLE tmpA         : std_logic_vector(31 downto 0);
        VARIABLE tmpD         : std_logic_vector(7 downto 0);
        VARIABLE tmpD1        : std_logic_vector(15 downto 0);
        VARIABLE tmpAB        : std_logic_vector(31 downto 0);
        VARIABLE tmpPASS      : std_logic_vector(63 downto 0);
        VARIABLE tmpData      : std_logic_vector(7 downto 0);
        VARIABLE Latency_code : NATURAL;
        VARIABLE EHP          : BOOLEAN;
        VARIABLE data_tmp4    : NATURAL := 0;
        VARIABLE data_tmp3    : NATURAL := 0;
        VARIABLE data_tmp2    : NATURAL := 0;
        VARIABLE data_tmp1    : NATURAL := 0;
        VARIABLE AddrLo       : NATURAL;
        VARIABLE AddrHi       : NATURAL;
        VARIABLE SECT         : NATURAL;

    BEGIN

        SECT := sector;

        IF (TimingModel(15) = '0' OR TimingModel(15) = '2' OR
            TimingModel(15) = '3' OR TimingModel(15) = 'R' OR
            TimingModel(15) = 'A' OR TimingModel(15) = 'B' OR
            TimingModel(15) = 'C' OR TimingModel(15) = 'D' OR
            TimingModel(15) = 'Y' OR TimingModel(15) = 'Z' OR
            TimingModel(15) = 'S' OR TimingModel(15) = 'T' OR
            TimingModel(15) = 'K' OR TimingModel(15) = 'L') THEN
                EHP := TRUE;
        ELSIF (TimingModel(15) = '4' OR TimingModel(15) = '6' OR
               TimingModel(15) = '7' OR TimingModel(15) = '8' OR
               TimingModel(15) = '9' OR TimingModel(15) = 'Q') THEN
                EHP := FALSE;
        END IF;

        IF (TimingModel(15) ='0' OR TimingModel(15) ='2' OR
            TimingModel(15) ='3' OR TimingModel(15) ='R' OR
            TimingModel(15) ='A' OR TimingModel(15) ='B' OR
            TimingModel(15) ='C' OR TimingModel(15) ='D' OR
            TimingModel(15) ='4' OR TimingModel(15) ='6' OR
            TimingModel(15) ='7' OR TimingModel(15) ='8' OR
            TimingModel(15) ='9' OR TimingModel(15) ='Q') THEN
            ASP_INIT   <= 1;
        ELSIF (TimingModel(15) ='Y' OR TimingModel(15) ='Z' OR
               TimingModel(15) ='S' OR TimingModel(15) ='T' OR
               TimingModel(15) ='K' OR TimingModel(15) ='L') THEN
            ASP_INIT   <= 0;
        END IF;

        tmpA := to_slv(ReturnAddr(address,SECT));
        data_tmp4 := data4;
        data_tmp3 := data3;
        data_tmp2 := data2;
        data_tmp1 := data1;
        tmpD := to_slv(data_tmp1, 8);
        tmpD1:= to_slv(data_tmp1, 16);
        tmpAB(15 downto 0) := to_slv(data_tmp1, 16);
        tmpAB(31 downto 16):= to_slv(data_tmp2, 16);
        tmpPASS(63 downto 0):= to_slv(data_tmp4, 16)& to_slv(data_tmp3, 16)&
                               to_slv(data_tmp2, 16)& to_slv(data_tmp1, 16);

        CASE bus_cmd IS

            WHEN bus_idle        =>
                    T_CSNeg    <= '1';
                    IF QUAD = '1' THEN
                        T_HOLDNeg  <= '1';
                    ELSE
                        --Testing if internal pullup works
                        T_HOLDNeg  <= 'Z';
                    END IF;
                    IF protect THEN
                        WAIT FOR 100 ns;
                        T_WPNeg <= not(T_WPNeg);
                    END IF;
                    WAIT FOR 20 ns;

            WHEN bus_select      =>
                T_HOLDNeg  <= '1';
                T_CSNeg <= '0';
                WAIT FOR tm;

            WHEN bus_reset  =>
                T_RSTNeg <= '0', '1' AFTER tm;
                WAIT FOR 30 ns;

            WHEN bus_inv_write        =>
                IF Clock_polarity = '1' THEN
                    WAIT UNTIL falling_edge(T_SCK);
                END IF;
                WAIT FOR 1.5 ns;
                FOR I IN 7 downto (data_num+1) LOOP
                    T_SI <= opcode(i);
                    WAIT FOR 2*half_period;
                END LOOP;
                T_SI <= opcode(data_num);

            WHEN bus_opcode        =>
                IF Clock_polarity = '1' THEN
                    WAIT UNTIL falling_edge(T_SCK);
                END IF;
                IF cmd = fast_ddr_rd OR cmd = fast_ddr_rd4 OR
                   cmd = dual_high_ddr_rd OR cmd = dual_high_ddr_rd4 OR
                   cmd = quad_high_ddr_rd OR cmd = quad_high_ddr_rd_4 THEN
                    WAIT FOR 1.5 ns;
                ELSE
                    WAIT FOR 0.5 ns;
                END IF;
                IF pause = false THEN
                    FOR I IN 7 downto 1 LOOP
                        T_SI <= opcode(i);
                        WAIT FOR 2*half_period;
                    END LOOP;
                    T_SI <= opcode(0);
                ELSE ---assert HOLD#
                    FOR I IN 7 downto 4 LOOP
                        T_SI <= opcode(i);
                        WAIT FOR 2*half_period;
                    END LOOP;
                    T_HOLDNeg <= '0';-- check clock is low here
                    WAIT FOR 6*half_period;
                    T_HOLDNeg <= '1';-- hold rises while clock is low
                    FOR I IN 3 downto 1 LOOP
                        T_SI <= opcode(i);
                        WAIT FOR 2*half_period;
                    END LOOP;
                    T_SI <= opcode(0);
                END IF;
                -- if number of clock pulses isn't multiple of 8
                IF pulse = true THEN
                    WAIT FOR 2*half_period;
                END IF;

            WHEN bus_deselect    =>
                WAIT UNTIL rising_edge(T_SCK);
                IF Clock_polarity = '0' THEN
                    WAIT UNTIL falling_edge(T_SCK);
                ELSE
                    IF half_period = half_period1_srl THEN
                        WAIT FOR 3 ns;
                    ELSIF half_period = half_period_quad THEN
                        WAIT FOR 4.5 ns;
                    ELSIF half_period = half_period_quadpg THEN
                        WAIT FOR 4.5 ns;
                    ELSIF half_period = half_period_ddr THEN
                        WAIT FOR 4.9 ns;
                    END IF;
                END IF;
                T_CSNeg <= '1';

                IF cmd = bank_acc THEN
                    BAR_ACC := 1;
                ELSE
                    BAR_ACC := 0;
                END IF;

                IF break THEN
                    WAIT FOR 15 ns;
                ELSE
                    WAIT FOR 30 ns;
                END IF;

            WHEN bus_desel_read    =>
                IF Clock_polarity = '1' THEN
                    WAIT UNTIL rising_edge(T_SCK);
                    IF half_period = half_period1_srl THEN
                        WAIT FOR 3.5 ns;
                    ELSIF half_period = half_period_quad THEN
                        WAIT FOR 4 ns;
                    ELSE
                        WAIT FOR 5 ns;
                    END IF;
                ELSE
                    IF half_period = half_period1_srl THEN
                        WAIT UNTIL falling_edge(T_SCK);
                    ELSIF half_period = half_period_quad THEN
                        WAIT UNTIL falling_edge(T_SCK);
                    ELSIF half_period = half_period_ddr THEN
                        WAIT UNTIL falling_edge(T_SCK);
                    ELSE
                        WAIT UNTIL falling_edge(T_SCK);
                    END IF;
                END IF;
                T_CSNeg <= '1';
                BAR_ACC := 0;
                IF opcode = I_RDQO OR opcode = I_RDQO4
                OR opcode = I_RDQIO OR opcode = I_RDQIO4
                OR opcode = I_RDDRQ OR opcode = I_RDDRQ4 OR
                   opcode = I_RESET THEN
                    WAIT FOR 2*half_period;
                    T_WPNeg <= '1';
                END IF;

            WHEN bus_address     =>
                --Dual I/O High Performance (3 Bytes Address)
                IF opcode = I_RDDIO AND EXTADD = '0' THEN
                    IF break THEN
                        IF Clock_polarity = '1' THEN
                            WAIT UNTIL falling_edge(T_SCK);
                        END IF;
                    ELSE
                        WAIT UNTIL falling_edge(T_SCK);
                    END IF;
                    WAIT FOR 0.5 ns;
                    IF NOT (pause) THEN
                        FOR I IN 0 TO 10 LOOP
                            T_SO <= tmpA(23-2*i);
                            T_SI <= tmpA(22-2*i);
                            WAIT FOR 2*half_period;
                        END LOOP;
                        T_SO <= tmpA(1);
                        T_SI <= tmpA(0);
                    ELSE
                        FOR I IN 0 TO 6 LOOP
                            T_SO <= tmpA(23-2*i);
                            T_SI <= tmpA(22-2*i);
                            WAIT FOR 2*half_period;
                        END LOOP;
                        T_HOLDNeg <= '0';-- check clock is low here
                        WAIT FOR 6*half_period;
                        T_HOLDNeg <= '1';
                        FOR I IN 7 TO 10 LOOP
                            T_SO <= tmpA(23-2*i);
                            T_SI <= tmpA(22-2*i);
                            WAIT FOR 2*half_period;
                        END LOOP;
                        T_SO <= tmpA(1);
                        T_SI <= tmpA(0);
                    END IF;
                --Dual I/O High Performance (4 Bytes Address)
                ELSIF (opcode = I_RDDIO AND EXTADD = '1') OR
                       opcode = I_RDDIO4 THEN
                    IF break THEN
                        IF Clock_polarity = '1' THEN
                            WAIT UNTIL falling_edge(T_SCK);
                        END IF;
                    ELSE
                        WAIT UNTIL falling_edge(T_SCK);
                    END IF;
                    WAIT FOR 0.5 ns;
                    IF NOT (pause) THEN
                        FOR I IN 0 TO 14 LOOP
                            T_SO <= tmpA(31-2*i);
                            T_SI <= tmpA(30-2*i);
                            WAIT FOR 2*half_period;
                        END LOOP;
                        T_SO <= tmpA(1);
                        T_SI <= tmpA(0);
                    ELSE
                        FOR I IN 0 TO 6 LOOP
                            T_SO <= tmpA(31-2*i);
                            T_SI <= tmpA(30-2*i);
                            WAIT FOR 2*half_period;
                        END LOOP;
                        T_HOLDNeg <= '0';-- check clock is low here
                        WAIT FOR 6*half_period;
                        T_HOLDNeg <= '1';
                        FOR I IN 7 TO 14 LOOP
                            T_SO <= tmpA(31-2*i);
                            T_SI <= tmpA(30-2*i);
                            WAIT FOR 2*half_period;
                        END LOOP;
                        T_SO <= tmpA(1);
                        T_SI <= tmpA(0);
                    END IF;
                --QUAD I/O High Performance (3 Bytes Address)
                ELSIF opcode = I_RDQIO AND EXTADD = '0' THEN
                    IF break THEN
                        IF Clock_polarity = '1' THEN
                            WAIT UNTIL falling_edge(T_SCK);
                        END IF;
                    ELSE
                        WAIT UNTIL falling_edge(T_SCK);
                    END IF;
                    WAIT FOR 0.5 ns;
                    FOR I IN 0 TO 4 LOOP
                        T_HOLDNeg <= tmpA(23-4*i);
                        T_WPNeg   <= tmpA(22-4*i);
                        T_SO      <= tmpA(21-4*i);
                        T_SI      <= tmpA(20-4*i);
                        WAIT FOR 2*half_period;
                    END LOOP;
                    T_HOLDNeg <= tmpA(3);
                    T_WPNeg   <= tmpA(2);
                    T_SO      <= tmpA(1);
                    T_SI      <= tmpA(0);
                --QUAD I/O High Performance (4 Bytes Address)
                ELSIF (opcode = I_RDQIO AND EXTADD = '1') OR
                       opcode = I_RDQIO4 THEN
                    IF break THEN
                        IF Clock_polarity = '1' THEN
                            WAIT UNTIL falling_edge(T_SCK);
                        END IF;
                    ELSE
                        WAIT UNTIL falling_edge(T_SCK);
                    END IF;
                    WAIT FOR 0.5 ns;
                    FOR I IN 0 TO 6 LOOP
                        T_HOLDNeg <= tmpA(31-4*i);
                        T_WPNeg   <= tmpA(30-4*i);
                        T_SO <= tmpA(29-4*i);
                        T_SI <= tmpA(28-4*i);
                        WAIT FOR 2*half_period;
                    END LOOP;
                    T_HOLDNeg <= tmpA(3);
                    T_WPNeg   <= tmpA(2);
                    T_SO <= tmpA(1);
                    T_SI <= tmpA(0);
                --Fast DDR Read Mode (3 Bytes Address)
                ELSIF (opcode = I_FDDR AND EXTADD= '0' ) THEN
                    IF break THEN
                        IF Clock_polarity = '1' THEN
                            WAIT UNTIL falling_edge(T_SCK);
                        END IF;
                            T_SI <= tmpA(23);
                        FOR I IN 22 downto 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 3 ns;
                            T_SI <= tmpA(i);
                        END LOOP;
                    ELSE
                        WAIT UNTIL rising_edge(T_SCK);
                        FOR I IN 23 downto 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 3 ns;
                            T_SI <= tmpA(i);
                        END LOOP;
                    END IF;
                --Fast DDR Read Mode (4 Bytes Address)
                ELSIF (opcode = I_FDDR4 OR
                      (opcode = I_FDDR AND EXTADD= '1' ))THEN
                    IF break THEN
                        IF Clock_polarity = '1' THEN
                            WAIT UNTIL falling_edge(T_SCK);
                        END IF;
                            T_SI <= tmpA(31);
                        FOR I IN 30 downto 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 3 ns;
                            T_SI <= tmpA(i);
                        END LOOP;
                    ELSE
                        WAIT UNTIL rising_edge(T_SCK);
                        FOR I IN 31 downto 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 3 ns;
                            T_SI <= tmpA(i);
                        END LOOP;
                    END IF;
                --Dual I/O DDR Read Mode (3 Bytes Address)
                ELSIF (opcode = I_RDDRD AND EXTADD= '0' ) THEN
                    IF break THEN
                        IF Clock_polarity = '1' THEN
                            WAIT UNTIL falling_edge(T_SCK);
                        END IF;
                        T_SO <= tmpA(23);
                        T_SI <= tmpA(22);
                        FOR I IN 10 downto 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 3 ns;
                            T_SO <= tmpA(2*i+1);
                            T_SI <= tmpA(2*i);
                        END LOOP;
                    ELSE
                        WAIT UNTIL rising_edge(T_SCK);
                        FOR I IN 11 downto 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 3 ns;
                            T_SO <= tmpA(2*i+1);
                            T_SI <= tmpA(2*i);
                        END LOOP;
                    END IF;
                --Dual I/O DDR Read Mode (4 Bytes Address)
                ELSIF (opcode = I_RDDRD4 OR
                      (opcode = I_RDDRD AND EXTADD= '1' ))  THEN
                    IF break THEN
                        IF Clock_polarity = '1' THEN
                            WAIT UNTIL falling_edge(T_SCK);
                        END IF;
                        T_SO <= tmpA(31);
                        T_SI <= tmpA(30);
                        FOR I IN 14 downto 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 3 ns;
                            T_SO <= tmpA(2*i+1);
                            T_SI <= tmpA(2*i);
                        END LOOP;
                    ELSE
                        WAIT UNTIL rising_edge(T_SCK);
                        FOR I IN 15 downto 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 3 ns;
                            T_SO <= tmpA(2*i+1);
                            T_SI <= tmpA(2*i);
                        END LOOP;
                    END IF;
                --QUAD I/O DDR Read Mode (3 Bytes Address)
                ELSIF (opcode = I_RDDRQ AND EXTADD= '0' ) THEN
                    IF break THEN
                        IF Clock_polarity = '1' THEN
                            WAIT UNTIL falling_edge(T_SCK);
                        END IF;
                        T_HOLDNeg <= tmpA(23);
                        T_WPNeg   <= tmpA(22);
                        T_SO <= tmpA(21);
                        T_SI <= tmpA(20);
                        FOR I IN 4 downto 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 2.5 ns;
                            T_HOLDNeg <= tmpA(4*i+3);
                            T_WPNeg   <= tmpA(4*i+2);
                            T_SO      <= tmpA(4*i+1);
                            T_SI      <= tmpA(4*i);
                        END LOOP;
                    ELSE
                        WAIT UNTIL rising_edge(T_SCK);
                        FOR I IN 5 downto 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 2.5 ns;
                            T_HOLDNeg <= tmpA(4*i+3);
                            T_WPNeg   <= tmpA(4*i+2);
                            T_SO      <= tmpA(4*i+1);
                            T_SI      <= tmpA(4*i);
                        END LOOP;
                    END IF;
                ELSIF (opcode = I_RDDRQ4 OR
                      (opcode = I_RDDRQ AND EXTADD= '1' ))  THEN
                    IF break THEN
                        IF Clock_polarity = '1' THEN
                            WAIT UNTIL falling_edge(T_SCK);
                        END IF;
                        T_HOLDNeg <= tmpA(31);
                        T_WPNeg   <= tmpA(30);
                        T_SO <= tmpA(29);
                        T_SI <= tmpA(28);
                        FOR I IN 6 downto 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 2.5 ns;
                            T_HOLDNeg <= tmpA(4*i+3);
                            T_WPNeg   <= tmpA(4*i+2);
                            T_SO      <= tmpA(4*i+1);
                            T_SI      <= tmpA(4*i);
                        END LOOP;
                    ELSE
                        WAIT UNTIL rising_edge(T_SCK);
                        FOR I IN 7 downto 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 2.5 ns;
                            T_HOLDNeg <= tmpA(4*i+3);
                            T_WPNeg   <= tmpA(4*i+2);
                            T_SO      <= tmpA(4*i+1);
                            T_SI      <= tmpA(4*i);
                        END LOOP;
                    END IF;
                --4 Bytes Address
                ELSIF opcode = I_RD4 OR opcode = I_PP4 OR opcode = I_QPP4 OR
                      opcode =I_SE4 OR opcode = I_FSTRD4 OR opcode = I_RDDO4 OR
                      opcode =I_RDQO4 OR opcode = I_FSTRD4 OR opcode=I_DYBRD OR
                      opcode=I_PPBP OR opcode=I_DYBWR OR opcode = I_P4E4 OR
                      opcode = I_PPBRD OR opcode = I_ECCRD OR
                      ((opcode = I_READ OR opcode = I_PP OR opcode = I_QPP OR
                        opcode =I_SE OR opcode =I_FSTRD OR opcode =I_RDDO OR
                        opcode =I_RDQO) AND EXTADD = '1') THEN
                    WAIT UNTIL falling_edge(T_SCK);
                    WAIT FOR 0.5 ns;
                    IF pause = false THEN
                        FOR I IN 31 downto 1 LOOP
                            T_SI <= tmpA(i);
                            WAIT FOR 2*half_period;
                        END LOOP;
                        T_SI <= tmpA(0);
                    ELSE
                        FOR I IN 31 downto 4 LOOP
                            T_SI <= tmpA(i);
                            WAIT FOR 2*half_period;
                        END LOOP;
                        T_HOLDNeg <= '0';-- check clock is low here
                        WAIT FOR 6*half_period;
                        T_HOLDNeg <= '1';-- hold rises while clock is low
                        FOR I IN 3 downto 1 LOOP
                            T_SI <= tmpA(i);
                            WAIT FOR 2*half_period;
                        END LOOP;
                        T_SI <= tmpA(0);
                    END IF;
                ELSE                   --3 Bytes Address
                    WAIT UNTIL falling_edge(T_SCK);
                    WAIT FOR 0.5 ns;
                    IF pause = false THEN
                        FOR I IN 23 downto 1 LOOP
                            T_SI <= tmpA(i);
                            WAIT FOR 2*half_period;
                        END LOOP;
                        T_SI <= tmpA(0);
                    ELSE
                        FOR I IN 23 downto 4 LOOP
                            T_SI <= tmpA(i);
                            WAIT FOR 2*half_period;
                        END LOOP;
                        T_HOLDNeg <= '0';-- check clock is low here
                        WAIT FOR 6*half_period;
                        T_HOLDNeg <= '1';-- hold rises while clock is low
                        FOR I IN 3 downto 1 LOOP
                            T_SI <= tmpA(i);
                            WAIT FOR 2*half_period;
                        END LOOP;
                        T_SI <= tmpA(0);
                    END IF;
                END IF;

            WHEN bus_mode_byte  =>
                IF opcode = I_RDDIO OR opcode = I_RDDIO4 THEN
                    WAIT UNTIL falling_edge(T_SCK);
                    WAIT FOR 1.5 ns;
                    FOR I IN 0 to 2 LOOP
                        T_SO <= tmpD(7-2*i);
                        T_SI <= tmpD(6-2*i);
                        WAIT FOR 2*half_period;
                    END LOOP;
                    T_SO <= tmpD(1);
                    T_SI <= tmpD(0);
                ELSIF opcode = I_RDQIO OR opcode = I_RDQIO4 THEN
                    WAIT UNTIL falling_edge(T_SCK);
                    WAIT FOR 1.5 ns;
                    T_HOLDNeg <= tmpD(7);
                    T_WPNeg   <= tmpD(6);
                    T_SO <= tmpD(5);
                    T_SI <= tmpD(4);
                    WAIT FOR 2*half_period;
                    T_HOLDNeg <= tmpD(3);
                    T_WPNeg   <= tmpD(2);
                    T_SO <= tmpD(1);
                    T_SI <= tmpD(0);
                ELSIF opcode = I_FDDR OR opcode = I_FDDR4 THEN
                    WAIT UNTIL T_SCK'EVENT;
                    WAIT FOR 3 ns;
                    FOR I IN 7 downto 1 LOOP
                        T_SI <= tmpD(i);
                        WAIT FOR half_period;
                    END LOOP;
                    T_SI <= tmpD(0);
                ELSIF opcode = I_RDDRD OR opcode = I_RDDRD4 THEN
                    WAIT UNTIL T_SCK'EVENT;
                    WAIT FOR 3 ns;
                    FOR I IN 3 downto 1 LOOP
                        T_SO <= tmpD(2*i+1);
                        T_SI <= tmpD(2*i);
                        WAIT FOR half_period;
                    END LOOP;
                    T_SO <= tmpD(1);
                    T_SI <= tmpD(0);
                ELSIF opcode = I_RDDRQ OR opcode = I_RDDRQ4 THEN
                    WAIT UNTIL T_SCK'EVENT;
                    WAIT FOR 3 ns;
                    T_HOLDNeg <= tmpD(7);
                    T_WPNeg   <= tmpD(6);
                    T_SO      <= tmpD(5);
                    T_SI      <= tmpD(4);
                    WAIT FOR half_period;
                    T_HOLDNeg <= tmpD(3);
                    T_WPNeg   <= tmpD(2);
                    T_SO      <= tmpD(1);
                    T_SI      <= tmpD(0);
                END IF;

            WHEN bus_dummy_byte  =>
                Latency_code := to_nat(LC1 & LC0);
                IF opcode = I_RES THEN
                    FOR I IN 2 downto 1 LOOP
                        WAIT UNTIL falling_edge(T_SCK);
                        WAIT FOR 0.5 ns;
                        FOR I IN 7 downto 0 LOOP
                            T_SI <= '0';
                            WAIT FOR 2*half_period;
                        END LOOP;
                    END LOOP;
                    FOR I IN 7 downto 1 LOOP
                        T_SI <= '0';
                        WAIT FOR 2*half_period;
                    END LOOP;
                    T_SI <= '0';
                ELSIF opcode = I_ECCRD THEN
                    FOR I IN 7 downto 1 LOOP
                        WAIT UNTIL falling_edge(T_SCK);
                        WAIT FOR 0.5 ns;
                        FOR I IN 7 downto 0 LOOP
                            T_SI <= '0';
                            WAIT FOR 2*half_period;
                        END LOOP;
                    END LOOP;
                    FOR I IN 7 downto 1 LOOP
                        T_SI <= '0';
                        WAIT FOR 2*half_period;
                    END LOOP;
                    T_SI <= '0';
                ELSIF (opcode = I_FSTRD OR opcode = I_FSTRD4 OR
                       opcode = I_RDDO  OR opcode = I_RDDO4 OR
                       opcode = I_OTPR OR opcode = I_RDQO  OR
                       opcode = I_RDQO4) THEN
                    IF Latency_code /= 3 THEN
                        WAIT UNTIL falling_edge(T_SCK);
                        WAIT FOR 0.5 ns;
                        IF pause = false THEN
                            FOR I IN 7 downto 1 LOOP
                                T_SI <= '0';
                                WAIT FOR 2*half_period;
                            END LOOP;
                            T_SI <= '0';
                        ELSE
                            FOR I IN 7 downto 4 LOOP
                                T_SI <= '0';
                                WAIT FOR 2*half_period;
                            END LOOP;
                            T_HOLDNeg <= '0';-- check clock is low here
                            WAIT FOR 6*half_period;
                            T_HOLDNeg <= '1';-- hold rises while clock is low
                            FOR I IN 3 downto 1 LOOP
                                T_SI <= '0';
                                WAIT FOR 2*half_period;
                            END LOOP;
                            T_SI <= '0';
                        END IF;
                    END IF;
                ELSIF (opcode = I_FDDR OR opcode = I_FDDR4) THEN
                    IF EHP THEN
                        IF Latency_code = 0 THEN
                            WAIT UNTIL falling_edge(T_SCK);
                            WAIT FOR 2 ns;
                            T_SI <= '0';
                            WAIT FOR 2*half_period;
                            T_SI <= '0';
                        ELSIF Latency_code = 1 THEN
                            FOR I IN 3 DOWNTO 1 LOOP
                                WAIT UNTIL falling_edge(T_SCK);
                                WAIT FOR 2 ns;
                                T_SI <= '0';
                            END LOOP;
                            WAIT FOR 2*half_period;
                            T_SI <= '0';
                        ELSIF Latency_code = 2 THEN
                            FOR I IN 4 DOWNTO 1 LOOP
                                WAIT UNTIL falling_edge(T_SCK);
                                WAIT FOR 2 ns;
                                T_SI <= '0';
                            END LOOP;
                            WAIT FOR 2*half_period;
                            T_SI <= '0';
                        ELSIF Latency_code = 3 THEN
                            WAIT UNTIL falling_edge(T_SCK);
                            WAIT FOR 2 ns;
                            T_SI <= '0';
                        END IF;
                    ELSE
                        IF Latency_code = 0 THEN
                            FOR I IN 4 DOWNTO 1 LOOP
                                WAIT UNTIL falling_edge(T_SCK);
                                WAIT FOR 2 ns;
                                T_SI <= '0';
                            END LOOP;
                            WAIT FOR 2*half_period;
                            T_SI <= '0';
                        ELSIF Latency_code = 1 THEN
                            FOR I IN 5 DOWNTO 1 LOOP
                                WAIT UNTIL falling_edge(T_SCK);
                                WAIT FOR 2 ns;
                                T_SI <= '0';
                            END LOOP;
                            WAIT FOR 2*half_period;
                            T_SI <= '0';
                        ELSIF Latency_code = 2 THEN
                            FOR I IN 6 DOWNTO 1 LOOP
                                WAIT UNTIL falling_edge(T_SCK);
                                WAIT FOR 2 ns;
                                T_SI <= '0';
                            END LOOP;
                            WAIT FOR 2*half_period;
                            T_SI <= '0';
                        ELSIF Latency_code = 3 THEN
                            FOR I IN 3 DOWNTO 1 LOOP
                                WAIT UNTIL falling_edge(T_SCK);
                                WAIT FOR 2 ns;
                                T_SI <= '0';
                            END LOOP;
                            WAIT FOR 2*half_period;
                            T_SI <= '0';
                        END IF;
                    END IF;
                END IF;

            WHEN bus_dummy_clock  =>
                Latency_code := to_nat(LC1 & LC0);
                IF (opcode = I_RDDIO OR opcode = I_RDDIO4) THEN
                    IF EHP THEN
                        IF Latency_code = 2 THEN
                            WAIT UNTIL falling_edge(T_SCK);
                            WAIT FOR 1.5 ns;
                            T_SI <= 'X';
                            T_SO <= 'X';
                            WAIT FOR 2*half_period;
                            T_SI <= 'X';
                        ELSIF Latency_code = 1 THEN
                            WAIT UNTIL falling_edge(T_SCK);
                            WAIT FOR 1.5 ns;
                            T_SI <= 'X';
                            T_SO <= 'X';
                        END IF;
                    ELSE
                        IF Latency_code = 0 THEN
                            FOR I IN 3 DOWNTO 1 LOOP
                                WAIT UNTIL falling_edge(T_SCK);
                                WAIT FOR 1.5 ns;
                                T_SI <= 'X';
                                T_SO <= 'X';
                            END LOOP;
                            WAIT FOR 2*half_period;
                            T_SI <= 'X';
                            T_SO <= 'X';
                        ELSIF Latency_code = 1 THEN
                            FOR I IN 4 DOWNTO 1 LOOP
                                WAIT UNTIL falling_edge(T_SCK);
                                WAIT FOR 1.5 ns;
                                T_SI <= 'X';
                                T_SO <= 'X';
                            END LOOP;
                            WAIT FOR 2*half_period;
                            T_SI <= 'X';
                            T_SO <= 'X';
                        ELSIF Latency_code = 2 THEN
                            FOR I IN 5 DOWNTO 1 LOOP
                                WAIT UNTIL falling_edge(T_SCK);
                                WAIT FOR 1.5 ns;
                                T_SI <= 'X';
                                T_SO <= 'X';
                            END LOOP;
                            WAIT FOR 2*half_period;
                            T_SI <= 'X';
                            T_SO <= 'X';
                        ELSIF Latency_code = 3 THEN
                            FOR I IN 3 DOWNTO 1 LOOP
                                WAIT UNTIL falling_edge(T_SCK);
                                WAIT FOR 1.5 ns;
                                T_SI <= 'X';
                                T_SO <= 'X';
                            END LOOP;
                            WAIT FOR 2*half_period;
                            T_SI <= 'X';
                            T_SO <= 'X';
                        END IF;
                    END IF;
                ELSIF (opcode = I_RDQIO OR opcode = I_RDQIO4) THEN
                    IF Latency_code = 3 THEN
                        WAIT UNTIL falling_edge(T_SCK);
                        WAIT FOR 1.5 ns;
                        T_HOLDNeg <= 'X';
                        T_WPNeg   <= 'X';
                        T_SI      <= 'X';
                        T_SO      <= 'X';
                    ELSIF Latency_code = 0 THEN
                        FOR I IN 3 DOWNTO 1 LOOP
                            WAIT UNTIL falling_edge(T_SCK);
                            WAIT FOR 1.5 ns;
                            T_HOLDNeg <= 'X';
                            T_WPNeg   <= 'X';
                            T_SI      <= 'X';
                            T_SO      <= 'X';
                        END LOOP;
                        WAIT FOR 2*half_period;
                        T_HOLDNeg <= 'X';
                        T_WPNeg   <= 'X';
                        T_SI      <= 'X';
                        T_SO      <= 'X';
                    ELSIF Latency_code = 1 THEN
                        FOR I IN 3 DOWNTO 1 LOOP
                            WAIT UNTIL falling_edge(T_SCK);
                            WAIT FOR 1.5 ns;
                            T_HOLDNeg <= 'X';
                            T_WPNeg   <= 'X';
                            T_SI      <= 'X';
                            T_SO      <= 'X';
                        END LOOP;
                        WAIT FOR 2*half_period;
                        T_HOLDNeg <= 'X';
                        T_WPNeg   <= 'X';
                        T_SI      <= 'X';
                        T_SO      <= 'X';
                    ELSIF Latency_code = 2 THEN
                        FOR I IN 4 DOWNTO 1 LOOP
                            WAIT UNTIL falling_edge(T_SCK);
                            WAIT FOR 1.5 ns;
                            T_HOLDNeg <= 'X';
                            T_WPNeg   <= 'X';
                            T_SI      <= 'X';
                            T_SO      <= 'X';
                        END LOOP;
                        WAIT FOR 2*half_period;
                        T_HOLDNeg <= 'X';
                        T_WPNeg   <= 'X';
                        T_SI      <= 'X';
                        T_SO      <= 'X';
                    END IF;
                ELSIF opcode = I_RDDRD OR opcode = I_RDDRD4 THEN
                    IF EHP THEN
                        IF Latency_code = 0 THEN
                            IF (VDLR_reg /= "00000000") THEN
                                FOR I IN 3 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_SI <= 'Z';
                                    T_SO <= 'Z';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_SI <= 'Z';
                                T_SO <= 'Z';
                            ELSE
                                FOR I IN 3 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_SI <= 'X';
                                    T_SO <= 'X';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_SI <= 'X';
                                T_SO <= 'X';
                            END IF;
                        ELSIF Latency_code = 1 THEN
                            IF (VDLR_reg /= "00000000") THEN
                                FOR I IN 4 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_SI <= 'Z';
                                    T_SO <= 'Z';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_SI <= 'Z';
                                T_SO <= 'Z';
                            ELSE
                                FOR I IN 4 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_SI <= 'X';
                                    T_SO <= 'X';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_SI <= 'X';
                                T_SO <= 'X';
                            END IF;
                        ELSIF Latency_code = 2 THEN
                            IF (VDLR_reg /= "00000000") THEN
                                FOR I IN 5 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                T_SI <= 'Z';
                                T_SO <= 'Z';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_SI <= 'Z';
                                T_SO <= 'Z';
                            ELSE
                                FOR I IN 5 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                T_SI <= 'X';
                                T_SO <= 'X';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_SI <= 'X';
                                T_SO <= 'X';
                            END IF;
                        ELSIF Latency_code = 3 THEN
                            WAIT UNTIL falling_edge(T_SCK);
                            WAIT FOR 2 ns;
                            T_SI <= 'X';
                            T_SO <= 'X';
                            WAIT FOR 2*half_period;
                            T_SI <= 'X';
                            T_SO <= 'X';
                        END IF;
                    ELSE
                        IF Latency_code = 0 THEN
                            IF (VDLR_reg /= "00000000") THEN
                                FOR I IN 5 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_SI <= 'Z';
                                    T_SO <= 'Z';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_SI <= 'Z';
                                T_SO <= 'Z';
                            ELSE
                                FOR I IN 5 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_SI <= 'X';
                                    T_SO <= 'X';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_SI <= 'X';
                                T_SO <= 'X';
                            END IF;
                        ELSIF Latency_code = 1 THEN
                            IF (VDLR_reg /= "00000000") THEN
                                FOR I IN 6 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_SI <= 'Z';
                                    T_SO <= 'Z';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_SI <= 'Z';
                                T_SO <= 'Z';
                            ELSE
                                FOR I IN 6 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_SI <= 'X';
                                    T_SO <= 'X';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_SI <= 'X';
                                T_SO <= 'X';
                            END IF;
                        ELSIF Latency_code = 2 THEN
                            IF (VDLR_reg /= "00000000") THEN
                                FOR I IN 7 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_SI <= 'Z';
                                    T_SO <= 'Z';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_SI <= 'Z';
                                T_SO <= 'Z';
                            ELSE
                                FOR I IN 7 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_SI <= 'X';
                                    T_SO <= 'X';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_SI <= 'X';
                                T_SO <= 'X';
                            END IF;
                        ELSIF Latency_code = 3 THEN
                            IF (VDLR_reg /= "00000000") THEN
                                FOR I IN 3 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_SI <= 'Z';
                                    T_SO <= 'Z';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_SI <= 'Z';
                                T_SO <= 'Z';
                            ELSE
                                FOR I IN 3 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_SI <= 'X';
                                    T_SO <= 'X';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_SI <= 'X';
                                T_SO <= 'X';
                            END IF;
                        END IF;
                    END IF;
                ELSIF opcode = I_RDDRQ OR opcode = I_RDDRQ4 THEN
                    IF EHP THEN
                        IF Latency_code = 0 THEN
                            IF (VDLR_reg /= "00000000") THEN
                                FOR I IN 5 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_HOLDNeg <= 'Z';
                                    T_WPNeg   <= 'Z';
                                    T_SI      <= 'Z';
                                    T_SO      <= 'Z';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_HOLDNeg <= 'Z';
                                T_WPNeg   <= 'Z';
                                T_SI      <= 'Z';
                                T_SO      <= 'Z';
                            ELSE
                                FOR I IN 5 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_HOLDNeg <= 'X';
                                    T_WPNeg   <= 'X';
                                    T_SI      <= 'X';
                                    T_SO      <= 'X';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_HOLDNeg <= 'X';
                                T_WPNeg   <= 'X';
                                T_SI      <= 'X';
                                T_SO      <= 'X';
                            END IF;
                        ELSIF Latency_code = 1 THEN
                            IF (VDLR_reg /= "00000000") THEN
                                FOR I IN 6 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_HOLDNeg <= 'Z';
                                    T_WPNeg   <= 'Z';
                                    T_SI      <= 'Z';
                                    T_SO      <= 'Z';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_HOLDNeg <= 'Z';
                                T_WPNeg   <= 'Z';
                                T_SI      <= 'Z';
                                T_SO      <= 'Z';
                            ELSE
                                FOR I IN 6 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_HOLDNeg <= 'X';
                                    T_WPNeg   <= 'X';
                                    T_SI      <= 'X';
                                    T_SO      <= 'X';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_HOLDNeg <= 'X';
                                T_WPNeg   <= 'X';
                                T_SI      <= 'X';
                                T_SO      <= 'X';
                            END IF;
                        ELSIF Latency_code = 2 THEN
                            IF (VDLR_reg /= "00000000") THEN
                                FOR I IN 7 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_HOLDNeg <= 'Z';
                                    T_WPNeg   <= 'Z';
                                    T_SI      <= 'Z';
                                    T_SO      <= 'Z';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_HOLDNeg <= 'Z';
                                T_WPNeg   <= 'Z';
                                T_SI      <= 'Z';
                                T_SO      <= 'Z';
                            ELSE
                                FOR I IN 7 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_HOLDNeg <= 'X';
                                    T_WPNeg   <= 'X';
                                    T_SI      <= 'X';
                                    T_SO      <= 'X';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_HOLDNeg <= 'X';
                                T_WPNeg   <= 'X';
                                T_SI      <= 'X';
                                T_SO      <= 'X';
                            END IF;
                        ELSIF Latency_code = 3 THEN
                            FOR I IN 2 DOWNTO 1 LOOP
                                WAIT UNTIL falling_edge(T_SCK);
                                WAIT FOR 2 ns;
                                T_HOLDNeg <= 'X';
                                T_WPNeg   <= 'X';
                                T_SI      <= 'X';
                                T_SO      <= 'X';
                            END LOOP;
                            WAIT FOR 2*half_period;
                            T_HOLDNeg <= 'X';
                            T_WPNeg   <= 'X';
                            T_SI      <= 'X';
                            T_SO      <= 'X';
                        END IF;
                    ELSE
                        IF Latency_code = 0 THEN
                            IF (VDLR_reg /= "00000000") THEN
                                FOR I IN 5 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_HOLDNeg <= 'Z';
                                    T_WPNeg   <= 'Z';
                                    T_SI      <= 'Z';
                                    T_SO      <= 'Z';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_HOLDNeg <= 'Z';
                                T_WPNeg   <= 'Z';
                                T_SI      <= 'Z';
                                T_SO      <= 'Z';
                            ELSE
                                FOR I IN 5 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_HOLDNeg <= 'X';
                                    T_WPNeg   <= 'X';
                                    T_SI      <= 'X';
                                    T_SO      <= 'X';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_HOLDNeg <= 'X';
                                T_WPNeg   <= 'X';
                                T_SI      <= 'X';
                                T_SO      <= 'X';
                            END IF;
                        ELSIF Latency_code = 1 THEN
                            IF (VDLR_reg /= "00000000") THEN
                                FOR I IN 6 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_HOLDNeg <= 'Z';
                                    T_WPNeg   <= 'Z';
                                    T_SI      <= 'Z';
                                    T_SO      <= 'Z';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_HOLDNeg <= 'Z';
                                T_WPNeg   <= 'Z';
                                T_SI      <= 'Z';
                                T_SO      <= 'Z';
                            ELSE
                                FOR I IN 6 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_HOLDNeg <= 'X';
                                    T_WPNeg   <= 'X';
                                    T_SI      <= 'X';
                                    T_SO      <= 'X';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_HOLDNeg <= 'X';
                                T_WPNeg   <= 'X';
                                T_SI      <= 'X';
                                T_SO      <= 'X';
                            END IF;
                        ELSIF Latency_code = 2 THEN
                            IF (VDLR_reg /= "00000000") THEN
                                FOR I IN 7 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_HOLDNeg <= 'Z';
                                    T_WPNeg   <= 'Z';
                                    T_SI      <= 'Z';
                                    T_SO      <= 'Z';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_HOLDNeg <= 'Z';
                                T_WPNeg   <= 'Z';
                                T_SI      <= 'Z';
                                T_SO      <= 'Z';
                            ELSE
                                FOR I IN 7 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_HOLDNeg <= 'X';
                                    T_WPNeg   <= 'X';
                                    T_SI      <= 'X';
                                    T_SO      <= 'X';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_HOLDNeg <= 'X';
                                T_WPNeg   <= 'X';
                                T_SI      <= 'X';
                                T_SO      <= 'X';
                            END IF;
                        ELSIF Latency_code = 3 THEN
                            IF (VDLR_reg /= "00000000") THEN
                                FOR I IN 3 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_HOLDNeg <= 'Z';
                                    T_WPNeg   <= 'Z';
                                    T_SI      <= 'Z';
                                    T_SO      <= 'Z';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_HOLDNeg <= 'Z';
                                T_WPNeg   <= 'Z';
                                T_SI      <= 'Z';
                                T_SO      <= 'Z';
                            ELSE
                                FOR I IN 2 DOWNTO 1 LOOP
                                    WAIT UNTIL falling_edge(T_SCK);
                                    WAIT FOR 2 ns;
                                    T_HOLDNeg <= 'X';
                                    T_WPNeg   <= 'X';
                                    T_SI      <= 'X';
                                    T_SO      <= 'X';
                                END LOOP;
                                WAIT FOR 2*half_period;
                                T_HOLDNeg <= 'X';
                                T_WPNeg   <= 'X';
                                T_SI      <= 'X';
                                T_SO      <= 'X';
                            END IF;
                        END IF;
                    END IF;
                END IF;

            WHEN bus_data_read   =>

                WAIT FOR 9 ns;
                IF opcode = I_RDDO OR opcode = I_RDDO4 OR
                   opcode = I_RDDIO OR opcode = I_RDDIO4 OR
                   opcode = I_RDDRD OR opcode = I_RDDRD4 THEN
                    T_SO <= 'Z';
                    T_SI <= 'Z';
                ELSIF opcode = I_RDQO OR opcode = I_RDQO4 OR
                      opcode = I_RDQIO OR opcode = I_RDQIO4 OR
                      opcode = I_RDDRQ OR opcode = I_RDDRQ4 OR
                      (opcode = I_RESET AND ABE = '1' AND QUAD = '1') THEN
                    T_SO      <= 'Z';
                    T_SI      <= 'Z';
                    T_WPNeg   <= 'Z';
                    T_HOLDNeg <= 'Z';
                ELSE
                    T_SO <= 'Z';
                END IF;
                IF break = true THEN
                    FOR I IN data_num-1 downto 0 LOOP
                        WAIT UNTIL falling_edge(T_SCK);
                        WAIT FOR 8 ns;
                    END LOOP;
                ELSIF pause = false THEN
                    IF opcode = I_RDDO OR opcode = I_RDDO4 OR
                       opcode =I_RDDIO OR opcode = I_RDDIO4 THEN
                        FOR I IN data_num-1 DOWNTO 0 LOOP
                            FOR I IN 3 downto 0 LOOP
                                WAIT UNTIL falling_edge(T_SCK);
                                WAIT FOR 8 ns;
                            END LOOP;
                        END LOOP;
                    ELSIF opcode = I_RDQO OR opcode = I_RDQO4 OR
                          opcode = I_RDQIO OR opcode = I_RDQIO4 THEN
                        FOR I IN data_num-1 DOWNTO 0 LOOP
                            FOR I IN 1 downto 0 LOOP
                                WAIT UNTIL falling_edge(T_SCK);
                                WAIT FOR 6 ns;
                            END LOOP;
                        END LOOP;
                    ELSIF (opcode = I_RESET AND ABE = '1' AND QUAD = '1') THEN
                        FOR I IN data_num-1 DOWNTO 0 LOOP
                            IF I = data_num-1 THEN
                                WAIT UNTIL rising_edge(T_SCK);
                                WAIT FOR 3 ns;
                            END IF;
                            FOR I IN 1 downto 0 LOOP
                                WAIT UNTIL falling_edge(T_SCK);
                                WAIT FOR 6 ns;
                            END LOOP;
                        END LOOP;
                    ELSIF opcode = I_FDDR OR opcode = I_FDDR4 THEN
                        FOR I IN data_num-1 DOWNTO 0 LOOP
                            FOR I IN 7 downto 0 LOOP
                                WAIT UNTIL T_SCK'EVENT;
                                WAIT FOR 4 ns;
                            END LOOP;
                        END LOOP;
                    ELSIF opcode = I_RDDRD OR opcode = I_RDDRD4 THEN
                        FOR I IN data_num-1 DOWNTO 0 LOOP
                            FOR I IN 3 downto 0 LOOP
                                WAIT UNTIL T_SCK'EVENT;
                                WAIT FOR 4 ns;
                            END LOOP;
                        END LOOP;
                    ELSIF opcode = I_RDDRQ OR opcode = I_RDDRQ4 THEN
                        FOR I IN data_num-1 DOWNTO 0 LOOP
                            FOR I IN 1 downto 0 LOOP
                                WAIT UNTIL T_SCK'EVENT;
                                WAIT FOR 4 ns;
                            END LOOP;
                        END LOOP;
                    ELSIF opcode = I_ABRD THEN
                        FOR I IN data_num-1 DOWNTO 0 LOOP
                            FOR I IN 31 downto 0 LOOP
                                WAIT UNTIL falling_edge(T_SCK);
                                WAIT FOR 3 ns;
                            END LOOP;
                        END LOOP;
                    ELSIF opcode = I_ASPRD THEN
                        FOR I IN data_num-1 DOWNTO 0 LOOP
                            FOR I IN 15 downto 0 LOOP
                                WAIT UNTIL falling_edge(T_SCK);
                                WAIT FOR 3 ns;
                            END LOOP;
                        END LOOP;
                    ELSIF opcode = I_PASSRD THEN
                        FOR I IN data_num-1 DOWNTO 0 LOOP
                            FOR I IN 63 downto 0 LOOP
                                WAIT UNTIL falling_edge(T_SCK);
                                WAIT FOR 3 ns;
                            END LOOP;
                        END LOOP;
                    ELSE
                        FOR I IN data_num-1 DOWNTO 0 LOOP
                            FOR I IN 7 downto 0 LOOP
                                WAIT UNTIL falling_edge(T_SCK);
                                IF half_period = half_period1_srl THEN
                                    WAIT FOR 3 ns;
                                ELSIF half_period = half_period_quad THEN
                                    WAIT FOR 4.5 ns;
                                ELSIF half_period = half_period_ddr THEN
                                    WAIT FOR 4.9 ns;
                                ELSE
                                    WAIT FOR 8 ns;
                                END IF;
                            END LOOP;
                        END LOOP;
                    END IF;
                ELSE
                    FOR I IN data_num-1 DOWNTO 0 LOOP
                        FOR I IN 7 downto 2 LOOP
                            WAIT UNTIL falling_edge(T_SCK);
                            WAIT FOR 8 ns;
                        END LOOP;
                        WAIT UNTIL falling_edge(T_SCK);
                        WAIT FOR 5 ns;
                        T_HOLDNeg <= '0';
                        WAIT FOR 6*half_period;
                        T_HOLDNeg <= '1';
                        WAIT UNTIL falling_edge(T_SCK);
                        WAIT FOR 9 ns;
                    END LOOP;
                END IF;
                --two more bit of data-out sequence
                IF pulse = true THEN
                    WAIT FOR 4*half_period;
                END IF;

            WHEN bus_data_write  =>
                IF QUAD = '1' AND (opcode = I_QPP OR opcode = I_QPP4 )THEN
                    WAIT UNTIL falling_edge(T_SCK);
                        WAIT FOR 0.5 ns;
                    FOR I IN data_num-1 DOWNTO 0 LOOP
                        T_HOLDNeg <= tmpD(7);
                        T_WPNeg   <= tmpD(6);
                        T_SO      <= tmpD(5);
                        T_SI      <= tmpD(4);
                        WAIT FOR 2*half_period;
                        T_HOLDNeg <= tmpD(3);
                        T_WPNeg   <= tmpD(2);
                        T_SO      <= tmpD(1);
                        T_SI      <= tmpD(0);
                        data_tmp1 := data_tmp1 + 1;
                        tmpD := to_slv(data_tmp1, 8);
                        IF I > 0 THEN
                            WAIT FOR 2*half_period;
                        END IF;
                    END LOOP;
                ELSIF cmd = w_scr OR cmd = w_asp THEN
                    WAIT UNTIL falling_edge(T_SCK);
                    WAIT FOR 0.5 ns;
                    FOR I IN 15 downto 1 LOOP
                        T_SI <= tmpD1(i);
                        WAIT FOR 2*half_period;
                    END LOOP;
                    T_SI <= tmpD1(0);
                    tmpD1 := to_slv(data_tmp1, 16);
                ELSIF cmd = w_autoboot THEN
                    WAIT UNTIL falling_edge(T_SCK);
                    WAIT FOR 0.5 ns;
                    FOR I IN 31 downto 1 LOOP
                        T_SI <= tmpAB(i);
                        WAIT FOR 2*half_period;
                    END LOOP;
                    T_SI <= tmpAB(0);
                    tmpAB := to_slv(data_tmp2, 16)&to_slv(data_tmp1, 16);
                ELSIF cmd = w_password OR cmd = psw_unlock THEN
                    WAIT UNTIL falling_edge(T_SCK);
                    WAIT FOR 0.5 ns;
                    FOR I IN 1 to 7 LOOP
                        FOR J IN 1 to 8 LOOP
                            T_SI <= tmpPASS(I*8-J);
                            WAIT FOR 2*half_period;
                        END LOOP;
                    END LOOP;
                    FOR J IN 1 to 7 LOOP
                        T_SI <= tmpPASS(64-J);
                        WAIT FOR 2*half_period;
                    END LOOP;
                    T_SI <= tmpPASS(56);
                ELSE
                    IF pause = false THEN
                        FOR I IN data_num-1 DOWNTO 0 LOOP
                            WAIT UNTIL falling_edge(T_SCK);
                            WAIT FOR 0.5 ns;
                            FOR I IN 7 downto 1 LOOP
                                T_SI <= tmpD(i);
                                WAIT FOR 2*half_period;
                            END LOOP;
                            T_SI <= tmpD(0);
                            data_tmp1 := data_tmp1 + 1;
                            tmpD := to_slv(data_tmp1, 8);
                        END LOOP;
                    ELSE
                        FOR I IN data_num-1 DOWNTO 0 LOOP
                            WAIT UNTIL falling_edge(T_SCK);
                            WAIT FOR 0.5 ns;
                            FOR I IN 7 downto 3 LOOP
                                T_SI <= tmpD(i);
                                WAIT FOR 2*half_period;
                            END LOOP;
                            T_HOLDNeg <= '0';-- check clock is low here
                            WAIT FOR 6*half_period;
                            T_HOLDNeg <= '1';-- hold rises while clock is low
                            FOR I IN 2 downto 1 LOOP
                                T_SI <= tmpD(i);
                                WAIT FOR 2*half_period;
                            END LOOP;
                            T_SI <= tmpD(0);
                            data_tmp1 := data_tmp1 + 1;
                            tmpD := to_slv(data_tmp1, 8);
                        END LOOP;
                    END IF;
                END IF;

            WHEN bus_st_delay  =>
                start_delay := to_nat(AutoBoot_reg(8 DOWNTO 1));
                FOR I IN start_delay DOWNTO 0 LOOP
                    WAIT UNTIL falling_edge(T_SCK);
                END LOOP;

        END CASE;

    END PROCEDURE;

   ----------------------------------------------------------------------------
    --procedure to decode commands into specific bus command sequence
    ---------------------------------------------------------------------------
    PROCEDURE cmd_dc
        (   command  :   IN  cmd_rec   )

    IS

        VARIABLE slv_1, slv_2 : std_logic_vector(7 downto 0);
        VARIABLE slv_3        : std_logic_vector(15 downto 0);
        VARIABLE slv_4        : std_logic_vector(15 downto 0);
        VARIABLE opcode_tmp   : std_logic_vector(7 downto 0);
        VARIABLE Data_byte    : INTEGER RANGE 0 TO 16#FFFF#  := 0;
        VARIABLE Byte_number  : NATURAL RANGE 0 TO 600;
        VARIABLE cnt          : NATURAL RANGE 0 TO 512;
        VARIABLE pgm_page     : NATURAL;
        VARIABLE page_addr    : NATURAL RANGE 0 TO AddrRANGE;
        VARIABLE AddrLow      : NATURAL RANGE 0 TO AddrRANGE;
        VARIABLE ADDR         : NATURAL RANGE 0 TO AddrRANGE;
        VARIABLE addr_tmp     : NATURAL RANGE 0 TO AddrRANGE;
        VARIABLE AddrHigh     : NATURAL RANGE 0 TO AddrRANGE;
        VARIABLE SECTOR       : NATURAL RANGE 0 TO 541;
        VARIABLE BP_bits      : std_logic_vector(2 downto 0) := "000";
        VARIABLE tmp          : NATURAL;
        VARIABLE tmp_byte_num : NATURAL;
        VARIABLE pass_tmp     : std_logic_vector(63 downto 0);
        VARIABLE sec_tmp      : NATURAL RANGE 0 TO 541;
        VARIABLE BAR_ACC_tmp  :   NATURAL RANGE 0 TO 1:=0;
        VARIABLE Bank_Addr_reg_tmp: std_logic_vector(7 downto 0)
                                            := (others => '0');

    BEGIN
        IF TimingModel(10) = 'A' AND TimingModel(11) = 'G' THEN
            half_period := half_period1_srl;
        ELSIF TimingModel(10) = 'D' AND TimingModel(11) = 'P' THEN
            half_period := half_period_ddr;
        END IF;

        IF TimingModel(16) = '0' AND TBPARM = '0' THEN
            b_act := 1;
        ELSE
            b_act := 0;
        END IF;

        CASE command.cmd IS
            WHEN    idle        =>
                bus_cycle(bus_cmd => bus_idle,
                          PowerUp => command.aux=PowerUp,
                          protect => command.aux=violate);

            WHEN    w_enable    =>

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_WREN,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                IF status /= err THEN
                    WEL := '1';
                END IF;

                WAIT FOR 9*half_period ;

            WHEN    w_disable    =>

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_WRDI,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                IF status /= err THEN
                    WEL := '0';
                END IF;

                WAIT FOR 9*half_period ;

            WHEN    mbr    =>

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_MBR,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                WAIT FOR 9*half_period ;

            WHEN    bank_acc    =>

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_BRAC,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                WAIT FOR 9*half_period ;

            WHEN    h_reset         =>

                bus_cycle(bus_cmd => bus_reset,
                          data_num=> 1,
                          tm      => command.wtime);
                VDLR_reg  := NVDLR_reg;
                Bank_Addr_reg := (others => '0');
                --Resets the Status register 1
                P_ERR     := '0';
                E_ERR     := '0';
                WEL       := '0';
                WIP       := '0';
                --Resets the Status register 2
                ES        := '0';
                PS        := '0';
                --Resets the Configuration register 1
                FREEZE    := '0';
                IF BPNV = '1'  AND FREEZE = '0' THEN --AND LOCK='0'
                    BP0 := '1';
                    BP1 := '1';
                    BP2 := '1';
                    BP_bits := BP2 & BP1 & BP0;
                    Sec_Prot := (OTHERS => '1');
                END IF;
                IF PWDMLB = '0' THEN
                    PPB_LOCK := '0';
                ELSE
                    PPB_LOCK := '1';
                END IF;
                WAIT for 50 ns;

            WHEN    w_sr         =>

                IF status /= err AND BAR_ACC = 1 THEN
                    BAR_ACC_tmp := 1;
                END IF;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_WRR,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_write,
                          data1    => command.data1,
                          data_num=> 1,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                Data_byte :=  command.data1;
                slv_1 := to_slv(Data_byte,8);
                WIP := '1';

                IF status /= err AND WEL = '1' AND BAR_ACC_tmp = 0 THEN
                    IF NOT(SRWD='1' AND T_WPNeg='0') THEN
                        SRWD   := slv_1 (7);
--                         IF LOCK='0' THEN
                            IF FREEZE='0' THEN
                                BP2    := slv_1 (4);
                                BP1    := slv_1 (3);
                                BP0    := slv_1 (2);

                                BP_bits := BP2 & BP1 & BP0;
                            END IF;
--                         END IF;
                        Sec_Prot := (others => '0');
                        CASE BP_bits IS
                            WHEN "000" =>
                                Sec_Prot := (OTHERS => '0');
                            WHEN "001" =>
                                IF TBPROT = '0' THEN
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)*63/64+30*b_act)
                                                            := (OTHERS => '1');
                                    Sec_Prot((SecNum+1)*63/64+
                                        30*b_act-1 downto 0) := (OTHERS => '0');
                                ELSE
                                    Sec_Prot((SecNum+1)/64+30*b_act-1 downto 0)
                                                            := (OTHERS => '1');
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)/64+30*b_act)
                                                            := (OTHERS => '0');
                                END IF;
                            WHEN "010" =>
                                IF TBPROT =  '0' THEN
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)*31/32+30*b_act)
                                                            := (OTHERS => '1');
                                    Sec_Prot((SecNum+1)*31/32+
                                        30*b_act-1 downto 0) := (OTHERS => '0');
                                ELSE
                                    Sec_Prot((SecNum+1)/32+30*b_act-1 downto 0)
                                                            := (others => '1');
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)/32+30*b_act)
                                                            := (OTHERS => '0');
                                END IF;
                            WHEN "011" =>
                                IF TBPROT =  '0' THEN
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)*15/16+30*b_act)
                                                            := (OTHERS => '1');
                                    Sec_Prot((SecNum+1)*15/16+
                                        30*b_act-1 downto 0) := (OTHERS => '0');
                                ELSE
                                    Sec_Prot((SecNum+1)/16+30*b_act-1 downto 0)
                                                            := (OTHERS => '1');
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)/16+30*b_act)
                                                            := (OTHERS => '0');
                                END IF;
                            WHEN "100" =>
                                IF TBPROT =  '0' THEN
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)*7/8+30*b_act)
                                                            := (OTHERS => '1');
                                    Sec_Prot((SecNum+1)*7/8+30*b_act-1 downto 0)
                                                            := (OTHERS => '0');
                                ELSE
                                    Sec_Prot((SecNum+1)/8+30*b_act-1 downto 0)
                                                            := (OTHERS => '1');
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)/8+30*b_act)
                                                            := (OTHERS => '0');
                                END IF;
                            WHEN "101" =>
                                IF TBPROT =  '0' THEN
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)*3/4+30*b_act)
                                                           := (OTHERS => '1');
                                    Sec_Prot((SecNum+1)*3/4+30*b_act-1 downto 0)
                                                           := (OTHERS => '0');
                                ELSE
                                    Sec_Prot((SecNum+1)/4+30*b_act-1 downto 0)
                                                           := (OTHERS => '1');
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)/4+30*b_act)
                                                           := (OTHERS => '0');
                               END IF;
                            WHEN "110" =>
                               IF TBPROT =  '0' THEN
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)/2+30*b_act)
                                                           := (OTHERS => '1');
                                    Sec_Prot((SecNum+1)/2+30*b_act-1 downto 0)
                                                           := (OTHERS => '0');
                                ELSE
                                    Sec_Prot((SecNum+1)/2+30*b_act-1 downto 0)
                                                           := (OTHERS => '1');
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)/2+30*b_act)
                                                           := (OTHERS => '0');
                               END IF;
                            WHEN OTHERS =>
                                Sec_Prot := (OTHERS => '1');
                        END CASE;
                    ELSE
                        WEL := '0';
                    END IF;
                    WEL := '0';
                    WIP := '0';
                ELSIF status /= err AND BAR_ACC_tmp = 1 THEN
                    Bank_Addr_reg_tmp:= to_slv(command.data1,8);
                    Bank_Addr_reg(0) := Bank_Addr_reg_tmp(0);
                    WIP := '0';
                    BAR_ACC_tmp := 0;
                ELSE
                    WEL := '0';
                    WIP := '0';
                END IF;
                
                
            WHEN    ecc_rd       =>
                
                half_period := half_period1_srl;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_ECCRD,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);
                          
                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_ECCRD,
                          address => command.addr,
                          sector  => command.sect,
                          pause   => command.aux=hold_add,
                          tm      => command.wtime);
                          
                bus_cycle(bus_cmd => bus_dummy_byte,
                          opcode  => I_ECCRD,
                          pause   => command.aux=hold_dum,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_ECCRD,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 22*half_period ;

            WHEN    rd_sr1       =>

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_RDSR,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_RDSR,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 22*half_period ;

            WHEN    rd_sr2       =>

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_RDSR2,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_RDSR2,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 22*half_period ;

            WHEN    clr_sr       =>

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_CLSR,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                IF status /= err  THEN
                    E_ERR := '0';
                    P_ERR := '0';
                END IF;

                WAIT FOR 22*half_period ;

            WHEN    w_scr        =>

                WIP := '1';
                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_WRR,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd  => bus_data_write,
                          opcode   => I_WRR,
                          data1    => command.data1,
                          data_num => 1,
                          pause    => command.aux=hold_dat,
                          tm       => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                Data_byte :=  command.data1;
                slv_3 := to_slv(Data_byte,16);

                WAIT FOR 22*half_period ;

                IF status /= err AND WEL = '1' THEN
                    IF NOT(SRWD='1' AND T_WPNeg='0') THEN
                        SRWD   := slv_3 (15);
--                         IF LOCK='0' THEN
                            IF FREEZE='0' THEN
                                BP2    := slv_3 (12);
                                BP1    := slv_3 (11);
                                BP0    := slv_3 (10);

                                BP_bits := BP2 & BP1 & BP0;
                                IF TBPROT = '0' THEN
                                    TBPROT  := slv_3 (5);
                                END IF;
                                IF (TBPARM = '0' AND not(INITIAL_CONFIG) AND
                                    TimingModel(16) = '0') THEN
                                    TBPARM  := slv_3 (2);
                                END IF;
                            END IF;
--                         END IF;
--                         IF WRLOCKENABLE AND LOCK = '0' THEN
--                             LOCK    := slv_3(4);
--                             WRLOCKENABLE <= false;
--                         END IF;
                        IF BPNV = '0' THEN
                            BPNV    := slv_3(3);
                        END IF;
                        IF FREEZE = '0' THEN
                            FREEZE    := slv_3(0);
                        END IF;
                        LC1     := slv_3(7);
                        LC0     := slv_3(6);
                        QUAD    := slv_3(1);

                        Sec_Prot := (others => '0');
                        CASE BP_bits IS
                            WHEN "000" =>
                                Sec_Prot := (OTHERS => '0');
                            WHEN "001" =>
                                IF TBPROT = '0' THEN
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)*63/64+30*b_act)
                                                            := (OTHERS => '1');
                                    Sec_Prot((SecNum+1)*63/64+
                                        30*b_act-1 downto 0) := (OTHERS => '0');
                                ELSE
                                    Sec_Prot((SecNum+1)/64+30*b_act-1 downto 0)
                                                            := (OTHERS => '1');
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)/64+30*b_act)
                                                            := (OTHERS => '0');
                                END IF;
                            WHEN "010" =>
                                IF TBPROT =  '0' THEN
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)*31/32+30*b_act)
                                                            := (OTHERS => '1');
                                    Sec_Prot((SecNum+1)*31/32+
                                        30*b_act-1 downto 0) := (OTHERS => '0');
                                ELSE
                                    Sec_Prot((SecNum+1)/32+30*b_act-1 downto 0)
                                                            := (others => '1');
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)/32+30*b_act)
                                                            := (OTHERS => '0');
                                END IF;
                            WHEN "011" =>
                                IF TBPROT =  '0' THEN
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)*15/16+30*b_act)
                                                            := (OTHERS => '1');
                                    Sec_Prot((SecNum+1)*15/16+
                                        30*b_act-1 downto 0) := (OTHERS => '0');
                                ELSE
                                    Sec_Prot((SecNum+1)/16+30*b_act-1 downto 0)
                                                            := (OTHERS => '1');
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)/16+30*b_act)
                                                            := (OTHERS => '0');
                                END IF;
                            WHEN "100" =>
                                IF TBPROT =  '0' THEN
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)*7/8+30*b_act)
                                                            := (OTHERS => '1');
                                    Sec_Prot((SecNum+1)*7/8+30*b_act-1 downto 0)
                                                            := (OTHERS => '0');
                                ELSE
                                    Sec_Prot((SecNum+1)/8+30*b_act-1 downto 0)
                                                            := (OTHERS => '1');
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)/8+30*b_act)
                                                            := (OTHERS => '0');
                                END IF;
                            WHEN "101" =>
                                IF TBPROT =  '0' THEN
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)*3/4+30*b_act)
                                                           := (OTHERS => '1');
                                    Sec_Prot((SecNum+1)*3/4+30*b_act-1 downto 0)
                                                           := (OTHERS => '0');
                                ELSE
                                    Sec_Prot((SecNum+1)/4+30*b_act-1 downto 0)
                                                           := (OTHERS => '1');
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)/4+30*b_act)
                                                           := (OTHERS => '0');
                               END IF;
                            WHEN "110" =>
                               IF TBPROT =  '0' THEN
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)/2+30*b_act)
                                                           := (OTHERS => '1');
                                    Sec_Prot((SecNum+1)/2+30*b_act-1 downto 0)
                                                           := (OTHERS => '0');
                                ELSE
                                    Sec_Prot((SecNum+1)/2+30*b_act-1 downto 0)
                                                           := (OTHERS => '1');
                                    Sec_Prot(SecNumMax downto
                                            (SecNum+1)/2+30*b_act)
                                                           := (OTHERS => '0');
                               END IF;
                            WHEN OTHERS =>
                                Sec_Prot := (OTHERS => '1');
                        END CASE;
                    END IF;
                    WEL := '0';
                    WIP := '0';
                ELSE
                    WEL := '0';
                    WIP := '0';
                END IF;

            WHEN    rd_scr       =>

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_RDCR,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_RDCR,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 22*half_period ;

            WHEN    rd_dlp       =>

                half_period := half_period2_srl;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_RDDLP,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);
                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_RDDLP,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 22*half_period ;

            WHEN    rd           =>

                half_period := half_period2_srl;

                IF command.aux = violate THEN
                    half_period := 10 ns;
                END IF;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_READ,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_READ,
                          address => command.addr,
                          sector  => command.sect,
                          pause   => command.aux=hold_add,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_READ,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_dat,
                          break   => command.aux=violate,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    WAIT FOR 5 ns;
                END IF;

                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 9*half_period ;

            WHEN    rd_4           =>

                half_period := half_period2_srl;

                IF command.aux = violate THEN
                    half_period := 10 ns;
                END IF;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_RD4,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_RD4,
                          data1   => command.data1,
                          address => command.addr,
                          sector  => command.sect,
                          pause   => command.aux=hold_add,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_RD4,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_dat,
                          break   => command.aux=violate,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    WAIT FOR 5 ns;
                END IF;

                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 9*half_period ;

            WHEN    fast_rd      =>
                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_FSTRD,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_FSTRD,
                          address => command.addr,
                          sector  => command.sect,
                          pause   => command.aux=hold_add,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_dummy_byte,
                          opcode  => I_FSTRD,
                          pause   => command.aux=hold_dum,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    half_period := 4 ns;
                END IF;

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_FSTRD,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    WAIT FOR 7 ns;
                END IF;
                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 22*half_period ;

            WHEN    fast_rd4       =>
                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_FSTRD4,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_FSTRD4,
                          address => command.addr,
                          data1   => command.data1,
                          sector  => command.sect,
                          pause   => command.aux=hold_add,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_dummy_byte,
                          opcode  => I_FSTRD4,
                          pause   => command.aux=hold_dum,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    half_period := 4 ns;
                END IF;

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_FSTRD4,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    WAIT FOR 7 ns;
                END IF;
                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 22*half_period ;

            WHEN    dual_rd      =>

                IF TimingModel(10) = 'A' AND TimingModel(11) = 'G' THEN
                    half_period := half_period_quad;
                ELSIF TimingModel(10) = 'D' AND TimingModel(11) = 'P' THEN
                    half_period := half_period_ddr;
                END IF;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_RDDO,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_RDDO,
                          address => command.addr,
                          sector  => command.sect,
                          pause   => command.aux=hold_add,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_dummy_byte,
                          opcode  => I_RDDO,
                          pause   => command.aux=hold_dum,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    half_period := 4 ns;
                END IF;

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_RDDO,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    WAIT FOR 7 ns;
                END IF;
                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 22*half_period ;

            WHEN    dual_rd_4      =>

                IF TimingModel(10) = 'A' AND TimingModel(11) = 'G' THEN
                    half_period := half_period_quad;
                ELSIF TimingModel(10) = 'D' AND TimingModel(11) = 'P' THEN
                    half_period := half_period_ddr;
                END IF;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_RDDO4,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_RDDO4,
                          address => command.addr,
                          data1   => command.data1,
                          sector  => command.sect,
                          pause   => command.aux=hold_add,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_dummy_byte,
                          opcode  => I_RDDO4,
                          pause   => command.aux=hold_dum,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    half_period := 4 ns;
                END IF;

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_RDDO4,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    WAIT FOR 7 ns;
                END IF;
                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 22*half_period ;

            WHEN    dual_high_rd      =>

                IF TimingModel(10) = 'A' AND TimingModel(11) = 'G' THEN
                    half_period := half_period_quad;
                ELSIF TimingModel(10) = 'D' AND TimingModel(11) = 'P' THEN
                    half_period := half_period_ddr;
                END IF;

                bus_cycle(bus_cmd => bus_select);

                IF command.status /= rd_cont_dualIO THEN
                    bus_cycle(bus_cmd => bus_opcode,
                            opcode  => I_RDDIO,
                            pulse   => false,
                            pause   => command.aux=hold_op,
                            tm      => command.wtime);
                END IF;

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_RDDIO,
                          address => command.addr,
                          sector  => command.sect,
                          break   => command.aux=break,
                          pause   => command.aux=hold_add,
                          tm      => command.wtime);

                IF (TimingModel(15) = '0' OR TimingModel(15) = '2' OR
                    TimingModel(15) = '3' OR TimingModel(15) = 'R' OR
                    TimingModel(15) = 'A' OR TimingModel(15) = 'B' OR
                    TimingModel(15) = 'C' OR TimingModel(15) = 'D' OR
                    TimingModel(15) = 'Y' OR TimingModel(15) = 'Z' OR
                    TimingModel(15) = 'S' OR TimingModel(15) = 'T' OR
                    TimingModel(15) = 'K' OR TimingModel(15) = 'L') THEN
                    bus_cycle(bus_cmd => bus_mode_byte,
                              opcode  => I_RDDIO,
                              data1   => command.data1,
                              pause   => command.aux=hold_mod,
                              tm      => command.wtime);
                END IF;

                bus_cycle(bus_cmd => bus_dummy_clock,
                          opcode  => I_RDDIO,
                          pause   => command.aux=hold_dum,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    half_period := 4 ns;
                END IF;

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_RDDIO,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    WAIT FOR 7 ns;
                END IF;
                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 22*half_period ;

            WHEN    dual_high_rd_4      =>

                IF TimingModel(10) = 'A' AND TimingModel(11) = 'G' THEN
                    half_period := half_period_quad;
                ELSIF TimingModel(10) = 'D' AND TimingModel(11) = 'P' THEN
                    half_period := half_period_ddr;
                END IF;

                bus_cycle(bus_cmd => bus_select);

                IF command.status /= rd_cont_dualIO4 THEN
                    bus_cycle(bus_cmd => bus_opcode,
                            opcode  => I_RDDIO4,
                            pulse   => false,
                            pause   => command.aux=hold_op,
                            tm      => command.wtime);
                END IF;

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_RDDIO4,
                          address => command.addr,
                          data1   => command.data1,
                          sector  => command.sect,
                          break   => command.aux=break,
                          pause   => command.aux=hold_add,
                          tm      => command.wtime);

                IF (TimingModel(15) = '0' OR TimingModel(15) = '2' OR
                    TimingModel(15) = '3' OR TimingModel(15) = 'R' OR
                    TimingModel(15) = 'A' OR TimingModel(15) = 'B' OR
                    TimingModel(15) = 'C' OR TimingModel(15) = 'D' OR
                    TimingModel(15) = 'Y' OR TimingModel(15) = 'Z' OR
                    TimingModel(15) = 'S' OR TimingModel(15) = 'T' OR
                    TimingModel(15) = 'K' OR TimingModel(15) = 'L') THEN
                    bus_cycle(bus_cmd => bus_mode_byte,
                              opcode  => I_RDDIO4,
                              data1   => command.data1,
                              pause   => command.aux=hold_mod,
                              tm      => command.wtime);
                END IF;

                bus_cycle(bus_cmd => bus_dummy_clock,
                          opcode  => I_RDDIO4,
                          pause   => command.aux=hold_dum,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    half_period := 4 ns;
                END IF;

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_RDDIO4,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    WAIT FOR 7 ns;
                END IF;
                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 22*half_period ;

            WHEN    quad_rd      =>

                IF TimingModel(10) = 'A' AND TimingModel(11) = 'G' THEN
                    half_period := half_period_quad;
                ELSIF TimingModel(10) = 'D' AND TimingModel(11) = 'P' THEN
                    half_period := half_period_ddr;
                END IF;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_RDQO,
                          pulse   => false,
                          pause   => false,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_RDQO,
                          address => command.addr,
                          sector  => command.sect,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_dummy_byte,
                          opcode  => I_RDQO,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    half_period := 4 ns;
                END IF;

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_RDQO,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    WAIT FOR 7 ns;
                END IF;
                bus_cycle(bus_cmd => bus_desel_read,
                          opcode  => I_RDQO);

                WAIT FOR 22*half_period ;

            WHEN    quad_rd_4      =>

                IF TimingModel(10) = 'A' AND TimingModel(11) = 'G' THEN
                    half_period := half_period_quad;
                ELSIF TimingModel(10) = 'D' AND TimingModel(11) = 'P' THEN
                    half_period := half_period_ddr;
                END IF;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_RDQO4,
                          pulse   => false,
                          pause   => false,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_RDQO4,
                          address => command.addr,
                          data1   => command.data1,
                          sector  => command.sect,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_dummy_byte,
                          opcode  => I_RDQO4,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    half_period := 4 ns;
                END IF;

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_RDQO4,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    WAIT FOR 7 ns;
                END IF;
                bus_cycle(bus_cmd => bus_desel_read,
                          opcode  => I_RDQO4);

                WAIT FOR 22*half_period ;

            WHEN    quad_high_rd      =>

                IF TimingModel(10) = 'A' AND TimingModel(11) = 'G' THEN
                    half_period := half_period_quad;
                ELSIF TimingModel(10) = 'D' AND TimingModel(11) = 'P' THEN
                    half_period := half_period_ddr;
                END IF;

                bus_cycle(bus_cmd => bus_select);

                IF command.status /= rd_cont_quadIO THEN

                    bus_cycle(bus_cmd => bus_opcode,
                              opcode  => I_RDQIO,
                              pulse   => false,
                              pause   => false,
                              tm      => command.wtime);
                END IF;

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_RDQIO,
                          address => command.addr,
                          sector  => command.sect,
                          break   => command.aux=break,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_mode_byte,
                          opcode  => I_RDQIO,
                          data1   => command.data1,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_dummy_clock,
                          opcode  => I_RDQIO,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    half_period := 4 ns;
                END IF;

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_RDQIO,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    WAIT FOR 7 ns;
                END IF;
                bus_cycle(bus_cmd => bus_desel_read,
                          opcode  => I_RDQIO);

                WAIT FOR 22*half_period ;

            WHEN    quad_high_rd_4      =>

                IF TimingModel(10) = 'A' AND TimingModel(11) = 'G' THEN
                    half_period := half_period_quad;
                ELSIF TimingModel(10) = 'D' AND TimingModel(11) = 'P' THEN
                    half_period := half_period_ddr;
                END IF;

                bus_cycle(bus_cmd => bus_select);

                IF command.status /= rd_cont_quadIO4 THEN

                    bus_cycle(bus_cmd => bus_opcode,
                              opcode  => I_RDQIO4,
                              pulse   => false,
                              pause   => false,
                              tm      => command.wtime);
                END IF;

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_RDQIO4,
                          address => command.addr,
                          data1   => command.data1,
                          sector  => command.sect,
                          break   => command.aux=break,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_mode_byte,
                          opcode  => I_RDQIO4,
                          data1   => command.data1,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_dummy_clock,
                          opcode  => I_RDQIO4,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    half_period := 4 ns;
                END IF;

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_RDQIO4,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    WAIT FOR 7 ns;
                END IF;
                bus_cycle(bus_cmd => bus_desel_read,
                          opcode  => I_RDQIO4);

                WAIT FOR 22*half_period ;

            WHEN    fast_ddr_rd      =>
                --The maximum operating clock frequency for Fast
                --DDR Read mode is 80 MHz
                half_period := half_period_ddr;

                bus_cycle(bus_cmd => bus_select);

                IF command.status /= rd_cont_fddr THEN

                    bus_cycle(bus_cmd => bus_opcode,
                              opcode  => I_FDDR,
                              pulse   => false,
                              pause   => false,
                              tm      => command.wtime);
                END IF;

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_FDDR,
                          address => command.addr,
                          sector  => command.sect,
                          break   => command.aux=break,
                          tm      => command.wtime);

                IF (TimingModel(15) = '0' OR TimingModel(15) = '2' OR
                    TimingModel(15) = '3' OR TimingModel(15) = 'R' OR
                    TimingModel(15) = 'A' OR TimingModel(15) = 'B' OR
                    TimingModel(15) = 'C' OR TimingModel(15) = 'D' OR
                    TimingModel(15) = 'Y' OR TimingModel(15) = 'Z' OR
                    TimingModel(15) = 'S' OR TimingModel(15) = 'T' OR
                    TimingModel(15) = 'K' OR TimingModel(15) = 'L') THEN
                    bus_cycle(bus_cmd => bus_mode_byte,
                            opcode  => I_FDDR,
                            data1   => command.data1,
                            tm      => command.wtime);
                END IF;

                bus_cycle(bus_cmd => bus_dummy_byte,
                          opcode  => I_FDDR,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    half_period := 4 ns;
                END IF;

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_FDDR,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    WAIT FOR 7 ns;
                END IF;
                bus_cycle(bus_cmd => bus_desel_read,
                          opcode  => I_FDDR);

                WAIT FOR 22*half_period ;

            WHEN    fast_ddr_rd4      =>
                --The maximum operating clock frequency for Fast
                --DDR Read mode is 80 MHz
                half_period := half_period_ddr;

                bus_cycle(bus_cmd => bus_select);

                IF command.status /= rd_cont_fddr4 THEN

                    bus_cycle(bus_cmd => bus_opcode,
                              opcode  => I_FDDR4,
                              pulse   => false,
                              pause   => false,
                              tm      => command.wtime);
                END IF;

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_FDDR4,
                          address => command.addr,
                          sector  => command.sect,
                          break   => command.aux=break,
                          tm      => command.wtime);

                IF (TimingModel(15) = '0' OR TimingModel(15) = '2' OR
                    TimingModel(15) = '3' OR TimingModel(15) = 'R' OR
                    TimingModel(15) = 'A' OR TimingModel(15) = 'B' OR
                    TimingModel(15) = 'C' OR TimingModel(15) = 'D' OR
                    TimingModel(15) = 'Y' OR TimingModel(15) = 'Z' OR
                    TimingModel(15) = 'S' OR TimingModel(15) = 'T' OR
                    TimingModel(15) = 'K' OR TimingModel(15) = 'L') THEN
                    bus_cycle(bus_cmd => bus_mode_byte,
                            opcode  => I_FDDR4,
                            data1   => command.data1,
                            tm      => command.wtime);
                END IF;

                bus_cycle(bus_cmd => bus_dummy_byte,
                          opcode  => I_FDDR4,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    half_period := 4 ns;
                END IF;

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_FDDR4,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    WAIT FOR 7 ns;
                END IF;
                bus_cycle(bus_cmd => bus_desel_read,
                          opcode  => I_FDDR4);

                WAIT FOR 22*half_period ;

            WHEN    dual_high_ddr_rd      =>
                --The maximum operating clock frequency for Dual I/O
                --DDR Read mode is 80 MHz
                half_period := half_period_ddr;

                bus_cycle(bus_cmd => bus_select);

                IF command.status /= rd_cont_dddr THEN

                    bus_cycle(bus_cmd => bus_opcode,
                              opcode  => I_RDDRD,
                              pulse   => false,
                              pause   => false,
                              tm      => command.wtime);
                END IF;

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_RDDRD,
                          address => command.addr,
                          sector  => command.sect,
                          break   => command.aux=break,
                          tm      => command.wtime);

                IF (TimingModel(15) = '0' OR TimingModel(15) = '2' OR
                    TimingModel(15) = '3' OR TimingModel(15) = 'R' OR
                    TimingModel(15) = 'A' OR TimingModel(15) = 'B' OR
                    TimingModel(15) = 'C' OR TimingModel(15) = 'D' OR
                    TimingModel(15) = 'Y' OR TimingModel(15) = 'Z' OR
                    TimingModel(15) = 'S' OR TimingModel(15) = 'T' OR
                    TimingModel(15) = 'K' OR TimingModel(15) = 'L') THEN
                    bus_cycle(bus_cmd => bus_mode_byte,
                            opcode  => I_RDDRD,
                            data1   => command.data1,
                            tm      => command.wtime);
                END IF;

                bus_cycle(bus_cmd => bus_dummy_clock,
                          opcode  => I_RDDRD,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    half_period := 4 ns;
                END IF;

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_RDDRD,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    WAIT FOR 7 ns;
                END IF;
                bus_cycle(bus_cmd => bus_desel_read,
                          opcode  => I_RDDRD);

                WAIT FOR 22*half_period ;

            WHEN    dual_high_ddr_rd4      =>
                --The maximum operating clock frequency for Dual I/O
                --DDR Read mode is 80 MHz
                half_period := half_period_ddr;

                bus_cycle(bus_cmd => bus_select);

                IF command.status /= rd_cont_dddr4 THEN

                    bus_cycle(bus_cmd => bus_opcode,
                              opcode  => I_RDDRD4,
                              pulse   => false,
                              pause   => false,
                              tm      => command.wtime);
                END IF;

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_RDDRD4,
                          address => command.addr,
                          sector  => command.sect,
                          break   => command.aux=break,
                          tm      => command.wtime);

                IF (TimingModel(15) = '0' OR TimingModel(15) = '2' OR
                    TimingModel(15) = '3' OR TimingModel(15) = 'R' OR
                    TimingModel(15) = 'A' OR TimingModel(15) = 'B' OR
                    TimingModel(15) = 'C' OR TimingModel(15) = 'D' OR
                    TimingModel(15) = 'Y' OR TimingModel(15) = 'Z' OR
                    TimingModel(15) = 'S' OR TimingModel(15) = 'T' OR
                    TimingModel(15) = 'K' OR TimingModel(15) = 'L') THEN
                    bus_cycle(bus_cmd => bus_mode_byte,
                              opcode  => I_RDDRD4,
                              data1   => command.data1,
                              tm      => command.wtime);
                END IF;

                bus_cycle(bus_cmd => bus_dummy_clock,
                          opcode  => I_RDDRD4,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    half_period := 4 ns;
                END IF;

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_RDDRD4,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    WAIT FOR 7 ns;
                END IF;
                bus_cycle(bus_cmd => bus_desel_read,
                          opcode  => I_RDDRD4);

                WAIT FOR 22*half_period ;

            WHEN    quad_high_ddr_rd      =>
                --The maximum operating clock frequency for Quad I/O
                --DDR Read mode is 80 MHz
                half_period := half_period_ddr;

                bus_cycle(bus_cmd => bus_select);

                IF command.status /= rd_cont_qddr THEN

                    bus_cycle(bus_cmd => bus_opcode,
                              opcode  => I_RDDRQ,
                              pulse   => false,
                              pause   => false,
                              tm      => command.wtime);
                END IF;

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_RDDRQ,
                          address => command.addr,
                          sector  => command.sect,
                          break   => command.aux=break,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_mode_byte,
                          opcode  => I_RDDRQ,
                          data1   => command.data1,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_dummy_clock,
                          opcode  => I_RDDRQ,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    half_period := 4 ns;
                END IF;

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_RDDRQ,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    WAIT FOR 7 ns;
                END IF;
                bus_cycle(bus_cmd => bus_desel_read,
                          opcode  => I_RDDRQ);

                WAIT FOR 22*half_period ;

            WHEN    quad_high_ddr_rd_4      =>
                --The maximum operating clock frequency for Quad I/O
                --DDR Read mode is 80 MHz
                half_period := half_period_ddr;

                bus_cycle(bus_cmd => bus_select);

                IF command.status /= rd_cont_qddr4 THEN

                    bus_cycle(bus_cmd => bus_opcode,
                              opcode  => I_RDDRQ4,
                              pulse   => false,
                              pause   => false,
                              tm      => command.wtime);
                END IF;

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_RDDRQ4,
                          address => command.addr,
                          data1   => command.data1,
                          sector  => command.sect,
                          break   => command.aux=break,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_mode_byte,
                          opcode  => I_RDDRQ4,
                          data1   => command.data1,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_dummy_clock,
                          opcode  => I_RDDRQ4,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    half_period := 4 ns;
                END IF;

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_RDDRQ4,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          tm      => command.wtime);

                IF command.aux = violate THEN
                    WAIT FOR 7 ns;
                END IF;
                bus_cycle(bus_cmd => bus_desel_read,
                          opcode  => I_RDDRQ4);

                WAIT FOR 22*half_period ;

            WHEN    read_ID      =>
                --The maximum operating clock frequency for Read ID
                --(90h) command is 133 MHz
                IF TimingModel(10) = 'A' AND TimingModel(11) = 'G' THEN
                    half_period := half_period1_srl;
                ELSIF TimingModel(10) = 'D' AND TimingModel(11) = 'P' THEN
                    half_period := half_period_ddr;
                END IF;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_REMS,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_REMS,
                          address => command.addr,
                          sector  => command.sect,
                          pause   => command.aux=hold_add,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_REMS,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 22*half_period ;

            WHEN    read_JID       =>

                half_period := half_period2_srl;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_RDID,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_RDID,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 9*half_period ;

            WHEN    read_ES      =>

                half_period := half_period2_srl;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_RES,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_dummy_byte,
                          opcode  => I_RES,
                          pause   => command.aux=hold_dum,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_RES,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 22*half_period ;

            WHEN    sector_erase  | p4_erase =>

                SECTOR := command.sect;
                SECSUSP := SECTOR;
                ADDR   := command.addr;
                WIP := '1';
                INITIAL_CONFIG <= TRUE;

                IF command.cmd = sector_erase THEN
                    opcode_tmp := I_SE;
                    PARM_BLOCK <= FALSE;
                ELSIF command.cmd = p4_erase THEN
                    opcode_tmp := I_P4E;
                    PARM_BLOCK <= TRUE;
                END IF;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => opcode_tmp,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          break   => command.aux=violate,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => opcode_tmp,
                          address => command.addr,
                          sector  => command.sect,
                          pause   => command.aux=hold_add,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                IF status /= err THEN
                    IF (Sec_Prot(SECTOR) /= '1' AND WEL = '1' AND
                        PPB_bits(SECTOR)='1' AND DYB_bits(SECTOR)='1') THEN
                        WIP := '1';
                        sesa(AddrLow,AddrHigh,SECTOR);
                        FOR i IN AddrLow TO AddrHigh LOOP
                            mem(i) := 16#FF#;
                            pgm_page := i / PageSize;
                            QPP_page(pgm_page):='0';
                        END LOOP;
                        E_ERR := '0';
                        WEL := '0';
                        WIP := '0';
                    ELSE
                        E_ERR := '1';
                        WEL := '0';
                        WIP := '0';
                    END IF;
                ELSE
                    WEL := '0';
                END IF;

            WHEN    sector_erase_4  | p4_erase_4  =>

                SECTOR := command.sect;
                SECSUSP := SECTOR;
                ADDR := command.addr;
                WIP := '1';
                INITIAL_CONFIG <= TRUE;

                IF command.cmd = sector_erase_4 THEN
                    opcode_tmp := I_SE4;
                    PARM_BLOCK <= FALSE;
                ELSIF command.cmd = p4_erase_4 THEN
                    opcode_tmp := I_P4E4;
                    PARM_BLOCK <= TRUE;
                END IF;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => opcode_tmp,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          break   => command.aux=violate,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => opcode_tmp,
                          address => command.addr,
                          sector  => command.sect,
                          pause   => command.aux=hold_add,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                IF status /= err THEN
                    IF (Sec_Prot(SECTOR) /= '1' AND WEL = '1' AND
                        PPB_bits(SECTOR)='1' AND DYB_bits(SECTOR)='1') THEN
                        WIP := '1';
                        sesa(AddrLow,AddrHigh,SECTOR);
                        FOR i IN AddrLow TO AddrHigh LOOP
                            mem(i) := 16#FF#;
                            pgm_page := i / PageSize;
                            QPP_page(pgm_page):='0';
                        END LOOP;
                        E_ERR := '0';
                        WEL := '0';
                        WIP := '0';
                    ELSE
                        E_ERR := '1';
                        WEL := '0';
                        WIP := '0';
                    END IF;
                ELSE
                    WEL := '0';
                END IF;

            WHEN    bulk_erase =>

                INITIAL_CONFIG <= TRUE;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_BE,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          break   => command.aux=violate,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                IF status /= err AND WEL = '1' THEN
                    IF (BP0 = '0' AND BP1 = '0' AND BP2 = '0') THEN
                        WIP := '1';
                        FOR i IN 0 TO ADDRRange LOOP
                            -- Sector ID calculation
                            IF TimingModel(16) = '0' THEN
                                sec_tmp := i / (SecSize64+1);
                                IF BootConfig = TRUE THEN
                                    IF sec_tmp <= 1 THEN      --4KB Sectors
                                        SECTOR := i/(SecSize4+1);
                                    ELSE
                                        SECTOR := sec_tmp + 30;
                                    END IF;
                                ELSIF BootConfig = FALSE THEN
                                    IF sec_tmp >= 510 THEN       --4KB Sectors
                                        SECTOR :=
                                         510+(i-(SecSize64+1)*510)/(SecSize4+1);
                                    ELSE
                                        SECTOR := sec_tmp;
                                    END IF;
                                END IF;
                            ELSE
                                SECTOR := i/(SecSize256+1);
                            END IF;

                            IF PPB_bits(SECTOR)='1' AND
                               DYB_bits(SECTOR)='1' THEN
                                mem(i) := 16#FF#;
                                pgm_page := i / PageSize;
                                QPP_page(pgm_page):='0';
                            END IF;
                        END LOOP;
                        E_ERR := '0';
                        WEL := '0';
                        WIP := '0';
                    ELSE
                        WEL := '0';
                        WIP := '0';
                    END IF;

                END IF;

            WHEN     ers_susp        =>
                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_ERSP,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                IF status /= err THEN
                    WIP := '0' ;
                    ES  := '1' ;
                END IF;
                WAIT FOR 22*half_period ;

            WHEN     ers_resume      =>
                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_ERRS,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                IF status /= err THEN
                    WIP := '1' ;
                    ES  := '0' ;
                END IF;

            WHEN    pg_prog      =>

                SECTOR := command.sect;
                SECSUSP := SECTOR;
                ADDR   := command.addr;
                sepa(AddrLow,AddrHigh,SECTOR,ADDR);
                Byte_number := command.byte_num;
                Data_byte   := command.data1;
                WIP := '1';
                INITIAL_CONFIG <= TRUE;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_PP,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          break   => command.aux=violate,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_PP,
                          address => command.addr,
                          sector  => command.sect,
                          pause   => command.aux=hold_add,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_write,
                          opcode  => I_PP,
                          data_num=> command.byte_num,
                          data1   => command.data1,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                IF status /= err THEN
                    IF (Sec_Prot(SECTOR) /= '1' AND WEL = '1' AND
                        PPB_bits(SECTOR)='1' AND DYB_bits(SECTOR)='1') THEN
                        --if more than PageSize are sent to the device
                        IF Byte_number > PageSize THEN
                            Data_byte := Data_byte + (Byte_number-PageSize);
                            Byte_number := PageSize;
                        END IF;
                        page_addr := ReturnAddr(ADDR,SECTOR);
                        cnt := 0;

                        FOR i IN 0 TO  Byte_number - 1 LOOP
                            --page program
                            slv_1 := to_slv(Data_byte,8);

                            IF mem(page_addr+i-cnt)>-1 THEN
                                slv_2 := to_slv(mem(page_addr+i-cnt),8);
                            ELSE
                                slv_2 := (OTHERS=>'X');
                            END IF;

                            FOR j IN 0 to 7 LOOP
                                --changing bits from 1 to 0
                                IF slv_2(j)='0' THEN
                                    slv_1(j):='0';
                                END IF;
                            END LOOP;

                            mem(page_addr + i - cnt) := to_nat(slv_1);

                            IF page_addr + i - cnt = AddrHigh THEN
                                cnt := i+1;
                                page_addr := AddrLow;
                            END IF;
                            IF Data_byte = 511 THEN
                                Data_byte := 0;
                            ELSE
                                Data_byte := Data_byte + 1;
                            END IF;
                        END LOOP;
                        P_ERR := '0';
                        IF ES = '0' THEN
                            WEL := '0';
                        END IF;
                        WIP := '0';
                    ELSE
                        P_ERR := '1';
                        WEL := '0';
                        WIP := '0';
                    END IF;
                ELSE
                    P_ERR := '1';
                END IF;

            WHEN    pg_prog4      =>

                SECTOR := command.sect;
                ADDR   := command.addr;
                SECSUSP := SECTOR;
                sepa(AddrLow,AddrHigh,SECTOR,ADDR);
                Byte_number := command.byte_num;
                Data_byte   := command.data1;
                WIP := '1';
                INITIAL_CONFIG <= TRUE;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_PP4,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          break   => command.aux=violate,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_PP4,
                          address => command.addr,
                          sector  => command.sect,
                          pause   => command.aux=hold_add,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_write,
                          opcode  => I_PP4,
                          data_num=> command.byte_num,
                          data1   => command.data1,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                IF status /= err THEN
                    IF (Sec_Prot(SECTOR) /= '1' AND WEL = '1' AND
                        PPB_bits(SECTOR)='1' AND DYB_bits(SECTOR)='1') THEN
                        WIP := '1';
                        --if more than PageSize are sent to the device
                        IF Byte_number > PageSize THEN
                            Data_byte := Data_byte + (Byte_number-PageSize);
                            Byte_number := PageSize;
                        END IF;
                        page_addr := ReturnAddr(ADDR,SECTOR);
                        cnt := 0;

                        FOR i IN 0 TO  Byte_number - 1 LOOP
                            --page program
                            slv_1 := to_slv(Data_byte,8);

                            IF mem(page_addr+i-cnt)>-1 THEN
                                slv_2 := to_slv(mem(page_addr+i-cnt),8);
                            ELSE
                                slv_2 := (OTHERS=>'X');
                            END IF;

                            FOR j IN 0 to 7 LOOP
                                --changing bits from 1 to 0
                                IF slv_2(j)='0' THEN
                                    slv_1(j):='0';
                                END IF;
                            END LOOP;

                            mem(page_addr + i - cnt) := to_nat(slv_1);

                            IF page_addr + i - cnt = AddrHigh THEN
                                cnt := i+1;
                                page_addr := AddrLow;
                            END IF;
                            IF Data_byte = 511 THEN
                                Data_byte := 0;
                            ELSE
                                Data_byte := Data_byte + 1;
                            END IF;
                        END LOOP;
                        P_ERR := '0';
                        WEL := '0';
                        WIP := '0';
                    ELSE
                        P_ERR := '1';
                        WEL := '0';
                        WIP := '0';
                    END IF;
                ELSE
                    P_ERR := '1';
                END IF;

            WHEN    quad_pg_prog      =>

                IF TimingModel(10) = 'A' AND TimingModel(11) = 'G' THEN
                    half_period := half_period_quadpg;
                ELSIF TimingModel(10) = 'D' AND TimingModel(11) = 'P' THEN
                    half_period := half_period_ddr;
                END IF;

                SECTOR := command.sect;
                SECSUSP := SECTOR;
                ADDR   := command.addr;
                sepa(AddrLow,AddrHigh,SECTOR,ADDR);
                Byte_number := command.byte_num;
                Data_byte   := command.data1;
                pgm_page := AddrLow / (PageSize+1);
                WIP := '1';
                INITIAL_CONFIG <= TRUE;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_QPP,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          pause   => false,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_QPP,
                          address => command.addr,
                          sector  => command.sect,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_write,
                          opcode  => I_QPP,
                          data_num=> command.byte_num,
                          data1   => command.data1,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                IF status /= err THEN
                    IF (Sec_Prot(SECTOR) /= '1' AND WEL = '1' AND
                        PPB_bits(SECTOR)='1' AND DYB_bits(SECTOR)='1') THEN
                        WIP := '1';
                        --if more than PageSize are sent to the device
                        IF Byte_number > PageSize THEN
                            Data_byte := Data_byte + (Byte_number-PageSize);
                            Byte_number := PageSize;
                        END IF;
                        QPP_page(pgm_page) :='1';
                        page_addr := ReturnAddr(ADDR,SECTOR);
                        cnt := 0;

                        FOR i IN 0 TO  Byte_number - 1 LOOP
                            --page program
                            slv_1 := to_slv(Data_byte,8);

                            IF mem(page_addr+i-cnt)>-1 THEN
                                slv_2 := to_slv(mem(page_addr+i-cnt),8);
                            ELSE
                                slv_2 := (OTHERS=>'X');
                            END IF;

                            FOR j IN 0 to 7 LOOP
                                --changing bits from 1 to 0
                                IF slv_2(j)='0' THEN
                                    slv_1(j):='0';
                                END IF;
                            END LOOP;

                            mem(page_addr + i - cnt) := to_nat(slv_1);

                            IF page_addr + i - cnt = AddrHigh THEN
                                cnt := i+1;
                                page_addr := AddrLow;
                            END IF;
                            IF Data_byte = 511 THEN
                                Data_byte := 0;
                            ELSE
                                Data_byte := Data_byte + 1;
                            END IF;
                        END LOOP;
                        P_ERR := '0';
                        WEL := '0';
                        WIP := '0';
                    ELSE
                        P_ERR := '1';
                        WEL := '0';
                    END IF;
                ELSE
                    P_ERR := '1';
                END IF;

            WHEN    quad_pg_prog4      =>

                IF TimingModel(10) = 'A' AND TimingModel(11) = 'G' THEN
                    half_period := half_period_quadpg;
                ELSIF TimingModel(10) = 'D' AND TimingModel(11) = 'P' THEN
                    half_period := half_period_ddr;
                END IF;

                SECTOR := command.sect;
                SECSUSP := SECTOR;
                ADDR   := command.addr;
                sepa(AddrLow,AddrHigh,SECTOR,ADDR);
                Byte_number := command.byte_num;
                Data_byte   := command.data1;
                pgm_page := AddrLow / (PageSize+1);
                WIP := '1';
                INITIAL_CONFIG <= TRUE;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_QPP4,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          pause   => false,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_QPP4,
                          address => command.addr,
                          sector  => command.sect,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_write,
                          opcode  => I_QPP4,
                          data_num=> command.byte_num,
                          data1   => command.data1,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                IF status /= err THEN
                    IF (Sec_Prot(SECTOR) /= '1' AND WEL = '1' AND
                        PPB_bits(SECTOR)='1' AND DYB_bits(SECTOR)='1') THEN
                        WIP := '1';
                        --if more than PageSize are sent to the device
                        IF Byte_number > PageSize THEN
                            Data_byte := Data_byte + (Byte_number-PageSize);
                            Byte_number := PageSize;
                        END IF;
                        QPP_page(pgm_page) :='1';
                        page_addr := ReturnAddr(ADDR,SECTOR);
                        cnt := 0;

                        FOR i IN 0 TO  Byte_number - 1 LOOP
                            --page program
                            slv_1 := to_slv(Data_byte,8);

                            IF mem(page_addr+i-cnt)>-1 THEN
                                slv_2 := to_slv(mem(page_addr+i-cnt),8);
                            ELSE
                                slv_2 := (OTHERS=>'X');
                            END IF;

                            FOR j IN 0 to 7 LOOP
                                --changing bits from 1 to 0
                                IF slv_2(j)='0' THEN
                                    slv_1(j):='0';
                                END IF;
                            END LOOP;

                            mem(page_addr + i - cnt) := to_nat(slv_1);

                            IF page_addr + i - cnt = AddrHigh THEN
                                cnt := i+1;
                                page_addr := AddrLow;
                            END IF;
                            IF Data_byte = 511 THEN
                                Data_byte := 0;
                            ELSE
                                Data_byte := Data_byte + 1;
                            END IF;
                        END LOOP;
                        P_ERR := '0';
                        WEL := '0';
                        WIP := '0';
                    ELSE
                        P_ERR := '1';
                        WEL   := '0';
                    END IF;
                ELSE
                    P_ERR := '1';
                    WEL   := '0';
                END IF;

            WHEN     prg_susp        =>
                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_PGSP,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                IF status /= err THEN
                    WIP := '0' ;
                    PS  := '1' ;
                END IF;

            WHEN     prg_resume      =>
                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_PGRS,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                IF status /= err THEN
                    WIP := '1' ;
                    PS  := '0' ;
                END IF;

            WHEN    otp_prog      =>

                WIP   := '1';

                ADDR        := command.addr;
                Data_byte   := command.data1;
                Byte_number := command.byte_num;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_OTPP,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          break   => command.aux=violate,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_OTPP,
                          address => command.addr,
                          sector  => 0,
                          pause   => command.aux=hold_add,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_write,
                          opcode  => I_OTPP,
                          data_num=> command.byte_num,
                          data1   => command.data1,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                LOCK_BYTE1 := to_slv(Otp(16#10#),8);
                LOCK_BYTE2 := to_slv(Otp(16#11#),8);
                LOCK_BYTE3 := to_slv(Otp(16#12#),8);
                LOCK_BYTE4 := to_slv(Otp(16#13#),8);

                IF status /= err AND WEL = '1' AND FREEZE = '0' THEN
                    IF (((ADDR >= 16#10# AND ADDR <= 16#13#) OR
                         (ADDR >= 16#20# AND ADDR <= 16#FF#))
                         AND LOCK_BYTE1(ADDR/32) = '1') OR
                       ((ADDR >= 16#100# AND ADDR <= 16#1FF#)
                         AND LOCK_BYTE2((ADDR-16#100#)/32) = '1') OR
                       ((ADDR >= 16#200# AND ADDR <= 16#2FF#)
                         AND LOCK_BYTE3((ADDR-16#200#)/32) = '1') OR
                       ((ADDR >= 16#300# AND ADDR <= 16#3FF#)
                         AND LOCK_BYTE4((ADDR-16#300#)/32) = '1') THEN

                        WIP := '1';
                        IF ADDR + (Byte_number - 1) <= OTPHiAddr THEN
                            FOR i IN 0 TO  Byte_number - 1 LOOP
                                slv_1 := to_slv(Data_byte,8);

                                IF Otp(ADDR + i)>-1 THEN
                                    slv_2 := to_slv(Otp(ADDR + i),8);
                                ELSE
                                    slv_2 := (OTHERS=>'X');
                                END IF;

                                FOR j IN 0 to 7 LOOP
                                    --changing bits from 1 to 0
                                    IF slv_2(j)='0' THEN
                                        slv_1(j):='0';
                                    END IF;
                                END LOOP;

                                Otp(ADDR + i) := to_nat(slv_1);

                                IF Data_byte = 255 THEN
                                    Data_byte := 0;
                                ELSE
                                    Data_byte := Data_byte + 1;
                                END IF;
                            END LOOP;
                        ELSE
                            ASSERT false
                                REPORT "Programming will reach over address "&
                                " limit of OTP array"
                                SEVERITY warning;
                        END IF;
                        P_ERR := '0';
                        WEL   := '0';
                        WIP   := '0';
                    ELSE
                        P_ERR := '1';
                        WEL   := '0';
                    END IF;
                ELSE
                    WEL   := '0';
                    P_ERR := '1';
                END IF;

            WHEN    w_nvldr      =>
                Byte_number := command.byte_num;
                Data_byte   := command.data1;
                WIP := '1';

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                            opcode  => I_PNVDLR,
                            pulse   => command.aux=clock_num,
                            pause   => command.aux=hold_op,
                            tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_write,
                            opcode  => I_PNVDLR,
                            data_num=> command.byte_num,
                            data1   => command.data1,
                            pause   => command.aux=hold_dat,
                            tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                IF status /= err AND WEL = '1' THEN
                    slv_1 := to_slv(Data_byte,8);
                    IF to_nat(NVDLR_reg) > -1 THEN
                        slv_2 := NVDLR_reg;
                    ELSE
                        slv_2 := (OTHERS=>'X');
                    END IF;

                    IF slv_2(7 DOWNTO 0) /= "XXXXXXXX" THEN
                        NVDLR_reg := slv_1;
                        VDLR_reg  := slv_1;
                    END IF;

                    WEL := '0';
                    WIP := '0';
                ELSE
                    P_ERR := '1';
                END IF;

            WHEN    w_wvdlr      =>
                Byte_number := command.byte_num;
                Data_byte   := command.data1;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                            opcode  => I_WVDLR,
                            pulse   => command.aux=clock_num,
                            pause   => command.aux=hold_op,
                            tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_write,
                            opcode  => I_WVDLR,
                            data_num=> command.byte_num,
                            data1   => command.data1,
                            pause   => command.aux=hold_dat,
                            tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                IF status /= err AND WEL = '1' THEN
                    slv_1 := to_slv(Data_byte,8);
                    VDLR_reg  := slv_1;
                    WEL := '0';
                ELSE
                    P_ERR := '1';
                END IF;

            WHEN    otp_read      =>
                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_OTPR,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_OTPR,
                          address => command.addr,
                          sector  => command.sect,
                          pause   => command.aux=hold_add,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_dummy_byte,
                          opcode  => I_OTPR,
                          pause   => command.aux=hold_dum,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_OTPR,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 22*half_period ;

            WHEN    autoboot_rd      =>
                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_ABRD,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_ABRD,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 22*half_period ;

            WHEN    w_autoboot      =>

                WIP := '1';
                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_ABWR,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_write,
                          opcode  => I_ABWR,
                          data_num=> command.byte_num,
                          data1   => command.data1,
                          data2   => command.data2,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                slv_3 := to_slv(command.data1, 16);
                slv_4 := to_slv(command.data2, 16);

                IF status /= err AND WEL = '1' THEN
                    AutoBoot_reg := slv_3(7 downto 0) & slv_3(15 downto 8)&
                                    slv_4(7 downto 0) & slv_4(15 downto 8);
                    WIP := '0';
                    WEL := '0';
                ELSE
                    WEL := '0';
                    WIP := '0';
                    P_ERR := '1';
                END IF;

                WAIT FOR 22*half_period ;

            WHEN    bank_rd      =>
                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_BRRD,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_BRRD,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 22*half_period ;

            WHEN    w_bank      =>

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_BRWR,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_write,
                          opcode  => I_BRWR,
                          data_num=> command.byte_num,
                          data1   => command.data1,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                IF status /= err THEN
                    Bank_Addr_reg := to_slv(command.data1,8);
                END IF;

                WAIT FOR 22*half_period ;

            WHEN    asp_reg_rd      =>
                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_ASPRD,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_ASPRD,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 22*half_period ;

            WHEN    w_asp      =>

                WIP := '1';
                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_ASPP,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_write,
                          opcode  => I_ASPP,
                          data_num=> command.byte_num,
                          data1   => command.data1,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                IF status /= err AND WEL = '1' AND not(ASPOTPFLAG)THEN
                    slv_3 := to_slv(command.data1, 16);

                    IF RPME = '1' THEN
                        RPME    := slv_3(5);
                    END IF;
                    IF PPBOTP = '1' THEN
                        PPBOTP    := slv_3(3);
                    END IF;
                    IF (PWDMLB = '1' AND PSTMLB = '1') THEN
                        IF (slv_3(2) = '0' AND slv_3(1) = '0') THEN
                            P_ERR := '1';
                        ELSE
                            PWDMLB    := slv_3(2);
                            PSTMLB    := slv_3(1);
                            IF (slv_3(2) /= '1' AND slv_3(1) /= '1') THEN
                                ASPOTPFLAG <= true;
                            END IF;
                        END IF;
                    END IF;

                    WIP := '0';
                    WEL := '0';
                ELSE
                    WEL := '0';
                    WIP := '0';
                    P_ERR := '1';
                END IF;

                WAIT FOR 22*half_period ;

            WHEN    pass_reg_rd      =>
                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_PASSRD,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_PASSRD,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          break   => command.aux=violate,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 22*half_period ;

            WHEN    w_password      =>

                WIP := '1';
                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_PASSP,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_write,
                          opcode  => I_PASSP,
                          data_num=> command.byte_num,
                          data1   => command.data1,
                          data2   => command.data2,
                          data3   => command.data3,
                          data4   => command.data4,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                IF status /= err AND WEL = '1' THEN
                    Password_reg := to_slv(command.data4, 16)&
                                    to_slv(command.data3, 16)&
                                    to_slv(command.data2, 16)&
                                    to_slv(command.data1, 16);
                    WIP := '0';
                    WEL := '0';
                ELSE
                    WEL := '0';
                    WIP := '0';
                    P_ERR := '1';
                END IF;

                WAIT FOR 22*half_period ;

            WHEN    psw_unlock      =>

                WIP := '1';
                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_PASSU,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_write,
                          opcode  => I_PASSU,
                          data_num=> command.byte_num,
                          data1   => command.data1,
                          data2   => command.data2,
                          data3   => command.data3,
                          data4   => command.data4,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                IF status /= err THEN
                    Pass_tmp := to_slv(command.data4, 16)&
                                to_slv(command.data3, 16)&
                                to_slv(command.data2, 16)&
                                to_slv(command.data1, 16);
                    IF Pass_tmp = Password_reg  AND PWDMLB = '0' THEN
                        PPB_LOCK := '1';
                    ELSE
                        P_ERR := '1';
                    END IF;
                    WIP   := '0';
                    WEL   := '0';
                ELSE
                    WEL := '0';
                    WIP := '0';
                    P_ERR := '1';
                END IF;

                WAIT FOR 22*half_period ;

            WHEN    ppbl_reg_rd       =>

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_PLBRD,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_PLBRD,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 22*half_period ;

            WHEN    w_ppbl_reg       =>

                WIP := '1';

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_PLBWR,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                IF status /= err AND WEL = '1' THEN
                    PPB_LOCK := '0';
                    WIP  := '0';
                    WEL  := '0';
                END IF;

                WAIT FOR 22*half_period ;

            WHEN    ppbacc_rd       =>

                SECTOR := command.sect;
                IF PPB_bits(SECTOR) = '1' THEN
                    PPBAR(7 downto 0) := "11111111";
                ELSE
                    PPBAR(7 downto 0) := "00000000";
                END IF;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_PPBRD,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_PPBRD,
                          address => command.addr,
                          sector  => command.sect,
                          pause   => command.aux=hold_add,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_PPBRD,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

            WHEN    w_ppb  =>

                SECTOR := command.sect;
                ADDR   := command.addr;
                WIP := '1';

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_PPBP,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_PPBP,
                          address => command.addr,
                          sector  => command.sect,
                          pause   => command.aux=hold_add,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                IF status /= err AND WEL = '1' THEN
                    IF PPB_LOCK /= '0' THEN
                        PPB_bits(SECTOR):= '0';
                        P_ERR := '0';
                        WEL := '0';
                        WIP := '0';
                    ELSE
                        P_ERR := '1';
                        WEL := '0';
                        WIP := '0';
                    END IF;
                END IF;

            WHEN    ppb_ers  =>

                WIP := '1';

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_PPBERS,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                IF status /= err AND WEL = '1' THEN
                    IF PPB_LOCK /= '0' AND PPBOTP = '1' THEN
                        PPB_bits:= (OTHERS => '1');
                    ELSE
                        E_ERR := '1';
                    END IF;
                    WIP   := '0';
                    WEL   := '0';
                END IF;

            WHEN    dybacc_rd       =>

                SECTOR := command.sect;
                IF DYB_bits(SECTOR) = '1' THEN
                    DYBAR(7 downto 0) := "11111111";
                ELSE
                    DYBAR(7 downto 0) := "00000000";
                END IF;

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_DYBRD,
                          pulse   => false,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_DYBRD,
                          address => command.addr,
                          sector  => command.sect,
                          pause   => command.aux=hold_add,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_read,
                          opcode  => I_DYBRD,
                          data_num=> command.byte_num,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_desel_read);

                WAIT FOR 22*half_period ;

            WHEN    w_dyb  =>

                SECTOR := command.sect;
                ADDR   := command.addr;
                Data_byte :=  command.data1;
                slv_1 := to_slv(Data_byte,8);
                WIP := '1';

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_DYBWR,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_address,
                          opcode  => I_DYBWR,
                          address => command.addr,
                          sector  => command.sect,
                          pause   => command.aux=hold_add,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_data_write,
                          opcode  => I_DYBWR,
                          data_num=> command.byte_num,
                          data1   => command.data1,
                          pause   => command.aux=hold_dat,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                IF status /= err AND WEL = '1' THEN
                    DYBAR := slv_1;
                    IF DYBAR = "11111111" THEN
                        DYB_bits(SECTOR):= '1';
                    ELSIF DYBAR = "00000000" THEN
                        DYB_bits(SECTOR):= '0';
                    ELSE
                        P_ERR := '1';
                    END IF;
                    WIP  := '0';
                    WEL  := '0';
                END IF;

            WHEN    rst    =>

                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_opcode,
                          opcode  => I_RESET,
                          pulse   => command.aux=clock_num,
                          pause   => command.aux=hold_op,
                          tm      => command.wtime);

                bus_cycle(bus_cmd => bus_deselect);

                IF ABE = '1' THEN
                    IF QUAD = '1' THEN
                        IF start_delay > 0 THEN
                            half_period := half_period_quad;
                        ELSE
                            half_period := half_period2_srl;
                        END IF;
                    ELSE
                        IF start_delay > 0 THEN
                            half_period := half_period1_srl;
                        ELSE
                            half_period := half_period2_srl;
                        END IF;
                    END IF;

                    WAIT FOR 50 ns;

                    bus_cycle(bus_cmd => bus_select);

                    bus_cycle(bus_cmd => bus_st_delay);

                    bus_cycle(bus_cmd => bus_data_read,
                              opcode  => I_RESET,
                              data_num=> command.byte_num,
                              pulse   => command.aux=clock_num,
                              tm      => command.wtime);

                    IF QUAD = '1' THEN
                    WAIT FOR 6 ns;
                    END IF;
                    bus_cycle(bus_cmd => bus_desel_read);

                    IF QUAD = '1' THEN
                    WAIT FOR 2*half_period;
                    T_WPNeg <= '1';
                    END IF;
                END IF;

                IF status /= err  THEN
                    P_ERR  := '0';
                    E_ERR  := '0';
                    PS  := '0';
                    ES  := '0';
                    WIP := '0';
                    --The EXTADD is set for Address mode
                    EXTADD := '0';
                    --The WEL bit is cleared.
                    WEL := '0';
                    --When BPNV is set to '1'. the BP2-0 bits in Status
                    --Register are volatile and will be reseted after
                    --reset command
                    IF BPNV = '1'  AND FREEZE = '0' THEN
                        BP0 := '1';
                        BP1 := '1';
                        BP2 := '1';
                        BP_bits := BP2 & BP1 & BP0;
                        Sec_Prot := (OTHERS => '1');
                    END IF;
                END IF;
                WAIT for 50 ns;

            WHEN    wt          =>
                WAIT FOR command.wtime;
                WAIT for 50 ns;

            WHEN    inv_write          =>
                bus_cycle(bus_cmd => bus_select);

                bus_cycle(bus_cmd => bus_inv_write,
                          data_num=> command.byte_num,
                          opcode  => to_slv(command.data1,8));

                bus_cycle(bus_cmd => bus_deselect);

                IF status /= err THEN
                    IF BP0 = '0' AND BP1 = '0' AND BP2 = '0' THEN
                        FOR i IN 0 TO ADDRRange LOOP
                            mem(i) := 16#FF#;
                        END LOOP;
                        E_ERR := '0';
                    ELSE
                        E_ERR := '0';
                    END IF;
                    WEL := '0';
                END IF;

            WHEN    OTHERS  =>  null;
        END CASE;

    END PROCEDURE;

    VARIABLE cmd_cnt    :   NATURAL;
    VARIABLE command    :   cmd_rec;

BEGIN
    TestInit(TimingModel, LongTimming);
    Pick_TC (Model   =>  "s25fl256s");

    Tseries <=  ts_cnt  ;
    Tcase   <=  tc_cnt  ;

    Generate_TC
        (Model       => TimingModel ,
         Series      => ts_cnt,
         TestCase    => tc_cnt,
         Sec_Arch    => BootConfig,
         command_seq => cmd_seq);

    cmd_cnt := 1;
    WHILE cmd_seq(cmd_cnt).cmd /= done LOOP
        command  := cmd_seq(cmd_cnt);
        status   <=  command.status;
        cmd      <=  command.cmd;
        read_num <= command.byte_num;
        cmd_dc(command);
        cmd_cnt :=cmd_cnt +1;
    END LOOP;

END PROCESS tb;

-------------------------------------------------------------------------------
-- Checker process,
-------------------------------------------------------------------------------
checker: PROCESS
    VARIABLE Addr_reg    : std_logic_vector(31 downto 0);
    VARIABLE Data_reg    : std_logic_vector(63 downto 0);
    VARIABLE DLP0_reg    : std_logic_vector(7 downto 0);
    VARIABLE DLP1_reg    : std_logic_vector(7 downto 0);
    VARIABLE DLP2_reg    : std_logic_vector(7 downto 0);
    VARIABLE DLP3_reg    : std_logic_vector(7 downto 0);
    VARIABLE DLP_ACT     : std_logic_vector(1 downto 0);
    VARIABLE DLP_EN      : std_logic;
    VARIABLE Pass_out    : std_logic_vector(63 downto 0);
    VARIABLE address     : NATURAL RANGE 0 TO AddrRANGE;
    VARIABLE byte        : NATURAL;
    VARIABLE CFIaddress  : NATURAL RANGE 16#00# TO 16#55#;
    VARIABLE tmp         : NATURAL;
    VARIABLE Lat_cnt     : NATURAL;
    VARIABLE start_del   : NATURAL;
    VARIABLE Sec_addr    : NATURAL RANGE 0 TO SecSize256;
    VARIABLE SecAddr     : NATURAL RANGE 0 TO AddrRANGE;
    VARIABLE AutoBoot_reg_rd   : std_logic_vector(31 downto 0);

BEGIN

    IF (T_CSNeg='0') THEN
        DLP_EN := '0';
        DLP0_reg(7 downto 0) := (OTHERS => '0');
        DLP1_reg(7 downto 0) := (OTHERS => '0');
        DLP2_reg(7 downto 0) := (OTHERS => '0');
        DLP3_reg(7 downto 0) := (OTHERS => '0');

        --Opcode
        IF (status /= rd_cont_dualIO AND status /= rd_cont_dualIO4 AND
            status /= rd_cont_quadIO AND status /= rd_cont_quadIO4 AND
            status /= rd_cont_fddr AND status /= rd_cont_fddr4 AND
            status /= rd_cont_dddr AND status /= rd_cont_dddr4 AND
            status /= rd_cont_qddr AND status /= rd_cont_qddr4 AND
            status /= none) THEN
            FOR I IN 7 DOWNTO 0 LOOP
                WAIT UNTIL (rising_edge(T_SCK) AND T_HOLDNeg = '1');
            END LOOP;
        END IF;

        --Address
        --3 Bytes Address
        IF ((cmd = rd OR cmd = fast_rd OR cmd = dual_rd OR cmd = quad_rd OR
             cmd = read_ID) AND EXTADD = '0') OR cmd = otp_read THEN
            FOR I IN 23 DOWNTO 0 LOOP
                WAIT UNTIL (rising_edge(T_SCK) AND
                           ((T_HOLDNeg = '1' AND QUAD = '0') OR QUAD = '1'));
                Addr_reg(i) := T_SI;
            END LOOP;
            Addr_reg(31 downto 25):= "0000000";
            Addr_reg(24):= Bank_Addr_reg(0);
            address := to_nat(Addr_reg(31 downto 0));
        ELSIF cmd = dual_high_rd AND EXTADD= '0' THEN
            FOR I IN 0 TO 11 LOOP
                WAIT UNTIL (rising_edge(T_SCK) AND
                           ((T_HOLDNeg = '1' AND QUAD = '0') OR QUAD = '1'));
                Addr_reg(23-2*i) := T_SO;
                Addr_reg(22-2*i) := T_SI;
            END LOOP;
            Addr_reg(31 downto 25):= "0000000";
            Addr_reg(24):= Bank_Addr_reg(0);
            address := to_nat(Addr_reg(31 downto 0));
        ELSIF cmd = quad_high_rd AND EXTADD= '0' THEN
            FOR I IN 0 TO 5 LOOP
                WAIT UNTIL rising_edge(T_SCK);
                Addr_reg(23-4*i) := T_HOLDNeg;
                Addr_reg(22-4*i) := T_WPNeg;
                Addr_reg(21-4*i) := T_SO;
                Addr_reg(20-4*i) := T_SI;
            END LOOP;
            Addr_reg(31 downto 25):= "0000000";
            Addr_reg(24):= Bank_Addr_reg(0);
            address := to_nat(Addr_reg(31 downto 0));
        ELSIF cmd = fast_ddr_rd AND EXTADD= '0' THEN
            WAIT UNTIL rising_edge(T_SCK);
            Addr_reg(23) := T_SI;
            FOR I IN 1 TO 23 LOOP
                WAIT UNTIL T_SCK'EVENT;
               Addr_reg(23-i) := T_SI;
            END LOOP;
            Addr_reg(31 downto 25):= "0000000";
            Addr_reg(24):= Bank_Addr_reg(0);
            address := to_nat(Addr_reg(31 downto 0));
        ELSIF cmd = dual_high_ddr_rd AND EXTADD= '0' THEN
            WAIT UNTIL rising_edge(T_SCK);
            Addr_reg(23) := T_SO;
            Addr_reg(22) := T_SI;
            FOR I IN 1 TO 11 LOOP
                WAIT UNTIL T_SCK'EVENT;
                Addr_reg(23-2*i) := T_SO;
                Addr_reg(22-2*i) := T_SI;
            END LOOP;
            Addr_reg(31 downto 25):= "0000000";
            Addr_reg(24):= Bank_Addr_reg(0);
            address := to_nat(Addr_reg(31 downto 0));
        ELSIF cmd = quad_high_ddr_rd AND EXTADD= '0' THEN
            WAIT UNTIL rising_edge(T_SCK);
            Addr_reg(23)   := T_HOLDNeg;
            Addr_reg(22)   := T_WPNeg;
            Addr_reg(21)   := T_SO;
            Addr_reg(20)   := T_SI;
            FOR I IN 1 TO 5 LOOP
                WAIT UNTIL T_SCK'EVENT;
                Addr_reg(23-4*i)   := T_HOLDNeg;
                Addr_reg(22-4*i)   := T_WPNeg;
                Addr_reg(21-4*i)   := T_SO;
                Addr_reg(20-4*i)   := T_SI;
            END LOOP;
            Addr_reg(31 downto 25):= "0000000";
            Addr_reg(24):= Bank_Addr_reg(0);
            address := to_nat(Addr_reg(31 downto 0));
        END IF;

        --4 Bytes Address
        IF ((cmd = fast_rd OR cmd = dual_rd OR cmd = quad_rd OR cmd = rd) AND
             EXTADD = '1') OR cmd = fast_rd4 OR cmd = dual_rd_4 OR
             cmd = quad_rd_4 OR cmd = rd_4 OR cmd = ppbacc_rd OR
             cmd = dybacc_rd THEN
            FOR I IN 31 DOWNTO 0 LOOP
                WAIT UNTIL (rising_edge(T_SCK) AND
                          ((T_HOLDNeg = '1' AND QUAD = '0') OR QUAD = '1'));
                Addr_reg(i) := T_SI;
            END LOOP;
            address := to_nat(Addr_reg(31 downto 0));
        ELSIF (cmd = dual_high_rd AND EXTADD= '1') OR cmd = dual_high_rd_4 THEN
            FOR I IN 0 TO 15 LOOP
                WAIT UNTIL (rising_edge(T_SCK) AND
                          ((T_HOLDNeg = '1' AND QUAD = '0') OR QUAD = '1'));
                Addr_reg(31-2*i) := T_SO;
                Addr_reg(30-2*i) := T_SI;
            END LOOP;
            address := to_nat(Addr_reg(31 downto 0));
        ELSIF (cmd = quad_high_rd AND EXTADD= '1') OR cmd = quad_high_rd_4 THEN
            FOR I IN 0 TO 7 LOOP
                WAIT UNTIL rising_edge(T_SCK);
                Addr_reg(31-4*i) := T_HOLDNeg;
                Addr_reg(30-4*i) := T_WPNeg;
                Addr_reg(29-4*i) := T_SO;
                Addr_reg(28-4*i) := T_SI;
            END LOOP;
            address := to_nat(Addr_reg(31 downto 0));
        ELSIF (cmd = fast_ddr_rd AND EXTADD= '1') OR cmd = fast_ddr_rd4 THEN
            WAIT UNTIL rising_edge(T_SCK);
            Addr_reg(31) := T_SI;
            FOR I IN 1 TO 31 LOOP
                WAIT UNTIL T_SCK'EVENT;
                Addr_reg(31-i) := T_SI;
            END LOOP;
            address := to_nat(Addr_reg(31 downto 0));
        ELSIF (cmd = dual_high_ddr_rd AND EXTADD= '1') OR
               cmd = dual_high_ddr_rd4 THEN
            WAIT UNTIL rising_edge(T_SCK);
            Addr_reg(31) := T_SO;
            Addr_reg(30) := T_SI;
            FOR I IN 1 TO 15 LOOP
                WAIT UNTIL T_SCK'EVENT;
                Addr_reg(31-2*i) := T_SO;
                Addr_reg(30-2*i) := T_SI;
            END LOOP;
            address := to_nat(Addr_reg(31 downto 0));
        ELSIF (cmd = quad_high_ddr_rd AND EXTADD= '1') OR
               cmd = quad_high_ddr_rd_4 THEN
            WAIT UNTIL rising_edge(T_SCK);
            Addr_reg(31)   := T_HOLDNeg;
            Addr_reg(30)   := T_WPNeg;
            Addr_reg(29)   := T_SO;
            Addr_reg(28)   := T_SI;
            FOR I IN 1 TO 7 LOOP
                WAIT UNTIL T_SCK'EVENT;
                Addr_reg(31-4*i)   := T_HOLDNeg;
                Addr_reg(30-4*i)   := T_WPNeg;
                Addr_reg(29-4*i)   := T_SO;
                Addr_reg(28-4*i)   := T_SI;
            END LOOP;
            address := to_nat(Addr_reg(31 downto 0));
        END IF;

       IF cmd = rst AND ABE = '1' THEN
           Addr_reg(31 downto 9):= Autoboot_reg(31 downto 9);
           Addr_reg(8 downto 0):= "000000000";
           address := to_nat(Addr_reg(31 downto 0));
       END IF;

        --Mode Byte
        IF (TimingModel(15) = '0' OR TimingModel(15) = '2' OR
            TimingModel(15) = '3' OR TimingModel(15) = 'R' OR
            TimingModel(15) = 'A' OR TimingModel(15) = 'B' OR
            TimingModel(15) = 'C' OR TimingModel(15) = 'D' OR
            TimingModel(15) = 'Y' OR TimingModel(15) = 'Z' OR
            TimingModel(15) = 'S' OR TimingModel(15) = 'T' OR
            TimingModel(15) = 'K' OR TimingModel(15) = 'L') THEN
            IF cmd = dual_high_rd OR cmd = dual_high_rd_4 THEN
                FOR I IN 3 DOWNTO 0 LOOP
                    WAIT UNTIL rising_edge(T_SCK);
                END LOOP;
            ELSIF cmd = fast_ddr_rd OR cmd = fast_ddr_rd4 THEN
                FOR I IN 7 DOWNTO 0 LOOP
                    WAIT UNTIL T_SCK'EVENT;
                END LOOP;
            ELSIF cmd = quad_high_rd OR cmd = quad_high_rd_4 THEN
                FOR I IN 1 DOWNTO 0 LOOP
                    WAIT UNTIL rising_edge(T_SCK);
                END LOOP;
            ELSIF cmd = dual_high_ddr_rd OR cmd = dual_high_ddr_rd4 THEN
                FOR I IN 3 DOWNTO 0 LOOP
                    WAIT UNTIL T_SCK'EVENT;
                END LOOP;
            ELSIF cmd = quad_high_ddr_rd OR cmd = quad_high_ddr_rd_4 THEN
                FOR I IN 1 DOWNTO 0 LOOP
                    WAIT UNTIL T_SCK'EVENT;
                END LOOP;
            END IF;
        ELSIF (TimingModel(15) = '4' OR TimingModel(15) = '6' OR
               TimingModel(15) = '7' OR TimingModel(15) = '8' OR
               TimingModel(15) = '9' OR TimingModel(15) = 'Q') THEN
            IF cmd = quad_high_rd OR cmd = quad_high_rd_4 THEN
                FOR I IN 3 DOWNTO 0 LOOP
                    WAIT UNTIL T_SCK'EVENT;
                END LOOP;
            ELSIF cmd = quad_high_ddr_rd OR cmd = quad_high_ddr_rd_4 THEN
                FOR I IN 1 DOWNTO 0 LOOP
                    WAIT UNTIL T_SCK'EVENT;
                END LOOP;
            END IF;
        END IF;
            
        -- Dummy Bytes
        Lat_cnt := to_nat(LC1 & LC0);
        IF (cmd = fast_rd OR cmd = fast_rd4 OR cmd = otp_read
           OR cmd = dual_rd OR cmd = dual_rd_4 OR cmd=quad_rd OR cmd=quad_rd_4
           OR cmd=fast_ddr_rd OR cmd=fast_ddr_rd4) THEN
            IF cmd=fast_ddr_rd OR cmd=fast_ddr_rd4 THEN
                IF (TimingModel(15) = '0' OR TimingModel(15) = '2' OR
                    TimingModel(15) = '3' OR TimingModel(15) = 'R' OR
                    TimingModel(15) = 'A' OR TimingModel(15) = 'B' OR
                    TimingModel(15) = 'C' OR TimingModel(15) = 'D' OR
                    TimingModel(15) = 'Y' OR TimingModel(15) = 'Z' OR
                    TimingModel(15) = 'S' OR TimingModel(15) = 'T' OR
                    TimingModel(15) = 'K' OR TimingModel(15) = 'L') THEN
                    IF Lat_cnt = 0 THEN
                        FOR I IN 1 DOWNTO 0 LOOP
                            WAIT UNTIL rising_edge(T_SCK);
                        END LOOP;
                    ELSIF Lat_cnt = 1 THEN
                        FOR I IN 6 DOWNTO 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                        END LOOP;
                    ELSIF Lat_cnt = 2 THEN
                        IF (VDLR_reg /= "00000000") THEN
                            WAIT UNTIL rising_edge(T_SCK);
                        END IF;
                        FOR I IN 7 DOWNTO 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 6.5 ns;
                            IF (VDLR_reg /= "00000000") THEN
                                DLP0_reg(I) := T_SO;
                            END IF;
                        END LOOP;
                        DLP_EN := '1';
                        IF (VDLR_reg = "00000000") THEN
                            WAIT UNTIL rising_edge(T_SCK);
                        END IF;
                    ELSIF Lat_cnt = 3 THEN
                        WAIT UNTIL rising_edge(T_SCK);
                    END IF;
                ELSIF (TimingModel(15) = '4' OR TimingModel(15) = '6' OR
                       TimingModel(15) = '7' OR TimingModel(15) = '8' OR
                       TimingModel(15) = '9' OR TimingModel(15) = 'Q') THEN
                    IF Lat_cnt = 0 THEN
                        IF (VDLR_reg /= "00000000") THEN
                            WAIT UNTIL rising_edge(T_SCK);
                        END IF;
                        FOR I IN 7 DOWNTO 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 6.5 ns;
                            IF (VDLR_reg /= "00000000") THEN
                                DLP0_reg(I) := T_SO;
                            END IF;
                        END LOOP;
                        DLP_EN := '1';
                        IF (VDLR_reg = "00000000") THEN
                            WAIT UNTIL rising_edge(T_SCK);
                        END IF;
                    ELSIF Lat_cnt = 1 THEN
                        FOR I IN 1 DOWNTO 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                        END LOOP;
                        IF (VDLR_reg /= "00000000") THEN
                            WAIT UNTIL rising_edge(T_SCK);
                        END IF;
                        FOR I IN 7 DOWNTO 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 6.5 ns;
                            IF (VDLR_reg /= "00000000") THEN
                                DLP0_reg(I) := T_SO;
                            END IF;
                        END LOOP;
                        DLP_EN := '1';
                        IF (VDLR_reg = "00000000") THEN
                            WAIT UNTIL rising_edge(T_SCK);
                        END IF;
                    ELSIF Lat_cnt = 2 THEN
                        FOR I IN 3 DOWNTO 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                        END LOOP;
                        IF (VDLR_reg /= "00000000") THEN
                            WAIT UNTIL rising_edge(T_SCK);
                        END IF;
                        FOR I IN 7 DOWNTO 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 6.5 ns;
                            IF (VDLR_reg /= "00000000") THEN
                                DLP0_reg(I) := T_SO;
                            END IF;
                        END LOOP;
                        DLP_EN := '1';
                        IF (VDLR_reg = "00000000") THEN
                            WAIT UNTIL rising_edge(T_SCK);
                        END IF;
                    ELSIF Lat_cnt = 3 THEN
                        FOR I IN 3 DOWNTO 0 LOOP
                            WAIT UNTIL rising_edge(T_SCK);
                        END LOOP;
                    END IF;
                END IF;            
            ELSE
                IF Lat_cnt /= 3 AND (cmd=quad_rd OR cmd=quad_rd_4) THEN
                    FOR I IN 7 DOWNTO 0 LOOP
                        WAIT UNTIL (rising_edge(T_SCK));
                    END LOOP;
                ELSIF Lat_cnt /= 3 THEN
                    FOR I IN 7 DOWNTO 0 LOOP
                        WAIT UNTIL (rising_edge(T_SCK) AND T_HOLDNeg = '1');
                    END LOOP;
                END IF;
            END IF;
        ELSIF cmd = read_ES THEN
            FOR I IN 23 DOWNTO 0 LOOP
                WAIT UNTIL rising_edge(T_SCK);
            END LOOP;
        ELSIF cmd = ecc_rd THEN
            FOR I IN 7 DOWNTO 0 LOOP
                WAIT UNTIL rising_edge(T_SCK);
            END LOOP;
        ELSIF cmd = dual_high_rd OR cmd = dual_high_rd_4 THEN
            IF (TimingModel(15) = '0' OR TimingModel(15) = '2' OR
                TimingModel(15) = '3' OR TimingModel(15) = 'R' OR
                TimingModel(15) = 'A' OR TimingModel(15) = 'B' OR
                TimingModel(15) = 'C' OR TimingModel(15) = 'D' OR
                TimingModel(15) = 'Y' OR TimingModel(15) = 'Z' OR
                TimingModel(15) = 'S' OR TimingModel(15) = 'T' OR
                TimingModel(15) = 'K' OR TimingModel(15) = 'L') THEN
                IF Lat_cnt = 1 THEN
                    WAIT UNTIL rising_edge(T_SCK);
                ELSIF Lat_cnt = 2 THEN
                    FOR I IN 1 DOWNTO 0 LOOP
                        WAIT UNTIL rising_edge(T_SCK);
                    END LOOP;
                END IF;
            ELSIF (TimingModel(15) = '4' OR TimingModel(15) = '6' OR
                   TimingModel(15) = '7' OR TimingModel(15) = '8' OR
                   TimingModel(15) = '9' OR TimingModel(15) = 'Q') THEN
                IF Lat_cnt = 0 THEN
                    FOR I IN 3 DOWNTO 0 LOOP
                        WAIT UNTIL rising_edge(T_SCK);
                    END LOOP;
                ELSIF Lat_cnt = 1 THEN
                    FOR I IN 4 DOWNTO 0 LOOP
                        WAIT UNTIL rising_edge(T_SCK);
                    END LOOP;
                ELSIF Lat_cnt = 2 THEN
                    FOR I IN 5 DOWNTO 0 LOOP
                        WAIT UNTIL rising_edge(T_SCK);
                    END LOOP;
                ELSIF Lat_cnt = 3 THEN
                    FOR I IN 3 DOWNTO 0 LOOP
                        WAIT UNTIL rising_edge(T_SCK);
                    END LOOP;
                END IF;
            END IF;
        ELSIF cmd = dual_high_ddr_rd OR cmd = dual_high_ddr_rd4 OR
              cmd = quad_high_rd OR cmd = quad_high_rd_4 THEN
            IF cmd = dual_high_ddr_rd OR cmd = dual_high_ddr_rd4 THEN
                IF (TimingModel(15) = '0' OR TimingModel(15) = '2' OR
                    TimingModel(15) = '3' OR TimingModel(15) = 'R' OR
                    TimingModel(15) = 'A' OR TimingModel(15) = 'B' OR
                    TimingModel(15) = 'C' OR TimingModel(15) = 'D' OR
                    TimingModel(15) = 'Y' OR TimingModel(15) = 'Z' OR
                    TimingModel(15) = 'S' OR TimingModel(15) = 'T' OR
                    TimingModel(15) = 'K' OR TimingModel(15) = 'L') THEN
                    IF Lat_cnt = 0 THEN
                        FOR I IN 3 DOWNTO 0 LOOP
                            WAIT UNTIL rising_edge(T_SCK);
                        END LOOP;
                    ELSIF Lat_cnt = 1 THEN
                        IF (VDLR_reg /= "00000000") THEN
                            WAIT UNTIL rising_edge(T_SCK);
                        END IF;
                        FOR I IN 7 DOWNTO 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 6.5 ns;
                            IF (VDLR_reg /= "00000000") THEN
                                DLP0_reg(I) := T_SO;
                                DLP1_reg(I) := T_SI;
                            END IF;
                        END LOOP;
                        DLP_EN := '1';
                        IF (VDLR_reg = "00000000") THEN
                            WAIT UNTIL rising_edge(T_SCK);
                        END IF;
                    ELSIF Lat_cnt = 2 THEN
                        FOR I IN 1 DOWNTO 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                        END LOOP;
                        IF (VDLR_reg /= "00000000") THEN
                            WAIT UNTIL rising_edge(T_SCK);
                        END IF;
                        FOR I IN 7 DOWNTO 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 6.5 ns;
                            IF (VDLR_reg /= "00000000") THEN
                                DLP0_reg(I) := T_SO;
                                DLP1_reg(I) := T_SI;
                            END IF;
                        END LOOP;
                        DLP_EN := '1';
                        IF (VDLR_reg = "00000000") THEN
                            WAIT UNTIL rising_edge(T_SCK);
                        END IF;
                    ELSIF Lat_cnt = 3 THEN
                        FOR I IN 1 DOWNTO 0 LOOP
                            WAIT UNTIL rising_edge(T_SCK);
                        END LOOP;
                    END IF;
                ELSIF (TimingModel(15) = '4' OR TimingModel(15) = '6' OR
                       TimingModel(15) = '7' OR TimingModel(15) = '8' OR
                       TimingModel(15) = '9' OR TimingModel(15) = 'Q') THEN
                    IF Lat_cnt = 0 THEN
                        FOR I IN 1 DOWNTO 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                        END LOOP;
                        IF (VDLR_reg /= "00000000") THEN
                            WAIT UNTIL rising_edge(T_SCK);
                        END IF;
                        FOR I IN 7 DOWNTO 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 6.5 ns;
                            IF (VDLR_reg /= "00000000") THEN
                                DLP0_reg(I) := T_SO;
                                DLP1_reg(I) := T_SI;
                            END IF;
                        END LOOP;
                        DLP_EN := '1';
                        IF (VDLR_reg = "00000000") THEN
                            WAIT UNTIL rising_edge(T_SCK);
                        END IF;
                    ELSIF Lat_cnt = 1 THEN
                        FOR I IN 3 DOWNTO 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                        END LOOP;
                        IF (VDLR_reg /= "00000000") THEN
                            WAIT UNTIL rising_edge(T_SCK);
                        END IF;
                        FOR I IN 7 DOWNTO 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 6.5 ns;
                            IF (VDLR_reg /= "00000000") THEN
                                DLP0_reg(I) := T_SO;
                                DLP1_reg(I) := T_SI;
                            END IF;
                        END LOOP;
                        DLP_EN := '1';
                        IF (VDLR_reg = "00000000") THEN
                            WAIT UNTIL rising_edge(T_SCK);
                        END IF;
                    ELSIF Lat_cnt = 2 THEN
                        FOR I IN 5 DOWNTO 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                        END LOOP;
                        IF (VDLR_reg /= "00000000") THEN
                            WAIT UNTIL rising_edge(T_SCK);
                        END IF;
                        FOR I IN 7 DOWNTO 0 LOOP
                            WAIT UNTIL T_SCK'EVENT;
                            WAIT FOR 6.5 ns;
                            IF (VDLR_reg /= "00000000") THEN
                                DLP0_reg(I) := T_SO;
                                DLP1_reg(I) := T_SI;
                            END IF;
                        END LOOP;
                        DLP_EN := '1';
                        IF (VDLR_reg = "00000000") THEN
                            WAIT UNTIL rising_edge(T_SCK);
                        END IF;
                    ELSIF Lat_cnt = 3 THEN
                        FOR I IN 3 DOWNTO 0 LOOP
                            WAIT UNTIL rising_edge(T_SCK);
                        END LOOP;
                    END IF;
                END IF;
            ELSE
                IF Lat_cnt = 0 THEN
                    FOR I IN 3 DOWNTO 0 LOOP
                        WAIT UNTIL rising_edge(T_SCK);
                    END LOOP;
                ELSIF Lat_cnt = 1 THEN
                    FOR I IN 3 DOWNTO 0 LOOP
                        WAIT UNTIL rising_edge(T_SCK);
                    END LOOP;
                ELSIF Lat_cnt = 2 THEN
                    FOR I IN 4 DOWNTO 0 LOOP
                        WAIT UNTIL rising_edge(T_SCK);
                    END LOOP;
                ELSIF Lat_cnt = 3 THEN
                    WAIT UNTIL rising_edge(T_SCK);
                END IF;
            END IF;
        ELSIF cmd = quad_high_ddr_rd OR cmd = quad_high_ddr_rd_4 THEN
            IF Lat_cnt = 0 THEN
                FOR I IN 1 DOWNTO 0 LOOP
                    WAIT UNTIL T_SCK'EVENT;
                END LOOP;
                IF (VDLR_reg /= "00000000") THEN
                    WAIT UNTIL rising_edge(T_SCK);
                END IF;
                FOR I IN 7 DOWNTO 0 LOOP
                    WAIT UNTIL T_SCK'EVENT;
                    WAIT FOR 6.5 ns;
                    IF (VDLR_reg /= "00000000") THEN
                        DLP0_reg(I) := T_SO;
                        DLP1_reg(I) := T_SI;
                        DLP2_reg(I) := T_WPNeg;
                        DLP3_reg(I) := T_HOLDNeg;
                    END IF;
                END LOOP;
                DLP_EN := '1';
                IF (VDLR_reg = "00000000") THEN
                    WAIT UNTIL rising_edge(T_SCK);
                END IF;
            ELSIF Lat_cnt = 1 THEN
                FOR I IN 3 DOWNTO 0 LOOP
                    WAIT UNTIL T_SCK'EVENT;
                END LOOP;
                IF (VDLR_reg /= "00000000") THEN
                    WAIT UNTIL rising_edge(T_SCK);
                END IF;
                FOR I IN 7 DOWNTO 0 LOOP
                    WAIT UNTIL T_SCK'EVENT;
                    WAIT FOR 6.5 ns;
                    IF (VDLR_reg /= "00000000") THEN
                        DLP0_reg(I) := T_SO;
                        DLP1_reg(I) := T_SI;
                        DLP2_reg(I) := T_WPNeg;
                        DLP3_reg(I) := T_HOLDNeg;
                    END IF;
                END LOOP;
                DLP_EN := '1';
                IF (VDLR_reg = "00000000") THEN
                    WAIT UNTIL rising_edge(T_SCK);
                END IF;
            ELSIF Lat_cnt = 2 THEN
                FOR I IN 5 DOWNTO 0 LOOP
                    WAIT UNTIL T_SCK'EVENT;
                END LOOP;
                IF (VDLR_reg /= "00000000") THEN
                    WAIT UNTIL rising_edge(T_SCK);
                END IF;
                FOR I IN 7 DOWNTO 0 LOOP
                    WAIT UNTIL T_SCK'EVENT;
                    WAIT FOR 6.5 ns;
                    IF (VDLR_reg /= "00000000") THEN
                        DLP0_reg(I) := T_SO;
                        DLP1_reg(I) := T_SI;
                        DLP2_reg(I) := T_WPNeg;
                        DLP3_reg(I) := T_HOLDNeg;
                    END IF;
                END LOOP;
                DLP_EN := '1';
                IF (VDLR_reg = "00000000") THEN
                    WAIT UNTIL rising_edge(T_SCK);
                END IF;
            ELSIF Lat_cnt = 3 THEN
                FOR I IN 2 DOWNTO 0 LOOP
                    WAIT UNTIL rising_edge(T_SCK);
                END LOOP;
            END IF;
        END IF;

        --Data Bytes
        CFIaddress := 16#00#;
        byte    := 0;

        IF cmd = rst AND ABE = '1' THEN
            start_del:=to_nat(AutoBoot_reg(8 DOWNTO 1));
            IF start_del > 0 THEN
                FOR I IN start_del-1 DOWNTO 0 LOOP
                    WAIT UNTIL rising_edge(T_SCK);
                END LOOP;
            ELSE
                WAIT UNTIL rising_edge(T_SCK);
            END IF;
        END IF;

        IF (status /= none AND status /= err) OR (cmd = rst AND ABE = '1') THEN
            FOR I IN read_num-1 DOWNTO 0 LOOP
                Data_reg(7 downto 0) := (OTHERS => '0');
                IF cmd = dual_rd OR cmd = dual_rd_4 OR
                   cmd = dual_high_rd OR cmd = dual_high_rd_4 THEN
                    FOR J IN 0 TO 3 LOOP
                        WAIT UNTIL (falling_edge(T_SCK) AND T_HOLDNeg = '1');
                        IF Clock_polarity = '0' THEN
                            IF TimingModel(10)='A' AND TimingModel(11)='G' THEN
                                WAIT FOR 8 ns;
                            ELSIF TimingModel(10)='D' AND
                                  TimingModel(11)='P' THEN
                                WAIT FOR 14.5 ns;
                            END IF;
                        ELSE
                            IF TimingModel(10)='A' AND TimingModel(11)='G' THEN
                                WAIT FOR 8 ns;
                            ELSIF TimingModel(10)='D' AND
                                  TimingModel(11)='P' THEN
                                WAIT FOR 14.5 ns;
                            END IF;
                        END IF;
                        Data_reg(7-2*J) := T_SO;
                        Data_reg(6-2*J) := T_SI;
                    END LOOP;
                ELSIF cmd = quad_rd OR cmd = quad_rd_4 OR
                      cmd = quad_high_rd OR cmd = quad_high_rd_4 OR
                      (cmd = rst AND ABE = '1' AND QUAD = '1' AND
                       start_delay > 0) THEN
                    FOR J IN 0 TO 1 LOOP
                        WAIT UNTIL falling_edge(T_SCK);
                        IF Clock_polarity = '0' THEN
                            IF TimingModel(10)='A' AND
                               TimingModel(11)='G' THEN
                                WAIT FOR 8 ns;
                            ELSIF TimingModel(10)='D' AND
                                TimingModel(11)='P' THEN
                                WAIT FOR 14.5 ns;
                            END IF;
                        ELSE
                            IF TimingModel(10)='A' AND
                               TimingModel(11)='G' THEN
                                WAIT FOR 8 ns;
                            ELSIF TimingModel(10)='D' AND
                                TimingModel(11)='P' THEN
                                WAIT FOR 14.5 ns;
                            END IF;
                        END IF;
                        Data_reg(7-4*J) := T_HOLDNeg;
                        Data_reg(6-4*J) := T_WPNeg;
                        Data_reg(5-4*J) := T_SO;
                        Data_reg(4-4*J) := T_SI;
                    END LOOP;
                ELSIF cmd = rst AND ABE = '1' AND QUAD = '1' AND
                       start_delay = 0 THEN
                    FOR J IN 0 TO 1 LOOP
                        WAIT UNTIL falling_edge(T_SCK);
                        IF TimingModel(10)='D' AND TimingModel(11)='P' THEN
                            WAIT FOR 14.5 ns;
                        ELSE
                            WAIT FOR 10 ns;
                        END IF;
                        Data_reg(7-4*J) := T_HOLDNeg;
                        Data_reg(6-4*J) := T_WPNeg;
                        Data_reg(5-4*J) := T_SO;
                        Data_reg(4-4*J) := T_SI;
                    END LOOP;
                ELSIF cmd = fast_ddr_rd OR cmd = fast_ddr_rd4 THEN
                    FOR J IN 7 DOWNTO 0 LOOP
                        WAIT UNTIL T_SCK'EVENT;
                        WAIT FOR 6.5 ns;
                        Data_reg(J) := T_SO;
                    END LOOP;
                ELSIF cmd = dual_high_ddr_rd OR cmd = dual_high_ddr_rd4 THEN
                    FOR J IN 0 TO 3 LOOP
                        WAIT UNTIL T_SCK'EVENT;
                        WAIT FOR 6.5 ns;
                        Data_reg(7-2*J) := T_SO;
                        Data_reg(6-2*J) := T_SI;
                    END LOOP;
                ELSIF cmd = quad_high_ddr_rd OR cmd = quad_high_ddr_rd_4 THEN
                    FOR J IN 0 TO 1 LOOP
                        WAIT UNTIL T_SCK'EVENT;
                        WAIT FOR 6.5 ns;
                        Data_reg(7-4*J) := T_HOLDNeg;
                        Data_reg(6-4*J) := T_WPNeg;
                        Data_reg(5-4*J) := T_SO;
                        Data_reg(4-4*J) := T_SI;
                    END LOOP;
                ELSIF cmd = autoboot_rd THEN
                    FOR J IN 31 DOWNTO 0 LOOP
                        WAIT UNTIL (falling_edge(T_SCK) AND T_HOLDNeg = '1');
                        IF TimingModel(10)='A' AND
                           TimingModel(11)='G' THEN
                            WAIT FOR 6.5 ns;
                        ELSIF TimingModel(10)='D' AND
                            TimingModel(11)='P' THEN
                            WAIT FOR 14.5 ns;
                        END IF;
                        Data_reg(J) := T_SO;
                    END LOOP;
                ELSIF cmd = asp_reg_rd THEN
                    FOR J IN 15 DOWNTO 0 LOOP
                        WAIT UNTIL (falling_edge(T_SCK) AND T_HOLDNeg = '1');
                        IF TimingModel(10)='A' AND
                           TimingModel(11)='G' THEN
                            WAIT FOR 6.5 ns;
                        ELSIF TimingModel(10)='D' AND
                            TimingModel(11)='P' THEN
                            WAIT FOR 14.5 ns;
                        END IF;
                        Data_reg(J) := T_SO;
                    END LOOP;
                ELSIF cmd = pass_reg_rd THEN
                    FOR J IN 63 DOWNTO 0 LOOP
                        WAIT UNTIL (falling_edge(T_SCK) AND T_HOLDNeg = '1');
                        IF TimingModel(10)='A' AND
                           TimingModel(11)='G' THEN
                            WAIT FOR 6.5 ns;
                        ELSIF TimingModel(10)='D' AND
                            TimingModel(11)='P' THEN
                            WAIT FOR 14.5 ns;
                        END IF;
                        Data_reg(J) := T_SO;
                    END LOOP;
                ELSE
                    FOR J IN 7 DOWNTO 0 LOOP
                        WAIT UNTIL (falling_edge(T_SCK) AND T_HOLDNeg = '1');
                        IF half_period = half_period1_srl THEN
                            IF Clock_polarity = '0' THEN
                                IF TimingModel(10)='A' AND
                                TimingModel(11)='G' THEN
                                    WAIT FOR 6.5 ns;
                                ELSIF TimingModel(10)='D' AND
                                    TimingModel(11)='P' THEN
                                    WAIT FOR 14.5 ns;
                                END IF;
                            ELSE
                                IF TimingModel(10)='A' AND
                                   TimingModel(11)='G' THEN
                                    WAIT FOR 6.5 ns;
                                ELSIF TimingModel(10)='D' AND
                                      TimingModel(11)='P' THEN
                                    WAIT FOR 14.5 ns;
                                END IF;
                            END IF;
                        ELSE
                            IF Clock_polarity= '1' THEN
                                IF TimingModel(10)='A' AND
                                   TimingModel(11)='G' THEN
                                    WAIT FOR 8 ns;
                                ELSIF TimingModel(10)='D' AND
                                      TimingModel(11)='P' THEN
                                    WAIT FOR 14.5 ns;
                                END IF;
                            ELSE
                                IF TimingModel(10)='A' AND
                                   TimingModel(11)='G' THEN
                                    WAIT FOR 8 ns;
                                ELSIF TimingModel(10)='D' AND
                                      TimingModel(11)='P' THEN
                                    WAIT FOR 14.5 ns;
                                END IF;
                            END IF;
                        END IF;
                        Data_reg(J) := T_SO;
                    END LOOP;
                END IF;

                CASE status IS
                    WHEN read | read_4 | read_fast | read_fast_4 | read_dual |
                         read_dual_4 | rd_quad | rd_quad_4 | read_dual_hi |
                         read_dual_hi4| read_quad_hi | read_quad_hi4 |
                         read_ddr_fast | read_ddr_fast4 | read_ddr_dual_hi |
                         read_ddr_dual_hi4 | read_ddr_quad_hi |
                         read_ddr_quad_hi4 | rd_cont_dualIO |
                         rd_cont_dualIO4 | rd_cont_quadIO | rd_cont_quadIO4 |
                         rd_cont_fddr | rd_cont_fddr4 | rd_cont_dddr |
                         rd_cont_dddr4 | rd_cont_qddr | rd_cont_qddr4 =>
                        DLP_ACT := "00";
                        IF (VDLR_reg /= "00000000") AND DLP_EN = '1' THEN
                            IF (status = read_ddr_fast
                            OR status = read_ddr_fast4) THEN
                                DLP_ACT := "01";
                            END IF;
                            IF (status = read_ddr_dual_hi4
                            OR status = read_ddr_dual_hi) THEN
                                DLP_ACT := "10";
                            END IF;
                            IF (status = read_ddr_quad_hi4
                            OR status = read_ddr_quad_hi) THEN
                                DLP_ACT := "11";
                            END IF;
                            DLP_EN := '0';
                        END IF;

                        SecAddr := ReturnSectorID(address);
                        Sec_addr := address-SecAddr*(SecSize+1);
                        IF (PPB_LOCK = '0' AND PWDMLB = '0' AND RPME = '0') THEN
                            IF TBPROT = '0' THEN
                                SecAddr := 0;
                            ELSE
                                SecAddr := SecNum;
                            END IF;
                            address := Sec_addr + SecAddr*(SecSize+1);
                        END IF;

                        --read memory array data and dlp if enabled
                        Check_read (
                            DQ        => Data_reg(7 downto 0),
                            DQ_reg0   => DLP0_reg(7 downto 0),
                            DQ_reg1   => DLP1_reg(7 downto 0),
                            DQ_reg2   => DLP2_reg(7 downto 0),
                            DQ_reg3   => DLP3_reg(7 downto 0),
                            D_mem     => mem(address),
                            DLP_reg   => to_nat(VDLR_reg),
                            D_dlp_act => DLP_ACT,
                            check_err => check_err);

                        -- if the highest address is reached
                        IF address = AddrRange THEN
                            address := 0;
                        ELSE
                            address := address +1;
                        END IF;

                    WHEN rd_HiZ =>
                        --read memory array data
                        Check_Z (
                            DQ        => Data_reg(0),
                            check_err => check_err);

                    WHEN rd_U =>
                        --read memory array data
                        Check_U (
                            DQ        => Data_reg(0),
                            check_err => check_err);

                    WHEN read_otp =>
                        --read otp array data
                        IF address >= OTPLoAddr AND address <= OTPHiAddr THEN
                            Check_otp_read (
                                DQ         => Data_reg(7 downto 0),
                                otp_mem    => Otp(address),
                                check_err  => check_err);

                            address := address +1;
                        END IF;

                    WHEN rd_JID =>

                        IF (byte < 81) THEN
                            -- read ID
                            Check_read_JID (
                                DQ          => Data_reg(7 downto 0),
                                VDATA       => CFI_array(CFIaddress) ,
                                byte_no     => byte,
                                check_err   => check_err);

                            CFIaddress := CFIaddress + 1;
                         ELSE
                            Check_U (
                                DQ        => Data_reg(0),
                                check_err => check_err);
                         END IF;

                         byte := byte + 1;

                    WHEN rd_res  =>
                        -- read Electronic Signature
                        Check_read_ES (
                            DQ          => Data_reg(7 downto 0),
                            check_err   => check_err);

                    WHEN rd_ID =>
                        -- read ID
                        Check_read_ID (
                            DQ          => Data_reg(7 downto 0),
                            ADDR_BIT    => Addr_reg(0),
                            check_err   => check_err);

                        IF Addr_reg(0) = '0' THEN
                            Addr_reg(0) := '1';
                        ELSIF Addr_reg(0) = '1' THEN
                            Addr_reg(0) := '0';
                        END IF;

                    WHEN read_sr1 =>
                        --read status register1
                        Check_read_sr1 (
                            DQ       => Data_reg(7 downto 0),
                            D_mem    => to_nat(Status_reg1),
                            check_err=> check_err);

                    WHEN read_sr2 =>
                        --read status register2
                        Check_read_sr2 (
                            DQ       => Data_reg(7 downto 0),
                            D_mem    => to_nat(Status_reg2),
                            check_err=> check_err);

                    WHEN read_config =>
                        --read configuration register
                        Check_read_config (
                            DQ       => Data_reg(7 downto 0),
                            D_mem    => to_nat(Config_reg1),
                            check_err=> check_err);

                    WHEN read_dlp =>
                        --read dlp register
                        Check_read_dlp (
                            DQ       => Data_reg(7 downto 0),
                            DLP_reg  => to_nat(VDLR_reg),
                            check_err=> check_err);

                    WHEN read_autoboot =>
                        --read autoboot register
                        FOR I IN 0 TO 3 LOOP
                            FOR J IN 0 TO 7 LOOP
                                AutoBoot_reg_rd(I*8+J) :=
                                        AutoBoot_reg((3-I)*8+J);
                            END LOOP;
                        END LOOP;

                        Check_read_autoboot (
                            DQ       => Data_reg(31 downto 0),
                            D_mem    => to_nat(AutoBoot_reg_rd),
                            check_err=> check_err);

                    WHEN read_bank =>
                        --read bank address register
                        Check_read_bank (
                            DQ       => Data_reg(7 downto 0),
                            D_mem    =>
                            to_nat(Bank_Addr_reg(7)&"000000"&Bank_Addr_reg(0)),
                            check_err=> check_err);

                    WHEN read_asp =>
                        --read asp register
                        Check_read_asp (
                            DQ       => Data_reg(15 downto 0),
                            D_mem    => to_nat(ASP_reg),
                            check_err=> check_err);

                    WHEN read_pass_reg =>
                        --read password register
                        Pass_out := Password_reg(7  downto 0) &
                                    Password_reg(15 downto 8) &
                                    Password_reg(23 downto 16) &
                                    Password_reg(31 downto 24) &
                                    Password_reg(39 downto 32) &
                                    Password_reg(47 downto 40) &
                                    Password_reg(55 downto 48) &
                                    Password_reg(63 downto 56);

                        Check_read_pass_reg (
                            DQ       => Data_reg(63 downto 0),
                            D_mem    => to_nat(Pass_out),
                            check_err=> check_err);

                    WHEN rd_ecc =>
                        --read ppb lock register
                        Check_rd_ecc(
                            DQ       => Data_reg(7 downto 0),
                            D_mem    => to_nat(ECCSR),
                            check_err=> check_err);
                            
                    WHEN read_ppbl =>
                        --read ppb lock register
                        Check_read_ppbl (
                            DQ       => Data_reg(7 downto 0),
                            D_mem    => to_nat(PPBL),
                            check_err=> check_err);

                    WHEN read_ppbar =>
                        --read ppb access register
                        Check_read_ppbar (
                            DQ       => Data_reg(7 downto 0),
                            D_mem    => to_nat(PPBAR),
                            check_err=> check_err);

                    WHEN read_dybar =>
                        --read dyb access register
                        Check_read_dybar (
                            DQ       => Data_reg(7 downto 0),
                            D_mem    => to_nat(DYBAR),
                            check_err=> check_err);

                    WHEN rd_ppblock_0 | rd_ppblock_1 =>
                        Check_PPBLOCK_bit (
                            DQ       => PPBL(0),
                            sts      => status,
                            check_err=> check_err);

                    WHEN rd_wip_0 | rd_wip_1 =>
                        Check_WIP_bit (
                            DQ       => Data_reg(0),
                            sts      => status,
                            check_err=> check_err);

                    WHEN rd_wel_0 | rd_wel_1 =>
                        Check_WEL_bit (
                            DQ       =>Status_reg1(1),
                            sts      => status,
                            check_err=> check_err);

                    WHEN erase_succ | erase_nosucc =>
                        Check_eers_bit (
                            DQ       => Data_reg(5),
                            sts      => status,
                            check_err=> check_err);

                    WHEN pgm_succ | pgm_nosucc =>
                        Check_epgm_bit (
                            DQ       => Data_reg(6),
                            sts      => status,
                            check_err=> check_err);

                    WHEN rd_ps_0 | rd_ps_1 =>
                        Check_PS_bit (
                            DQ       => Data_reg(0),
                            sts      => status,
                            check_err=> check_err);

                    WHEN rd_es_0 | rd_es_1 =>
                        Check_ES_bit (
                            DQ       => Data_reg(1),
                            sts      => status,
                            check_err=> check_err);

                    WHEN others =>
                        null;

                END CASE;
            END LOOP;
        END IF;
    END IF;

    WAIT ON T_CSNeg;

END PROCESS checker;

    ---------------------------------------------------------------------------
    ---- CFI Preload Process
    ---------------------------------------------------------------------------
    CFIPreload : PROCESS

    BEGIN
        -----------------------------------------------------------------------
        --CFI array data
        -----------------------------------------------------------------------
        -- Manufacturer and Device ID
        CFI_array(16#00#) := 16#01#;
        CFI_array(16#01#) := 16#02#;
        CFI_array(16#02#) := 16#19#;
        CFI_array(16#03#) := 16#00#;
        IF TimingModel(16) = '0' THEN
            CFI_array(16#04#) := 16#01#;--256B page
        ELSIF TimingModel(16) = '1' THEN
            CFI_array(16#04#) := 16#00#;--512B page
        END IF;
        CFI_array(16#05#) := 16#80#;

        CFI_array(16#06#) := 16#00#;
        CFI_array(16#07#) := 16#00#;
        CFI_array(16#08#) := 16#00#;
        CFI_array(16#09#) := 16#00#;
        CFI_array(16#0A#) := 16#00#;
        CFI_array(16#0B#) := 16#00#;
        CFI_array(16#0C#) := 16#00#;
        CFI_array(16#0D#) := 16#00#;
        CFI_array(16#0E#) := 16#00#;
        CFI_array(16#0F#) := 16#00#;
        --CFI Query Identification String
        CFI_array(16#10#) := 16#51#;
        CFI_array(16#11#) := 16#52#;
        CFI_array(16#12#) := 16#59#;
        CFI_array(16#13#) := 16#02#;
        CFI_array(16#14#) := 16#00#;
        CFI_array(16#15#) := 16#40#;
        CFI_array(16#16#) := 16#00#;
        CFI_array(16#17#) := 16#53#;
        CFI_array(16#18#) := 16#46#;
        CFI_array(16#19#) := 16#51#;
        CFI_array(16#1A#) := 16#00#;
        --CFI system interface string
        CFI_array(16#1B#) := 16#27#;
        CFI_array(16#1C#) := 16#36#;
        CFI_array(16#1D#) := 16#00#;
        CFI_array(16#1E#) := 16#00#;
        CFI_array(16#1F#) := 16#06#;
        IF TimingModel(16) = '0' THEN
            CFI_array(16#20#) := 16#08#;--256B page
            CFI_array(16#21#) := 16#08#;--64KB
        ELSIF TimingModel(16) = '1' THEN
            CFI_array(16#20#) := 16#09#;--512B page
            CFI_array(16#21#) := 16#09#;--256KB
        END IF;

        CFI_array(16#22#) := 16#10#;
        CFI_array(16#23#) := 16#02#;
        CFI_array(16#24#) := 16#02#;
        CFI_array(16#25#) := 16#03#;
        CFI_array(16#26#) := 16#03#;
        --Device Geometry Definition
        CFI_array(16#27#) := 16#19#;
        CFI_array(16#28#) := 16#02#;
        CFI_array(16#29#) := 16#01#;
        IF TimingModel(16) = '0' THEN
            CFI_array(16#2A#) := 16#08#;--256B page
        ELSIF TimingModel(16) = '1' THEN
            CFI_array(16#2A#) := 16#09#;--512B page
        END IF;
        CFI_array(16#2B#) := 16#00#;
        IF TimingModel(16) = '1' THEN
            CFI_array(16#2C#) := 16#01#; --Uniform Device
            CFI_array(16#2D#) := 16#7F#;
            CFI_array(16#2E#) := 16#00#;
            CFI_array(16#2F#) := 16#00#;
            CFI_array(16#30#) := 16#04#;
            CFI_array(16#31#) := 16#FF#;
            CFI_array(16#32#) := 16#FF#;
            CFI_array(16#33#) := 16#FF#;
            CFI_array(16#34#) := 16#FF#;
        ELSE
            CFI_array(16#2C#) := 16#02#; --Boot device
            IF TBPARM = '1' THEN
                CFI_array(16#2D#) := 16#FD#;
                CFI_array(16#2E#) := 16#00#;
                CFI_array(16#2F#) := 16#00#;
                CFI_array(16#30#) := 16#01#;
                CFI_array(16#31#) := 16#1F#;
                CFI_array(16#32#) := 16#01#;
                CFI_array(16#33#) := 16#10#;
                CFI_array(16#34#) := 16#00#;
            ELSE
                CFI_array(16#2D#) := 16#1F#;
                CFI_array(16#2E#) := 16#00#;
                CFI_array(16#2F#) := 16#10#;
                CFI_array(16#30#) := 16#00#;
                CFI_array(16#31#) := 16#FD#;
                CFI_array(16#32#) := 16#01#;
                CFI_array(16#33#) := 16#00#;
                CFI_array(16#34#) := 16#01#;
            END IF;
        END IF;
        CFI_array(16#35#) := 16#FF#;
        CFI_array(16#36#) := 16#FF#;
        CFI_array(16#37#) := 16#FF#;
        CFI_array(16#38#) := 16#FF#;
        CFI_array(16#39#) := 16#FF#;
        CFI_array(16#3A#) := 16#FF#;
        CFI_array(16#3B#) := 16#FF#;
        CFI_array(16#3C#) := 16#FF#;
        CFI_array(16#3D#) := 16#FF#;
        CFI_array(16#3E#) := 16#FF#;
        CFI_array(16#3F#) := 16#FF#;
        --CFI Primary Vendor-Specific Extended Query
        CFI_array(16#40#) := 16#50#;
        CFI_array(16#41#) := 16#52#;
        CFI_array(16#42#) := 16#49#;
        CFI_array(16#43#) := 16#31#;
        CFI_array(16#44#) := 16#33#;
        CFI_array(16#45#) := 16#21#;
        CFI_array(16#46#) := 16#02#;
        CFI_array(16#47#) := 16#01#;
        CFI_array(16#48#) := 16#00#;
        CFI_array(16#49#) := 16#08#;
        CFI_array(16#4A#) := 16#00#;
        CFI_array(16#4B#) := 16#01#;
        CFI_array(16#4C#) := 16#00#;
        CFI_array(16#4D#) := 16#00#;
        CFI_array(16#4E#) := 16#00#;
        CFI_array(16#4F#) := 16#07#;
        CFI_array(16#50#) := 16#01#;

        WAIT;
    END PROCESS CFIPreload;

    ---------------------------------------------------------------------------
    ---- File Read Section - Preload Control
    ---------------------------------------------------------------------------

    default:    PROCESS

    -- text file input variables
        FILE mem_f            : text  is  mem_file;
        FILE otp_f            : text  is  otp_file;
        VARIABLE ind          : NATURAL RANGE 0 TO AddrRANGE := 0;
        VARIABLE otp_ind      : NATURAL RANGE 16#000# TO 16#3FF# := 16#000#;
        VARIABLE buf          : line;

BEGIN
    --Preload Control
    ---------------------------------------------------------------------------
    -- File Read Section
    ---------------------------------------------------------------------------
         -- memory preload
        IF (mem_file(1 to 4) /= "none" AND UserPreload) THEN
            ind := 0;
            Mem := (OTHERS => MaxData);
            WHILE (not ENDFILE (mem_f)) LOOP
                READLINE (mem_f, buf);
                IF buf(1) = '/' THEN
                    NEXT;
                ELSIF buf(1) = '@' THEN
                    IF ind > AddrRANGE THEN
                        ASSERT false
                            REPORT "Given preload address is out of" &
                                   "memory address range"
                            SEVERITY warning;
                    ELSE
                        ind := h(buf(2 to 8)); --address
                    END IF;
                ELSE
                    Mem(ind) := h(buf(1 to 2));
                    IF ind < AddrRANGE THEN
                        ind := ind + 1;
                    END IF;
                END IF;
            END LOOP;
        END IF;

         -- memory preload
        IF (otp_file(1 to 4) /= "none" AND UserPreload) THEN
            otp_ind := 16#000#;
            Otp := (OTHERS => MaxData);
            WHILE (not ENDFILE (otp_f)) LOOP
                READLINE (otp_f, buf);
                IF buf(1) = '/' THEN
                    NEXT;
                ELSIF buf(1) = '@' THEN
                    IF otp_ind > 16#3FF# OR otp_ind < 16#000# THEN
                        ASSERT false
                            REPORT "Given preload address is out of" &
                                   "OTP address range"
                            SEVERITY warning;
                    ELSE
                        otp_ind := h(buf(2 to 4)); --address
                    END IF;
                ELSE
                    Otp(otp_ind) := h(buf(1 to 2));
                    otp_ind := otp_ind + 1;
                END IF;
            END LOOP;
        END IF;

        LOCK_BYTE1 := to_slv(Otp(16#10#),8);
        LOCK_BYTE2 := to_slv(Otp(16#11#),8);
        LOCK_BYTE3 := to_slv(Otp(16#12#),8);
        LOCK_BYTE4 := to_slv(Otp(16#13#),8);

    WAIT;

END PROCESS default;

END vhdl_behavioral;