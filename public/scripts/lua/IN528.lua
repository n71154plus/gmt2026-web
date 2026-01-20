function Build()
  return New.Product{
    Name = 'IN528',
    Type = 'IN528-GM01',
    Application = 'NoteBook',
    Package = 'WQFN3X3-28',
    Description = 'Integrated Power Supply for TFT-LCD',

    RegisterTable = {
      New.RegisterTable{
  Name = 'PMIC',
  DeviceAddress = { 0x9C, 0x9E },
  FrontDoorRegisters = {
    -- DVCOM
    DVCOM_Delay = New.Register{ Name='DVCOM_Delay', Group='DVCOM', Page='PMIC', Unit='ms', MemI_B0={ Addr=0x19, MSB=6, LSB=2 }, DACValueExpr='[DAC]*5', DAC=0x00 },
    -- Enable
    DVCOM_EN = New.Register{ Name='DVCOM_EN', Group='Enable', Page='PMIC', MemI_B0={ Addr=0x01, MSB=4, LSB=4 }, IsCheckBox=true, DAC=0x00 },
    -- Enable
    GMA_EN = New.Register{ Name='GMA_EN', Group='Enable', Page='PMIC', MemI_B0={ Addr=0x01, MSB=0, LSB=0 }, IsCheckBox=true, DAC=0x00 },
    -- Enable
    HVAA_EN = New.Register{ Name='HVAA_EN', Group='Enable', Page='PMIC', MemI_B0={ Addr=0x00, MSB=4, LSB=4 }, IsCheckBox=true, DAC=0x00 },
    -- Enable
    NTC_EN = New.Register{ Name='NTC_EN', Group='Enable', Page='PMIC', MemI_B0={ Addr=0x01, MSB=5, LSB=5 }, IsCheckBox=true, DAC=0x00 },
    -- Enable
    VAA_EN = New.Register{ Name='VAA_EN', Group='Enable', Page='PMIC', MemI_B0={ Addr=0x00, MSB=0, LSB=0 }, IsCheckBox=true, DAC=0x00 },
    -- Enable
    VCORE_EN = New.Register{ Name='VCORE_EN', Group='Enable', Page='PMIC', MemI_B0={ Addr=0x00, MSB=5, LSB=5 }, IsCheckBox=true, DAC=0x00 },
    -- Enable
    VGH_EN = New.Register{ Name='VGH_EN', Group='Enable', Page='PMIC', MemI_B0={ Addr=0x00, MSB=3, LSB=3 }, IsCheckBox=true, DAC=0x00 },
    -- Enable
    VGL1_EN = New.Register{ Name='VGL1_EN', Group='Enable', Page='PMIC', MemI_B0={ Addr=0x00, MSB=1, LSB=1 }, IsCheckBox=true, DAC=0x00 },
    -- Enable
    VGL2_EN = New.Register{ Name='VGL2_EN', Group='Enable', Page='PMIC', MemI_B0={ Addr=0x00, MSB=2, LSB=2 }, IsCheckBox=true, DAC=0x00 },
    -- Enable
    VIO_EN = New.Register{ Name='VIO_EN', Group='Enable', Page='PMIC', MemI_B0={ Addr=0x00, MSB=6, LSB=6 }, IsCheckBox=true, DAC=0x00 },
    -- Enable
    VLDO_EN = New.Register{ Name='VLDO_EN', Group='Enable', Page='PMIC', MemI_B0={ Addr=0x00, MSB=7, LSB=7 }, IsCheckBox=true, DAC=0x00 },
    -- Enable
    XAO_EN = New.Register{ Name='XAO_EN', Group='Enable', Page='PMIC', MemI_B0={ Addr=0x01, MSB=1, LSB=1 }, IsCheckBox=true, DAC=0x00 },
    -- HVAA
    HVAA_Voltage = New.Register{ Name='HVAA_Voltage', Group='HVAA', Page='PMIC', Unit='V', MemI_B0={ Addr=0x07, MSB=5, LSB=0 }, DACValueExpr='lookup(\r\n  3.5, 3.6, 3.7, 3.8,\r\n  3.85, 3.9, 3.95, 4.0,\r\n  4.05, 4.1, 4.15, 4.2,\r\n  4.25, 4.3, 4.35, 4.4,\r\n  4.45, 4.5, 4.55, 4.6,\r\n  4.65, 4.7, 4.75, 4.8,\r\n  4.85, 4.9, 4.95, 5.0,\r\n  5.05, 5.1, 5.15, 5.2,\r\n  5.25, 5.3, 5.35, 5.4,\r\n  5.45, 5.5, 5.55, 5.6,\r\n  5.65, 5.7, 5.75, 5.8,\r\n  5.85, 5.9, 5.95, 6.0,\r\n  6.05, 6.1, 6.15, 6.2,\r\n  6.25, 6.3, 6.35, 6.4,\r\n  6.45, 6.5, 6.55, 6.6,\r\n  6.65, 6.7, 6.75, 6.8\r\n)', DAC=0x00 },
    -- VAA
    LXA_Frequency = New.Register{ Name='LXA_Frequency', Group='VAA', Page='PMIC', Unit='kHz', MemI_B0={ Addr=0x10, MSB=2, LSB=0 }, DACValueExpr='Select({600,715,800,933,1000,1225},[DAC])', DAC=0x00 },
    -- VAA
    VAA_Delay = New.Register{ Name='VAA_Delay', Group='VAA', Page='PMIC', Unit='ms', MemI_B0={ Addr=0x11, MSB=2, LSB=0 }, DACValueExpr='Select({1,2,3,4,5,6,7,12},[DAC])', DAC=0x00 },
    -- VAA
    VAA_SS = New.Register{ Name='VAA_SS', Group='VAA', Page='PMIC', Unit='ms', MemI_B0={ Addr=0x11, MSB=5, LSB=3 }, DACValueExpr='2+[DAC]*2', DAC=0x00 },
    -- VAA
    VAA_Voltage = New.Register{ Name='VAA_Voltage', Group='VAA', Page='PMIC', Unit='V', MemI_B0={ Addr=0x02, MSB=6, LSB=0 }, DACValueExpr='Min(14,7+[DAC]*0.1)', DAC=0x00 },
    -- VCORE/VIO/LDO
    LXB1_Frequency = New.Register{ Name='LXB1_Frequency', Group='VCORE/VIO/LDO', Page='PMIC', Unit='kHz', MemI_B0={ Addr=0x17, MSB=4, LSB=2 }, DACValueExpr='Select({600,715,800,933,1000,1225},[DAC])', DAC=0x00 },
    -- VCORE/VIO/LDO
    LXB2_Frequency = New.Register{ Name='LXB2_Frequency', Group='VCORE/VIO/LDO', Page='PMIC', Unit='kHz', MemI_B0={ Addr=0x18, MSB=4, LSB=2 }, DACValueExpr='Select({600,715,800,933,1000,1225},[DAC])', DAC=0x00 },
    -- VCORE/VIO/LDO
    VCORE_Voltage = New.Register{ Name='VCORE_Voltage', Group='VCORE/VIO/LDO', Page='PMIC', Unit='V', MemI_B0={ Addr=0x08, MSB=6, LSB=0 }, DACValueExpr='Min(2,0.8+[DAC]*0.05)', DAC=0x00 },
    -- VCORE/VIO/LDO
    VIO_Voltage = New.Register{ Name='VIO_Voltage', Group='VCORE/VIO/LDO', Page='PMIC', Unit='V', MemI_B0={ Addr=0x09, MSB=6, LSB=0 }, DACValueExpr='Min(2.8,1.0+[DAC]*0.05)', DAC=0x00 },
    -- VCORE/VIO/LDO
    VLDO_Delay = New.Register{ Name='VLDO_Delay', Group='VCORE/VIO/LDO', Page='PMIC', Unit='ms', MemI_B0={ Addr=0x19, MSB=1, LSB=0 }, DACValueExpr='Select({0,15,34,45},[DAC])', DAC=0x00 },
    -- VGH
    VGH_Delay = New.Register{ Name='VGH_Delay', Group='VGH', Page='PMIC', Unit='ms', MemI_B0={ Addr=0x15, MSB=2, LSB=0 }, DACValueExpr='Select({2,7,18,25,34,50,100,150},[DAC])', DAC=0x00 },
    -- VGH
    VGH_SS = New.Register{ Name='VGH_SS', Group='VGH', Page='PMIC', Unit='ms', MemI_B0={ Addr=0x15, MSB=4, LSB=3 }, DACValueExpr='2+[DAC]*2', DAC=0x00 },
    -- VGH
    VGH_Voltage = New.Register{ Name='VGH_Voltage', Group='VGH', Page='PMIC', Unit='V', MemI_B0={ Addr=0x05, MSB=5, LSB=0 }, DACValueExpr='Min(36,5+[DAC]*0.5)', DAC=0x00 },
    -- VGH
    VGHT_Voltage = New.Register{ Name='VGHT_Voltage', Group='VGH', Page='PMIC', Unit='V', MemI_B0={ Addr=0x06, MSB=4, LSB=0 }, DACValueExpr='5+[DAC]*1', DAC=0x00 },
    -- VGL
    VGL1_Delay = New.Register{ Name='VGL1_Delay', Group='VGL', Page='PMIC', Unit='ms', MemI_B0={ Addr=0x13, MSB=2, LSB=0 }, DACValueExpr='[DAC]*5', DAC=0x00 },
    -- VGL
    VGL1_Frequency = New.Register{ Name='VGL1_Frequency', Group='VGL', Page='PMIC', Unit='ratio', MemI_B0={ Addr=0x13, MSB=5, LSB=5 }, DAC=0x00 },
    -- VGL
    VGL1_Mode = New.Register{ Name='VGL1_Mode', Group='VGL', Page='PMIC', MemI_B0={ Addr=0x13, MSB=7, LSB=6 }, DAC=0x00 },
    -- VGL
    VGL1_SS = New.Register{ Name='VGL1_SS', Group='VGL', Page='PMIC', Unit='ms', MemI_B0={ Addr=0x13, MSB=4, LSB=3 }, DACValueExpr='2+[DAC]*2', DAC=0x00 },
    -- VGL
    VGL1_Voltage = New.Register{ Name='VGL1_Voltage', Group='VGL', Page='PMIC', Unit='V', MemI_B0={ Addr=0x03, MSB=6, LSB=0 }, DACValueExpr='Max(-14.5,-2-[DAC]*0.1)', DAC=0x00 },
    -- VGL
    VGL2_Delay = New.Register{ Name='VGL2_Delay', Group='VGL', Page='PMIC', Unit='ms', MemI_B0={ Addr=0x14, MSB=2, LSB=0 }, DACValueExpr='[DAC]*5', DAC=0x00 },
    -- VGL
    VGL2_SS = New.Register{ Name='VGL2_SS', Group='VGL', Page='PMIC', Unit='ms', MemI_B0={ Addr=0x14, MSB=4, LSB=3 }, DACValueExpr='2+[DAC]*2', DAC=0x00 },
    -- VGL
    VGL2_Voltage = New.Register{ Name='VGL2_Voltage', Group='VGL', Page='PMIC', Unit='V', MemI_B0={ Addr=0x04, MSB=6, LSB=0 }, DACValueExpr='Max(-14.5,-2-[DAC]*0.1)', DAC=0x00 },
    -- VLDO
    VLDO_Voltage = New.Register{ Name='VLDO_Voltage', Group='VLDO', Page='PMIC', Unit='V', MemI_B0={ Addr=0x0B, MSB=3, LSB=0 }, DACValueExpr='Min(2.8,1.2+[DAC]*0.1)', DAC=0x00 },
    -- XAO
    XAO_Delay = New.Register{ Name='XAO_Delay', Group='XAO', Page='PMIC', Unit='ms', MemI_B0={ Addr=0x1A, MSB=3, LSB=0 }, DACValueExpr='[DAC]*5', DAC=0x00 },
    -- XAO
    XAO_Voltage = New.Register{ Name='XAO_Voltage', Group='XAO', Page='PMIC', Unit='V', MemI_B0={ Addr=0x0F, MSB=2, LSB=0 }, DACValueExpr='2+[DAC]*0.1', DAC=0x00 },
  },
  ChecksumMemIndexCollect = {
    ['Default'] = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D },
    ['WithoutVCOM'] = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D },
  },
  NeedShowMemIndex = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D },
}





      ,
    },
  }
end
