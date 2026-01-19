import { RuleResult, I2COperationRecord } from '@/types'

interface StatusBarProps {
  ruleResults: RuleResult[]
  selectedRuleResult?: RuleResult
  i2cOperationRecords: I2COperationRecord[]
  selectedI2COperationRecord?: I2COperationRecord
  statusMessage?: string
  statusMessageColor: string
  onRuleResultSelect: (rule: RuleResult) => void
  onI2CRecordSelect: (record: I2COperationRecord) => void
}

export function StatusBar({
  ruleResults,
  selectedRuleResult,
  i2cOperationRecords,
  selectedI2COperationRecord,
  statusMessage,
  statusMessageColor,
  onRuleResultSelect,
  onI2CRecordSelect
}: StatusBarProps) {
  return (
    <div className="h-8 bg-gray-200 border-t border-gray-300 flex">
      {/* 左邊欄：規則評估結果 */}
      <div className="flex-1 border-r border-gray-400 px-2 flex items-center">
        <select
          value={selectedRuleResult?.RuleName || ''}
          onChange={(e) => {
            const rule = ruleResults.find(r => r.RuleName === e.target.value)
            if (rule) onRuleResultSelect(rule)
          }}
          className={`w-full text-xs font-bold ${selectedRuleResult?.Result === false ? 'text-red-600' : 'text-blue-600'}`}
        >
          {ruleResults.map((rule) => (
            <option key={rule.RuleName} value={rule.RuleName}>
              {rule.RuleName}: {rule.Result ? 'PASS' : 'FAIL'}
            </option>
          ))}
        </select>
      </div>

      {/* 中間欄：I2C 操作記錄 */}
      <div className="flex-1 border-r border-gray-400 px-2 flex items-center">
        <select
          value={selectedI2COperationRecord ? i2cOperationRecords.indexOf(selectedI2COperationRecord) : ''}
          onChange={(e) => {
            const index = parseInt(e.target.value)
            if (!isNaN(index) && index >= 0) {
              onI2CRecordSelect(i2cOperationRecords[index])
            }
          }}
          className={`w-full text-xs font-bold ${selectedI2COperationRecord?.IsSuccess === false ? 'text-red-600' : 'text-blue-600'}`}
        >
          {i2cOperationRecords.map((record, index) => (
            <option key={index} value={index}>
              {record.OperationType}: {record.IsSuccess ? '成功' : '失敗'}
            </option>
          ))}
        </select>
      </div>

      {/* 右邊欄：一般狀態訊息 */}
      <div className="flex-1 px-2 flex items-center">
        {statusMessage && (
          <span className={`text-xs font-bold truncate ${statusMessageColor}`}>
            {statusMessage}
          </span>
        )}
      </div>
    </div>
  )
}