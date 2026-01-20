// 產品相關類型
export interface Product {
  Name: string;
  Type: string;
  Application: string;
  Package: string;
  Description: string;
  RegisterTable: RegisterTable[];
}

// 暫存器表類型
export interface RegisterTable {
  Name: string;
  DeviceAddress: number[];
  Registers: Register[];
  ChecksumMemIndexCollect: { [key: string]: number[] };
  NeedShowMemIndex: number[];
}

// 暫存器類型
export interface Register {
  Name: string;
  Group: string;
  Addr: number;
  MSB: number;
  LSB: number;
  DACValueExpr: string;
  DAC: number;
  DACValues?: string[];
  ValuesCount?: number;
  Unit?: string;
  ReadOnly?: boolean;
  IsTextBlock?: boolean;
  IsCheckBox?: boolean;
}

// I2C操作記錄
export interface I2COperationRecord {
  Timestamp: Date;
  OperationType: string;
  OperationSubType?: string;
  DeviceAddress: number;
  Data: { [key: number]: number | null };
  IsSuccess: boolean;
  ErrorMessage?: string;
  ShortErrorMessage?: string;
  IsFromLua?: boolean;
  LuaFunctionName?: string;
}

// 規則結果
export interface RuleResult {
  RuleName: string;
  Description: string;
  Result: boolean;
}

// 圖表數據
export interface DiagramResult {
  Id: string;
  Title: string;
  Data: any;
}

// HEX操作
export interface HexOperation {
  GroupName: string;
  SaveCommand: () => Promise<void>;
  LoadCommand: () => Promise<void>;
}

// 產品文件信息
export interface ProductFileInfo {
  Product: Product;
  FileName: string;
}

// 地址入口
export interface AddressEntry {
  RegisterTableName: string;
  Value: number;
}

// 應用程式狀態
export interface AppState {
  title: string;
  modelName: string;
  selectedProduct?: ProductFileInfo;
  selectedAddress?: number;
  selectedRegisterTable?: RegisterTableViewModel;
  registerTables: RegisterTableViewModel[];
  deviceAddressesView: AddressEntry[];
  availableProducts: ProductFileInfo[];
  i2cOperationRecords: I2COperationRecord[];
  selectedI2COperationRecord?: I2COperationRecord;
  ruleResults: RuleResult[];
  selectedRuleResult?: RuleResult;
  statusMessage?: string;
  statusMessageColor: string;
  hasStatusMessage: boolean;
  isI2cBusy: boolean;
  i2cErrorMessage?: string;
  hasI2CErrorMessage: boolean;
  luaErrorMessage?: string;
  hasLuaErrorMessage: boolean;
}

// 暫存器表視圖模型
export interface RegisterTableViewModel {
  Name: string;
  DeviceAddress: number[];
  Registers: RegisterViewModel[];
  Data: RegisterData[];
  Pages: string[];
  SelectedPage: string;
  ViewMode: 'GroupView' | 'AddressSort';
  FilterText: string;
  RegistersView: RegisterViewModel[];
  CheckSumCollection: { [key: string]: ChecksumInfo };
  NeedShowMemIndex: number[];
}

// 暫存器視圖模型
export interface RegisterViewModel {
  Name: string;
  Group: string;
  Addr: number;
  MSB: number;
  LSB: number;
  DACValueExpr: string;
  DAC: number;
  DACValues?: (string | number)[];
  ValuesCount?: number;
  Unit?: string;
  ReadOnly?: boolean;
  IsTextBlock?: boolean;
  CurrentValue?: any;
  IsCheckBox: boolean;
  AddressColorIndex: number;
  DependentParameters?: string[]; // 依賴的參數名稱列表
}

// 暫存器數據
export interface RegisterData {
  Address: number;
  Bytes: number[];
}

// 校驗和信息
export interface ChecksumInfo {
  Value: number;
  ExpectedValue?: number;
}