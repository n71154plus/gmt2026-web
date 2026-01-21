import { EventEmitter } from 'events';

/**
 * 提供以「bit 為單位」操作既有 byte[] 陣列的工具類別（零拷貝、就地修改）。
 * 位序假設：每個位元組（byte）內採 LSB-first（bit0 = LSB，bit7 = MSB）。
 */
export class DataBits {
  private readonly _bytes: Uint8Array;
  private readonly _byteCollection: DataBitsByteCollection;
  private readonly _eventEmitter: EventEmitter;

  /**
   * 供 UI 綁定使用的位元組視圖（就地修改並觸發通知）。
   */
  public get bytes(): DataBitsByteCollection {
    return this._byteCollection;
  }

  /**
   * 建立以 backingBytes 為底層緩衝區的 DataBits 視圖（不複製資料）。
   */
  constructor(backingBytes: Uint8Array) {
    this._bytes = backingBytes;
    this._byteCollection = new DataBitsByteCollection(this);
    this._eventEmitter = new EventEmitter();
  }

  /**
   * 總位數（= _bytes.length * 8）。
   */
  get count(): number {
    return this._bytes.length << 3;
  }

  /**
   * 位元組數量。
   */
  get byteCount(): number {
    return this._bytes.length;
  }

  /**
   * 以全域 bit 索引讀/寫單一 bit（0 = 第一個位元組的 LSB）。
   */
  public bit(bitIndex: number): boolean {
    if ((bitIndex >>> 0) >= this.count) {
      throw new RangeError('Bit index out of range');
    }

    const byteIndex = bitIndex >> 3; // /8
    const bitInByte = bitIndex & 7;  // %8（LSB=0）
    return (this._bytes[byteIndex] & (1 << bitInByte)) !== 0;
  }

  public setBit(bitIndex: number, value: boolean): void {
    if ((bitIndex >>> 0) >= this.count) {
      throw new RangeError('Bit index out of range');
    }

    const byteIndex = bitIndex >> 3;
    const bitInByte = bitIndex & 7;
    const mask = 1 << bitInByte;

    const cell = this._bytes[byteIndex];
    const updated = value ? (cell | mask) : (cell & ~mask);

    if (cell !== updated) {
      this._bytes[byteIndex] = updated;
      this.notifyByteChanged(byteIndex);
    }
  }

  /**
   * 以全域 bit 範圍讀/寫（含端點），回傳/寫入至 number 的低位（最多 32 bit）。
   */
  public bits(hi: number, lo: number): number;
  public bits(hi: number, lo: number, value: number): void;
  public bits(hi: number, lo: number, value?: number): number | void {
    const norm = this.normalize(hi, lo);
    hi = norm.hi;
    lo = norm.lo;
    const width = hi - lo + 1;

    if (width > 32) {
      throw new RangeError('Bit width cannot exceed 32');
    }

    if (value !== undefined) {
      this.writeBits(lo, width, value);
    } else {
      return this.readBits(lo, width);
    }
  }

  /**
   * 以「指定位元組」內的 bit 範圍讀/寫。
   */
  public byteBits(byteIndex: number, hi: number, lo: number): number;
  public byteBits(byteIndex: number, hi: number, lo: number, value: number): void;
  public byteBits(byteIndex: number, hi: number, lo: number, value?: number): number | void {
    this.checkByteIndex(byteIndex);
    const norm = this.normalize(hi, lo);
    hi = norm.hi;
    lo = norm.lo;
    this.checkBitInByte(hi);
    this.checkBitInByte(lo);

    // 將「此位元組內位移」轉成「全域 bit 位移」
    const bitOffset = (byteIndex << 3) + lo;
    const bitCount = hi - lo + 1;

    if (value !== undefined) {
      this.writeBitsFast(bitOffset, bitCount, value);
    } else {
      return this.readBitsFast(bitOffset, bitCount);
    }
  }

  /**
   * 以兩段位元組的 bit 範圍串接讀/寫。
   */
  public twoSegmentBits(b0: number, hi0: number, lo0: number, b1: number, hi1: number, lo1: number): number;
  public twoSegmentBits(b0: number, hi0: number, lo0: number, b1: number, hi1: number, lo1: number, value: number): void;
  public twoSegmentBits(b0: number, hi0: number, lo0: number, b1: number, hi1: number, lo1: number, value?: number): number | void {
    this.checkByteIndex(b0);
    this.checkByteIndex(b1);

    const n0 = this.normalize(hi0, lo0);
    hi0 = n0.hi; lo0 = n0.lo;
    const n1 = this.normalize(hi1, lo1);
    hi1 = n1.hi; lo1 = n1.lo;

    this.checkBitInByte(hi0); this.checkBitInByte(lo0);
    this.checkBitInByte(hi1); this.checkBitInByte(lo1);

    const w0 = hi0 - lo0 + 1; // 第一段寬度
    const w1 = hi1 - lo1 + 1; // 第二段寬度

    if (w0 + w1 > 32) {
      throw new RangeError('Total bit width cannot exceed 32');
    }

    if (value !== undefined) {
      const mask1 = w1 === 32 ? 0xFFFF_FFFF : ((1 << w1) - 1);

      // 低位段（w1）→ 第二段；高位段（w0）→ 第一段
      const seg1 = value & mask1;
      const seg0 = (value >> w1) & ((1 << w0) - 1);

      this.writeBitsFast((b0 << 3) + lo0, w0, seg0);
      this.writeBitsFast((b1 << 3) + lo1, w1, seg1);
    } else {
      const seg0 = this.readBitsFast((b0 << 3) + lo0, w0); // 高位段
      const seg1 = this.readBitsFast((b1 << 3) + lo1, w1); // 低位段

      return (seg0 << w1) | seg1;
    }
  }

  /**
   * 取得指定索引的位元組值。
   */
  public getByte(index: number): number {
    this.checkByteIndex(index);
    return this._bytes[index];
  }

  /**
   * 設定指定索引的位元組值，並在變更時觸發通知。
   */
  public setByte(index: number, value: number): void {
    this.checkByteIndex(index);
    const byteValue = value & 0xFF;

    if (this._bytes[index] !== byteValue) {
      this._bytes[index] = byteValue;
      this.notifyByteChanged(index);
    }
  }

  /**
   * 取得底層的位元組陣列（不複製）。
   */
  public getBackingBytes(): Uint8Array {
    return this._bytes;
  }

  /**
   * 訂閱位元組變更事件。
   */
  public onByteChanged(callback: (index: number) => void): () => void {
    this._eventEmitter.on('byteChanged', callback);
    return () => this._eventEmitter.off('byteChanged', callback);
  }

  /**
   * 發出指定位元組變更的通知。
   */
  private notifyByteChanged(index: number): void {
    this._eventEmitter.emit('byteChanged', index);
  }

  // 私有輔助方法

  private normalize(a: number, b: number): { hi: number; lo: number } {
    return a >= b ? { hi: a, lo: b } : { hi: b, lo: a };
  }

  private checkBitInByte(b: number): void {
    if ((b >>> 0) > 7) {
      throw new RangeError('Bit in byte must be between 0..7');
    }
  }

  private checkByteIndex(i: number): void {
    if ((i >>> 0) >= this._bytes.length) {
      throw new RangeError('Byte index out of range');
    }
  }

  private readBits(hi: number, lo: number): number {
    const norm = this.normalize(hi, lo);
    hi = norm.hi; lo = norm.lo;
    const width = hi - lo + 1;

    if (width > 32) {
      throw new RangeError('Bit width cannot exceed 32');
    }

    if (hi >= this.count || lo < 0) {
      throw new RangeError('Bit range out of bounds');
    }

    return this.readBitsFast(lo, width);
  }

  private writeBits(hi: number, lo: number, value: number): void {
    const norm = this.normalize(hi, lo);
    hi = norm.hi; lo = norm.lo;
    const width = hi - lo + 1;

    if (width > 32) {
      throw new RangeError('Bit width cannot exceed 32');
    }

    if (hi >= this.count || lo < 0) {
      throw new RangeError('Bit range out of bounds');
    }

    this.writeBitsFast(lo, width, value);
  }

  private readBitsFast(bitOffset: number, bitCount: number): number {
    const lastBit = bitOffset + bitCount - 1;
    if (bitOffset < 0 || bitCount < 1 || bitCount > 32 || lastBit >= this.count) {
      throw new RangeError('Invalid bit range');
    }

    const byteIndex = bitOffset >> 3;  // 起始位元組
    const shift = bitOffset & 7;       // 位元組內位移（0..7）

    // 檢查是否只需要單一位元組的部分位元
    const endByte = (lastBit >> 3);
    if (byteIndex === endByte && shift + bitCount <= 8) {
      // 單一位元組操作，直接讀取該位元組
      const byteValue = this._bytes[byteIndex];
      const mask = bitCount === 32 ? 0xFFFF_FFFF : ((1 << bitCount) - 1);
      return (byteValue >>> shift) & mask;
    }

    // 複雜情況：跨越位元組邊界，需要使用視窗方法
    let chunk = 0;
    const avail = Math.min(5, this._bytes.length - byteIndex);
    for (let i = 0; i < avail; i++) {
      chunk |= this._bytes[byteIndex + i] << (8 * i);
    }

    const mask = bitCount === 32 ? 0xFFFF_FFFF : ((1 << bitCount) - 1);
    return (chunk >>> shift) & mask;
  }

  private writeBitsFast(bitOffset: number, bitCount: number, value: number): void {
    const lastBit = bitOffset + bitCount - 1;
    if (bitOffset < 0 || bitCount < 1 || bitCount > 32 || lastBit >= this.count) {
      throw new RangeError('Invalid bit range');
    }

    const byteIndex = bitOffset >> 3;
    const shift = bitOffset & 7;

    const mask = bitCount === 32 ? 0xFFFF_FFFF : ((1 << bitCount) - 1);

    // 計算受影響的位元組範圍
    const startByte = byteIndex;
    const endByte = (lastBit >> 3);
    const affectedBytes = endByte - startByte + 1;

    // 對於簡單的情況（不跨越位元組邊界），直接操作單一位元組
    if (affectedBytes === 1 && shift + bitCount <= 8) {
      const byteMask = mask << shift;
      const currentByte = this._bytes[byteIndex];
      const updatedByte = (currentByte & ~byteMask) | ((value & mask) << shift);

      if (currentByte !== updatedByte) {
        this._bytes[byteIndex] = updatedByte;
        this.notifyByteChanged(byteIndex);
      }
      return;
    }

    // 複雜情況：跨越位元組邊界，需要使用視窗方法
    let chunk = 0;
    const windowSize = Math.min(5, this._bytes.length - byteIndex);
    for (let i = 0; i < windowSize; i++) {
      chunk |= this._bytes[byteIndex + i] << (8 * i);
    }

    // Read-Modify-Write：先清掉目標區，再寫入新值（對齊 shift）
    chunk &= ~(mask << shift);
    chunk |= (value & mask) << shift;

    // 只寫回實際受影響的位元組
    for (let i = 0; i < affectedBytes && i < windowSize; i++) {
      const targetIndex = byteIndex + i;
      const updated = (chunk >> (8 * i)) & 0xFF;
      if (this._bytes[targetIndex] !== updated) {
        this._bytes[targetIndex] = updated;
        this.notifyByteChanged(targetIndex);
      }
    }
  }
}

/**
 * 提供將 DataBits 視為可綁定位元組集合的包裝類別。
 */
export class DataBitsByteCollection {
  constructor(private owner: DataBits) {}

  /**
   * 取得位元組數量。
   */
  get count(): number {
    return this.owner.byteCount;
  }

  /**
   * 以索引存取位元組。
   */
  public get(index: number): number {
    return this.owner.getByte(index);
  }

  public set(index: number, value: number): void {
    this.owner.setByte(index, value);
  }

  /**
   * 取得所有位元組的陣列複本。
   */
  public toArray(): number[] {
    return Array.from(this.owner.getBackingBytes());
  }

  /**
   * 迭代器。
   */
  public [Symbol.iterator](): Iterator<number> {
    let index = 0;
    const backing = this.owner.getBackingBytes();

    return {
      next: (): IteratorResult<number> => {
        if (index < this.owner.byteCount) {
          return { value: backing[index++], done: false };
        } else {
          return { done: true, value: undefined as any };
        }
      }
    };
  }
}