function Build()
  return New.Product{
    Name        = 'L105.19',
    Type        = 'LED Driver',
    Application = 'NoteBook',
    Package     = '',
    Description = 'L105.19 LED Driver IC',
    RegisterTable = {
      New.RegisterTable{
  Name = 'Default',
  DeviceAddress = { 0x6C, 0x6E },
  FrontDoorRegisters = {
    -- Dimming Setting && Others
    --ADDR_SEL = New.Register{ Name='ADDR_SEL', Group='Dimming Setting && Others', MemI_B0={ Addr=0x08, MSB=7, LSB=7 }, DACValueExpr="lookup('0x6C & 0x6E','0x60 & 0x62')", DAC=0x00 },
    -- Dimming Setting && Others
    Dimming_Mode = New.Register{ Name='Dimming_Mode', Group='Dimming Setting && Others', MemI_B0={ Addr=0x00, MSB=1, LSB=0 }, DACValueExpr="lookup('PWM','DC','Mix','MIX-26K')", Unit='Mode', DAC=0x01 },
    -- Dimming Setting && Others
    MixMode_Threshold = New.Register{ Name='MixMode_Threshold', Group='Dimming Setting && Others', Unit='%', MemI_B0={ Addr=0x0C, MSB=1, LSB=1 }, DACValueExpr='lookup(25,50)', DAC=0x00 },
    -- Dimming Setting && Others
    Write_Protect = New.Register{ Name='Write_Protect', Group='Dimming Setting && Others', MemI_B0={ Addr=0x0C, MSB=0, LSB=0 }, DACValueExpr="lookup('Off', 'On')", DAC=0x00 },
    -- LED Setting
    ISET_Range = New.Register{ Name='ISET_Range', Group='LED Setting', Unit='mA', MemI_B0={ Addr=0x09, MSB=0, LSB=0 }, DACValueExpr="lookup('6mA~25mA','2m~14.7mA')", DAC=0x00 },
    -- LED Setting
    Led_Current = New.Register{ Name='Led_Current', Group='LED Setting', Unit='mA', MemI_B0={ Addr=0x01, MSB=7, LSB=0 }, DACValueExpr='Min([DAC],1) * Min( (5.9 - 3.95*[ISET_Range_DAC]) + (0.1 - 0.05*[ISET_Range_DAC])*[DAC] , (25.0 - 10.3*[ISET_Range_DAC]) )', DAC=0x60 },
    -- LED Setting
    LED_Driver_Headroom = New.Register{ Name='LED_Driver_Headroom', Group='LED Setting', Unit='mV', MemI_B0={ Addr=0x06, MSB=1, LSB=0 }, DACValueExpr='lookup(400, 460, 500, 560)', DAC=0x02 },
    -- Protection
    Over_Voltage_Protection_Selection = New.Register{ Name='Over_Voltage_Protection_Selection', Group='Protection', Unit='V', MemI_B0={ Addr=0x02, MSB=6, LSB=2 }, DACValueExpr='lookup(10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,46)', DAC=0x1F },
    -- Protection
    VIN_UVLO = New.Register{ Name='VIN_UVLO', Group='Protection', Unit='V', MemI_B0={ Addr=0x02, MSB=1, LSB=0 }, DACValueExpr='lookup(2.45, 2.7, 3.2, 3.8)', DAC=0x00 },
    -- Switching Power 1
    Boost_Compensation = New.Register{ Name='Boost_Compensation', Group='Switching Power Options', MemI_B0={ Addr=0x02, MSB=7, LSB=7 },Unit='Mode', DACValueExpr="lookup('External','Internal')", DAC=0x01 },
    -- Switching Power 1
    LX_Edge_Rate_Control = New.Register{ Name='LX_Edge_Rate_Control', Group='Switching Power Options', Unit='%', MemI_B0={ Addr=0x04, MSB=1, LSB=0 }, DACValueExpr='lookup(25, 50, 100, 200)', DAC=0x02 },
    -- Switching Power 1
    Switching_Frequency = New.Register{ Name='Switching_Frequency', Group='Switching Power Options', Unit='Hz', MemI_B0={ Addr=0x03, MSB=3, LSB=0 }, DACValueExpr='lookup(100000,150000,200000,250000,300000,400000,500000,600000,700000,800000,900000,1000000,1225000,1335000,1450000,1600000)', DAC=0x0C },
    -- Switching Power Options
    Lowest_Switching_Frequency_for_PFM = New.Register{ Name='Lowest_Switching_Frequency_for_PFM', Group='Switching Power Options', Unit='Hz', MemI_B0={ Addr=0x04, MSB=7, LSB=2 },DACValueExpr='[Switching_Frequency_Value]*(63-[DAC])/64', DAC=0x2F },
    -- Switching Power Options
    PFM_Enable = New.Register{ Name='PFM_Enable', Group='Switching Power Options', MemI_B0={ Addr=0x03, MSB=5, LSB=5 }, DACValueExpr="lookup('Off','On')", DAC=0x00 },
	      -- Dimming Setting
	Fading_Time_Duty_Change_Threshold = New.Register{
	Name='Fading_Time_Duty_Change_Threshold', Group='Fading Time Setting', Unit='%',
	MemI_B0={ Addr=0x08, MSB=6, LSB=6 },
	DACValueExpr='lookup(12.5, 25)', DAC=0x01
	},
	Fading_Time_SEL1 = New.Register{
	Name='Fading_Time_SEL1', Group='Fading Time Setting', Unit='us',
	MemI_B0={ Addr=0x08, MSB=2, LSB=0 },
	DACValueExpr='lookup(1, 8, 16, 32, 64, 128, 256, 512)', DAC=0x00
	},
	Fading_Time_SEL2 = New.Register{
	Name='Fading_Time_SEL2', Group='Fading Time Setting', Unit='us',
	MemI_B0={ Addr=0x08, MSB=5, LSB=3 },
	DACValueExpr='lookup(1, 8, 16, 32, 64, 128, 256, 512)', DAC=0x00
	},
  },
  ChecksumMemIndexCollect = {
    ['Default'] = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C },
  },
  NeedShowMemIndex = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x06, 0x08, 0x09, 0x0A, 0x0B, 0x0C },
}

    }
  }
end
-- 初始化 RegValues（全域）
RegValues = RegValues or {}
-- 保留跨次重繪的狀態（避免每次都重新自動計算）
DiagramState = DiagramState or {}

-- 使用 DiagramHelper 取得值（全域函數）
function getnum(key, default)
  return DiagramHelper.GetNumber(key, RegValues, default)
end

-- 取得 Register 的 DAC 值（選擇的索引）（全域函數）
function get_register_dac(reg_name)
  return DiagramHelper.GetRegisterDAC(reg_name, RegValues)
end

-- 取得 Register 的實際值（全域函數）
function get_register_value(reg_name, reg)
  local val = DiagramHelper.GetRegisterValue(reg_name, reg, RegValues)
  if val == nil then return nil end
  return val
end
-- 定義自訂按鈕功能
-- 這些函式會自動變成 UI 上的按鈕
i2capi = {
  ReadFromDAC = function(ctx, deviceAddress)
    -- 使用預設裝置位址 0x46，或使用傳入的位址
    local addr = deviceAddress or 0x6C
    ctx:WriteI2CByteIndex(addr, 0x0D, 0x5A)
    delay(1)
    ctx:WriteI2CByteIndex(addr, 0xff, 0x00)
    delay(5)
    ctx:ReadI2C()
  end,
  ReadFromMTP = function(ctx, deviceAddress)
    -- 使用預設裝置位址 0x46，或使用傳入的位址
    local addr = deviceAddress or 0x6C
    ctx:WriteI2CByteIndex(addr, 0x0D, 0x5A)
    delay(1)
    ctx:WriteI2CByteIndex(addr, 0xff, 0x01)
    delay(20)
    ctx:ReadI2C()
  end,
  WriteRegisters = function(ctx, deviceAddress)
    -- 一行指令即可寫入所有暫存器（會自動使用 UI 中選取的暫存器表）
    local addr = deviceAddress or 0x6C
    ctx:WriteI2CByteIndex(addr, 0x0D, 0x5A)
    delay(1)
    ctx:WriteI2C()
  end,
  WriteToMTP = function(ctx, deviceAddress)
    local addr = deviceAddress or 0x6C
    ctx:WriteI2CByteIndex(addr, 0x0D, 0x5A)
    delay(1)
    ctx:WriteI2CByteIndex(addr, 0xff, 0x80)
    delay(20)
    ctx:ReadI2C()
  end
}

rule = {
  DR1 = function()
    local pfm_en = get_register_value("PFM_Enable")
    return {
      "PFM must be set to Off",
      pfm_en == 'Off'
    }
  end,
  DR20 = function()
    local pfm_lowest_frequency = tonumber(get_register_value("Lowest_Switching_Frequency_for_PFM"))
    return {
      "Lowest_Switching_Frequency_for_PFM must be > 300KHz",
      pfm_lowest_frequency > 300000
    }
  end,

  DR2 = function()
    local dimming_Mode = tostring(get_register_value("Dimming_Mode"))
    return {
      "Dimming_Mode must be set to DC Mode",
      dimming_Mode == "DC"
    }
  end,
  DR3 = function()
    local boost_Compensation = tostring(get_register_value("Boost_Compensation"))
    return {
      "Boost_Compensation must be set to Internal",
      boost_Compensation == 'Internal'
    }
  end,
  DR4 = function()
    local ovp = tonumber(get_register_value("Over_Voltage_Protection_Selection"))
    return {
      "OVP must be set to 46V",
      ovp == 46
    }
  end,
  DR5 = function()
    local uvlo = tonumber(get_register_value("VIN_UVLO"))
    return {
      "VIN_UVLO must be set to 2.45V",
      uvlo == 2.45
    }
  end,
  DR6 = function()
    local lx_slew_rate = tonumber(get_register_value("LX_Edge_Rate_Control"))
    return {
      "LX_Edge_Rate_Control must be set to 100%",
      lx_slew_rate == 100
    }
  end,
  DR7 = function()
    local headroom = tonumber(get_register_value("LED_Driver_Headroom"))
    return {
      "LED_Driver_Headroom must be set to 500mV",
      headroom == 500
    }
  end,
  DR8 = function()
    local mixMode_Threshold = tonumber(get_register_value("MixMode_Threshold"))
    return {
      "MixMode_Threshold must be set to 25%",
      mixMode_Threshold == 25
    }
  end,
  DR9 = function()
    local fading_Time_Duty_Change_Threshold = tonumber(get_register_value("Fading_Time_Duty_Change_Threshold"))
    return {
      "Fading_Time_Duty_Change_Threshold must be set to 25%",
      fading_Time_Duty_Change_Threshold == 25
    }
  end,
  DR10 = function()
    local fading_Time_SEL1 = tonumber(get_register_value("Fading_Time_SEL1"))
    return {
      "Fading_Time_SEL1 must be set to 1us",
      fading_Time_SEL1 == 1
    }
  end,
  DR11 = function()
    local fading_Time_SEL2 = tonumber(get_register_value("Fading_Time_SEL2"))
    return {
      "Fading_Time_SEL2 must be set to 1us",
      fading_Time_SEL2 == 1
    }
  end,
  DR12 = function()
    local switching_Frequency = tonumber(get_register_value("Switching_Frequency"))
    return {
      "Switching_Frequency must be >= 600KHz",
      switching_Frequency >= 600000
    }
  end,
}