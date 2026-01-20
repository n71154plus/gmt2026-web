function Build()
  return New.Product{
    Name        = 'S306.19',
    Type        = 'Level Shifter',
    Application = 'TV',
    Package     = '',
    Description = 'S306.19 Level Shifter / OCP / ST2 control IC',

    RegisterTable = {
      New.RegisterTable{
        Name = 'Default',
        DeviceAddress = { 0xA0, 0xA2, 0xA4, 0xA6 },

        FrontDoorRegisters = {
          -- Error OCP Status
          Error_HC_OCP   = New.Register{ Name='Error_HC OCP',   Group='Error OCP Status', MemI_B0={ Addr=0x12, MSB=7, LSB=7 }, IsCheckBox=true, DAC=0x01, ReadOnly=true },
          Error_ST_OCP   = New.Register{ Name='Error_ST OCP',   Group='Error OCP Status', MemI_B0={ Addr=0x12, MSB=6, LSB=6 }, IsCheckBox=true, DAC=0x01, ReadOnly=true },
          Error_LC_OCP   = New.Register{ Name='Error_LC OCP',   Group='Error OCP Status', MemI_B0={ Addr=0x12, MSB=5, LSB=5 }, IsCheckBox=true, DAC=0x01, ReadOnly=true },
          Error_VSSG_OCP = New.Register{ Name='Error_VSSG OCP', Group='Error OCP Status', MemI_B0={ Addr=0x12, MSB=4, LSB=4 }, IsCheckBox=true, DAC=0x01, ReadOnly=true },
          Error_VSSQ_OCP = New.Register{ Name='Error_VSSQ OCP', Group='Error OCP Status', MemI_B0={ Addr=0x12, MSB=3, LSB=3 }, IsCheckBox=true, DAC=0x01, ReadOnly=true },
          Error_VGHD_OCP = New.Register{ Name='Error_VGHD_ OCP',Group='Error OCP Status', MemI_B0={ Addr=0x12, MSB=2, LSB=2 }, IsCheckBox=true, DAC=0x01, ReadOnly=true },

          -- Error Status
          Error_SCP      = New.Register{ Name='Error_SCP',              Group='Error Status', MemI_B0={ Addr=0x12, MSB=1, LSB=1 }, IsCheckBox=true, DAC=0x01, ReadOnly=true },
          Error_TOP      = New.Register{ Name='Error_TOP',              Group='Error Status', MemI_B0={ Addr=0x12, MSB=0, LSB=0 }, IsCheckBox=true, DAC=0x01, ReadOnly=true },
          Error_Checksum = New.Register{ Name='Error_Check sum',        Group='Error Status', MemI_B0={ Addr=0x13, MSB=1, LSB=1 }, IsCheckBox=true, DAC=0x01, ReadOnly=true },
          Error_VSSQ_PON = New.Register{ Name='Error_VSSQ Power on',     Group='Error Status', MemI_B0={ Addr=0x13, MSB=0, LSB=0 }, IsCheckBox=true, DAC=0x01, ReadOnly=true },
          Error_YCLK     = New.Register{ Name='Error_YCLK protection',   Group='Error Status', MemI_B0={ Addr=0x14, MSB=2, LSB=2 }, IsCheckBox=true, DAC=0x01, ReadOnly=true },
          Error_MultiYDIO= New.Register{ Name='Error_Multi YDIO',        Group='Error Status', MemI_B0={ Addr=0x14, MSB=1, LSB=1 }, IsCheckBox=true, DAC=0x01, ReadOnly=true },
          Error_VGHD_PON = New.Register{ Name='Error_VGHD Power on',     Group='Error Status', MemI_B0={ Addr=0x14, MSB=0, LSB=0 }, IsCheckBox=true, DAC=0x01, ReadOnly=true },

          -- Power on/off
          VGHD_EN_TH = New.Register{ Name='VGHD_EN_TH', Group='Power on/off', Unit='V',  MemI_B0={ Addr=0x01, MSB=7, LSB=6 }, DACValueExpr="lookup('16','18','20','22')", DAC=0x00 },
          VGHD_Delay = New.Register{ Name='VGHD_Delay', Group='Power on/off', Unit='ms', MemI_B0={ Addr=0x01, MSB=5, LSB=4 }, DACValueExpr="lookup('20','60','80','100')", DAC=0x00 },
          ST_HC_Power_on_Mask = New.Register{ Name='ST/HC_Power on Mask', Group='Power on/off', Unit='ms', MemI_B0={ Addr=0x01, MSB=3, LSB=2 }, DACValueExpr="lookup('20','60','80','100')", DAC=0x00 },

          -- Power and other Function
          VSSQ_OP_EN = New.Register{
            Name='VSSQ OP_EN', Group='Power and other Function',
            MemI_B0={ Addr=0x01, MSB=1, LSB=1 },
            DACValueExpr="lookup('Disbale(VSSQ output Hi-Z)','Enable')", DAC=0x00
          },
          Fault_function = New.Register{
            Name='Fault function', Group='Power and other Function',
            MemI_B0={ Addr=0x01, MSB=0, LSB=0 },
            DACValueExpr="lookup('define to Output (OCP trigger--> Fault pin is low --> shut down P303)','define to Input and Output (OCP trigger -->Fault is low --> shut down P303 & other LS)')",
            DAC=0x00
          },

          -- Power on/off and ST2
          ST2_Power_on_pulse_delay = New.Register{ Name='ST2_Power on pulse delay', Group='Power on/off and ST2', Unit='ms', MemI_B0={ Addr=0x02, MSB=7, LSB=6 }, DACValueExpr="lookup('10','30','40','50')", DAC=0x00 },
          ST2_Power_on_pulse_width = New.Register{ Name='ST2_Power on pulse width', Group='Power on/off and ST2', Unit='us', MemI_B0={ Addr=0x02, MSB=5, LSB=3 }, DACValueExpr="lookup('10','12','14','16','22','30','36','48')", DAC=0x00 },
          ST2_Power_on_Mask = New.Register{ Name='ST2_Power on Mask', Group='Power on/off and ST2', MemI_B0={ Addr=0x02, MSB=2, LSB=2 }, DACValueExpr="lookup('Mode Change mask','ST2 output by auto pulse , don\\'t care YDIO2 input')", DAC=0x00 },

          -- Protection / Channel Setting
          Multi_YDIO_ST2_mask = New.Register{ Name='Multi-YDIO_ST2 mask', Group='Protection', MemI_B0={ Addr=0x02, MSB=1, LSB=1 }, DACValueExpr="lookup('ST2 no mask when Multi-YDIO protect','ST2 mask when Multi-YDIO protect')", DAC=0x00 },
          Mode_Change_mask = New.Register{ Name='Mode Change mask', Group='Channel Setting', MemI_B0={ Addr=0x02, MSB=0, LSB=0 }, DACValueExpr="lookup('Disable','Enable')", DAC=0x00 },

          -- Power on/off and ST2
          ST2_auto_pulse_width = New.Register{ Name='ST2 auto pulse width', Group='Power on/off and ST2', Unit='us', MemI_B0={ Addr=0x03, MSB=7, LSB=5 }, DACValueExpr="lookup('10','12','14','16','22','30','36','48')", DAC=0x00 },
          ST2_outputmode = New.Register{ Name='ST2 outputmode', Group='Power on/off and ST2', MemI_B0={ Addr=0x03, MSB=4, LSB=4 }, DACValueExpr="lookup('ST2 follow YDIO2','ST2 output auto pulse by YDIO2 rising edge trigger')", DAC=0x00 },

          -- Channel Setting
          HC_Phase = New.Register{ Name='HC_Phase', Group='Channel Setting', MemI_B0={ Addr=0x03, MSB=3, LSB=1 }, DACValueExpr="lookup('4 Phase','6 Phase','8 Phase','10 Phase','12 Phase','12 Phase','12 Phase','12 Phase')", DAC=0x00 },
          HC_Roate = New.Register{ Name='HC_Roate', Group='Channel Setting', MemI_B0={ Addr=0x03, MSB=0, LSB=0 }, DACValueExpr="lookup('Norma, HC1-->HC12','Rotate, HC12-->HC1')", DAC=0x00 },

          -- Mode A
          ST2_Mode_A = New.Register{ Name='ST2_Mode(A)', Group='Mode A', MemI_B0={ Addr=0x04, MSB=7, LSB=7 }, DACValueExpr="lookup('ST2 ON (follow YDIO2)','ST2 ON (follow YDIO2)')", DAC=0x00 },
          Multi_line_on_A = New.Register{ Name='Multi-line on (A)', Group='Mode A', MemI_B0={ Addr=0x04, MSB=6, LSB=5 }, DACValueExpr="lookup('1 line on','2 line on','4 line on','4 line on')", DAC=0x00 },
          N_line_pre_charge_A = New.Register{ Name='N line pre-charge (A)', Group='Mode A', MemI_B0={ Addr=0x04, MSB=4, LSB=1 }, DACValueExpr="lookup('No pre-charge','1 line','2 line','3 line','4 line','5 line','6 line','7 line','8 line','9 line','10 line','11 line','11 line','11 line','11 line','11 line')", DAC=0x00 },
          Time_Interval_A = New.Register{ Name='Time Interval (A)', Group='Mode A', MemI_B0={ Addr=0x04, MSB=0, LSB=0 }, DACValueExpr="lookup('No time interval','Sometime interval')", DAC=0x00 },

          -- Mode B
          ST2_Mode_B = New.Register{ Name='ST2_Mode(B)', Group='Mode B', MemI_B0={ Addr=0x05, MSB=7, LSB=7 }, DACValueExpr="lookup('ST2 ON (follow YDIO2)','ST2 ON (follow YDIO2)')", DAC=0x00 },
          Multi_line_on_B = New.Register{ Name='Multi-line on (B)', Group='Mode B', MemI_B0={ Addr=0x05, MSB=6, LSB=5 }, DACValueExpr="lookup('1 line on','2 line on','4 line on','4 line on')", DAC=0x00 },
          N_line_pre_charge_B = New.Register{ Name='N line pre-charge (B)', Group='Mode B', MemI_B0={ Addr=0x05, MSB=4, LSB=1 }, DACValueExpr="lookup('No pre-charge','1 line','2 line','3 line','4 line','5 line','6 line','7 line','8 line','9 line','10 line','11 line','11 line','11 line','11 line','11 line')", DAC=0x00 },
          Time_Interval_B = New.Register{ Name='Time Interval (B)', Group='Mode B', MemI_B0={ Addr=0x05, MSB=0, LSB=0 }, DACValueExpr="lookup('No time interval','Sometime interval')", DAC=0x00 },

          -- Mode A/B OCP Function
          HC_OCP_current_A = New.Register{ Name='HC_OCP current(A)', Group='Mode A OCP Function', MemI_B0={ Addr=0x06, MSB=7, LSB=4 }, DACValueExpr="lookup('Disable','20mA','30mA','40mA','50mA','60mA','70mA','80mA','90mA','100mA','110mA','120mA','130mA','140mA','150mA','160mA')", DAC=0x00 },
          HC_OCP_current_B = New.Register{ Name='HC_OCP current(B)', Group='Mode B OCP Function', MemI_B0={ Addr=0x06, MSB=3, LSB=0 }, DACValueExpr="lookup('Disable','20mA','30mA','40mA','50mA','60mA','70mA','80mA','90mA','100mA','110mA','120mA','130mA','140mA','150mA','160mA')", DAC=0x00 },

          HC_Blanking_Time_A = New.Register{ Name='HC_Blanking Time(A)', Group='Mode A OCP Function', Unit='us', MemI_B0={ Addr=0x07, MSB=7, LSB=5 }, DACValueExpr="lookup('4','5','6','7','8','9','10','11')", DAC=0x00 },
          HC_Denoise_Time_A = New.Register{ Name='HC_Denoise Time(A)', Group='Mode A OCP Function', Unit='us', MemI_B0={ Addr=0x07, MSB=4, LSB=3 }, DACValueExpr="lookup('0.5','1','1.5','2')", DAC=0x00 },
          OCP_global_EN_A = New.Register{ Name='OCP_ global EN(A)', Group='Mode A OCP Function', MemI_B0={ Addr=0x07, MSB=2, LSB=2 }, DACValueExpr="lookup('Disable OCP','Enable OCP')", DAC=0x00 },
          HC_NG_Frame_Criteria = New.Register{ Name='HC_NG Frame Criteria', Group='Protection', Unit='times', MemI_B0={ Addr=0x07, MSB=1, LSB=0 }, DACValueExpr="lookup('8','16','32','64')", DAC=0x00 },

          HC_Blanking_Time_B = New.Register{ Name='HC_Blanking Time(B)', Group='Mode B OCP Function', Unit='us', MemI_B0={ Addr=0x08, MSB=7, LSB=5 }, DACValueExpr="lookup('4','5','6','7','8','9','10','11')", DAC=0x00 },
          HC_Denoise_Time_B = New.Register{ Name='HC_Denoise Time(B)', Group='Mode B OCP Function', Unit='us', MemI_B0={ Addr=0x08, MSB=4, LSB=3 }, DACValueExpr="lookup('0.5','1','1.5','2')", DAC=0x00 },
          OCP_global_EN_B = New.Register{ Name='OCP_ global EN(B)', Group='Mode B OCP Function', MemI_B0={ Addr=0x08, MSB=2, LSB=2 }, DACValueExpr="lookup('Disable OCP','Enable OCP')", DAC=0x00 },
          OCP_Continue_NG_Frame_Counter = New.Register{ Name='OCP Continue NG Frame Counter', Group='Protection', Unit='times', MemI_B0={ Addr=0x08, MSB=1, LSB=0 }, DACValueExpr="lookup('8','16','32','64')", DAC=0x00 },

          -- Global OCP Current
          ST_OCP_current = New.Register{ Name='ST_OCP current', Group='Global OCP Current', MemI_B0={ Addr=0x09, MSB=7, LSB=4 }, DACValueExpr="lookup('Disable','20mA','30mA','40mA','50mA','60mA','70mA','80mA','90mA','100mA','110mA','120mA','130mA','140mA','150mA','160mA')", DAC=0x00 },
          LC_OCP_current = New.Register{ Name='LC_OCP current', Group='Global OCP Current', MemI_B0={ Addr=0x09, MSB=3, LSB=0 }, DACValueExpr="lookup('Disable','20mA','30mA','40mA','50mA','60mA','70mA','80mA','90mA','100mA','110mA','120mA','130mA','140mA','150mA','160mA')", DAC=0x00 },

          -- Global OCP Time Setting
          ST_Blanking_time_high_side = New.Register{ Name='ST_Blanking time_high side', Group='Global OCP Time Setting', Unit='us', MemI_B0={ Addr=0x0A, MSB=7, LSB=6 }, DACValueExpr="lookup('6','8','9','10')", DAC=0x00 },
          ST_Denoise_time_high_side  = New.Register{ Name='ST_Denoise time_high side', Group='Global OCP Time Setting', Unit='us', MemI_B0={ Addr=0x0A, MSB=5, LSB=4 }, DACValueExpr="lookup('0.5','1','1.5','2')", DAC=0x00 },
          ST_Denoise_time_low_side   = New.Register{ Name='ST_Denoise time_low side', Group='Global OCP Time Setting', Unit='us', MemI_B0={ Addr=0x0A, MSB=3, LSB=2 }, DACValueExpr="lookup('4','6','8','10')", DAC=0x00 },
          LC_Denoise_time_high_low_side = New.Register{ Name='LC_Denoise time_high & low side', Group='Global OCP Time Setting', Unit='us', MemI_B0={ Addr=0x0A, MSB=1, LSB=0 }, DACValueExpr="lookup('4','6','8','10')", DAC=0x00 },

          -- Global OCP Current
          VSSQ_OCP_current = New.Register{ Name='VSSQ_OCP current', Group='Global OCP Current', MemI_B0={ Addr=0x0B, MSB=7, LSB=4 }, DACValueExpr="lookup('Disable','20mA','30mA','40mA','50mA','60mA','70mA','80mA','90mA','100mA','110mA','120mA','130mA','140mA','150mA','160mA')", DAC=0x00 },
          VSSG_OCP_current = New.Register{ Name='VSSG_OCP current', Group='Global OCP Current', MemI_B0={ Addr=0x0B, MSB=3, LSB=0 }, DACValueExpr="lookup('Disable','20mA','30mA','40mA','50mA','60mA','70mA','80mA','90mA','100mA','110mA','120mA','130mA','140mA','150mA','160mA')", DAC=0x00 },

          VGHD_OCP_current = New.Register{ Name='VGHD_OCP current', Group='Global OCP Current', MemI_B0={ Addr=0x0C, MSB=7, LSB=4 }, DACValueExpr="lookup('Disable','20mA','30mA','40mA','50mA','60mA','70mA','80mA','90mA','100mA','110mA','120mA','130mA','140mA','150mA','160mA')", DAC=0x00 },

          -- Power on/off
          VGH1_Vth = New.Register{ Name='VGH1_Vth', Group='Power on/off', Unit='V', MemI_B0={ Addr=0x0C, MSB=3, LSB=1 }, DACValueExpr="lookup('6','7','8','9','10','12','14','16')", DAC=0x00 },
          Power_off_Xon = New.Register{ Name='Power off_Xon', Group='Power on/off', MemI_B0={ Addr=0x0C, MSB=0, LSB=0 }, DACValueExpr="lookup('a-Si XON mode','Oxide XON mode')", DAC=0x00 },

          -- Channel Setting
          HC_Slew_Rate_Rising = New.Register{ Name='HC_Slew Rate for Rising Edge', Group='Channel Setting', Unit='V/us', MemI_B0={ Addr=0x0D, MSB=7, LSB=5 }, DACValueExpr="lookup(100,200,400,550,700,1000,1000,1000)", DAC=0x00 },
          HC_Slew_Rate_Falling = New.Register{ Name='HC_Slew Rate for Falling Edge', Group='Channel Setting', Unit='V/us', MemI_B0={ Addr=0x0D, MSB=4, LSB=2 }, DACValueExpr="lookup(100,200,400,550,700,1000,1000,1000)", DAC=0x00 },
          Device = New.Register{ Name='Device', Group='Power and other Function', MemI_B0={ Addr=0x0D, MSB=1, LSB=0 }, DACValueExpr="lookup('Slave','Single Chip','Single Chip','Master')", DAC=0x00 },

          -- Protection / VSSQ Voltage
          Multi_YDIO_Line_Count = New.Register{ Name='Multi-YDIO Line Count', Group='Protection', MemI_B0={ Addr=0x0E, MSB=7, LSB=5 }, DACValueExpr="lookup('Disable','256','512','768','1024','2048','3072','4096')", DAC=0x00 },
          VSSQ_NG = New.Register{
            Name='VSSQ_NG', Group='Protection',
            MemI_B0={ Addr=0x0E, MSB=4, LSB=4 },
            DACValueExpr="lookup('Protection Disable, do nothing','Protection Enable. All channel output is Hi-Z and /Fault pin active output low')",
            DAC=0x00
          },
          VSSQ_Voltage = New.Register{ Name='VSSQ Voltage', Group='Power and other Function', Unit='V', MemI_B0={ Addr=0x0E, MSB=3, LSB=0 }, DACValueExpr="lookup('-6','-6.5','-7','-7.5','-8','-8.5','-9','-9.5','-10','-10.5','-11','-11.5','-12','-12.5','-13','-13.5')", DAC=0x00 },

          -- Charge-Sharing
          Sharing_to_RE_on_time = New.Register{ Name='Sharing to RE on time', Group='Charge-Sharing', Unit='us', MemI_B0={ Addr=0x0F, MSB=6, LSB=4 }, DACValueExpr="lookup('0.5','1.0','1.5','2','2.5','3','3.5','4')", DAC=0x00 },
          Sharing_to_RE_signal  = New.Register{ Name='Sharing to RE signal',  Group='Charge-Sharing', MemI_B0={ Addr=0x0F, MSB=3, LSB=3 }, DACValueExpr="lookup('Internal clock','External clock')", DAC=0x00 },
          Sharing_to_RE_Mode    = New.Register{ Name='Sharing to RE Mode',    Group='Charge-Sharing', MemI_B0={ Addr=0x0F, MSB=2, LSB=1 }, DACValueExpr="lookup('Disable','Rise Edge','Fall Edge','Both')", DAC=0x00 },

          -- OCP Mode Setting / Power on/off
          Oxide_XON_Mode_Selec = New.Register{ Name='Oxide XON Mode Selec', Group='Power on/off', MemI_B0={ Addr=0x10, MSB=3, LSB=3 }, DACValueExpr="lookup('LC1/LC2 without XON(Case1-1)','LC1/LC2 with XON(Case1-2)')", DAC=0x00 },
          ST_OCP_Mode_Select = New.Register{ Name='ST OCP Mode Select', Group='OCP Mode Setting', MemI_B0={ Addr=0x10, MSB=1, LSB=1 }, DACValueExpr="lookup('Blanking/Denoise Mode','One-time detection Mode')", DAC=0x00 },
          HC_OCP_Mode_Select = New.Register{ Name='HC OCP Mode Select', Group='OCP Mode Setting', MemI_B0={ Addr=0x10, MSB=0, LSB=0 }, DACValueExpr="lookup('Blanking/Denoise Mode','One-time detection Mode')", DAC=0x00 },

          -- UN-USED
          UNUSED_0x10_2 = New.Register{ Name='0x10[2:2]', Group='UN-USED', MemI_B0={ Addr=0x10, MSB=2, LSB=2 }, DACValueExpr="lookup(0,1)", DAC=0x00 },
        },

        ChecksumMemIndexCollect = {
          Default = { 0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F,0x10 }
        },

        NeedShowMemIndex = {
          0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F,0x10,
          0x12,0x13,0x14
        },

      }
    }
  }
end
