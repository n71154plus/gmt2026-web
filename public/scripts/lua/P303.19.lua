function Build()
  local DLY_2b = { 0, 5, 10, 100 } -- ms (00/01/10/11) :contentReference[oaicite:2]{index=2}
  local VGH_SNS = { 0.1, 0.2, 0.3, 0.4 } -- ohm :contentReference[oaicite:3]{index=3}

  return New.Product{
    Name        = 'P303.29',
    Type        = 'PMIC',
    Application = 'TV',
    Package     = 'TQFN5x5-40',
    Description = table.concat({
      'LCD Bias Power PMIC with MTP.',
      'PMIC I2C address: 0x70(A0=0) / 0x71(A0=1).',
      'DVCOM address: 0x76 only for D_VCOM, and only exists when A0=1.',
      'VCOM buffer: 8-bit coarse (34mV/LSB) + 7-bit fine (17mV/LSB).'
    }, ' '),

    RegisterTable = {
      -- =========================================================
      -- PMIC CONTROL (0x70/0x71)
      -- =========================================================
      New.RegisterTable{
        Name = 'PMIC',
        DeviceAddress = { 0xE0, 0xE2 },
        FrontDoorRegisters = {
          -- AVDD
          AVDD_MOS = New.Register{ Name='AVDD_MOS', Group='AVDD', MemI_B0={ Addr=0x18, MSB=0, LSB=0 }, DACValueExpr='lookup(\'Internal\', \'External\')', DAC=0x00 },
          -- AVDD
          AVDD_SW_Freq = New.Register{ Name='AVDD_SW_Freq', Group='AVDD', Unit='kHz', MemI_B0={ Addr=0x11, MSB=6, LSB=4 }, DACValueExpr='Min(2000000, 500000 + [DAC] * 250000)', DAC=0x00 },
          -- AVDD
          AVDD_Voltage = New.Register{ Name='AVDD', Group='AVDD', Unit='V', MemI_B0={ Addr=0x10, MSB=6, LSB=0 }, DACValueExpr='Min(19.02, 5.63 + Max(0, [DAC] - 20) * 0.13)', DAC=0x00 },
          -- AVDD
          EN_SEPIC = New.Register{ Name='EN_SEPIC', Group='AVDD', MemI_B0={ Addr=0x10, MSB=7, LSB=7 }, IsCheckBox=true, DAC=0x00 },
          -- AVDD
          GD_MOS = New.Register{ Name='GD_MOS', Group='AVDD', MemI_B0={ Addr=0x18, MSB=1, LSB=1 }, DACValueExpr='lookup(\'Internal\', \'External\')', DAC=0x00 },
          -- AVDD
          TSSA = New.Register{ Name='TSSA', Group='AVDD', Unit='ms', MemI_B0={ Addr=0x11, MSB=2, LSB=0 }, DACValueExpr='2 + [DAC] * 2', DAC=0x00 },
          -- Enable
          EN_AVDD = New.Register{ Name='EN_AVDD', Group='Enable', MemI_B0={ Addr=0x17, MSB=0, LSB=0 }, IsCheckBox=true, DAC=0x00 },
          -- Enable
          EN_TVCOM = New.Register{ Name='EN_TVCOM', Group='Enable', MemI_B0={ Addr=0x17, MSB=3, LSB=3 }, IsCheckBox=true, DAC=0x00 },
          -- Enable
          EN_TVGH = New.Register{ Name='EN_TVGH', Group='Enable', MemI_B0={ Addr=0x17, MSB=6, LSB=6 }, IsCheckBox=true, DAC=0x00 },
          -- Enable
          EN_VCOM = New.Register{ Name='EN_VCOM', Group='Enable', MemI_B0={ Addr=0x22, MSB=0, LSB=0 }, IsCheckBox=true, DAC=0x00 },
          -- Enable
          EN_Vcore = New.Register{ Name='EN_Vcore', Group='Enable', MemI_B0={ Addr=0x17, MSB=4, LSB=4 }, IsCheckBox=true, DAC=0x00 },
          -- Enable
          EN_VGH = New.Register{ Name='EN_VGH', Group='Enable', MemI_B0={ Addr=0x17, MSB=2, LSB=2 }, IsCheckBox=true, DAC=0x00 },
          -- Enable
          EN_VGL = New.Register{ Name='EN_VGL', Group='Enable', MemI_B0={ Addr=0x17, MSB=1, LSB=1 }, IsCheckBox=true, DAC=0x00 },
          -- Enable
          EN_Vlogic = New.Register{ Name='EN_Vlogic', Group='Enable', MemI_B0={ Addr=0x17, MSB=5, LSB=5 }, IsCheckBox=true, DAC=0x00 },
          -- Enable
          EN_VSS = New.Register{ Name='EN_VSS', Group='Enable', MemI_B0={ Addr=0x17, MSB=7, LSB=7 }, IsCheckBox=true, DAC=0x00 },
          -- Sequence
          AVDDF_VGL = New.Register{ Name='AVDDF_VGL', Group='Sequence', MemI_B0={ Addr=0x28, MSB=0, LSB=0 }, IsCheckBox=true, DAC=0x00 },
          -- Sequence
          D3D3_delay = New.Register{ Name='3D3_delay', Group='Sequence', MemI_B0={ Addr=0x26, MSB=4, LSB=4 }, IsCheckBox=true, DAC=0x00 },
          -- Sequence
          DLY_3D3 = New.Register{ Name='DLY_3D3', Group='Sequence', Unit='ms', MemI_B0={ Addr=0x26, MSB=1, LSB=0 }, DACValueExpr='lookup(0, 5, 10, 100)', DAC=0x00 },
          -- Sequence
          DLY_A = New.Register{ Name='DLY_A', Group='Sequence', Unit='ms', MemI_B0={ Addr=0x25, MSB=5, LSB=4 }, DACValueExpr='lookup(0, 5, 10, 100)', DAC=0x00 },
          -- Sequence
          DLY_AF = New.Register{ Name='DLY_AF', Group='Sequence', Unit='ms', MemI_B0={ Addr=0x25, MSB=3, LSB=2 }, DACValueExpr='lookup(0, 5, 10, 100)', DAC=0x00 },
          -- Sequence
          DLY_GH = New.Register{ Name='DLY_GH', Group='Sequence', Unit='ms', MemI_B0={ Addr=0x25, MSB=7, LSB=6 }, DACValueExpr='lookup(0, 5, 10, 100)', DAC=0x00 },
          -- Sequence
          DLY_GL = New.Register{ Name='DLY_GL', Group='Sequence', Unit='ms', MemI_B0={ Addr=0x25, MSB=1, LSB=0 }, DACValueExpr='lookup(0, 5, 10, 100)', DAC=0x00 },
          -- Sequence
          EN_pin = New.Register{ Name='EN_pin', Group='Sequence', MemI_B0={ Addr=0x26, MSB=7, LSB=5 }, DACValueExpr='lookup(\'control VCORE\', \'control V3D3\', \'control VGL\', \'control VSS\', \'control AVDD\', \'control VCOM\', \'control VGH\')', DAC=0x00 },
          -- Sequence
          VSS_START = New.Register{ Name='VSS_START', Group='Sequence', MemI_B0={ Addr=0x26, MSB=3, LSB=3 }, DACValueExpr='lookup(\'after VGL\', \'with VGL\')', DAC=0x00 },
          -- Status
          AVDD_NG = New.Register{ Name='AVDD_NG', Group='Status', MemI_B0={ Addr=0x02, MSB=0, LSB=0 }, IsCheckBox=true, ReadOnly=true, DAC=0x00 },
          -- Status
          CheckSum_Error = New.Register{ Name='CheckSum_Error', Group='Status', MemI_B0={ Addr=0xE0, MSB=0, LSB=0 }, IsCheckBox=true, ReadOnly=true, DAC=0x00 },
          -- Status
          OTP = New.Register{ Name='OTP', Group='Status', MemI_B0={ Addr=0x02, MSB=5, LSB=5 }, IsCheckBox=true, ReadOnly=true, DAC=0x00 },
          -- Status
          Sequence_OK = New.Register{ Name='Sequence_OK', Group='Status', MemI_B0={ Addr=0x02, MSB=6, LSB=6 }, IsCheckBox=true, ReadOnly=true, DAC=0x00 },
          -- Status
          Vcore_NG = New.Register{ Name='Vcore_NG', Group='Status', MemI_B0={ Addr=0x02, MSB=4, LSB=4 }, IsCheckBox=true, ReadOnly=true, DAC=0x00 },
          -- Status
          VGH_NG = New.Register{ Name='VGH_NG', Group='Status', MemI_B0={ Addr=0x02, MSB=2, LSB=2 }, IsCheckBox=true, ReadOnly=true, DAC=0x00 },
          -- Status
          VGH_OCP = New.Register{ Name='VGH_OCP', Group='Status', MemI_B0={ Addr=0x02, MSB=7, LSB=7 }, IsCheckBox=true, ReadOnly=true, DAC=0x00 },
          -- Status
          VGL_NG = New.Register{ Name='VGL_NG', Group='Status', MemI_B0={ Addr=0x02, MSB=1, LSB=1 }, IsCheckBox=true, ReadOnly=true, DAC=0x00 },
          -- Status
          Vlogic_NG = New.Register{ Name='Vlogic_NG', Group='Status', MemI_B0={ Addr=0x02, MSB=3, LSB=3 }, IsCheckBox=true, ReadOnly=true, DAC=0x00 },
          -- Status NVM
          NG_status_to_NVM = New.Register{ Name='NG status to NVM', Group='Status NVM', MemI_B0={ Addr=0x27, MSB=1, LSB=1 }, IsCheckBox=true, DAC=0x00 },
          -- Status NVM
          StatusNVM_AVDD_NG = New.Register{ Name='StatusNVM_AVDD_NG', Group='Status NVM', MemI_B0={ Addr=0x03, MSB=0, LSB=0 }, IsCheckBox=true, ReadOnly=true, DAC=0x00 },
          -- Status NVM
          StatusNVM_OTP = New.Register{ Name='StatusNVM_OTP', Group='Status NVM', MemI_B0={ Addr=0x03, MSB=5, LSB=5 }, IsCheckBox=true, ReadOnly=true, DAC=0x00 },
          -- Status NVM
          StatusNVM_Sequence_OK = New.Register{ Name='StatusNVM_Sequence_OK', Group='Status NVM', MemI_B0={ Addr=0x03, MSB=6, LSB=6 }, IsCheckBox=true, ReadOnly=true, DAC=0x00 },
          -- Status NVM
          StatusNVM_Vcore_NG = New.Register{ Name='StatusNVM_Vcore_NG', Group='Status NVM', MemI_B0={ Addr=0x03, MSB=4, LSB=4 }, IsCheckBox=true, ReadOnly=true, DAC=0x00 },
          -- Status NVM
          StatusNVM_VGH_NG = New.Register{ Name='StatusNVM_VGH_NG', Group='Status NVM', MemI_B0={ Addr=0x03, MSB=2, LSB=2 }, IsCheckBox=true, ReadOnly=true, DAC=0x00 },
          -- Status NVM
          StatusNVM_VGH_OCP = New.Register{ Name='StatusNVM_VGH_OCP', Group='Status NVM', MemI_B0={ Addr=0x03, MSB=7, LSB=7 }, IsCheckBox=true, ReadOnly=true, DAC=0x00 },
          -- Status NVM
          StatusNVM_VGL_NG = New.Register{ Name='StatusNVM_VGL_NG', Group='Status NVM', MemI_B0={ Addr=0x03, MSB=1, LSB=1 }, IsCheckBox=true, ReadOnly=true, DAC=0x00 },
          -- Status NVM
          StatusNVM_Vlogic_NG = New.Register{ Name='StatusNVM_Vlogic_NG', Group='Status NVM', MemI_B0={ Addr=0x03, MSB=3, LSB=3 }, IsCheckBox=true, ReadOnly=true, DAC=0x00 },
          -- TempComp
          VGH_Voltage_LT = New.Register{ Name='VGH_Voltage_LT', Group='TempComp', Unit='V', MemI_B0={ Addr=0x14, MSB=4, LSB=0 }, DACValueExpr='0.5 * [DAC] + 24.5 - 44.5 * [VGL_TC_DAC]', DAC=0x00 },
          -- TempComp
          VGL_TC = New.Register{ Name='VGL_TC', Group='TempComp', MemI_B0={ Addr=0x15, MSB=7, LSB=7 }, IsCheckBox=true, DAC=0x00 },
          -- TempComp
          VT_HT = New.Register{ Name='VT_HT', Group='TempComp', Unit='V', MemI_B0={ Addr=0x16, MSB=7, LSB=5 }, DACValueExpr='1.0 + [DAC] * 0.1', DAC=0x00 },
          -- TempComp
          VT_LT = New.Register{ Name='VT_LT', Group='TempComp', Unit='V', MemI_B0={ Addr=0x16, MSB=2, LSB=0 }, DACValueExpr='1.7 + [DAC] * 0.1', DAC=0x00 },
          -- VCOM/VSS
          DVCOM = New.Register{ Name='DVCOM', Group='VCOM/VSS', Unit='V', MemI_B0={ Addr=0x20, MSB=7, LSB=0 }, DACValueExpr='Min(8.75, 0.08 + [DAC] * 0.034)', DAC=0x00 },
          -- VCOM/VSS
          DVCOMLT = New.Register{ Name='DVCOMLT', Group='VCOM/VSS', Unit='V', MemI_B0={ Addr=0x21, MSB=7, LSB=0 }, DACValueExpr='Min(8.75, 0.08 + [DAC] * 0.034)', DAC=0x00 },
          -- VCOM/VSS
          VSS_Voltage = New.Register{ Name='VSS_Voltage', Group='VCOM/VSS', Unit='V', MemI_B0={ Addr=0x22, MSB=4, LSB=1 }, DACValueExpr='-4 + [DAC] * -0.5', DAC=0x00 },
          -- VCORE/VLOGIC
          Sync_3D3 = New.Register{ Name='Sync_3D3', Group='VCORE/VLOGIC', MemI_B0={ Addr=0x26, MSB=2, LSB=2 }, DACValueExpr='lookup(\'non-sync\', \'sync\')', DAC=0x00 },
          -- VCORE/VLOGIC
          Vcore_Freq = New.Register{ Name='Vcore_Freq', Group='VCORE/VLOGIC', Unit='Hz', MemI_B0={ Addr=0x12, MSB=7, LSB=6 }, DACValueExpr='500000 + (1 - [DAC]) * 250000', DAC=0x00 },
          -- VCORE/VLOGIC
          Vcore_Voltage = New.Register{ Name='Vcore_Voltage', Group='VCORE/VLOGIC', Unit='V', MemI_B0={ Addr=0x24, MSB=4, LSB=0 }, DACValueExpr='Min(2.022, 0.968 + [DAC] * 0.034)', DAC=0x00 },
          -- VCORE/VLOGIC
          Vlogic_Voltage = New.Register{ Name='Vlogic_Voltage', Group='VCORE/VLOGIC', Unit='V', MemI_B0={ Addr=0x23, MSB=3, LSB=0 }, DACValueExpr='Min(3.7, 2.2 + [DAC] *0.1 )', DAC=0x00 },
          -- VGL/VGH
          SHD_VGH = New.Register{ Name='SHD_VGH', Group='VGL/VGH', MemI_B0={ Addr=0x19, MSB=6, LSB=6 }, DACValueExpr='lookup(\'0:Shut AVDD+VGH\', \'1:Shut VGL+AVDD+VGH\')', DAC=0x00 },
          -- VGL/VGH
          SHD_VGH_OCP = New.Register{ Name='SHD_VGH_OCP', Group='VGL/VGH', MemI_B0={ Addr=0x19, MSB=5, LSB=5 }, DACValueExpr='lookup(\'Enable Counter\', \'Disable Counter\')', DAC=0x00 },
          -- VGL/VGH
          VGH_OCP_Level = New.Register{ Name='VGH_OCP', Group='VGL/VGH', Unit='V', MemI_B0={ Addr=0x19, MSB=2, LSB=0 }, DACValueExpr='0.2 + [DAC] * 0.022', DAC=0x00 },
          -- VGL/VGH
          VGH_SNS = New.Register{ Name='VGH_SNS', Group='VGL/VGH', Unit='ohm', MemI_B0={ Addr=0x19, MSB=4, LSB=3 }, DACValueExpr='lookup(0.1, 0.2, 0.3, 0.4)', DAC=0x00 },
          -- VGL/VGH
          VGH_Type = New.Register{ Name='VGH Type', Group='VGL/VGH', MemI_B0={ Addr=0x18, MSB=2, LSB=2 }, DACValueExpr='lookup(\'Boost\', \'Charge Pump\')', DAC=0x00 },
          -- VGL/VGH
          VGH_Voltage = New.Register{ Name='VGH_Voltage', Group='VGL/VGH', Unit='V', MemI_B0={ Addr=0x13, MSB=4, LSB=0 }, DACValueExpr='Min(34.0, 19.0 + [DAC] * 0.5)', DAC=0x00 },
          -- VGL/VGH
          VGL_Type = New.Register{ Name='VGL Type', Group='VGL/VGH', MemI_B0={ Addr=0x18, MSB=3, LSB=3 }, DACValueExpr='lookup(\'Inverting\', \'Charge Pump\')', DAC=0x00 },
          -- VGL/VGH
          VGL_Voltage = New.Register{ Name='VGL_Voltage', Group='VGL/VGH', Unit='V', MemI_B0={ Addr=0x15, MSB=5, LSB=0 }, DACValueExpr='Min(-4.0625, -14 + [DAC] * 0.1875)', DAC=0x00 },
          },
        ChecksumMemIndexCollect = {
          Default = {
            0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,
            0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28
            }
          },
        NeedShowMemIndex = {
          0x00,0x01,0x02,0x03,0x04,
          0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,
          0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,
          },
        }
      ,

      -- =========================================================
      -- DVCOM (0x76) : only for D_VCOM_H/L, only when A0=1 :contentReference[oaicite:24]{index=24}
      -- =========================================================
      New.RegisterTable{
        Name = 'DVCOM',
        DeviceAddress = { 0xEC },
        FrontDoorRegisters = {
          -- VCOM
          D_VCOM_Fine = New.Register{ Name='D_VCOM (Fine)', Group='VCOM', Unit='V', MemI_B0={ Addr=0x01, MSB=6, LSB=0 }, DACValueExpr='[DAC] * 0.017', DAC=0x00 },
          },
        }

      }
    }
end
i2capi = {
  -- �N�����O�GI2C �U�F 0x46, 0xff, 0x80
  -- ctx: LuaTconContext ��ҡA���� I2C �ާ@��k
  -- deviceAddress: �˸m��}�]�i��Ѽơ^
  WriteEEPROM = function(ctx, deviceAddress)
  -- �ϥιw�]�˸m��} 0x46�A�ΨϥζǤJ����}
  local addr = deviceAddress or 0xE0

  -- ���g�J��ӼȦs�����]���� C# �� WriteRegistersAsync�^
  ctx.WriteI2C()

  -- �M��g�J�S�w���N�����O�G�g�J 0x80 ����� 0xff
  ctx.WriteI2CByteIndex(addr, 0x00, 0x08)
  end,

  -- Ū���Ȧs���G�ϥ� ReadI2C �|�۰ʩI�s C# �� ReadRegistersAsync
  -- ctx: LuaTconContext ���
  -- deviceAddress: �˸m��}�]�i��ѼơA��ڤW���|�ϥΡA�]���|�ϥ� UI ���������}�^
  ResetEEPROM = function(ctx, deviceAddress)
  local addr = deviceAddress or 0xE0
  ctx.WriteI2CByteIndex(addr, 0x00, 0x10)
  -- �@����O�Y�iŪ���Ҧ��Ȧs���]�|�۰ʨϥ� UI ��������Ȧs�����^
  ctx.ReadI2C()
  end,

  -- �g�J�Ȧs���G�ϥ� WriteI2C �|�۰ʩI�s C# �� WriteRegistersAsync
  -- ctx: LuaTconContext ���
  -- deviceAddress: �˸m��}�]�i��ѼơA��ڤW���|�ϥΡA�]���|�ϥ� UI ���������}�^
  WriteRegisters = function(ctx, deviceAddress)
  -- �@����O�Y�i�g�J�Ҧ��Ȧs���]�|�۰ʨϥ� UI ��������Ȧs�����^
  ctx.WriteI2C()
  end,

  -- �զX�ާ@�d�ҡG��Ū���A�A�g�J�N�����O�A�̫�AŪ��
  ReadWriteRead = function(ctx, deviceAddress)
  -- Ū���Ȧs��
  ctx.ReadI2C()

  -- �g�J�N�����O
  local addr = deviceAddress or 0x46
  ctx.WriteI2CByteIndex(addr, 0xff, 01)

  -- �A��Ū���Ȧs��
  ctx.ReadI2C()
end
}