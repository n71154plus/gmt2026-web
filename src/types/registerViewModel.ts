import { Register, RealValue } from './index';
import { BitSegmentImpl } from '@/lib/bitSegment';

// 重新導出 BitSegment 類型
export type BitSegment = BitSegmentImpl;
import { DataBits } from '@/lib/dataBits';

/**
 * 位元段結構，描述位址和位元範圍。
 */

/**
 * 代表單一暫存器（抽象基底）。
 * 具體呈現交由子型別決定。
 */
export abstract class RegisterViewModel {
  protected readonly register: Register;

  // 公開 register 屬性供內部使用
  public get rawRegister(): Register {
    return this.register;
  }
  protected dataBits: DataBits;
  protected readonly dataMutated?: (vm: RegisterViewModel) => void;
  protected cachedDacValue: number;
  protected readonly byteIndices: readonly number[];
  // 追蹤是否已經設置過 DefaultDAC，避免重複設置
  private hasSetDefaultDac: boolean = false;

  constructor(
    register: Register,
    dataBits: DataBits,
    dataMutated?: (vm: RegisterViewModel) => void
  ) {
    this.register = register;
    this.dataBits = dataBits;
    this.dataMutated = dataMutated;

    // 初始化 cachedDacValue
    if (register.DefaultDAC !== undefined && register.DefaultDAC >= 0) {
      // 如果 Register 定義了有效的 DefaultDAC，使用它
      this.cachedDacValue = register.DefaultDAC;
    } else if (dataBits) {
      // 否則從資料位元讀取當前值
      this.cachedDacValue = this.readValue();
    } else {
      // 如果沒有dataBits且沒有DefaultDAC，設置為0
      this.cachedDacValue = 0;
    }

    this.byteIndices = this.buildByteIndices(register);
  }

  // 屬性

  get name(): string {
    return this.register.Name;
  }

  get isCheckBox(): boolean {
    return this.register.IsCheckBox === true;
  }

  get isReadOnly(): boolean {
    return this.register.ReadOnly === true;
  }

  get displayValue(): string | null {
    return this.tryGetCurrentValue() ?? null;
  }

  get unit(): string | undefined {
    return this.register.Unit;
  }

  get group(): string {
    return this.register.Group || 'Main';
  }

  get page(): string {
    return this.register.Page || 'Main';
  }

  get byteIndicesList(): readonly number[] {
    return this.byteIndices;
  }

  get memI_B0Addr(): number {
    return this.register.MemI_B0?.byteIndex ?? Number.MAX_SAFE_INTEGER;
  }

  get memI_B1Addr(): number {
    return this.register.MemI_B1?.byteIndex ?? Number.MAX_SAFE_INTEGER;
  }

  get addressColorIndex(): number {
    return this.memI_B0Addr === Number.MAX_SAFE_INTEGER ? 0 : this.memI_B0Addr;
  }

  get addressBitRange(): string {
    const parts: string[] = [];

    if (this.register.MemI_B0) {
      const normalized = this.register.MemI_B0.normalize();
      const bitRange = normalized.hi === normalized.lo
        ? normalized.hi.toString().padStart(2)
        : `${normalized.hi}..${normalized.lo}`;
      parts.push(`Addr${normalized.byteIndex.toString().padStart(2, '0')}[${bitRange.padStart(5)}]`);
    }

    if (this.register.MemI_B1) {
      const normalized = this.register.MemI_B1.normalize();
      const bitRange = normalized.hi === normalized.lo
        ? normalized.hi.toString().padStart(2)
        : `${normalized.hi}..${normalized.lo}`;
      parts.push(`Addr${normalized.byteIndex.toString().padStart(2, '0')}[${bitRange.padStart(5)}]`);
    }

    return parts.join(', ');
  }

  get dacValues(): RealValue[] | undefined {
    return this.register.DACValues;
  }

  get dac(): number {
    // 總是從資料位元讀取（如果有的話），否則返回快取值
    if (this.dataBits) {
      return this.readValue();
    }
    return this.cachedDacValue;
  }

  set dac(value: number) {
    // 如果值為 -1，只更新快取，不寫入資料位元
    if (value < 0) {
      const currentDac = this.dac;
      if (currentDac === value) return;

      this.cachedDacValue = value;
      // 這裡應該觸發屬性變更通知，但由於是React環境，這由狀態管理處理
      return;
    }

    // 正常情況：將 number 轉換為 uint 並寫入資料位元
    if (this.register.ReadOnly) {
      console.log(`[dac setter] ${this.register.Name} is ReadOnly, ignoring write`);
      return;
    }

    const normalized = this.normalize(value);
    const current = this.readValue();
    if (current === normalized) {
      console.log(`[dac setter] ${this.register.Name}: value ${value} (normalized: ${normalized}) equals current ${current}, skipping write`);
      return;
    }

    this.writeValue(normalized);
    this.cachedDacValue = normalized;
    this.dataMutated?.(this);
  }

  // 方法

  refreshFromData(): void {
    if (!this.dataBits) return;

    const before = this.cachedDacValue;
    const currentUint = this.readValue();
    const current = this.cachedDacValue < 0 ? this.cachedDacValue : currentUint;

    // console.log(`[refreshFromData] ${this.register.Name}: before=${before}, current=${current}`);

    if (current !== before) {
      this.cachedDacValue = current;
      // console.log(`[refreshFromData] ${this.register.Name}: updated cached value to ${current}`);
      // 屬性變更通知由React狀態管理處理
    }
  }

  rebindDataBits(newDataBits: DataBits): void {
    const hadDataBits = this.dataBits != null;
    this.dataBits = newDataBits;

    console.log(`[rebindDataBits] ${this.register.Name}: hadDataBits=${hadDataBits}, hasSetDefaultDac=${this.hasSetDefaultDac}, cachedDacValue=${this.cachedDacValue}`);

    // 如果之前沒有dataBits，需要將緩存的值寫入dataBits
    if (!hadDataBits) {
      const normalizedValue = this.normalize(this.cachedDacValue);
      console.log(`[rebindDataBits] Writing cached value for ${this.register.Name}: ${this.cachedDacValue} -> ${normalizedValue}`);
      this.writeValue(normalizedValue);
      this.hasSetDefaultDac = true;
    } else {
      // 如果已經有dataBits，同步當前值
      const currentValue = this.readValue();
      console.log(`[rebindDataBits] Syncing value for ${this.register.Name}: ${currentValue}`);
      this.cachedDacValue = currentValue;
    }
  }

  recalculateDACValues(parameters?: Record<string, any>): void {
    if (parameters && this.register.DACValueExpr) {
      // 先記錄當前的 DAC 值（選取索引）
      const currentDac = this.dac;

      // 重算 DACValues - 這裡實現類似GMT2026的邏輯
      const newDACValues = this.calculateDACValues(this.register.DACValueExpr, parameters);
      this.register.DACValues = newDACValues;

      // 檢查新的列表大小
      const values = this.register.DACValues;
      const newCount = values?.length ?? 0;

      if (newCount > 0) {
        // 如果原來的索引還在範圍內，保持原選取
        // 如果超出範圍，夾到最後一個有效索引
        const targetDac = (currentDac >= 0 && currentDac < newCount) ? currentDac : (newCount - 1);
        const normalizedTarget = this.normalize(targetDac);

        // 檢查是否需要更新資料位元
        const currentValue = this.readValue();
        const needsUpdate = currentValue !== normalizedTarget;

        if (needsUpdate) {
          // 只有當值需要改變時才更新資料位元
          // 使用 setByte 而不是 writeValue，避免觸發額外的回調
          const byteIndex = this.register.Addr;
          if (this.dataBits) {
            this.dataBits.setByte(byteIndex, normalizedTarget);
          }
        }
        this.cachedDacValue = targetDac;
      }
    }
  }

  private calculateDACValues(dacValueExpr: string, parameters?: Record<string, any>): RealValue[] {
    const valuesCount = this.register.ValuesCount || Math.pow(2, this.getBitWidth());
    const results: RealValue[] = [];

    try {
      // 簡單的表達式求值實現
      for (let dac = 0; dac < valuesCount; dac++) {
        // 將 DAC 替換為當前值
        let expr = dacValueExpr.replace(/\bDAC\b/g, dac.toString());

        // 將參數替換
        if (parameters) {
          Object.entries(parameters).forEach(([key, value]) => {
            expr = expr.replace(new RegExp(`\\b${key}\\b`, 'g'), value?.toString() || '0');
          });
        }

        // 數學運算子轉換
        expr = expr
          .replace(/&&/g, ' && ')
          .replace(/\|\|/g, ' || ')
          .replace(/!=/g, ' !== ')
          .replace(/!/g, '!')
          // 數學函數
          .replace(/\bMin\(/g, 'Math.min(')
          .replace(/\bMax\(/g, 'Math.max(')
          .replace(/\bAbs\(/g, 'Math.abs(')
          .replace(/\bSqrt\(/g, 'Math.sqrt(')
          .replace(/\bPow\(/g, 'Math.pow(')

        // 簡單的數學表達式求值（這裡簡化實現，實際應該使用更強大的求值器）
        try {
          // 使用 Function 構造函數來求值（注意：這在生產環境中可能有安全風險）
          const result = new Function('return ' + expr)();
          results.push(typeof result === 'number' ? result : result?.toString() || '0');
        } catch {
          results.push('Error');
        }
      }
    } catch {
      // 如果計算失敗，返回簡單的數值序列
      for (let dac = 0; dac < valuesCount; dac++) {
        results.push(dac);
      }
    }
    return results;
  }

  protected tryGetCurrentValue(): any {
    const values = this.register.DACValues;
    const index = this.dac;
    if (!values || index < 0 || index >= values.length) {
      return null;
    }

    const realValue = values[index];
    // RealValue 的實現需要根據實際類型調整
    return realValue;
  }

  // 私有方法

  private buildByteIndices(register: Register): readonly number[] {
    const indices = new Set<number>();

    if (register.MemI_B0) {
      indices.add(register.MemI_B0.normalize().byteIndex);
    }

    if (register.MemI_B1) {
      indices.add(register.MemI_B1.normalize().byteIndex);
    }

    if (indices.size === 0) {
      return [];
    }

    return Array.from(indices).sort((a, b) => a - b);
  }

  private readValue(): number {
    const segments = this.tryGetSegments();
    if (segments.primary && this.segmentInRange(segments.primary)) {
      const value = segments.secondary && this.segmentInRange(segments.secondary)
        ? this.dataBits.twoSegmentBits(
            segments.primary.byteIndex, segments.primary.hi, segments.primary.lo,
            segments.secondary.byteIndex, segments.secondary.hi, segments.secondary.lo
          )
        : this.dataBits.byteBits(segments.primary.byteIndex, segments.primary.hi, segments.primary.lo);

      this.cachedDacValue = value;
      return value;
    }

    const fallback = this.cachedDacValue < 0 ? 0 : this.normalize(this.cachedDacValue);
    this.cachedDacValue = fallback;
    return fallback;
  }

  private writeValue(value: number): void {
    console.log(`[writeValue] ${this.register.Name}: writing value ${value} to dataBits`);
    const segments = this.tryGetSegments();
    if (segments.primary && this.segmentInRange(segments.primary)) {
      if (segments.secondary && this.segmentInRange(segments.secondary)) {
        this.dataBits.twoSegmentBits(
          segments.primary.byteIndex, segments.primary.hi, segments.primary.lo,
          segments.secondary.byteIndex, segments.secondary.hi, segments.secondary.lo,
          value
        );
      } else {
        this.dataBits.byteBits(segments.primary.byteIndex, segments.primary.hi, segments.primary.lo, value);
      }
    }
    this.cachedDacValue = value;
  }

  private normalize(value: number): number {
    const bitWidth = this.getBitWidth();
    if (bitWidth <= 0 || bitWidth >= 32) return value;
    const mask = (1 << bitWidth) - 1;
    return value & mask;
  }

  private getBitWidth(): number {
    const segments = this.tryGetSegments();
    if (segments.primary) {
      let width = segments.primary.width;
      if (segments.secondary) width += segments.secondary.width;
      return width;
    }
    return (this.register.BitLength && this.register.BitLength > 0) ? this.register.BitLength : 0;
  }

  private tryGetSegments(): { primary?: BitSegment; secondary?: BitSegment } {
    if (this.register.MemI_B0) {
      const primary = this.register.MemI_B0.normalize();
      if (this.register.MemI_B1) {
        const secondary = this.register.MemI_B1.normalize();
        return { primary, secondary };
      }
      return { primary };
    }
    return {};
  }

  private segmentInRange(segment: BitSegment): boolean {
    const byteCount = this.dataBits.byteCount;
    return segment.byteIndex >= 0 && segment.byteIndex < byteCount;
  }
}