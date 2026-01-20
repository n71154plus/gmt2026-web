function Build()
  return New.Product{
    Name        = 'S102.19',
    Type        = 'LS',
    Application = 'NoteBook',
    Package     = '',
    Description = 'S102.19 Level Shift IC',
    RegisterTable = {
      New.RegisterTable{
  Name = 'Default',
  DeviceAddress = { 0x5E },
  FrontDoorRegisters = {
    -- Charge Sharing Setting
    CS_CLK_Interval = New.Register{ Name='CS_CLK_Interval', Group='Charge Sharing Setting', MemI_B0={ Addr=0x02, MSB=4, LSB=2 }, DACValueExpr='lookup(\'Disable\',\'1us\',\'1.5us\',\'2us\',\'2.5us\',\'3us\',\'3.5us\',\'4us\')', DAC=0x00 },
    -- Charge Sharing Setting
    CS_Edge = New.Register{ Name='CS_Edge', Group='Charge Sharing Setting', MemI_B0={ Addr=0x00, MSB=5, LSB=4 }, DACValueExpr='lookup(\'No charge sharing\',\'Rising edge\',\'Falling edge\',\'Rising & Falling edge\')', DAC=0x00 },
    -- Charge Sharing Setting
    CS_GND = New.Register{ Name='CS_GND', Group='Charge Sharing Setting', MemI_B0={ Addr=0x01, MSB=6, LSB=6 }, DACValueExpr='lookup(\'Charing sharing channel to channel\',\'Charing sharing to GND\')', DAC=0x00 },
    -- Mode Setting
    LC2_Change = New.Register{ Name='LC2_Change', Group='Mode Setting', MemI_B0={ Addr=0x02, MSB=5, LSB=5 }, DACValueExpr='lookup(\'LC1 will follow LC, LC2 will be inverse of LC1\',\'LC1 will follow LC, LC2 will follow CS-CLK.\')', DAC=0x00 },
    -- Mode Setting
    TERM_Mode = New.Register{ Name='TERM_Mode', Group='Mode Setting', MemI_B0={ Addr=0x01, MSB=7, LSB=7 }, DACValueExpr='lookup(\'All CKH pull low while Terminate signal rising\',\'After Terminate signal rising, LVSH will close CKH in sequence without turning on any CKH\')', DAC=0x00 },
    -- On/Off Setting & Prog
    Burned_Counter = New.Register{ Name='Burned_Counter', Group='On/Off Setting & Prog', Unit='次', MemI_B0={ Addr=0x04, MSB=2, LSB=0 }, ReadOnly=true, IsTextBlock=true, DACValueExpr='[DAC]', DAC=0x00 },
    -- On/Off Setting & Prog
    VGH_UVLO = New.Register{ Name='VGH_UVLO', Group='On/Off Setting & Prog', Unit='V', MemI_B0={ Addr=0x02, MSB=7, LSB=6 }, DACValueExpr='lookup(4,7,10,15)', DAC=0x00 },
    -- Phase Setting
    CKH_Interval = New.Register{ Name='CKH_Interval', Group='Phase Setting', Unit='time interval', MemI_B0={ Addr=0x00, MSB=1, LSB=1 }, DACValueExpr='lookup(\'No\',\'Some\')', DAC=0x00 },
    -- Phase Setting
    CLEAR_CLK = New.Register{ Name='CLEAR_CLK', Group='Phase Setting', Unit='VCE CLK Cycle', MemI_B0={ Addr=0x02, MSB=1, LSB=0 }, DACValueExpr='lookup(1,2,3,4)', DAC=0x00 },
    -- Phase Setting
    CLK_Phase = New.Register{ Name='CLK_Phase', Group='Phase Setting', Unit='Phase', MemI_B0={ Addr=0x00, MSB=7, LSB=6 }, DACValueExpr='lookup(8,6,4,3)', DAC=0x00 },
    -- Phase Setting
    Pre_charge = New.Register{ Name='Pre_charge', Group='Phase Setting', Unit='CLK pre-charge', MemI_B0={ Addr=0x00, MSB=3, LSB=2 }, DACValueExpr='lookup(\'No\',1,2,3)', DAC=0x00 },
    -- Slew Rate Setting
    CKH_Slew_rate = New.Register{ Name='CKH_Slew_rate', Group='Slew Rate Setting', MemI_B0={ Addr=0x01, MSB=2, LSB=0 }, DACValueExpr='lookup(\'Fastest\',\'Fast2\',\'Fast1\',\'Middle\',\'Slow1\',\'Slow2\',\'Slow3\',\'Slowest\')', DAC=0x00 },
    -- Slew Rate Setting
    MUX_Slew_rate = New.Register{ Name='MUX_Slew_rate', Group='Slew Rate Setting', MemI_B0={ Addr=0x01, MSB=5, LSB=3 }, DACValueExpr='lookup(\'Fastest\',\'Fast2\',\'Fast1\',\'Middle\',\'Slow1\',\'Slow2\',\'Slow3\',\'Slowest\')', DAC=0x00 },
  },
  ChecksumMemIndexCollect = {
    ['Default'] = { 0x00, 0x01, 0x02 },
  },
  NeedShowMemIndex = { 0x00, 0x01, 0x02, 0x04 },
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

-- 根據時序圖產生波形（數位訊號 0/1）
function GetDiagrams()
  -- 使用 DiagramHelper 建立 channel
  local function channel(name, color, pts, opts)
    return DiagramHelper.CreateChannel(name, color, pts, opts)
  end

  -- 使用 DiagramHelper 建立波形點管理器
  local wfm = DiagramHelper.CreateWaveformPointManager()
  local push_pt = wfm.push_pt
  local set_transition = wfm.set_transition

  -- ====== 輸入信號參數（由 UI controls 設定）======
  local sim_cycles = math.floor(getnum("SIM_CYCLES", 2))
  local SIM_TAIL_uS = getnum("SIM_TAIL_uS", 2.0)

  -- YDIO：頻率和高電平時間
  local ydio_hz = getnum("YDIO_HZ", 60.0)
  -- 單位：us（key 名稱維持 *_MS，但數值視為 us）
  local ydio_high_us_in = getnum("YDIO_HIGH_uS", 200.0)

  -- YCLK：每個 frame 內的 Gate Clock pulse train（可調 pulse 數 / high / low 與 window）
  local yclk_pulses = math.floor(getnum("YCLK_PULSES", 1200))
  local yclk_high_us_in = getnum("YCLK_HIGH_uS", 7.0)
  local yclk_low_us_in = getnum("YCLK_LOW_uS", 6.0)
  local yclk_win_start_offset_us = getnum("yclk_win_start_offset_us", 0.00)
  local yclk_win_end_guard_us = getnum("yclk_win_end_guard_us", 0.00)

  -- Terminate：每個 frame 尾端打一個 High pulse（預設為 Low）
  -- TERM_TO_NEXT_YDIO_uS：pulse 結束到下一次 YDIO rising 的間隔
  local TERM_HIGH_uS_in = getnum("TERM_HIGH_uS", 20.0)
  local term_to_next_ydio_us_in = getnum("TERM_TO_NEXT_YDIO_uS", 100.0)
  -- Terminate 位置控制：是否相對於 YDIO rising 設定（而非 frame 尾端）
  local term_before_ydio = (getnum("term_before_ydio", 1) ~= 0)  -- 0 表示 false，非 0 表示 true
  local term_offset_from_ydio_us = getnum("term_offset_from_ydio_us", 0.0)  -- 相對於 YDIO rising 的偏移（負數表示在 YDIO 之前）

  -- 2pcs串接模式
  local cascade_2pcs = (getnum("cascade_2pcs", 1) ~= 0)  -- 0 表示 false，非 0 表示 true

  -- 將輸入信號參數寫入 RegValues（先不寫入 YCLK_HIGH_uS 和 YCLK_LOW_uS，等計算完再寫入）
  RegValues["SIM_CYCLES"] = RegValues["SIM_CYCLES"] or sim_cycles
  RegValues["SIM_TAIL_uS"] = RegValues["SIM_TAIL_uS"] or SIM_TAIL_uS
  RegValues["YDIO_HZ"] = RegValues["YDIO_HZ"] or ydio_hz
  RegValues["YDIO_HIGH_uS"] = RegValues["YDIO_HIGH_uS"] or ydio_high_us_in
  RegValues["YCLK_PULSES"] = RegValues["YCLK_PULSES"] or yclk_pulses
  RegValues["yclk_win_start_offset_us"] = RegValues["yclk_win_start_offset_us"] or yclk_win_start_offset_us
  RegValues["yclk_win_end_guard_us"] = RegValues["yclk_win_end_guard_us"] or yclk_win_end_guard_us
  RegValues["TERM_HIGH_uS"] = RegValues["TERM_HIGH_uS"] or TERM_HIGH_uS_in
  RegValues["TERM_TO_NEXT_YDIO_uS"] = RegValues["TERM_TO_NEXT_YDIO_uS"] or term_to_next_ydio_us_in
  RegValues["term_before_ydio"] = RegValues["term_before_ydio"] or (term_before_ydio and 1 or 0)
  RegValues["term_offset_from_ydio_us"] = RegValues["term_offset_from_ydio_us"] or term_offset_from_ydio_us

  -- ====== 從 Register 取得設定值 ======
  -- 注意：Register 的 Name 可能是 "CLK Phase"（含空白），但 Lua 習慣寫 "CLK_Phase"
  -- 這裡做相容，避免讀不到而永遠用 DAC=0 -> 8 phase
  local ckh_count = get_register_value("CLK_Phase",CLK_Phase)
  local pre_charge_count = get_register_dac("Pre_charge")
  local ckh_interval_dac = get_register_dac("CKH_Interval")
  local term_mode = get_register_dac("TERM_Mode")
  local clear_clk = get_register_value("CLEAR_CLK",CLEAR_CLK)

  -- CKH_Interval: 0='No time interval', 1='Some time interval'
  local has_ckh_interval = (ckh_interval_dac == 1)

  local warnings = {}

  -- ====== 計算 YDIO 週期（內部使用 ms，控制項輸入用 us）======
  local period_us = 0
  if ydio_hz > 0 then
    period_us = 1000000.0 / ydio_hz
  else
    period_us = 20000.0
    table.insert(warnings, "YDIO_HZ <= 0，已使用 period=20ms")
  end

  local YDIO_HIGH_uS = ydio_high_us_in
  if YDIO_HIGH_uS < 0 then YDIO_HIGH_uS = 0 end
  if YDIO_HIGH_uS > period_us then
    table.insert(warnings, string.format(
      "YDIO_HIGH_uS(%.3fus) > period(%.3fms=%.3fus)，已 clamp",
      ydio_high_us_in,
      period_us, period_us * 1000000.0
    ))
    YDIO_HIGH_uS = period_us
  end
  local ydio_low_ms = period_us - YDIO_HIGH_uS
  if ydio_low_ms < 0 then ydio_low_ms = 0 end

  -- ====== 自動計算 YCLK_HIGH_uS 和 YCLK_LOW_uS（如果 YCLK_PULSES 或 YDIO_HZ 改變）======
  -- 檢查 YCLK_PULSES 或 YDIO_HZ 是否改變，如果改變則自動計算以填滿 frame
  -- 注意：這只是初始設定，用戶之後可以手動調整 YCLK_HIGH_uS 和 YCLK_LOW_uS
  local previous_yclk_pulses = DiagramState["YCLK_PULSES"]
  local previous_ydio_hz = DiagramState["YDIO_HZ"]
  local yclk_pulses_changed = (previous_yclk_pulses == nil) or (previous_yclk_pulses ~= yclk_pulses)
  local ydio_hz_changed = (previous_ydio_hz == nil) or (math.abs(previous_ydio_hz - ydio_hz) > 0.001)  -- 允許小的浮點誤差
  
  if (yclk_pulses_changed or ydio_hz_changed) and yclk_pulses > 0 then
    if cascade_2pcs then
      -- 2pcs 串接模式：每個 IC 使用 yclk_pulses / 2 個 pulse
      local yclk_pulses_per_ic = math.floor(yclk_pulses / 2)
      
      if yclk_pulses_per_ic > 0 then
        -- 在 cascade_2pcs 模式下：
        -- YCLK1 從 yclk_high_us_in 開始，可用時間 = period_us - yclk_high_us_in
        -- YCLK2 從 yclk_high_us_in + yclk_high_us_in = 2 * yclk_high_us_in 開始
        -- 可用時間 = period_us - 2 * yclk_high_us_in
        --
        -- 在此模式下，為了讓 YCLK2 的 pulses 平均填滿可用時間：
        -- 2 * H * yclk_pulses_per_ic = period_us - 2 * H
        -- => H = period_us / (2 * (yclk_pulses_per_ic + 1))
        local half_pulse = period_us / (2.0 * (yclk_pulses_per_ic + 1))
        if half_pulse > 0 then
          yclk_high_us_in = half_pulse
          yclk_low_us_in = half_pulse
        end
      end
    else
      -- 單一模式：計算可用時間（從 window start offset 到 frame 結束）
      local available_time = period_us - yclk_win_start_offset_us
      
      if available_time > 0 then
        -- 計算每個 pulse 的平均時間（填滿可用時間）
        local pulse_width = available_time / yclk_pulses
        
        -- 重新平均填滿（high=low）
        yclk_high_us_in = pulse_width / 2.0
        yclk_low_us_in = pulse_width / 2.0
      end
    end
    
    -- 更新 RegValues（只有在 YCLK_PULSES 或 YDIO_HZ 改變時才自動計算並更新）
    RegValues["YCLK_HIGH_uS"] = yclk_high_us_in
    RegValues["YCLK_LOW_uS"] = yclk_low_us_in
    
    -- 記錄當前的 YCLK_PULSES 和 YDIO_HZ，用於下次比較
    DiagramState["YCLK_PULSES"] = yclk_pulses
    DiagramState["YDIO_HZ"] = ydio_hz
  else
    -- 如果 YCLK_PULSES 和 YDIO_HZ 都沒有改變，使用 RegValues 中的值（用戶可能已經手動調整過）
    -- 優先使用 RegValues 中的值，這樣用戶手動調整的值會被保留
    yclk_high_us_in = RegValues["YCLK_HIGH_uS"] or yclk_high_us_in
    yclk_low_us_in = RegValues["YCLK_LOW_uS"] or yclk_low_us_in
    -- 確保 RegValues 中有這些值（如果用戶手動調整過，這些值已經在 RegValues 中了）
    RegValues["YCLK_HIGH_uS"] = yclk_high_us_in
    RegValues["YCLK_LOW_uS"] = yclk_low_us_in
  end

  -- ====== 建立輸入波形：YDIO / YCLK / Terminate ======
  local total_us = sim_cycles * period_us + SIM_TAIL_uS
  local dummy_start_time = -1000
  -- YDIO
  local ydio_pts = {}
  push_pt(ydio_pts, dummy_start_time, 0)
  for i = 0, sim_cycles - 1 do
    local t0 = i * period_us
    local tr = t0
    local tf = t0 + YDIO_HIGH_uS
    set_transition(ydio_pts, tr, 1)  -- 從 0 轉到 1
    set_transition(ydio_pts, tf, 0)  -- 從 1 轉到 0
  end
  set_transition(ydio_pts, total_us, 0)

  -- YCLK：每個 frame 的 window 內產生固定 pulse 數
  -- 若 window 時間不足以容納 pulses*(high+low)，則保留 pulse 數，等比例縮放 high/low
  local yclk_labels = {}
  local yclk_pts = {}
  push_pt(yclk_pts, dummy_start_time, 0)

  -- 2pcs串接模式：生成YCLK1和YCLK2
  local yclk1_pts = {}
  local yclk2_pts = {}
  local yclk1_labels = {}
  local yclk2_labels = {}
  if cascade_2pcs then
    push_pt(yclk1_pts, dummy_start_time, 0)
    push_pt(yclk2_pts, dummy_start_time, 0)
  end

  local YCLK_HIGH_uS_last = math.max(0, yclk_high_us_in)
  local YCLK_LOW_uS_last = math.max(0, yclk_low_us_in)
  local yclk_scale_last = 1.0
  local yclk_available_last = 0.0

  -- 生成YCLK（單一模式）或YCLK1/YCLK2（2pcs串接模式）
  if cascade_2pcs then
    -- 2pcs串接模式：YCLK1和YCLK2的pulse數為YCLK_PULSES的一半
    -- YCLK1起始offset為YCLK_HIGH_uS，YCLK2起始點延遲YCLK1 YCLK_HIGH_uS的時間
    local yclk_pulses_per_ic = math.floor(yclk_pulses / 2)
    local yclk_start_offset = yclk_high_us_in

    for i = 0, sim_cycles - 1 do
      local t0 = i * period_us
      if yclk_pulses_per_ic > 0 then
        -- YCLK1
        local win_start1 = t0 + yclk_start_offset
        local win_end = (i + 1) * period_us
        local available = win_end - win_start1
        yclk_available_last = available

        if available <= 0 then
          table.insert(warnings, string.format(
            "YCLK1: frame%d window 時間不足 (available=%.3fus)，已略過該 frame 的 YCLK1",
            i, available
          ))
        else
          local hi = math.max(0, yclk_high_us_in)
          local lo = math.max(0, yclk_low_us_in)
          local pulse_w = hi + lo
          if pulse_w <= 0 then
            table.insert(warnings, "YCLK1: (high+low) <= 0，已略過")
          else
            local need = yclk_pulses_per_ic * pulse_w
            local scale = 1.0
            if need > available then
              scale = available / need
              hi = hi * scale
              lo = lo * scale
            end

            YCLK_HIGH_uS_last = hi
            YCLK_LOW_uS_last = lo
            yclk_scale_last = scale

            local pulse_w_eff = hi + lo
            for p = 0, yclk_pulses_per_ic - 1 do
              local ts = win_start1 + p * pulse_w_eff
              local th = ts + hi
              if th > win_end + 1e-6 then
                break
              end
              set_transition(yclk1_pts, ts, 1)
              set_transition(yclk1_pts, th, 0)
              table.insert(yclk1_labels, { t = ts, text = tostring(p+1) })
            end
          end
        end

        -- YCLK2：起始點延遲YCLK1 YCLK_HIGH_uS的時間
        local win_start2 = win_start1 + yclk_high_us_in  -- YCLK2延遲YCLK1 YCLK_HIGH_uS
        local available2 = win_end - win_start2
        if available2 <= 0 then
          table.insert(warnings, string.format(
            "YCLK2: frame%d window 時間不足 (available=%.3fus)，已略過該 frame 的 YCLK2",
            i, available2
          ))
        else
          local hi = YCLK_HIGH_uS_last  -- 使用YCLK1計算出的值
          local lo = YCLK_LOW_uS_last
          local pulse_w = hi + lo
          if pulse_w <= 0 then
            table.insert(warnings, "YCLK2: (high+low) <= 0，已略過")
          else
            local pulse_w_eff = hi + lo
            for p = 0, yclk_pulses_per_ic - 1 do
              local ts = win_start2 + p * pulse_w_eff
              local th = ts + hi
              if th > win_end + 1e-6 then
                break
              end
              set_transition(yclk2_pts, ts, 1)
              set_transition(yclk2_pts, th, 0)
              table.insert(yclk2_labels, { t = ts, text = tostring(p+1) })
            end
          end
        end
      end
    end
    set_transition(yclk1_pts, total_us, 0)
    set_transition(yclk2_pts, total_us, 0)
  else
    -- 單一模式：原有的YCLK生成邏輯
    for i = 0, sim_cycles - 1 do
      local t0 = i * period_us
      if yclk_pulses > 0 then
        local win_start = t0 + yclk_win_start_offset_us
        -- YCLK 窗口結束時間直接使用 period_us（不受 Terminate 限制）
        local win_end = (i + 1) * period_us
        
        local available = win_end - win_start
        yclk_available_last = available

        if available <= 0 then
          table.insert(warnings, string.format(
            "YCLK: frame%d window 時間不足 (available=%.3fms=%.3fus)，已略過該 frame 的 YCLK",
            i, available, available 
          ))
        else
          local hi = math.max(0, yclk_high_us_in)
          local lo = math.max(0, yclk_low_us_in)
          local pulse_w = hi + lo
          if pulse_w <= 0 then
            table.insert(warnings, "YCLK: (high+low) <= 0，已略過")
          else
            local need = yclk_pulses * pulse_w
            local scale = 1.0
            if need > available then
              scale = available / need
              hi = hi * scale
              lo = lo * scale
              table.insert(warnings, string.format(
                "YCLK: window(%.3fms=%.3fus) 不足以容納 pulses=%d, (high+low)=%.3fms=%.3fus，已等比例縮放：scale=%.6f, high=%.3fms=%.3fus, low=%.3fms=%.3fus",
                available, available ,
                yclk_pulses,
                pulse_w, pulse_w ,
                scale,
                hi, hi ,
                lo, lo 
              ))
            end

            YCLK_HIGH_uS_last = hi
            YCLK_LOW_uS_last = lo
            yclk_scale_last = scale

            local pulse_w_eff = hi + lo
            for p = 0, yclk_pulses - 1 do
              local ts = win_start + p * pulse_w_eff
              local th = ts + hi
              if th > win_end + 1e-6 then
                break
              end
              set_transition(yclk_pts, ts, 1)  -- 從 0 轉到 1
              set_transition(yclk_pts, th, 0)  -- 從 1 轉到 0
              table.insert(yclk_labels, { t = ts, text = tostring(p+1) })

            end
          end
        end
      end
    end
    set_transition(yclk_pts, total_us, 0)
  end

  -- Terminate：預設 Low，在每個 frame 尾端打一個 High pulse
  local term_pts = {}
  push_pt(term_pts, dummy_start_time, 0)  -- 初始為低

  for i = 0, sim_cycles - 1 do
    local t0 = i * period_us
    local next_rise = (i + 1) * period_us
    local TERM_HIGH_uS = math.max(0, TERM_HIGH_uS_in)
    
    local term_start, term_end
    
    if term_before_ydio then
      -- 新模式：相對於 YDIO rising 設定位置
      term_start = t0 + term_offset_from_ydio_us
      term_end = term_start + TERM_HIGH_uS
    else
      -- 原本邏輯：在 frame 尾端，距離下一個 YDIO rising 有間隔
      local TERM_TO_NEXT_YDIO_uS = math.max(0, term_to_next_ydio_us_in)
      term_end = next_rise - TERM_TO_NEXT_YDIO_uS
      term_start = term_end - TERM_HIGH_uS
    end

    -- 驗證和調整
    if term_before_ydio then
      -- 新模式：相對於 YDIO rising 設定位置（可以是之前或之後）
      -- 如果 offset < 0（Terminate 在 YDIO 之前），限制 term_end 不超過 t0
      -- 如果 offset >= 0（Terminate 在 YDIO 之後），不限制，允許延伸到 frame 內
      if term_offset_from_ydio_us < 0 and term_end > t0 then
        term_end = t0
      end
      
      -- 限制 term_start 的最小值（允許負數時間）
      -- 第一個 frame：允許 >= dummy_start_time（通常是 -1000）
      -- 其他 frame：允許 >= 前一個 frame 的開始時間
      local min_start = (i == 0) and dummy_start_time or ((i - 1) * period_us)
      if term_start < min_start then
        term_start = min_start
      end
      
      -- 檢查 pulse 是否有效
      if term_end <= term_start then
        -- pulse 寬度為 0 或負數，跳過
        table.insert(warnings, string.format(
          "Terminate: frame%d term_end=%.3fms=%.3fus <= term_start=%.3fms=%.3fus，已略過該 frame",
          i, term_end, term_end , term_start, term_start 
        ))
      else
        -- pulse 有效，生成 Terminate（允許負數時間）
        set_transition(term_pts, term_start, 1)
        set_transition(term_pts, term_end, 0)
      end
    else
      -- 原本邏輯：在 frame 尾端
      if term_end <= t0 then
        table.insert(warnings, string.format(
          "Terminate: frame%d term_end=%.3fms=%.3fus <= frame_start=%.3fms=%.3fus，已略過該 frame",
          i, term_end, term_end , t0, t0 
        ))
      else
        if term_start < t0 then
          table.insert(warnings, string.format(
            "Terminate: frame%d term_start=%.3fms=%.3fus < frame_start=%.3fms=%.3fus，已 clamp",
            i, term_start, term_start , t0, t0 
          ))
          term_start = t0
        end
        if term_start < 0 then term_start = 0 end
        if term_end < term_start then term_end = term_start end
        set_transition(term_pts, term_start, 1)
        set_transition(term_pts, term_end, 0)
      end
    end
  end
  set_transition(term_pts, total_us, 0)

  -- ====== 根據 Register 設定產生輸出波形：STH1 / CKH1~CKH8 ======
  
  -- STH1：跟隨 YDIO
  local sth1_pts = {}
  push_pt(sth1_pts, dummy_start_time, 0)

  -- 產生所有 CKH 信號（單一模式：CKH1~CKH8；2pcs串接模式：CKH1~CKH16；未使用的 CKH 需永遠維持 Low）
  local CKH_MAX = cascade_2pcs and 16 or 8
  local ckh_pts_list = {}
  for i = 1, CKH_MAX do
    local pts = {}
    push_pt(pts, dummy_start_time, 0)
    ckh_pts_list[i] = pts
  end

  -- 建立可查詢的輸入數位訊號（可用於控制輸出波形）
  local ydioSig = DiagramHelper.CreateDigitalSignal(ydio_pts)
  local yclkSig = cascade_2pcs and nil or DiagramHelper.CreateDigitalSignal(yclk_pts)
  local yclk1Sig = cascade_2pcs and DiagramHelper.CreateDigitalSignal(yclk1_pts) or nil
  local yclk2Sig = cascade_2pcs and DiagramHelper.CreateDigitalSignal(yclk2_pts) or nil
  local termSig = DiagramHelper.CreateDigitalSignal(term_pts)

  local ydio_rising_edges = ydioSig.RisingEdges
  local yclk_rising_edges = cascade_2pcs and {} or yclkSig.RisingEdges
  local yclk1_rising_edges = cascade_2pcs and yclk1Sig.RisingEdges or {}
  local yclk2_rising_edges = cascade_2pcs and yclk2Sig.RisingEdges or {}
  local term_rising_edges = termSig.RisingEdges
  local ydio_falling_edges = ydioSig.FallingEdges
  local yclk_falling_edges = cascade_2pcs and {} or yclkSig.FallingEdges
  local yclk1_falling_edges = cascade_2pcs and yclk1Sig.FallingEdges or {}
  local yclk2_falling_edges = cascade_2pcs and yclk2Sig.FallingEdges or {}
  local term_falling_edges = termSig.FallingEdges

  -- 合併所有事件並排序（Terminate rising -> YDIO rising -> YCLK rising）
  local events = {}
  for _, t in ipairs(ydio_rising_edges) do
    table.insert(events, {type = "ydio_rise", time = t})
  end
  if cascade_2pcs then
    -- 2pcs串接模式：分別處理YCLK1和YCLK2
    for _, t in ipairs(yclk1_rising_edges) do
      table.insert(events, {type = "yclk_rise", time = t, ic_index = 1})
    end
    for _, t in ipairs(yclk2_rising_edges) do
      table.insert(events, {type = "yclk_rise", time = t, ic_index = 2})
    end
    for _, t in ipairs(yclk1_falling_edges) do
      table.insert(events, {type = "yclk_fall", time = t, ic_index = 1})
    end
    for _, t in ipairs(yclk2_falling_edges) do
      table.insert(events, {type = "yclk_fall", time = t, ic_index = 2})
    end
  else
    -- 單一模式：原有的YCLK事件
    for _, t in ipairs(yclk_rising_edges) do
      table.insert(events, {type = "yclk_rise", time = t})
    end
    for _, t in ipairs(yclk_falling_edges) do
      table.insert(events, {type = "yclk_fall", time = t})
    end
  end
  for _, t in ipairs(term_rising_edges) do
    table.insert(events, {type = "term_rise", time = t})
  end
  for _, t in ipairs(ydio_falling_edges) do
    table.insert(events, {type = "ydio_fall", time = t})
  end
  for _, t in ipairs(term_falling_edges) do
    table.insert(events, {type = "term_fall", time = t})
  end
  local function event_pri2(tp)
    if tp == "ydio_rise" then return 0 end
    if tp == "term_rise" then return 1 end
    if tp == "yclk_rise" then return 2 end
    if tp == "yclk_fall" then return 3 end
    if tp == "ydio_fall" then return 4 end
    if tp == "term_fall" then return 5 end
  end
  table.sort(events, function(a, b)
    if a.time ~= b.time then return a.time < b.time end
    return event_pri2(a.type) < event_pri2(b.type)
  end)
  local clear_clk_idx = 0
  local yclk_rise_idx = 0
  local yclk_fall_idx = 0
  local active_end_rise_idx = {}
  local active_end_fall_idx = {}
  local term_mode0_activated = false
  local term_mode1_activated = false
  local ckh_activated = false

  -- 2pcs串接模式：分別追蹤兩個IC的狀態
  local clear_clk_idx_ic1 = 0
  local yclk_rise_idx_ic1 = 0
  local yclk_fall_idx_ic1 = 0
  local active_end_rise_idx_ic1 = {}
  local active_end_fall_idx_ic1 = {}
  local term_mode0_activated_ic1 = false
  local term_mode1_activated_ic1 = false
  local ckh_activated_ic1 = false

  local clear_clk_idx_ic2 = 0
  local yclk_rise_idx_ic2 = 0
  local yclk_fall_idx_ic2 = 0
  local active_end_rise_idx_ic2 = {}
  local active_end_fall_idx_ic2 = {}
  local term_mode0_activated_ic2 = false
  local term_mode1_activated_ic2 = false
  local ckh_activated_ic2 = false

  -- 記錄 YCLK Rising Edge 的標籤（時間和索引）

  local function all_ckh_low(t, ic_index)
    if cascade_2pcs and ic_index then
      -- 2pcs串接模式：第1顆IC處理奇數，第2顆IC處理偶數
      local start_parity = (ic_index == 1) and 1 or 2  -- 1=奇數, 2=偶數
      for ckh_idx = start_parity, CKH_MAX, 2 do
        set_transition(ckh_pts_list[ckh_idx], t, 0)
        local phase_idx_in_ic = math.floor((ckh_idx - start_parity) / 2) + 1
        if ic_index == 1 then
          active_end_rise_idx_ic1[phase_idx_in_ic] = nil
          active_end_fall_idx_ic1[phase_idx_in_ic] = nil
        else
          active_end_rise_idx_ic2[phase_idx_in_ic] = nil
          active_end_fall_idx_ic2[phase_idx_in_ic] = nil
        end
      end
    else
      -- 單一模式：處理所有CKH
      for i = 1, CKH_MAX do
        set_transition(ckh_pts_list[i], t, 0)
        active_end_rise_idx[i] = nil
        active_end_fall_idx[i] = nil
      end
    end
  end

  for _, event in ipairs(events) do
    if event.type == "term_rise" then
      -- Terminate rising：依 Terminate 模式控制 CKH
      if term_mode == 0 then
        term_mode0_activated = true
        if cascade_2pcs then
          term_mode0_activated_ic1 = true
          term_mode0_activated_ic2 = true
        end
        all_ckh_low(event.time, nil)
        if cascade_2pcs then
          all_ckh_low(event.time, 1)  -- IC1處理奇數
          all_ckh_low(event.time, 2)  -- IC2處理偶數
        end
      elseif term_mode == 1 then
        clear_clk_idx = 0
        term_mode1_activated = true
        if cascade_2pcs then
          clear_clk_idx_ic1 = 0
          clear_clk_idx_ic2 = 0
          term_mode0_activated_ic1 = false
          term_mode0_activated_ic2 = false
          term_mode1_activated_ic1 = true
          term_mode1_activated_ic2 = true
        end
      end
    elseif event.type == "ydio_rise" then
      -- Frame 起點：重置 YCLK index，並把 CKH 清成 Low
      if term_mode == 0 then
        yclk_rise_idx = 0
        yclk_fall_idx = 0
        if cascade_2pcs then
          yclk_rise_idx_ic1 = 0
          yclk_fall_idx_ic1 = 0
          yclk_rise_idx_ic2 = 0
          yclk_fall_idx_ic2 = 0
        end
        if term_mode0_activated then
          set_transition(sth1_pts, event.time, 1)
          ckh_activated = true
          term_mode0_activated = false
          if cascade_2pcs then
            ckh_activated_ic1 = true
            ckh_activated_ic2 = true
            term_mode0_activated_ic1 = false
            term_mode0_activated_ic2 = false
          end
        end
      elseif term_mode == 1 then
        set_transition(sth1_pts, event.time, 1)
        ckh_activated = true
        if cascade_2pcs then
          ckh_activated_ic1 = true
          ckh_activated_ic2 = true
        end
      end
      
    elseif event.type == "ydio_fall" then
      set_transition(sth1_pts, event.time, 0)
    elseif event.type == "yclk_rise" then
      local ic_index = event.ic_index
      if cascade_2pcs and ic_index then
        -- 2pcs串接模式：根據ic_index處理對應的IC
        -- IC1處理奇數：1,3,5,7,9,11,13,15；IC2處理偶數：2,4,6,8,10,12,14,16
        local ckh_parity = (ic_index == 1) and 1 or 2  -- 1=奇數, 2=偶數
        local yclk_rise_idx_ic = (ic_index == 1) and yclk_rise_idx_ic1 or yclk_rise_idx_ic2
        local yclk_fall_idx_ic = (ic_index == 1) and yclk_fall_idx_ic1 or yclk_fall_idx_ic2
        local term_mode0_activated_ic = (ic_index == 1) and term_mode0_activated_ic1 or term_mode0_activated_ic2
        local term_mode1_activated_ic = (ic_index == 1) and term_mode1_activated_ic1 or term_mode1_activated_ic2
        local ckh_activated_ic = (ic_index == 1) and ckh_activated_ic1 or ckh_activated_ic2
        local active_end_rise_idx_ic = (ic_index == 1) and active_end_rise_idx_ic1 or active_end_rise_idx_ic2
        local active_end_fall_idx_ic = (ic_index == 1) and active_end_fall_idx_ic1 or active_end_fall_idx_ic2

        local clear_clk_idx_ic = (ic_index == 1) and clear_clk_idx_ic1 or clear_clk_idx_ic2
        -- 在加總之前就判斷是否仍在阻擋期，避免提前放行
        local term_mode1_block = term_mode1_activated_ic and (clear_clk_idx_ic < clear_clk)
        if term_mode1_activated_ic then
          if clear_clk_idx_ic == clear_clk then
            if ic_index == 1 then
              yclk_rise_idx_ic1 = 0
              yclk_fall_idx_ic1 = 0
              term_mode1_activated_ic1 = false
              term_mode0_activated_ic1 = false
            else
              yclk_rise_idx_ic2 = 0
              yclk_fall_idx_ic2 = 0
              term_mode1_activated_ic2 = false
              term_mode0_activated_ic2 = false
            end
          end

          -- term_mode1 在 cascade_2pcs 由 term_mode1_block 控制阻擋，不用提早拉低
          -- (避免 clear_clk-1 的低電位導致放行延後一拍)
          -- elseif clear_clk_idx_ic == clear_clk-1 then ... end
          if ic_index == 1 then
            clear_clk_idx_ic1 = clear_clk_idx_ic1 + 1
          else
            clear_clk_idx_ic2 = clear_clk_idx_ic2 + 1
          end
        end
        -- 重新抓取更新後的狀態，確保同一個 edge 能正確放行 CKH
        term_mode0_activated_ic = (ic_index == 1) and term_mode0_activated_ic1 or term_mode0_activated_ic2
        term_mode1_activated_ic = (ic_index == 1) and term_mode1_activated_ic1 or term_mode1_activated_ic2
        -- 重新取得最新的 clear_clk_idx_ic，避免使用舊值
        clear_clk_idx_ic = (ic_index == 1) and clear_clk_idx_ic1 or clear_clk_idx_ic2
        -- 若已達 clear_clk，視為 term_mode1 放行（避免狀態未即時更新導致多擋一拍）
        -- term_mode1_block 以「加總前」的 clear_clk_idx_ic 判斷，避免提前放行

        if ckh_activated_ic then
          -- 無論是否阻擋，先前進 YCLK 計數，讓尾端結束判斷依舊進行
          if ic_index == 1 then
            yclk_rise_idx_ic1 = yclk_rise_idx_ic1 + 1
            yclk_rise_idx_ic = yclk_rise_idx_ic1
          else
            yclk_rise_idx_ic2 = yclk_rise_idx_ic2 + 1
            yclk_rise_idx_ic = yclk_rise_idx_ic2
          end

          if term_mode0_activated_ic then
            all_ckh_low(event.time, ic_index)
          elseif term_mode1_block then
            -- 阻擋期間：不發新脈衝，但仍允許尾端收斂
            if not has_ckh_interval then
              for ckh_idx = ckh_parity, CKH_MAX, 2 do
                local phase_idx_in_ic = math.floor((ckh_idx - ckh_parity) / 2) + 1
                if phase_idx_in_ic <= ckh_count and active_end_rise_idx_ic[phase_idx_in_ic] == yclk_rise_idx_ic then
                  set_transition(ckh_pts_list[ckh_idx], event.time, 0)
                  active_end_rise_idx_ic[phase_idx_in_ic] = nil
                end
              end
            end
            -- has_ckh_interval 模式下，尾端收斂在 fall 邏輯處理
          else
            if not has_ckh_interval then
              -- 檢查對應奇偶數的CKH是否需要結束
              for ckh_idx = ckh_parity, CKH_MAX, 2 do
                local phase_idx_in_ic = math.floor((ckh_idx - ckh_parity) / 2) + 1
                if phase_idx_in_ic <= ckh_count and active_end_rise_idx_ic[phase_idx_in_ic] == yclk_rise_idx_ic then
                  set_transition(ckh_pts_list[ckh_idx], event.time, 0)
                  active_end_rise_idx_ic[phase_idx_in_ic] = nil
                end
              end
            end

            if ckh_count > 0 then
              local phase_idx = ((yclk_rise_idx_ic - 1) % ckh_count) + 1
              -- 計算對應的CKH索引：IC1用奇數，IC2用偶數
              local ckh_idx = (phase_idx - 1) * 2 + ckh_parity
              if ckh_idx <= CKH_MAX then
                set_transition(ckh_pts_list[ckh_idx], event.time, 1)

                if has_ckh_interval then
                  active_end_fall_idx_ic[phase_idx] = yclk_rise_idx_ic + pre_charge_count
                else
                  active_end_rise_idx_ic[phase_idx] = yclk_rise_idx_ic + pre_charge_count + 1
                end
              end
            end
          end

          -- 更新對應IC的狀態
          if ic_index == 1 then
            active_end_rise_idx_ic1 = active_end_rise_idx_ic
            active_end_fall_idx_ic1 = active_end_fall_idx_ic
          else
            active_end_rise_idx_ic2 = active_end_rise_idx_ic
            active_end_fall_idx_ic2 = active_end_fall_idx_ic
          end
        end
      else
        -- 單一模式：原有的邏輯
        if term_mode1_activated then
          if clear_clk_idx == clear_clk then
            yclk_rise_idx = 0
            yclk_fall_idx = 0
            term_mode1_activated = false
            term_mode0_activated = false
          elseif clear_clk_idx == clear_clk-1 then
            term_mode0_activated = true
          end
          clear_clk_idx = clear_clk_idx + 1
        end
        if ckh_activated then
          yclk_rise_idx = yclk_rise_idx + 1
          if term_mode0_activated then
            all_ckh_low(event.time, 0)
          else
            if not has_ckh_interval then
              for i = 1, CKH_MAX do
                if active_end_rise_idx[i] == yclk_rise_idx then
                  set_transition(ckh_pts_list[i], event.time, 0)
                  active_end_rise_idx[i] = nil
                end
              end
            end

            if ckh_count > 0 and not term_mode1_activated then
              local phase_idx = ((yclk_rise_idx - 1) % ckh_count) + 1
              set_transition(ckh_pts_list[phase_idx], event.time, 1)

              if has_ckh_interval then
                active_end_fall_idx[phase_idx] = yclk_rise_idx + pre_charge_count
              else
                active_end_rise_idx[phase_idx] = yclk_rise_idx + pre_charge_count + 1
              end
            end
          end
        end
      end

    elseif event.type == "yclk_fall" then
      local ic_index = event.ic_index
      if cascade_2pcs and ic_index then
        -- 2pcs串接模式：根據ic_index處理對應的IC
        -- IC1處理奇數：1,3,5,7,9,11,13,15；IC2處理偶數：2,4,6,8,10,12,14,16
        local ckh_parity = (ic_index == 1) and 1 or 2  -- 1=奇數, 2=偶數
        if ic_index == 1 then
          yclk_fall_idx_ic1 = yclk_fall_idx_ic1 + 1
        else
          yclk_fall_idx_ic2 = yclk_fall_idx_ic2 + 1
        end
        local yclk_fall_idx_ic = (ic_index == 1) and yclk_fall_idx_ic1 or yclk_fall_idx_ic2
        local active_end_fall_idx_ic = (ic_index == 1) and active_end_fall_idx_ic1 or active_end_fall_idx_ic2

        if has_ckh_interval then
          -- 檢查對應奇偶數的CKH是否需要結束
          for ckh_idx = ckh_parity, CKH_MAX, 2 do
            local phase_idx_in_ic = math.floor((ckh_idx - ckh_parity) / 2) + 1
            if phase_idx_in_ic <= ckh_count and active_end_fall_idx_ic[phase_idx_in_ic] == yclk_fall_idx_ic then
              set_transition(ckh_pts_list[ckh_idx], event.time, 0)
              active_end_fall_idx_ic[phase_idx_in_ic] = nil
            end
          end
        end

        -- 更新對應IC的狀態
        if ic_index == 1 then
          active_end_fall_idx_ic1 = active_end_fall_idx_ic
        else
          active_end_fall_idx_ic2 = active_end_fall_idx_ic
        end
      else
        -- 單一模式：原有的邏輯
        yclk_fall_idx = yclk_fall_idx + 1

        if has_ckh_interval then
          for i = 1, CKH_MAX do
            if active_end_fall_idx[i] == yclk_fall_idx then
              set_transition(ckh_pts_list[i], event.time, 0)
              active_end_fall_idx[i] = nil
            end
          end
        end
      end
    end

  end

  -- 為所有信號添加結束點
  set_transition(sth1_pts, total_us, 0)
  for i = 1, CKH_MAX do
    set_transition(ckh_pts_list[i], total_us, 0)
  end

  -- ====== Channels ======
  local YDIO = channel("YDIO", "#4F81BD", ydio_pts, {
    editable = true,
    isExtra = true,
    note = string.format(
      "Hz=%.2f, period=%.3fms=%.3fus, high=%.3fus, low=%.3fus",
      ydio_hz, period_us, period_us , YDIO_HIGH_uS , ydio_low_ms 
    )
  })

  local YCLK, YCLK1, YCLK2
  if cascade_2pcs then
    -- 2pcs串接模式：顯示YCLK1和YCLK2
    local yclk_pulses_per_ic = math.floor(yclk_pulses / 2)
    YCLK1 = channel("YCLK1", "#C0504D", yclk1_pts, {
      editable = true,
      isExtra = true,
      note = string.format(
        "IC1: pulses=%d (YCLK_PULSES/2), start_offset=%.3fus (YCLK_HIGH_uS), req_high=%.3fus, req_low=%.3fus, scale=%.6f, high=%.3fus, low=%.3fus",
        yclk_pulses_per_ic,
        yclk_high_us_in,
        yclk_high_us_in, yclk_low_us_in,
        yclk_scale_last,
        YCLK_HIGH_uS_last, YCLK_LOW_uS_last
      ),
      labels = yclk1_labels
    })
    YCLK2 = channel("YCLK2", "#E46C0A", yclk2_pts, {
      editable = true,
      isExtra = true,
      note = string.format(
        "IC2: pulses=%d (YCLK_PULSES/2), start_delay=%.3fus (YCLK1_start + YCLK_HIGH_uS), req_high=%.3fus, req_low=%.3fus, scale=%.6f, high=%.3fus, low=%.3fus",
        yclk_pulses_per_ic,
        yclk_high_us_in,
        yclk_high_us_in, yclk_low_us_in,
        yclk_scale_last,
        YCLK_HIGH_uS_last, YCLK_LOW_uS_last
      ),
      labels = yclk2_labels
    })
  else
    -- 單一模式：顯示YCLK
    YCLK = channel("YCLK", "#C0504D", yclk_pts, {
      editable = true,
      isExtra = true,
      note = string.format(
        "pulses=%d, win_start_offset=%.3fus, win_end_guard=%.3fus, req_high=%.3fus, req_low=%.3fus, scale=%.6f, high=%.3fus, low=%.3fus, avail=%.3fus",
        yclk_pulses,
        yclk_win_start_offset_us, yclk_win_end_guard_us,
        yclk_high_us_in, yclk_low_us_in,
        yclk_scale_last,
        YCLK_HIGH_uS_last , YCLK_LOW_uS_last,
        yclk_available_last 
      ),
      labels = yclk_labels
    })
  end

  local TERM = channel("Terminate", "#9BBB59", term_pts, {
    editable = true,
    isExtra = true,
    note = string.format("high=%.3fus, to_next_YDIO=%.3fus (default low, end-of-frame high pulse)", TERM_HIGH_uS_in, term_to_next_ydio_us_in)
  })

  local STH1 = channel("STH1", "#8064A2", sth1_pts, {
    note = string.format("根據 YDIO 和 Register 設定產生")
  })

  -- 動態產生 CKH 通道
  local ckh_channels = {}
  local ckh_colors = {"#F79646", "#1F497D", "#4BACC6", "#806000", "#31859B", "#604A7B", "#7F6000", "#2F5597"}
  for i = 1, CKH_MAX do
    local color = ckh_colors[((i - 1) % #ckh_colors) + 1]
    local is_odd = (i % 2 == 1)
    local ic_num = cascade_2pcs and (is_odd and 1 or 2) or 1
    local phase_idx_in_ic = cascade_2pcs and (math.floor((i - (is_odd and 1 or 2)) / 2) + 1) or i
    local active = (phase_idx_in_ic <= ckh_count)
    local note_text
    if cascade_2pcs then
      local parity_text = is_odd and "Odd" or "Even"
      note_text = active
        and string.format("IC%d (CKH%d %s): Active (CLK_Phase=%d, Pre_charge=%d, CKH_Interval=%s)", ic_num, i, parity_text, ckh_count, pre_charge_count, has_ckh_interval and "Some" or "No")
        or string.format("IC%d (CKH%d %s): Inactive (CLK_Phase=%d，此 channel 永遠為 Low）", ic_num, i, parity_text, ckh_count)
    else
      note_text = active
        and string.format("Active: CLK_Phase=%d, Pre_charge=%d, CKH_Interval=%s", ckh_count, pre_charge_count, has_ckh_interval and "Some" or "No")
        or string.format("Inactive: CLK_Phase=%d（此 channel 永遠為 Low）", ckh_count)
    end
    table.insert(ckh_channels, channel("CKH" .. i, color, ckh_pts_list[i], {
      visible = active,
      note = note_text
    }))
  end

  -- ====== UI controls（僅輸入信號）======
  local controls = {
    { key = "SIM_CYCLES", label = "Sim Cycles", min = 1, max = 10, step = 1, value = sim_cycles },
    { key = "SIM_TAIL_uS", label = "Sim Tail (ms)", min = 0, max = 50, step = 0.1, value = SIM_TAIL_uS },
    { key = "YDIO_HZ", label = "YDIO Freq (Hz)", min = 15, max = 480, step = 1, value = ydio_hz },
    { key = "YDIO_HIGH_uS", label = "YDIO High (us)", min = 0.1, max = 100, step = 0.1, value = ydio_high_us_in },
    { key = "cascade_2pcs", label = "2pcs Cascade", min = 0, max = 1, step = 1, value = cascade_2pcs and 1 or 0 },
    { key = "YCLK_PULSES", label = "YCLK Pulses", min = 768, max = 4096, step = 1, value = yclk_pulses },
    { key = "YCLK_HIGH_uS", label = "YCLK High (us)", min = 0.1, max = 100, step = 0.1, value = yclk_high_us_in },
    { key = "YCLK_LOW_uS", label = "YCLK Low (us)", min = 0.1, max = 100, step = 0.1, value = yclk_low_us_in },
    { key = "yclk_win_start_offset_us", label = "YCLK Win Start Offset (us)", min = -10000, max = 100, step = 0.1, value = yclk_win_start_offset_us },
    { key = "yclk_win_end_guard_us", label = "YCLK Win End Guard (us)", min = 0, max = 100, step = 0.1, value = yclk_win_end_guard_us },
    { key = "TERM_HIGH_uS", label = "TERM High (us)", min = 0.1, max = 100, step = 0.1, value = TERM_HIGH_uS_in },
    { key = "term_before_ydio", label = "Terminate Before YDIO", min = 0, max = 1, step = 1, value = term_before_ydio and 1 or 0 },
    { key = "term_offset_from_ydio_us", label = "TERM Offset from YDIO (us)", min = -10000, max = 10000, step = 0.1, value = term_offset_from_ydio_us },
    { key = "TERM_TO_NEXT_YDIO_uS", label = "TERM->Next YDIO (us)", min = 0.1, max = 10000, step = 0.1, value = term_to_next_ydio_us_in },
  }

  -- 組合所有通道
  local all_channels = {YDIO}
  if cascade_2pcs then
    table.insert(all_channels, YCLK1)
    table.insert(all_channels, YCLK2)
  else
    table.insert(all_channels, YCLK)
  end
  table.insert(all_channels, TERM)
  table.insert(all_channels, STH1)
  for i = 1, #ckh_channels do
    table.insert(all_channels, ckh_channels[i])
  end

  local diagram = {
    id = "s102_timing_diagram",
    title = string.format("S102.19 Timing Diagram %s (CKH Count=%d, Pre-charge=%d, Interval=%s)", 
      cascade_2pcs and "(2pcs Cascade)" or "(Single)", 
      ckh_count, pre_charge_count, has_ckh_interval and "Yes" or "No"),
    channels = all_channels,
    warnings = warnings,
    controls = controls,
    separatedYAxis = true,
    timeUnit = "us"  -- 使用微秒作為時間單位
  }

  return { diagrams = { diagram } }
end
-- 定義自訂按鈕功能
-- 這些函式會自動變成 UI 上的按鈕
i2capi = {
  ReadAll = function(ctx, deviceAddress)
    local addr = deviceAddress or 0x5E
    ctx:ReadI2C()
  end,

  WriteAll = function(ctx, deviceAddress)
    
    ctx:WriteI2C()
  end,
  
  WriteFuse = function(ctx, deviceAddress)
    -- 一行指令即可寫入所有暫存器（會自動使用 UI 中選取的暫存器表）
    local addr = deviceAddress or 0x5E
    --ctx:ReadI2C()
    local burned_counter_DAC = get_register_dac("Burned_Counter")
    local burned_counter = tostring(burned_counter_DAC)
    local message ={"目前IC已燒錄的次數為",burned_counter,"次\r\n總共只有5次\r\n確定要進行Fuse燒錄嗎？"}
    local r = MessageBox.Show(table.concat(message), "提示", "YesNo", "Question")
    if r == "Yes" then
    	ctx:WriteI2CByteIndex(addr, 0x20, 0x80)
    	delay(20)
    	ctx:ReadI2C()
    else
    	msgbox("Fuse燒錄取消","提示")
    end
  end,
  
  -- 組合操作範例：先讀取，再寫入燒錄指令，最後再讀取
  Reset = function(ctx, deviceAddress)   
    local addr = deviceAddress or 0x46
    ctx:WriteI2CByteIndex(addr, 0xff, 0x01)
    delay(20)
    ctx:ReadI2C()
  end
}