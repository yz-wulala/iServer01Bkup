// ****************************************************************************
// *                                                                          *
// * C-Sky Microsystems Confidential                                          *
// * -------------------------------                                          *
// * This file and all its contents are properties of C-Sky Microsystems. The *
// * information contained herein is confidential and proprietary and is not  *
// * to be disclosed outside of C-Sky Microsystems except under a             *
// * Non-Disclosure Agreement (NDA).                                          *
// *                                                                          *
// ****************************************************************************
//FILE NAME       : smpu_comp_hit.vp
//AUTHOR          : Tao Jiang
//FUNCTION        : Generate the mask for the address based on the address size
//                : stored in entries then generate the match signal for the
//                : current access.
//RELEASE HISTORY :
//*****************************************************************************
// //&Depend("cpu_cfig.h"); @18
// &ModuleBeg; @19
module smpu_comp_hit(
  biu_pad_haddr,
  biu_pad_hprot,
  smpu_entry,
  smpu_entry0,
  smpu_hit,
  smpu_hsec
);

// &Ports; @20
input   [31:0]  biu_pad_haddr; 
input   [3 :0]  biu_pad_hprot; 
input   [31:0]  smpu_entry;   
input   [31:0]  smpu_entry0;  
output          smpu_hit;     
output          smpu_hsec;    

// &Regs; @21
reg     [22:0]  addr_mask;    

// &Wires; @22
wire            addr_match;   
wire    [31:0]  biu_pad_haddr; 
wire    [3 :0]  biu_pad_hprot; 
wire    [31:0]  smpu_entry;   
wire    [31:0]  smpu_entry0;  
wire            smpu_hit;     
wire            smpu_hsec;    



// &Force("bus", "biu_pad_haddr", 31, 0); @25
// &Force("bus", "biu_pad_hprot", 3, 0); @26

assign smpu_hit =1'b0;
// &Force("nonport", "addr_match"); @32

assign addr_match = {(smpu_entry[0] & !biu_pad_hprot[2]), 
                     (addr_mask[22:0] & biu_pad_haddr[31:9])}
                 ==  { 1'b1, smpu_entry[31:9]};

assign smpu_hsec  = {(smpu_entry0[0] & biu_pad_hprot[2]), 
                     (addr_mask[22:0] & biu_pad_haddr[31:9])}
                 ==  { 1'b1, smpu_entry0[31:9]};

//Generate the address mask for the addr 
// &CombBeg; @44
always @( smpu_entry[4:1])
begin
  case(smpu_entry[4:1])
    4'b0111 : addr_mask[22:0] = 23'h7f_ffff;
    4'b1000 : addr_mask[22:0] = 23'h7f_fffe;
    4'b1001 : addr_mask[22:0] = 23'h7f_fffc;
    default : addr_mask[22:0] = 23'h00_0000;
  endcase
// &CombEnd; @51
end


// &ModuleEnd; @54
endmodule


