function Build()
  return New.Product{
    Name = 'P105.19',
    Type = 'PMIC',
    Description = 'P105.19 Power Management IC',
    Application = 'NoteBook',

    RegisterTable = {
      New.RegisterTable{
        Name = 'Default',
      DeviceAddress = { 0x46 },
        FrontDoorRegisters = {
          -- AVDD
      AVDD_Current_limit = New.Register{ Name='AVDD Current limit', Group='AVDD', Unit='A', MemI_B0={ Addr=0x0E, MSB=7, LSB=6 }, DACValueExpr='lookup(0.5, 1.0, 1.5, 2.0)', DAC=0x00 },
          -- AVDD
      AVDD_Delay_Time = New.Register{ Name='AVDD_Delay_Time', Group='AVDD', Unit='ms', MemI_B0={ Addr=0x0F, MSB=3, LSB=0 }, DACValueExpr='lookup(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 45, 45, 45, 45, 45, 45)', DAC=0x00 },
          -- AVDD
      AVDD_LX_FREQ = New.Register{ Name='AVDD LX_FREQ', Group='AVDD', Unit='Hz', MemI_B0={ Addr=0x0E, MSB=2, LSB=0 }, DACValueExpr='lookup(600000, 715000, 800000, 933000, 1000000, 1225000, 1225000, 1225000)', DAC=0x00 },
          -- AVDD
      AVDD_LX_Slew_Rate = New.Register{ Name='AVDD LX_Slew Rate', Group='AVDD', MemI_B0={ Addr=0x0E, MSB=5, LSB=3 }, DACValueExpr='lookup(\'Level0(Fastest)\',\'Level1\',\'Level2\',\'Level3\',\'Level4\',\'Level5\',\'Level6\',\'Level7(Slowest)\')', DAC=0x00 },
          -- AVDD
      AVDD_SS_Time = New.Register{ Name='AVDD_SS_Time', Group='AVDD', Unit='ms', MemI_B0={ Addr=0x0F, MSB=6, LSB=4 }, DACValueExpr='lookup(2, 4, 6, 8, 10, 12, 14, 16)', DAC=0x00 },
          -- AVDD
      AVDD_Voltage = New.Register{ Name='AVDD_Voltage', Group='AVDD', Unit='V', MemI_B0={ Addr=0x03, MSB=5, LSB=0 }, DACValueExpr='Min(7.0, 4.0 + [DAC] * 0.05)', DAC=0x00 },
          -- AVEE
      AVEE_Current_limit = New.Register{ Name='AVEE Current limit', Group='AVEE', Unit='A', MemI_B0={ Addr=0x1B, MSB=4, LSB=3 }, DACValueExpr='lookup(2.5, 2.0, 1.5, 1.0)', DAC=0x00 },
          -- AVEE
      AVEE_Delay_Time = New.Register{ Name='AVEE_Delay_Time', Group='AVEE', Unit='ms', MemI_B0={ Addr=0x10, MSB=3, LSB=0 }, DACValueExpr='lookup(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 45, 45, 45, 45, 45, 45)', DAC=0x00 },
          -- AVEE
      AVEE_LX_Slew_Rate = New.Register{ Name='AVEE LX_Slew Rate', Group='AVEE', MemI_B0={ Addr=0x1B, MSB=6, LSB=5 }, DACValueExpr='lookup(\'Fastest\',\'Fast\',\'Normal\',\'Slowest\')', DAC=0x00 },
          -- AVEE
      AVEE_SS_Time = New.Register{ Name='AVEE_SS_Time', Group='AVEE', Unit='ms', MemI_B0={ Addr=0x10, MSB=6, LSB=4 }, DACValueExpr='lookup(4, 4, 6, 8, 10, 12, 14, 16)', DAC=0x00 },
          -- AVEE
      AVEE_Voltage = New.Register{ Name='AVEE_Voltage', Group='AVEE', Unit='V', MemI_B0={ Addr=0x04, MSB=4, LSB=0 }, DACValueExpr='Max(-7.0, -4.0 + [DAC] * -0.1)', DAC=0x00 },
          -- Channel Discharge
      EN_AVDD_Discharge = New.Register{ Name='EN_AVDD_Discharge', Group='Channel Discharge', MemI_B0={ Addr=0x02, MSB=0, LSB=0 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Discharge
      EN_AVEE_Discharge = New.Register{ Name='EN_AVEE_Discharge', Group='Channel Discharge', MemI_B0={ Addr=0x02, MSB=1, LSB=1 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Discharge
      EN_LDO_Discharge = New.Register{ Name='EN_LDO_Discharge', Group='Channel Discharge', MemI_B0={ Addr=0x02, MSB=6, LSB=6 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Discharge
      EN_VCOM_Discharge = New.Register{ Name='EN_VCOM_Discharge', Group='Channel Discharge', MemI_B0={ Addr=0x02, MSB=7, LSB=7 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Discharge
      EN_VCORE_Discharge = New.Register{ Name='EN_VCORE_Discharge', Group='Channel Discharge', MemI_B0={ Addr=0x02, MSB=4, LSB=4 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Discharge
      EN_VGH_Discharge = New.Register{ Name='EN_VGH_Discharge', Group='Channel Discharge', MemI_B0={ Addr=0x02, MSB=2, LSB=2 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Discharge
      EN_VGL_Discharge = New.Register{ Name='EN_VGL_Discharge', Group='Channel Discharge', MemI_B0={ Addr=0x02, MSB=3, LSB=3 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Discharge
      EN_VIO_Discharge = New.Register{ Name='EN_VIO_Discharge', Group='Channel Discharge', MemI_B0={ Addr=0x02, MSB=5, LSB=5 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Enable
      EN_AVDD = New.Register{ Name='EN_AVDD', Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=0, LSB=0 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Enable
      EN_AVEE = New.Register{ Name='EN_AVEE', Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=1, LSB=1 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Enable
      EN_LDO = New.Register{ Name='EN_LDO', Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=6, LSB=6 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Enable
      EN_VCOM = New.Register{ Name='EN_VCOM', Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=7, LSB=7 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Enable
      EN_VCORE = New.Register{ Name='EN_VCORE', Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=5, LSB=5 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Enable
      EN_VGH = New.Register{ Name='EN_VGH', Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=2, LSB=2 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Enable
      EN_VGL = New.Register{ Name='EN_VGL', Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=3, LSB=3 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Enable
      EN_VIO = New.Register{ Name='EN_VIO', Group='Channel Enable', MemI_B0={ Addr=0x00, MSB=4, LSB=4 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Setting
      EN_CTRL = New.Register{ Name='EN_CTRL', Group='Channel Setting', MemI_B0={ Addr=0x01, MSB=3, LSB=3 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Setting
      EN_GMA1 = New.Register{ Name='EN_GMA1', Group='Channel Setting', MemI_B0={ Addr=0x01, MSB=0, LSB=0 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Setting
      EN_GMA2 = New.Register{ Name='EN_GMA2', Group='Channel Setting', MemI_B0={ Addr=0x01, MSB=1, LSB=1 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Setting
      EN_High_Resolution = New.Register{ Name='EN_High Resolution', Group='Channel Setting', MemI_B0={ Addr=0x01, MSB=7, LSB=7 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Setting
      EN_RESET = New.Register{ Name='EN_RESET', Group='Channel Setting', MemI_B0={ Addr=0x01, MSB=2, LSB=2 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Setting
      EN_VCORE_PWM = New.Register{ Name='EN_VCORE_PWM', Group='Channel Setting', MemI_B0={ Addr=0x01, MSB=5, LSB=5 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Setting
      EN_VIO_PWM = New.Register{ Name='EN_VIO_PWM', Group='Channel Setting', MemI_B0={ Addr=0x01, MSB=6, LSB=6 }, IsCheckBox=true, DAC=0x00 },
          -- Channel Setting
      PRE_AVDD = New.Register{ Name='PRE_AVDD', Group='Channel Setting', MemI_B0={ Addr=0x01, MSB=4, LSB=4 }, IsCheckBox=true, DAC=0x00 },
          -- Reset&&LDO
      LDO_Delay_Time = New.Register{ Name='LDO_Delay_Time', Group='Reset&&LDO', Unit='ms', MemI_B0={ Addr=0x19, MSB=3, LSB=0 }, DACValueExpr='lookup(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 45, 45, 45, 45, 45, 45)', DAC=0x00 },
          -- Reset&&LDO
      LDO_Voltage = New.Register{ Name='LDO_Voltage', Group='Reset&&LDO', Unit='V', MemI_B0={ Addr=0x09, MSB=3, LSB=0 }, DACValueExpr='Min(2.8, 1.7 + [DAC] * 0.1)', DAC=0x00 },
          -- Reset&&LDO
      RESET_Delay_Time = New.Register{ Name='RESET_Delay_Time', Group='Reset&&LDO', Unit='ms', MemI_B0={ Addr=0x18, MSB=3, LSB=0 }, DACValueExpr='lookup(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75)', DAC=0x00 },
          -- Reset&&LDO
      RESET_Voltage = New.Register{ Name='RESET_Voltage', Group='Reset&&LDO', Unit='V', MemI_B0={ Addr=0x0B, MSB=2, LSB=0 }, DACValueExpr='Min(2.7, 2.0 + [DAC] * 0.1)', DAC=0x00 },
          -- VCOM&&GAMMA
      Gamma1_Voltage = New.Register{ Name='Gamma1_Voltage', Group='VCOM&&GAMMA', Unit='V', MemI_B0={ Addr=0x0C, MSB=5, LSB=0 }, DACValueExpr='[AVDD_Voltage_Value] - [DAC] * 0.02', DAC=0x00 },
          -- VCOM&&GAMMA
      Gamma2_Voltage = New.Register{ Name='Gamma2_Voltage', Group='VCOM&&GAMMA', Unit='V', MemI_B0={ Addr=0x0D, MSB=5, LSB=0 }, DACValueExpr='[AVEE_Voltage_Value] + [DAC] * 0.02', DAC=0x00 },
          -- VCOM&&GAMMA
      VCOM_Delay_Time = New.Register{ Name='VCOM_Delay_Time', Group='VCOM&&GAMMA', Unit='ms', MemI_B0={ Addr=0x1A, MSB=4, LSB=0 }, DACValueExpr='Min(155, [DAC] * 5)', DAC=0x00 },
          -- VCOM&&GAMMA
      VCOM_MIN_Voltage = New.Register{ Name='VCOM_MIN_Voltage', Group='VCOM&&GAMMA', Unit='V', MemI_B0={ Addr=0x1C, MSB=4, LSB=0 }, DACValueExpr='lookup(-3.6, -3.6, -3.6, -3.45, -3.3, -3.15, -3.0, -2.85, -2.7, -2.55, -2.4, -2.25, -2.1, -1.95, -1.8, -1.65, -1.5, -1.35, -1.2, -1.05, -0.9, -0.75, -0.6, -0.45, -0.3, -0.15, 0.0, 0.15, 0.3, 0.45, 0.6, 0.75)', DAC=0x00 },
          -- VCOM&&GAMMA
      VCOM_Power_off_Selection = New.Register{ Name='VCOM Power off Selection', Group='VCOM&&GAMMA', MemI_B0={ Addr=0x1A, MSB=5, LSB=5 }, DACValueExpr='lookup(\'VIN_UVLO_F\',\'RESET\')', DAC=0x00 },
          -- VCOM&&GAMMA
      VCOM_Voltage = New.Register{ Name='VCOM_Voltage', Group='VCOM&&GAMMA', Unit='V', MemI_B0={ Addr=0x0A, MSB=7, LSB=1 }, DACValueExpr='[VCOM_MIN_Voltage_Value]+[DAC]*0.01', DAC=0x00 },
          -- VCORE
      LXB1_FREQ = New.Register{ Name='LXB1_FREQ', Group='VCORE', Unit='Hz', MemI_B0={ Addr=0x14, MSB=2, LSB=0 }, DACValueExpr='lookup(600000, 715000, 800000, 933000, 1000000, 1225000, 1225000, 1225000)', DAC=0x00 },
          -- VCORE
      LXB1_Slew_Rate = New.Register{ Name='LXB1_Slew Rate', Group='VCORE', MemI_B0={ Addr=0x14, MSB=4, LSB=3 }, DACValueExpr='lookup(\'Fastest\',\'Fast\',\'Normal\',\'Slowest\')', DAC=0x00 },
          -- VCORE
      VCORE_Delay_Time = New.Register{ Name='VCORE_Delay_Time', Group='VCORE', Unit='ms', MemI_B0={ Addr=0x15, MSB=3, LSB=0 }, DACValueExpr='lookup(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 45, 45, 45, 45, 45, 45)', DAC=0x00 },
          -- VCORE
      VCORE_SS_Time = New.Register{ Name='VCORE_SS_Time', Group='VCORE', Unit='ms', MemI_B0={ Addr=0x15, MSB=5, LSB=4 }, DACValueExpr='lookup(2, 4, 6, 8)', DAC=0x00 },
          -- VCORE
      VCORE_Voltage = New.Register{ Name='VCORE_Voltage', Group='VCORE', Unit='V', MemI_B0={ Addr=0x07, MSB=5, LSB=0 }, DACValueExpr='Min(2.06, 0.8 + [DAC] * 0.02)', DAC=0x00 },
          -- VGH&&VGL
      LXH_LXN_FREQ = New.Register{ Name='LXH/LXN_FREQ', Group='VGH&&VGL', Unit='Hz', MemI_B0={ Addr=0x11, MSB=2, LSB=0 }, DACValueExpr='lookup(500000, 600000, 715000, 800000, 933000, 1000000, 1225000, 1430000)', DAC=0x00 },
          -- VGH&&VGL
      LXH_LXN_Slew_Rate = New.Register{ Name='LXH/LXN_Slew Rate', Group='VGH&&VGL', MemI_B0={ Addr=0x11, MSB=4, LSB=3 }, DACValueExpr='lookup(\'Fastest\',\'Fast\',\'Normal\',\'Slowest\')', DAC=0x00 },
          -- VGH&&VGL
      VGH_Delay_Time = New.Register{ Name='VGH_Delay_Time', Group='VGH&&VGL', Unit='ms', MemI_B0={ Addr=0x12, MSB=3, LSB=0 }, DACValueExpr='lookup(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 45, 45, 45, 45, 45, 45)', DAC=0x00 },
          -- VGH&&VGL
      VGH_SS_Time = New.Register{ Name='VGH_SS_Time', Group='VGH&&VGL', Unit='ms', MemI_B0={ Addr=0x12, MSB=5, LSB=4 }, DACValueExpr='lookup(4, 6, 8, 12)', DAC=0x00 },
          -- VGH&&VGL
      VGH_Voltage = New.Register{ Name='VGH_Voltage', Group='VGH&&VGL', Unit='V', MemI_B0={ Addr=0x05, MSB=4, LSB=0 }, DACValueExpr='(1 - [EN_High Resolution_DAC]) * Min(12.0, 6.0 + [DAC]*0.2) + [EN_High Resolution_DAC] * (12.5 + [DAC]*0.5)', DAC=0x00 },
          -- VGH&&VGL
      VGL_Delay_Time = New.Register{ Name='VGL_Delay_Time', Group='VGH&&VGL', Unit='ms', MemI_B0={ Addr=0x13, MSB=3, LSB=0 }, DACValueExpr='lookup(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 45, 45, 45, 45, 45, 45)', DAC=0x00 },
          -- VGH&&VGL
      VGL_SS_Time = New.Register{ Name='VGL_SS_Time', Group='VGH&&VGL', Unit='ms', MemI_B0={ Addr=0x13, MSB=6, LSB=4 }, DACValueExpr='lookup(4, 4, 6, 8, 10, 12, 14, 16)', DAC=0x00 },
          -- VGH&&VGL
      VGL_Voltage = New.Register{ Name='VGL_Voltage', Group='VGH&&VGL', Unit='V', MemI_B0={ Addr=0x06, MSB=5, LSB=0 }, DACValueExpr='Max(-18.0, -5.4 + [DAC] * -0.2)', DAC=0x00 },
          -- VIO
      LXB2_FREQ = New.Register{ Name='LXB2_FREQ', Group='VIO', Unit='Hz', MemI_B0={ Addr=0x16, MSB=2, LSB=0 }, DACValueExpr='lookup(600000, 715000, 800000, 933000, 1000000, 1225000, 1225000, 1225000)', DAC=0x00 },
          -- VIO
      LXB2_Slew_Rate = New.Register{ Name='LXB2_Slew Rate', Group='VIO', MemI_B0={ Addr=0x16, MSB=4, LSB=3 }, DACValueExpr='lookup(\'Fastest\',\'Fast\',\'Normal\',\'Slowest\')', DAC=0x00 },
          -- VIO
      VIO_Delay_Time = New.Register{ Name='VIO_Delay_Time', Group='VIO', Unit='ms', MemI_B0={ Addr=0x17, MSB=3, LSB=0 }, DACValueExpr='lookup(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 45, 45, 45, 45, 45, 45)', DAC=0x00 },
          -- VIO
      VIO_Power_off_Selection = New.Register{ Name='VIO Power off Selection', Group='VIO', MemI_B0={ Addr=0x17, MSB=6, LSB=6 }, DACValueExpr='lookup(\'VIN_UVLO_F\',\'RESET\')', DAC=0x00 },
          -- VIO
      VIO_SS_Time = New.Register{ Name='VIO_SS_Time', Group='VIO', Unit='ms', MemI_B0={ Addr=0x17, MSB=5, LSB=4 }, DACValueExpr='lookup(2, 4, 6, 8)', DAC=0x00 },
          -- VIO
      VIO_Voltage = New.Register{ Name='VIO_Voltage', Group='VIO', Unit='V', MemI_B0={ Addr=0x08, MSB=4, LSB=0 }, DACValueExpr='Min(2.55, 1.0 + [DAC] * 0.05)', DAC=0x00 },
        },
        ChecksumMemIndexCollect = {
        ['Default'] = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F },
        },
      NeedShowMemIndex = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x3B },
      },

      New.RegisterTable{
        Name = 'DVCOM',
      DeviceAddress = { 0x9E },
        FrontDoorRegisters = {
      DVCOM = New.Register{ Name='DVCOM', MemI_B0={ Addr=0x00, MSB=7, LSB=1 }, DAC=0x00 },
        },
      },
    },
  }
end

-- 定義自訂按鈕功能
-- 這些函式會自動變成 UI 上的按鈕
i2capi = {
  -- 燒錄指令：I2C 下達 0x46, 0xff, 0x80
  -- ctx: LuaTconContext 實例，提供 I2C 操作方法
  -- deviceAddress: 裝置位址（可選參數）
  WriteEEPROM = function(ctx, deviceAddress)
    -- 使用預設裝置位址 0x46，或使用傳入的位址
    local addr = deviceAddress or 0x46

    -- 先寫入整個暫存器表（對應 C# 的 WriteRegistersAsync）
    ctx.WriteI2C()

    -- 然後寫入特定的燒錄指令：寫入 0x80 到索引 0xff
    ctx.WriteI2CByteIndex(addr, 0xff, 0x80)
  end,

  -- 讀取暫存器：使用 ReadI2C 會自動呼叫 C# 的 ReadRegistersAsync
  -- ctx: LuaTconContext 實例
  -- deviceAddress: 裝置位址（可選參數，實際上不會使用，因為會使用 UI 中選取的位址）
  ReadRegisters = function(ctx, deviceAddress)
    -- 一行指令即可讀取所有暫存器（會自動使用 UI 中選取的暫存器表）
    ctx.ReadI2C()
  end,

  -- 寫入暫存器：使用 WriteI2C 會自動呼叫 C# 的 WriteRegistersAsync
  -- ctx: LuaTconContext 實例
  -- deviceAddress: 裝置位址（可選參數，實際上不會使用，因為會使用 UI 中選取的位址）
  WriteRegisters = function(ctx, deviceAddress)
    -- 一行指令即可寫入所有暫存器（會自動使用 UI 中選取的暫存器表）
    ctx.WriteI2C()
  end,

  -- 組合操作範例：先讀取，再寫入燒錄指令，最後再讀取
  ReadWriteRead = function(ctx, deviceAddress)
    -- 讀取暫存器
    ctx.ReadI2C()

    -- 寫入燒錄指令
    local addr = deviceAddress or 0x46
    ctx.WriteI2CByteIndex(addr, 0xff, 01)

    -- 再次讀取暫存器
    ctx.ReadI2C()
  end
}

rule = {
  DR1 = function()
    local ldo = tonumber(DiagramHelper.GetRegisterValue("LDO_Delay_Time",LDO_Delay_Time,RegValues))
    local vcore = tonumber(DiagramHelper.GetRegisterValue("VCORE_Delay_Time",VCORE_Delay_Time,RegValues))
    return {
      "LDO_Delay_Time >= VCORE_Delay_Time",
      ldo >= vcore
    }
  end,
  DR2 = function()
    local ldo = tonumber(DiagramHelper.GetRegisterValue("LDO_Delay_Time"))
    local vcore = tonumber(DiagramHelper.GetRegisterValue("VCORE_Delay_Time"))
    return {
      "LDO_Delay_Time >= VCORE_Delay_Time",
      ldo >= vcore
    }
  end
}

-- 通用 Diagram 定義：所有時序計算邏輯都在 Lua
function GetDiagrams()
  -- 使用 DiagramHelper 取得寄存器值
  local function get_value(name, reg)
    local val = DiagramHelper.GetRegisterValue(name, reg, RegValues)
    if val == nil then return nil end
      local num = tonumber(val)
      return num or val
    end

    -- 特定欄位的便捷取值
    local function avdd_delay_ms()  return get_value("AVDD_Delay_Time",  AVDD_Delay_Time)  or 0 end
    local function avdd_ss_ms()     return get_value("AVDD_SS_Time",     AVDD_SS_Time)     or 0 end
    local function avdd_voltage()   return get_value("AVDD_Voltage",     AVDD_Voltage)     or 0 end

    local function avee_delay_ms()  return get_value("AVEE_Delay_Time",  AVEE_Delay_Time)  or 0 end
    local function avee_ss_ms()     return get_value("AVEE_SS_Time",     AVEE_SS_Time)     or 0 end
    local function avee_voltage()   return get_value("AVEE_Voltage",     AVEE_Voltage)     or 0 end

    local function vgh_delay_ms()   return get_value("VGH_Delay_Time",   VGH_Delay_Time)   or 0 end
    local function vgh_ss_ms()      return get_value("VGH_SS_Time",      VGH_SS_Time)      or 0 end
    local function vgh_voltage()    return get_value("VGH_Voltage",      VGH_Voltage)      or 0 end

    local function vgl_delay_ms()   return get_value("VGL_Delay_Time",   VGL_Delay_Time)   or 0 end
    local function vgl_ss_ms()      return get_value("VGL_SS_Time",      VGL_SS_Time)      or 0 end
    local function vgl_voltage()    return get_value("VGL_Voltage",      VGL_Voltage)      or 0 end

    local function vio_delay_ms()   return get_value("VIO_Delay_Time",   VIO_Delay_Time)   or 0 end
    local function vio_ss_ms()      return get_value("VIO_SS_Time",      VIO_SS_Time)      or 0 end
    local function vio_voltage()    return get_value("VIO_Voltage",      VIO_Voltage)      or 0 end

    local function vcore_delay_ms() return get_value("VCORE_Delay_Time", VCORE_Delay_Time) or 0 end
    local function vcore_ss_ms()    return get_value("VCORE_SS_Time",    VCORE_SS_Time)    or 0 end
    local function vcore_voltage()  return get_value("VCORE_Voltage",    VCORE_Voltage)    or 0 end

    local function ldo_delay_ms()   return get_value("LDO_Delay_Time",   LDO_Delay_Time)   or 0 end
    local function ldo_ss_ms()      return 1 end
    local function ldo_voltage()    return get_value("LDO_Voltage",      LDO_Voltage)      or 0 end

    local function reset_delay_ms() return get_value("RESET_Delay_Time", RESET_Delay_Time) or 0 end
    local function reset_ss_ms()    return 1 end
    local function reset_voltage()  return get_value("RESET_Voltage",    RESET_Voltage)    or 0 end

    local function vcom_delay_ms()  return get_value("VCOM_Delay_Time",  VCOM_Delay_Time)  or 0 end
    local function vcom_ss_ms()     return 1 end
    local function vcom_voltage()   return get_value("VCOM_Voltage",     VCOM_Voltage)     or 0 end

    -- 使用 DiagramHelper 檢查 Enable 狀態（先保留，暫時不套進 loop，之後再加）
    local function is_enabled(name, reg)
      return DiagramHelper.IsEnabled(name, reg, RegValues)
    end

    -- 外部 VDD 相關：可用 RegValues 注入覆寫
    local function ext_vdd_input_v()     return DiagramHelper.GetNumber("EXT_VDD_IN", RegValues, 3.3) end
    local function ext_uvlo_threshold()  return DiagramHelper.GetNumber("EXT_UVLO_OVERRIDE", RegValues, 1.9) end
    local function ext_ramp_ms()         return DiagramHelper.GetNumber("EXT_RAMP_MS_OVERRIDE", RegValues, 1.0) end
    local function ramp_from_uvlo(t, t_uvlo, delay_ms, ss_ms, vtgt)
      if t_uvlo == math.huge then return 0 end

        local d  = math.max(0, delay_ms or 0)
        local ss = math.max(0, ss_ms or 0)
        local vt = vtgt or 0

        local t_start = t_uvlo + d

        if t < t_start then
          return 0
        end

        if ss == 0 then
          return vt
        end

        local t_end = t_start + ss
        if t < t_end then
          local k = (t - t_start) / ss -- 0..1
          local v = vt * k
          if v < 0 then v = 0 end
            if v > vt then v = vt end
              return v
            end

            return vt
          end
          ------------------------------------------------------------------
          -- 共用時間軸：1000 點、總長 200ms
          ------------------------------------------------------------------
          local START_MS = 0
          local TOTAL_MS = 200
          local NPTS     = 1000
          local DT_MS    = TOTAL_MS / NPTS

          ------------------------------------------------------------------
          -- 一次取好參數（避免 loop 內一直 call）
          ------------------------------------------------------------------
          local vin  = ext_vdd_input_v()
          local uvlo = ext_uvlo_threshold()
          local ramp = ext_ramp_ms()

          local avdd_delay = avdd_delay_ms()
          local avdd_ss    = avdd_ss_ms()
          local avdd_vtgt  = avdd_voltage()

          local avee_delay = avee_delay_ms()
          local avee_ss    = avee_ss_ms()
          local avee_vtgt  = avee_voltage()

          local vgh_delay  = vgh_delay_ms()
          local vgh_ss     = vgh_ss_ms()
          local vgh_vtgt   = vgh_voltage()

          local vgl_delay  = vgl_delay_ms()
          local vgl_ss     = vgl_ss_ms()
          local vgl_vtgt   = vgl_voltage()

          local vio_delay  = vio_delay_ms()
          local vio_ss     = vio_ss_ms()
          local vio_vtgt   = vio_voltage()

          local vcore_delay = vcore_delay_ms()
          local vcore_ss    = vcore_ss_ms()
          local vcore_vtgt  = vcore_voltage()

          local ldo_delay  = ldo_delay_ms()
          local ldo_ss     = ldo_ss_ms()
          local ldo_vtgt   = ldo_voltage()

          local reset_delay = reset_delay_ms()
          local reset_ss    = reset_ss_ms()
          local reset_vtgt  = reset_voltage()

          local vcom_delay = vcom_delay_ms()
          local vcom_ss    = vcom_ss_ms()
          local vcom_vtgt  = vcom_voltage()

          ------------------------------------------------------------------
          -- UVLO crossing time（仍保留給後續用）
          ------------------------------------------------------------------
          local t_uvlo = math.huge
          if vin > 0 and vin > uvlo then
            t_uvlo = ramp * (uvlo / vin)
          end

          ------------------------------------------------------------------
          -- 所有 channel 的 pts 容器
          ------------------------------------------------------------------
        local pts_ext_vdd = {}
        local pts_avdd    = {}
        local pts_avee    = {}
        local pts_vgh     = {}
        local pts_vgl     = {}
        local pts_vio     = {}
        local pts_vcore   = {}
        local pts_ldo     = {}
        local pts_reset   = {}
        local pts_vcom    = {}

          ------------------------------------------------------------------
          -- 只有一個 1000 次主迴圈：EXT_VDD 先算，其他全部基於 ext_v 判斷
          ------------------------------------------------------------------
          for i = 0, NPTS - 1 do
            local t = START_MS + i * DT_MS

            -- EXT_VDD (master)
            local ext_v
            if t <= 0 then
              ext_v = 0
            elseif t < ramp then
              ext_v = vin * (t / ramp)
            else
              ext_v = vin
            end
          pts_ext_vdd[#pts_ext_vdd + 1] = { t = t, v = ext_v }

            -- 基本骨架：若 ext_v 未達 uvlo，先全部 0（之後你再改成更細的條件）
            local ok = (ext_v >= uvlo)

            -- AVDD
            local avdd_v = 0
            if ok and is_enabled("EN_AVDD", EN_AVDD) then
              avdd_v = ramp_from_uvlo(t, t_uvlo, avdd_delay, avdd_ss, avdd_vtgt)
            end
          pts_avdd[#pts_avdd + 1] = { t = t, v = avdd_v }

            -- AVEE
            local avee_v = 0
            if ok and is_enabled("EN_AVEE", EN_AVEE) then
              avee_v = ramp_from_uvlo(t, t_uvlo, avee_delay, avee_ss, avee_vtgt)
            end
          pts_avee[#pts_avee + 1] = { t = t, v = avee_v }

            -- VGH
            local vgh_v = 0
            if ok and is_enabled("EN_VGH", EN_VGH) then
              vgh_v = ramp_from_uvlo(t, t_uvlo, vgh_delay, vgh_ss, vgh_vtgt)
            end
          pts_vgh[#pts_vgh + 1] = { t = t, v = vgh_v }

            -- VGL
            local vgl_v = 0
            if ok and is_enabled("EN_VGL", EN_VGL) then
              vgl_v = ramp_from_uvlo(t, t_uvlo, vgl_delay, vgl_ss, vgl_vtgt)
            end
          pts_vgl[#pts_vgl + 1] = { t = t, v = vgl_v }

            -- VIO
            local vio_v = 0
            if ok and is_enabled("EN_VIO", EN_VIO) then
              vio_v = ramp_from_uvlo(t, t_uvlo, vio_delay, vio_ss, vio_vtgt)
            end
          pts_vio[#pts_vio + 1] = { t = t, v = vio_v }

            -- VCORE
            local vcore_v = 0
            if ok and is_enabled("EN_VCORE", EN_VCORE) then
              vcore_v = ramp_from_uvlo(t, t_uvlo, vcore_delay, vcore_ss, vcore_vtgt)
            end
          pts_vcore[#pts_vcore + 1] = { t = t, v = vcore_v }

            -- LDO
            local ldo_v = 0
            if ok and is_enabled("EN_LDO", EN_LDO) then
              ldo_v = ramp_from_uvlo(t, t_uvlo, ldo_delay, ldo_ss, ldo_vtgt)
            end
          pts_ldo[#pts_ldo + 1] = { t = t, v = ldo_v }

            -- RESET
            local reset_v = 0
            if ok and is_enabled("EN_RESET", EN_RESET) then
              reset_v = ramp_from_uvlo(t, t_uvlo, reset_delay, reset_ss, reset_vtgt)
            end
          pts_reset[#pts_reset + 1] = { t = t, v = reset_v }

            -- VCOM
            local vcom_v = 0
            if ok and is_enabled("EN_VCOM", EN_VCOM) then
              vcom_v = ramp_from_uvlo(t, t_uvlo, vcom_delay, vcom_ss, vcom_vtgt)
            end
          pts_vcom[#pts_vcom + 1] = { t = t, v = vcom_v }
          end

          ------------------------------------------------------------------
          -- 建立 channels（迴圈外一次做）
          ------------------------------------------------------------------
          local ext_vdd = DiagramHelper.CreateChannel('EXT_VDD', '#FFAA00', pts_ext_vdd, {
            editable = true,
            isExtra  = true,
            note     = string.format("VIN=%.2fV, UVLO=%.2fV, dt=%.3fms", vin, uvlo, DT_MS)
          })
          ext_vdd.t_uvlo = t_uvlo

        local avdd  = DiagramHelper.CreateChannel('AVDD',  '#4F81BD', pts_avdd,  { editable = true })
        local avee  = DiagramHelper.CreateChannel('AVEE',  '#C0504D', pts_avee,  { editable = true })
        local vgh   = DiagramHelper.CreateChannel('VGH',   '#9BBB59', pts_vgh,   { editable = true })
        local vgl   = DiagramHelper.CreateChannel('VGL',   '#8064A2', pts_vgl,   { editable = true })
        local vio   = DiagramHelper.CreateChannel('VIO',   '#F79646', pts_vio,   { editable = true })
        local vcore = DiagramHelper.CreateChannel('VCORE', '#4BACC6', pts_vcore, { editable = true })
        local ldo   = DiagramHelper.CreateChannel('LDO',   '#1F497D', pts_ldo,   { editable = true })
        local reset = DiagramHelper.CreateChannel('RESET', '#31859B', pts_reset, { editable = true })
        local vcom  = DiagramHelper.CreateChannel('VCOM',  '#806000', pts_vcom,  { editable = true })

          local dbg = {
            string.format("EXT_VDD: VIN=%.3f UVLO=%.3f RAMP=%.3f", vin, uvlo, ramp),
          }

          return {
            diagrams = {
              {
                id = 'power_on',
                title = 'P105.19 Power On',
              channels = { avdd, avee, vgh, vgl, vio, vcore, ldo, reset, vcom, ext_vdd },
              warnings = (t_uvlo == math.huge) and { 'EXT_VDD 未達 UVLO，AVDD 不啟動' } or dbg,
                controls = {
                { key = 'EXT_UVLO_OVERRIDE', label = 'EXT UVLO (V)', min = 1.9, max = 2.1, step = 0.1, value = uvlo },
                { key = 'EXT_RAMP_MS_OVERRIDE', label = 'EXT Ramp (ms)', min = 0, max = 20, step = 0.1, value = ramp },
                { key = 'EXT_VDD_IN', label = 'EXT VIN (V)', min = 2.8, max = 3.6, step = 0.1, value = vin }
                },
                timeUnit = "ms"  -- 使用毫秒作為時間單位
              }
            }
          }
        end



