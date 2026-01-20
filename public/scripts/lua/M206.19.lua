function Build()
  return New.Product{
    Name        = 'M206.19',
    Type        = 'PMIC',
    Application = 'Monitor',
    Package     = 'QFN-24',
    Description = 'M206.19 Power Management IC',
    RegisterTable = {
      New.RegisterTable{
        Name = 'Default',
        DeviceAddress = { 0xE0 },
        FrontDoorRegisters = {
          -- Error Status
          VSSQ_REG_NG = New.Register{ Name='VSSQ_REG_NG', Group='Error Status', MemI_B0={ Addr=0x30, MSB=7, LSB=7 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          VSSG_REG_NG = New.Register{ Name='VSSG_REG_NG', Group='Error Status', MemI_B0={ Addr=0x30, MSB=6, LSB=6 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          VGL_REG_NG = New.Register{ Name='VGL_REG_NG', Group='Error Status', MemI_B0={ Addr=0x30, MSB=5, LSB=5 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          VGH_REG_NG = New.Register{ Name='VGH_REG_NG', Group='Error Status', MemI_B0={ Addr=0x30, MSB=4, LSB=4 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          VLDO_REG_NG = New.Register{ Name='VLDO_REG_NG', Group='Error Status', MemI_B0={ Addr=0x30, MSB=3, LSB=3 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          Vbuck2_REG_NG = New.Register{ Name='Vbuck2_REG_NG', Group='Error Status', MemI_B0={ Addr=0x30, MSB=2, LSB=2 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          Vbuck1_REG_NG = New.Register{ Name='Vbuck1_REG_NG', Group='Error Status', MemI_B0={ Addr=0x30, MSB=1, LSB=1 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          AVDD_REG_NG = New.Register{ Name='AVDD_REG_NG', Group='Error Status', MemI_B0={ Addr=0x30, MSB=0, LSB=0 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          LS_REG_NG = New.Register{ Name='LS_REG_NG', Group='Error Status', MemI_B0={ Addr=0x31, MSB=2, LSB=2 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          Sequence_REG_NG = New.Register{ Name='Sequence_REG_NG', Group='Error Status', MemI_B0={ Addr=0x31, MSB=1, LSB=1 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          OTP_REG_NG = New.Register{ Name='OTP_REG_NG', Group='Error Status', MemI_B0={ Addr=0x31, MSB=0, LSB=0 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          CheckSum_Error = New.Register{ Name='CheckSum Error', Group='Error Status', MemI_B0={ Addr=0x3F, MSB=0, LSB=0 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},

          -- Error Status MTP
          VSSQ_NG = New.Register{ Name='VSSQ_NG', Group='Error Status MTP', MemI_B0={ Addr=0x32, MSB=7, LSB=7 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          VSSG_NG = New.Register{ Name='VSSG_NG', Group='Error Status MTP', MemI_B0={ Addr=0x32, MSB=6, LSB=6 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          VGL_NG = New.Register{ Name='VGL_NG', Group='Error Status MTP', MemI_B0={ Addr=0x32, MSB=5, LSB=5 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          VGH_NG = New.Register{ Name='VGH_NG', Group='Error Status MTP', MemI_B0={ Addr=0x32, MSB=4, LSB=4 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          VLDO_NG = New.Register{ Name='VLDO_NG', Group='Error Status MTP', MemI_B0={ Addr=0x32, MSB=3, LSB=3 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          Vbuck2_NG = New.Register{ Name='Vbuck2_NG', Group='Error Status MTP', MemI_B0={ Addr=0x32, MSB=2, LSB=2 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          Vbuck1_NG = New.Register{ Name='Vbuck1_NG', Group='Error Status MTP', MemI_B0={ Addr=0x32, MSB=1, LSB=1 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          AVDD_NG = New.Register{ Name='AVDD_NG', Group='Error Status MTP', MemI_B0={ Addr=0x32, MSB=0, LSB=0 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          LS_NG = New.Register{ Name='LS_NG', Group='Error Status MTP', MemI_B0={ Addr=0x33, MSB=2, LSB=2 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          Sequence_NG = New.Register{ Name='Sequence_NG', Group='Error Status MTP', MemI_B0={ Addr=0x33, MSB=1, LSB=1 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},
          OTP_NG = New.Register{ Name='OTP_NG', Group='Error Status MTP', MemI_B0={ Addr=0x33, MSB=0, LSB=0 }, IsCheckBox = true, DAC=0x01, ReadOnly=true},

          -- HAVDD
          HAVDD_Voltage = New.Register{ Name='HAVDD Voltage', Group='HAVDD', Unit='V', MemI_B0={ Addr=0x01, MSB=7, LSB=0 }, DACValueExpr='Min(10.0, 3 + [DAC] * 0.05)', DAC=0x46},

          -- Channel Enable
          EN_HAVDD = New.Register{ Name='EN_HVADD', Group='Channel Enable', MemI_B0={ Addr=0x02, MSB=7, LSB=7 }, IsCheckBox = true, DAC=0x01},
          EN_VSSQ = New.Register{ Name='EN_VSSQ', Group='Channel Enable', MemI_B0={ Addr=0x02, MSB=6, LSB=6 }, IsCheckBox = true, DAC=0x01},
          EN_VSSG = New.Register{ Name='EN_VSSG', Group='Channel Enable', MemI_B0={ Addr=0x02, MSB=5, LSB=5 }, IsCheckBox = true, DAC=0x01},
          EN_VGL = New.Register{ Name='EN_VGL', Group='Channel Enable', MemI_B0={ Addr=0x02, MSB=4, LSB=4 }, IsCheckBox = true, DAC=0x01},
          EN_VGH = New.Register{ Name='EN_VGH', Group='Channel Enable', MemI_B0={ Addr=0x02, MSB=3, LSB=3 }, IsCheckBox = true, DAC=0x01},
          EN_Vbuck2 = New.Register{ Name='EN_Vbuck2', Group='Channel Enable', MemI_B0={ Addr=0x02, MSB=2, LSB=2 }, IsCheckBox = true, DAC=0x01},
          EN_Vbuck1 = New.Register{ Name='EN_Vbuck1', Group='Channel Enable', MemI_B0={ Addr=0x02, MSB=1, LSB=1 }, IsCheckBox = true, DAC=0x01},
          EN_AVDD = New.Register{ Name='EN_AVDD', Group='Channel Enable', MemI_B0={ Addr=0x02, MSB=0, LSB=0 }, IsCheckBox = true, DAC=0x01},

          -- Channel Setting/VT/LDO
          HAVDD_POS = New.Register{ Name='HAVDD POS', Group='Channel Setting/VT/LDO', MemI_B0={ Addr=0x03, MSB=6, LSB=6 }, IsCheckBox = true, DAC=0x01},
          AVDD_INT_EXT = New.Register{ Name='AVDD_INT./EXT', Group='Channel Setting/VT/LDO', MemI_B0={ Addr=0x03, MSB=5, LSB=5 }, IsCheckBox = true, DAC=0x01},
          EN_VT = New.Register{ Name='EN_VT', Group='Channel Enable', MemI_B0={ Addr=0x03, MSB=3, LSB=3 }, IsCheckBox = true, DAC=0x01},
          EN_LDO = New.Register{ Name='EN_LDO', Group='Channel Enable', MemI_B0={ Addr=0x03, MSB=2, LSB=2 }, IsCheckBox = true, DAC=0x01},
          EN_OPA2 = New.Register{ Name='EN_OPA2', Group='Channel Enable', MemI_B0={ Addr=0x03, MSB=1, LSB=1 }, IsCheckBox = true, DAC=0x01},
          EN_OPA1 = New.Register{ Name='EN_OPA1', Group='Channel Enable', MemI_B0={ Addr=0x03, MSB=0, LSB=0 }, IsCheckBox = true, DAC=0x01},

          -- XON_Vth (特殊處理，Qs(4, 3, -0.5, "follow VIN UVLO_F", "V"))
          XON_Vth = New.Register{ Name='XON_Vth', Group='Channel Setting/VT/LDO', MemI_B0={ Addr=0x04, MSB=7, LSB=6 }, DACValueExpr="4 + [DAC] * -0.5", DAC=0x00},

          -- AVDD
          TSSA = New.Register{ Name='TSSA', Group='AVDD', Unit='ms', MemI_B0={ Addr=0x04, MSB=3, LSB=3 }, DACValueExpr='10 + [DAC] * 10', DAC=0x00},
          DLY_AVDD = New.Register{ Name='DLY_AVDD', Group='AVDD', Unit='ms', MemI_B0={ Addr=0x04, MSB=2, LSB=0 }, DACValueExpr="lookup(0, 5, 10, 20, 30, 40, 50, 100)", DAC=0x00},
          AVDD_Inductor_Select = New.Register{ Name='AVDD_Inductor_Select', Group='AVDD', Unit='uH', MemI_B0={ Addr=0x05, MSB=7, LSB=6 }, DACValueExpr="lookup(3.3, 4.7, 6.8, 10)", DAC=0x00},
          AVDD_SW_Freq = New.Register{ Name='AVDD_SW_Freq', Group='AVDD', Unit='KHz', MemI_B0={ Addr=0x05, MSB=5, LSB=4 }, DACValueExpr='500 + [DAC] * 250', DAC=0x00},
          Current_limit_AVDD_SNS = New.Register{ Name='Current_limit_AVDD_SNS', Group='AVDD', Unit='mohm', MemI_B0={ Addr=0x05, MSB=3, LSB=3 }, DACValueExpr='50 + [DAC] * -25', DAC=0x00},
          Current_limit_AVDD_EXT = New.Register{ Name='Current limit_AVDD_EXT', Group='AVDD', Unit='V', MemI_B0={ Addr=0x05, MSB=2, LSB=2 }, DACValueExpr='0.125 + [DAC] * 0.075', DAC=0x00},
          Current_limit_AVDD_INT = New.Register{ Name='Current limit_AVDD_INT', Group='AVDD', Unit='A', MemI_B0={ Addr=0x05, MSB=1, LSB=0 }, DACValueExpr='2 + [DAC] * 0.5', DAC=0x00},
          AVDD_Voltage = New.Register{ Name='AVDD Voltage', Group='AVDD', Unit='V', MemI_B0={ Addr=0x06, MSB=6, LSB=0 }, DACValueExpr='Min(18.0, 8 + [DAC] * 0.1)', DAC=0x00},

          -- BUCK2/BUCK1
          DLY_Buck2 = New.Register{ Name='DLY_Buck2', Group='BUCK2', Unit='ms', MemI_B0={ Addr=0x07, MSB=5, LSB=3 }, DACValueExpr="lookup(0, 5, 10, 20, 30, 40, 50, 100)", DAC=0x00},
          DLY_Buck1 = New.Register{ Name='DLY_Buck1', Group='BUCK1', Unit='ms', MemI_B0={ Addr=0x07, MSB=2, LSB=0 }, DACValueExpr="lookup(0, 5, 10, 20, 30, 40, 50, 100)", DAC=0x00},
          Current_limit_Buck2 = New.Register{ Name='Current limit_Buck2', Group='BUCK2', Unit='A', MemI_B0={ Addr=0x08, MSB=7, LSB=6 }, DACValueExpr='1 + [DAC] * 0.5', DAC=0x00},
          Buck2_SW_Freq = New.Register{ Name='Buck2_SW Freq', Group='BUCK2', Unit='KHz', MemI_B0={ Addr=0x08, MSB=5, LSB=4 }, DACValueExpr='500 + [DAC] * 250', DAC=0x00},
          Current_limit_Buck1 = New.Register{ Name='Current limit_Buck1', Group='BUCK1', Unit='A', MemI_B0={ Addr=0x08, MSB=3, LSB=2 }, DACValueExpr='1 + [DAC] * 0.5', DAC=0x00},
          Buck1_SW_Freq = New.Register{ Name='Buck1_SW Freq', Group='BUCK1', Unit='KHz', MemI_B0={ Addr=0x08, MSB=1, LSB=0 }, DACValueExpr='500 + [DAC] * 250', DAC=0x00},
          Buck1_Inductor_Select = New.Register{ Name='Buck1_Inductor_Select', Group='BUCK1', Unit='uH', MemI_B0={ Addr=0x09, MSB=7, LSB=6 }, DACValueExpr="lookup(3.3, 4.7, 6.8, 10)", DAC=0x00},
          Vbuck1_Voltage = New.Register{ Name='Vbuck1 Voltage', Group='BUCK1', Unit='V', MemI_B0={ Addr=0x09, MSB=4, LSB=0 }, DACValueExpr='Min(3.7, 1.2 + [DAC] * 0.1)', DAC=0x00},
          Buck2_Inductor_Select = New.Register{ Name='Buck2_Inductor_Select', Group='BUCK2', Unit='uH', MemI_B0={ Addr=0x0A, MSB=7, LSB=6 }, DACValueExpr="lookup(3.3, 4.7, 6.8, 10)", DAC=0x00},
          Vbuck2_Voltage = New.Register{ Name='Vbuck2 Voltage', Group='BUCK2', Unit='V', MemI_B0={ Addr=0x0A, MSB=5, LSB=0 }, DACValueExpr='Min(3.7, 0.8 + [DAC] * 0.05)', DAC=0x00},
          DLY_LDO = New.Register{ Name='DLY_LDO', Group='Channel Setting/VT/LDO', Unit='ms', MemI_B0={ Addr=0x0B, MSB=7, LSB=5 }, DACValueExpr="lookup(0, 5, 10, 20, 30, 40, 50, 100)", DAC=0x00},
          LDO_Voltage = New.Register{ Name='LDO Voltage', Group='Channel Setting/VT/LDO', Unit='V', MemI_B0={ Addr=0x0B, MSB=4, LSB=0 }, DACValueExpr='Min(3.6, 1.8 + [DAC] * 0.1)', DAC=0x00},

          -- VGH
          DLY_VGH = New.Register{ Name='DLY_VGH', Group='VGH', Unit='ms', MemI_B0={ Addr=0x0C, MSB=3, LSB=2 }, DACValueExpr="lookup(0, 5, 20, 50)", DAC=0x00},
          Current_limit_VGH = New.Register{ Name='Current limit_VGH', Group='VGH', Unit='A', MemI_B0={ Addr=0x0C, MSB=1, LSB=0 }, DACValueExpr='0.75 + [DAC] * 0.25', DAC=0x00},
          VGH_Voltage = New.Register{ Name='VGH Voltage', Group='VGH', Unit='V', MemI_B0={ Addr=0x0D, MSB=5, LSB=0 }, DACValueExpr='Min(34.0, 10 + [DAC] * 0.5)', DAC=0x00},
          VGH_Voltage_LT = New.Register{ Name='VGH Voltage_LT', Group='VGH', Unit='V', MemI_B0={ Addr=0x0E, MSB=5, LSB=0 }, DACValueExpr='Min(40.0, 10 + [DAC] * 0.5)', DAC=0x00},
          VT_HT = New.Register{ Name='VT_HT', Group='Channel Setting/VT/LDO', Unit='V', MemI_B0={ Addr=0x0F, MSB=5, LSB=3 }, DACValueExpr='1 + [DAC] * 0.1', DAC=0x00},
          VT_LT = New.Register{ Name='VT_LT', Group='Channel Setting/VT/LDO', Unit='V', MemI_B0={ Addr=0x0F, MSB=2, LSB=0 }, DACValueExpr='1.7 + [DAC] * 0.1', DAC=0x00},
          SHD_VGH_OCP_Frame = New.Register{ Name='SHD_VGH_OCP Frame', Group='VGH', Unit='frames', MemI_B0={ Addr=0x10, MSB=5, LSB=3 }, DACValueExpr="lookup(1, 2, 4, 8, 16, 32, 64, 128)", DAC=0x00},
          SHD_VGH_OCP_Count = New.Register{ Name='SHD_VGH_OCP Count', Group='VGH', Unit='times', MemI_B0={ Addr=0x10, MSB=2, LSB=1 }, DACValueExpr="lookup(64, 128, 256, 512)", DAC=0x00},
          SHD_VGH_OCP = New.Register{ Name='SHD_VGH_OCP', Group='VGH', MemI_B0={ Addr=0x10, MSB=0, LSB=0 }, DACValueExpr="lookup('Disable', 'Enable')", DAC=0x00},

          -- VGL/VSSQ/VSSG
          VGL_Voltage = New.Register{ Name='VGL Voltage', Group='VGL/VSSQ/VSSG', Unit='V', MemI_B0={ Addr=0x11, MSB=5, LSB=0 }, DACValueExpr='Max(-3.0, -14 + [DAC] * 0.25)', DAC=0x00},
          DLY_VSSG_P = New.Register{ Name='DLY_VSSG_P', Group='VGL/VSSQ/VSSG', MemI_B0={ Addr=0x12, MSB=7, LSB=6 }, DACValueExpr="lookup('Follow VGL', '5ms', '20ms', '50ms')", DAC=0x00},
          VSSG_P_Voltage = New.Register{ Name='VSSG_P Voltage', Group='VGL/VSSQ/VSSG', Unit='V', MemI_B0={ Addr=0x12, MSB=5, LSB=0 }, DACValueExpr='Max(-3.0, -13 + [DAC] * 0.25)', DAC=0x00},
          DLY_VSSQ_P = New.Register{ Name='DLY_VSSQ_P', Group='VGL/VSSQ/VSSG', MemI_B0={ Addr=0x13, MSB=7, LSB=6 }, DACValueExpr="lookup('Follow VGL', '5ms', '20ms', '50ms')", DAC=0x00},
          VSSQ_P_Voltage = New.Register{ Name='VSSQ_P Voltage', Group='VGL/VSSQ/VSSG', Unit='V', MemI_B0={ Addr=0x13, MSB=5, LSB=0 }, DACValueExpr='Max(-3.0, -13 + [DAC] * 0.25)', DAC=0x00},

          -- Level Shift - Power On/Off
          XON_Continued_Time = New.Register{ Name='XON Continued Time', Group='Power On/Off', Page='Level Shift', Unit='ms', MemI_B0={ Addr=0x20, MSB=5, LSB=4 }, DACValueExpr="lookup(4, 8, 16, 32)", DAC=0x00},
          XON_Mode = New.Register{ Name='XON_Mode', Group='Power On/Off', Page='Level Shift', MemI_B0={ Addr=0x20, MSB=3, LSB=3 }, DACValueExpr="lookup('XON behavior continued constant time', 'XON behavior continued until VGH_SSOK and then de-XON')", DAC=0x00},
          ST_HC_Power_on_Mask = New.Register{ Name='ST/HC_Power on Mask', Group='Power On/Off', Page='Level Shift', Unit='ms', MemI_B0={ Addr=0x20, MSB=2, LSB=0 }, DACValueExpr="lookup(20, 100, 120, 140, 160, 180, 200, 300)", DAC=0x00},

          -- Level Shift - Channel Setting
          Multi_line_on = New.Register{ Name='Multi-line on', Group='Channel Setting', Page='Level Shift', MemI_B0={ Addr=0x21, MSB=5, LSB=5 }, DACValueExpr="lookup('1 line on', '2 line on')", DAC=0x00},
          N_line_pre_charge = New.Register{ Name='N line pre-charge', Group='Channel Setting', Page='Level Shift', MemI_B0={ Addr=0x21, MSB=4, LSB=2 }, DACValueExpr="lookup('No pre-charge', '1 line', '2 line', '3 line', '4 line', '5 line', '5 line', '5 line')", DAC=0x00},
          Time_Interval = New.Register{ Name='Time Interval', Group='Channel Setting', Page='Level Shift', MemI_B0={ Addr=0x21, MSB=1, LSB=1 }, DACValueExpr="lookup('No time interval', 'Sometime interval')", DAC=0x00},
          HC_Phase = New.Register{ Name='HC_Phase', Group='Channel Setting', Page='Level Shift', MemI_B0={ Addr=0x21, MSB=0, LSB=0 }, DACValueExpr="lookup('4 Phase', '6 Phase')", DAC=0x00},
          Slew_rate = New.Register{ Name='Slew rate', Group='Channel Setting', Page='Level Shift', MemI_B0={ Addr=0x22, MSB=7, LSB=6 }, DACValueExpr="lookup('Fastest', 'Fast', 'Normal', 'Slow')", DAC=0x00},

          -- Level Shift - Protection
          HC_NG_Frame_Criteria = New.Register{ Name='HC_NG Frame Criteria', Group='Protection', Page='Level Shift', Unit='times', MemI_B0={ Addr=0x22, MSB=5, LSB=4 }, DACValueExpr="lookup(8, 16, 32, 64)", DAC=0x00},
          HC_OCP_current = New.Register{ Name='HC_OCP current', Group='OCP Current', Page='Level Shift', MemI_B0={ Addr=0x22, MSB=3, LSB=0 }, DACValueExpr="lookup('Disable', '20mA', '30mA', '40mA', '50mA', '60mA', '70mA', '80mA', '80mA')", DAC=0x00},
          HC_NG_Frame_Counter = New.Register{ Name='HC_NG Frame Counter', Group='Protection', Page='Level Shift', Unit='frames', MemI_B0={ Addr=0x23, MSB=6, LSB=5 }, DACValueExpr="lookup(8, 16, 32, 64)", DAC=0x00},
          HC_Blanking_Time = New.Register{ Name='HC_Blanking Time', Group='OCP Time Setting', Page='Level Shift', Unit='us', MemI_B0={ Addr=0x23, MSB=4, LSB=2 }, DACValueExpr="lookup(4, 5, 6, 7, 8, 9, 10, 11)", DAC=0x00},
          HC_Denoise_Time = New.Register{ Name='HC_Denoise Time', Group='OCP Time Setting', Page='Level Shift', Unit='us', MemI_B0={ Addr=0x23, MSB=1, LSB=0 }, DACValueExpr="lookup(0.5, 1, 1.5, 2)", DAC=0x00},
          ST_OCP_current = New.Register{ Name='ST_OCP current', Group='OCP Current', Page='Level Shift', MemI_B0={ Addr=0x24, MSB=7, LSB=4 }, DACValueExpr="lookup('Disable', '20mA', '30mA', '40mA', '50mA', '60mA', '70mA', '80mA')", DAC=0x00},
          LC_OCP_current = New.Register{ Name='LC_OCP current', Group='OCP Current', Page='Level Shift', MemI_B0={ Addr=0x24, MSB=3, LSB=0 }, DACValueExpr="lookup('Disable', '20mA', '30mA', '40mA', '50mA', '60mA', '70mA', '80mA')", DAC=0x00},
          ST_Blanking_time_high_side = New.Register{ Name='ST_Blanking time_high side', Group='OCP Time Setting', Page='Level Shift', Unit='us', MemI_B0={ Addr=0x25, MSB=7, LSB=6 }, DACValueExpr="lookup(6, 8, 9, 10)", DAC=0x00},
          ST_Denoise_time_high_side = New.Register{ Name='ST_Denoise time_high side', Group='OCP Time Setting', Page='Level Shift', Unit='us', MemI_B0={ Addr=0x25, MSB=5, LSB=4 }, DACValueExpr="lookup(0.5, 1, 1.5, 2)", DAC=0x00},
          ST_Denoise_time_low_side = New.Register{ Name='ST_Denoise time_low side', Group='OCP Time Setting', Page='Level Shift', Unit='us', MemI_B0={ Addr=0x25, MSB=3, LSB=2 }, DACValueExpr="lookup(4, 6, 8, 10)", DAC=0x00},
          LC_Denoise_time_high_low_side = New.Register{ Name='LC_Denoise time_high & low side', Group='OCP Time Setting', Page='Level Shift', Unit='us', MemI_B0={ Addr=0x25, MSB=1, LSB=0 }, DACValueExpr="lookup(4, 6, 8, 10)", DAC=0x00},
          VSSQ_OCP_current = New.Register{ Name='VSSQ_OCP current', Group='OCP Current', Page='Level Shift', MemI_B0={ Addr=0x26, MSB=7, LSB=4 }, DACValueExpr="lookup('Disable', '20mA', '30mA', '40mA', '50mA', '60mA', '70mA', '80mA')", DAC=0x00},
          VSSG_OCP_current = New.Register{ Name='VSSG_OCP current', Group='OCP Current', Page='Level Shift', MemI_B0={ Addr=0x26, MSB=3, LSB=0 }, DACValueExpr="lookup('Disable', '20mA', '30mA', '40mA', '50mA', '60mA', '70mA', '80mA')", DAC=0x00},
          VSSQ_XON = New.Register{ Name='VSSQ_XON', Group='Power On/Off', Page='Level Shift', MemI_B0={ Addr=0x27, MSB=5, LSB=5 }, DACValueExpr="lookup('Pull to VGH', 'keep in VSSQ_P')", DAC=0x00},
          VSSG_XON = New.Register{ Name='VSSG_XON', Group='Power On/Off', Page='Level Shift', MemI_B0={ Addr=0x27, MSB=4, LSB=4 }, DACValueExpr="lookup('Pull to VGH', 'keep in VSSG_P')", DAC=0x00},
          HC_Rotate = New.Register{ Name='HC_Rotate', Group='Channel Setting', Page='Level Shift', MemI_B0={ Addr=0x27, MSB=3, LSB=3 }, DACValueExpr="lookup('Normal, HC1-->HC6', 'Rotate, HC6-->HC1')", DAC=0x00},
          Multi_YDIO_Line_Count = New.Register{ Name='Multi-YDIO Line Count', Group='Protection', Page='Level Shift', MemI_B0={ Addr=0x27, MSB=2, LSB=0 }, DACValueExpr="lookup('Disable', 256, 512, 768, 1024, 2048, 3072, 4096)", DAC=0x00},

          -- Level Shift - Charge-Sharing
          Sharing_Mode = New.Register{ Name='Sharing Mode', Group='Charge-Sharing', Page='Level Shift', MemI_B0={ Addr=0x28, MSB=7, LSB=6 }, DACValueExpr="lookup('Disable', 'STG_Mode', 'Channel to Channel_Mode')", DAC=0x00},
          STG_Mode = New.Register{ Name='STG Mode', Group='Charge-Sharing', Page='Level Shift', MemI_B0={ Addr=0x28, MSB=5, LSB=4 }, DACValueExpr="lookup('Disable', 'Rise Edge', 'Fall Edge', 'Both')", DAC=0x00},
          STG_on_time = New.Register{ Name='STG on time', Group='Charge-Sharing', Page='Level Shift', Unit='us', MemI_B0={ Addr=0x28, MSB=3, LSB=0 }, DACValueExpr='0.25 + [DAC] * 0.25', DAC=0x00},
          channel_to_channel_setting = New.Register{ Name='channel to channel setting', Group='Charge-Sharing', Page='Level Shift', MemI_B0={ Addr=0x29, MSB=1, LSB=0 }, DACValueExpr="lookup('HC1 to HC2', 'HC1 to HC3', 'HC1 to HC4', 'HC1 to HC5')", DAC=0x00},
        },
        ChecksumMemIndexCollect = {
          Default = { 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29}
        },
        NeedShowMemIndex = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x30, 0x31, 0x32, 0x33, 0x3F}
      }
    }
  }
end
