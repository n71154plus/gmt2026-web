import { BitSegment } from '@/types';

/**
 * BitSegment 的實現。
 */
export class BitSegmentImpl implements BitSegment {
  constructor(
    public byteIndex: number,
    public hi: number,
    public lo: number
  ) {}

  get width(): number {
    return this.hi - this.lo + 1;
  }

  normalize(): BitSegment {
    const hi = Math.max(this.hi, this.lo);
    const lo = Math.min(this.hi, this.lo);
    return new BitSegmentImpl(this.byteIndex, hi, lo);
  }

  /**
   * 從現有的位址和MSB/LSB創建BitSegment。
   */
  static fromAddrMsbLsb(addr: number, msb: number, lsb: number): BitSegment {
    return new BitSegmentImpl(addr, msb, lsb);
  }
}