function Build()
  return New.Product{
    Name        = 'P102.29',
    Type        = 'PMIC',
    Application = 'NoteBook',
    Package     = '',
    Description = 'P102.29 Power Management IC',
    RegisterTable = {
      New.RegisterTable{
        Name = 'Default',
        DeviceAddress = { 0x46 },
        FrontDoorRegisters = {

          -- Channel Enable
          EN_VCOM  = New.Register{ Name='EN_VCOM',  Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=7, LSB=7 }, IsCheckBox=true, DAC=0x01 },
          EN_LDO   = New.Register{ Name='EN_LDO',   Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=6, LSB=6 }, IsCheckBox=true, DAC=0x01 },
          EN_VCORE = New.Register{ Name='EN_VCORE', Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=5, LSB=5 }, IsCheckBox=true, DAC=0x01 },
          EN_VIO   = New.Register{ Name='EN_VIO',   Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=4, LSB=4 }, IsCheckBox=true, DAC=0x01 },
          EN_VGL   = New.Register{ Name='EN_VGL',   Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=3, LSB=3 }, IsCheckBox=true, DAC=0x01 },
          EN_VGH   = New.Register{ Name='EN_VGH',   Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=2, LSB=2 }, IsCheckBox=true, DAC=0x01 },
          EN_AVEE  = New.Register{ Name='EN_AVEE',  Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=1, LSB=1 }, IsCheckBox=true, DAC=0x01 },
          EN_AVDD  = New.Register{ Name='EN_AVDD',  Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=0, LSB=0 }, IsCheckBox=true, DAC=0x01 },

          -- Channel Setting
          EN_High_Resolution = New.Register{
            Name='EN_High Resolution', Group='Channel Setting',
            MemI_B0={ Addr=0x01, MSB=7, LSB=7 }, IsCheckBox=true, DAC=0x01
          },
          EN_VIO_PWM   = New.Register{ Name='EN_VIO_PWM',   Group='Channel Setting', MemI_B0={ Addr=0x01, MSB=6, LSB=6 }, IsCheckBox=true, DAC=0x01 },
          EN_VCORE_PWM = New.Register{ Name='EN_VCORE_PWM', Group='Channel Setting', MemI_B0={ Addr=0x01, MSB=5, LSB=5 }, IsCheckBox=true, DAC=0x01 },
          PRE_AVDD     = New.Register{ Name='PRE_AVDD',     Group='Channel Setting', MemI_B0={ Addr=0x01, MSB=4, LSB=4 }, IsCheckBox=true, DAC=0x01 },
          EN_CTRL      = New.Register{ Name='EN_CTRL',      Group='Channel Setting', MemI_B0={ Addr=0x01, MSB=3, LSB=3 }, IsCheckBox=true, DAC=0x01 },
          EN_RESET     = New.Register{ Name='EN_RESET',     Group='Channel Setting', MemI_B0={ Addr=0x01, MSB=2, LSB=2 }, IsCheckBox=true, DAC=0x01 },
          EN_GMA2      = New.Register{ Name='EN_GMA2',      Group='Channel Setting', MemI_B0={ Addr=0x01, MSB=1, LSB=1 }, IsCheckBox=true, DAC=0x01 },
          EN_GMA1      = New.Register{ Name='EN_GMA1',      Group='Channel Setting', MemI_B0={ Addr=0x01, MSB=0, LSB=0 }, IsCheckBox=true, DAC=0x01 },

          -- Channel Discharge
          EN_VCOM_Discharge  = New.Register{ Name='EN_VCOM_Discharge',  Group='Channel Discharge', MemI_B0={ Addr=0x02, MSB=7, LSB=7 }, IsCheckBox=true, DAC=0x01 },
          EN_LDO_Discharge   = New.Register{ Name='EN_LDO_Discharge',   Group='Channel Discharge', MemI_B0={ Addr=0x02, MSB=6, LSB=6 }, IsCheckBox=true, DAC=0x01 },
          EN_VIO_Discharge   = New.Register{ Name='EN_VIO_Discharge',   Group='Channel Discharge', MemI_B0={ Addr=0x02, MSB=5, LSB=5 }, IsCheckBox=true, DAC=0x01 },
          EN_VCORE_Discharge = New.Register{ Name='EN_VCORE_Discharge', Group='Channel Discharge', MemI_B0={ Addr=0x02, MSB=4, LSB=4 }, IsCheckBox=true, DAC=0x01 },
          EN_VGL_Discharge   = New.Register{ Name='EN_VGL_Discharge',   Group='Channel Discharge', MemI_B0={ Addr=0x02, MSB=3, LSB=3 }, IsCheckBox=true, DAC=0x01 },
          EN_VGH_Discharge   = New.Register{ Name='EN_VGH_Discharge',   Group='Channel Discharge', MemI_B0={ Addr=0x02, MSB=2, LSB=2 }, IsCheckBox=true, DAC=0x01 },
          EN_AVEE_Discharge  = New.Register{ Name='EN_AVEE_Discharge',  Group='Channel Discharge', MemI_B0={ Addr=0x02, MSB=1, LSB=1 }, IsCheckBox=true, DAC=0x01 },
          EN_AVDD_Discharge  = New.Register{ Name='EN_AVDD_Discharge',  Group='Channel Discharge', MemI_B0={ Addr=0x02, MSB=0, LSB=0 }, IsCheckBox=true, DAC=0x01 },

          -- AVDD / AVEE / DAC-style voltages
          AVDD_Voltage = New.Register{
            Name='AVDD_Voltage', Group='AVDD', Unit='V',
            MemI_B0={ Addr=0x03, MSB=5, LSB=0 },
            DACValueExpr='Min(6.5, 4.0 + [DAC] * 0.05)', DAC=0x00
          },
          AVEE_Voltage = New.Register{
            Name='AVEE_Voltage', Group='AVEE', Unit='V',
            MemI_B0={ Addr=0x04, MSB=4, LSB=0 },
            DACValueExpr='Max(-6.1, -4.0 + [DAC] * -0.1)', DAC=0x00
          },

          -- VGH&&VGL
          VGH_Voltage = New.Register{
            Name='VGH_Voltage', Group='VGH&&VGL', Unit='V',
            MemI_B0={ Addr=0x05, MSB=4, LSB=0 },
            DACValueExpr = '(1 - [EN_High Resolution_DAC]) * Min(12.0, 6.0 + [DAC]*0.2) + [EN_High Resolution_DAC] * (12.5 + [DAC]*0.5)', DAC=0x00
          },
          VGL_Voltage = New.Register{
            Name='VGL_Voltage', Group='VGH&&VGL', Unit='V',
            MemI_B0={ Addr=0x06, MSB=5, LSB=0 },
            DACValueExpr='Max(-18.0, -5.4 + [DAC] * -0.2)', DAC=0x00
          },

          -- VCORE / VIO
          VCORE_Voltage = New.Register{
            Name='VCORE_Voltage', Group='VCORE', Unit='V',
            MemI_B0={ Addr=0x07, MSB=5, LSB=0 },
            DACValueExpr='Min(2.06, 0.8 + [DAC] * 0.02)', DAC=0x00
          },
          VIO_Voltage = New.Register{
            Name='VIO_Voltage', Group='VIO', Unit='V',
            MemI_B0={ Addr=0x08, MSB=4, LSB=0 },
            DACValueExpr='Min(2.55, 1.0 + [DAC] * 0.05)', DAC=0x00
          },

          -- Reset&&LDO
          LDO_Voltage = New.Register{
            Name='LDO_Voltage', Group='Reset&&LDO', Unit='V',
            MemI_B0={ Addr=0x09, MSB=3, LSB=0 },
            DACValueExpr='Min(2.8, 1.7 + [DAC] * 0.1)', DAC=0x00
          },
          RESET_Voltage = New.Register{
            Name='RESET_Voltage', Group='Reset&&LDO', Unit='V',
            MemI_B0={ Addr=0x0B, MSB=2, LSB=0 },
            DACValueExpr='Min(2.7, 2.0 + [DAC] * 0.1)', DAC=0x00
          },

          -- VCOM&&GAMMA
          VCOM_Voltage = New.Register{
            Name='VCOM_Voltage', Group='VCOM&&GAMMA', Unit='V',
            MemI_B0={ Addr=0x0A, MSB=7, LSB=1 },
            DACValueExpr='[VCOM_MIN_Voltage_Value]+[DAC]*0.01', DAC=0x00
          },
          Gamma1_Voltage = New.Register{
            Name='Gamma1_Voltage', Group='VCOM&&GAMMA', Unit='V',
            MemI_B0={ Addr=0x0C, MSB=5, LSB=0 },
            DACValueExpr='[AVDD_Voltage_Value] - [DAC] * 0.02', DAC=0x00
          },
          Gamma2_Voltage = New.Register{
            Name='Gamma2_Voltage', Group='VCOM&&GAMMA', Unit='V',
            MemI_B0={ Addr=0x0D, MSB=5, LSB=0 },
            DACValueExpr='[AVEE_Voltage_Value] + [DAC] * 0.02', DAC=0x00
          },

          -- AVDD config (0x0E/0x0F)
          AVDD_Current_limit = New.Register{
            Name='AVDD Current limit', Group='AVDD', Unit='A',
            MemI_B0={ Addr=0x0E, MSB=7, LSB=6 },
            DACValueExpr='lookup(0.5, 1.0, 1.5, 2.0)', DAC=0x00
          },
          AVDD_LX_Slew_Rate = New.Register{
            Name='AVDD LX_Slew Rate', Group='AVDD',
            MemI_B0={ Addr=0x0E, MSB=5, LSB=3 },
            DACValueExpr="lookup('Level0(Fastest)','Level1','Level2','Level3','Level4','Level5','Level6','Level7(Slowest)')", DAC=0x00
          },
          AVDD_LX_FREQ = New.Register{
            Name='AVDD LX_FREQ', Group='AVDD', Unit='Hz',
            MemI_B0={ Addr=0x0E, MSB=2, LSB=0 },
            DACValueExpr='lookup(600000, 715000, 800000, 933000, 1000000, 1225000, 1225000, 1225000)', DAC=0x00
          },
          AVDD_SS_Time = New.Register{
            Name='AVDD_SS Time', Group='AVDD', Unit='ms',
            MemI_B0={ Addr=0x0F, MSB=6, LSB=4 },
            DACValueExpr='lookup(2, 4, 6, 8, 10, 12, 14, 16)', DAC=0x00
          },
          AVDD_Delay_Time = New.Register{
            Name='AVDD_Delay Time', Group='AVDD', Unit='ms',
            MemI_B0={ Addr=0x0F, MSB=3, LSB=0 },
            DACValueExpr='lookup(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 45, 45, 45, 45, 45, 45)', DAC=0x00
          },

          -- AVEE config (0x10)
          AVEE_FREQ = New.Register{
            Name='AVEE_ FREQ', Group='AVEE',
            MemI_B0={ Addr=0x10, MSB=7, LSB=7 },
            DACValueExpr="lookup('0.5 * AVDD LX','AVDD LX')", DAC=0x00
          },
          AVEE_SS_Time = New.Register{
            Name='AVEE_SS Time', Group='AVEE', Unit='ms',
            MemI_B0={ Addr=0x10, MSB=6, LSB=4 },
            DACValueExpr='lookup(4, 4, 6, 8, 10, 12, 14, 16)', DAC=0x00
          },
          AVEE_Delay_Time = New.Register{
            Name='AVEE_Delay Time', Group='AVEE', Unit='ms',
            MemI_B0={ Addr=0x10, MSB=3, LSB=0 },
            DACValueExpr='lookup(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 45, 45, 45, 45, 45, 45)', DAC=0x00
          },

          -- VGH&&VGL timing (0x11/0x12/0x13)
          LXH_LXN_Slew_Rate = New.Register{
            Name='LXH/LXN_Slew Rate', Group='VGH&&VGL',
            MemI_B0={ Addr=0x11, MSB=4, LSB=3 },
            DACValueExpr="lookup('Fastest','Fast','Normal','Slowest')", DAC=0x00
          },
          LXH_LXN_FREQ = New.Register{
            Name='LXH/LXN_FREQ', Group='VGH&&VGL', Unit='Hz',
            MemI_B0={ Addr=0x11, MSB=2, LSB=0 },
            DACValueExpr='lookup(500000, 600000, 715000, 800000, 933000, 1000000, 1225000, 1430000)', DAC=0x00
          },
          VGH_SS_Time = New.Register{
            Name='VGH_SS Time', Group='VGH&&VGL', Unit='ms',
            MemI_B0={ Addr=0x12, MSB=5, LSB=4 },
            DACValueExpr='lookup(4, 6, 8, 12)', DAC=0x00
          },
          VGH_Delay_Time = New.Register{
            Name='VGH_Delay Time', Group='VGH&&VGL', Unit='ms',
            MemI_B0={ Addr=0x12, MSB=3, LSB=0 },
            DACValueExpr='lookup(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 45, 45, 45, 45, 45, 45)', DAC=0x00
          },
          VGL_SS_Time = New.Register{
            Name='VGL_SS Time', Group='VGH&&VGL', Unit='ms',
            MemI_B0={ Addr=0x13, MSB=6, LSB=4 },
            DACValueExpr='lookup(4, 4, 6, 8, 10, 12, 14, 16)', DAC=0x00
          },
          VGL_Delay_Time = New.Register{
            Name='VGL_Delay Time', Group='VGH&&VGL', Unit='ms',
            MemI_B0={ Addr=0x13, MSB=3, LSB=0 },
            DACValueExpr='lookup(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 45, 45, 45, 45, 45, 45)', DAC=0x00
          },

          -- VCORE timing (0x14/0x15)
          LXB1_Slew_Rate = New.Register{
            Name='LXB1_Slew Rate', Group='VCORE',
            MemI_B0={ Addr=0x14, MSB=4, LSB=3 },
            DACValueExpr="lookup('Fastest','Fast','Normal','Slowest')", DAC=0x00
          },
          LXB1_FREQ = New.Register{
            Name='LXB1_FREQ', Group='VCORE', Unit='Hz',
            MemI_B0={ Addr=0x14, MSB=2, LSB=0 },
            DACValueExpr='lookup(600000, 715000, 800000, 933000, 1000000, 1225000, 1225000, 1225000)', DAC=0x00
          },
          VCORE_SS_Time = New.Register{
            Name='VCORE_SS Time', Group='VCORE', Unit='ms',
            MemI_B0={ Addr=0x15, MSB=5, LSB=4 },
            DACValueExpr='lookup(2, 4, 6, 8)', DAC=0x00
          },
          VCORE_Delay_Time = New.Register{
            Name='VCORE_Delay Time', Group='VCORE', Unit='ms',
            MemI_B0={ Addr=0x15, MSB=3, LSB=0 },
            DACValueExpr='lookup(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 45, 45, 45, 45, 45, 45)', DAC=0x00
          },

          -- VIO timing (0x16/0x17)
          LXB2_Slew_Rate = New.Register{
            Name='LXB2_Slew Rate', Group='VIO',
            MemI_B0={ Addr=0x16, MSB=4, LSB=3 },
            DACValueExpr="lookup('Fastest','Fast','Normal','Slowest')", DAC=0x00
          },
          LXB2_FREQ = New.Register{
            Name='LXB2_FREQ', Group='VIO', Unit='Hz',
            MemI_B0={ Addr=0x16, MSB=2, LSB=0 },
            DACValueExpr='lookup(600000, 715000, 800000, 933000, 1000000, 1225000, 1225000, 1225000)', DAC=0x00
          },
          VIO_Power_off_Selection = New.Register{
            Name='VIO Power off Selection', Group='VIO',
            MemI_B0={ Addr=0x17, MSB=6, LSB=6 },
            DACValueExpr="lookup('VIN_UVLO_F','RESET')", DAC=0x00
          },
          VIO_SS_Time = New.Register{
            Name='VIO_SS Time', Group='VIO', Unit='ms',
            MemI_B0={ Addr=0x17, MSB=5, LSB=4 },
            DACValueExpr='lookup(2, 4, 6, 8)', DAC=0x00
          },
          VIO_Delay_Time = New.Register{
            Name='VIO_Delay Time', Group='VIO', Unit='ms',
            MemI_B0={ Addr=0x17, MSB=3, LSB=0 },
            DACValueExpr='lookup(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 45, 45, 45, 45, 45, 45)', DAC=0x00
          },

          -- RESET/LDO timing (0x18/0x19)
          RESET_Delay_Time = New.Register{
            Name='RESET_Delay Time', Group='Reset&&LDO', Unit='ms',
            MemI_B0={ Addr=0x18, MSB=3, LSB=0 },
            DACValueExpr='lookup(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75)', DAC=0x00
          },
          LDO_Delay_Time = New.Register{
            Name='LDO_Delay Time', Group='Reset&&LDO', Unit='ms',
            MemI_B0={ Addr=0x19, MSB=3, LSB=0 },
            DACValueExpr='lookup(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 45, 45, 45, 45, 45, 45)', DAC=0x00
          },

          -- VCOM delay / power off (0x1A)
          VCOM_Delay_Time = New.Register{
            Name='VCOM_Delay Time', Group='VCOM&&GAMMA', Unit='ms',
            MemI_B0={ Addr=0x1A, MSB=4, LSB=0 },
            DACValueExpr='Min(155, [DAC] * 5)', DAC=0x00
          },
          VCOM_Power_off_Selection = New.Register{
            Name='VCOM Power off Selection', Group='VCOM&&GAMMA',
            MemI_B0={ Addr=0x1A, MSB=5, LSB=5 },
            DACValueExpr="lookup('VIN_UVLO_F','RESET')", DAC=0x00
          },

          -- VCOM_MIN (0x1C)
          VCOM_MIN_Voltage = New.Register{
            Name='VCOM_MIN_Voltage', Group='VCOM&&GAMMA', Unit='V',
            MemI_B0={ Addr=0x1C, MSB=4, LSB=0 },
            DACValueExpr="lookup(-3.6, -3.6, -3.6, -3.45, -3.3, -3.15, -3.0, -2.85, -2.7, -2.55, -2.4, -2.25, -2.1, -1.95, -1.8, -1.65, -1.5, -1.35, -1.2, -1.05, -0.9, -0.75, -0.6, -0.45, -0.3, -0.15, 0.0, 0.15, 0.3, 0.45, 0.6, 0.75)",
            DAC=0x00
          },
        },

        ChecksumMemIndexCollect = {
          Default = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C }
        },
        NeedShowMemIndex = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C }
      }
    }
  }
end
