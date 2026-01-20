function Build()
  return New.Product{
    Name        = 'L102.19',
    Type        = 'LED Driver',
    Application = 'NoteBook',
    Package     = '',
    Description = 'L102.19 LED Driver IC',
    RegisterTable = {
      New.RegisterTable{
        Name = 'Default',
        DeviceAddress = { 0x6C, 0x6E },
        FrontDoorRegisters = {

          -- Dimming Setting
          Dimming_Mode = New.Register{
            Name='Dimming_Mode', Group='Dimming Setting',
            MemI_B0={ Addr=0x00, MSB=1, LSB=0 },
            DACValueExpr="lookup('PWM','DC','Mix','MIX-26K')", Unit='Mode', DAC=0x01
            },

          -- LED Setting
          Led_Current = New.Register{
            Name='Led_Current', Group='LED Setting', Unit='mA',
            MemI_B0={ Addr=0x01, MSB=7, LSB=0 },
            -- C# list: [0, 6.0..25.0 step 0.1]
            DACValueExpr='Min([DAC],1) * Min( (5.9 ) + (0.1 )*[DAC] , (25.0) )',
            DAC=0x00
            },

          -- Switching Power
          Boost_Compensation = New.Register{
            Name='Boost_Compensation', Group='Switching Power',
            MemI_B0={ Addr=0x02, MSB=7, LSB=7 },
            DACValueExpr="lookup('External','Internal')",Unit='Mode', DAC=0x01
            },
          Over_Voltage_Protection_Selection = New.Register{
            Name='Over_Voltage_Protection_Selection', Group='Protection', Unit='V',
            MemI_B0={ Addr=0x02, MSB=6, LSB=2 },
            DACValueExpr='Min(40, 10 + [DAC] * 1)', DAC=0x1C
            },
          VIN_UVLO = New.Register{
            Name='VIN_UVLO', Group='Protection', Unit='V',
            MemI_B0={ Addr=0x02, MSB=1, LSB=0 },
            DACValueExpr='lookup(2.3, 2.7, 3.2, 3.8)', DAC=0x00
            },

          PFM_Enable = New.Register{
            Name='PFM_Enable', Group='Switching Power',
            MemI_B0={ Addr=0x03, MSB=5, LSB=5 },
            DACValueExpr="lookup('Off','On')", DAC=0x00
            },
          Switching_Frequency = New.Register{
            Name='Switching_Frequency', Group='Switching Power', Unit='Hz',
            MemI_B0={ Addr=0x03, MSB=3, LSB=0 },
            DACValueExpr='lookup(100000,150000,200000,250000,300000,400000,500000,600000,700000,800000,900000,1000000,1225000,1335000,1450000,1600000)',
            DAC=0x0C
            },

          Lowest_Switching_Frequency_for_PFM = New.Register{
            Name='Lowest_Switching_Frequency_for_PFM', Group='Switching Power', Unit='Hz',
            MemI_B0={ Addr=0x04, MSB=7, LSB=2 },
            DACValueExpr='1000*16000/((16000/([Switching_Frequency_Value]/1000))+(8*[DAC])+7)', DAC=0x04
            },
          LX_Edge_Rate_Control = New.Register{
            Name='LX_Edge_Rate_Control', Group='Switching Power', Unit='%',
            MemI_B0={ Addr=0x04, MSB=1, LSB=0 },
            DACValueExpr='lookup(25,50,100,200)', DAC=0x02
            },

          -- LED Setting / Protection
          LED_Driver_Headroom = New.Register{
            Name='LED_Driver_Headroom', Group='LED Setting', Unit='mV',
            MemI_B0={ Addr=0x06, MSB=1, LSB=0 },
            DACValueExpr='lookup(400,460,500,560)', DAC=0x02
            },
          LED_Short_Protection = New.Register{
            Name='LED_Short_Protection', Group='Protection',
            MemI_B0={ Addr=0x07, MSB=4, LSB=4 },
            DACValueExpr="lookup('Off','On')", DAC=0x01
            },
          LED_OVP_Level = New.Register{
            Name='LED_OVP_Level', Group='Protection', Unit='V',
            MemI_B0={ Addr=0x07, MSB=1, LSB=0 },
            DACValueExpr='lookup(2.1, 2.52, 2.8, 3.5)', DAC=0x03
            },

          -- Dimming Setting
          Fading_Time_Duty_Change_Threshold = New.Register{
            Name='Fading_Time_Duty_Change_Threshold', Group='Fading Time Setting', Unit='%',
            MemI_B0={ Addr=0x08, MSB=6, LSB=6 },
            DACValueExpr='lookup(12.5, 25)', DAC=0x01
            },
          Fading_Time_SEL1 = New.Register{
            Name='Fading_Time_SEL1', Group='Fading Time Setting', Unit='us',
            MemI_B0={ Addr=0x08, MSB=5, LSB=3 },
            DACValueExpr='lookup(1, 4, 16, 64, 512, 1024, 2048, 4096)', DAC=0x00
            },
          Fading_Time_SEL2 = New.Register{
            Name='Fading_Time_SEL2', Group='Fading Time Setting', Unit='us',
            MemI_B0={ Addr=0x08, MSB=2, LSB=0 },
            DACValueExpr='lookup(1, 4, 16, 64, 1024, 4096, 8192, 16384)', DAC=0x00
            },
          },

        ChecksumMemIndexCollect = {
          Default = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08 }
          },
        NeedShowMemIndex = { 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08 }
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
    ctx:WriteI2CByteIndex(addr, 0xff, 0x00)
    delay(5)
    ctx:ReadI2C()
  end,
  ReadFromMTP = function(ctx, deviceAddress)
    -- 使用預設裝置位址 0x46，或使用傳入的位址
    local addr = deviceAddress or 0x6C
    ctx:WriteI2CByteIndex(addr, 0xff, 0x01)
    delay(20)
    ctx:ReadI2C()
  end,
  WriteRegisters = function(ctx, deviceAddress)
    -- 一行指令即可寫入所有暫存器（會自動使用 UI 中選取的暫存器表）
    local addr = deviceAddress or 0x6C
    ctx:WriteI2C()
  end,
  WriteToMTP = function(ctx, deviceAddress)
    local addr = deviceAddress or 0x6C
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
      "OVP must be set to 38V",
      ovp == 38
    }
  end,
  DR5 = function()
    local uvlo = tonumber(get_register_value("VIN_UVLO"))
    return {
      "VIN_UVLO must be set to 2.3",
      uvlo == 2.3
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
    local led_OVP_Level = tonumber(get_register_value("LED_OVP_Level"))
    return {
      "LED_OVP_Level must be set to 3.5V",
      led_OVP_Level == 3.5
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
    local led_Short_Protection = get_register_value("LED_Short_Protection")
    return {
      "LED_Short_Protection must be set to On",
      led_Short_Protection == 'On'
    }
  end,
  DR13 = function()
    local switching_Frequency = tonumber(get_register_value("Switching_Frequency"))
    return {
      "Switching_Frequency must be >= 600KHz",
      switching_Frequency >= 600000
    }
  end,
}
-- 通用 Diagram 定義：所有時序計算邏輯都在 Lua
function GetDiagrams()
  local warnings = {}
  local pts_pwm    = {}
  pts_pwm[0] = { t = 1, v = 3.3 }
  pts_pwm[1] = { t = 2, v = 0 }
  local pwm  = DiagramHelper.CreateChannel('PWM',  '#4F81BD', pts_pwm,  { editable = true })
  return {
    diagrams = {
      {
        id = 'power_on',
        title = 'L102.19 VIN/EN/PWM Sequence',
        channels = {pwm },
        --controls = {        },
        timeUnit = "ms",  -- 使用毫秒作為時間單位
        separatedYAxis = true,
        warnings = warnings,
      }
    }
  }
end