import { RegisterViewModel } from './registerViewModel';
import { Register } from './index';

/**
 * 具體的 RegisterViewModel 實現。
 * 根據 Register 的屬性決定呈現類型。
 */
export class ConcreteRegisterViewModel extends RegisterViewModel {
  constructor(
    register: Register,
    dataBits: import('@/lib/dataBits').DataBits,
    dataMutated?: (vm: RegisterViewModel) => void
  ) {
    super(register, dataBits, dataMutated);
  }
}