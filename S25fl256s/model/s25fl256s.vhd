-------------------------------------------------------------------------------
--  File Name: s25fl256s.vhd
-------------------------------------------------------------------------------
--  Copyright (C) 2012 Spansion, LLC.
--
--  MODIFICATION HISTORY:
--
--  version: |  author:  | mod date: |  changes made:
--    V1.0     V.Mancev    09 Nov 26   Inital Release
--    V1.1     V.Mancev    10 Mar 04   addr_cnt for second read in
--                                     high performance read continuous
--                                     mode can change its value only
--                                     when CSNeg = '0'
--    V1.2     V.Mancev   10 July 28   During the QUAD mode HOLD# input
--                                     is not monitored for its normal
--                                     function
--    V1.3      V.Mancev  10 Oct 15    Latest datasheet aligned
--    V1.4      V.Mancev  10 Oct 21    Hybrid configuration added
--    V1.5      V.Mancev  10 Nov 12    QUAD Program operation during Erase
--                                     Suspend is added
--                                     Warning for Resume to Suspend time
--                                     is added
--                                     During Erase Suspend, after Program
--                                     operation is completed, WEL bit is
--                                     cleared
--                                     Implemetation of Software Reset is
--                                     Changed
--   V1.6       V. Mancev 11 July 04   Latest datasheet aligned
--   V1.7       V. Mancev 11 Nov 18    Time tHO is changed to 1 ns
--                                     (customer's request)
--                                     BRWR instruction is corrected
--   V1.8       S.Petrovic 12 Aug 28   QPP Instruction is allowed on
--                                     previously programmed page
--   V1.9       V. Mancev  13 Feb 13   Reverted restriction for QPP
--                                     on programmed page and
--                                     added clearing with sector erase
--   V1.10      S.Petrovic 13 Nov 25   In process Threset time thold_CSNeg_RSTNeg
--                                     replaced by CONSTANT value
--   V1.11      S.Petrovic 13 Nov 28   Corrected FSM state transitions initiated
--                                     by Power-Up and HW Reset in StateGen
--                                     process
--   V1.12      S.Petrovic 13 Dec 20   Corrected DLP read
--   V1.13      M.Stojanovic 15 May 15 Ignored upper address bits for RD4
--   V1.14      M.Stojanovic 15 May 29 Ignored upper address bits for all
--                                     commands in QUAD mode
--   V1.15      M.Stojanovic 16 May 11 During QPP and QPP4 commands
--                                     the same page must not be
--                                     programmed more than once. However
--                                     do not generate P_ERR if this
--                                     occurs.
--   V1.16      M.Krneta     19 May 07 Updated according to the rev *P
--                                     (QPP and QPP4 commands changed,
--                                     ECCRD command added,
--                                     LOCK bit removed)
--
-------------------------------------------------------------------------------
--  PART DESCRIPTION:
--
--  Library:    FLASH
--  Technology: FLASH MEMORY
--  Part:       S25FL256S
--
--   Description: 256 Megabit Serial Flash Memory
--
-------------------------------------------------------------------------------
--  Comments :
--      For correct simulation, simulator resolution should be set to 1 ps
--      A device ordering (trim) option determines whether a feature is enabled
--      or not, or provide relevant parameters:
--        -15th character in TimingModel determines if enhanced high
--         performance option is available
--            (0,2,3,R,A,B,C,D) EHPLC
--            (Y,Z,S,T,K,L)     Security EHPLC
--            (4,6,7,8,9,Q)     HPLC
--        -15th character in TimingModel determines if RESET# input
--        is available
--            (R,A,B,C,D,Q.6,7,K,L,S,T,M,N,U,V)  RESET# is available
--            (0,2,3,4,8,9,Y.Z.W,X)              RESET# is tied to the inactive
--                                               state,inside the package.
--        -16th character in TimingModel determines Sector and Page Size:
--            (0) Sector Size = 64 kB;  Page Size = 256 bytes
--                Hybrid Top/Bottom sector size architecture
--            (1) Sector Size = 256 kB; Page Size = 512 bytes
--                Uniform sector size architecture
--
-------------------------------------------------------------------------------
--  Known Bugs:
--
-------------------------------------------------------------------------------
LIBRARY IEEE;   USE IEEE.std_logic_1164.ALL;
                USE STD.textio.ALL;
                USE IEEE.VITAL_timing.ALL;
                USE IEEE.VITAL_primitives.ALL;

LIBRARY FMF;    USE FMF.gen_utils.ALL;
                USE FMF.conversions.ALL;
-------------------------------------------------------------------------------
-- ENTITY DECLARATION
-------------------------------------------------------------------------------
ENTITY s25fl256s IS
    GENERIC (
    ---------------------------------------------------------------------------
    -- TIMING GENERICS:
    ---------------------------------------------------------------------------
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

        -- tpd delays: propagation delays (pin-to-pin delay within a component)
        tpd_SCK_SO_normal       : VitalDelayType01Z := UnitDelay01Z; -- tV, tHO
        tpd_CSNeg_SO            : VitalDelayType01Z := UnitDelay01Z; -- tDIS
        tpd_HOLDNeg_SO          : VitalDelayType01Z := UnitDelay01Z;--
        tpd_RSTNeg_SO           : VitalDelayType01Z := UnitDelay01Z;--
            -- DDR operation values
        tpd_SCK_SO_DDR          : VitalDelayType01Z := UnitDelay01Z;--tV(66MHz)

        -- tsetup values: setup times
        --   setup time is minimum time before the referent signal edge the
        --   input should be stable
        tsetup_CSNeg_SCK_normal_noedge_posedge
                                : VitalDelayType    := UnitDelay; -- tCSS /
        tsetup_CSNeg_SCK_DDR_noedge_posedge
                                : VitalDelayType    := UnitDelay; -- tCSS /
        tsetup_SI_SCK_normal_noedge_posedge: VitalDelayType
                                                    := UnitDelay; -- tSU:DAT /
        tsetup_WPNeg_CSNeg      : VitalDelayType    := UnitDelay; -- tWPS \
        tsetup_HOLDNeg_SCK      : VitalDelayType    := UnitDelay;
        tsetup_RSTNeg_CSNeg     : VitalDelayType    := UnitDelay; -- tRP
            -- DDR operation values
        tsetup_SI_SCK_DDR_noedge_posedge:   VitalDelayType
                                                    := UnitDelay;   -- tSU /
        tsetup_SI_SCK_DDR_noedge_negedge:   VitalDelayType
                                                    := UnitDelay;   -- tSU \
        tsetup_SI_SCK_DDR80_noedge_posedge: VitalDelayType
                                                    := UnitDelay;   -- tSU /
        tsetup_SI_SCK_DDR80_noedge_negedge: VitalDelayType
                                                    := UnitDelay;   -- tSU \

        -- thold values: hold times
        --   hold time is minimum time the input should be present stable
        --   after the referent signal edge
        thold_CSNeg_SCK_normal_noedge_posedge
                                : VitalDelayType    := UnitDelay; -- tCSH /
        thold_CSNeg_SCK_DDR_noedge_posedge
                                : VitalDelayType    := UnitDelay; -- tCSH /
        thold_SI_SCK_normal_noedge_posedge: VitalDelayType
                                                    := UnitDelay; -- tHD:DAT /
        thold_WPNeg_CSNeg       : VitalDelayType    := UnitDelay; -- tWPH /
        thold_HOLDNeg_SCK       : VitalDelayType    := UnitDelay; --
        thold_CSNeg_RSTNeg      : VitalDelayType    := UnitDelay; -- tRPH
            -- DDR operation values
        thold_SI_SCK_DDR_noedge_posedge:   VitalDelayType
                                                    := UnitDelay;  -- tHD /
        thold_SI_SCK_DDR_noedge_negedge:   VitalDelayType
                                                    := UnitDelay;  -- tHD \
        thold_SI_SCK_DDR80_noedge_posedge: VitalDelayType
                                                    := UnitDelay;  -- tHD /
        thold_SI_SCK_DDR80_noedge_negedge: VitalDelayType
                                                    := UnitDelay;  -- tHD \

        --tpw values: pulse width
        tpw_SCK_serial_posedge  : VitalDelayType := UnitDelay; -- tWH
        tpw_SCK_dual_posedge    : VitalDelayType := UnitDelay; -- tWH
        tpw_SCK_fast_posedge    : VitalDelayType := UnitDelay; -- tWH
        tpw_SCK_quadpg_posedge  : VitalDelayType := UnitDelay; -- tWH
        tpw_SCK_serial_negedge  : VitalDelayType := UnitDelay; -- tWL
        tpw_SCK_dual_negedge    : VitalDelayType := UnitDelay; -- tWL
        tpw_SCK_fast_negedge    : VitalDelayType := UnitDelay; -- tWL
        tpw_SCK_quadpg_negedge  : VitalDelayType := UnitDelay; -- tWL
        tpw_CSNeg_read_posedge  : VitalDelayType := UnitDelay; -- tCS
        tpw_CSNeg_pgers_posedge : VitalDelayType := UnitDelay; -- tCS
        tpw_RSTNeg_negedge      : VitalDelayType := UnitDelay; -- tRP
        tpw_RSTNeg_posedge      : VitalDelayType := UnitDelay; -- tRS
            -- DDR operation values
        tpw_SCK_DDR_posedge     : VitalDelayType := UnitDelay; -- tWH(66MHz)
        tpw_SCK_DDR_negedge     : VitalDelayType := UnitDelay; -- tWL(66Hz)
        tpw_SCK_DDR80_posedge   : VitalDelayType := UnitDelay; -- tWH(80MHz)
        tpw_SCK_DDR80_negedge   : VitalDelayType := UnitDelay; -- tWL(80Hz)

        -- tperiod min (calculated as 1/max freq)
        tperiod_SCK_serial_rd   : VitalDelayType := UnitDelay; --fSCK=50MHz
        tperiod_SCK_fast_rd     : VitalDelayType := UnitDelay; --fSCK=133MHz
        tperiod_SCK_dual_rd     : VitalDelayType := UnitDelay; --fSCK=104MHz
        tperiod_SCK_quadpg      : VitalDelayType := UnitDelay; --fSCK=80MHz
            -- DDR operation values
        tperiod_SCK_DDR_rd      : VitalDelayType := UnitDelay; --fSCK=66MHz
        tperiod_SCK_DDR80_rd    : VitalDelayType := UnitDelay; --fSCK=80MHz

        -- tdevice values: values for internal delays
            --timing values that are internal to the model and not associated
            --with any port.
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
        tdevice_PRGSUSP         : VitalDelayType := 40 us;   --
            -- VCC (min) to CS# Low
        tdevice_PU              : VitalDelayType := 300 us;  --tPU
          -- PPB Erase Time
        tdevice_PPBERASE         :VitalDelayType := 15 ms;  --
          -- Password Unlock Time
        tdevice_PASSULCK         :VitalDelayType := 1 us;   --
        -- Password Unlock Time
        tdevice_PASSACC          :VitalDelayType := 100 us;
        -- Data In Setup Max time
        tdevice_TSU              :VitalDelayType := 300 ns;

    ---------------------------------------------------------------------------
    -- CONTROL GENERICS:
    ---------------------------------------------------------------------------
        -- generic control parameters
        InstancePath      : STRING    := DefaultInstancePath;
        TimingChecksOn    : BOOLEAN   := DefaultTimingChecks;
        MsgOn             : BOOLEAN   := DefaultMsgOn;
        XOn               : BOOLEAN   := DefaultXon;
        -- memory file to be loaded
        mem_file_name     : STRING    := "s25fl256s.mem";
        otp_file_name     : STRING    := "s25fl256sOTP.mem";

        UserPreload       : BOOLEAN   := FALSE; --TRUE;
        LongTimming       : BOOLEAN   := TRUE;

        -- For FMF SDF technology file usage
        TimingModel       : STRING
    );
    PORT (
        -- Data Inputs/Outputs
        SI                : INOUT std_ulogic := 'U'; -- serial data input/IO0
        SO                : INOUT std_ulogic := 'U'; -- serial data output/IO1
        -- Controls
        SCK               : IN    std_ulogic := 'U'; -- serial clock input
        CSNeg             : IN    std_ulogic := 'U'; -- chip select input
        RSTNeg            : IN    std_ulogic := 'U'; -- hardware reset pin
        WPNeg             : INOUT std_ulogic := 'U'; -- write protect input/IO2
        HOLDNeg           : INOUT std_ulogic := 'U'  -- hold input/IO3

    );

    ATTRIBUTE VITAL_LEVEL0 of s25fl256s : ENTITY IS TRUE;
END s25fl256s;

-------------------------------------------------------------------------------
-- ARCHITECTURE DECLARATION
-------------------------------------------------------------------------------
ARCHITECTURE vhdl_behavioral of s25fl256s IS
    ATTRIBUTE VITAL_LEVEL0 OF vhdl_behavioral : ARCHITECTURE IS TRUE;

    ---------------------------------------------------------------------------
    -- CONSTANT AND SIGNAL DECLARATION
    ---------------------------------------------------------------------------
    --Declaration of constants - memory characteristics
        -- The constant declared here are used to enable the creation of models
        -- of memories within a family with a minimum amount of editing

    CONSTANT PartID        : STRING  := "s25fl256s";
    CONSTANT MaxData       : NATURAL := 16#FF#;        --255;
    CONSTANT MemSize       : NATURAL := 16#1FFFFFF#;   --256Mbyte
    CONSTANT SecSize256    : NATURAL := 16#3FFFF#;     --256KB
    CONSTANT SecSize64     : NATURAL := 16#FFFF#;      --64KB
    CONSTANT SecSize4      : NATURAL := 16#FFF#;       --4KB
    CONSTANT SecNum64      : NATURAL := 541;
    CONSTANT SecNum256     : NATURAL := 127;
    CONSTANT PageNum64     : NATURAL := 16#3FFFF#;
    CONSTANT PageNum256    : NATURAL := 16#FFFF#;
    CONSTANT AddrRANGE     : NATURAL := 16#1FFFFFF#;
    CONSTANT HiAddrBit     : NATURAL := 31;
    CONSTANT OTPSize       : NATURAL := 1023;
    CONSTANT OTPLoAddr     : NATURAL := 16#000#;
    CONSTANT OTPHiAddr     : NATURAL := 16#3FF#;
    CONSTANT BYTE          : NATURAL := 8;

    --Manufacturer Identification
    CONSTANT Manuf_ID      : NATURAL := 16#01#;
    CONSTANT DeviceID      : NATURAL := 16#18#;
    --Electronic Signature
    CONSTANT ESignature    : NATURAL := 16#18#;
    --Device ID
    --Manufacturer Identification && Memory Type && Memory Capacity
    CONSTANT Jedec_ID      : NATURAL := 16#01#; -- first byte of Device ID
    CONSTANT DeviceID1     : NATURAL := 16#02#;
    CONSTANT DeviceID2     : NATURAL := 16#19#;
    CONSTANT ExtendedBytes : NATURAL := 16#4D#;
    CONSTANT ExtendedID64  : NATURAL := 16#01#;
    CONSTANT ExtendedID256 : NATURAL := 16#00#;
    CONSTANT DieRev        : NATURAL := 16#00#;
    CONSTANT MaskRev       : NATURAL := 16#00#;
    CONSTANT HOLD_CSNeg_RSTNeg : TIME := 34800 ns;

    -- Declaration of signals that will hold the delayed values of ports
    SIGNAL SI_ipd          : std_ulogic := 'U';
    SIGNAL SO_ipd          : std_ulogic := 'U';
    SIGNAL SCK_ipd         : std_ulogic := 'U';
    SIGNAL CSNeg_ipd       : std_ulogic := 'U';
    SIGNAL RSTNeg_ipd      : std_ulogic := 'U';
    SIGNAL WPNeg_ipd       : std_ulogic := 'U';
    SIGNAL HOLDNeg_ipd     : std_ulogic := 'U';
    SIGNAL HOLDNeg_pullup  : std_ulogic := 'U';
    SIGNAL WPNeg_pullup    : std_ulogic := 'U';
    SIGNAL RSTNeg_pullup   : std_ulogic := 'U';

    -- internal delays
    SIGNAL PP256_in        : std_ulogic := '0';
    SIGNAL PP256_out       : std_ulogic := '0';
    SIGNAL PP512_in        : std_ulogic := '0';
    SIGNAL PP512_out       : std_ulogic := '0';
    SIGNAL BP_in           : std_ulogic := '0';
    SIGNAL BP_out          : std_ulogic := '0';
    SIGNAL SE64_in         : std_ulogic := '0';
    SIGNAL SE64_out        : std_ulogic := '0';
    SIGNAL SE256_in        : std_ulogic := '0';
    SIGNAL SE256_out       : std_ulogic := '0';
    SIGNAL BE_in           : std_ulogic := '0';
    SIGNAL BE_out          : std_ulogic := '0';
    SIGNAL WRR_in          : std_ulogic := '0';
    SIGNAL WRR_out         : std_ulogic := '0';
    SIGNAL ERSSUSP_in      : std_ulogic := '0';
    SIGNAL ERSSUSP_out     : std_ulogic := '0';
    SIGNAL PRGSUSP_in      : std_ulogic := '0';
    SIGNAL PRGSUSP_out     : std_ulogic := '0';
    SIGNAL PU_in           : std_ulogic := '0';
    SIGNAL PU_out          : std_ulogic := '0';
    SIGNAL RST_in          : std_ulogic := '0';-- Hardware Reset Timeout
    SIGNAL RST_out         : std_ulogic := '1';--
    SIGNAL PPBERASE_in     : std_ulogic := '0';
    SIGNAL PPBERASE_out    : std_ulogic := '0';
    SIGNAL PASSULCK_in     : std_ulogic := '0';
    SIGNAL PASSULCK_out    : std_ulogic := '0';
    SIGNAL PASSACC_in      : std_ulogic := '0';
    SIGNAL PASSACC_out     : std_ulogic := '0';

    FUNCTION ReturnSectorIDRdPswdMd(TBPROT : std_logic) RETURN NATURAL IS
            VARIABLE result : NATURAL;
        BEGIN
            IF TBPROT = '0' THEN
                result := 0;
            ELSE
                IF (TimingModel(16) = '1') THEN
                    result := SecNum256;
                ELSE
                    result := 511;
                END IF;
            END IF;
            RETURN result;
        END ReturnSectorIDRdPswdMd;

BEGIN

    ---------------------------------------------------------------------------
    -- Internal Delays
    ---------------------------------------------------------------------------
    -- Artificial VITAL primitives to incorporate internal delays
    -- Because a tdevice generics is used, there must be a VITAL_primitives
    -- assotiated with them
    PP256     :VitalBuf(PP256_out,   PP256_in,   (tdevice_PP256   ,UnitDelay));
    PP512     :VitalBuf(PP512_out,   PP512_in,   (tdevice_PP512   ,UnitDelay));
    BP        :VitalBuf(BP_out,      BP_in,      (tdevice_BP      ,UnitDelay));
    SE64      :VitalBuf(SE64_out,    SE64_in,    (tdevice_SE64    ,UnitDelay));
    SE256     :VitalBuf(SE256_out,   SE256_in,   (tdevice_SE256   ,UnitDelay));
    BE        :VitalBuf(BE_out,      BE_in,      (tdevice_BE      ,UnitDelay));
    WRR       :VitalBuf(WRR_out,     WRR_in,     (tdevice_WRR     ,UnitDelay));
    ERSSUSP   :VitalBuf(ERSSUSP_out, ERSSUSP_in, (tdevice_ERSSUSP ,UnitDelay));
    PRGSUSP   :VitalBuf(PRGSUSP_out, PRGSUSP_in, (tdevice_PRGSUSP ,UnitDelay));
    PU        :VitalBuf(PU_out,      PU_in,      (tdevice_PU      ,UnitDelay));
    PPBERASE  :VitalBuf(PPBERASE_out,PPBERASE_in,(tdevice_PPBERASE,UnitDelay));
    PASSULCK  :VitalBuf(PASSULCK_out,PASSULCK_in,(tdevice_PASSULCK,UnitDelay));
    PASSACC   :VitalBuf(PASSACC_out, PASSACC_in, (tdevice_PASSACC ,UnitDelay));

    ---------------------------------------------------------------------------
    -- Wire Delays
    ---------------------------------------------------------------------------
    WireDelay : BLOCK
    BEGIN

        w_1 : VitalWireDelay (SI_ipd,      SI,      tipd_SI);
        w_2 : VitalWireDelay (SO_ipd,      SO,      tipd_SO);
        w_3 : VitalWireDelay (SCK_ipd,     SCK,     tipd_SCK);
        w_4 : VitalWireDelay (CSNeg_ipd,   CSNeg,   tipd_CSNeg);
        w_5 : VitalWireDelay (RSTNeg_ipd,  RSTNeg,  tipd_RSTNeg);
        w_6 : VitalWireDelay (WPNeg_ipd,   WPNeg,   tipd_WPNeg);
        w_7 : VitalWireDelay (HOLDNeg_ipd, HOLDNeg, tipd_HOLDNeg);

    END BLOCK;

    ---------------------------------------------------------------------------
    -- Main Behavior Block
    ---------------------------------------------------------------------------
    Behavior: BLOCK

        PORT (
            SIIn           : IN    std_ulogic := 'U';
            SIOut          : OUT   std_ulogic := 'U';
            SOIn           : IN    std_logic  := 'U';
            SOut           : OUT   std_logic  := 'U';
            SCK            : IN    std_ulogic := 'U';
            CSNeg          : IN    std_ulogic := 'U';
            RSTNeg         : IN    std_ulogic := 'U';
            HOLDNegIn      : IN    std_ulogic := 'U';
            HOLDNegOut     : OUT   std_ulogic := 'U';
            WPNegIn        : IN    std_ulogic := 'U';
            WPNegOut       : OUT   std_ulogic := 'U'
        );

        PORT MAP (
             SIIn       => SI_ipd,
             SIOut      => SI,
             SOIn       => SO_ipd,
             SOut       => SO,
             SCK        => SCK_ipd,
             CSNeg      => CSNeg_ipd,
             RSTNeg     => RSTNeg_ipd,
             HOLDNegIn  => HOLDNeg_ipd,
             HOLDNegOut => HOLDNeg,
             WPNegIn    => WPNeg_ipd,
             WPNegOut   => WPNeg
        );

        -- State Machine : State_Type
        TYPE state_type IS (IDLE,
                            RESET_STATE,
                            AUTOBOOT,
                            WRITE_SR,
                            PAGE_PG,
                            OTP_PG,
                            PG_SUSP,
                            SECTOR_ERS,
                            BULK_ERS,
                            ERS_SUSP,
                            ERS_SUSP_PG,
                            ERS_SUSP_PG_SUSP,
                            PASS_PG,
                            PASS_UNLOCK,
                            PPB_PG,
                            PPB_ERS,
                            AUTOBOOT_PG,
                            ASP_PG,
                            PLB_PG,
                            DYB_PG,
                            NVDLR_PG
                            );

        -- Instruction Type
        TYPE instruction_type IS ( NONE,
                                   WREN,       -- Write Enable
                                   WRDI,       -- Write Disable
                                   WRR,        -- Write Register
                                   READ,       -- Read Normal (3Byte Address)
                                   RD4,        -- Read Normal (4Byte +)
                                   OTPR,       -- OTP Read
                                   RDSR,       -- Read Status Register 1
                                   RDSR2,      -- Read Status Register 2
                                   RDCR,       -- Read Configuration Register 1
                                   REMS,       -- Read ID (SST)
                                   RDID,       -- Read ID JEDEC
                                   RES,        -- Read ID
                                   FSTRD,      -- Fast Read (3Byte Address)
                                   FSTRD4,     -- Fast Read (4Byte +)
                                   DDRFR,      -- Fast Read DDR (3Byte Address)
                                   DDRFR4,     -- Fast Read DDR (4Byte +)
                                   DOR,        -- Read Dual Out (3Byte Address)
                                   DOR4,       -- Read Dual Out (4Byte +)
                                   DIOR,       -- Read Dual I/O (3Byte Address)
                                   DIOR4,      -- Read Dual I/O (4Byte +)
                                   DDRDIOR,    -- Read DDR Dual I/O (3Byte)
                                   DDRDIOR4,   -- Read DDR Dual I/O (4Byte +)
                                   QOR,        -- Read Quad Out (3Byte Address)
                                   QOR4,       -- Read Quad Out (4Byte +)
                                   QIOR,       -- Read Quad I/O (3Byte Address)
                                   QIOR4,      -- Read Quad I/O (4Byte +)
                                   DDRQIOR,    -- Read DDR Quad I/O (3Byte)
                                   DDRQIOR4,   -- Read DDR Quad I/O (4Byte +)
                                   PP,         -- Program Page (3Byte Address)
                                   PP4,        -- Program Page (4Byte +)
                                   QPP,        -- Quad Page Program (3Byte)
                                   QPP4,       -- Quad Page Program (4Byte +)
                                   OTPP,       -- OTP Program
                                   PGSP,       -- Program Suspend
                                   PGRS,       -- Program Resume
                                   BE,         -- Bulk Erase
                                   SE,         -- Erase 128/256KB (3Byte)
                                   SE4,        -- Erase 128/256KB (4Byte +)
                                   P4E,        -- 4KB-sector Erase (3Byte Addr)
                                   P4E4,       -- 4KB-sector Erase (4Byte Addr)
                                   ERSP,       -- Erase Suspend
                                   ERRS,       -- Erase Resume
                                   ABRD,       -- AutoBoot Register Read
                                   ABWR,       -- AutoBoot Register Write
                                   BRRD,       -- Bank Register Read
                                   BRWR,       -- Bank Register Write
                                   BRAC,       -- Bank Register Access
                                   ECCRD,      -- ECC Register Read
                                   DLPRD,      -- Read Data Learning Pattern
                                   PNVDLR,     -- Program NVDLP Reg
                                   WVDLR,      -- Write Volatile DLP Reg
                                   ASPRD,      -- ASP Read
                                   ASPP,       -- ASP Program
                                   DYBRD,      -- DYB Read
                                   DYBWR,      -- DYB Write
                                   PPBRD,      -- PPB Read
                                   PPBP,       -- PPB Program
                                   PPBERS,     -- PPB Erase
                                   PLBWR,      -- PPB Lock Bit Write
                                   PLBRD,      -- PPB Lock Bit Read
                                   PASSRD,     -- Password Read
                                   PASSP,      -- Password Program
                                   PASSU,      -- Password Unlock
                                   RESET,      -- Reset
                                   MBR,        -- Mode Bit Reset
                                   MPM,        -- Multi-I/O-High Perf Mode
                                   CLSR        -- Clear Status Register
                                );

        TYPE WByteType IS ARRAY (0 TO 511) OF INTEGER RANGE -1 TO MaxData;
        -- Flash Memory Array
        TYPE MemArray IS ARRAY (0 TO AddrRANGE) OF INTEGER RANGE -1 TO MaxData;
        -- OTP Memory Array
        TYPE OTPArray IS ARRAY (OTPLoAddr TO OTPHiAddr) OF INTEGER
                                                    RANGE -1 TO MaxData;
        --CFI Array (Common Flash Interface Query codes)
        TYPE CFItype  IS ARRAY (16#00# TO 16#55#) OF
                                              INTEGER RANGE -1 TO 16#FF#;
        -----------------------------------------------------------------------
        --  memory declaration
        -----------------------------------------------------------------------
        -- Memory
        SHARED VARIABLE Mem          : MemArray  := (OTHERS => MaxData);
        -- OTP Sector
        SHARED VARIABLE OTPMem       : OTPArray  := (OTHERS => MaxData);
        --CFI Array
        SHARED VARIABLE CFI_array    : CFItype   := (OTHERS => 0);
        -- Programming Buffer
        SIGNAL WByte                 : WByteType := (OTHERS => MaxData);

        -- states
        SIGNAL current_state         : state_type := RESET_STATE;
        SIGNAL next_state            : state_type := RESET_STATE;

        SIGNAL Instruct              : instruction_type;
        --zero delay signal
        SIGNAL SOut_zd               : std_logic := 'Z';
        SIGNAL SIOut_zd              : std_logic := 'Z';
        SIGNAL HOLDNegOut_zd         : std_logic := 'Z';
        SIGNAL WPNegOut_zd           : std_logic := 'Z';
        --HOLD delay on output data
        SIGNAL SOut_z                : std_logic := 'Z';
        SIGNAL SIOut_z               : std_logic := 'Z';
        -- powerup
        SIGNAL PoweredUp             : std_logic := '0';

        -----------------------------------------------------------------------
        -- Registers
        -----------------------------------------------------------------------
        --     ***  Status Register 1  ***
        SHARED VARIABLE Status_reg1   : std_logic_vector(7 downto 0)
                                                := (others => '0');
        SIGNAL Status_reg1_in         : std_logic_vector(7 downto 0)
                                                := (others => '0');

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
        SIGNAL Status_reg2_in         : std_logic_vector(7 downto 0)
                                                := (others => '0');

        -- Status Register Write Enable Latch Bit
        ALIAS ES        :std_logic IS Status_reg2(1);
        -- Status Register Write In Progress Bit
        ALIAS PS        :std_logic IS Status_reg2(0);

        --      ***  Configuration Register 1  ***
        SHARED VARIABLE Config_reg1   : std_logic_vector(7 downto 0)
                                                := (others => '0');
        SIGNAL Config_reg1_in         : std_logic_vector(7 downto 0)
                                                := (others => '0');

        -- Latency code
        ALIAS LC1       :std_logic IS Config_reg1(7);
        ALIAS LC0       :std_logic IS Config_reg1(6);
        -- Configuration Register TBPROT bit
        ALIAS TBPROT    :std_logic IS Config_reg1(5);
--        -- Configuration Register LOCK bit
--        ALIAS LOCK      :std_logic IS Config_reg1(4);
        -- Configuration Register BPNV bit
        ALIAS BPNV      :std_logic IS Config_reg1(3);
        -- Configuration Register TBPARM bit
        ALIAS TBPARM    :std_logic IS Config_reg1(2);
        -- Configuration Register QUAD bit
        ALIAS QUAD      :std_logic IS Config_reg1(1);
        -- Configuration Register FREEZE bit
        ALIAS FREEZE    :std_logic IS Config_reg1(0);

        --      ***  VDLR Register  ***
        SHARED VARIABLE VDLR_reg      : std_logic_vector(7 downto 0)
                                                := (others => '0');
        SIGNAL VDLR_reg_in            : std_logic_vector(7 downto 0)
                                                := (others => '0');

        --      ***  NVDLR Register  ***
        SHARED VARIABLE NVDLR_reg     : std_logic_vector(7 downto 0)
                                                := (others => '0');
        SIGNAL NVDLR_reg_in           : std_logic_vector(7 downto 0)
                                                := (others => '0');

        --      ***  AutoBoot Register  ***
        SHARED VARIABLE AutoBoot_reg   : std_logic_vector(31 downto 0)
                                                := (others => '0');
        SIGNAL AutoBoot_reg_in         : std_logic_vector(31 downto 0)
                                                := (others => '0');
        --AutoBoot Enable Bit
        ALIAS ABE       :std_logic IS AutoBoot_reg(0);

        --      ***  Bank Address Register  ***
        SHARED VARIABLE Bank_Addr_reg  : std_logic_vector(7 downto 0)
                                                := (others => '0');
        SIGNAL Bank_Addr_reg_in        : std_logic_vector(7 downto 0)
                                                := (others => '0');
        --Bank Address Register EXTADD bit
        ALIAS EXTADD    :std_logic IS Bank_Addr_reg(7);
        --      ***  ECC Status Register  ***
        SHARED VARIABLE ECCSR     : std_logic_vector(7 downto 0)
                                                := (others => '0');
        ALIAS EECC        :std_logic IS ECCSR(2);
        ALIAS EECCD       :std_logic IS ECCSR(1);
        ALIAS ECCDI       :std_logic IS ECCSR(0);

        --      ***  ASP Register  ***
        SHARED VARIABLE ASP_reg        : std_logic_vector(15 downto 0);
        SIGNAL ASP_reg_in              : std_logic_vector(15 downto 0)
                                                     := (others => '1');
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
        SIGNAL Password_reg_in         : std_logic_vector(63 downto 0)
                                                := (others => '1');
        --      ***  PPB Lock Register  ***
        SHARED VARIABLE PPBL           : std_logic_vector(7 downto 0)
                                                := (others => '0');
        SIGNAL PPBL_in                 : std_logic_vector(7 downto 0)
                                                := (others => '0');
        --Persistent Protection Mode Lock Bit
        ALIAS PPB_LOCK                  : std_logic IS PPBL(0);
        SIGNAL PPB_LOCK_temp            : std_ulogic := '0';

        --      ***  PPB Access Register  ***
        SHARED VARIABLE PPBAR          : std_logic_vector(7 downto 0)
                                                := (others => '1');
        SIGNAL PPBAR_in                : std_logic_vector(7 downto 0)
                                                := (others => '1');
        -- PPB_bits(Sec)
        SHARED VARIABLE PPB_bits       : std_logic_vector(SecNum64 downto 0)
                                                := (OTHERS => '1');
        --      ***  DYB Access Register  ***
        SHARED VARIABLE DYBAR          : std_logic_vector(7 downto 0)
                                                := (others => '1');
        SIGNAL DYBAR_in                : std_logic_vector(7 downto 0)
                                                := (others => '1');
        -- DYB(Sec)
        SHARED VARIABLE DYB_bits       : std_logic_vector(SecNum64 downto 0);

        -- The Lock Protection Registers for OTP Memory space
        SHARED VARIABLE LOCK_BYTE1 :std_logic_vector(7 downto 0);
        SHARED VARIABLE LOCK_BYTE2 :std_logic_vector(7 downto 0);
        SHARED VARIABLE LOCK_BYTE3 :std_logic_vector(7 downto 0);
        SHARED VARIABLE LOCK_BYTE4 :std_logic_vector(7 downto 0);

        --Command Register
        SIGNAL write              : std_logic := '0';
        SIGNAL cfg_write          : std_logic := '0';
        SIGNAL read_out           : std_logic := '0';

        SIGNAL rd                 : boolean   := false;
        SIGNAL dual               : boolean   := false;
        SIGNAL fast_rd            : boolean   := true;
        SIGNAL ddr                : boolean   := false;
        SIGNAL ddr80              : boolean   := false;
        SIGNAL any_read           : boolean   := false;

        SIGNAL quadpg             : boolean   := false;

        SIGNAL oe                 : boolean   := false;
        SIGNAL oe_z               : boolean   := false;

        SHARED VARIABLE hold_mode : boolean := false;

        -- Memory Array Configuration
        SIGNAL BottomBoot        : boolean := false;
        SIGNAL TopBoot           : boolean := false;
        SIGNAL UniformSec        : boolean := false;

        --FSM control signals
        SIGNAL PDONE              : std_logic := '1'; --Page Prog. Done
        SIGNAL PSTART             : std_logic := '0'; --Start Page Programming
        SIGNAL PGSUSP             : std_logic := '0'; --Suspend Program
        SIGNAL PGRES              : std_logic := '0'; --Resume Program

        SIGNAL TSU                : std_logic := '0'; --Resume Program
        
        SIGNAL RES_TO_SUSP_MIN_TIME : std_logic := '0';--Resume to Suspend Flag
        SIGNAL RES_TO_SUSP_TYP_TIME : std_logic := '0';--Resume to Suspend Flag

        SIGNAL WDONE              : std_logic := '1'; --Write operation Done
        SIGNAL WSTART             : std_logic := '0'; --Start Write operation

        SIGNAL ESTART             : std_logic := '0'; --Start Erase operation
        SIGNAL EDONE              : std_logic := '1'; --Erase operation Done
        SIGNAL ESUSP              : std_logic := '0'; --Suspend Erase
        SIGNAL ERES               : std_logic := '0'; --Resume Erase

        --reset timing
        SIGNAL RST                 : std_logic := '0';
        SIGNAL Reseted             : std_logic := '0'; --Reset Timing Control
        --Lock Bit is enabled for customer programming
        SIGNAL WRLOCKENABLE       : BOOLEAN   := TRUE;
        --Flag that mark if ASP Register is allready programmed
        SIGNAL ASPOTPFLAG         : BOOLEAN   := FALSE;
        SIGNAL ASP_INIT           : NATURAL RANGE 0 TO 1;
        SIGNAL INITIAL_CONFIG     : std_logic := '0';

        SHARED VARIABLE PageSize  : NATURAL   :=  0 ;
        SHARED VARIABLE PageNum   : NATURAL   :=  0 ;
        SHARED VARIABLE SecNum    : NATURAL   :=  0 ;
        SHARED VARIABLE SecNumMax : NATURAL   :=  0 ;
        SHARED VARIABLE SecSize   : NATURAL   :=  0 ;
        SHARED VARIABLE b_act     : NATURAL   :=  0 ;

        SHARED VARIABLE ASP_ProtSE : NATURAL   := 0;
        SHARED VARIABLE Sec_ProtSE : NATURAL   := 0;

        SHARED VARIABLE SecAddr   : NATURAL RANGE 0 TO SecNum64:= 0;

        SHARED VARIABLE Sec_addr  : NATURAL   := 0;

        SHARED VARIABLE Page_addr : NATURAL;
        SHARED VARIABLE pgm_page  : NATURAL;

--        SHARED VARIABLE QPP_page       : std_logic_vector(PageNum64 downto 0)
--                                                       := (OTHERS => '0');

        --Flag for Password unlock command
        SIGNAL PASS_UNLOCKED      : boolean   := FALSE;
        SIGNAL PASS_TEMP          : std_logic_vector(63 downto 0)
                                                := (others => '1');

        SHARED VARIABLE DOUBLE    : BOOLEAN := FALSE;
        SHARED VARIABLE EHP       : BOOLEAN := FALSE;

        SHARED VARIABLE read_cnt  : NATURAL := 0;
        SHARED VARIABLE byte_cnt  : NATURAL := 1;
        SHARED VARIABLE read_addr : NATURAL RANGE 0 TO AddrRANGE ;
        SHARED VARIABLE read_addr_tmp : NATURAL RANGE 0 TO AddrRANGE ;

        SHARED VARIABLE start_delay : NATURAL RANGE 0 TO 7;
        SHARED VARIABLE ABSD        : NATURAL RANGE 0 TO 7;
        SIGNAL start_autoboot       : std_logic := '0';

        SIGNAL change_addr        : std_logic := '0';
        SIGNAL Address            : NATURAL RANGE 0 TO AddrRANGE := 0;
        SIGNAL SectorSuspend      : NATURAL RANGE 0 TO SecNum64 := 0;

        -- Sector address
        SIGNAL SA                 : NATURAL RANGE 0 TO SecNum64 := 0;

        -- Sector is protect if Sec_Prot(SecNum) = '1'
        SHARED VARIABLE Sec_Prot  : std_logic_vector(SecNum64 downto 0) :=
                                                   (OTHERS => '0');

        SIGNAL change_TBPARM      : std_logic := '0';

        SIGNAL change_BP          : std_logic := '0';
        SHARED VARIABLE BP_bits   : std_logic_vector(2 downto 0) := "000";

        SHARED VARIABLE CFI_array_tmp    : std_logic_vector(647 downto 0);

        SIGNAL Byte_number        : NATURAL RANGE 0 TO 511    := 0;

        TYPE bus_cycle_type IS (STAND_BY,
                                OPCODE_BYTE,
                                ADDRESS_BYTES,
                                DUMMY_BYTES,
                                MODE_BYTE,
                                DATA_BYTES
                                );
        SHARED VARIABLE bus_cycle_state    : bus_cycle_type;
        -- switch between Data bytes and Dummy bytes
        SHARED VARIABLE DummyBytes_act     : X01 := '0';
        SIGNAL dummy_cnt_act_temp          : NATURAL := 0;
        SIGNAL dummy_cnt_act               : NATURAL := 0;
        --Read Password Protection Mode Active flag
        SIGNAL RdPswdProtMode              : std_ulogic := '0';
        --Read Password Protection Mode Support flag
        SIGNAL RdPswdProtEnable            : std_ulogic := '0';
        SIGNAL BAR_ACC                     : std_ulogic := '0';

        SHARED VARIABLE Latency_code       : NATURAL RANGE 0 TO 7;
        SHARED VARIABLE opcode_cnt         : NATURAL := 0;
        SHARED VARIABLE addr_cnt           : NATURAL := 0;
        SHARED VARIABLE mode_cnt           : NATURAL := 0;
        SHARED VARIABLE dummy_cnt          : NATURAL := 0;
        SHARED VARIABLE data_cnt           : NATURAL := 0;

        SHARED VARIABLE PARAM_REGION       : BOOLEAN := FALSE;

        -- timing check violation
        SIGNAL Viol               : X01 := '0';

        PROCEDURE ADDRHILO_SEC(
            VARIABLE   AddrLOW  : INOUT NATURAL RANGE 0 to ADDRRange;
            VARIABLE   AddrHIGH : INOUT NATURAL RANGE 0 to ADDRRange;
            VARIABLE   Addr     : NATURAL) IS
            VARIABLE   sector   : NATURAL RANGE 0 TO 541;
        BEGIN

            IF (TimingModel(16) = '0') THEN
                IF TBPARM = '0' THEN
                    IF Addr/(SecSize64+1) <= 1 AND
                      (Instruct = P4E OR Instruct = P4E4) THEN  --4KB Sectors
                        sector   := Addr/(SecSize4+1);
                        AddrLOW  := sector*(SecSize4+1);
                        AddrHIGH := sector*(SecSize4+1) + SecSize4;
                    ELSE
                        sector   := Addr/(SecSize64+1);
                        AddrLOW  := sector*(SecSize64+1);
                        AddrHIGH := sector*(SecSize64+1) + SecSize64;
                    END IF;
                ELSE
                    IF Addr/(SecSize64+1) >= 510 AND
                      (Instruct = P4E OR Instruct = P4E4) THEN  --4KB Sectors
                        sector   := 510 + (Addr-(SecSize64+1)*510)/(SecSize4+1);
                        AddrLOW  := 510*(SecSize64+1)+(sector-510)*(SecSize4+1);
                        AddrHIGH := 510*(SecSize64+1) +
                                        (sector-510)*(SecSize4+1) + SecSize4;
                    ELSE
                        sector   := Addr/(SecSize64+1);
                        AddrLOW  := sector*(SecSize64+1);
                        AddrHIGH := sector*(SecSize64+1) + SecSize64;
                    END IF;
                END IF;
            ELSE
                sector   := Addr/(SecSize256+1);
                AddrLOW  := sector*(SecSize256+1);
                AddrHIGH := sector*(SecSize256+1) + SecSize256;
            END IF;
        END ADDRHILO_SEC;

        PROCEDURE ADDRHILO_PG(
            VARIABLE   AddrLOW  : INOUT NATURAL RANGE 0 to AddrRANGE;
            VARIABLE   AddrHIGH : INOUT NATURAL RANGE 0 to AddrRANGE;
            VARIABLE   Addr     : NATURAL) IS
            VARIABLE   page     : NATURAL RANGE 0 TO PageNum;
        BEGIN
            page     := Addr/PageSize;
            AddrLOW  := Page*PageSize;
            AddrHIGH := Page*PageSize + (PageSize-1);
        END AddrHILO_PG;

        PROCEDURE ReturnSectorID(
            VARIABLE result : INOUT NATURAL;
            SIGNAL   ADDR   : NATURAL RANGE 0 TO AddrRANGE) IS
            VARIABLE conv   : NATURAL;
        BEGIN
            IF (TimingModel(16) = '0') THEN
                conv := ADDR / (SecSize64+1);
                IF BottomBoot = TRUE THEN
                    IF conv <= 1 THEN       --4KB Sectors
                        result := ADDR/(SecSize4+1);
                    ELSE
                        result := conv + 30;
                    END IF;
                ELSIF TopBoot = TRUE THEN
                    IF conv >= 510 THEN       --4KB Sectors
                        result := 510 + (Addr-(SecSize64+1)*510)/(SecSize4+1);
                    ELSE
                        result := conv;
                    END IF;
                END IF;
            ELSE
                result   := ADDR/(SecSize256+1);
            END IF;
        END ReturnSectorID;

    BEGIN
    ---------------------------------------------------------------------------
    --Power Up time
    ---------------------------------------------------------------------------

    PoweredUp <= '1' AFTER tdevice_PU;

    ---------------------------------------------------------------------------
    --sector structure
    ---------------------------------------------------------------------------
    UniformSec <= TRUE WHEN (TimingModel(16) = '1')
        ELSE FALSE;
    TimingModelSel: PROCESS
    BEGIN
        IF TimingModel(16) = '1'  THEN
            -- Sector Number/Sector Size
            SecNumMax:= SecNum256;
            SecNum   := SecNum256;
            SecSize  := SecSize256;
            -- 256B/512B Page Size
            PageSize := 512;
            PageNum  := PageNum256;
        ELSE
            -- Sector Number/Sector Size
            SecNumMax:= SecNum64;
            SecNum   := 511;
            SecSize  := SecSize64;
            -- 256B/512B Page Size
            PageSize := 256;
            PageNum  := PageNum64;
        END IF;
        --Enhanced High Performance Flag
        IF (TimingModel(15) = '0' OR TimingModel(15) = '2' OR
            TimingModel(15) = '3' OR TimingModel(15) = 'R' OR
            TimingModel(15) = 'A' OR TimingModel(15) = 'B' OR
            TimingModel(15) = 'C' OR TimingModel(15) = 'D' OR
            TimingModel(15) = 'Y' OR TimingModel(15) = 'Z' OR
            TimingModel(15) = 'S' OR TimingModel(15) = 'T' OR
            TimingModel(15) = 'K' OR TimingModel(15) = 'L') THEN
            EHP := TRUE;
            IF (TimingModel(15) = 'Y' OR TimingModel(15) = 'Z' OR
                TimingModel(15) = 'S' OR TimingModel(15) = 'T' OR
                TimingModel(15) = 'K' OR TimingModel(15) = 'L')   THEN
                RdPswdProtEnable <= '1';
            END IF;
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
        WAIT;
    END PROCESS;

    RSTtiming: PROCESS(RSTNeg_pullup,Instruct)
    BEGIN
        IF falling_edge(RSTNeg_pullup) THEN
            RST <= '1', '0' AFTER 200 ns;
        ELSIF Instruct = RESET THEN
            Reseted <= '0', '1' AFTER 10 ns;
        END IF;
    END PROCESS;

    DUMMYcnt: PROCESS(dummy_cnt_act_temp)
    BEGIN
        dummy_cnt_act <= dummy_cnt_act_temp;
    END PROCESS;

    ReadPasswordProtectionMode: PROCESS(PPB_LOCK_temp,
    ASP_reg_in(2), ASP_reg_in(5))
    BEGIN
        IF (PPB_LOCK = '0' AND PWDMLB = '0' AND RPME = '0' AND
            RdPswdProtEnable = '1') THEN
            RdPswdProtMode <= '1';
            ABE := '0';
        ELSE
            RdPswdProtMode <= '0';
        END IF;
    END PROCESS;
    ---------------------------------------------------------------------------
    -- autoboot control logic
    ---------------------------------------------------------------------------
    AutoBootControl: PROCESS(SCK_ipd, current_state)
    BEGIN
        IF (current_state = AUTOBOOT) THEN
            IF rising_edge(SCK_ipd) THEN
                IF (start_delay > 0) THEN
                    start_delay := start_delay - 1;
                END IF;
            END IF;

            IF (start_delay = 0) THEN
                start_autoboot <= '1';
            ELSE
                start_autoboot <= '0';
            END IF;
        END IF;
    END PROCESS;

    ---------------------------------------------------------------------------
    -- VITAL Timing Checks Procedures
    ---------------------------------------------------------------------------
    VITALTimingCheck: PROCESS(SIIn, SOIn, SCK_ipd, CSNeg_ipd, RSTNeg_ipd,
                              HOLDNegIn, WPNegIn)

        -- Timing Check Variables
        -- Setup/Hold Checks variables
        VARIABLE Tviol_CSNeg_SCK_normal  : X01 := '0';
        VARIABLE TD_CSNeg_SCK_normal     : VitalTimingDataType;

        VARIABLE Tviol_CSNeg_SCK_DDR     : X01 := '0';
        VARIABLE TD_CSNeg_SCK_DDR        : VitalTimingDataType;

        VARIABLE Tviol_CSNeg_RSTNeg      : X01 := '0';
        VARIABLE TD_CSNeg_RSTNeg         : VitalTimingDataType;

        VARIABLE Tviol_SI_SCK            : X01 := '0';
        VARIABLE TD_SI_SCK               : VitalTimingDataType;

        VARIABLE Tviol_WPNeg_CSNeg_setup : X01 := '0';
        VARIABLE TD_WPNeg_CSNeg_setup    : VitalTimingDataType;

        VARIABLE Tviol_WPNeg_CSNeg_hold  : X01 := '0';
        VARIABLE TD_WPNeg_CSNeg_hold     : VitalTimingDataType;

        VARIABLE Tviol_HOLDNeg_SCK       : X01 := '0';
        VARIABLE TD_HOLDNeg_SCK          : VitalTimingDataType;

        VARIABLE Tviol_SI_SCK_DDR_R      : X01 := '0';
        VARIABLE TD_SI_SCK_DDR_R         : VitalTimingDataType;

        VARIABLE Tviol_SI_SCK_DDR_F      : X01 := '0';
        VARIABLE TD_SI_SCK_DDR_F         : VitalTimingDataType;

        VARIABLE Tviol_RSTNeg_CSNeg      : X01 := '0';
        VARIABLE TD_RSTNeg_CSNeg         : VitalTimingDataType;

        --Pulse Width and Period Check Variables
        VARIABLE Pviol_SCK_serial  : X01 := '0';
        VARIABLE PD_SCK_serial     : VitalPeriodDataType:= VitalPeriodDataInit;

        VARIABLE Pviol_SCK_dual    : X01 := '0';
        VARIABLE PD_SCK_dual       : VitalPeriodDataType:= VitalPeriodDataInit;

        VARIABLE Pviol_SCK_DDR80   : X01 := '0';
        VARIABLE PD_SCK_DDR80      : VitalPeriodDataType:= VitalPeriodDataInit;

        VARIABLE Pviol_SCK_fast    : X01 := '0';
        VARIABLE PD_SCK_fast       : VitalPeriodDataType:= VitalPeriodDataInit;

        VARIABLE Pviol_SCK_quadpg  : X01 := '0';
        VARIABLE PD_SCK_quadpg     : VitalPeriodDataType:= VitalPeriodDataInit;

        VARIABLE Pviol_SCK_DDR     : X01 := '0';
        VARIABLE PD_SCK_DDR        : VitalPeriodDataType:= VitalPeriodDataInit;

        VARIABLE Pviol_CSNeg_read  : X01 := '0';
        VARIABLE PD_CSNeg_read     : VitalPeriodDataType:= VitalPeriodDataInit;

        VARIABLE Pviol_CSNeg_pgers : X01 := '0';
        VARIABLE PD_CSNeg_pgers    : VitalPeriodDataType:= VitalPeriodDataInit;

        VARIABLE Pviol_RSTNeg      : X01 := '0';
        VARIABLE PD_RSTNeg         : VitalPeriodDataType:= VitalPeriodDataInit;

        VARIABLE Pviol_SCK_serial_rd : X01 := '0';
        VARIABLE PD_SCK_serial_rd  : VitalPeriodDataType:= VitalPeriodDataInit;

        VARIABLE Pviol_SCK_fast_rd : X01 := '0';
        VARIABLE PD_SCK_fast_rd    : VitalPeriodDataType:=VitalPeriodDataInit;

        VARIABLE Pviol_SCK_dual_rd : X01 := '0';
        VARIABLE PD_SCK_dual_rd    : VitalPeriodDataType:=VitalPeriodDataInit;

        VARIABLE Pviol_SCK_DDR_rd  : X01 := '0';
        VARIABLE PD_SCK_DDR_rd     : VitalPeriodDataType:= VitalPeriodDataInit;

        VARIABLE Pviol_SCK_DDR80_rd  : X01 := '0';
        VARIABLE PD_SCK_DDR80_rd     : VitalPeriodDataType:= VitalPeriodDataInit;

        VARIABLE Pviol_SCK_quad_pg : X01 := '0';
        VARIABLE PD_SCK_quad_pg    : VitalPeriodDataType:= VitalPeriodDataInit;

        VARIABLE Violation         : X01 := '0';

    BEGIN
    ---------------------------------------------------------------------------
    -- Timing Check Section
    ---------------------------------------------------------------------------
        IF (TimingChecksOn) THEN

        -- Setup/Hold Check between CS# and SCK
        VitalSetupHoldCheck (
            TestSignal      => CSNeg_ipd,
            TestSignalName  => "CS#",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupHigh       => tsetup_CSNeg_SCK_normal_noedge_posedge,
            SetupLow        => tsetup_CSNeg_SCK_normal_noedge_posedge,
            HoldHigh        => thold_CSNeg_SCK_normal_noedge_posedge,
            HoldLow         => thold_CSNeg_SCK_normal_noedge_posedge,
            CheckEnabled    => ddr = false,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_CSNeg_SCK_normal,
            Violation       => Tviol_CSNeg_SCK_normal
        );

        -- Setup/Hold Check between CS# and SCK
        VitalSetupHoldCheck (
            TestSignal      => CSNeg_ipd,
            TestSignalName  => "CS#",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupHigh       => tsetup_CSNeg_SCK_DDR_noedge_posedge,
            SetupLow        => tsetup_CSNeg_SCK_DDR_noedge_posedge,
            HoldHigh        => thold_CSNeg_SCK_DDR_noedge_posedge,
            HoldLow         => thold_CSNeg_SCK_DDR_noedge_posedge,
            CheckEnabled    => ddr,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_CSNeg_SCK_DDR,
            Violation       => Tviol_CSNeg_SCK_DDR
        );

        -- Hold Check between CSNeg and RSTNeg
        VitalSetupHoldCheck (
            TestSignal      => CSNeg,
            TestSignalName  => "CSNeg",
            RefSignal       => RSTNeg,
            RefSignalName   => "RSTNeg",
            HoldHigh        => thold_CSNeg_RSTNeg,
            CheckEnabled    => TRUE,
            RefTransition   => '\',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_CSNeg_RSTNeg,
            Violation       => Tviol_CSNeg_RSTNeg
        );

        -- Setup/Hold Check between SI and SCK, serial mode
        VitalSetupHoldCheck (
            TestSignal      => SIIn,
            TestSignalName  => "SI",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupHigh       => tsetup_SI_SCK_normal_noedge_posedge,
            SetupLow        => tsetup_SI_SCK_normal_noedge_posedge,
            HoldHigh        => thold_SI_SCK_normal_noedge_posedge,
            HoldLow         => thold_SI_SCK_normal_noedge_posedge,
            CheckEnabled    => NOT(DOUBLE) AND SIOut_z /= SIIn ,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_SI_SCK,
            Violation       => Tviol_SI_SCK
        );

        -- Setup Check between WP# and CS# \
        VitalSetupHoldCheck (
            TestSignal      => WPNegIn,
            TestSignalName  => "WP#",
            RefSignal       => CSNeg_ipd,
            RefSignalName   => "CS#",
            SetupHigh       => tsetup_WPNeg_CSNeg,
            CheckEnabled    => true,
            RefTransition   => '\',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_WPNeg_CSNeg_setup,
            Violation       => Tviol_WPNeg_CSNeg_setup
        );

        -- Hold Check between WP# and CS# /
        VitalSetupHoldCheck (
            TestSignal      => WPNegIn,
            TestSignalName  => "WP#",
            RefSignal       => CSNeg_ipd,
            RefSignalName   => "CS#",
            HoldHigh        => thold_WPNeg_CSNeg,
            CheckEnabled    => SRWD = '1' AND WEL = '1',
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_WPNeg_CSNeg_hold,
            Violation       => Tviol_WPNeg_CSNeg_hold
        );

        -- Setup/Hold Check between HOLD# and SCK /
        VitalSetupHoldCheck (
            TestSignal      => HOLDNegIn,
            TestSignalName  => "HOLD#",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupLow        => tsetup_HOLDNeg_SCK,
            SetupHigh       => tsetup_HOLDNeg_SCK,
            HoldLow         => thold_HOLDNeg_SCK,
            HoldHigh        => thold_HOLDNeg_SCK,
            CheckEnabled    => QUAD = '0'
                               AND HOLDNegOut_zd /= HOLDNegIn,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_HOLDNeg_SCK,
            Violation       => Tviol_HOLDNeg_SCK
        );

        -- Setup/Hold Check between SI and SCK, DDR mode
        VitalSetupHoldCheck (
            TestSignal      => SIIn,
            TestSignalName  => "SI",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupHigh       => tsetup_SI_SCK_DDR_noedge_posedge,
            SetupLow        => tsetup_SI_SCK_DDR_noedge_posedge,
            HoldHigh        => thold_SI_SCK_DDR_noedge_posedge,
            HoldLow         => thold_SI_SCK_DDR_noedge_posedge,
            CheckEnabled    => DOUBLE AND dual = false AND
                               ddr80 = false AND SIOut_z /= SIIn,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_SI_SCK_DDR_R,
            Violation       => Tviol_SI_SCK_DDR_R
        );

        -- Setup/Hold Check between SI and SCK, DDR mode
        VitalSetupHoldCheck (
            TestSignal      => SIIn,
            TestSignalName  => "SI",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupHigh       => tsetup_SI_SCK_DDR80_noedge_posedge,
            SetupLow        => tsetup_SI_SCK_DDR80_noedge_posedge,
            HoldHigh        => thold_SI_SCK_DDR80_noedge_posedge,
            HoldLow         => thold_SI_SCK_DDR80_noedge_posedge,
            CheckEnabled    => DOUBLE AND dual = false AND
                               ddr80 = true AND SIOut_z /= SIIn,
            RefTransition   => '/',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_SI_SCK_DDR_R,
            Violation       => Tviol_SI_SCK_DDR_R
        );

        -- Setup/Hold Check between SI and SCK, DDR mode
        VitalSetupHoldCheck (
            TestSignal      => SIIn,
            TestSignalName  => "SI",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupHigh       => tsetup_SI_SCK_DDR_noedge_negedge,
            SetupLow        => tsetup_SI_SCK_DDR_noedge_negedge,
            HoldHigh        => thold_SI_SCK_DDR_noedge_negedge,
            HoldLow         => thold_SI_SCK_DDR_noedge_negedge,
            CheckEnabled    => ddr AND dual = false
                               AND SIOut_z /= SIIn ,
            RefTransition   => '\',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_SI_SCK_DDR_F,
            Violation       => Tviol_SI_SCK_DDR_F
        );


        -- Setup/Hold Check between SI and SCK, DDR mode
        VitalSetupHoldCheck (
            TestSignal      => SIIn,
            TestSignalName  => "SI",
            RefSignal       => SCK_ipd,
            RefSignalName   => "SCK",
            SetupHigh       => tsetup_SI_SCK_DDR80_noedge_negedge,
            SetupLow        => tsetup_SI_SCK_DDR80_noedge_negedge,
            HoldHigh        => thold_SI_SCK_DDR80_noedge_negedge,
            HoldLow         => thold_SI_SCK_DDR80_noedge_negedge,
            CheckEnabled    => ddr AND dual = false AND 
                               ddr80 = false AND SIOut_z /= SIIn ,
            RefTransition   => '\',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_SI_SCK_DDR_F,
            Violation       => Tviol_SI_SCK_DDR_F
        );

        -- Setup Check between RSTNeg and SCK, DDR fast mode
        VitalSetupHoldCheck (
            TestSignal      => RSTNeg,
            TestSignalName  => "RSTNeg",
            RefSignal       => CSNeg,
            RefSignalName   => "CSNeg",
            SetupHigh       => tsetup_RSTNeg_CSNeg,
            CheckEnabled    => TRUE,
            RefTransition   => '\',
            HeaderMsg       => InstancePath & PartID,
            TimingData      => TD_RSTNeg_CSNeg,
            Violation       => Tviol_RSTNeg_CSNeg
        );

        --Pulse Width and Period Check Variables
        -- Pulse Width Check SCK for READ, serial mode
        VitalPeriodPulseCheck (
            TestSignal      =>  SCK_ipd,
            TestSignalName  =>  "SCK",
            PulseWidthLow   =>  tpw_SCK_serial_negedge,
            PulseWidthHigh  =>  tpw_SCK_serial_posedge,
            PeriodData      =>  PD_SCK_serial,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_SCK_serial,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  rd);

        -- Pulse Width Check SCK for DUAL_READ, serial mode
        VitalPeriodPulseCheck (
            TestSignal      =>  SCK_ipd,
            TestSignalName  =>  "SCK",
            PulseWidthLow   =>  tpw_SCK_dual_negedge,
            PulseWidthHigh  =>  tpw_SCK_dual_posedge,
            PeriodData      =>  PD_SCK_dual,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_SCK_dual,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  dual);

        -- Pulse Width Check SCK for DUAL_READ, serial mode
        VitalPeriodPulseCheck (
            TestSignal      =>  SCK_ipd,
            TestSignalName  =>  "SCK",
            PulseWidthLow   =>  tpw_SCK_ddr80_negedge,
            PulseWidthHigh  =>  tpw_SCK_ddr80_posedge,
            PeriodData      =>  PD_SCK_dual,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_SCK_dual,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  ddr80);

        -- Pulse Width Check SCK for FAST_READ, serial mode
        VitalPeriodPulseCheck (
            TestSignal      =>  SCK_ipd,
            TestSignalName  =>  "SCK",
            PulseWidthLow   =>  tpw_SCK_fast_negedge,
            PulseWidthHigh  =>  tpw_SCK_fast_posedge,
            PeriodData      =>  PD_SCK_fast,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_SCK_fast,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  fast_rd );

        -- Pulse Width Check SCK for QPP
        VitalPeriodPulseCheck (
            TestSignal      =>  SCK_ipd,
            TestSignalName  =>  "SCK",
            PulseWidthLow   =>  tpw_SCK_quadpg_negedge,
            PulseWidthHigh  =>  tpw_SCK_quadpg_posedge,
            PeriodData      =>  PD_SCK_quadpg,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_SCK_quadpg,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  quadpg);

        -- Pulse Width Check CS# for READ, serial mode
        VitalPeriodPulseCheck (
            TestSignal      =>  CSNeg_ipd,
            TestSignalName  =>  "CS#",
            PulseWidthHigh  =>  tpw_CSNeg_read_posedge,
            PeriodData      =>  PD_CSNeg_read,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_CSNeg_read,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  any_read );

        -- Pulse Width Check CS# for Program/Erase, serial mode
        VitalPeriodPulseCheck (
            TestSignal      =>  CSNeg_ipd,
            TestSignalName  =>  "CS#",
            PulseWidthHigh  =>  tpw_CSNeg_pgers_posedge,
            PeriodData      =>  PD_CSNeg_pgers,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_CSNeg_pgers,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  NOT(any_read));

        -- Pulse Width Check RSTNeg
        VitalPeriodPulseCheck (
            TestSignal        => RSTNeg_ipd,
            TestSignalName    => "RSTNeg",
            PulseWidthLow     => tpw_RSTNeg_negedge,
            PulseWidthHigh    => tpw_RSTNeg_posedge,
            CheckEnabled      => TRUE,
            HeaderMsg         => InstancePath & PartID,
            PeriodData        => PD_RSTNeg,
            Violation         => Pviol_RSTNeg
            );

        -- Pulse Width Check SCK for DDR READ
        VitalPeriodPulseCheck (
            TestSignal      =>  SCK_ipd,
            TestSignalName  =>  "SCK",
            PulseWidthLow   =>  tpw_SCK_DDR_negedge,
            PulseWidthHigh  =>  tpw_SCK_DDR_posedge,
            PeriodData      =>  PD_SCK_DDR,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_SCK_DDR,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  ddr);

        -- Pulse Width Check SCK for DDR READ
        VitalPeriodPulseCheck (
            TestSignal      =>  SCK_ipd,
            TestSignalName  =>  "SCK",
            PulseWidthLow   =>  tpw_SCK_DDR80_negedge,
            PulseWidthHigh  =>  tpw_SCK_DDR80_posedge,
            PeriodData      =>  PD_SCK_DDR80,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_SCK_DDR80,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  ddr80);

        -- Period Check SCK for READ, serial mode
        VitalPeriodPulseCheck (
            TestSignal      =>  SCK_ipd,
            TestSignalName  =>  "SCK",
            Period          =>  tperiod_SCK_serial_rd,
            PeriodData      =>  PD_SCK_serial_rd,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_SCK_serial_rd,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  rd );

        -- Period Check SCK for FAST READ, serial mode
        VitalPeriodPulseCheck (
            TestSignal      =>  SCK_ipd,
            TestSignalName  =>  "SCK",
            Period          =>  tperiod_SCK_fast_rd,
            PeriodData      =>  PD_SCK_fast_rd,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_SCK_fast_rd,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  fast_rd );

        -- Period Check SCK for DUAL READ, serial mode
        VitalPeriodPulseCheck (
            TestSignal      =>  SCK_ipd,
            TestSignalName  =>  "SCK",
            Period          =>  tperiod_SCK_dual_rd,
            PeriodData      =>  PD_SCK_dual_rd,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_SCK_dual_rd,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  dual );

        -- Period Check SCK for QPP
        VitalPeriodPulseCheck (
            TestSignal      =>  SCK_ipd,
            TestSignalName  =>  "SCK",
            Period          =>  tperiod_SCK_quadpg,
            PeriodData      =>  PD_SCK_quad_pg,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_SCK_quad_pg,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  quadpg );

        -- Period Check SCK for DDR READ
        VitalPeriodPulseCheck (
            TestSignal      =>  SCK_ipd,
            TestSignalName  =>  "SCK",
            Period          =>  tperiod_SCK_DDR_rd,
            PeriodData      =>  PD_SCK_DDR_rd,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_SCK_DDR_rd,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  ddr );

        -- Period Check SCK for DDR READ
        VitalPeriodPulseCheck (
            TestSignal      =>  SCK_ipd,
            TestSignalName  =>  "SCK",
            Period          =>  tperiod_SCK_DDR80_rd,
            PeriodData      =>  PD_SCK_DDR80_rd,
            XOn             =>  XOn,
            MsgOn           =>  MsgOn,
            Violation       =>  Pviol_SCK_DDR80_rd,
            HeaderMsg       =>  InstancePath & PartID,
            CheckEnabled    =>  ddr80 );

        Violation :=   Tviol_CSNeg_SCK_normal OR
                       Tviol_CSNeg_SCK_DDR OR
                       Tviol_CSNeg_RSTNeg OR
                       Tviol_SI_SCK OR
                       Tviol_WPNeg_CSNeg_setup OR
                       Tviol_WPNeg_CSNeg_hold OR
                       Tviol_HOLDNeg_SCK OR
                       Tviol_SI_SCK_DDR_R OR
                       Tviol_SI_SCK_DDR_F OR
                       Tviol_RSTNeg_CSNeg OR
                       Pviol_SCK_serial OR
                       Pviol_SCK_dual OR
                       Pviol_SCK_fast OR
                       Pviol_SCK_quadpg OR
                       Pviol_CSNeg_read OR
                       Pviol_CSNeg_pgers OR
                       Pviol_SCK_DDR OR
                       Pviol_SCK_DDR80 OR
                       Pviol_SCK_serial_rd OR
                       Pviol_SCK_fast_rd OR
                       Pviol_SCK_dual_rd OR
                       Pviol_SCK_quad_pg OR
                       Pviol_SCK_DDR_rd OR
                       Pviol_SCK_DDR80_rd;

            Viol <= Violation;

            ASSERT Violation = '0'
                REPORT InstancePath & partID & ": simulation may be" &
                    " inaccurate due to timing violations"
                SEVERITY WARNING;

        END IF;
    END PROCESS VITALTimingCheck;

    ----------------------------------------------------------------------------
    -- sequential process for FSM state transition
    ----------------------------------------------------------------------------
    StateTransition : PROCESS(next_state, RST, PoweredUp, RST_out)

    BEGIN
        IF PoweredUp = '1' THEN
            IF RSTNeg_pullup = '1' and RST_out= '1' THEN
                IF next_state'EVENT THEN
                    current_state <= next_state;
                END IF;
            ELSIF RSTNeg_pullup = '0' AND falling_edge(RST) THEN
                --no state transition while RESET# low
                current_state <= RESET_STATE;
                RST_in <= '1', '0' AFTER 1 ns;
            END IF;
        END IF;
    END PROCESS StateTransition;

    Threset : PROCESS(RST_in)
    BEGIN
        IF rising_edge(RST_in) THEN
            RST_out <= '0', '1' AFTER HOLD_CSNeg_RSTNeg;
        END IF;
    END PROCESS Threset;

    ---------------------------------------------------------------------------
    --  Write cycle decode
    ---------------------------------------------------------------------------
    BusCycleDecode : PROCESS(SCK_ipd, CSNeg_ipd, HOLDNeg_pullup, SIIn, RST_out,
                             WPNeg_pullup, current_state)

        TYPE quad_data_type IS ARRAY (0 TO 1023) OF INTEGER RANGE 0 TO 15;

        VARIABLE bit_cnt            : NATURAL := 0;
        VARIABLE Data_in            : std_logic_vector(4095 downto 0)
                                                    := (others => '0');

        VARIABLE opcode             : std_logic_vector(7 downto 0);
        VARIABLE opcode_in          : std_logic_vector(7 downto 0);
        VARIABLE addr_bytes         : std_logic_vector(31 downto 0);
        VARIABLE hiaddr_bytes       : std_logic_vector(31 downto 0);
        VARIABLE Address_in         : std_logic_vector(31 downto 0);
        VARIABLE mode_bytes         : std_logic_vector(7 downto 0);
        VARIABLE mode_in            : std_logic_vector(7 downto 0);
        VARIABLE quad_data_in       : quad_data_type;
        VARIABLE quad_nybble        : std_logic_vector(3 downto 0);
        VARIABLE Quad_slv           : std_logic_vector(3 downto 0);
        VARIABLE Byte_slv           : std_logic_vector(7 downto 0);

        VARIABLE CLK_PER            : time;
        VARIABLE LAST_CLK           : time;
        VARIABLE Check_freq         : boolean := FALSE;

    BEGIN

        IF (rising_edge(CSNeg_ipd) AND NOT(bus_cycle_state = DATA_BYTES))
        OR current_state = RESET_STATE THEN
            bus_cycle_state := STAND_BY;
        ELSE
            CASE bus_cycle_state IS
                WHEN STAND_BY =>
                    IF falling_edge(CSNeg_ipd) THEN
                        Instruct  <= NONE;
                        write     <= '1';
                        cfg_write <= '0';
                        opcode_cnt:= 0;
                        addr_cnt  := 0;
                        mode_cnt  := 0;
                        dummy_cnt := 0;
                        dummy_cnt_act_temp <= dummy_cnt;
                        data_cnt  := 0;
                        DOUBLE    := FALSE;
                        CLK_PER   := 0 ns;
                        LAST_CLK  := 0 ns;
                        IF current_state = AUTOBOOT THEN
                            bus_cycle_state := DATA_BYTES;
                        ELSE
                            bus_cycle_state := OPCODE_BYTE;
                        END IF;
                    END IF;

                WHEN OPCODE_BYTE =>
                    IF rising_edge(SCK_ipd)  THEN

                        Latency_code := to_nat(LC1 & LC0);
                        CLK_PER  := NOW - LAST_CLK;
                        LAST_CLK := NOW;
                        IF Check_freq THEN
                            IF (CLK_PER < 20 ns AND Latency_code = 3)  OR
                               (CLK_PER < 12.5 ns AND Latency_code = 0) OR
                               (CLK_PER < 11.1 ns AND Latency_code = 1) OR
                               (CLK_PER < 9.6 ns AND Latency_code = 2) THEN
                                ASSERT FALSE
                                REPORT "More wait states are required for " &
                                       "this clock frequency value"
                                SEVERITY warning;
                                IF (Instruct = DDRFR   OR Instruct = DDRFR4 OR
                                    Instruct = DDRDIOR OR Instruct = DDRDIOR4 OR
                                    Instruct = DDRQIOR OR Instruct = DDRQIOR4)  THEN
                                    IF (CLK_PER < 12.5 ns) THEN 
                                        ddr80 <= TRUE;
                                    ELSE
                                        ddr80 <= FALSE;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                        Check_freq := FALSE;

                        IF ((HOLDNeg_pullup='1' AND QUAD='0') OR QUAD='1') THEN
                        --One-byte of instruction opcode is shifted into the
                        --device on the SI serial input pin with the most
                        --significant bit (MSB) first.Each bit input on the
                        --SI serial input pin is latched on the rising edge of
                        --the SCK serial clock signal.
                            opcode_in(opcode_cnt) := SIIn;
                            opcode_cnt := opcode_cnt + 1;
                            IF opcode_cnt = BYTE THEN
                                --MSB first
                                FOR I IN 7 DOWNTO 0 LOOP
                                    opcode(i) := opcode_in(7-i);
                                END LOOP;

                                CASE opcode IS
                                    WHEN "00000110"  => --06h
                                        Instruct <= WREN;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "00000100"  => --04h
                                        Instruct <= WRDI;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "00000001"  => --01h
                                        Instruct <= WRR;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "00000011"  => --03h
                                        Instruct <= READ;
                                        bus_cycle_state := ADDRESS_BYTES;
                                    WHEN "00010011"  => --13h
                                        Instruct <= RD4;
                                        bus_cycle_state := ADDRESS_BYTES;
                                    WHEN "01001011"  => --4Bh
                                        Instruct <= OTPR;
                                        bus_cycle_state := ADDRESS_BYTES;
                                    WHEN "00000101"  => --05h
                                        Instruct <= RDSR;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "00000111"  => --07h
                                        Instruct <= RDSR2;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "00110101"  => --35h
                                        Instruct <= RDCR;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "10010000"  => --90h
                                        Instruct <= REMS;
                                        bus_cycle_state := ADDRESS_BYTES;
                                    WHEN "10011111"  => --9Fh
                                        Instruct <= RDID;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "10101011"  => --ABh
                                        Instruct <= RES;
                                        bus_cycle_state := DUMMY_BYTES;
                                    WHEN "00001011"  => --0Bh
                                        Instruct <= FSTRD;
                                        bus_cycle_state := ADDRESS_BYTES;
                                        Check_freq := TRUE;
                                    WHEN "00001100"  => --0Ch
                                        Instruct <= FSTRD4;
                                        bus_cycle_state := ADDRESS_BYTES;
                                        Check_freq := TRUE;
                                    WHEN "00001101"  => --0Dh
                                        Instruct <= DDRFR;
                                        bus_cycle_state := ADDRESS_BYTES;
                                        Check_freq := TRUE;
                                    WHEN "00001110"  => --0Eh
                                        Instruct <= DDRFR4;
                                        bus_cycle_state := ADDRESS_BYTES;
                                        Check_freq := TRUE;
                                    WHEN "00111011"  => --3Bh
                                        Instruct <= DOR;
                                        Check_freq := TRUE;
                                        bus_cycle_state := ADDRESS_BYTES;
                                    WHEN "00111100"  => --3Ch
                                        Instruct <= DOR4;
                                        bus_cycle_state := ADDRESS_BYTES;
                                        Check_freq := TRUE;
                                    WHEN "10111011"  => --BBh
                                        Instruct <= DIOR;
                                        bus_cycle_state := ADDRESS_BYTES;
                                        Check_freq := TRUE;
                                    WHEN "10111100"  => --BCh
                                        Instruct <= DIOR4;
                                        bus_cycle_state := ADDRESS_BYTES;
                                        Check_freq := TRUE;
                                    WHEN "10111101"  => --BDh
                                        Instruct <= DDRDIOR;
                                        bus_cycle_state := ADDRESS_BYTES;
                                        Check_freq := TRUE;
                                    WHEN "10111110"  => --BEh
                                        Instruct <= DDRDIOR4;
                                        bus_cycle_state := ADDRESS_BYTES;
                                        Check_freq := TRUE;
                                    WHEN "01101011"  => --6Bh
                                        Instruct <= QOR;
                                        bus_cycle_state := ADDRESS_BYTES;
                                        Check_freq := TRUE;
                                    WHEN "01101100"  => --6Ch
                                        Instruct <= QOR4;
                                        bus_cycle_state := ADDRESS_BYTES;
                                        Check_freq := TRUE;
                                    WHEN "11101011"  => --EBh
                                        Instruct <= QIOR;
                                        bus_cycle_state := ADDRESS_BYTES;
                                        Check_freq := TRUE;
                                    WHEN "11101100"  => --ECh
                                        Instruct <= QIOR4;
                                        bus_cycle_state := ADDRESS_BYTES;
                                        Check_freq := TRUE;
                                    WHEN "11101101"  => --EDh
                                        Instruct <= DDRQIOR;
                                        bus_cycle_state := ADDRESS_BYTES;
                                        Check_freq := TRUE;
                                    WHEN "11101110"  => --EEh
                                        Instruct <= DDRQIOR4;
                                        bus_cycle_state := ADDRESS_BYTES;
                                        Check_freq := TRUE;
                                    WHEN "00000010"  => --02h
                                        Instruct <= PP;
                                        bus_cycle_state := ADDRESS_BYTES;
                                    WHEN "00010010"  => --12h
                                        Instruct <= PP4;
                                        bus_cycle_state := ADDRESS_BYTES;
                                    WHEN "00110010"  => --32h
                                        Instruct <= QPP;
                                        bus_cycle_state := ADDRESS_BYTES;
                                        quadpg   <= TRUE;
                                    WHEN "00111000"  => --38h
                                        Instruct <= QPP;
                                        bus_cycle_state := ADDRESS_BYTES;
                                        quadpg   <= TRUE;
                                    WHEN "00110100"  => --34h
                                        Instruct <= QPP4;
                                        bus_cycle_state := ADDRESS_BYTES;
                                        quadpg   <= TRUE;
                                    WHEN "01000010"  => --42h
                                        Instruct <= OTPP;
                                        bus_cycle_state := ADDRESS_BYTES;
                                    WHEN "10000101"  => --85h
                                        Instruct <= PGSP;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "10001010"  => --8Ah
                                        Instruct <= PGRS;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "11000111"  => --C7h
                                        Instruct <= BE;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "01100000"  => --60h
                                        Instruct <= BE;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "11011000"  => --D8h
                                        Instruct <= SE;
                                        bus_cycle_state := ADDRESS_BYTES;
                                    WHEN "11011100"  => --DCh
                                        Instruct <= SE4;
                                        bus_cycle_state := ADDRESS_BYTES;
                                    WHEN "00100000"  => --20h
                                        Instruct <= P4E;
                                        bus_cycle_state := ADDRESS_BYTES;
                                    WHEN "00100001"  => --21h
                                        Instruct <= P4E4;
                                        bus_cycle_state := ADDRESS_BYTES;
                                    WHEN "01110101"  => --75h
                                        Instruct <= ERSP;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "01111010"  => --7Ah
                                        Instruct <= ERRS;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "00010100"  => --14h
                                        Instruct <= ABRD;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "00010101"  => --15h
                                        Instruct <= ABWR;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "00010110"  => --16h
                                        Instruct <= BRRD;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "00010111"  => --17h
                                        Instruct <= BRWR;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "10111001"  => --B9h
                                        Instruct <= BRAC;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "00101011"  => --2Bh
                                        Instruct <= ASPRD;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "00101111"  => --2Fh
                                        Instruct <= ASPP;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "11100000"  => --E0h
                                        Instruct <= DYBRD;
                                        bus_cycle_state := ADDRESS_BYTES;
                                    WHEN "11100001"  => --E1h
                                        Instruct <= DYBWR;
                                        bus_cycle_state := ADDRESS_BYTES;
                                    WHEN "11100010"  => --E2h
                                        Instruct <= PPBRD;
                                        bus_cycle_state := ADDRESS_BYTES;
                                    WHEN "11100011"  => --E3h
                                        Instruct <= PPBP;
                                        bus_cycle_state := ADDRESS_BYTES;
                                    WHEN "00011000"  => --18h
                                        Instruct <= ECCRD;
                                        bus_cycle_state := ADDRESS_BYTES;
                                    WHEN "11100100"  => --E4h
                                        Instruct <= PPBERS;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "10100110"  => --A6h
                                        Instruct <= PLBWR;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "10100111"  => --A7h
                                        Instruct <= PLBRD;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "11100111"  => --E7h
                                        Instruct <= PASSRD;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "11101000"  => --E8h
                                        Instruct <= PASSP;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "11101001"  => --E9h
                                        Instruct <= PASSU;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "11110000"  => --F0h
                                        Instruct <= RESET;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "11111111"  => --FFh
                                        Instruct <= MBR;
                                        bus_cycle_state := MODE_BYTE;
                                    WHEN "01000001"  => -- 41h
                                        Instruct <= DLPRD;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "01000011"  => -- 43h
                                        Instruct <= PNVDLR;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "01001010"  => -- 4Ah
                                        Instruct <= WVDLR;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN "00110000"  => --30h
                                        Instruct <= CLSR;
                                        bus_cycle_state := DATA_BYTES;
                                    WHEN others =>
                                        null;

                                END CASE;
                            END IF;
                        END IF;
                    END IF;

                WHEN ADDRESS_BYTES =>
                    IF Instruct= DDRFR OR Instruct= DDRFR4 OR Instruct= DDRDIOR
                       OR Instruct = DDRDIOR4 OR Instruct = DDRQIOR OR
                       Instruct = DDRQIOR4 THEN
                       DOUBLE := TRUE;
                    ELSE
                       DOUBLE := FALSE;
                    END IF;

                    IF (rising_edge(SCK_ipd) AND NOT(DOUBLE) AND
                       (CSNeg_ipd= '0')) THEN
                        IF (((Instruct=FSTRD AND EXTADD= '0' )
                         OR  (Instruct=DOR  AND EXTADD= '0')
                         OR   Instruct=OTPR) AND
                         ((HOLDNeg_pullup='1' AND QUAD='0') OR QUAD='1'))
                         OR  (Instruct=QOR  AND QUAD= '1' AND EXTADD='0') THEN
                            --Instruction + 3 Bytes Address + Dummy Byte
                            Address_in(addr_cnt) := SIIn;
                            addr_cnt := addr_cnt + 1;
                            IF addr_cnt = 3*BYTE THEN
                                FOR I IN 23 DOWNTO 0 LOOP
                                    addr_bytes(23-i) := Address_in(i);
                                END LOOP;
                                addr_bytes(31 downto 25) := "0000000";
                                addr_bytes(24) := Bank_Addr_reg(0);
                                Address <= to_nat(addr_bytes);
                                change_addr <= '1','0' AFTER 1 ns;
                                IF (Instruct=FSTRD OR Instruct=DOR OR
                                    Instruct=QOR) THEN
                                    IF (Latency_code = 3) THEN
                                        bus_cycle_state := DATA_BYTES;
                                    ELSE
                                        bus_cycle_state := DUMMY_BYTES;
                                    END IF;
                                ELSE
                                    bus_cycle_state := DUMMY_BYTES;
                                END IF;
                            END IF;
                        ELSIF (Instruct=ECCRD) THEN
                            --Instruction + 4 Bytes Address + Dummy Byte
                            Address_in(addr_cnt) := SIIn;
                            addr_cnt := addr_cnt + 1;
                            IF addr_cnt = 4*BYTE THEN
                                FOR I IN 31 DOWNTO 0 LOOP
                                    hiaddr_bytes(31-i) := Address_in(i);
                                END LOOP;
                                hiaddr_bytes(3 downto 0) := "0000";
                                Address<= to_nat(hiaddr_bytes);
                                change_addr <= '1','0' AFTER 1 ns;
                                bus_cycle_state := DUMMY_BYTES;
                            END IF;
                        ELSIF ((((Instruct=FSTRD4) OR (Instruct=DOR4) OR
                            ((Instruct=FSTRD) AND EXTADD= '1') OR
                            ((Instruct=DOR) AND EXTADD= '1')) AND
                            ((HOLDNeg_pullup='1' AND QUAD='0') OR QUAD='1')) OR
                            ((Instruct=QOR4) AND QUAD='1') OR
                            ((Instruct=QOR) AND QUAD='1' AND EXTADD='1')) THEN
                            --Instruction + 4 Bytes Address + Dummy Byte
                            Address_in(addr_cnt) := SIIn;
                            addr_cnt := addr_cnt + 1;
                            IF addr_cnt = 4*BYTE THEN
                                FOR I IN 31 DOWNTO 0 LOOP
                                    hiaddr_bytes(31-i) := Address_in(i);
                                END LOOP;
                                Address <= to_nat(hiaddr_bytes(24 downto 0));
                                change_addr <= '1','0' AFTER 1 ns;
                                IF Latency_code = 3 THEN
                                    bus_cycle_state := DATA_BYTES;
                                ELSE
                                    bus_cycle_state := DUMMY_BYTES;
                                    IF (DOUBLE AND NOT(hold_mode) AND
                                        VDLR_reg /= "00000000") THEN
                                        read_out <= '1', '0' AFTER 1 ns;
                                    END IF;
                                END IF;
                            END IF;
                        ELSIF Instruct = DIOR AND EXTADD= '0' AND
                           ((HOLDNeg_pullup='1' AND QUAD='0') OR QUAD='1') THEN
                            -- DUAL I/O High Performance Read (3Bytes Address)
                            IF SOIn /= 'Z' THEN
                                Address_in(2*addr_cnt)   := SOIn;
                                Address_in(2*addr_cnt+1) := SIIn;
                                read_cnt := 0;
                                addr_cnt := addr_cnt + 1;
                                IF addr_cnt = (3*BYTE) / 2 THEN
                                    addr_cnt := 0;
                                    FOR I IN 23 DOWNTO 0 LOOP
                                        addr_bytes(23-i) := Address_in(i);
                                    END LOOP;
                                    addr_bytes(31 downto 25) := "0000000";
                                    addr_bytes(24) := Bank_Addr_reg(0);
                                    Address <= to_nat(addr_bytes);
                                    change_addr <= '1','0' AFTER 1 ns;
                                    IF EHP THEN
                                        bus_cycle_state := MODE_BYTE;
                                    ELSE
                                        bus_cycle_state := DUMMY_BYTES;
                                    END IF;
                                END IF;
                            ELSE
                                bus_cycle_state := STAND_BY;
                            END IF;
                        ELSIF ((Instruct = DIOR4 OR
                              (Instruct = DIOR AND EXTADD= '1')) AND
                              ((HOLDNeg_pullup = '1' AND QUAD = '0') OR
                                QUAD = '1')) THEN
                            -- DUAL I/O High Performance Read (4Bytes Address)
                            IF SOIn /= 'Z' THEN
                                Address_in(2*addr_cnt)   := SOIn;
                                Address_in(2*addr_cnt+1) := SIIn;
                                read_cnt := 0;
                                addr_cnt := addr_cnt + 1;
                                IF addr_cnt = (4*BYTE) / 2 THEN
                                    addr_cnt := 0;
                                    FOR I IN 31 DOWNTO 0 LOOP
                                        hiaddr_bytes(31-i) := Address_in(i);
                                    END LOOP;
                                    Address <= to_nat(hiaddr_bytes(24 downto 0));
                                    change_addr <= '1','0' AFTER 1 ns;
                                    IF EHP THEN
                                        bus_cycle_state := MODE_BYTE;
                                    ELSE
                                        bus_cycle_state := DUMMY_BYTES;
                                    END IF;
                                END IF;
                            ELSE
                                bus_cycle_state := STAND_BY;
                            END IF;
                        ELSIF (Instruct = QIOR AND EXTADD= '0') THEN
                            -- QUAD I/O High Performance Read (3Bytes Address)
                            IF QUAD = '1' THEN
                                IF SOIn /= 'Z' THEN
                                    Address_in(4*addr_cnt)   := HOLDNegIn;
                                    Address_in(4*addr_cnt+1) := WPNegIn;
                                    Address_in(4*addr_cnt+2) := SOIn;
                                    Address_in(4*addr_cnt+3) := SIIn;
                                    read_cnt := 0;
                                    addr_cnt := addr_cnt + 1;
                                    IF addr_cnt = (3*BYTE) / 4 THEN
                                        addr_cnt := 0;
                                        FOR I IN 23 DOWNTO 0 LOOP
                                            addr_bytes(23-i) := Address_in(i);
                                        END LOOP;
                                        addr_bytes(31 downto 25) := "0000000";
                                        addr_bytes(24) := Bank_Addr_reg(0);
                                        Address <= to_nat(addr_bytes);
                                        change_addr <= '1','0' AFTER 1 ns;
                                        bus_cycle_state := MODE_BYTE;
                                    END IF;
                                END IF;
                            ELSE
                                bus_cycle_state := STAND_BY;
                            END IF;
                        ELSIF (Instruct = QIOR4 OR
                              (Instruct = QIOR AND EXTADD= '1')) THEN
                            -- QUAD I/O High Performance Read (4Bytes Address)
                            IF QUAD = '1' THEN
                                IF SOIn /= 'Z' THEN
                                    Address_in(4*addr_cnt)   := HOLDNegIn;
                                    Address_in(4*addr_cnt+1) := WPNegIn;
                                    Address_in(4*addr_cnt+2) := SOIn;
                                    Address_in(4*addr_cnt+3) := SIIn;
                                    read_cnt := 0;
                                    addr_cnt := addr_cnt + 1;
                                    IF addr_cnt = (4*BYTE) / 4 THEN
                                        addr_cnt := 0;
                                        FOR I IN 31 DOWNTO 0 LOOP
                                            hiaddr_bytes(31-i)
                                                        := Address_in(i);
                                        END LOOP;
                                        Address <= to_nat(hiaddr_bytes(24 downto 0));
                                        change_addr <= '1','0' AFTER 1 ns;
                                        bus_cycle_state := MODE_BYTE;
                                    END IF;
                                END IF;
                            ELSE
                                bus_cycle_state := STAND_BY;
                            END IF;
                        ELSIF (((Instruct = RD4  OR Instruct = PP4 OR
                              Instruct = SE4 OR Instruct = PPBRD OR
                              Instruct = DYBRD OR Instruct = DYBWR OR
                              Instruct = PPBP OR Instruct = P4E4 OR
                              (Instruct = READ AND EXTADD= '1' ) OR
                              (Instruct = PP AND EXTADD= '1' ) OR
                              (Instruct = P4E AND EXTADD= '1' ) OR
                              (Instruct = SE AND EXTADD= '1' )) AND
                              ((HOLDNeg_pullup='1' AND QUAD='0') OR QUAD='1'))
                              OR (QUAD ='1' AND (Instruct=QPP4 OR
                              (Instruct = QPP AND EXTADD= '1' ))))THEN
                            Address_in(addr_cnt) := SIIn;
                            addr_cnt := addr_cnt + 1;
                            IF addr_cnt = 4*BYTE THEN
                                FOR I IN 31 DOWNTO 0 LOOP
                                    hiaddr_bytes(31-i) := Address_in(i);
                                END LOOP;
                                Address <= to_nat(hiaddr_bytes(24 downto 0));
                                change_addr <= '1','0' AFTER 1 ns;
                                bus_cycle_state := DATA_BYTES;
                            END IF;
                        ELSIF (((HOLDNeg_pullup='1' AND QUAD='0')
                                 OR QUAD='1') AND EXTADD= '0') THEN
                            Address_in(addr_cnt) := SIIn;
                            addr_cnt := addr_cnt + 1;
                            IF addr_cnt = 3*BYTE THEN
                                FOR I IN 23 DOWNTO 0 LOOP
                                    addr_bytes(23-i) := Address_in(i);
                                END LOOP;
                                addr_bytes(31 downto 25) := "0000000";
                                addr_bytes(24) := Bank_Addr_reg(0);
                                Address <= to_nat(addr_bytes);
                                change_addr <= '1','0' AFTER 1 ns;
                                bus_cycle_state := DATA_BYTES;
                            END IF;
                        END IF;
                    ELSIF (SCK_ipd'EVENT AND DOUBLE AND addr_cnt /= 0 ) OR
                       (rising_edge(SCK_ipd) AND DOUBLE AND addr_cnt = 0 ) THEN
                        IF (Instruct=DDRFR AND EXTADD= '0' ) THEN
                            --Fast DDR Read Mode
                            Address_in(addr_cnt) := SIIn;
                            addr_cnt := addr_cnt + 1;
                            read_cnt := 0;
                            IF addr_cnt = 3*BYTE THEN
                                addr_cnt := 0;
                                FOR I IN 23 DOWNTO 0 LOOP
                                    addr_bytes(23-i) := Address_in(i);
                                END LOOP;
                                addr_bytes(31 downto 25) := "0000000";
                                addr_bytes(24) := Bank_Addr_reg(0);
                                Address <= to_nat(addr_bytes);
                                change_addr <= '1','0' AFTER 1 ns;
                                IF EHP THEN
                                    bus_cycle_state := MODE_BYTE;
                                ELSE
                                    bus_cycle_state := DUMMY_BYTES;
                                END IF;
                            END IF;
                        ELSIF (Instruct=DDRFR4 OR
                              (Instruct=DDRFR AND EXTADD= '1' )) THEN
                            Address_in(addr_cnt) := SIIn;
                            addr_cnt := addr_cnt + 1;
                            read_cnt := 0;
                            IF addr_cnt = 4*BYTE THEN
                                addr_cnt := 0;
                                FOR I IN 31 DOWNTO 0 LOOP
                                    addr_bytes(31-i) := Address_in(i);
                                END LOOP;
                                Address <= to_nat(addr_bytes(24 downto 0));
                                change_addr <= '1','0' AFTER 1 ns;
                                IF EHP THEN
                                    bus_cycle_state := MODE_BYTE;
                                ELSE
                                    bus_cycle_state := DUMMY_BYTES;
                                    IF ((DOUBLE AND NOT(hold_mode)) AND
                                         VDLR_reg /= "00000000") THEN
                                        read_out <= '1', '0' AFTER 1 ns;
                                    END IF;
                                END IF;
                            END IF;
                        ELSIF (Instruct= DDRDIOR AND EXTADD= '0' ) THEN
                            --Dual I/O DDR Read Mode
                            Address_in(2*addr_cnt)  := SOIn;
                            Address_in(2*addr_cnt+1):= SIIn;
                            addr_cnt := addr_cnt + 1;
                            read_cnt := 0;
                            IF addr_cnt = (3*BYTE)/2 THEN
                                addr_cnt := 0;
                                FOR I IN 23 DOWNTO 0 LOOP
                                    addr_bytes(23-i) := Address_in(i);
                                END LOOP;
                                addr_bytes(31 downto 25) := "0000000";
                                addr_bytes(24) := Bank_Addr_reg(0);
                                Address <= to_nat(addr_bytes);
                                change_addr <= '1','0' AFTER 1 ns;
                                IF EHP THEN
                                    bus_cycle_state := MODE_BYTE;
                                ELSE
                                    bus_cycle_state := DUMMY_BYTES;
                                END IF;
                            END IF;
                        ELSIF (Instruct=DDRDIOR4 OR
                              (Instruct=DDRDIOR AND EXTADD= '1' )) THEN
                             --Dual I/O DDR Read Mode
                            Address_in(2*addr_cnt)   := SOIn;
                            Address_in(2*addr_cnt+1) := SIIn;
                            addr_cnt := addr_cnt + 1;
                            read_cnt := 0;
                            IF addr_cnt = (4*BYTE)/2 THEN
                                addr_cnt := 0;
                                FOR I IN 31 DOWNTO 0 LOOP
                                    addr_bytes(31-i) := Address_in(i);
                                END LOOP;
                                Address <= to_nat(addr_bytes(24 downto 0));
                                change_addr <= '1','0' AFTER 1 ns;
                                IF EHP THEN
                                    bus_cycle_state := MODE_BYTE;
                                ELSE
                                    bus_cycle_state := DUMMY_BYTES;
                                    IF ((DOUBLE AND NOT(hold_mode)) AND
                                         VDLR_reg /= "00000000") THEN
                                        read_out <= '1', '0' AFTER 1 ns;
                                    END IF;
                                END IF;
                            END IF;
                        ELSIF (Instruct=DDRQIOR AND EXTADD= '0' ) AND
                               QUAD = '1' THEN
                            --Quad I/O DDR Read Mode
                            Address_in(4*addr_cnt)   := HOLDNegIn;
                            Address_in(4*addr_cnt+1) := WPNegIn;
                            Address_in(4*addr_cnt+2) := SOIn;
                            Address_in(4*addr_cnt+3) := SIIn;
                            addr_cnt := addr_cnt + 1;
                            read_cnt := 0;
                            IF addr_cnt = (3*BYTE)/4 THEN
                                addr_cnt := 0;
                                FOR I IN 23 DOWNTO 0 LOOP
                                    addr_bytes(23-i) := Address_in(i);
                                END LOOP;
                                addr_bytes(31 downto 25) := "0000000";
                                addr_bytes(24) := Bank_Addr_reg(0);
                                Address <= to_nat(addr_bytes);
                                change_addr <= '1','0' AFTER 5 ns;
                                bus_cycle_state := MODE_BYTE;
                            END IF;
                        ELSIF QUAD = '1' AND (Instruct=DDRQIOR4 OR
                              (Instruct=DDRQIOR AND EXTADD= '1' )) THEN
                            Address_in(4*addr_cnt)   := HOLDNegIn;
                            Address_in(4*addr_cnt+1) := WPNegIn;
                            Address_in(4*addr_cnt+2) := SOIn;
                            Address_in(4*addr_cnt+3) := SIIn;
                            addr_cnt := addr_cnt + 1;
                            read_cnt := 0;
                            IF addr_cnt = (4*BYTE)/4 THEN
                                addr_cnt := 0;
                                FOR I IN 31 DOWNTO 0 LOOP
                                    addr_bytes(31-i) := Address_in(i);
                                END LOOP;
                                Address <= to_nat(addr_bytes(24 downto 0));
                                change_addr <= '1','0' AFTER 1 ns;
                                bus_cycle_state := MODE_BYTE;
                            END IF;
                        END IF;
                    END IF;

                WHEN MODE_BYTE =>
                    IF rising_edge(SCK_ipd) THEN
                        IF ((Instruct=DIOR OR Instruct = DIOR4) AND
                         ((HOLDNeg_pullup='1' AND QUAD='0') OR QUAD='1')) THEN
                            mode_in(2*mode_cnt)   := SOIn;
                            mode_in(2*mode_cnt+1) := SIIn;
                            mode_cnt := mode_cnt + 1;
                            IF mode_cnt = BYTE/2 THEN
                                mode_cnt := 0;
                                FOR I IN 7 DOWNTO 0 LOOP
                                    mode_bytes(i) := mode_in(7-i);
                                END LOOP;
                                IF Latency_code = 0 OR Latency_code = 3 THEN
                                    bus_cycle_state := DATA_BYTES;
                                ELSE
                                    bus_cycle_state := DUMMY_BYTES;
                                END IF;
                            END IF;
                        ELSIF (Instruct=QIOR OR Instruct = QIOR4)
                               AND QUAD = '1' THEN
                            mode_in(4*mode_cnt)   := HOLDNegIn;
                            mode_in(4*mode_cnt+1) := WPNegIn;
                            mode_in(4*mode_cnt+2) := SOIn;
                            mode_in(4*mode_cnt+3) := SIIn;
                            mode_cnt := mode_cnt + 1;
                            IF mode_cnt = BYTE/4 THEN
                                mode_cnt := 0;
                                FOR I IN 7 DOWNTO 0 LOOP
                                    mode_bytes(i) := mode_in(7-i);
                                END LOOP;
                                bus_cycle_state := DUMMY_BYTES;
                            END IF;
                        ELSIF Instruct=DDRFR OR Instruct = DDRFR4 THEN
                            mode_in(2*mode_cnt)   := SIIn;
                        ELSIF Instruct=DDRDIOR OR Instruct = DDRDIOR4 THEN
                            mode_in(4*mode_cnt)   := SOIn;
                            mode_in(4*mode_cnt+1) := SIIn;
                        ELSIF (Instruct=DDRQIOR OR Instruct = DDRQIOR4)
                             AND QUAD = '1' THEN
                            mode_in(0) := HOLDNegIn;
                            mode_in(1) := WPNegIn;
                            mode_in(2) := SOIn;
                            mode_in(3) := SIIn;
                        END IF;
                        dummy_cnt := 0;
                        dummy_cnt_act_temp <= dummy_cnt;
                    ELSIF falling_edge(SCK_ipd) THEN
                        IF Instruct=DDRFR OR Instruct = DDRFR4 THEN
                            mode_in(2*mode_cnt+1)   := SIIn;
                            mode_cnt := mode_cnt + 1;
                            IF mode_cnt = BYTE/2 THEN
                                mode_cnt := 0;
                                FOR I IN 7 DOWNTO 0 LOOP
                                    mode_bytes(i) := mode_in(7-i);
                                END LOOP;
                                bus_cycle_state := DUMMY_BYTES;
                            END IF;
                        ELSIF Instruct=DDRDIOR OR Instruct = DDRDIOR4 THEN
                            mode_in(4*mode_cnt+2) := SOIn;
                            mode_in(4*mode_cnt+3) := SIIn;
                            mode_cnt := mode_cnt + 1;
                            IF mode_cnt = BYTE/4 THEN
                                mode_cnt := 0;
                                FOR I IN 7 DOWNTO 0 LOOP
                                    mode_bytes(i) := mode_in(7-i);
                                END LOOP;
                                bus_cycle_state := DUMMY_BYTES;
                            END IF;
                        ELSIF (Instruct=DDRQIOR OR Instruct = DDRQIOR4)
                               AND QUAD = '1' THEN
                            mode_in(4) := HOLDNegIn;
                            mode_in(5) := WPNegIn;
                            mode_in(6) := SOIn;
                            mode_in(7) := SIIn;
                            FOR I IN 7 DOWNTO 0 LOOP
                                mode_bytes(i) := mode_in(7-i);
                            END LOOP;
                            bus_cycle_state := DUMMY_BYTES;
                        END IF;
                    END IF;

                WHEN DUMMY_BYTES =>
                    IF rising_edge(SCK_ipd) THEN
                        IF (((Instruct=FSTRD OR Instruct=FSTRD4 OR
                              Instruct=DOR OR Instruct=DOR4 OR
                              Instruct=OTPR) AND
                           ((HOLDNeg_pullup='1' AND QUAD='0') OR QUAD='1')) OR
                           ((Instruct = QOR OR Instruct = QOR4) AND
                             QUAD = '1'))THEN
                            dummy_cnt := dummy_cnt + 1;
                            dummy_cnt_act_temp <= dummy_cnt;
                            IF dummy_cnt = BYTE THEN
                                bus_cycle_state := DATA_BYTES;
                            END IF;
                        ELSIF (Instruct=DDRFR OR Instruct=DDRFR4) THEN
                            dummy_cnt := dummy_cnt + 1;
                            dummy_cnt_act_temp <= dummy_cnt;
                            IF EHP THEN
                                IF ((Latency_code = 3 AND dummy_cnt=1) OR
                                (Latency_code = 0 AND dummy_cnt=2) OR
                                (Latency_code = 1 AND dummy_cnt=4) OR
                                (Latency_code = 2 AND dummy_cnt=5)) THEN
                                    bus_cycle_state := DATA_BYTES;
                                END IF;
                                IF VDLR_reg/="00000000" AND Latency_code=2 THEN
                                    IF dummy_cnt>1 THEN
                                        read_out <= '1', '0' AFTER 1 ns;
                                        IF dummy_cnt=5 THEN
                                            DummyBytes_act  := '1';
                                        END IF;
                                    END IF;
                                END IF;
                            ELSE
                                IF ((Latency_code = 3 AND dummy_cnt = 4) OR
                                (Latency_code = 0 AND dummy_cnt = 5) OR
                                (Latency_code = 1 AND dummy_cnt = 6) OR
                                (Latency_code = 2 AND dummy_cnt = 7)) THEN
                                    bus_cycle_state := DATA_BYTES;
                                 END IF;
                                IF VDLR_reg/="00000000" THEN                                                                       
                                    IF Latency_code=0 THEN
                                        IF dummy_cnt>1 THEN
                                            read_out <= '1', '0' AFTER 1 ns;
                                            IF dummy_cnt=5 THEN
                                                DummyBytes_act  := '1';
                                            END IF;
                                        END IF;
                                    ELSIF Latency_code = 1 THEN
                                        IF dummy_cnt>2 THEN
                                            read_out <= '1', '0' AFTER 1 ns;
                                            IF dummy_cnt=6 THEN
                                                DummyBytes_act  := '1';
                                            END IF;
                                        END IF;
                                    ELSIF Latency_code = 2 THEN
                                        IF dummy_cnt>3 THEN
                                            read_out <= '1', '0' AFTER 1 ns;
                                            IF dummy_cnt=7 THEN
                                                DummyBytes_act  := '1';
                                            END IF;
                                        END IF;
                                    END IF;
                                END IF;
                             END IF;
                        ELSIF Instruct=RES THEN
                            dummy_cnt := dummy_cnt + 1;
                            dummy_cnt_act_temp <= dummy_cnt;
                            IF dummy_cnt = 3*BYTE THEN
                                bus_cycle_state := DATA_BYTES;
                            END IF;
                        ELSIF Instruct=ECCRD THEN
                            dummy_cnt := dummy_cnt + 1;
                            dummy_cnt_act_temp <= dummy_cnt;
                            IF dummy_cnt = BYTE THEN
                                bus_cycle_state := DATA_BYTES;
                            END IF;
                        ELSIF (Instruct = DIOR OR Instruct = DIOR4) AND
                           ((HOLDNeg_pullup='1' AND QUAD='0') OR QUAD='1') THEN
                            dummy_cnt := dummy_cnt + 1;
                            dummy_cnt_act_temp <= dummy_cnt;
                            IF EHP THEN
                                IF ((Latency_code = 1 AND dummy_cnt = 1) OR
                                    (Latency_code = 2 AND dummy_cnt = 2)) THEN
                                    bus_cycle_state := DATA_BYTES;
                                END IF;
                            ELSE
                                IF ((Latency_code = 3 AND dummy_cnt = 4) OR
                                    (Latency_code = 0 AND dummy_cnt = 4) OR
                                    (Latency_code = 1 AND dummy_cnt = 5) OR
                                    (Latency_code = 2 AND dummy_cnt = 6)) THEN
                                    bus_cycle_state := DATA_BYTES;
                                END IF;
                            END IF;
                        ELSIF Instruct = DDRDIOR OR Instruct = DDRDIOR4 THEN
                            dummy_cnt := dummy_cnt + 1;
                            dummy_cnt_act_temp <= dummy_cnt;
                            IF EHP THEN
                                IF ((Latency_code = 3 AND dummy_cnt = 2) OR
                                (Latency_code = 0 AND dummy_cnt = 4) OR
                                (Latency_code = 1 AND dummy_cnt = 5) OR
                                (Latency_code = 2 AND dummy_cnt = 6)) THEN
                                    bus_cycle_state := DATA_BYTES;
                                END IF;
                                IF VDLR_reg/="00000000" THEN
                                    IF Latency_code=1 THEN
                                        IF dummy_cnt>1 THEN
                                            read_out <= '1', '0' AFTER 1 ns;
                                            IF dummy_cnt=5 THEN
                                                DummyBytes_act  := '1';
                                            END IF;
                                        END IF;
                                    ELSIF Latency_code=2 THEN
                                        IF dummy_cnt>2 THEN
                                            read_out <= '1', '0' AFTER 1 ns;
                                            IF dummy_cnt=6 THEN
                                                DummyBytes_act  := '1';
                                            END IF;
                                        END IF;
                                    END IF;
                                END IF;
                            ELSE
                                IF ((Latency_code = 3 AND dummy_cnt = 4) OR
                                (Latency_code = 0 AND dummy_cnt = 6) OR
                                (Latency_code = 1 AND dummy_cnt = 7) OR
                                (Latency_code = 2 AND dummy_cnt = 8)) THEN
                                    bus_cycle_state := DATA_BYTES;
                                END IF;
                                IF VDLR_reg/="00000000" THEN
                                    IF Latency_code=0  THEN
                                        IF dummy_cnt>2 THEN
                                            read_out <= '1', '0' AFTER 1 ns;
                                            IF dummy_cnt=6 THEN
                                                DummyBytes_act  := '1';
                                            END IF;
                                        END IF;
                                    ELSIF Latency_code = 1 THEN
                                        IF dummy_cnt>3 THEN
                                            read_out <= '1', '0' AFTER 1 ns;
                                            IF dummy_cnt=7 THEN
                                                DummyBytes_act  := '1';
                                            END IF;
                                        END IF;
                                    ELSIF Latency_code = 2 THEN
                                        IF dummy_cnt>4 THEN
                                            read_out <= '1', '0' AFTER 1 ns;
                                            IF dummy_cnt=8 THEN
                                                DummyBytes_act  := '1';
                                            END IF;
                                        END IF;
                                    END IF;
                                END IF;
                            END IF;
                        ELSIF ((Instruct = QIOR OR Instruct = QIOR4) AND
                              QUAD = '1') THEN
                            dummy_cnt := dummy_cnt + 1;
                            dummy_cnt_act_temp <= dummy_cnt;
                            IF ((Latency_code = 3 AND dummy_cnt = 1) OR
                                (Latency_code = 0 AND dummy_cnt = 4) OR
                                (Latency_code = 1 AND dummy_cnt = 4) OR
                                (Latency_code = 2 AND dummy_cnt = 5)) THEN
                                bus_cycle_state := DATA_BYTES;
                            END IF;
                        ELSIF (Instruct = DDRQIOR OR Instruct = DDRQIOR4)
                              AND QUAD = '1' THEN
                            dummy_cnt := dummy_cnt + 1;
                            dummy_cnt_act_temp <= dummy_cnt;
                            IF ((Latency_code = 3 AND dummy_cnt = 3) OR
                            (Latency_code = 0 AND dummy_cnt = 6) OR
                            (Latency_code = 1 AND dummy_cnt = 7) OR
                            (Latency_code = 2 AND dummy_cnt = 8)) THEN
                                bus_cycle_state := DATA_BYTES;
                            END IF;
                            IF VDLR_reg/="00000000" THEN
                               IF Latency_code = 0 THEN
                                    IF dummy_cnt>2 THEN
                                        read_out <= '1', '0' AFTER 1 ns;
                                        IF dummy_cnt=6 THEN
                                            DummyBytes_act  := '1';
                                        END IF;
                                    END IF;
                                ELSIF Latency_code = 1 THEN
                                    IF dummy_cnt>3 THEN
                                        read_out <= '1', '0' AFTER 1 ns;
                                        IF dummy_cnt=7 THEN
                                            DummyBytes_act  := '1';
                                        END IF;
                                    END IF;
                                ELSIF Latency_code = 2 THEN
                                    IF dummy_cnt>4 THEN
                                        read_out <= '1', '0' AFTER 1 ns;
                                        IF dummy_cnt=8 THEN
                                            DummyBytes_act  := '1';
                                        END IF;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    ELSIF falling_edge(SCK_ipd) THEN
                        IF VDLR_reg /= "00000000" THEN
                            IF (Instruct=DDRFR OR Instruct=DDRFR4) THEN
                                IF EHP THEN
                                    IF (Latency_code = 2 AND dummy_cnt>=1) THEN
                                        read_out <= '1', '0' AFTER 1 ns;
                                    END IF;
                                ELSE
                                    IF (Latency_code = 0 AND dummy_cnt>=1) THEN
                                        read_out <= '1', '0' AFTER 1 ns;
                                    ELSIF (Latency_code = 1 AND dummy_cnt>=2) THEN
                                        read_out <= '1', '0' AFTER 1 ns;
                                    ELSIF (Latency_code = 2 AND dummy_cnt>=3) THEN
                                        read_out <= '1', '0' AFTER 1 ns;
                                    END IF;
                                END IF;
                            ELSIF (Instruct=DDRDIOR OR Instruct=DDRDIOR4) THEN
                                IF EHP THEN
                                    IF (Latency_code = 1 AND dummy_cnt>=1) THEN
                                        read_out <= '1', '0' AFTER 1 ns;
                                    ELSIF (Latency_code = 2 AND dummy_cnt>=2) THEN
                                        read_out <= '1', '0' AFTER 1 ns;
                                    END IF;
                                ELSE
                                    IF (Latency_code = 0 AND dummy_cnt>=2) THEN
                                        read_out <= '1', '0' AFTER 1 ns;
                                    ELSIF (Latency_code = 1 AND dummy_cnt>=3) THEN
                                        read_out <= '1', '0' AFTER 1 ns;
                                    ELSIF (Latency_code = 2 AND dummy_cnt>=4) THEN
                                        read_out <= '1', '0' AFTER 1 ns;
                                    END IF;
                                END IF;
                            ELSIF (Instruct=DDRQIOR OR Instruct=DDRQIOR4) THEN
                                IF (Latency_code = 0 AND dummy_cnt>=2) THEN
                                    read_out <= '1', '0' AFTER 1 ns;
                                ELSIF (Latency_code = 1 AND dummy_cnt>=3) THEN
                                    read_out <= '1', '0' AFTER 1 ns;
                                ELSIF (Latency_code = 2 AND dummy_cnt>=4) THEN
                                    read_out <= '1', '0' AFTER 1 ns;
                                END IF;
                            END IF;
                        END IF;
                    END IF;

                WHEN DATA_BYTES =>
                    IF rising_edge(CSNeg_ipd) THEN
                        IF ((mode_bytes(7 downto 4) = "1010" AND
                          (Instruct = DIOR OR Instruct = DIOR4 OR
                           Instruct = QIOR OR Instruct = QIOR4)) OR
                          ((mode_bytes(7 downto 4) =
                                    NOT(mode_bytes(3 downto 0))) AND
                          (Instruct = DDRFR  OR Instruct = DDRFR4  OR
                           Instruct = DDRDIOR OR Instruct = DDRDIOR4 OR
                           Instruct = DDRQIOR OR Instruct = DDRQIOR4))) THEN
                            bus_cycle_state := ADDRESS_BYTES;
                        ELSE
                            bus_cycle_state := STAND_BY;
                        END IF;
                    END IF;
                    IF falling_edge(SCK_ipd) AND CSNeg_ipd = '0' AND
                       NOT(DOUBLE) THEN
                        IF ((Instruct = READ OR Instruct=RD4 OR
                            Instruct = FSTRD OR Instruct = FSTRD4 OR
                            Instruct = RDSR  OR Instruct = RDSR2 OR
                            Instruct = RDCR  OR Instruct = OTPR OR
                            Instruct = DOR  OR Instruct = DOR4 OR
                            Instruct = DIOR OR Instruct = DIOR4 OR
                            Instruct = ABRD  OR Instruct = BRRD OR
                            Instruct = ASPRD OR Instruct = DYBRD OR
                            Instruct = PPBRD OR Instruct = ECCRD OR
                            Instruct = PASSRD OR Instruct = RDID OR
                            Instruct = RES  OR Instruct = REMS OR
                            Instruct = PLBRD OR Instruct = DLPRD)
                           AND ((HOLDNeg_pullup='1' AND QUAD='0') OR QUAD='1'))
                           OR (current_state = AUTOBOOT AND start_delay = 0)OR
                          ((Instruct=QOR OR Instruct=QIOR OR Instruct=QOR4
                            OR Instruct= QIOR4) AND QUAD = '1') THEN
                            read_out <= '1', '0' AFTER 1 ns;
                        END IF;
                    ELSIF SCK_ipd'EVENT AND CSNeg_ipd = '0' AND DOUBLE THEN
                        read_out <= '1', '0' AFTER 1 ns;
                    END IF;

                    IF rising_edge(SCK_ipd) THEN
                        IF QUAD = '1' AND (Instruct=QPP OR Instruct = QPP4)THEN
                            quad_nybble := HOLDNegIn & WPNegIn & SOIn & SIIn;
                            IF data_cnt > (PageSize*2-1) THEN
                            --In case of quad mode and QPP,
                            --if more than 512 bytes are sent to the device
                                FOR I IN 0 TO (PageSize*2-2) LOOP
                                    quad_data_in(i) := quad_data_in(i+1);
                                END LOOP;
                                quad_data_in((PageSize*2-1)) :=
                                                    to_nat(quad_nybble);
                                data_cnt := data_cnt +1;
                            ELSE
                                IF quad_nybble /= "ZZZZ" THEN
                                    quad_data_in(data_cnt) :=
                                    to_nat(quad_nybble);
                                END IF;
                                    data_cnt := data_cnt +1;
                            END IF;
                        ELSIF ((HOLDNeg_pullup='1' AND QUAD='0')
                                OR QUAD='1') THEN
                            IF data_cnt > (PageSize*8-1) THEN
                            --In case of serial mode and PP,
                            -- if more than 512 bytes are sent to the device
                            -- previously latched data are discarded and last
                            -- 512 data bytes are guaranteed to be programmed
                            -- correctly within the same page.
                                IF bit_cnt = 0 THEN
                                    FOR I IN 0 TO ((PageSize-1)*BYTE - 1) LOOP
                                        Data_in(i) := Data_in(i+8);
                                    END LOOP;
                                END IF;
                                Data_in((PageSize-1)*BYTE + bit_cnt) := SIIn;
                                bit_cnt := bit_cnt + 1;
                                IF bit_cnt = 8 THEN
                                    bit_cnt := 0;
                                END IF;
                                data_cnt := data_cnt + 1;
                            ELSE
                                Data_in(data_cnt) := SIIn;
                                data_cnt := data_cnt + 1;
                                bit_cnt := 0;
                            END IF;
                        END IF;
                    END IF;

                    IF rising_edge(CSNeg_ipd) THEN
                    CASE Instruct IS
                        WHEN WREN | WRDI | BE | SE | SE4 | CLSR | RESET |
                             PPBP | PPBERS | PGSP | PGRS | ERSP | BRAC |
                             ERRS | P4E | P4E4 | PLBWR =>
                            IF ((HOLDNeg_pullup='1' AND QUAD='0')
                                OR QUAD='1') THEN
                                IF data_cnt = 0 THEN
                                    write <= '0';
                                END IF;
                            END IF;

                        WHEN WRR =>
                            IF ((HOLDNeg_pullup='1' AND QUAD='0')
                                OR QUAD='1') THEN
                                IF ((data_cnt mod 8) = 0 AND data_cnt > 0) THEN
                                    IF data_cnt = 8 THEN
                                    --If CS# is driven high after eight
                                    --cycle,only the Status Register is
                                    --written to.
                                        write <= '0';
                                        IF BAR_ACC = '0' THEN
                                            FOR i IN 0 TO 7 LOOP
                                                Status_reg1_in(i) <=
                                                                   Data_in(7-i);
                                            END LOOP;
                                        ELSIF P_ERR = '0' AND E_ERR = '0' THEN
                                            FOR i IN 0 TO 7 LOOP
                                                Bank_Addr_reg_in(i) <=
                                                                   Data_in(7-i);
                                            END LOOP;
                                        END IF;
                                    ELSIF data_cnt = 16 THEN
                                    --After the 16th cycle both the
                                    --Status and Configuration Registers
                                    --are written to.
                                        write <= '0';
                                        IF BAR_ACC = '0' THEN
                                            FOR i IN 0 TO 7 LOOP
                                                cfg_write  <= '1';
                                                FOR i IN 0 TO 7 LOOP
                                                    Status_reg1_in(i) <=
                                                                   Data_in(7-i);
                                                    Config_reg1_in(i) <=
                                                                  Data_in(15-i);
                                                END LOOP;
                                            END LOOP;
                                        ELSIF P_ERR = '0' AND E_ERR = '0' THEN
                                            FOR i IN 0 TO 7 LOOP
                                                Bank_Addr_reg_in(i) <=
                                                                   Data_in(7-i);
                                            END LOOP;
                                        END IF;
                                    END IF;
                                END IF;
                            END IF;

                        WHEN PP | PP4 | OTPP =>
                            IF ((HOLDNeg_pullup='1' AND QUAD='0') OR
                                 QUAD='1') THEN
                                IF data_cnt > 0 THEN
                                    IF (data_cnt mod 8) = 0 THEN
                                        write <= '0';
                                        FOR I IN 0 TO (PageSize-1) LOOP
                                            FOR J IN 7 DOWNTO 0 LOOP
                                                IF Data_in((i*8) + (7-j))
                                                                  /= 'X' THEN
                                                    Byte_slv(j) :=
                                                    Data_in((i*8) + (7-j));
                                                END IF;
                                            END LOOP;
                                            WByte(i) <=
                                                to_nat(Byte_slv);
                                        END LOOP;
                                        IF data_cnt > PageSize*BYTE THEN
                                            Byte_number <= PageSize-1;
                                        ELSE
                                            Byte_number <= data_cnt/8-1;
                                        END IF;
                                    END IF;
                                END IF;
                            END IF;

                        WHEN QPP | QPP4=>
                            IF data_cnt > 0 THEN
                                IF data_cnt mod 2 = 0 THEN
                                    quadpg   <= FALSE;
                                    write <= '0';
                                    FOR I IN 0 TO (PageSize-1) LOOP
                                        FOR J IN 1 DOWNTO 0 LOOP
                                            Quad_slv :=
                                            to_slv(quad_data_in((i*2) +
                                              (1-j)),4);

                                            Byte_slv(4*j+3 DOWNTO 4*j) :=
                                                Quad_slv;
                                        END LOOP;
                                        WByte(i) <= to_nat(Byte_slv);
                                    END LOOP;
                                    IF data_cnt > PageSize*2 THEN
                                        Byte_number <= PageSize-1;
                                    ELSE
                                        Byte_number <= data_cnt/2-1;
                                    END IF;
                                END IF;
                            END IF;

                        WHEN ABWR =>
                            IF ((HOLDNeg_pullup='1' AND QUAD='0') OR
                                 QUAD='1') THEN
                                IF data_cnt = 32 THEN
                                    write <= '0';
                                    FOR J IN 0 TO 31 LOOP
                                        AutoBoot_reg_in(J) <=
                                                Data_in(31-J);
                                    END LOOP;
                                END IF;
                            END IF;

                        WHEN BRWR =>
                            IF ((HOLDNeg_pullup='1' AND QUAD='0') OR
                                 QUAD='1') THEN
                                IF data_cnt = 8 THEN
                                    write <= '0';
                                    FOR J IN 0 TO 7 LOOP
                                        Bank_Addr_reg_in(J) <=
                                              Data_in(7-J);
                                    END LOOP;
                                END IF;
                            END IF;

                        WHEN ASPP =>
                            IF ((HOLDNeg_pullup='1' AND QUAD='0') OR
                                 QUAD='1') THEN
                                IF data_cnt = 16 THEN
                                    write <= '0';
                                    FOR J IN 0 TO 15 LOOP
                                        ASP_reg_in(J) <=
                                              Data_in(15-J);
                                    END LOOP;
                                END IF;
                            END IF;

                        WHEN DYBWR =>
                            IF ((HOLDNeg_pullup='1' AND QUAD='0') OR
                                 QUAD='1') THEN
                                IF data_cnt = 8 THEN
                                    write <= '0';
                                    FOR J IN 0 TO 7 LOOP
                                        DYBAR_in(J) <=
                                              Data_in(7-J);
                                    END LOOP;
                                END IF;
                            END IF;

                        WHEN PNVDLR =>
                            IF ((HOLDNeg_pullup='1' AND QUAD='0') OR
                                 QUAD='1') THEN
                                IF data_cnt = 8 THEN
                                    write <= '0';
                                    FOR J IN 0 TO 7 LOOP
                                        NVDLR_reg_in(J) <= Data_in(7-J);
                                    END LOOP;
                                END IF;
                            END IF;

                        WHEN WVDLR =>
                            IF ((HOLDNeg_pullup='1' AND QUAD='0') OR
                                 QUAD='1') THEN
                                IF data_cnt = 8 THEN
                                    write <= '0';
                                    FOR J IN 0 TO 7 LOOP
                                        VDLR_reg_in(J) <= Data_in(7-J);
                                    END LOOP;
                                END IF;
                            END IF;

                        WHEN PASSP =>
                            IF ((HOLDNeg_pullup='1' AND QUAD='0') OR
                                 QUAD='1') THEN
                                IF data_cnt = 64 THEN
                                    write <= '0';
                                    FOR J IN 1 TO 8 LOOP
                                        FOR K IN 1 TO 8 LOOP
                                            Password_reg_in(J*8-K) <=
                                                       Data_in(8*(J-1)+K-1);
                                        END LOOP;
                                    END LOOP;
                                END IF;
                            END IF;

                        WHEN PASSU =>
                            IF ((HOLDNeg_pullup='1' AND QUAD='0') OR
                                 QUAD='1') THEN
                                IF data_cnt = 64 THEN
                                    write <= '0';
                                    FOR J IN 1 TO 8 LOOP
                                        FOR K IN 1 TO 8 LOOP
                                            PASS_TEMP(J*8-K) <=
                                                       Data_in(8*(J-1)+K-1);
                                        END LOOP;
                                    END LOOP;
                                END IF;
                            END IF;

                        WHEN others =>
                            null;

                    END CASE;
                END IF;
            END CASE;
        END IF;

    END PROCESS BusCycleDecode;

    ---------------------------------------------------------------------------
    -- Timing control for the Page Program
    ---------------------------------------------------------------------------
    ProgTime : PROCESS(PSTART, PGSUSP, PGRES, RST_in, Reseted)
        VARIABLE pob      : time;
        VARIABLE elapsed  : time;
        VARIABLE start    : time;
        VARIABLE duration : time;
    BEGIN
        IF rising_edge(PSTART) AND PDONE = '1' THEN
            IF Instruct = PP OR Instruct = PP4 OR Instruct = OTPP OR
               Instruct = QPP OR Instruct = QPP4 THEN
                IF PageSize = 256 THEN
                    pob  := tdevice_PP256;
                ELSE
                    pob  := tdevice_PP512;
                END IF;
            ELSE
                pob  := tdevice_BP;
            END IF;
            elapsed := 0 ns;
            start := NOW;
            PDONE <= '0', '1' AFTER pob;
        ELSIF PGSUSP'EVENT AND PGSUSP = '1' AND PDONE /= '1' THEN
            elapsed  := NOW - start;
            duration := pob - elapsed;
            PDONE <= '0';
        ELSIF PGRES'EVENT AND PGRES = '1' AND PDONE /= '1'THEN
            start := NOW;
            PDONE <= '0', '1' AFTER duration;
        END IF;

        IF rising_edge(RST_in) THEN
            PDONE <= '1';  -- reset done, programing terminated
        ELSIF rising_edge(Reseted) THEN
            PDONE <= '1';  -- reset done, programing terminated
        END IF;

    END PROCESS ProgTime;

    ---------------------------------------------------------------------------
    -- Timing control for the Max Setup Time
    ---------------------------------------------------------------------------
    SetupTime : PROCESS(SI, SCK)
        VARIABLE start_tsu       : time;
        VARIABLE elapsed_tsu     : time;
        VARIABLE duration_tsu    : time;
    BEGIN
        IF rising_edge(SI) OR falling_edge(SI) THEN
            IF Instruct = PGSP OR Instruct = PGRS OR
               Instruct = ERSP OR Instruct = ERRS THEN
               start_tsu := NOW;
            END IF;
        END IF;

        IF rising_edge(SCK) THEN
            IF Instruct = PGSP OR Instruct = PGRS OR
               Instruct = ERSP OR Instruct = ERRS THEN
               elapsed_tsu := NOW - start_tsu;
               duration_tsu := tdevice_TSU - elapsed_tsu;
               IF (duration_tsu < 0 ns) THEN
                   REPORT "Warning!" &
                    "tSU max time violation"
                   SEVERITY WARNING;
               END IF;
            END IF;
        END IF;

    END PROCESS SetupTime;
    ---------------------------------------------------------------------------
    -- Timing control for the Write Status Register
    ---------------------------------------------------------------------------
    WriteTime : PROCESS(WSTART, RST_in)
        VARIABLE wob      : time;
    BEGIN
        IF LongTimming THEN
            wob  := tdevice_WRR;
        ELSE
            wob  := tdevice_WRR / 100;
        END IF;
        IF rising_edge(WSTART) AND WDONE = '1' THEN
            WDONE <= '0', '1' AFTER wob;
        END IF;

        IF rising_edge(RST_in) THEN
            WDONE <= '1';  -- reset done, programing terminated
        ELSIF rising_edge(Reseted) THEN
            WDONE <= '1';  -- reset done, programing terminated
        END IF;

    END PROCESS WriteTime;

    ---------------------------------------------------------------------------
    -- Timing control for the Bulk Erase
    ---------------------------------------------------------------------------
    ErsTime : PROCESS(ESTART, ESUSP, ERES, RST_in, Reseted)
        VARIABLE seo      : time;
        VARIABLE beo      : time;
        VARIABLE elapsed  : time;
        VARIABLE start    : time;
        VARIABLE duration : time;
    BEGIN
        IF LongTimming THEN
            IF UniformSec THEN
                seo := tdevice_SE256;
            ELSE
                seo := tdevice_SE64;
            END IF;
            beo := tdevice_BE;
        ELSE
            IF UniformSec THEN
                seo := tdevice_SE256 / 1000;
            ELSE
                seo := tdevice_SE64 / 100;
            END IF;
            beo := tdevice_BE / 1000;
        END IF;
        IF rising_edge(ESTART) AND EDONE = '1' THEN
            IF Instruct = BE THEN
                duration := beo;
            ELSE --Instruct = SE OR SE4 OR P4E OR P4E4
                duration := seo;
            END IF;
            elapsed := 0 ns;
            EDONE <= '0', '1' AFTER duration;
            start := NOW;
        ELSIF ESUSP'EVENT AND ESUSP = '1' AND EDONE /= '1' THEN
            elapsed  := NOW - start;
            duration := duration - elapsed;
            EDONE <= '0';
        ELSIF ERES'EVENT AND ERES = '1' AND EDONE /= '1' THEN
            start := NOW;
            EDONE <= '0', '1' AFTER duration;
        END IF;

        IF rising_edge(RST_in) THEN
            EDONE <= '1';  -- reset done, eras terminated
        ELSIF rising_edge(Reseted) THEN
            EDONE <= '1';  -- reset done, erase terminated
        END IF;

    END PROCESS ErsTime;

    CheckCEOnPowerUP :PROCESS(CSNeg_ipd)
    BEGIN
        IF (PoweredUp = '0' AND falling_edge(CSNeg_ipd)) THEN
            REPORT InstancePath & partID &
            ": Device is selected during Power Up"
            SEVERITY WARNING;
        END IF;
    END PROCESS;

    ---------------------------------------------------------------------------
    -- Main Behavior Process
    -- combinational process for next state generation
    ---------------------------------------------------------------------------
    StateGen :PROCESS(PoweredUp, write, CSNeg_ipd, RSTNeg_pullup, WDONE, PDONE,
                      ERSSUSP_out, PRGSUSP_out, EDONE, RST_out, PPBERASE_in,
                      PASSULCK_in)

    VARIABLE sect      : NATURAL RANGE 0 TO SecNum64;

    BEGIN

        IF rising_edge(PoweredUp) AND RSTNeg = '1' AND RST_out = '1' THEN
            IF ABE = '1' AND RPME /= '0' THEN
            --Autoboot is enabled and The Read Password feature is not enabled
                next_state <= AUTOBOOT;
                read_cnt    := 0;
                byte_cnt    := 1;
                read_addr   := to_nat(AutoBoot_reg(31 DOWNTO 9)&"000000000");
                start_delay := to_nat(AutoBoot_reg(8 DOWNTO 1));
                ABSD        := to_nat(AutoBoot_reg(8 DOWNTO 1));
            ELSE
                next_state <= IDLE;
            END IF;
        ELSE
            IF RST_out= '0' then
                next_state <= current_state;
            ELSIF falling_edge(write) AND Instruct = RESET THEN
                IF ABE = '1' AND RPME /= '0' THEN
                    read_cnt   := 0;
                    byte_cnt    := 1;
                    read_addr  := to_nat(AutoBoot_reg(31 DOWNTO 9)&
                                                      "000000000");
                    start_delay:= to_nat(AutoBoot_reg(8 DOWNTO 1));
                    ABSD       := to_nat(AutoBoot_reg(8 DOWNTO 1));
                    next_state <= AUTOBOOT;
                ELSE
                    next_state <= IDLE;
                END IF;
            ELSE
            CASE current_state IS
                WHEN  RESET_STATE =>
                    IF (rising_edge(RST_out) AND RSTNeg = '1') OR
                    (rising_edge(RSTNeg_pullup) AND RST_out = '1') THEN
                        IF ABE = '1' AND RPME /= '0'
                        AND RdPswdProtMode = '0' THEN
                            next_state <= AUTOBOOT;
                            read_cnt    := 0;
                            byte_cnt    := 1;
                            read_addr   := to_nat(AutoBoot_reg(31 DOWNTO 9)&
                                                               "000000000");
                            start_delay := to_nat(AutoBoot_reg(8 DOWNTO 1));
                            ABSD        := to_nat(AutoBoot_reg(8 DOWNTO 1));
                        ELSE
                            next_state <= IDLE;
                        END IF;
                    END IF;

                WHEN  IDLE =>
                    IF falling_edge(write) AND RdPswdProtMode = '0' THEN

                        IF (Instruct = WRR AND WEL = '1' AND BAR_ACC = '0') THEN
                            IF ((not(SRWD = '1' AND WPNeg_pullup = '0') AND
                                     QUAD = '0') OR QUAD = '1') THEN
                                -- can not execute if HPM is entered
                                -- or if WEL bit is zero
                                IF ((TBPROT='1' AND Config_reg1_in(5)='0') OR
                                    (TBPARM='1' AND Config_reg1_in(2)='0') OR
                                    (BPNV  ='1' AND Config_reg1_in(3)='0')) AND
                                    cfg_write = '1' THEN
                                    ASSERT cfg_write = '0'
                                    REPORT "Changing value of Configuration " &
                                           "Register OTP bit from 1 to 0 is " &
                                           "not allowed!!!"
                                    SEVERITY WARNING;
                                ELSE
                                    next_state <= WRITE_SR;
                                END IF;
                            END IF;
                        ELSIF (Instruct = PP OR Instruct = QPP OR
                                Instruct = PP4 OR Instruct = QPP4) AND
                                WEL = '1' THEN
                            ReturnSectorID(sect,Address);
                            pgm_page := Address/(PageSize+1);
                            IF (Sec_Prot(sect) = '0' AND
                                PPB_bits(sect)='1' AND DYB_bits(sect)='1') THEN
--                                IF (Instruct = QPP OR Instruct = QPP4)  AND
--                                    QPP_page(pgm_page) = '1' THEN
--                                    REPORT "WARNING:The same page must not be" &
--                                           "programmed more than once!!!"
--                                   SEVERITY WARNING;
                                    next_state <=  PAGE_PG;
--                                ELSE
--                                    next_state <=  PAGE_PG;
--                                END IF;
                            END IF;
                        ELSIF Instruct=OTPP AND WEL = '1' AND FREEZE = '0' THEN
                            IF ((((Address >= 16#10# AND Address <= 16#13#) OR
                               (Address >= 16#20# AND Address <= 16#FF#))
                               AND LOCK_BYTE1(Address/32) = '1') OR
                               ((Address >= 16#100# AND Address <= 16#1FF#)
                               AND LOCK_BYTE2((Address-16#100#)/32) = '1') OR
                               ((Address >= 16#200# AND Address <= 16#2FF#)
                               AND LOCK_BYTE3((Address-16#200#)/32) = '1') OR
                               ((Address >= 16#300# AND Address <= 16#3FF#)
                               AND LOCK_BYTE4((Address-16#300#)/32) = '1')) AND
                              (Address + Byte_number <= OTPHiAddr) THEN
                                next_state <=  OTP_PG;
                            END IF;
                        ELSIF (Instruct= SE OR Instruct= SE4) AND WEL= '1' THEN
                            ReturnSectorID(sect,Address);
                            IF UniformSec = TRUE OR
                              (TopBoot = TRUE AND sect < 510) OR
                              (BottomBoot = TRUE AND sect > 31) THEN
                                IF (Sec_Prot(sect) = '0' AND PPB_bits(sect)='1'
                                   AND DYB_bits(sect)='1') THEN
                                    next_state <=  SECTOR_ERS;
                                END IF;
                            ELSIF (TopBoot = TRUE AND sect >= 510) OR
                                    (BottomBoot = TRUE AND sect <= 31) THEN
                                IF Sec_ProtSE = 32 AND ASP_ProtSE = 32 THEN
                                --Sector erase command is applied to a 64 KB
                                --range that includes 4 KB sectors.
                                    next_state <=  SECTOR_ERS;
                                END IF;
                            END IF;
                        ELSIF (Instruct=P4E OR Instruct=P4E4) AND WEL='1' THEN
                            ReturnSectorID(sect,Address);
                            IF UniformSec = TRUE OR
                              (TopBoot = TRUE AND sect < 510) OR
                              (BottomBoot = TRUE AND sect > 31) THEN
                              --A P4E instruction applied to a sector that
                              --is larger than 4 KB will not be executed
                              --and will not set the E_ERR status.
                                REPORT "The instruction is applied to a "&
                                       "sector that is larger than 4 KB. "&
                                       "Instruction is ignored!!!"
                                SEVERITY warning;
                            ELSE
                                IF Sec_Prot(sect) = '0' AND PPB_bits(sect)='1'
                                    AND DYB_bits(sect)='1' THEN
                                    next_state <=  SECTOR_ERS;
                                END IF;
                            END IF;
                        ELSIF Instruct = BE AND WEL = '1' AND
                          (BP0='0' AND BP1='0' AND BP2='0') THEN
                            next_state <= BULK_ERS;
                        ELSIF Instruct = ABWR   AND WEL = '1' THEN
                        --Autoboot Register Write Command
                            next_state <= AUTOBOOT_PG;
                        ELSIF Instruct = BRWR THEN
                        --Bank Register Write Command
                            next_state <= IDLE;
                        ELSIF Instruct = ASPP   AND WEL = '1' THEN
                        --ASP Register Program Command
                            IF not(ASPOTPFLAG) THEN
                                next_state <= ASP_PG;
                            END IF;
                        ELSIF Instruct = PLBWR  AND WEL = '1' AND
                            RdPswdProtEnable = '0' THEN
                            next_state <= PLB_PG;
                        ELSIF Instruct = PASSP  AND WEL = '1' THEN
                            IF not(PWDMLB='0' AND PSTMLB='1') THEN
                                next_state <= PASS_PG;
                            END IF;
                        ELSIF Instruct = PASSU  AND WEL= '1' AND WIP= '0' THEN
                            next_state <= PASS_UNLOCK;
                        ELSIF Instruct = PPBP   AND WEL = '1' THEN
                            next_state <= PPB_PG;
                        ELSIF (Instruct=PPBERS AND WEL='1' AND PPBOTP='1') THEN
                            next_state <= PPB_ERS;
                        ELSIF Instruct = DYBWR  AND WEL = '1' THEN
                            next_state <= DYB_PG;
                        ELSIF Instruct = PNVDLR  AND WEL = '1' THEN
                            next_state <= NVDLR_PG;
                        ELSE
                            next_state <= IDLE;
                        END IF;
                    END IF;
                    IF falling_edge(write) AND RdPswdProtMode = '1' AND
                       WIP = '0' THEN
                        IF Instruct = PASSU THEN
                            next_state <= PASS_UNLOCK;
                        END IF;
                    END IF;

                WHEN  AUTOBOOT =>
                    IF rising_edge(CSNeg_ipd) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN WRITE_SR       =>
                    IF rising_edge(WDONE) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN PAGE_PG        =>
                    IF  PRGSUSP_out'EVENT AND PRGSUSP_out = '1' THEN
                        next_state <= PG_SUSP;
                    ELSIF rising_edge(PDONE) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN PG_SUSP      =>
                    IF falling_edge(write) THEN
                        IF Instruct = BRWR THEN
                            next_state <=  PG_SUSP;
                        ELSIF Instruct = PGRS THEN
                            next_state <=  PAGE_PG;
                        END IF;
                    ELSE
                        next_state <= PG_SUSP;
                    END IF;

                WHEN OTP_PG         =>
                    IF rising_edge(PDONE) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN BULK_ERS       =>
                    IF rising_edge(EDONE) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN SECTOR_ERS     =>
                    IF ERSSUSP_out'EVENT AND ERSSUSP_out = '1' THEN
                        next_state <= ERS_SUSP;
                    ELSIF rising_edge(EDONE) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN ERS_SUSP      =>
                    IF falling_edge(write) THEN
                        IF (Instruct = PP OR Instruct = QPP OR
                                Instruct = PP4 OR Instruct = QPP4) AND
                                WEL = '1' THEN
                            IF (PARAM_REGION = TRUE AND
                              SectorSuspend /= Address/(SecSize+1)) OR
                              (PARAM_REGION = FALSE AND
                              SectorSuspend/=Address/(SecSize+1)+30*b_act) THEN
                                ReturnSectorID(sect,Address);
                                pgm_page := Address / (PageSize+1);
                                IF PPB_bits(sect)='1' AND
                                   DYB_bits(sect)='1' THEN
                                      next_state <=  ERS_SUSP_PG;
                                END IF;
                            END IF;
                        ELSIF Instruct = BRWR THEN
                            next_state <=  ERS_SUSP;
                        ELSIF (Instruct = DYBWR AND WEL = '1') THEN
                            next_state <=  DYB_PG;
                        ELSIF Instruct = ERRS THEN
                            next_state <=  SECTOR_ERS;
                        END IF;
                    ELSE
                        next_state <= ERS_SUSP;
                    END IF;

                WHEN ERS_SUSP_PG         =>
                    IF PRGSUSP_out'EVENT AND PRGSUSP_out = '1' THEN
                        next_state <= ERS_SUSP_PG_SUSP;
                    ELSIF rising_edge(PDONE) THEN
                        next_state <= ERS_SUSP;
                    END IF;

                WHEN ERS_SUSP_PG_SUSP      =>
                    IF falling_edge(write) THEN
                        IF Instruct = BRWR THEN
                            next_state <=  ERS_SUSP_PG_SUSP;
                        ELSIF Instruct = PGRS THEN
                            next_state <=  ERS_SUSP_PG;
                        END IF;
                    ELSE
                        next_state <= ERS_SUSP_PG_SUSP;
                    END IF;

                WHEN PASS_PG        =>
                    IF rising_edge(PDONE) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN PASS_UNLOCK    =>
                    IF falling_edge(PASSULCK_in) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN PPB_PG         =>
                    IF rising_edge(PDONE) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN PPB_ERS        =>
                    IF falling_edge(PPBERASE_in) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN AUTOBOOT_PG    =>
                    IF rising_edge(PDONE) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN PLB_PG         =>
                    IF rising_edge(PDONE) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN DYB_PG         =>
                    IF rising_edge(PDONE) THEN
                        IF ES = '1' THEN
                            next_state <= ERS_SUSP;
                        ELSE
                            next_state <= IDLE;
                        END IF;
                    END IF;

                WHEN ASP_PG         =>
                    IF rising_edge(PDONE) THEN
                        next_state <= IDLE;
                    END IF;

                WHEN NVDLR_PG         =>
                    IF rising_edge(PDONE) THEN
                        next_state <= IDLE;
                    END IF;

                END CASE;
            END IF;
        END IF;

    END PROCESS StateGen;

    ReadEnable: PROCESS (read_out)
    BEGIN
        oe_z <= rising_edge(read_out) AND PoweredUp = '1';

        IF read_out'EVENT AND read_out = '0' AND PoweredUp = '1' THEN
            oe   <= TRUE, FALSE AFTER 1 ns;
        END IF;
    END PROCESS ReadEnable;
    ---------------------------------------------------------------------------
    --FSM Output generation and general funcionality
    ---------------------------------------------------------------------------
    Functional : PROCESS(write,current_state,start_autoboot,CSNeg_ipd,
                         HOLDNeg_pullup, Instruct, Address, WByte,change_addr,
                         PoweredUp, WPNeg_pullup, WDONE, PDONE, EDONE,
                         PRGSUSP_out,ERSSUSP_out, PASSACC_out, oe, oe_z)

        VARIABLE WData          : WByteType:= (OTHERS => MaxData);

        VARIABLE AddrLo         : NATURAL;
        VARIABLE AddrHi         : NATURAL;
        VARIABLE Addr           : NATURAL;
        VARIABLE Addr_tmp       : NATURAL;

        VARIABLE data_out       : std_logic_vector(7 downto 0);
        VARIABLE ident_out      : std_logic_vector(647 downto 0);

        VARIABLE ExtendedID     : NATURAL;

        VARIABLE old_bit        : std_logic_vector(7 downto 0);
        VARIABLE new_bit        : std_logic_vector(7 downto 0);
        VARIABLE old_int        : INTEGER RANGE -1 to MaxData;
        VARIABLE new_int        : INTEGER RANGE -1 to MaxData;
        VARIABLE old_pass       : std_logic_vector(63 downto 0);
        VARIABLE new_pass       : std_logic_vector(63 downto 0);
        VARIABLE wr_cnt         : NATURAL RANGE 0 TO 511;

        VARIABLE sect           : NATURAL RANGE 0 TO SecNum64;
        VARIABLE cnt            : NATURAL RANGE 0 TO 512 := 0;

        VARIABLE sec_tmp        : NATURAL RANGE 0 TO SecNum64;

    BEGIN

        -----------------------------------------------------------------------
        -- Functionality Section
        -----------------------------------------------------------------------

        IF Instruct'EVENT THEN
            read_cnt := 0;
            byte_cnt := 1;
            fast_rd  <= true;
            dual     <= false;
            rd       <= false;
            any_read <= false;
        END IF;

        IF PASSACC_out'EVENT AND PASSACC_out = '1' THEN
            WIP := '0';
            PASSACC_in <= '0';
        END IF;

        IF rising_edge(PoweredUp) THEN
            --the default condition after power-up
            --The Bank Address Register is loaded to all zeroes
            Bank_Addr_reg := (others => '0');
            --The Configuration Register FREEZE bit is cleared.
            FREEZE := '0';
            --The WEL bit is cleared.
            WEL := '0';
            --When BPNV is set to '1'. the BP2-0 bits in Status Register are
            --volatile and will be reset binary 111 after power-on reset
            IF BPNV = '1' AND FREEZE = '0' THEN
                BP0 := '1';
                BP1 := '1';
                BP2 := '1';
                BP_bits := BP2 & BP1 & BP0;
                change_BP <= '1', '0' AFTER 1 ns;
            END IF;
            --As shipped from the factory, all devices default ASP to the
            --Persistent Protection mode, with all sectors unprotected,
            --when power is applied. The device programmer or host system must
            --then choose which sector protection method to use.
            --For Persistent Protection mode, PPBLOCK defaults to "1"
            PPB_LOCK := '1';
            PPB_LOCK_temp <= '1';
            DYB_bits := (OTHERS => '1');

        END IF;

        IF falling_edge(write) AND Instruct = RESET THEN
            --The Configuration Register is set for Address mode
            Bank_Addr_reg := (others => '0');
            --P_ERR bit is cleared
            P_ERR := '0';
            --E_ERR bit is cleared
            E_ERR := '0';
            --The WEL bit is cleared.
            WEL   := '0';
            --The WIP bit is cleared.
            WIP   := '0';
            --The ES bit is cleared.
            ES    := '0';
            --The PS bit is cleared.
            PS    := '0';

            DummyBytes_act := '0';
            --When BPNV is set to '1'. the BP2-0 bits in Status
            --Register are volatile and will be reseted after
            --reset command
            IF BPNV = '1' AND FREEZE = '0' THEN
                BP0 := '1';
                BP1 := '1';
                BP2 := '1';
                BP_bits := BP2 & BP1 & BP0;
                change_BP <= '1', '0' AFTER 1 ns;
            END IF;
        END IF;

        IF change_addr'EVENT THEN
            read_addr := Address;
        END IF;

        CASE current_state IS
            WHEN IDLE          =>
                fast_rd <= true;
                rd      <= false;
                dual    <= false;
                ddr     <= false;
                ASP_ProtSE := 0;
                Sec_ProtSE := 0;
                PARAM_REGION := false;
                IF falling_edge(write) AND RdPswdProtMode = '1' THEN
                    IF Instruct = PASSU THEN
                        IF WIP = '0' THEN
                            PASSULCK_in <= '1';
                        ELSE
                            REPORT "The PASSU command cannot be accepted"&
                                   " any faster than once every 100us"
                            SEVERITY WARNING;
                        END IF;
                    ELSIF Instruct = CLSR THEN
                    --The Clear Status Register Command resets bit SR1[5]
                    --(Erase Fail Flag) and bit SR1[6] (Program Fail Flag)
                       E_ERR := '0';
                       P_ERR := '0';
                    END IF;
                END IF;
                IF BottomBoot = TRUE THEN
                    FOR J IN 31 DOWNTO 0 LOOP
                        IF (PPB_bits(J)='1' AND DYB_bits(J)='1') THEN
                            ASP_ProtSE := ASP_ProtSE + 1;
                        END IF;
                        IF (Sec_Prot(J)='0') THEN
                            Sec_ProtSE := Sec_ProtSE + 1;
                        END IF;
                    END LOOP;
                ELSIF TopBoot = TRUE THEN
                    FOR J IN 541 DOWNTO 510 LOOP
                        IF (PPB_bits(J)='1' AND DYB_bits(J)='1') THEN
                            ASP_ProtSE := ASP_ProtSE + 1;
                        END IF;
                        IF (Sec_Prot(J)='0') THEN
                            Sec_ProtSE := Sec_ProtSE + 1;
                        END IF;
                    END LOOP;
                END IF;
                IF falling_edge(write) AND RdPswdProtMode = '0' THEN
                    read_cnt := 0;
                    byte_cnt    := 1;
                    IF Instruct = WREN THEN
                        WEL := '1';
                    ELSIF Instruct = WRDI THEN
                        WEL := '0';
                    ELSIF Instruct = WRR AND WEL = '1' AND BAR_ACC = '0' THEN
                        IF (not(SRWD = '1' AND WPNeg_pullup = '0') AND
                                QUAD ='0') OR QUAD ='1' THEN
                            -- can not execute if Hardware Protection Mode
                            -- is entered or if WEL bit is zero

                            IF ((TBPROT='1' AND Config_reg1_in(5)='0') OR
                                (TBPARM='1' AND Config_reg1_in(2)='0') OR
                                (BPNV  ='1' AND Config_reg1_in(3)='0')) AND
                                 cfg_write = '1' THEN
                                P_ERR := '1';
                            ELSE
                                WSTART <= '1', '0' AFTER 5 ns;
                                WIP := '1';
                            END IF;
                        ELSE
                            WEL := '0';
                        END IF;
                    ELSIF (Instruct = PP OR Instruct = PP4) AND WEL = '1' THEN
                        ReturnSectorID(sect,Address);
                        Addr := Address;
                        IF (Sec_Prot(sect) = '0' AND
                           PPB_bits(sect)='1' AND DYB_bits(sect)='1') THEN
                            PSTART <= '1', '0' AFTER 5 ns;
                            PGSUSP  <= '0';
                            PGRES   <= '0';
                            INITIAL_CONFIG <= '1';
                            WIP := '1';
                            SA <= sect;
                            Addr := Address;
                            Addr_tmp := Address;
                            wr_cnt := Byte_number;
                            FOR I IN wr_cnt DOWNTO 0 LOOP
                                IF Viol /= '0' THEN
                                    WData(i) := -1;
                                ELSE
                                    WData(i) := WByte(i);
                                END IF;
                            END LOOP;
                        ELSE
                            P_ERR := '1';
                            WEL   := '0';
                        END IF;
                    ELSIF (Instruct = QPP OR Instruct = QPP4) AND WEL = '1' THEN
                        ReturnSectorID(sect,Address);
                        Addr := Address;
                        pgm_page := Address/(PageSize+1);
                        IF (Sec_Prot(sect)= '0' AND
                           PPB_bits(sect)='1' AND DYB_bits(sect)='1') THEN
                            PSTART <= '1', '0' AFTER 5 ns;
                            PGSUSP  <= '0';
                            PGRES   <= '0';
                            INITIAL_CONFIG <= '1';
                            WIP := '1';
                            SA <= sect;
                            Addr := Address;
                            Addr_tmp := Address;
                            wr_cnt := Byte_number;
                            FOR I IN wr_cnt DOWNTO 0 LOOP
                                IF Viol /= '0' THEN
                                    WData(i) := -1;
                                ELSE
                                    WData(i) := WByte(i);
                                END IF;
                            END LOOP;
                        ELSE
                            P_ERR := '1';
                            WEL   := '0';
                        END IF;
                    ELSIF Instruct = OTPP AND WEL = '1' THEN
                    -- As long as the FREEZE bit remains cleared to a logic '0'
                    --the OTP address space is programmable.
                        IF FREEZE = '0' THEN
                            IF ((((Address >= 16#0010# AND Address <= 16#13#)OR
                                (Address >= 16#0020# AND Address <= 16#FF#))
                            AND LOCK_BYTE1(Address/32) = '1') OR
                            ((Address >= 16#100# AND Address <= 16#1FF#)
                            AND LOCK_BYTE2((Address-16#100#)/32) = '1') OR
                            ((Address >= 16#200# AND Address <= 16#2FF#)
                            AND LOCK_BYTE3((Address-16#200#)/32) = '1') OR
                            ((Address >= 16#300# AND Address <= 16#3FF#)
                            AND LOCK_BYTE4((Address-16#300#)/32) = '1')) AND
                            (Address + Byte_number <= OTPHiAddr) THEN
                                PSTART <= '1', '0' AFTER 1 ns;
                                WIP := '1';
                                Addr := Address;
                                Addr_tmp := Address;
                                wr_cnt := Byte_number;
                                FOR I IN wr_cnt DOWNTO 0 LOOP
                                    IF Viol /= '0' THEN
                                        WData(i) := -1;
                                    ELSE
                                        WData(i) := WByte(i);
                                    END IF;
                                END LOOP;
                            ELSIF (Address < 16#0010# OR (Address > 16#0013# AND
                                Address < 16#0020#) OR Address > 16#3FF# ) THEN
                                P_ERR := '1';
                                WEL   := '0';
                                IF Address < 16#0020# THEN
                                    ASSERT false
                                        REPORT "Given  address is in" &
                                            "reserved address range"
                                        SEVERITY warning;
                                ELSIF Address > 16#3FF# THEN
                                    ASSERT false
                                        REPORT "Given  address is out of" &
                                            "OTP address range"
                                        SEVERITY warning;
                                END IF;
                            ELSE
                                WEL   := '0';
                                P_ERR := '1';
                            END IF;
                        ELSE
                            WEL   := '0';
                            P_ERR := '1';
                        END IF;
                    ELSIF (Instruct = SE OR Instruct = SE4) AND WEL = '1' THEN
                        ReturnSectorID(sect,Address);
                        IF UniformSec = TRUE OR
                          (TopBoot = TRUE AND sect < 510) OR
                          (BottomBoot = TRUE AND sect > 31) THEN
                            SectorSuspend <= sect;
                            PARAM_REGION := FALSE;
                            IF (Sec_Prot(sect) = '0' AND
                                PPB_bits(sect)='1' AND DYB_bits(sect)='1') THEN
                                ESTART <= '1', '0' AFTER 5 ns;
                                ESUSP  <= '0';
                                ERES   <= '0';
                                INITIAL_CONFIG <= '1';
                                WIP  := '1';
                                Addr := Address;
                            ELSE
                                E_ERR := '1';
                                WEL   := '0';
                            END IF;
                        ELSIF (TopBoot = TRUE AND sect >= 510) OR
                              (BottomBoot = TRUE AND sect <= 31) THEN
                            IF Sec_ProtSE = 32 AND ASP_ProtSE = 32 THEN
                            --Sector erase command is applied to a 64 KB range
                            --that includes 4 KB sectors
                                IF TopBoot = TRUE THEN
                                    SectorSuspend <= 510 + (541 - sect)/16;
                                ELSE
                                    SectorSuspend <= sect/16;
                                END IF;
                                PARAM_REGION := TRUE;
                                ESTART <= '1', '0' AFTER 5 ns;
                                ESUSP  <= '0';
                                ERES   <= '0';
                                INITIAL_CONFIG <= '1';
                                WIP  := '1';
                                Addr := Address;
                            ELSE
                                E_ERR := '1';
                                WEL   := '0';
                            END IF;
                        END IF;
                    ELSIF (Instruct = P4E OR Instruct = P4E4) AND WEL = '1' THEN
                        ReturnSectorID(sect,Address);
                        IF UniformSec = TRUE OR
                          (TopBoot = TRUE AND sect < 510) OR
                          (BottomBoot = TRUE AND sect > 31) THEN
                            WEL := '0';
                        ELSE
                            IF (Sec_Prot(sect) = '0' AND
                                PPB_bits(sect)='1' AND DYB_bits(sect)='1') THEN
                                --A P4E instruction applied to a sector
                                --that has been Write Protected through the
                                --Block Protect Bits or ASP will not be
                                --executed and will set the E_ERR status
                                ESTART <= '1', '0' AFTER 5 ns;
                                ESUSP  <= '0';
                                ERES   <= '0';
                                INITIAL_CONFIG <= '1';
                                WIP  := '1';
                                Addr := Address;
                            ELSE
                                E_ERR := '1';
                                WEL   := '0';
                            END IF;
                        END IF;
                    ELSIF Instruct = BE AND WEL = '1' THEN
                        IF (BP0='0' AND BP1='0' AND BP2='0') THEN
                            ESTART <= '1', '0' AFTER 5 ns;
                            ESUSP  <= '0';
                            ERES   <= '0';
                            INITIAL_CONFIG <= '1';
                            WIP := '1';
                        ELSE
                        --The Bulk Erase command will not set E_ERR if a
                        --protected sector is found during the command
                        --execution.
                            WEL   := '0';
                        END IF;
                    ELSIF Instruct = PASSP AND WEL = '1' THEN
                        IF not(PWDMLB='0' AND PSTMLB='1') THEN
                            PSTART <= '1', '0' AFTER 5 ns;
                            WIP := '1';
                        ELSE
                            REPORT "Password programming is not allowed" &
                                   " in Password Protection Mode."
                            SEVERITY warning;
                        END IF;
                    ELSIF Instruct = PASSU  AND WEL = '1' THEN
                        PASSULCK_in <= '1';
                    ELSIF Instruct = BRWR THEN
                        Bank_Addr_reg(7) := Bank_Addr_reg_in(7);
                        Bank_Addr_reg(0) := Bank_Addr_reg_in(0);
                        IF Bank_Addr_reg_in(1) = '1' THEN
                            REPORT "WARNING: Changing values of Bank Address" &
                                   " Register BA25 is not allowed!!!"
                            SEVERITY warning;
                        END IF;
                    ELSIF Instruct = WRR AND BAR_ACC = '1' THEN
                        IF (P_ERR = '0' AND E_ERR = '0') THEN
                            Bank_Addr_reg(0) := Bank_Addr_reg_in(0);
                            IF Bank_Addr_reg_in(1) = '1' THEN
                                REPORT "WARNING: Changing values of Bank " &
                                       "Address Register BA25 is not allowed!!!"
                                SEVERITY warning;
                            END IF;
                        END IF;
                    ELSIF Instruct = ASPP AND WEL = '1' THEN
                        IF not(ASPOTPFLAG) THEN
                            PSTART <= '1', '0' AFTER 5 ns;
                            WIP := '1';
                        ELSE
                            WEL := '0';
                            P_ERR := '1';
                            REPORT "Once the Protection Mode is selected," &
                                   "no further changes to the ASP register" &
                                   "is allowed."
                            SEVERITY warning;
                        END IF;
                    ELSIF Instruct = ABWR AND WEL = '1' THEN
                        PSTART <= '1', '0' AFTER 5 ns;
                        WIP := '1';
                    ELSIF Instruct = PPBP AND WEL = '1' THEN
                        ReturnSectorID(sect,Address);
                        Addr := Address;
                        pgm_page := Address/(PageSize+1);
                        PSTART <= '1', '0' AFTER 5 ns;
                        WIP := '1';
                    ELSIF Instruct = PPBERS AND WEL = '1' THEN
                        IF PPBOTP = '1' THEN
                            PPBERASE_in <= '1';
                            WIP := '1';
                        ELSE
                            E_ERR := '1';
                        END IF;
                    ELSIF Instruct = PLBWR  AND WEL = '1' AND
                        RdPswdProtEnable = '0' THEN
                        PSTART <= '1', '0' AFTER 5 ns;
                        WIP := '1';
                    ELSIF Instruct = DYBWR  AND WEL = '1' THEN
                        ReturnSectorID(sect,Address);
                        Addr := Address;
                        pgm_page := Address/(PageSize+1);
                        PSTART <= '1', '0' AFTER 5 ns;
                        WIP := '1';
                    ELSIF Instruct = PNVDLR  AND WEL = '1' THEN
                        PSTART <= '1', '0' AFTER 5 ns;
                        WIP := '1';
                    ELSIF Instruct = WVDLR  AND WEL = '1' THEN
                        VDLR_reg := VDLR_reg_in;
                        WEL := '0';
                    ELSIF Instruct = CLSR THEN
                    --The Clear Status Register Command resets bit SR1[5]
                    --(Erase Fail Flag) and bit SR1[6] (Program Fail Flag)
                       E_ERR := '0';
                       P_ERR := '0';
                    END IF;

                    IF Instruct = BRAC AND P_ERR = '0' AND E_ERR = '0' THEN
                        BAR_ACC <= '1';
                    ELSE
                        BAR_ACC <= '0';
                    END IF;
                ELSIF oe_z THEN
                    IF Instruct = READ OR Instruct = RD4 OR
                       Instruct = RES  OR Instruct = DLPRD THEN
                        fast_rd <= false;
                        rd      <= true;
                        dual    <= false;
                        ddr     <= false;
                    ELSIF Instruct = DDRFR OR Instruct = DDRFR4 THEN
                        fast_rd <= false;
                        rd      <= false;
                        dual    <= false;
                        ddr     <= true;
                    ELSIF Instruct = DDRDIOR OR Instruct = DDRDIOR4 THEN
                        fast_rd <= false;
                        rd      <= false;
                        dual    <= true;
                        ddr     <= true;
                    ELSIF Instruct = DOR OR Instruct=DOR4 OR
                          Instruct = DIOR OR Instruct = DIOR4 OR
                          Instruct = QOR OR Instruct=QOR4 OR
                          Instruct = QIOR OR Instruct= QIOR4 THEN
                        fast_rd <= false;
                        rd      <= false;
                        dual    <= true;
                        ddr     <= false;
                    ELSIF Instruct = DDRQIOR OR Instruct = DDRQIOR4 THEN
                        fast_rd <= false;
                        rd      <= false;
                        dual    <= true;
                        ddr     <= true;
                    ELSE
                        fast_rd <= true;
                        rd      <= false;
                        dual    <= false;
                        ddr     <= false;
                    END IF;
                    HOLDNegOut_zd <= 'Z';
                    WPNegOut_zd   <= 'Z';
                    SOut_zd       <= 'Z';
                    SIOut_zd      <= 'Z';
                ELSIF oe THEN
                    any_read <= true;
                    IF Instruct = RDSR THEN
                        --Read Status Register 1
                        SOut_zd <= Status_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= Status_reg2(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= Config_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDCR THEN
                        --Read ECC Register
                        SOut_zd <= ECCSR(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = READ OR Instruct = RD4 OR
                          Instruct = FSTRD OR Instruct = FSTRD4 OR
                          Instruct = DDRFR OR Instruct = DDRFR4 THEN
                        --Read Memory array
                        IF Instruct = READ OR Instruct = RD4 THEN
                            fast_rd <= false;
                            rd      <= true;
                            dual    <= false;
                            ddr     <= false;
                        ELSIF Instruct = DDRFR OR Instruct = DDRFR4 THEN
                            fast_rd <= false;
                            rd      <= false;
                            dual    <= false;
                            ddr     <= true;
                        ELSE
                            fast_rd <= true;
                            rd      <= false;
                            dual    <= false;
                            ddr     <= false;
                        END IF;
                        IF bus_cycle_state = DUMMY_BYTES OR
                           DummyBytes_act='1' THEN
                            DummyBytes_act := '0';
                            IF (Instruct = DDRFR OR Instruct = DDRFR4) THEN
                                data_out := VDLR_reg;
                                SOut_zd  <= data_out(7-read_cnt);
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 8 THEN
                                    read_cnt := 0;
                                END IF;
                            END IF;
                        ELSE
                            read_addr_tmp := read_addr;
                            SecAddr  := read_addr/(SecSize+1);
                            Sec_addr := read_addr - SecAddr*(SecSize+1);
                            SecAddr  := ReturnSectorIDRdPswdMd(TBPROT);
                            read_addr := Sec_addr + SecAddr*(SecSize+1);
                            IF RdPswdProtMode = '0' THEN
                                read_addr := read_addr_tmp;
                            END IF;
                            IF Mem(read_addr) /= -1 THEN
                                data_out := to_slv(Mem(read_addr),8);
                                SOut_zd <= data_out(7-read_cnt);
                            ELSE
                                SOut_zd <= 'U';
                            END IF;
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                                IF read_addr = AddrRANGE THEN
                                    read_addr := 0;
                                ELSE
                                    read_addr := read_addr + 1;
                                END IF;
                            END IF;
                        END IF;
                    ELSIF Instruct = DOR OR Instruct=DOR4 OR
                          Instruct = DIOR OR Instruct = DIOR4 OR
                          Instruct = DDRDIOR OR Instruct = DDRDIOR4 THEN
                        --Read Memory array
                        IF Instruct = DDRDIOR OR Instruct = DDRDIOR4 THEN
                            fast_rd <= false;
                            rd      <= false;
                            dual    <= true;
                            ddr     <= true;
                        ELSE
                            fast_rd <= false;
                            rd      <= false;
                            dual    <= true;
                            ddr     <= false;
                        END IF;
                        IF bus_cycle_state = DUMMY_BYTES
                        OR DummyBytes_act = '1' THEN
                            DummyBytes_act := '0';
                            IF (Instruct = DDRDIOR OR Instruct = DDRDIOR4) THEN
                                data_out := VDLR_reg;
                                SOut_zd  <= data_out(7-read_cnt);
                                SIOut_zd <= data_out(7-read_cnt);
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 8 THEN
                                    read_cnt := 0;
                                END IF;
                            END IF;
                        ELSE
                            read_addr_tmp := read_addr;
                            SecAddr := read_addr/(SecSize+1);
                            Sec_addr := read_addr - SecAddr*(SecSize+1);
                            SecAddr := ReturnSectorIDRdPswdMd(TBPROT);
                            read_addr := Sec_addr + SecAddr*(SecSize+1);
                            IF RdPswdProtMode = '0' THEN
                                read_addr := read_addr_tmp;
                            END IF;
                            data_out := to_slv(Mem(read_addr),8);
                            SOut_zd  <= data_out(7-2*read_cnt);
                            SIOut_zd <= data_out(6-2*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 4 THEN
                                read_cnt := 0;
                                IF read_addr = AddrRANGE THEN
                                    read_addr := 0;
                                ELSE
                                    read_addr := read_addr + 1;
                                END IF;
                            END IF;
                        END IF;
                    ELSIF (Instruct = QOR OR Instruct=QOR4 OR
                           Instruct = QIOR OR Instruct= QIOR4 OR
                           Instruct = DDRQIOR OR Instruct= DDRQIOR4)
                           AND QUAD = '1' THEN
                        --Read Memory array
                        IF Instruct = DDRQIOR OR Instruct = DDRQIOR4 THEN
                            fast_rd <= false;
                            rd      <= false;
                            dual    <= true;
                            ddr     <= true;
                        ELSE
                            fast_rd <= false;
                            rd      <= false;
                            dual    <= true;
                            ddr     <= false;
                        END IF;
                                                                                                                                                                     
                        IF bus_cycle_state=DUMMY_BYTES OR DummyBytes_act='1' THEN
                            DummyBytes_act := '0';
                            IF Instruct = DDRQIOR OR Instruct = DDRQIOR4 THEN
                                data_out := VDLR_reg;
                                HOLDNegOut_zd <= data_out(7-read_cnt);
                                WPNegOut_zd   <= data_out(7-read_cnt);
                                SOut_zd       <= data_out(7-read_cnt);
                                SIOut_zd      <= data_out(7-read_cnt);
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 8 THEN
                                    read_cnt := 0;
                                END IF;
                            END IF;
                        ELSE
                            read_addr_tmp := read_addr;
                            SecAddr := read_addr/(SecSize+1);
                            Sec_addr := read_addr - SecAddr*(SecSize+1);
                            SecAddr := ReturnSectorIDRdPswdMd(TBPROT);
                            read_addr := Sec_addr + SecAddr*(SecSize+1);
                            IF RdPswdProtMode = '0' THEN
                                read_addr := read_addr_tmp;
                            END IF;

                            data_out := to_slv(Mem(read_addr),8);
                            HOLDNegOut_zd   <= data_out(7-4*read_cnt);
                            WPNegOut_zd     <= data_out(6-4*read_cnt);
                            SOut_zd         <= data_out(5-4*read_cnt);
                            SIOut_zd        <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                                IF read_addr = AddrRANGE THEN
                                    read_addr := 0;
                                ELSE
                                    read_addr := read_addr + 1;
                                END IF;
                            END IF;
                        END IF;
                    ELSIF Instruct = OTPR  THEN
                        IF (read_addr>=OTPLoAddr) AND
                           (read_addr<=OTPHiAddr) AND RdPswdProtMode = '0' THEN
                            --Read OTP Memory array
                            fast_rd <= true;
                            rd      <= false;
                            data_out := to_slv(OTPMem(read_addr),8);
                            SOut_zd <= data_out(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                                read_addr := read_addr + 1;
                            END IF;
                        ELSIF (read_addr > OTPHiAddr)
                        OR RdPswdProtMode = '1' THEN
                        --OTP Read operation will not wrap to the
                        --starting address after the OTP address is at
                        --its maximum or Read Password Protection Mode
                        --is selected; instead, the data beyond the
                        --maximum OTP address will be undefined.
                            SOut_zd <= 'U';
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        END IF;
                    ELSIF Instruct = REMS THEN
                        --Read Manufacturer and Device ID
                        IF read_addr MOD 2 = 0 THEN
                            data_out := to_slv(Manuf_ID,8);
                            SOut_zd <= data_out(7 - read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                                read_addr := read_addr + 1;
                            END IF;
                        ELSE
                            data_out := to_slv(DeviceID,8);
                            SOut_zd <= data_out(7 - read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                                read_addr := 0;
                            END IF;
                        END IF;
                    ELSIF Instruct = RDID THEN
                        IF UniformSec THEN
                            ExtendedID := ExtendedID256;
                        ELSE
                            ExtendedID := ExtendedID64;
                        END IF;
                        ident_out := CFI_array_tmp;
                        IF read_cnt < 648 THEN
                            SOut_zd <= ident_out(647-read_cnt);
                            read_cnt  := read_cnt + 1;
                        ELSE
                        --Continued shifting of output beyond the end of
                        --the defined ID-CFI address space will provide
                        --undefined data.
                            SOut_zd <= 'U';
                        END IF;
                    ELSIF Instruct = RES THEN
                        fast_rd <= false;
                        rd      <= true;
                        dual    <= false;
                        ddr     <= false;
                        data_out := to_slv(ESignature,8);
                        SOut_zd <= data_out(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = DLPRD THEN
                        fast_rd <= false;
                        rd      <= true;
                        dual    <= false;
                        ddr     <= false;
                        SOut_zd <= VDLR_reg(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = ABRD THEN
                        --Read AutoBoot register
                        fast_rd <= true;
                        rd      <= false;
                        dual    <= false;
                        ddr     <= false;
                        SOut_zd <= AutoBoot_reg_in(31-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 32 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = BRRD THEN
                        --Read Bank Address Register
                        fast_rd <= true;
                        rd      <= false;
                        dual    <= false;
                        ddr     <= false;
                        SOut_zd <= Bank_Addr_reg(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = ASPRD THEN
                        --Read ASP Register
                        fast_rd <= true;
                        rd      <= false;
                        dual    <= false;
                        ddr     <= false;
                        SOut_zd <= ASP_reg(15-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 16 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = PASSRD THEN
                        --Read Password Register
                        IF not (PWDMLB='0' AND PSTMLB='1') THEN
                            fast_rd <= true;
                            rd      <= false;
                            dual    <= false;
                            ddr     <= false;
                            SOut_zd <= Password_reg((8*byte_cnt-1)-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                                byte_cnt := byte_cnt + 1;
                                IF byte_cnt = 9 THEN
                                   byte_cnt := 1;
                                END IF;
                            END IF;
                        ELSE
                            SOut_zd <= 'U';
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 64 THEN
                                read_cnt := 0;
                            END IF;
                            IF read_cnt = 0 THEN
                                ASSERT false
                                REPORT "Verification of password is not " &
                                       " allowed in Password Protection Mode."
                                SEVERITY warning;
                            END IF;
                        END IF;
                    ELSIF Instruct = PLBRD THEN
                        --Read PPB Lock Register
                        fast_rd <= true;
                        rd      <= false;
                        dual    <= false;
                        ddr     <= false;
                        SOut_zd <= PPBL(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = DYBRD THEN
                        --Read DYB Access Register
                        ReturnSectorID(sect,Address);
                        fast_rd <= true;
                        rd      <= false;
                        dual    <= false;
                        ddr     <= false;
                        DYBAR(7 downto 0) := "UUUUUUUU";
                        IF RdPswdProtMode = '0' THEN
                            IF DYB_bits(sect) = '1' THEN
                                DYBAR(7 downto 0) := "11111111";
                            ELSE
                                DYBAR(7 downto 0) := "00000000";
                            END IF;
                        END IF;
                        SOut_zd <= DYBAR(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = PPBRD THEN
                        --Read PPB Access Register
                        ReturnSectorID(sect,Address);
                        fast_rd <= true;
                        rd      <= false;
                        dual    <= false;
                        ddr     <= false;
                        PPBAR(7 downto 0) := "UUUUUUUU";
                        IF RdPswdProtMode = '0' THEN
                            IF PPB_bits(sect) = '1' THEN
                                PPBAR(7 downto 0) := "11111111";
                            ELSE
                                PPBAR(7 downto 0) := "00000000";
                            END IF;
                        END IF;
                        SOut_zd <= PPBAR(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                END IF;

            WHEN AUTOBOOT       =>
                IF start_autoboot = '1' THEN
                    IF (oe) THEN
                        any_read <= true;
                        IF QUAD = '1' THEN
                            IF ABSD > 0 THEN      --If ABSD > 0,
                                fast_rd <= false; --max SCK frequency is 104MHz
                                rd      <= false;
                                dual    <= true;
                                ddr     <= false;
                            ELSE -- If ABSD = 0, max SCK frequency is 50 MHz
                                fast_rd <= false;
                                rd      <= true;
                                dual    <= false;
                                ddr     <= false;
                            END IF;
                            data_out := to_slv(Mem(read_addr),8);
                            HOLDNegOut_zd   <= data_out(7-4*read_cnt);
                            WPNegOut_zd     <= data_out(6-4*read_cnt);
                            SOut_zd         <= data_out(5-4*read_cnt);
                            SIOut_zd        <= data_out(4-4*read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 2 THEN
                                read_cnt := 0;
                                read_addr := read_addr + 1;
                            END IF;
                        ELSE
                            IF ABSD > 0 THEN      --If ABSD > 0,
                                fast_rd <= true; --max SCK frequency is 133MHz
                                rd      <= false;
                                dual    <= false;
                                ddr     <= false;
                            ELSE -- If ABSD = 0, max SCK frequency is 50 MHz
                                fast_rd <= false;
                                rd      <= true;
                                dual    <= false;
                                ddr     <= false;
                            END IF;
                            data_out := to_slv(Mem(read_addr),8);
                            SOut_zd <= data_out(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                                read_addr := read_addr + 1;
                            END IF;
                       END IF;
                    ELSIF oe_z THEN
                       IF QUAD = '1' THEN
                           IF ABSD > 0 THEN      --If ABSD > 0,
                               fast_rd <= false; --max SCK frequency is 104MHz
                               rd      <= false;
                               dual    <= true;
                               ddr     <= false;
                           ELSE -- If ABSD = 0, max SCK frequency is 50 MHz
                               fast_rd <= false;
                               rd      <= true;
                               dual    <= false;
                               ddr     <= false;
                           END IF;
                       ELSE
                           IF ABSD > 0 THEN      --If ABSD > 0,
                               fast_rd <= true; --max SCK frequency is 133MHz
                               rd      <= false;
                               dual    <= false;
                               ddr     <= false;
                           ELSE -- If ABSD = 0, max SCK frequency is 50 MHz
                               fast_rd <= false;
                               rd      <= true;
                               dual    <= false;
                               ddr     <= false;
                           END IF;
                       END IF;
                       HOLDNegOut_zd <= 'Z';
                       WPNegOut_zd   <= 'Z';
                       SOut_zd       <= 'Z';
                       SIOut_zd      <= 'Z';
                    END IF;
                END IF;

            WHEN WRITE_SR       =>
                fast_rd <= true;
                rd      <= false;
                dual    <= false;
                ddr     <= false;
                IF oe THEN
                    any_read <= true;
                    IF Instruct = RDSR THEN
                        --Read Status Register 1
                        SOut_zd <= Status_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= Status_reg2(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= Config_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                ELSIF oe_z THEN
                    HOLDNegOut_zd <= 'Z';
                    WPNegOut_zd   <= 'Z';
                    SOut_zd       <= 'Z';
                    SIOut_zd      <= 'Z';
                END IF;

                IF WDONE = '1' THEN
                    WIP  := '0';
                    WEL  := '0';
                    SRWD := Status_reg1_in(7);--MSB first

                    IF FREEZE='0' THEN
                    --The Freeze Bit, when set to 1, locks the current
                    --state of the BP2-0 bits in Status Register,
                    --the TBPROT and TBPARM bits in the Config Register
                    --As long as the FREEZE bit remains cleared to logic
                    --'0', the other bits of the Configuration register
                    --including FREEZE are writeable.
                        BP2  := Status_reg1_in(4);
                        BP1  := Status_reg1_in(3);
                        BP0  := Status_reg1_in(2);

                        BP_bits := BP2 & BP1 & BP0;

                        IF TBPROT = '0' AND INITIAL_CONFIG = '0' THEN
                            TBPROT  := Config_reg1_in(5);
                        END IF;

                        IF (TBPARM = '0' AND INITIAL_CONFIG = '0' AND
                            TimingModel(16) = '0') THEN
                            TBPARM  := Config_reg1_in(2);
                            change_TBPARM <= '1', '0' AFTER 1 ns;
                        END IF;

                        change_BP <= '1', '0' AFTER 1 ns;

                        LC1     := Config_reg1_in(7);
                        LC0     := Config_reg1_in(6);
                        QUAD    := Config_reg1_in(1);

                        IF FREEZE = '0' THEN
                            FREEZE    := Config_reg1_in(0);
                        END IF;

                        IF BPNV = '0' THEN
                            BPNV    := Config_reg1_in(3);
                        END IF;
                    END IF;
                END IF;

            WHEN PAGE_PG        =>
                fast_rd <= true;
                rd      <= false;
                dual    <= false;
                ddr     <= false;
                IF oe THEN
                    any_read <= true;
                    IF Instruct = RDSR THEN
                        --Read Status Register 1
                        SOut_zd <= Status_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= Status_reg2(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= Config_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                ELSIF oe_z THEN
                    HOLDNegOut_zd <= 'Z';
                    WPNegOut_zd   <= 'Z';
                    SOut_zd       <= 'Z';
                    SIOut_zd      <= 'Z';
                END IF;

                IF falling_edge(PDONE) THEN
--                    IF (Instruct = QPP OR Instruct = QPP4) THEN
--                        QPP_page(pgm_page) := '1';
--                    END IF;

                    ADDRHILO_PG(AddrLo, AddrHi, Addr);
                    cnt := 0;

                    FOR i IN 0 TO wr_cnt LOOP
                        new_int := WData(i);
                        old_int := Mem(Addr + i - cnt);
                        IF new_int > -1 THEN
                            new_bit := to_slv(new_int,8);
                            IF old_int > -1 THEN
                                old_bit := to_slv(old_int,8);
                                FOR j IN 0 TO 7 LOOP
                                    IF old_bit(j) = '0' THEN
                                        new_bit(j) := '0';
                                    END IF;
                                END LOOP;
                                new_int := to_nat(new_bit);
                            END IF;
                            WData(i) := new_int;
                        ELSE
                            WData(i) := -1;
                        END IF;

                        Mem(Addr + i - cnt) :=  -1;

                        IF (Addr + i) = AddrHi THEN
                            Addr := AddrLo;
                            cnt := i + 1;
                        END IF;
                    END LOOP;
                    cnt :=0;
                END IF;

                IF PDONE = '1' THEN
                    WIP := '0';
                    WEL := '0';
                    FOR i IN 0 TO wr_cnt LOOP
                        Mem(Addr_tmp + i - cnt) := WData(i);
                        IF (Addr_tmp + i) = AddrHi THEN
                            Addr_tmp := AddrLo;
                            cnt := i + 1;
                        END IF;
                    END LOOP;
                ELSIF Instruct = PGSP AND PRGSUSP_in = '0' THEN
                    IF RES_TO_SUSP_MIN_TIME = '0' THEN
                        PGSUSP <= '1', '0' AFTER 1 ns;
                        PRGSUSP_in <= '1';
                        ASSERT RES_TO_SUSP_TYP_TIME = '0'
                        REPORT "Typical periods are needed for " &
                               "Program to progress to completion"
                        SEVERITY warning;
                    ELSE
                        ASSERT FALSE
                        REPORT "Minimum for tPRS is not satisfied! " &
                               "PGSP command is ignored"
                        SEVERITY warning;
                    END IF;
                END IF;

            WHEN PG_SUSP      =>
                fast_rd <= true;
                rd      <= false;
                dual    <= false;
                ddr     <= false;
                IF PRGSUSP_out = '1' AND PRGSUSP_in = '1' THEN
                    PRGSUSP_in <= '0';
                    --The RDY/BSY bit in the Status Register will indicate that
                    --the device is ready for another operation.
                    WIP := '0';
                    --The Program Suspend (PS) bit in the Status Register will
                    --be set to the logical “1” state to indicate that the
                    --program operation has been suspended.
                    PS := '1';
                END IF;

                IF oe THEN
                    any_read <= true;
                    IF Instruct = RDSR THEN
                        --Read Status Register 1
                        SOut_zd <= Status_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= Status_reg2(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= Config_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = BRRD THEN
                        --Read Bank Address Register
                        fast_rd <= true;
                        rd      <= false;
                        dual    <= false;
                        ddr     <= false;
                        SOut_zd <= Bank_Addr_reg(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    --Read Array Operations
                    ELSIF Instruct = READ OR Instruct = RD4 OR
                          Instruct = FSTRD OR Instruct = FSTRD4 OR
                          Instruct = DDRFR OR Instruct = DDRFR4 THEN
                        --Read Memory array
                        IF Instruct = READ OR Instruct = RD4 THEN
                            fast_rd <= false;
                            rd      <= true;
                            dual    <= false;
                            ddr     <= false;
                        ELSIF Instruct = DDRFR OR Instruct = DDRFR4 THEN
                            fast_rd <= false;
                            rd      <= false;
                            dual    <= false;
                            ddr     <= true;
                        ELSE
                            fast_rd <= true;
                            rd      <= false;
                            dual    <= false;
                            ddr     <= false;
                        END IF;

                        IF bus_cycle_state = DUMMY_BYTES
                        OR DummyBytes_act = '1' THEN
                            DummyBytes_act := '0';
                            IF (Instruct=DDRFR OR Instruct=DDRFR4) THEN
                                -- Data Learning Pattern (DLP) is
                                -- enabled, Optional DLP
                                data_out:= VDLR_reg;
                                SOut_zd <=data_out(7-read_cnt);
                                read_cnt:=read_cnt + 1;
                                IF read_cnt = 8 THEN
                                    read_cnt := 0;
                                END IF;
                            END IF;
                        ELSE
                            IF pgm_page /= read_addr/(PageSize+1) THEN
                                data_out := to_slv(Mem(read_addr),8);
                                SOut_zd <= data_out(7-read_cnt);
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 8 THEN
                                    read_cnt := 0;
                                    IF read_addr = AddrRANGE THEN
                                        read_addr := 0;
                                    ELSE
                                        read_addr := read_addr + 1;
                                    END IF;
                                END IF;
                            ELSE
                                SOut_zd <= 'U';
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 8 THEN
                                    read_cnt := 0;
                                    IF read_addr = AddrRANGE THEN
                                        read_addr := 0;
                                    ELSE
                                        read_addr := read_addr + 1;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    ELSIF Instruct =DOR OR Instruct=DOR4 OR
                          Instruct = DIOR OR Instruct = DIOR4 OR
                          Instruct = DDRDIOR OR Instruct = DDRDIOR4 THEN
                        --Read Memory array
                        IF Instruct = DDRDIOR OR Instruct = DDRDIOR4 THEN
                            fast_rd <= false;
                            rd      <= false;
                            dual    <= true;
                            ddr     <= true;
                        ELSE
                            fast_rd <= false;
                            rd      <= false;
                            dual    <= true;
                            ddr     <= false;
                        END IF;
                        IF bus_cycle_state = DUMMY_BYTES
                        OR DummyBytes_act = '1' THEN
                            DummyBytes_act := '0';
                            data_out:=VDLR_reg;
                            SOut_zd <=data_out(7-read_cnt);
                            SIOut_zd<=data_out(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        ELSE
                            IF  pgm_page /= read_addr/(PageSize+1) THEN
                                data_out := to_slv(Mem(read_addr),8);
                                SOut_zd  <= data_out(7-2*read_cnt);
                                SIOut_zd <= data_out(6-2*read_cnt);
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 4 THEN
                                    read_cnt := 0;
                                    IF read_addr = AddrRANGE THEN
                                        read_addr := 0;
                                    ELSE
                                        read_addr := read_addr + 1;
                                    END IF;
                                END IF;
                            ELSE
                                SOut_zd  <= 'U';
                                SIOut_zd <= 'U';
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 4 THEN
                                    read_cnt := 0;
                                    IF read_addr = AddrRANGE THEN
                                        read_addr := 0;
                                    ELSE
                                        read_addr := read_addr + 1;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    ELSIF (Instruct = QOR OR Instruct=QOR4 OR
                           Instruct = QIOR OR Instruct= QIOR4 OR
                           Instruct = DDRQIOR OR Instruct= DDRQIOR4)
                           AND QUAD = '1' THEN
                        --Read Memory array
                        IF Instruct = DDRQIOR OR Instruct = DDRQIOR4 THEN
                            fast_rd <= false;
                            rd      <= false;
                            dual    <= true;
                            ddr     <= true;
                        ELSE
                            fast_rd <= false;
                            rd      <= false;
                            dual    <= true;
                            ddr     <= false;
                        END IF;
                        IF bus_cycle_state = DUMMY_BYTES
                        OR DummyBytes_act = '1' THEN
                            DummyBytes_act := '0';
                            data_out := VDLR_reg;
                            HOLDNegOut_zd <= data_out(7-read_cnt);
                            WPNegOut_zd   <= data_out(7-read_cnt);
                            SOut_zd       <= data_out(7-read_cnt);
                            SIOut_zd      <= data_out(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        ELSE
                            IF  pgm_page /= read_addr/(PageSize+1)  THEN
                                data_out := to_slv(Mem(read_addr),8);
                                HOLDNegOut_zd   <= data_out(7-4*read_cnt);
                                WPNegOut_zd     <= data_out(6-4*read_cnt);
                                SOut_zd         <= data_out(5-4*read_cnt);
                                SIOut_zd        <= data_out(4-4*read_cnt);
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 2 THEN
                                    read_cnt := 0;
                                    IF read_addr = AddrRANGE THEN
                                        read_addr := 0;
                                    ELSE
                                        read_addr := read_addr + 1;
                                    END IF;
                                END IF;
                            ELSE
                                HOLDNegOut_zd   <= 'U';
                                WPNegOut_zd     <= 'U';
                                SOut_zd         <= 'U';
                                SIOut_zd        <= 'U';
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 2 THEN
                                    read_cnt := 0;
                                    IF read_addr = AddrRANGE THEN
                                        read_addr := 0;
                                    ELSE
                                        read_addr := read_addr + 1;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                ELSIF oe_z THEN
                    IF Instruct = READ OR Instruct = RD4 THEN
                        fast_rd <= false;
                        rd      <= true;
                        dual    <= false;
                        ddr     <= false;
                    ELSIF Instruct = DDRFR OR Instruct = DDRFR4 THEN
                        fast_rd <= false;
                        rd      <= false;
                        dual    <= false;
                        ddr     <= true;
                    ELSIF Instruct = DDRDIOR OR Instruct = DDRDIOR4 THEN
                        fast_rd <= false;
                        rd      <= false;
                        dual    <= true;
                        ddr     <= true;
                    ELSIF Instruct =DOR OR Instruct=DOR4 OR
                          Instruct = DIOR OR Instruct = DIOR4 OR
                          Instruct = QOR OR Instruct=QOR4 OR
                          Instruct = QIOR OR Instruct= QIOR4 THEN
                        fast_rd <= false;
                        rd      <= false;
                        dual    <= true;
                        ddr     <= false;
                    ELSIF Instruct = DDRQIOR OR Instruct = DDRQIOR4 THEN
                        fast_rd <= false;
                        rd      <= false;
                        dual    <= true;
                        ddr     <= true;
                    ELSE
                        fast_rd <= true;
                        rd      <= false;
                        dual    <= false;
                        ddr     <= false;
                    END IF;
                    HOLDNegOut_zd <= 'Z';
                    WPNegOut_zd   <= 'Z';
                    SOut_zd       <= 'Z';
                    SIOut_zd      <= 'Z';
                ELSIF falling_edge(write) THEN
                    IF Instruct = BRWR THEN
                        Bank_Addr_reg(7) := Bank_Addr_reg_in(7);
                        Bank_Addr_reg(0) := Bank_Addr_reg_in(0);
                        IF Bank_Addr_reg_in(1) = '1' THEN
                            REPORT "WARNING: Changing values of Bank Address" &
                                   " Register BA25 is not allowed!!!"
                            SEVERITY warning;
                        END IF;
                    ELSIF Instruct = WRR AND BAR_ACC = '1' THEN
                    -- Write to the lower address bits of the BAR
                        IF (P_ERR = '0' AND E_ERR = '0')THEN
                            Bank_Addr_reg(0) := Bank_Addr_reg_in(0);
                            IF Bank_Addr_reg_in(1) = '1' THEN
                                REPORT "WARNING: Changing values of Bank " &
                                       "Address Register BA25 is not allowed!!!"
                                SEVERITY warning;
                            END IF;
                        END IF;
                    ELSIF Instruct = PGRS THEN
                        PGRES <= '1', '0' AFTER 5 ns;
                        PS := '0';
                        WIP := '1';
                        RES_TO_SUSP_MIN_TIME <= '1', '0' AFTER 60 ns;
                        RES_TO_SUSP_TYP_TIME <= '1', '0' AFTER 100 us;
                    END IF;

                    IF Instruct = BRAC AND P_ERR = '0' AND E_ERR = '0' AND
                       RdPswdProtMode = '0' THEN
                        BAR_ACC <= '1';
                    ELSE
                        BAR_ACC <= '0';
                    END IF;
                END IF;

            WHEN ERS_SUSP_PG_SUSP      =>
                fast_rd <= true;
                rd      <= false;
                dual    <= false;
                ddr     <= false;
                IF PRGSUSP_out = '1' AND PRGSUSP_in = '1' THEN
                    PRGSUSP_in <= '0';
                    --The RDY/BSY bit in the Status Register will indicate that
                    --the device is ready for another operation.
                    WIP := '0';
                    --The Program Suspend (PS) bit in the Status Register will
                    --be set to the logical “1” state to indicate that the
                    --program operation has been suspended.
                    PS := '1';
                END IF;

                IF oe THEN
                    any_read <= true;
                    IF Instruct = RDSR THEN
                        --Read Status Register 1
                        SOut_zd <= Status_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= Status_reg2(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= Config_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = BRRD THEN
                        --Read Bank Address Register
                        fast_rd <= true;
                        rd      <= false;
                        dual    <= false;
                        ddr     <= false;
                        SOut_zd <= Bank_Addr_reg(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    --Read Array Operations
                    ELSIF Instruct = READ OR Instruct = RD4 OR
                          Instruct = FSTRD OR Instruct = FSTRD4 OR
                          Instruct = DDRFR OR Instruct = DDRFR4 THEN
                        --Read Memory array
                        IF Instruct = READ OR Instruct = RD4 THEN
                            fast_rd <= false;
                            rd      <= true;
                            dual    <= false;
                            ddr     <= false;
                        ELSIF Instruct = DDRFR OR Instruct = DDRFR4 THEN
                            fast_rd <= false;
                            rd      <= false;
                            dual    <= false;
                            ddr     <= true;
                        ELSE
                            fast_rd <= true;
                            rd      <= false;
                            dual    <= false;
                            ddr     <= false;
                        END IF;
                        IF bus_cycle_state = DUMMY_BYTES
                        OR DummyBytes_act = '1' THEN
                            DummyBytes_act := '0';
                            IF (Instruct=DDRFR OR Instruct=DDRFR4) THEN
                                data_out:= VDLR_reg;
                                SOut_zd <=data_out(7-read_cnt);
                                read_cnt:=read_cnt + 1;
                                IF read_cnt = 8 THEN
                                    read_cnt := 0;
                                END IF;
                            END IF;
                        ELSE
                            IF (SectorSuspend /= read_addr/(SecSize+1)+30*b_act AND
                            pgm_page /= read_addr/(PageSize+1)) THEN
                                data_out := to_slv(Mem(read_addr),8);
                                SOut_zd <= data_out(7-read_cnt);
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 8 THEN
                                    read_cnt := 0;
                                    IF read_addr = AddrRANGE THEN
                                        read_addr := 0;
                                    ELSE
                                        read_addr := read_addr + 1;
                                    END IF;
                                END IF;
                            ELSE
                                SOut_zd <= 'U';
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 8 THEN
                                    read_cnt := 0;
                                    IF read_addr = AddrRANGE THEN
                                        read_addr := 0;
                                    ELSE
                                        read_addr := read_addr + 1;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    ELSIF Instruct =DOR OR Instruct=DOR4 OR
                          Instruct = DIOR OR Instruct = DIOR4 OR
                          Instruct = DDRDIOR OR Instruct = DDRDIOR4 THEN
                        --Read Memory array

                        IF Instruct = DDRDIOR OR Instruct = DDRDIOR4 THEN
                            fast_rd <= false;
                            rd      <= false;
                            dual    <= true;
                            ddr     <= true;
                        ELSE
                            fast_rd <= false;
                            rd      <= false;
                            dual    <= true;
                            ddr     <= false;
                        END IF;
                        IF bus_cycle_state = DUMMY_BYTES
                        OR DummyBytes_act = '1' THEN
                            DummyBytes_act := '0';
                            IF (Instruct=DDRDIOR OR Instruct=DDRDIOR4) THEN
                                data_out:=VDLR_reg;
                                SOut_zd <=data_out(7-read_cnt);
                                SIOut_zd<=data_out(7-read_cnt);
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 8 THEN
                                    read_cnt := 0;
                                END IF;
                            END IF;
                        ELSE
                            IF (SectorSuspend /= read_addr/(SecSize+1)+30*b_act AND
                            pgm_page /= read_addr/(PageSize+1)) THEN
                                data_out := to_slv(Mem(read_addr),8);
                                SOut_zd  <= data_out(7-2*read_cnt);
                                SIOut_zd <= data_out(6-2*read_cnt);
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 4 THEN
                                    read_cnt := 0;
                                    IF read_addr = AddrRANGE THEN
                                        read_addr := 0;
                                    ELSE
                                        read_addr := read_addr + 1;
                                    END IF;
                                END IF;
                            ELSE
                                SOut_zd  <= 'U';
                                SIOut_zd <= 'U';
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 4 THEN
                                    read_cnt := 0;
                                    IF read_addr = AddrRANGE THEN
                                        read_addr := 0;
                                    ELSE
                                        read_addr := read_addr + 1;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    ELSIF (Instruct = QOR OR Instruct=QOR4 OR
                           Instruct = QIOR OR Instruct= QIOR4 OR
                           Instruct = DDRQIOR OR Instruct= DDRQIOR4)
                           AND QUAD = '1' THEN

                        --Read Memory array
                        IF Instruct = DDRQIOR OR Instruct = DDRQIOR4 THEN
                            fast_rd <= false;
                            rd      <= false;
                            dual    <= true;
                            ddr     <= true;
                        ELSE
                            fast_rd <= false;
                            rd      <= false;
                            dual    <= true;
                            ddr     <= false;
                        END IF;
                        IF bus_cycle_state = DUMMY_BYTES
                        OR DummyBytes_act = '1' THEN
                            DummyBytes_act := '0';
                            data_out := VDLR_reg;
                            HOLDNegOut_zd <= data_out(7-read_cnt);
                            WPNegOut_zd   <= data_out(7-read_cnt);
                            SOut_zd       <= data_out(7-read_cnt);
                            SIOut_zd      <= data_out(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        ELSE
                            IF (SectorSuspend /= read_addr/(SecSize+1)+30*b_act AND
                            pgm_page /= read_addr/(PageSize+1)) THEN
                                data_out := to_slv(Mem(read_addr),8);
                                HOLDNegOut_zd   <= data_out(7-4*read_cnt);
                                WPNegOut_zd     <= data_out(6-4*read_cnt);
                                SOut_zd         <= data_out(5-4*read_cnt);
                                SIOut_zd        <= data_out(4-4*read_cnt);
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 2 THEN
                                    read_cnt := 0;
                                    IF read_addr = AddrRANGE THEN
                                        read_addr := 0;
                                    ELSE
                                        read_addr := read_addr + 1;
                                    END IF;
                                END IF;
                            ELSE
                                HOLDNegOut_zd   <= 'U';
                                WPNegOut_zd     <= 'U';
                                SOut_zd         <= 'U';
                                SIOut_zd        <= 'U';
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 2 THEN
                                    read_cnt := 0;
                                    IF read_addr = AddrRANGE THEN
                                        read_addr := 0;
                                    ELSE
                                        read_addr := read_addr + 1;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                ELSIF oe_z THEN
                    IF Instruct = READ OR Instruct = RD4 THEN
                        fast_rd <= false;
                        rd      <= true;
                        dual    <= false;
                        ddr     <= false;
                    ELSIF Instruct = DDRFR OR Instruct = DDRFR4 THEN
                        fast_rd <= false;
                        rd      <= false;
                        dual    <= false;
                        ddr     <= true;
                    ELSIF Instruct = DDRDIOR OR Instruct = DDRDIOR4 THEN
                        fast_rd <= false;
                        rd      <= false;
                        dual    <= true;
                        ddr     <= true;
                    ELSIF Instruct =DOR OR Instruct=DOR4 OR
                          Instruct = DIOR OR Instruct = DIOR4 OR
                          Instruct = QOR OR Instruct=QOR4 OR
                          Instruct = QIOR OR Instruct= QIOR4 THEN
                        fast_rd <= false;
                        rd      <= false;
                        dual    <= true;
                        ddr     <= false;
                    ELSIF Instruct = DDRQIOR OR Instruct = DDRQIOR4 THEN
                        fast_rd <= false;
                        rd      <= false;
                        dual    <= true;
                        ddr     <= true;
                    ELSE
                        fast_rd <= true;
                        rd      <= false;
                        dual    <= false;
                        ddr     <= false;
                    END IF;
                    HOLDNegOut_zd <= 'Z';
                    WPNegOut_zd   <= 'Z';
                    SOut_zd       <= 'Z';
                    SIOut_zd      <= 'Z';
                ELSIF falling_edge(write) THEN
                    IF Instruct = BRWR THEN
                        Bank_Addr_reg(7) := Bank_Addr_reg_in(7);
                        Bank_Addr_reg(0) := Bank_Addr_reg_in(0);
                        IF Bank_Addr_reg_in(1) = '1' THEN
                            REPORT "WARNING: Changing values of Bank Address" &
                                   " Register BA25 is not allowed!!!"
                            SEVERITY warning;
                        END IF;
                    ELSIF Instruct = WRR AND BAR_ACC = '1' THEN
                    -- Write to the lower address bits of the BAR
                        IF (P_ERR = '0' AND E_ERR = '0')THEN
                            Bank_Addr_reg(0) := Bank_Addr_reg_in(0);
                            IF Bank_Addr_reg_in(1) = '1' THEN
                                REPORT "WARNING: Changing values of Bank " &
                                    "Address Register BA25 is not allowed!!!"
                                SEVERITY warning;
                            END IF;
                        END IF;
                    ELSIF Instruct = PGRS THEN
                        PGRES <= '1', '0' AFTER 5 ns;
                        PS := '0';
                        WIP := '1';
                        RES_TO_SUSP_MIN_TIME <= '1', '0' AFTER 60 ns;
                        RES_TO_SUSP_TYP_TIME <= '1', '0' AFTER 100 us;
                    END IF;

                    IF Instruct = BRAC AND P_ERR = '0' AND E_ERR = '0' AND
                    RdPswdProtMode = '0' THEN
                        BAR_ACC <= '1';
                    ELSE
                        BAR_ACC <= '0';
                    END IF;
                END IF;

            WHEN OTP_PG         =>
                fast_rd <= true;
                rd      <= false;
                dual    <= false;
                ddr     <= false;
                IF oe THEN
                    any_read <= true;
                    IF Instruct = RDSR THEN
                        --Read Status Register 1
                        SOut_zd <= Status_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= Status_reg2(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= Config_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                ELSIF oe_z THEN
                    HOLDNegOut_zd <= 'Z';
                    WPNegOut_zd   <= 'Z';
                    SOut_zd       <= 'Z';
                    SIOut_zd      <= 'Z';
                END IF;

                IF Address + wr_cnt <= OTPHiAddr THEN
                    FOR i IN 0 TO wr_cnt LOOP
                        new_int := WData(i);
                        old_int := OTPMem(Addr + i);
                        IF new_int > -1 THEN
                            new_bit := to_slv(new_int,8);
                            IF old_int > -1 THEN
                                old_bit := to_slv(old_int,8);
                                FOR j IN 0 TO 7 LOOP
                                    IF old_bit(j) = '0' THEN
                                        new_bit(j) := '0';
                                    END IF;
                                END LOOP;
                                new_int := to_nat(new_bit);
                            END IF;
                            WData(i) := new_int;
                        ELSE
                            WData(i) := -1;
                        END IF;

                        OTPMem(Addr + i) :=  -1;
                    END LOOP;
                ELSE
                    ASSERT false
                        REPORT "Programming will reach over address limit"&
                        " of OTP array"
                        SEVERITY warning;
                END IF;

                IF PDONE = '1' THEN
                    WIP := '0';
                    WEL := '0';
                    FOR i IN 0 TO wr_cnt LOOP
                        OTPMem(Addr_tmp + i) := WData(i);
                    END LOOP;
                    LOCK_BYTE1 := to_slv(OTPMem(16#10#),8);
                    LOCK_BYTE2 := to_slv(OTPMem(16#11#),8);
                    LOCK_BYTE3 := to_slv(OTPMem(16#12#),8);
                    LOCK_BYTE4 := to_slv(OTPMem(16#13#),8);
                END IF;

            WHEN SECTOR_ERS     =>
                fast_rd <= true;
                rd      <= false;
                dual    <= false;
                ddr     <= false;
                IF oe THEN
                    any_read <= true;
                    IF Instruct = RDSR THEN
                        --Read Status Register 1
                        SOut_zd <= Status_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= Status_reg2(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= Config_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                ELSIF oe_z THEN
                    HOLDNegOut_zd <= 'Z';
                    WPNegOut_zd   <= 'Z';
                    SOut_zd       <= 'Z';
                    SIOut_zd      <= 'Z';
                END IF;

                ADDRHILO_SEC(AddrLo, AddrHi, Addr);
                FOR i IN AddrLo TO AddrHi LOOP
                    Mem(i) := -1;
                END LOOP;
                IF EDONE = '1' THEN
                    WIP := '0';
                    WEL := '0';
                    FOR i IN AddrLo TO AddrHi LOOP
                        Mem(i) :=  MaxData;

                        pgm_page := i/PageSize;
--                        QPP_page(pgm_page) := '0';
                    END LOOP;
                ELSIF Instruct = ERSP AND ERSSUSP_in = '0' THEN
                    ESUSP <= '1', '0' AFTER 10 ns;
                    ERSSUSP_in <= '1';
                    ASSERT RES_TO_SUSP_TYP_TIME = '0'
                    REPORT "Typical periods are needed for " &
                           "Program to progress to completion"
                    SEVERITY warning;
                END IF;

            WHEN BULK_ERS       =>
                fast_rd <= true;
                rd      <= false;
                dual    <= false;
                ddr     <= false;
                IF oe THEN
                    any_read <= true;
                    IF Instruct = RDSR THEN
                        --Read Status Register 1
                        SOut_zd <= Status_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= Status_reg2(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= Config_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                ELSIF oe_z THEN
                    HOLDNegOut_zd <= 'Z';
                    WPNegOut_zd   <= 'Z';
                    SOut_zd       <= 'Z';
                    SIOut_zd      <= 'Z';
                END IF;

                IF falling_edge(EDONE) THEN
                    FOR i IN 0 TO AddrRANGE LOOP
                        -- Sector ID calculation
                        IF TimingModel(16) = '0' THEN
                            sec_tmp := i / (SecSize64+1);
                            IF BottomBoot THEN
                                IF sec_tmp <= 1 THEN      --4KB Sectors
                                    sect := i/(SecSize4+1);
                                ELSE
                                    sect := sec_tmp + 30;
                                END IF;
                            ELSIF TopBoot THEN
                                IF sec_tmp >= 510 THEN       --4KB Sectors
                                    sect :=
                                         510+(i-(SecSize64+1)*510)/(SecSize4+1);
                                ELSE
                                    sect := sec_tmp;
                                END IF;
                            END IF;
                        ELSE
                            sect := i/(SecSize256+1);
                        END IF;
                        IF PPB_bits(sect) = '1' AND DYB_bits(sect) = '1' THEN
                            Mem(i) := -1;
                        END IF;
                    END LOOP;
                END IF;

                IF EDONE = '1' THEN
                    WIP := '0';
                    WEL := '0';
                    FOR i IN 0 TO AddrRANGE LOOP
                        -- Sector ID calculation
                        IF TimingModel(16) = '0' THEN
                            sec_tmp := i / (SecSize64+1);
                            IF BottomBoot THEN
                                IF sec_tmp <= 1 THEN      --4KB Sectors
                                    sect := i/(SecSize4+1);
                                ELSE
                                    sect := sec_tmp + 30;
                                END IF;
                            ELSIF TopBoot THEN
                                IF sec_tmp >= 510 THEN       --4KB Sectors
                                    sect :=
                                         510+(i-(SecSize64+1)*510)/(SecSize4+1);
                                ELSE
                                    sect := sec_tmp;
                                END IF;
                            END IF;
                        ELSE
                            sect := i/(SecSize256+1);
                        END IF;
                        IF PPB_bits(sect) = '1' AND DYB_bits(sect) = '1' THEN
                            Mem(i) :=  MaxData;

                            pgm_page := i/PageSize;
--                            QPP_page(pgm_page) := '0';
                        END IF;
                    END LOOP;
                END IF;

            WHEN ERS_SUSP       =>
                fast_rd <= true;
                rd      <= false;
                dual    <= false;
                ddr     <= false;
                IF ERSSUSP_out = '1' THEN
                    ERSSUSP_in <= '0';
                    --The Erase Suspend (ES) bit in the Status Register will
                    --be set to the logical “1” state to indicate that the
                    --erase operation has been suspended.
                    ES := '1';
                    --The WIP bit in the Status Register will indicate that
                    --the device is ready for another operation.
                    WIP := '0';
                END IF;

                IF oe THEN
                    any_read <= true;
                    IF Instruct = RDSR THEN
                        --Read Status Register 1
                        SOut_zd <= Status_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= Status_reg2(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= Config_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = DYBRD THEN
                        --Read DYB Access Register
                        ReturnSectorID(sect,Address);
                        fast_rd <= true;
                        rd      <= false;
                        dual    <= false;
                        ddr     <= false;
                        IF DYB_bits(sect) = '1' THEN
                            DYBAR(7 downto 0) := "11111111";
                        ELSE
                            DYBAR(7 downto 0) := "00000000";
                        END IF;
                        SOut_zd <= DYBAR(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = BRRD THEN
                        --Read Bank Address Register
                        fast_rd <= true;
                        rd      <= false;
                        dual    <= false;
                        ddr     <= false;
                        SOut_zd <= Bank_Addr_reg(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = PPBRD THEN
                        --Read PPB Access Register
                        ReturnSectorID(sect,Address);
                        fast_rd <= true;
                        rd      <= false;
                        dual    <= false;
                        ddr     <= false;
                        PPBAR(7 downto 0) := "UUUUUUUU";
                        IF RdPswdProtMode = '0' THEN
                            IF PPB_bits(sect) = '1' THEN
                                PPBAR(7 downto 0) := "11111111";
                            ELSE
                                PPBAR(7 downto 0) := "00000000";
                            END IF;
                        END IF;
                        SOut_zd <= PPBAR(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    --Read Array Operations
                    ELSIF Instruct = READ OR Instruct = RD4 OR
                          Instruct = FSTRD OR Instruct = FSTRD4 OR
                          Instruct = DDRFR OR Instruct = DDRFR4 THEN
                        --Read Memory array
                        IF Instruct = READ OR Instruct = RD4 THEN
                            fast_rd <= false;
                            rd      <= true;
                            dual    <= false;
                            ddr     <= false;
                        ELSIF Instruct = DDRFR OR Instruct = DDRFR4 THEN
                            fast_rd <= false;
                            rd      <= false;
                            dual    <= false;
                            ddr     <= true;
                        ELSE
                            fast_rd <= true;
                            rd      <= false;
                            dual    <= false;
                            ddr     <= false;
                        END IF;

                        IF bus_cycle_state = DUMMY_BYTES
                        OR DummyBytes_act = '1' THEN
                            DummyBytes_act := '0';
                            IF (Instruct=DDRFR OR Instruct=DDRFR4) THEN
                                data_out:= VDLR_reg;
                                SOut_zd <=data_out(7-read_cnt);
                                read_cnt:=read_cnt + 1;
                                IF read_cnt = 8 THEN
                                    read_cnt := 0;
                                END IF;
                            END IF;
                        ELSE
                            IF (PARAM_REGION = TRUE AND
                            SectorSuspend /= read_addr/(SecSize+1)) OR
                            (PARAM_REGION = FALSE AND
                            SectorSuspend /= read_addr/(SecSize+1)+30*b_act) THEN
                                data_out := to_slv(Mem(read_addr),8);
                                SOut_zd <= data_out(7-read_cnt);
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 8 THEN
                                    read_cnt := 0;
                                    IF read_addr = AddrRANGE THEN
                                        read_addr := 0;
                                    ELSE
                                        read_addr := read_addr + 1;
                                    END IF;
                                END IF;
                            ELSE
                                SOut_zd <= 'U';
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 8 THEN
                                    read_cnt := 0;
                                    IF read_addr = AddrRANGE THEN
                                        read_addr := 0;
                                    ELSE
                                        read_addr := read_addr + 1;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    ELSIF Instruct =DOR OR Instruct=DOR4 OR
                          Instruct = DIOR OR Instruct = DIOR4 OR
                          Instruct = DDRDIOR OR Instruct = DDRDIOR4 THEN
                        --Read Memory array
                        IF Instruct = DDRDIOR OR Instruct = DDRDIOR4 THEN
                            fast_rd <= false;
                            rd      <= false;
                            dual    <= true;
                            ddr     <= true;
                        ELSE
                            fast_rd <= false;
                            rd      <= false;
                            dual    <= true;
                            ddr     <= false;
                        END IF;
                        IF bus_cycle_state = DUMMY_BYTES
                        OR DummyBytes_act = '1' THEN
                            DummyBytes_act := '0';
                            data_out:=VDLR_reg;
                            SOut_zd <=data_out(7-read_cnt);
                            SIOut_zd<=data_out(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        ELSE
                            IF (PARAM_REGION = TRUE AND
                            SectorSuspend /= read_addr/(SecSize+1)) OR
                            (PARAM_REGION = FALSE AND
                            SectorSuspend /= read_addr/(SecSize+1)+30*b_act) THEN
                                data_out := to_slv(Mem(read_addr),8);
                                SOut_zd  <= data_out(7-2*read_cnt);
                                SIOut_zd <= data_out(6-2*read_cnt);
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 4 THEN
                                    read_cnt := 0;
                                    IF read_addr = AddrRANGE THEN
                                        read_addr := 0;
                                    ELSE
                                        read_addr := read_addr + 1;
                                    END IF;
                                END IF;
                            ELSE
                                SOut_zd  <= 'U';
                                SIOut_zd <= 'U';
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 4 THEN
                                    read_cnt := 0;
                                    IF read_addr = AddrRANGE THEN
                                        read_addr := 0;
                                    ELSE
                                        read_addr := read_addr + 1;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    ELSIF (Instruct = QOR OR Instruct=QOR4 OR
                           Instruct = QIOR OR Instruct= QIOR4 OR
                           Instruct = DDRQIOR OR Instruct= DDRQIOR4)
                           AND QUAD = '1' THEN
                        --Read Memory array
                        IF Instruct = DDRQIOR OR Instruct = DDRQIOR4 THEN
                            fast_rd <= false;
                            rd      <= false;
                            dual    <= true;
                            ddr     <= true;
                        ELSE
                            fast_rd <= false;
                            rd      <= false;
                            dual    <= true;
                            ddr     <= false;
                        END IF;
                        IF bus_cycle_state = DUMMY_BYTES
                        OR DummyBytes_act = '1' THEN
                            DummyBytes_act := '0';
                            data_out := VDLR_reg;
                            HOLDNegOut_zd <= data_out(7-read_cnt);
                            WPNegOut_zd   <= data_out(7-read_cnt);
                            SOut_zd       <= data_out(7-read_cnt);
                            SIOut_zd      <= data_out(7-read_cnt);
                            read_cnt := read_cnt + 1;
                            IF read_cnt = 8 THEN
                                read_cnt := 0;
                            END IF;
                        ELSE
                            IF (PARAM_REGION = TRUE AND
                            SectorSuspend /= read_addr/(SecSize+1)) OR
                            (PARAM_REGION = FALSE AND
                            SectorSuspend /= read_addr/(SecSize+1)+30*b_act) THEN
                                data_out := to_slv(Mem(read_addr),8);
                                HOLDNegOut_zd   <= data_out(7-4*read_cnt);
                                WPNegOut_zd     <= data_out(6-4*read_cnt);
                                SOut_zd         <= data_out(5-4*read_cnt);
                                SIOut_zd        <= data_out(4-4*read_cnt);
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 2 THEN
                                    read_cnt := 0;
                                    IF read_addr = AddrRANGE THEN
                                        read_addr := 0;
                                    ELSE
                                        read_addr := read_addr + 1;
                                    END IF;
                                END IF;
                            ELSE
                                HOLDNegOut_zd   <= 'U';
                                WPNegOut_zd     <= 'U';
                                SOut_zd         <= 'U';
                                SIOut_zd        <= 'U';
                                read_cnt := read_cnt + 1;
                                IF read_cnt = 2 THEN
                                    read_cnt := 0;
                                    IF read_addr = AddrRANGE THEN
                                        read_addr := 0;
                                    ELSE
                                        read_addr := read_addr + 1;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                ELSIF oe_z THEN
                    IF Instruct = READ OR Instruct = RD4 THEN
                        fast_rd <= false;
                        rd      <= true;
                        dual    <= false;
                        ddr     <= false;
                    ELSIF Instruct = DDRFR OR Instruct = DDRFR4 THEN
                        fast_rd <= false;
                        rd      <= false;
                        dual    <= false;
                        ddr     <= true;
                    ELSIF Instruct = DDRDIOR OR Instruct = DDRDIOR4 THEN
                        fast_rd <= false;
                        rd      <= false;
                        dual    <= true;
                        ddr     <= true;
                    ELSIF Instruct =DOR OR Instruct=DOR4 OR
                          Instruct = DIOR OR Instruct = DIOR4 OR
                          Instruct = QOR OR Instruct=QOR4 OR
                          Instruct = QIOR OR Instruct= QIOR4 THEN
                        fast_rd <= false;
                        rd      <= false;
                        dual    <= true;
                        ddr     <= false;
                    ELSIF Instruct = DDRQIOR OR Instruct = DDRQIOR4 THEN
                        fast_rd <= false;
                        rd      <= false;
                        dual    <= true;
                        ddr     <= true;
                    ELSE
                        fast_rd <= true;
                        rd      <= false;
                        dual    <= false;
                        ddr     <= false;
                    END IF;
                    HOLDNegOut_zd <= 'Z';
                    WPNegOut_zd   <= 'Z';
                    SOut_zd       <= 'Z';
                    SIOut_zd      <= 'Z';
                END IF;

                IF falling_edge(write) THEN
                    IF (Instruct = PP OR Instruct = PP4) AND WEL = '1' THEN
                        IF (PARAM_REGION = TRUE AND
                            SectorSuspend /= Address/(SecSize+1)) OR
                           (PARAM_REGION = FALSE AND
                            SectorSuspend/=Address/(SecSize+1)+30*b_act) THEN
                            ReturnSectorID(sect,Address);
                            Addr := Address;
                            pgm_page := Address/(PageSize+1);
                            IF (Sec_Prot(sect) = '0' AND
                               PPB_bits(sect)='1' AND DYB_bits(sect)='1') THEN
                                PSTART <= '1', '0' AFTER 5 ns;
                                PGSUSP  <= '0';
                                PGRES   <= '0';
                                WIP := '1' ;
                                SA <= sect;
                                Addr := Address;
                                Addr_tmp := Address;
                                wr_cnt := Byte_number;
                                FOR I IN wr_cnt DOWNTO 0 LOOP
                                    IF Viol /= '0' THEN
                                        WData(i) := -1;
                                    ELSE
                                        WData(i) := WByte(i);
                                    END IF;
                                END LOOP;
                            ELSE
                                WEL   := '0';
                                P_ERR := '1';
                            END IF;
                        ELSE
                            WEL := '0';
                            P_ERR := '1';
                        END IF;
                    ELSIF (Instruct = QPP OR Instruct = QPP4) AND WEL = '1' THEN
                        IF (PARAM_REGION = TRUE AND
                            SectorSuspend /= Address/(SecSize+1)) OR
                           (PARAM_REGION = FALSE AND
                            SectorSuspend/=Address/(SecSize+1)+30*b_act) THEN
                            ReturnSectorID(sect,Address);
                            Addr := Address;
                            pgm_page := Address/(PageSize+1);
                            IF (Sec_Prot(sect)='0' AND
                            PPB_bits(sect)='1' AND DYB_bits(sect)='1') THEN
                                PSTART <= '1', '0' AFTER 5 ns;
                                PGSUSP  <= '0';
                                PGRES   <= '0';
                                WIP := '1' ;
                                SA <= sect;
                                Addr := Address;
                                Addr_tmp := Address;
                                wr_cnt := Byte_number;
                                FOR I IN wr_cnt DOWNTO 0 LOOP
                                    IF Viol /= '0' THEN
                                        WData(i) := -1;
                                    ELSE
                                        WData(i) := WByte(i);
                                    END IF;
                                END LOOP;
                            ELSE
                                WEL   := '0';
                                P_ERR := '1';
                            END IF;
                        ELSE
                            WEL := '0';
                            P_ERR := '1';
                        END IF;
                    ELSIF Instruct = WREN THEN
                        WEL := '1';
                    ELSIF Instruct = CLSR THEN
                    --The Clear Status Register Command resets bit SR1[5]
                    --(Erase Fail Flag) and bit SR1[6] (Program Fail Flag)
                       E_ERR := '0';
                       P_ERR := '0';
                    ELSIF Instruct = BRWR THEN
                        Bank_Addr_reg(7) := Bank_Addr_reg_in(7);
                        Bank_Addr_reg(0) := Bank_Addr_reg_in(0);
                        IF Bank_Addr_reg_in(1) = '1' THEN
                            REPORT "WARNING: Changing values of Bank Address" &
                                   " Register BA25 is not allowed!!!"
                            SEVERITY warning;
                        END IF;
                    ELSIF Instruct = WRR AND BAR_ACC = '1' THEN
                    -- Write to the lower address bits of the BAR
                        IF (P_ERR = '0' AND E_ERR = '0')THEN
                            Bank_Addr_reg(0) := Bank_Addr_reg_in(0);
                            IF Bank_Addr_reg_in(1) = '1' THEN
                                REPORT "WARNING: Changing values of Bank " &
                                       "Address Register BA25 is not allowed!!!"
                                SEVERITY warning;
                            END IF;
                        END IF;
                    ELSIF Instruct = DYBWR  AND WEL = '1' THEN
                        ReturnSectorID(sect,Address);
                        PSTART <= '1', '0' AFTER 5 ns;
                        WIP := '1';
                    ELSIF Instruct = ERRS THEN
                        ERES <= '1', '0' AFTER 5 ns;
                        ES := '0';
                        WIP := '1';
                        IF BottomBoot = TRUE THEN
                            IF PARAM_REGION = TRUE THEN
                                Addr := SectorSuspend*(SecSize+1);
                            ELSE
                                Addr := (SectorSuspend-30)*(SecSize+1);
                            END IF;
                        ELSE
                            Addr := SectorSuspend*(SecSize+1);
                        END IF;
                        ADDRHILO_SEC(AddrLo, AddrHi, Addr);
                        RES_TO_SUSP_TYP_TIME <= '1', '0' AFTER 100 us;
                    END IF;

                    IF Instruct = BRAC AND P_ERR = '0' AND E_ERR = '0' AND
                       RdPswdProtMode = '0' THEN
                        BAR_ACC <= '1';
                    ELSE
                        BAR_ACC <= '0';
                    END IF;
                END IF;

            WHEN ERS_SUSP_PG    =>
                fast_rd <= true;
                rd      <= false;
                dual    <= false;
                ddr     <= false;
                IF oe THEN
                    any_read <= true;
                    IF Instruct = RDSR THEN
                        --Read Status Register 1
                        SOut_zd <= Status_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= Status_reg2(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= Config_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                ELSIF oe_z THEN
                    HOLDNegOut_zd <= 'Z';
                    WPNegOut_zd   <= 'Z';
                    SOut_zd       <= 'Z';
                    SIOut_zd      <= 'Z';
--                END IF;

--                IF (Instruct = QPP OR Instruct = QPP4) THEN
--                    QPP_page(pgm_page) := '1';
                END IF;

                ADDRHILO_PG(AddrLo, AddrHi, Addr);
                cnt := 0;

                FOR i IN 0 TO wr_cnt LOOP
                    new_int := WData(i);
                    old_int := Mem(Addr + i - cnt);
                    IF new_int > -1 THEN
                        new_bit := to_slv(new_int,8);
                        IF old_int > -1 THEN
                            old_bit := to_slv(old_int,8);
                            FOR j IN 0 TO 7 LOOP
                                IF old_bit(j) = '0' THEN
                                    new_bit(j) := '0';
                                END IF;
                            END LOOP;
                            new_int := to_nat(new_bit);
                        END IF;
                        WData(i) := new_int;
                    ELSE
                        WData(i) := -1;
                    END IF;

                    IF (Addr + i) = AddrHi THEN
                        Addr := AddrLo;
                        cnt := i + 1;
                    END IF;
                END LOOP;
                cnt :=0;

                IF PDONE = '1' THEN
                    WIP := '0';
                    WEL := '0';
                    FOR i IN 0 TO wr_cnt LOOP
                        Mem(Addr_tmp + i - cnt) := WData(i);
                        IF (Addr_tmp + i) = AddrHi THEN
                            Addr_tmp := AddrLo;
                            cnt := i + 1;
                        END IF;
                    END LOOP;
                ELSIF Instruct = PGSP AND PRGSUSP_in = '0' THEN
                    PGSUSP <= '1', '0' AFTER 1 ns;
                    PRGSUSP_in <= '1';
                END IF;

            WHEN PASS_PG        =>
                fast_rd <= true;
                rd      <= false;
                dual    <= false;
                ddr     <= false;
                IF oe THEN
                    any_read <= true;
                    IF Instruct = RDSR THEN
                        --Read Status Register 1
                        SOut_zd <= Status_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= Status_reg2(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= Config_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                ELSIF oe_z THEN
                    HOLDNegOut_zd <= 'Z';
                    WPNegOut_zd   <= 'Z';
                    SOut_zd       <= 'Z';
                    SIOut_zd      <= 'Z';
                END IF;

                new_pass := Password_reg_in;
                old_pass := Password_reg;
                FOR j IN 0 TO 63 LOOP
                    IF old_pass(j) = '0' THEN
                        new_pass(j) := '0';
                    END IF;
                END LOOP;

                IF PDONE = '1' THEN
                    Password_reg := new_pass;
                    WIP  := '0';
                    WEL  := '0';
                END IF;

            WHEN PASS_UNLOCK    =>
                WIP := '1';
                fast_rd <= true;
                rd      <= false;
                dual    <= false;
                ddr     <= false;
                IF oe THEN
                    any_read <= true;
                    IF Instruct = RDSR THEN
                        --Read Status Register 1
                        SOut_zd <= Status_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= Status_reg2(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= Config_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                ELSIF oe_z THEN
                    HOLDNegOut_zd <= 'Z';
                    WPNegOut_zd   <= 'Z';
                    SOut_zd       <= 'Z';
                    SIOut_zd      <= 'Z';
                END IF;

                IF PASS_TEMP = Password_reg THEN
                    PASS_UNLOCKED <= TRUE;
                ELSE
                    PASS_UNLOCKED <= FALSE;
                END IF;

                IF PASSULCK_out = '1' THEN
                    IF PASS_UNLOCKED AND PWDMLB = '0' THEN
                        PPB_LOCK := '1';
                        PPB_LOCK_temp <= '1';
                        WIP   := '0';
                    ELSE
                        P_ERR := '1';
                        REPORT "Incorrect Password!"
                        SEVERITY warning;
                        PASSACC_in <= '1';
                    END IF;
                    WEL   := '0';
                    PASSULCK_in <= '0';
                END IF;

            WHEN PPB_PG         =>
                fast_rd <= true;
                rd      <= false;
                dual    <= false;
                ddr     <= false;
                IF oe THEN
                    any_read <= true;
                    IF Instruct = RDSR THEN
                        --Read Status Register 1
                        SOut_zd <= Status_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= Status_reg2(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= Config_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                ELSIF oe_z THEN
                    HOLDNegOut_zd <= 'Z';
                    WPNegOut_zd   <= 'Z';
                    SOut_zd       <= 'Z';
                    SIOut_zd      <= 'Z';
                END IF;

                IF PDONE = '1' THEN
                    IF PPB_LOCK /= '0' THEN
                        PPB_bits(sect):= '0';
                        WIP   := '0';
                        WEL   := '0';
                    ELSE
                        P_ERR := '0';
                        WIP   := '0';
                        WEL   := '0';
                    END IF;
                END IF;

            WHEN PPB_ERS        =>
                fast_rd <= true;
                rd      <= false;
                dual    <= false;
                ddr     <= false;
                IF oe THEN
                    any_read <= true;
                    IF Instruct = RDSR THEN
                        --Read Status Register 1
                        SOut_zd <= Status_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= Status_reg2(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= Config_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                ELSIF oe_z THEN
                    HOLDNegOut_zd <= 'Z';
                    WPNegOut_zd   <= 'Z';
                    SOut_zd       <= 'Z';
                    SIOut_zd      <= 'Z';
                END IF;

                IF PPBERASE_out = '1' THEN
                    IF PPB_LOCK /= '0' AND PPBOTP = '1' THEN
                        PPB_bits:= (OTHERS => '1');
                    ELSE
                        E_ERR := '1';
                    END IF;
                    WIP   := '0';
                    WEL   := '0';
                    PPBERASE_in <= '0';
                END IF;

            WHEN AUTOBOOT_PG    =>
                fast_rd <= true;
                rd      <= false;
                dual    <= false;
                ddr     <= false;
                IF oe THEN
                    any_read <= true;
                    IF Instruct = RDSR THEN
                        --Read Status Register 1
                        SOut_zd <= Status_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= Status_reg2(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= Config_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                ELSIF oe_z THEN
                    HOLDNegOut_zd <= 'Z';
                    WPNegOut_zd   <= 'Z';
                    SOut_zd       <= 'Z';
                    SIOut_zd      <= 'Z';
                END IF;

                IF PDONE = '1' THEN
                    FOR I IN 0 TO 3 LOOP
                        FOR J IN 0 TO 7 LOOP
                            AutoBoot_reg(I*8+J) :=
                                     AutoBoot_reg_in((3-I)*8+J);
                        END LOOP;
                    END LOOP;
                    WIP  := '0';
                    WEL  := '0';
                END IF;

            WHEN PLB_PG         =>
                fast_rd <= true;
                rd      <= false;
                dual    <= false;
                ddr     <= false;
                IF oe THEN
                    any_read <= true;
                    IF Instruct = RDSR THEN
                        --Read Status Register 1
                        SOut_zd <= Status_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= Status_reg2(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= Config_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                ELSIF oe_z THEN
                    HOLDNegOut_zd <= 'Z';
                    WPNegOut_zd   <= 'Z';
                    SOut_zd       <= 'Z';
                    SIOut_zd      <= 'Z';
                END IF;

                IF PDONE = '1' THEN
                    PPB_LOCK := '0';
                    PPB_LOCK_temp <= '0';
                    WIP  := '0';
                    WEL  := '0';
                END IF;

            WHEN DYB_PG         =>
                fast_rd <= true;
                rd      <= false;
                dual    <= false;
                ddr     <= false;
                IF oe THEN
                    any_read <= true;
                    IF Instruct = RDSR THEN
                        --Read Status Register 1
                        SOut_zd <= Status_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= Status_reg2(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= Config_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                ELSIF oe_z THEN
                    HOLDNegOut_zd <= 'Z';
                    WPNegOut_zd   <= 'Z';
                    SOut_zd       <= 'Z';
                    SIOut_zd      <= 'Z';
                END IF;

                IF PDONE = '1' THEN
                    DYBAR := DYBAR_in;
                    IF DYBAR = "11111111" THEN
                        DYB_bits(sect):= '1';
                    ELSIF DYBAR = "00000000" THEN
                        DYB_bits(sect):= '0';
                    ELSE
                        P_ERR := '1';
                    END IF;
                    WIP  := '0';
                    WEL  := '0';
                END IF;

            WHEN ASP_PG         =>
                fast_rd <= true;
                rd      <= false;
                dual    <= false;
                ddr     <= false;
                IF oe THEN
                    any_read <= true;
                    IF Instruct = RDSR THEN
                        --Read Status Register 1
                        SOut_zd <= Status_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= Status_reg2(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= Config_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                ELSIF oe_z THEN
                    HOLDNegOut_zd <= 'Z';
                    WPNegOut_zd   <= 'Z';
                    SOut_zd       <= 'Z';
                    SIOut_zd      <= 'Z';
                END IF;

                IF PDONE = '1' THEN

                    IF (RPME = '0' AND ASP_reg_in(5) = '1') THEN
                       P_ERR := '1';
                       REPORT "RPME bit is allready programmed"
                       SEVERITY warning;
                    ELSE
                        RPME := ASP_reg_in(5);
                    END IF;

                    IF (PPBOTP = '0' AND ASP_reg_in(3) ='1') THEN
                       P_ERR := '1';
                       REPORT "PPBOTP bit is allready programmed"
                       SEVERITY warning;
                    ELSE
                        PPBOTP := ASP_reg_in(3);
                    END IF;

                    IF (PWDMLB = '1' AND PSTMLB = '1') THEN
                        IF (ASP_reg_in(2) = '0' AND ASP_reg_in(1) = '0') THEN
                            REPORT "ASPR[2:1] = 00  Illegal condition"
                            SEVERITY warning;
                            P_ERR := '1';
                        ELSE
                            IF (ASP_reg_in(2) /= '1' OR
                                ASP_reg_in(1) /= '1') THEN
                                ASPOTPFLAG <= TRUE;
                            END IF;
                            PWDMLB := ASP_reg_in(2);
                            PSTMLB := ASP_reg_in(1);
                        END IF;
                    END IF;
                    WIP  := '0';
                    WEL  := '0';
                END IF;

            WHEN NVDLR_PG    =>
                fast_rd <= true;
                rd      <= false;
                dual    <= false;
                ddr     <= false;
                IF oe THEN
                    any_read <= true;
                    IF Instruct = RDSR THEN
                        --Read Status Register 1
                        SOut_zd <= Status_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDSR2 THEN
                        --Read Status Register 2
                        SOut_zd <= Status_reg2(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    ELSIF Instruct = RDCR THEN
                        --Read Configuration Register 1
                        SOut_zd <= Config_reg1(7-read_cnt);
                        read_cnt := read_cnt + 1;
                        IF read_cnt = 8 THEN
                            read_cnt := 0;
                        END IF;
                    END IF;
                ELSIF oe_z THEN
                    HOLDNegOut_zd <= 'Z';
                    WPNegOut_zd   <= 'Z';
                    SOut_zd       <= 'Z';
                    SIOut_zd      <= 'Z';
                END IF;

                IF PDONE = '1' THEN
                    IF NVDLR_reg = "00000000" THEN
                        NVDLR_reg :=NVDLR_reg_in;
                        VDLR_reg := NVDLR_reg_in;
                        WIP := '0';
                        WEL := '0';
                    ELSE
                        WIP   := '0';
                        WEL   := '0';
                        P_ERR := '1';
                        REPORT "NVDLR is allready programmed"
                        SEVERITY warning;
                    END IF;
                END IF;

            WHEN RESET_STATE    =>
                --the default condition hardware reset
                --The Bank Address Register is loaded to all zeroes
                Bank_Addr_reg := (others => '0');
                IF BPNV = '1' AND FREEZE = '0' THEN
                    BP0 := '1';
                    BP1 := '1';
                    BP2 := '1';
                    BP_bits := BP2 & BP1 & BP0;
                    change_BP <= '1', '0' AFTER 1 ns;
                END IF;
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
                --On reset cycles the data pattern reverts back
                --to what is in the NVDLR
                VDLR_reg := NVDLR_reg;
                --Loads the Program Buffer with all ones
                WData := (OTHERS => MaxData);

                IF PWDMLB = '0' THEN
                    PPB_LOCK := '0';
                    PPB_LOCK_temp <= '0';
                ELSE
                    PPB_LOCK := '1';
                    PPB_LOCK_temp <= '1';
                END IF;

        END CASE;

        --Output Disable Control
        IF (CSNeg_ipd = '1') THEN
            SIOut_zd        <= 'Z';
            HOLDNegOut_zd   <= 'Z';
            WPNegOut_zd     <= 'Z';
            SOut_zd         <= 'Z';
        END IF;

    END PROCESS Functional;

    ---------------------------------------------------------------------------
    -- CFI Process
    ---------------------------------------------------------------------------
    CFIPreload:    PROCESS

    BEGIN
        ------------------------------------------------------------------------
        --CFI array data
        ------------------------------------------------------------------------
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
        CFI_array(16#51#) := 16#41#;
        CFI_array(16#52#) := 16#4C#;
        CFI_array(16#53#) := 16#54#;
        CFI_array(16#54#) := 16#32#;
        CFI_array(16#55#) := 16#30#;

        CFI_array_tmp :=to_slv(CFI_array(16#00#), 8) &
                        to_slv(CFI_array(16#01#), 8) &
                        to_slv(CFI_array(16#02#), 8) &
                        to_slv(CFI_array(16#03#), 8) &
                        to_slv(CFI_array(16#04#), 8) &
                        to_slv(CFI_array(16#05#), 8) &
                        to_slv(CFI_array(16#06#), 8) &
                        to_slv(CFI_array(16#07#), 8) &
                        to_slv(CFI_array(16#08#), 8) &
                        to_slv(CFI_array(16#09#), 8) &
                        to_slv(CFI_array(16#0A#), 8) &
                        to_slv(CFI_array(16#0B#), 8) &
                        to_slv(CFI_array(16#0C#), 8) &
                        to_slv(CFI_array(16#0D#), 8) &
                        to_slv(CFI_array(16#0E#), 8) &
                        to_slv(CFI_array(16#0F#), 8) &
                        to_slv(CFI_array(16#10#), 8) &
                        to_slv(CFI_array(16#11#), 8) &
                        to_slv(CFI_array(16#12#), 8) &
                        to_slv(CFI_array(16#13#), 8) &
                        to_slv(CFI_array(16#14#), 8) &
                        to_slv(CFI_array(16#15#), 8) &
                        to_slv(CFI_array(16#16#), 8) &
                        to_slv(CFI_array(16#17#), 8) &
                        to_slv(CFI_array(16#18#), 8) &
                        to_slv(CFI_array(16#19#), 8) &
                        to_slv(CFI_array(16#1A#), 8) &
                        to_slv(CFI_array(16#1B#), 8) &
                        to_slv(CFI_array(16#1C#), 8) &
                        to_slv(CFI_array(16#1D#), 8) &
                        to_slv(CFI_array(16#1E#), 8) &
                        to_slv(CFI_array(16#1F#), 8) &
                        to_slv(CFI_array(16#20#), 8) &
                        to_slv(CFI_array(16#21#), 8) &
                        to_slv(CFI_array(16#22#), 8) &
                        to_slv(CFI_array(16#23#), 8) &
                        to_slv(CFI_array(16#24#), 8) &
                        to_slv(CFI_array(16#25#), 8) &
                        to_slv(CFI_array(16#26#), 8) &
                        to_slv(CFI_array(16#27#), 8) &
                        to_slv(CFI_array(16#28#), 8) &
                        to_slv(CFI_array(16#29#), 8) &
                        to_slv(CFI_array(16#2A#), 8) &
                        to_slv(CFI_array(16#2B#), 8) &
                        to_slv(CFI_array(16#2C#), 8) &
                        to_slv(CFI_array(16#2D#), 8) &
                        to_slv(CFI_array(16#2E#), 8) &
                        to_slv(CFI_array(16#2F#), 8) &
                        to_slv(CFI_array(16#30#), 8) &
                        to_slv(CFI_array(16#31#), 8) &
                        to_slv(CFI_array(16#32#), 8) &
                        to_slv(CFI_array(16#33#), 8) &
                        to_slv(CFI_array(16#34#), 8) &
                        to_slv(CFI_array(16#35#), 8) &
                        to_slv(CFI_array(16#36#), 8) &
                        to_slv(CFI_array(16#37#), 8) &
                        to_slv(CFI_array(16#38#), 8) &
                        to_slv(CFI_array(16#39#), 8) &
                        to_slv(CFI_array(16#3A#), 8) &
                        to_slv(CFI_array(16#3B#), 8) &
                        to_slv(CFI_array(16#3C#), 8) &
                        to_slv(CFI_array(16#3D#), 8) &
                        to_slv(CFI_array(16#3E#), 8) &
                        to_slv(CFI_array(16#3F#), 8) &
                        to_slv(CFI_array(16#40#), 8) &
                        to_slv(CFI_array(16#41#), 8) &
                        to_slv(CFI_array(16#42#), 8) &
                        to_slv(CFI_array(16#43#), 8) &
                        to_slv(CFI_array(16#44#), 8) &
                        to_slv(CFI_array(16#45#), 8) &
                        to_slv(CFI_array(16#46#), 8) &
                        to_slv(CFI_array(16#47#), 8) &
                        to_slv(CFI_array(16#48#), 8) &
                        to_slv(CFI_array(16#49#), 8) &
                        to_slv(CFI_array(16#4A#), 8) &
                        to_slv(CFI_array(16#4B#), 8) &
                        to_slv(CFI_array(16#4C#), 8) &
                        to_slv(CFI_array(16#4D#), 8) &
                        to_slv(CFI_array(16#4E#), 8) &
                        to_slv(CFI_array(16#4F#), 8) &
                        to_slv(CFI_array(16#50#), 8);

        WAIT;

    END PROCESS CFIPreload;

    AspRegInit: PROCESS(ASP_INIT)
    BEGIN
        IF ASP_INIT = 0 THEN
            ASP_reg := to_slv(16#FE4F#,16);
        ELSE
            ASP_reg := to_slv(16#FE7F#,16);
        END IF;
    END PROCESS AspRegInit;

    TopBottom: PROCESS(change_TBPARM, PoweredUp)
    BEGIN
        IF (TimingModel(16)= '0') THEN
            IF TBPARM = '0' THEN
                BottomBoot <= TRUE;
                b_act := 1;
            ELSE
                TopBoot    <= TRUE;
                BottomBoot <= FALSE;
                b_act := 0;
            END IF;
        END IF;
    END PROCESS TopBottom;

    Protect : PROCESS(change_BP)
    BEGIN
        IF rising_edge(change_BP) THEN

            CASE BP_bits IS
                WHEN "000" =>
                    Sec_Prot := (OTHERS => '0');
                WHEN "001" =>
                    IF TBPROT = '0' THEN
                        Sec_Prot(SecNumMax downto ((SecNum+1)*63/64+30*b_act))
                                                    := (OTHERS => '1');
                        Sec_Prot(((SecNum+1)*63/64 + 30*b_act) - 1 downto 0)
                                                    := (OTHERS => '0');
                    ELSE
                        Sec_Prot((SecNum+1)/64 + 30*b_act - 1 downto 0)
                                                    := (OTHERS => '1');
                        Sec_Prot(SecNumMax downto (SecNum+1)/64 + 30*b_act)
                                                    := (OTHERS => '0');
                    END IF;
                WHEN "010" =>
                    IF TBPROT =  '0' THEN
                        Sec_Prot(SecNumMax downto ((SecNum+1)*31/32+30*b_act))
                                                    := (OTHERS => '1');
                        Sec_Prot(((SecNum+1)*31/32+30*b_act) - 1 downto 0)
                                                    := (OTHERS => '0');
                    ELSE
                        Sec_Prot((SecNum+1)/32 + 30*b_act - 1 downto 0)
                                                    := (others => '1');
                        Sec_Prot(SecNumMax downto (SecNum+1)/32 + 30*b_act)
                                                    := (OTHERS => '0');
                    END IF;
                WHEN "011" =>
                    IF TBPROT =  '0' THEN
                        Sec_Prot(SecNumMax downto ((SecNum+1)*15/16+30*b_act))
                                                    := (OTHERS => '1');
                        Sec_Prot(((SecNum+1)*15/16 + 30*b_act) - 1 downto 0)
                                                    := (OTHERS => '0');
                    ELSE
                        Sec_Prot((SecNum+1)/16 + 30*b_act - 1 downto 0)
                                                    := (OTHERS => '1');
                        Sec_Prot(SecNumMax downto (SecNum+1)/16 + 30*b_act)
                                                    := (OTHERS => '0');
                    END IF;
                WHEN "100" =>
                    IF TBPROT =  '0' THEN
                        Sec_Prot(SecNumMax downto ((SecNum+1)*7/8 + 30*b_act))
                                                    := (OTHERS => '1');
                        Sec_Prot(((SecNum+1)*7/8 + 30*b_act) - 1 downto 0)
                                                    := (OTHERS => '0');
                    ELSE
                        Sec_Prot((SecNum+1)/8 + 30*b_act - 1 downto 0)
                                                            := (OTHERS => '1');
                        Sec_Prot(SecNumMax downto (SecNum+1)/8 + 30*b_act)
                                                            := (OTHERS => '0');
                    END IF;
                WHEN "101" =>
                    IF TBPROT =  '0' THEN
                        Sec_Prot(SecNumMax downto ((SecNum+1)*3/4 + 30*b_act))
                                                    := (OTHERS => '1');
                        Sec_Prot(((SecNum+1)*3/4 + 30*b_act) - 1 downto 0)
                                                    := (OTHERS => '0');
                    ELSE
                        Sec_Prot((SecNum+1)/4 + 30*b_act - 1 downto 0)
                                                            := (OTHERS => '1');
                        Sec_Prot(SecNumMax downto (SecNum+1)/4 + 30*b_act)
                                                            := (OTHERS => '0');
                    END IF;
                WHEN "110" =>
                    IF TBPROT =  '0' THEN
                        Sec_Prot(SecNumMax downto ((SecNum+1)/2 + 30*b_act))
                                                            := (OTHERS => '1');
                        Sec_Prot(((SecNum+1)/2 + 30*b_act) - 1 downto 0)
                                                            := (OTHERS => '0');
                    ELSE
                        Sec_Prot((SecNum+1)/2 + 30*b_act - 1 downto 0)
                                                            := (OTHERS => '1');
                        Sec_Prot(SecNumMax downto (SecNum+1)/2 + 30*b_act)
                                                            := (OTHERS => '0');
                    END IF;
                WHEN OTHERS =>
                    Sec_Prot := (OTHERS => '1');
            END CASE;
        END IF;
    END PROCESS Protect;

    HOLD_FRAME_ON_PO_ZD : PROCESS(SOut_zd, SIOut_zd, HOLDNeg_pullup)
    BEGIN
        IF (HOLDNeg_pullup = '0' AND QUAD /= '1') THEN
            hold_mode := TRUE;
            SIOut_z <= 'Z';
            SOut_z  <= 'Z';
        ELSE
            IF hold_mode THEN
                SIOut_z <= SIOut_zd AFTER tpd_HOLDNeg_SO(trz0);
                SOut_z  <= SOut_zd AFTER tpd_HOLDNeg_SO(trz0);
                hold_mode := FALSE;
            ELSE
                SIOut_z <= SIOut_zd;
                SOut_z  <= SOut_zd;
                hold_mode := FALSE;
            END IF;
        END IF;
    END PROCESS HOLD_FRAME_ON_PO_ZD;

    HOLD_PULL_UP : PROCESS(HOLDNegIn)
    BEGIN
        IF (QUAD = '0') THEN
            IF (HOLDNegIn = 'Z') THEN
                HOLDNeg_pullup <= '1';
            ELSE
                HOLDNeg_pullup <= HOLDNegIn;
            END IF;
        END IF;
    END PROCESS HOLD_PULL_UP;

    WP_PULL_UP : PROCESS(WPNegIn)
    BEGIN
        IF (QUAD = '0') THEN
            IF (WPNegIn = 'Z') THEN
                WPNeg_pullup <= '1';
            ELSE
                WPNeg_pullup <= WPNegIn;
            END IF;
        END IF;
    END PROCESS WP_PULL_UP;

    RST_PULL_UP : PROCESS(RSTNeg)
    BEGIN
        IF (RSTNeg = 'Z') THEN
            RSTNeg_pullup <= '1';
        ELSE
            RSTNeg_pullup <= RSTNeg;
        END IF;
    END PROCESS RST_PULL_UP;

    ---------------------------------------------------------------------------
    ---- File Read Section - Preload Control
    ---------------------------------------------------------------------------
    MemPreload : PROCESS

        -- text file input variables
        FILE mem_file         : text  is  mem_file_name;
        FILE otp_file         : text  is  otp_file_name;
        VARIABLE ind          : NATURAL RANGE 0 TO AddrRANGE := 0;
        VARIABLE otp_ind      : NATURAL RANGE 16#000# TO 16#3FF# := 16#000#;
        VARIABLE buf          : line;

    BEGIN
    ---------------------------------------------------------------------------
    --s25fl256s memory preload file format
-----------------------------------
    ---------------------------------------------------------------------------
    --   /       - comment
    --   @aaaaaa - <aaaaaa> stands for address
    --   dd      - <dd> is byte to be written at Mem(aaaaaa++)
    --             (aaaaaa is incremented at every load)
    --   only first 1-7 columns are loaded. NO empty lines !!!!!!!!!!!!!!!!
    ---------------------------------------------------------------------------

         -- memory preload
        IF (mem_file_name /= "none" AND UserPreload) THEN
            ind := 0;
            Mem := (OTHERS => MaxData);
            WHILE (not ENDFILE (mem_file)) LOOP
                READLINE (mem_file, buf);
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

    ---------------------------------------------------------------------------
    --s25fl256s_otp memory preload file format
    ---------------------------------------------------------------------------
    --   /       - comment
    --   @aaa - <aaa> stands for address
    --   dd      - <dd> is byte to be written at OTPMem(aaa++)
    --             (aaa is incremented at every load)
    --   only first 1-4 columns are loaded. NO empty lines !!!!!!!!!!!!!!!!
    ---------------------------------------------------------------------------

         -- memory preload
        IF (otp_file_name /= "none" AND UserPreload) THEN
            otp_ind := 16#000#;
            OTPMem := (OTHERS => MaxData);
            WHILE (not ENDFILE (otp_file)) LOOP
                READLINE (otp_file, buf);
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
                    OTPMem(otp_ind) := h(buf(1 to 2));
                    otp_ind := otp_ind + 1;
                END IF;
            END LOOP;
        END IF;

        LOCK_BYTE1 := to_slv(OTPMem(16#10#),8);
        LOCK_BYTE2 := to_slv(OTPMem(16#11#),8);
        LOCK_BYTE3 := to_slv(OTPMem(16#12#),8);
        LOCK_BYTE4 := to_slv(OTPMem(16#13#),8);

        WAIT;
    END PROCESS MemPreload;

    ----------------------------------------------------------------------------
    -- Path Delay Section
    ----------------------------------------------------------------------------

    S_Out_PathDelay_Gen : PROCESS(SOut_z)

            VARIABLE SO_GlitchData : VitalGlitchDataType;
        BEGIN
            VitalPathDelay01Z (
                OutSignal       => SOut,
                OutSignalName   => "SO",
                OutTemp         => SOut_z,
                Mode            => VitalTransport,
                GlitchData      => SO_GlitchData,
                Paths           => (
                    0 => (InputChangeTime => SCK_ipd'LAST_EVENT,
                        PathDelay => VitalExtendtofillDelay(tpd_SCK_SO_normal),
                        PathCondition   => NOT(ddr)),
                    1 => (InputChangeTime => SCK_ipd'LAST_EVENT,
                        PathDelay   => VitalExtendtofillDelay(tpd_SCK_SO_DDR),
                        PathCondition   => (ddr OR fast_rd)),
                    2 => (InputChangeTime => CSNeg_ipd'LAST_EVENT,
                        PathDelay       => tpd_CSNeg_SO,
                        PathCondition   => CSNeg_ipd = '1'),
                    3 => (InputChangeTime => HOLDNegIn'LAST_EVENT,
                        PathDelay       => tpd_HOLDNeg_SO,
                        PathCondition   => QUAD = '0')
                )
            );
        END PROCESS;

    SI_Out_PathDelay : PROCESS(SIOut_z)

            VARIABLE SI_GlitchData : VitalGlitchDataType;
        BEGIN
            VitalPathDelay01Z (
                OutSignal       => SIOut,
                OutSignalName   => "SI",
                OutTemp         => SIOut_z,
                Mode            => VitalTransport,
                GlitchData      => SI_GlitchData,
                Paths           => (
                    0 => (InputChangeTime => SCK_ipd'LAST_EVENT,
                        PathDelay => VitalExtendtofillDelay(tpd_SCK_SO_normal),
                        PathCondition => dual AND NOT(ddr)),
                    1 => (InputChangeTime => SCK_ipd'LAST_EVENT,
                        PathDelay   => VitalExtendtofillDelay(tpd_SCK_SO_DDR),
                        PathCondition   => dual AND ddr),
                    2 => (InputChangeTime => CSNeg_ipd'LAST_EVENT,
                        PathDelay       => tpd_CSNeg_SO,
                        PathCondition   => CSNeg_ipd = '1'),
                    3 => (InputChangeTime => HOLDNegIn'LAST_EVENT,
                        PathDelay       => tpd_HOLDNeg_SO,
                        PathCondition   => dual AND QUAD = '0')
                )
            );
        END PROCESS;

    HOLD_Out_PathDelay : PROCESS(HOLDNegOut_zd)

            VARIABLE HOLD_GlitchData : VitalGlitchDataType;
        BEGIN
            VitalPathDelay01Z (
                OutSignal       => HOLDNegOut,
                OutSignalName   => "HOLDNeg",
                OutTemp         => HOLDNegOut_zd,
                Mode            => VitalTransport,
                GlitchData      => HOLD_GlitchData,
                Paths           => (
                    0 => (InputChangeTime => SCK_ipd'LAST_EVENT,
                        PathDelay => VitalExtendtofillDelay(tpd_SCK_SO_normal),
                        PathCondition   => dual AND not(ddr) AND QUAD = '1'),
                    1 => (InputChangeTime => SCK_ipd'LAST_EVENT,
                        PathDelay => VitalExtendtofillDelay(tpd_SCK_SO_DDR),
                        PathCondition   => ddr AND QUAD = '1'),
                    2 => (InputChangeTime => CSNeg_ipd'LAST_EVENT,
                        PathDelay       => tpd_CSNeg_SO,
                        PathCondition   => CSNeg_ipd = '1' AND
                                           HOLDNegOut_zd = 'Z' AND QUAD = '1')
                )
            );
        END PROCESS;

    WP_Out_PathDelay : PROCESS(WPNegOut_zd)

            VARIABLE WP_GlitchData : VitalGlitchDataType;
        BEGIN
            VitalPathDelay01Z (
                OutSignal       => WPNegOut,
                OutSignalName   => "WPNeg",
                OutTemp         => WPNegOut_zd,
                Mode            => VitalTransport,
                GlitchData      => WP_GlitchData,
                Paths           => (
                    0 => (InputChangeTime => SCK_ipd'LAST_EVENT,
                        PathDelay => VitalExtendtofillDelay(tpd_SCK_SO_normal),
                        PathCondition   => dual AND not(ddr) AND QUAD = '1'),
                    1 => (InputChangeTime => SCK_ipd'LAST_EVENT,
                        PathDelay => VitalExtendtofillDelay(tpd_SCK_SO_DDR),
                        PathCondition   => ddr AND QUAD = '1'),
                    2 => (InputChangeTime => CSNeg_ipd'LAST_EVENT,
                        PathDelay       => tpd_CSNeg_SO,
                        PathCondition   => CSNeg_ipd = '1' AND
                                           WPNegOut_zd = 'Z' AND QUAD = '1')
                )
            );
        END PROCESS;

    END BLOCK behavior;
END vhdl_behavioral;