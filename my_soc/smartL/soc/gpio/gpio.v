// *                                                                           *
// * C-Sky Microsystems Confidential                                           *
// * -------------------------------                                           *
// * This file and all its contents are properties of C-Sky Microsystems. The  *
// * information contained herein is confidential and proprietary and is not   *
// * to be disclosed outside of C-Sky Microsystems except under a              *
// * Non-Disclosure Agreement (NDA).                                           *
// *                                                                           *
// *****************************************************************************
// FILE NAME       : gpio
// AUTHOR          : Yande Xiang
// ORIGINAL TIME   :
// FUNCTION        : gpio top module
// RESET           : asynchronism
// DFT             :
// DFP             :
// VERIFICATION    :
// RELEASE HISTORY :
// *****************************************************************************


// &ModuleBeg; @22
module gpio(
  gpio_porta_oe,
  gpio_porta_out,
  gpio_porta_in,
  gpio_intr,
  paddr,
  pclk,
  pclk_intr,
  penable,
  prdata,
  presetn,
  psel,
  pwdata,
  pwrite
);


input   [6 :2]  paddr;             
input           pclk;              
input           pclk_intr;         
input           penable;           
input           presetn;           
input           psel;              
input   [31:0]  pwdata;            
input           pwrite;            
output  [7 :0]  gpio_intr;         
output  [31:0]  prdata;            
output  [7 :0]  gpio_porta_oe;  
output  [7 :0]  gpio_porta_out;  
input   [7 :0]  gpio_porta_in;  


wire    [7 :0]  gpio_porta_oe;  
wire    [7 :0]  gpio_porta_out;  
wire    [7 :0]  gpio_porta_in;  
wire    [7 :0]  gpio_ext_porta;    
wire    [7 :0]  gpio_ext_porta_rb; 
wire    [7 :0]  gpio_int_polarity; 
wire    [7 :0]  gpio_inten;        
wire    [7 :0]  gpio_intmask;      
wire    [7 :0]  gpio_intr;         
wire            gpio_intr_flag_int; 
wire            gpio_intrclk_en;   
wire    [7 :0]  gpio_intstatus;    
wire    [7 :0]  gpio_inttype_level; 
wire            gpio_ls_sync;      
wire    [7 :0]  gpio_porta_ddr;    
wire    [7 :0]  gpio_porta_dr;     
wire    [7 :0]  gpio_porta_eoi;    
wire    [7 :0]  gpio_porta_oe;     
wire    [7 :0]  gpio_raw_intstatus; 
wire    [7 :0]  gpio_swporta_ctl;  
wire    [7 :0]  gpio_swporta_ddr;  
wire    [7 :0]  gpio_swporta_dr;   
wire    [6 :2]  paddr;             
wire            pclk;              
wire            pclk_intr;         
wire            penable;           
wire    [31:0]  prdata;            
wire            presetn;           
wire            psel;              
wire    [31:0]  pwdata;            
wire            pwrite;            


gpio_apbif  x_gpio_apbif (
  .gpio_ext_porta_rb  (gpio_ext_porta_rb ),
  .gpio_int_polarity  (gpio_int_polarity ),
  .gpio_inten         (gpio_inten        ),
  .gpio_intmask       (gpio_intmask      ),
  .gpio_intstatus     (gpio_intstatus    ),
  .gpio_inttype_level (gpio_inttype_level),
  .gpio_ls_sync       (gpio_ls_sync      ),
  .gpio_porta_eoi     (gpio_porta_eoi    ),
  .gpio_raw_intstatus (gpio_raw_intstatus),
  .gpio_swporta_ctl   (gpio_swporta_ctl  ),
  .gpio_swporta_ddr   (gpio_swporta_ddr  ),
  .gpio_swporta_dr    (gpio_swporta_dr   ),
  .paddr              (paddr             ),
  .pclk               (pclk              ),
  .penable            (penable           ),
  .prdata             (prdata            ),
  .presetn            (presetn           ),
  .psel               (psel              ),
  .pwdata             (pwdata            ),
  .pwrite             (pwrite            )
);

gpio_ctrl  x_gpio_ctrl (
  .gpio_ext_porta     (gpio_ext_porta    ),
  .gpio_ext_porta_rb  (gpio_ext_porta_rb ),
  .gpio_int_polarity  (gpio_int_polarity ),
  .gpio_inten         (gpio_inten        ),
  .gpio_intmask       (gpio_intmask      ),
  .gpio_intr          (gpio_intr         ),
  .gpio_intr_flag_int (gpio_intr_flag_int),
  .gpio_intr_int      (gpio_intstatus    ),
  .gpio_intrclk_en    (gpio_intrclk_en   ),
  .gpio_inttype_level (gpio_inttype_level),
  .gpio_ls_sync       (gpio_ls_sync      ),
  .gpio_porta_ddr     (gpio_porta_ddr    ),
  .gpio_porta_dr      (gpio_porta_dr     ),
  .gpio_porta_eoi     (gpio_porta_eoi    ),
  .gpio_raw_intstatus (gpio_raw_intstatus),
  .gpio_swporta_ctl   (gpio_swporta_ctl  ),
  .gpio_swporta_ddr   (gpio_swporta_ddr  ),
  .gpio_swporta_dr    (gpio_swporta_dr   ),
  .pclk               (pclk              ),
  .pclk_intr          (pclk_intr         ),
  .presetn            (presetn           )
);


assign gpio_porta_out[7:0] = gpio_porta_dr[7:0];  
assign gpio_porta_oe[7:0] = gpio_porta_ddr[7:0];
assign gpio_ext_porta[7:0] = gpio_porta_in[7:0];

endmodule


