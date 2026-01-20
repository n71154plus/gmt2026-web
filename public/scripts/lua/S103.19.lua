function Build()
  return New.Product{
    Name        = 'S103.19',
    Type        = 'LS',
    Application = 'NoteBook',
    Package     = '',
    Description = 'S103.19 Level Shift IC',
    RegisterTable = {
      New.RegisterTable{
        Name = 'Default',
      DeviceAddress = { 0x5E },
        FrontDoorRegisters = {
          -- Charge Sharing Setting
      CS_CLK_Interval = New.Register{ Name='CS_CLK_Interval', Group='Charge Sharing Setting', MemI_B0={ Addr=0x03, MSB=2, LSB=0 }, DACValueExpr='lookup(\'External CS CLK\',\'0.25 us\',\'0.5 us\',\'0.75 us\',\'1.0 us\',\'1.25 us\',\'1.5 us\',\'2.0 us\')', DAC=0x00 },
          -- Charge Sharing Setting
      CS_Edge_Setting = New.Register{ Name='CS Edge Setting', Group='Charge Sharing Setting', MemI_B0={ Addr=0x02, MSB=5, LSB=4 }, DACValueExpr='lookup(\'No CS\',\'Rising Edge\',\'Falling Edge\',\'Both Edge\')', DAC=0x00 },
          -- Mode Setting
      LC2_Change = New.Register{ Name='LC2_Change', Group='Mode Setting & Multi Line-on', MemI_B0={ Addr=0x02, MSB=3, LSB=3 }, DACValueExpr='lookup(\'LC1 will follow LC, LC2 will be inverse of LC1\',\'LC1 will follow LC, LC2 will follow CS-CLK.\')', DAC=0x00 },
          -- Mode Setting
      TERM_Mode = New.Register{ Name='TERM_Mode', Group='Mode Setting & Multi Line-on', MemI_B0={ Addr=0x00, MSB=2, LSB=2 }, DACValueExpr='lookup(\'All CKH pull low while Terminate signal rising\',\'After Terminate signal rising, LVSH will close CKH in sequence without turning on any CKH\')', DAC=0x00 },
          -- Multi Line-On
      CKH_Multi_Line_On = New.Register{ Name='CKH_Multi_Line_On', Group='Mode Setting & Multi Line-on', MemI_B0={ Addr=0x01, MSB=6, LSB=6 }, DACValueExpr='lookup(\'Off(1 Line On)\',\'On(2 Line On)\')', DAC=0x00 },
          -- Multi Line-On
      CKH_Multi_Line_On_Type = New.Register{ Name='CKH_Multi_Line_On_Type', Group='Mode Setting & Multi Line-on', MemI_B0={ Addr=0x01, MSB=7, LSB=7 }, DACValueExpr='lookup(\'Type1(CKH1=CKH2, CKH3=CKH4, CKH5=CKH6, CKH7=CKH8, CKH9=CKH10, CKH11=CKH12\',\'Type2(CKH1=CKH3, CKH2=CKH4, CKH5=CKH7, CKH6=CKH8, CKH9=CKH11, CKH10=CKH12)\')', DAC=0x00 },
          -- On/Off Setting & Prog
      Burned_Counter = New.Register{ Name='Burned_Counter', Group='On/Off Setting & Prog', Unit='次', MemI_B0={ Addr=0xFE, MSB=2, LSB=0 }, ReadOnly=true, IsTextBlock=true, DACValueExpr='[DAC]', DAC=0x00 },
          -- On/Off Setting & Prog
      VGH_UVLO = New.Register{ Name='VGH_UVLO', Group='On/Off Setting & Prog', MemI_B0={ Addr=0x01, MSB=5, LSB=4 }, DACValueExpr='lookup(4,7,10,15)', DAC=0x00 },
          -- Phase Setting
      CKH_Interval = New.Register{ Name='CKH_Interval', Group='Phase Setting', Unit='time interval', MemI_B0={ Addr=0x00, MSB=1, LSB=1 }, DACValueExpr='lookup(\'No\',\'Some\')', DAC=0x00 },
          -- Phase Setting
      CLEAR_CLK = New.Register{ Name='CLEAR_CLK', Group='Phase Setting', Unit='VCE CLK Cycle', MemI_B0={ Addr=0x02, MSB=2, LSB=0 }, DACValueExpr='[DAC]+1', DAC=0x00 },
          -- Phase Setting
      CLK_Phase = New.Register{ Name='CLK_Phase', Group='Phase Setting', Unit='Phase', MemI_B0={ Addr=0x00, MSB=7, LSB=6 }, DACValueExpr='lookup(4,6,8,12)', DAC=0x00 },
          -- Phase Setting
      Pre_charge = New.Register{ Name='Pre_charge', Group='Phase Setting', Unit='Pre-Charge', MemI_B0={ Addr=0x00, MSB=5, LSB=3 }, DACValueExpr='lookup(\'No\',1,2,3,4,5,6,7)', DAC=0x00 },
          -- Protection Setting
      Multi_YDIO_Protection = New.Register{ Name='Multi YDIO Protection', Group='Protection Setting', MemI_B0={ Addr=0x02, MSB=7, LSB=7 }, DACValueExpr='lookup(\'Disable\',\'Enable\')', DAC=0x00 },
          -- Protection Setting
      VCE_Clock_Protection = New.Register{ Name='VCE Clock Protection', Group='Protection Setting', MemI_B0={ Addr=0x02, MSB=6, LSB=6 }, DACValueExpr='lookup(\'Disable\',\'Enable\')', DAC=0x00 },
          -- Slew Rate Setting
      CKH_Slew_rate = New.Register{ Name='CKH Slew rate', Group='Slew Rate Setting', MemI_B0={ Addr=0x01, MSB=3, LSB=2 }, DACValueExpr='lookup(\'Fastest\',\'Fast\',\'Middle\',\'Slow\')', DAC=0x00 },
          -- Slew Rate Setting
      MUX_Slew_rate = New.Register{ Name='MUX Slew rate', Group='Slew Rate Setting', MemI_B0={ Addr=0x01, MSB=1, LSB=0 }, DACValueExpr='lookup(\'Fastest\',\'Fast\',\'Middle\',\'Slow\')', DAC=0x00 },
        },
        ChecksumMemIndexCollect = {
        ['Default'] = { 0x00, 0x01, 0x02, 0x03},
        },
      NeedShowMemIndex = { 0x00, 0x01, 0x02, 0x03, 0xFE },
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
  local ydio_high_us_in = getnum("YDIO_HIGH_uS", 34.0)

  -- YCLK：每個 frame 內的 Gate Clock pulse train（可調 pulse 數 / high / low 與 window）
  local yclk_pulses = math.floor(getnum("YCLK_PULSES", 2012))
  local yclk_high_us_in = getnum("YCLK_HIGH_uS", 4.15)
  local yclk_low_us_in = getnum("YCLK_LOW_uS", 4.1)
  local yclk_win_start_offset_us = getnum("yclk_win_start_offset_us", 40.00)
  local yclk_win_end_guard_us = getnum("yclk_win_end_guard_us", 0.00)

  -- Terminate：每個 frame 尾端打一個 High pulse（預設為 Low）
  -- TERM_TO_NEXT_YDIO_uS：pulse 結束到下一次 YDIO rising 的間隔
  local TERM_HIGH_uS_in = getnum("TERM_HIGH_uS", 34.0)
  local term_to_next_ydio_us_in = getnum("TERM_TO_NEXT_YDIO_uS", 100.0)
  -- Terminate 位置控制：是否相對於 YDIO rising 設定（而非 frame 尾端）
  local term_before_ydio = (getnum("term_before_ydio", 1) ~= 0)  -- 0 表示 false，非 0 表示 true
  local term_offset_from_ydio_us = getnum("term_offset_from_ydio_us", 0.0)  -- 相對於 YDIO rising 的偏移（負數表示在 YDIO 之前）

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
    -- 單一模式：計算可用時間（從 window start offset 到 frame 結束）
    local available_time = period_us - yclk_win_start_offset_us
    
    if available_time > 0 then
      -- 計算每個 pulse 的平均時間（填滿可用時間）
      local pulse_width = available_time / yclk_pulses
      
      -- 重新平均填滿（high=low）
      yclk_high_us_in = pulse_width / 2.0
      yclk_low_us_in = pulse_width / 2.0
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

  local YCLK_HIGH_uS_last = math.max(0, yclk_high_us_in)
  local YCLK_LOW_uS_last = math.max(0, yclk_low_us_in)
  local yclk_scale_last = 1.0
  local yclk_available_last = 0.0

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

  -- 產生所有 CKH 信號（固定 CKH1~CKH12；未使用的 CKH 需永遠維持 Low）
  local CKH_MAX = 12
  local ckh_pts_list = {}
  for i = 1, CKH_MAX do
    local pts = {}
    push_pt(pts, dummy_start_time, 0)
    ckh_pts_list[i] = pts
  end

  -- 建立可查詢的輸入數位訊號（可用於控制輸出波形）
  local ydioSig = DiagramHelper.CreateDigitalSignal(ydio_pts)
  local yclkSig = DiagramHelper.CreateDigitalSignal(yclk_pts)
  local termSig = DiagramHelper.CreateDigitalSignal(term_pts)

  local ydio_rising_edges = ydioSig.RisingEdges
  local yclk_rising_edges = yclkSig.RisingEdges
  local term_rising_edges = termSig.RisingEdges
  local ydio_falling_edges = ydioSig.FallingEdges
  local yclk_falling_edges = yclkSig.FallingEdges
  local term_falling_edges = termSig.FallingEdges

  -- 合併所有事件並排序（Terminate rising -> YDIO rising -> YCLK rising）
  local events = {}
  for _, t in ipairs(ydio_rising_edges) do
    table.insert(events, {type = "ydio_rise", time = t})
  end
  for _, t in ipairs(yclk_rising_edges) do
    table.insert(events, {type = "yclk_rise", time = t})
  end
  for _, t in ipairs(term_rising_edges) do
    table.insert(events, {type = "term_rise", time = t})
  end
  for _, t in ipairs(ydio_falling_edges) do
    table.insert(events, {type = "ydio_fall", time = t})
  end
  for _, t in ipairs(yclk_falling_edges) do
    table.insert(events, {type = "yclk_fall", time = t})
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
  -- 記錄 YCLK Rising Edge 的標籤（時間和索引）


  local function all_ckh_low(t)
    for i = 1, CKH_MAX do
      set_transition(ckh_pts_list[i], t, 0)
      active_end_rise_idx[i] = nil
      active_end_fall_idx[i] = nil
    end
  end

  for _, event in ipairs(events) do
    if event.type == "term_rise" then
      -- Terminate rising：依 Terminate 模式控制 CKH
      if term_mode == 0 then
        term_mode0_activated = true
        all_ckh_low(event.time)
      elseif term_mode == 1 then
        clear_clk_idx = 0
        term_mode1_activated = true
      end
    elseif event.type == "ydio_rise" then
      -- Frame 起點：重置 YCLK index，並把 CKH 清成 Low
      if term_mode == 0 then
        yclk_rise_idx = 0
        yclk_fall_idx = 0
        if term_mode0_activated then
          set_transition(sth1_pts, event.time, 1)
          ckh_activated = true
          term_mode0_activated = false
        end
      elseif term_mode == 1 then
        set_transition(sth1_pts, event.time, 1)
        ckh_activated = true
      end
      
    elseif event.type == "ydio_fall" then
      set_transition(sth1_pts, event.time, 0)
    elseif event.type == "yclk_rise" then
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
        --table.insert(yclk_labels, { t = event.time, text = tostring(clear_clk_idx) })
      end
      if ckh_activated then
        yclk_rise_idx = yclk_rise_idx + 1
        -- 先處理「到指定 rising index 要結束」的 CKH（同一個 edge 上，先 fall 再 rise）
        if term_mode0_activated  then
          all_ckh_low(event.time)
        else
          if not has_ckh_interval then
            for i = 1, CKH_MAX do
              if active_end_rise_idx[i] == yclk_rise_idx then
                set_transition(ckh_pts_list[i], event.time, 0)
                active_end_rise_idx[i] = nil
              end
            end
          end

          -- 本次 rising 要拉高哪一個 CKH（只在 CKH1..CKHn 內周而復始；其餘 CKH 永遠 Low）
          if ckh_count > 0 and not term_mode1_activated then
            local phase_idx = ((yclk_rise_idx - 1) % ckh_count) + 1
            set_transition(ckh_pts_list[phase_idx], event.time, 1)

            if has_ckh_interval then
              -- Some Time Interval：end 於第 (start + Pre_Charge) 個 falling
              active_end_fall_idx[phase_idx] = yclk_rise_idx + pre_charge_count
            else
              -- No Time Interval：end 於第 (start + Pre_Charge + 1) 個 rising
              active_end_rise_idx[phase_idx] = yclk_rise_idx + pre_charge_count + 1
            end
          end
        end
      end

    elseif event.type == "yclk_fall" then
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
  local YCLK = channel("YCLK", "#C0504D", yclk_pts, {
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
  local ckh_colors = {"#F79646", "#1F497D", "#4BACC6", "#806000", "#31859B", "#604A7B", "#7F6000", "#2F5597", "#E36C09", "#00B0F0", "#C55A11", "#0070C0"}
  for i = 1, CKH_MAX do
    local color = ckh_colors[((i - 1) % #ckh_colors) + 1]
    local active = (i <= ckh_count)
    table.insert(ckh_channels, channel("CKH" .. i, color, ckh_pts_list[i], {
      visible = active,
      note = active
        and string.format("Active: CLK_Phase=%d, Pre_charge=%d, CKH_Interval=%s", ckh_count, pre_charge_count, has_ckh_interval and "Some" or "No")
        or string.format("Inactive: CLK_Phase=%d（此 channel 永遠為 Low）", ckh_count)
    }))
  end

  -- ====== UI controls（僅輸入信號）======
  local controls = {
    { key = "SIM_CYCLES", label = "Sim Cycles", min = 1, max = 10, step = 1, value = sim_cycles },
    { key = "SIM_TAIL_uS", label = "Sim Tail (ms)", min = 0, max = 50, step = 0.1, value = SIM_TAIL_uS },
    { key = "YDIO_HZ", label = "YDIO Freq (Hz)", min = 15, max = 480, step = 1, value = ydio_hz },
    { key = "YDIO_HIGH_uS", label = "YDIO High (us)", min = 0.1, max = 100, step = 0.1, value = ydio_high_us_in },
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
  local all_channels = {YDIO, YCLK, TERM, STH1}
  for i = 1, #ckh_channels do
    table.insert(all_channels, ckh_channels[i])
  end

  local diagram = {
    id = "S103_timing_diagram",
    title = string.format("S103.19 Timing Diagram (CKH Count=%d, Pre-charge=%d, Interval=%s)", ckh_count, pre_charge_count, has_ckh_interval and "Yes" or "No"),
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

    ctx:WriteI2CByteIndex(addr, 0xfd, 0x72)

    ctx:ReadI2C()
  end,

  WriteAll = function(ctx, deviceAddress)
    -- 一行指令即可讀取所有暫存器（會自動使用 UI 中選取的暫存器表）
    local addr = deviceAddress or 0x5E

    ctx:WriteI2CByteIndex(addr, 0xfd, 0x72)

    ctx:WriteI2C()
  end,
  
  WriteFuse = function(ctx, deviceAddress)
    -- 一行指令即可寫入所有暫存器（會自動使用 UI 中選取的暫存器表）
    local addr = deviceAddress or 0x5E
    ctx:ReadI2C()
    local burned_counter_DAC = DiagramHelper.GetRegisterDAC("Burned_Counter", RegValues)
    local burned_counter = tostring(burned_counter_DAC)
    local message ={"目前IC已燒錄的次數為",burned_counter,"次\r\n總共只有3次\r\n確定要進行Fuse燒錄嗎？"}
    local r = MessageBox.Show(table.concat(message), "提示", "YesNo", "Question")
    if r == "Yes" then
    	ctx:WriteI2CByteIndex(addr, 0xfd, 0x72)
    	ctx:WriteI2CByteIndex(addr, 0xff, 0x80)
    	delay(20)
    	ctx:WriteI2CByteIndex(addr, 0xfd, 0x72)
    	ctx:ReadI2C()
    else
    	msgbox("Fuse燒錄取消","提示")
    end
  end,
  
  -- 組合操作範例：先讀取，再寫入燒錄指令，最後再讀取
  Reset = function(ctx, deviceAddress)
    -- 讀取暫存器
    
    local addr = deviceAddress or 0x5E
    
    ctx:WriteI2CByteIndex(addr, 0xfd, 0x72)
    
    ctx:WriteI2CByteIndex(addr, 0xff, 0x01)
    
    ctx:WriteI2CByteIndex(addr, 0xfd, 0x72)
    
    delay(20)
    
    ctx:ReadI2C()
    
  end
}