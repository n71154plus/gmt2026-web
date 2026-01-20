'use client'

import { RuleResult } from '@/types'

interface RuleResultPanelProps {
  ruleResults: RuleResult[]
  selectedRuleResult?: RuleResult
  onSelectRule: (rule: RuleResult) => void
}

export function RuleResultPanel({
  ruleResults,
  selectedRuleResult,
  onSelectRule
}: RuleResultPanelProps) {
  if (ruleResults.length === 0) {
    return null
  }

  // 總結規則（第一項）
  const allOkRule = ruleResults[0]
  const otherRules = ruleResults.slice(1)

  return (
    <div className="bg-white border border-gray-200 rounded-lg shadow-sm">
      {/* 標題 */}
      <div className="px-3 py-2 border-b border-gray-200 bg-gray-50">
        <h3 className="text-sm font-medium text-gray-700">Design Rule Check</h3>
      </div>

      {/* 總結規則 */}
      {allOkRule && (
        <div
          className={`px-3 py-2 cursor-pointer ${
            allOkRule.Result
              ? 'bg-green-50 hover:bg-green-100'
              : 'bg-red-50 hover:bg-red-100'
          }`}
          onClick={() => onSelectRule(allOkRule)}
        >
          <div className="flex items-center">
            <span
              className={`w-3 h-3 rounded-full mr-2 ${
                allOkRule.Result ? 'bg-green-500' : 'bg-red-500'
              }`}
            />
            <span
              className={`text-sm font-medium ${
                allOkRule.Result ? 'text-green-700' : 'text-red-700'
              }`}
            >
              {allOkRule.Result ? 'All Design Rule Check OK' : 'Design Rule Check NG'}
            </span>
          </div>
        </div>
      )}

      {/* 其他規則列表 */}
      {otherRules.length > 0 && (
        <div className="max-h-48 overflow-y-auto">
          {otherRules.map((rule, index) => (
            <div
              key={rule.RuleName}
              className={`px-3 py-1.5 cursor-pointer border-t border-gray-100 hover:bg-gray-50 ${
                selectedRuleResult?.RuleName === rule.RuleName ? 'bg-blue-50' : ''
              }`}
              onClick={() => onSelectRule(rule)}
            >
              <div className="flex items-center justify-between">
                <span className="text-sm text-gray-700">{rule.RuleName}</span>
                <span
                  className={`w-2.5 h-2.5 rounded-full ${
                    rule.Result ? 'bg-green-400' : 'bg-red-400'
                  }`}
                  title={rule.Description || '無描述'}
                />
              </div>
              {rule.Description && (
                <p className="text-xs text-gray-500 mt-0.5 truncate">
                  {rule.Description}
                </p>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
