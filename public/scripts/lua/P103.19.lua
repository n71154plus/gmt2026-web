function Build()
  return New.Product{
    Name        = 'P103.19',
    Type        = 'PMIC',
    Application = 'NoteBook',
    Package     = '',
    Description = 'P103.19 Power Management IC',
    RegisterTable = {
      New.RegisterTable{
        Name = 'Default',
        DeviceAddress = { 0xE8 },
        FrontDoorRegisters = {

          -- Channel Enable
          EN_GPM   = New.Register{ Name='EN_GPM',   Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=5, LSB=5 }, IsCheckBox=true, DAC=0x01 },
          EN_RESET = New.Register{ Name='EN_RESET', Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=4, LSB=4 }, IsCheckBox=true, DAC=0x01 },
          EN_VCOM2 = New.Register{ Name='EN_VCOM2', Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=3, LSB=3 }, IsCheckBox=true, DAC=0x01 },
          EN_VCOM1 = New.Register{ Name='EN_VCOM1', Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=2, LSB=2 }, IsCheckBox=true, DAC=0x01 },
          EN_LDO   = New.Register{ Name='EN_LDO',   Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=1, LSB=1 }, IsCheckBox=true, DAC=0x01 },
          EN_AVDD  = New.Register{ Name='EN_AVDD',  Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=0, LSB=0 }, IsCheckBox=true, DAC=0x01 },

          -- AVDD
          AVDD_Voltage = New.Register{
            Name='AVDD_Voltage', Group='AVDD', Unit='V',
            MemI_B0={ Addr=0x01, MSB=6, LSB=0 },
            DACValueExpr='Min(11.0, 4.5 + [DAC] * 0.1)', DAC=0x00
          },
          AVDD_LX_Slew_Rate = New.Register{
            Name='AVDD LX_Slew Rate', Group='AVDD',
            MemI_B0={ Addr=0x02, MSB=2, LSB=0 },
            DACValueExpr='lookup(3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5)', DAC=0x00
          },
          AVDD_LX_FREQ = New.Register{
            Name='AVDD LX_FREQ', Group='AVDD', Unit='Hz',
            MemI_B0={ Addr=0x02, MSB=4, LSB=3 },
            DACValueExpr='lookup(600000, 800000, 1000000, 1200000)', DAC=0x00
          },
          AVDD_SS_Time = New.Register{
            Name='AVDD_SS Time', Group='AVDD', Unit='ms',
            MemI_B0={ Addr=0x03, MSB=1, LSB=0 },
            DACValueExpr='lookup(5, 10, 15, 20)', DAC=0x00
          },
          AVDD_Delay_Time = New.Register{
            Name='AVDD_Delay Time', Group='AVDD', Unit='ms',
            MemI_B0={ Addr=0x03, MSB=4, LSB=2 },
            DACValueExpr='lookup(0, 5, 10, 15, 20, 25, 30)', DAC=0x00
          },
          AVDD_Current_limit = New.Register{
            Name='AVDD Current limit', Group='AVDD', Unit='A',
            MemI_B0={ Addr=0x03, MSB=5, LSB=5 },
            DACValueExpr='lookup(1, 2)', DAC=0x00
          },

          -- VCOM
          VCOM1_Medium_Voltage = New.Register{
            Name='VCOM1_Medium_Voltage', Group='VCOM', Unit='V',
            MemI_B0={ Addr=0x04, MSB=7, LSB=0 },
            DACValueExpr="lookup("
              .. "0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,"
              .. "0.8,0.82,0.84,0.86,0.88,0.9,0.92,0.94,0.96,0.98,1.0,1.02,1.04,1.06,1.08,1.1,1.12,1.14,1.16,1.18,"
              .. "1.2,1.22,1.24,1.26,1.28,1.3,1.32,1.34,1.36,1.38,1.4,1.42,1.44,1.46,1.48,1.5,1.52,1.54,1.56,1.58,"
              .. "1.6,1.62,1.64,1.66,1.68,1.7,1.72,1.74,1.76,1.78,1.8,1.82,1.84,1.86,1.88,1.9,1.92,1.94,1.96,1.98,"
              .. "2.0,2.02,2.04,2.06,2.08,2.1,2.12,2.14,2.16,2.18,2.2,2.22,2.24,2.26,2.28,2.3,2.32,2.34,2.36,2.38,"
              .. "2.4,2.42,2.44,2.46,2.48,2.5,2.52,2.54,2.56,2.58,2.6,2.62,2.64,2.66,2.68,2.7,2.72,2.74,2.76,2.78,"
              .. "2.8,2.82,2.84,2.86,2.88,2.9,2.92,2.94,2.96,2.98,3.0,3.02,3.04,3.06,3.08,3.1,3.12,3.14,3.16,3.18,"
              .. "3.2,3.22,3.24,3.26,3.28,3.3,3.32,3.34,3.36,3.38,3.4,3.42,3.44,3.46,3.48,3.5,3.52,3.54,3.56,3.58,"
              .. "3.6,3.62,3.64,3.66,3.68,3.7,3.72,3.74,3.76,3.78,3.8,3.82,3.84,3.86,3.88,3.9,3.92,3.94,3.96,3.98,"
              .. "4.0,4.02,4.04,4.06,4.08,4.1,4.12,4.14,4.16,4.18,4.2,4.22,4.24,4.26,4.28,4.3,4.32,4.34,4.36,4.38,"
              .. "4.4,4.42,4.44,4.46,4.48,4.5,4.52,4.54,4.56,4.58,4.6,4.62,4.64,4.66,4.68,4.7,4.72,4.74,4.76,4.78,"
              .. "4.8,4.82,4.84,4.86,4.88,4.9,4.92,4.94,4.96,4.98,5.0,5.02,5.04,5.06,5.08,5.1,5.12,5.14,5.16,5.18,"
              .. "5.2,5.22,5.24,5.26,5.28,5.3,5.32,5.34,5.36,5.38,5.4,5.42,5.44,5.46,5.48,5.5"
              .. ")", DAC=0x00
          },
          VCOM_Delay_Time = New.Register{
            Name='VCOM_Delay Time', Group='VCOM', Unit='ms',
            MemI_B0={ Addr=0x05, MSB=4, LSB=2 },
            DACValueExpr='lookup(0, 5, 10, 15, 20, 25, 30)', DAC=0x00
          },

          -- LDO
          LDO_Voltage = New.Register{
            Name='LDO_Voltage', Group='LDO', Unit='V',
            MemI_B0={ Addr=0x06, MSB=4, LSB=0 },
            DACValueExpr='Min(2.8, 1.2 + [DAC] * 0.1)', DAC=0x00
          },
          LDO_Delay_Time = New.Register{
            Name='LDO_Delay Time', Group='LDO', Unit='ms',
            MemI_B0={ Addr=0x06, MSB=6, LSB=5 },
            DACValueExpr='lookup(0, 2, 4, 6)', DAC=0x00
          },

          -- VGHM
          VGHM_Delay_Time = New.Register{
            Name='VGHM_Delay Time', Group='VGHM', Unit='ms',
            MemI_B0={ Addr=0x07, MSB=3, LSB=0 },
            DACValueExpr='Min(60, [DAC] * 4)', DAC=0x00
          },

          -- RESET
          Reset_Voltage = New.Register{
            Name='Reset_Voltage', Group='RESET', Unit='V',
            MemI_B0={ Addr=0x09, MSB=3, LSB=0 },
            DACValueExpr='Min(2.5, 1.6 + [DAC] * 0.1)', DAC=0x00
          },
          RESET_Delay_Time = New.Register{
            Name='RESET_Delay Time', Group='RESET', Unit='ms',
            MemI_B0={ Addr=0x0A, MSB=5, LSB=0 },
            DACValueExpr='Min(40, [DAC] + 1)', DAC=0x00
          },

          -- Un-Used
          _0x08_70 = New.Register{
            Name='0x08_70', Group='Un-Used',
            MemI_B0={ Addr=0x08, MSB=7, LSB=0 },
            DACValueExpr='Min(255, [DAC])', DAC=0x00
          },
        },

        ChecksumMemIndexCollect = {
          Default = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A }
        },
        NeedShowMemIndex = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A }
      }
    }
  }
end
