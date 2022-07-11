//
//  YXStockDetailFinancialListModel.swift
//  uSmartOversea
//
//  Created by youxin on 2019/10/14.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit

//MARK:利润/损益表
struct YXStockDetailFinancialListProfitModel: Codable {
    let list: YXStockDetailFinancialListProfitInfo?
    let yoy: YXStockDetailFinancialProfitYOYInfo? //yoy2, yoy3, yoy5
}


struct YXStockDetailFinancialListProfitInfo: Codable {
    let symbol, secuCode: String?
    let calendarYear, calendarQuarter, fiscalYear, fiscalQuarter: Int?
    let periodTypeID: Int?
    let periodTypeName: String?
    let revenues, otherRevenuesTotal, totalRevenues, costOfRevenues, ebitda, ebitdaMargin: Double?
    let grossProfit, grossMargin, saaExpenses, radExpenses, daaTotal: Double?
    let ooe, ooeTotal, totalOperatingExpenses, operatingIncome, roa, roe, eps: Double?
    let interestExpense, iaiIncome, netInterestExpenses, otherNonOeTotal: Double?
    let ebtExclUnusualItems, marExpenses, impairmentOfGoodwill, gainOrLossOnSOI: Double?
    let gainOrLossOnSOA, ouiTotal, totalUnusualItems, ebtInclUnusualItems: Double?
    let incomeTaxExpense, earningsFromCo, earningOfDo, eiAndAC: Double?
    let netIncomeToCompany, miInEarnings, netIncome, netIncomeMargin, pdAndOa: Double?
    let nitcInclExtraItems, nitcExclExtraItems: Double?
    let currUnit: String?
    let endDate, currName: String?

    enum CodingKeys: String, CodingKey {
        case symbol
        case secuCode = "secu_code"
        case calendarYear = "calendar_year"
        case calendarQuarter = "calendar_quarter"
        case fiscalYear = "fiscal_year"
        case fiscalQuarter = "fiscal_quarter"
        case periodTypeID = "period_type_id"
        case periodTypeName = "period_type_name"
        case revenues
        case otherRevenuesTotal = "other_revenues_total"
        case totalRevenues = "total_revenues"
        case costOfRevenues = "cost_of_revenues"
        case grossProfit = "gross_profit"
        case grossMargin = "gross_margin"
        case saaExpenses = "saa_expenses"
        case radExpenses = "rad_expenses"
        case daaTotal = "daa_total"
        case ooe, ebitda, roa, roe, eps
        case ebitdaMargin = "ebitda_margin"
        case ooeTotal = "ooe_total"
        case totalOperatingExpenses = "total_operating_expenses"
        case operatingIncome = "operating_income"
        case interestExpense = "interest_expense"
        case iaiIncome = "iai_income"
        case netInterestExpenses = "net_interest_expenses"
        case otherNonOeTotal = "other_non_oe_total"
        case ebtExclUnusualItems = "ebt_excl_unusual_items"
        case marExpenses = "mar_expenses"
        case impairmentOfGoodwill = "impairment_of_goodwill"
        case gainOrLossOnSOI = "gain_or_loss_on_soi"
        case gainOrLossOnSOA = "gain_or_loss_on_soa"
        case ouiTotal = "oui_total"
        case totalUnusualItems = "total_unusual_items"
        case ebtInclUnusualItems = "ebt_incl_unusual_items"
        case incomeTaxExpense = "income_tax_expense"
        case earningsFromCo = "earnings_from_co"
        case earningOfDo = "earning_of_do"
        case eiAndAC = "ei_and_ac"
        case netIncomeToCompany = "net_income_to_company"
        case miInEarnings = "mi_in_earnings"
        case netIncome = "net_income"
        case netIncomeMargin = "net_income_margin"
        case pdAndOa = "pd_and_oa"
        case nitcInclExtraItems = "nitc_incl_extra_items"
        case nitcExclExtraItems = "nitc_excl_extra_items"
        case currUnit = "curr_unit"
        case endDate = "end_date"
        case currName = "curr_name"
    }
}


struct YXStockDetailFinancialProfitYOYInfo: Codable {
    let revenuesYoy: Double?
    let otherRevenuesTotalYoy, totalRevenuesYoy, costOfRevenuesYoy, grossProfitYoy, grossMarginYoy: Double?
    let saaExpensesYoy, ebitdaYoy, ebitdaMarginYoy: Double?
    let radExpensesYoy, daaTotalYoy: Double?
    let ooeYoy, ooeTotalYoy, totalOperatingExpensesYoy, operatingIncomeYoy: Double?
    let interestExpenseYoy, iaiIncomeYoy, netInterestExpensesYoy, otherNonOeTotalYoy: Double?
    let ebtExclUnusualItemsYoy: Double?
    let marExpensesYoy, impairmentOfGoodwillYoy: Double?
    let gainOrLossOnSOIYoy, roaYoy, roeYoy, epsYoy: Double?
    let gainOrLossOnSOAYoy, ouiTotalYoy: Double?
    let totalUnusualItemsYoy, ebtInclUnusualItemsYoy, incomeTaxExpenseYoy, earningsFromCoYoy: Double?
    let earningOfDoYoy, eiAndACYoy: Double?
    let netIncomeToCompanyYoy, miInEarningsYoy, netIncomeYoy, netIncomeMarginYoy: Double?
    let pdAndOaYoy: Double?
    let nitcInclExtraItemsYoy, nitcExclExtraItemsYoy: Double?

    enum CodingKeys: String, CodingKey {
        case revenuesYoy = "revenues_yoy"
        case otherRevenuesTotalYoy = "other_revenues_total_yoy"
        case totalRevenuesYoy = "total_revenues_yoy"
        case costOfRevenuesYoy = "cost_of_revenues_yoy"
        case grossProfitYoy = "gross_profit_yoy"
        case grossMarginYoy = "gross_margin_yoy"
        case saaExpensesYoy = "saa_expenses_yoy"
        case radExpensesYoy = "rad_expenses_yoy"
        case daaTotalYoy = "daa_total_yoy"
        case ooeYoy = "ooe_yoy"
        case ooeTotalYoy = "ooe_total_yoy"
        case totalOperatingExpensesYoy = "total_operating_expenses_yoy"
        case operatingIncomeYoy = "operating_income_yoy"
        case interestExpenseYoy = "interest_expense_yoy"
        case iaiIncomeYoy = "iai_income_yoy"
        case netInterestExpensesYoy = "net_interest_expenses_yoy"
        case otherNonOeTotalYoy = "other_non_oe_total_yoy"
        case ebtExclUnusualItemsYoy = "ebt_excl_unusual_items_yoy"
        case marExpensesYoy = "mar_expenses_yoy"
        case impairmentOfGoodwillYoy = "impairment_of_goodwill_yoy"
        case gainOrLossOnSOIYoy = "gain_or_loss_on_soi_yoy"
        case gainOrLossOnSOAYoy = "gain_or_loss_on_soa_yoy"
        case ouiTotalYoy = "oui_total_yoy"
        case totalUnusualItemsYoy = "total_unusual_items_yoy"
        case ebtInclUnusualItemsYoy = "ebt_incl_unusual_items_yoy"
        case incomeTaxExpenseYoy = "income_tax_expense_yoy"
        case earningsFromCoYoy = "earnings_from_co_yoy"
        case earningOfDoYoy = "earning_of_do_yoy"
        case eiAndACYoy = "ei_and_ac_yoy"
        case netIncomeToCompanyYoy = "net_income_to_company_yoy"
        case miInEarningsYoy = "mi_in_earnings_yoy"
        case netIncomeYoy = "net_income_yoy"
        case netIncomeMarginYoy = "net_income_margin_yoy"
        case pdAndOaYoy = "pd_and_oa_yoy"
        case nitcInclExtraItemsYoy = "nitc_incl_extra_items_yoy"
        case nitcExclExtraItemsYoy = "nitc_excl_extra_items_yoy"
        case ebitdaYoy = "ebitda_yoy"
        case ebitdaMarginYoy = "ebitda_margin_yoy"
        case roaYoy = "roa_yoy"
        case roeYoy = "roe_yoy"
        case epsYoy = "eps_yoy"
    
    }
}

// MARK: 资产负债表
struct YXStockDetailFinancialListAssetModel: Codable {
    let list: YXStockDetailFinancialListAssetInfo?
    let yoy: YXStockDetailFinancialAssetYOYInfo? //yoy2, yoy3, yoy5
}

struct YXStockDetailFinancialListAssetInfo: Codable {
    let symbol, secuCode: String?
    let calendarYear, calendarQuarter, fiscalYear, fiscalQuarter: Int?
    let periodTypeID: Int?
    let periodTypeName: String?
    let cashAndEqu, shortTermInvest, tradeingAssetSecu, cashAndShortInvest: Double?
    let accountsReceivable, otherReceivable, notesReceivable, totalReceivalble: Double?
    let inventory, prepaidExpenses, fdLoansAndLeasesCurrent, fdOtherCurrentAssets: Double?
    let otherCurrentAssetsTotal, totalCurrentAssets, grossPpe, accumulatedDepreciation: Double?
    let netPpe, longTermInvestments, goodwill, otherIntangibles: Double?
    let fdLoansAndLeasesLongTerm, fdOtherLongTermAssets, otherAssetsTotal, totalAssets: Double?
    let accountsPayable, accruedExpenses, shortTermBorrowings, longTermDebtOrCapitalLeases: Double?
    let fdDebtCurrent, fdOtherCurrentLiabilies, otherCurrentLiabilitiesTotal, totalCurrentLiabilities: Double?
    let longTermDebt, capitalLeases, fdDebtNonCurrent, fdOtherNonCurrentLiabilities: Double?
    let otherLiabilitiesTotal, totalLiabilities, preferredStockOthers, totalPreferredEquity: Double?
    let commonStockAPIC, retainedEarnings, treasuryStockOther, totalCommonEquity: Double?
    let minorityInterest, totalEquity, totalLiabilitiesAndEquity: Double?
    let currUnit: Int?
    let endDate, currName: String?
    let currentRatio, totalLiabilitiesRatio: Double?

    enum CodingKeys: String, CodingKey {
        case symbol
        case secuCode = "secu_code"
        case calendarYear = "calendar_year"
        case calendarQuarter = "calendar_quarter"
        case fiscalYear = "fiscal_year"
        case fiscalQuarter = "fiscal_quarter"
        case periodTypeID = "period_type_id"
        case periodTypeName = "period_type_name"
        case cashAndEqu = "cash_and_equ"
        case shortTermInvest = "short_term_invest"
        case tradeingAssetSecu = "tradeing_asset_secu"
        case cashAndShortInvest = "cash_and_short_invest"
        case accountsReceivable = "accounts_receivable"
        case otherReceivable = "other_receivable"
        case notesReceivable = "notes_receivable"
        case totalReceivalble = "total_receivalble"
        case inventory
        case prepaidExpenses = "prepaid_expenses"
        case fdLoansAndLeasesCurrent = "fd_loans_and_leases_current"
        case fdOtherCurrentAssets = "fd_other_current_assets"
        case otherCurrentAssetsTotal = "other_current_assets_total"
        case totalCurrentAssets = "total_current_assets"
        case grossPpe = "gross_ppe"
        case accumulatedDepreciation = "accumulated_depreciation"
        case netPpe = "net_ppe"
        case longTermInvestments = "long_term_investments"
        case goodwill
        case otherIntangibles = "other_intangibles"
        case fdLoansAndLeasesLongTerm = "fd_loans_and_leases_long_term"
        case fdOtherLongTermAssets = "fd_other_long_term_assets"
        case otherAssetsTotal = "other_assets_total"
        case totalAssets = "total_assets"
        case accountsPayable = "accounts_payable"
        case accruedExpenses = "accrued_expenses"
        case shortTermBorrowings = "short_term_borrowings"
        case longTermDebtOrCapitalLeases = "long_term_debt_or_capital_leases"
        case fdDebtCurrent = "fd_debt_current"
        case fdOtherCurrentLiabilies = "fd_other_current_liabilies"
        case otherCurrentLiabilitiesTotal = "other_current_liabilities_total"
        case totalCurrentLiabilities = "total_current_liabilities"
        case longTermDebt = "long_term_debt"
        case capitalLeases = "capital_leases"
        case fdDebtNonCurrent = "fd_debt_non_current"
        case fdOtherNonCurrentLiabilities = "fd_other_non_current_liabilities"
        case otherLiabilitiesTotal = "other_liabilities_total"
        case totalLiabilities = "total_liabilities"
        case preferredStockOthers = "preferred_stock_others"
        case totalPreferredEquity = "total_preferred_equity"
        case commonStockAPIC = "common_stock_apic"
        case retainedEarnings = "retained_earnings"
        case treasuryStockOther = "treasury_stock_other"
        case totalCommonEquity = "total_common_equity"
        case minorityInterest = "minority_interest"
        case totalEquity = "total_equity"
        case totalLiabilitiesAndEquity = "total_liabilities_and_equity"
        case currUnit = "curr_unit"
        case endDate = "end_date"
        case currentRatio = "current_ratio"
        case totalLiabilitiesRatio = "total_liabilities_ratio"
        case currName = "curr_name"
    }
}

struct YXStockDetailFinancialAssetYOYInfo: Codable {
    let cashAndEquYoy: Double?
    let shortTermInvestYoy: Double?
    let tradeingAssetSecuYoy: Double?
    let cashAndShortInvestYoy, accountsReceivableYoy: Double?
    let otherReceivableYoy, notesReceivableYoy: Double?
    let totalReceivalbleYoy, inventoryYoy: Double?
    let prepaidExpensesYoy, fdLoansAndLeasesCurrentYoy, fdOtherCurrentAssetsYoy: Double?
    let otherCurrentAssetsTotalYoy, totalCurrentAssetsYoy: Double?
    let grossPpeYoy, accumulatedDepreciationYoy: Double?
    let netPpeYoy, longTermInvestmentsYoy: Double?
    let goodwillYoy: Double?
    let otherIntangiblesYoy: Double?
    let fdLoansAndLeasesLongTermYoy, fdOtherLongTermAssetsYoy: Double?
    let otherAssetsTotalYoy, totalAssetsYoy, accountsPayableYoy, accruedExpensesYoy: Double?
    let shortTermBorrowingsYoy, longTermDebtOrCapitalLeasesYoy: Double?
    let fdDebtCurrentYoy, fdOtherCurrentLiabiliesYoy: Double?
    let otherCurrentLiabilitiesTotalYoy, totalCurrentLiabilitiesYoy, longTermDebtYoy: Double?
    let capitalLeasesYoy, fdDebtNonCurrentYoy, fdOtherNonCurrentLiabilitiesYoy: Double?
    let otherLiabilitiesTotalYoy, totalLiabilitiesYoy: Double?
    let preferredStockOthersYoy, totalPreferredEquityYoy: Double?
    let commonStockAPICYoy, retainedEarningsYoy, treasuryStockOtherYoy, totalCommonEquityYoy: Double?
    let minorityInterestYoy, totalEquityYoy, totalLiabilitiesAndEquityYoy: Double?
    let currentRatioYoy, totalLiabilitiesRatioYoy: Double?

    enum CodingKeys: String, CodingKey {
        case cashAndEquYoy = "cash_and_equ_yoy"
        case shortTermInvestYoy = "short_term_invest_yoy"
        case tradeingAssetSecuYoy = "tradeing_asset_secu_yoy"
        case cashAndShortInvestYoy = "cash_and_short_invest_yoy"
        case accountsReceivableYoy = "accounts_receivable_yoy"
        case otherReceivableYoy = "other_receivable_yoy"
        case notesReceivableYoy = "notes_receivable_yoy"
        case totalReceivalbleYoy = "total_receivalble_yoy"
        case inventoryYoy = "inventory_yoy"
        case prepaidExpensesYoy = "prepaid_expenses_yoy"
        case fdLoansAndLeasesCurrentYoy = "fd_loans_and_leases_current_yoy"
        case fdOtherCurrentAssetsYoy = "fd_other_current_assets_yoy"
        case otherCurrentAssetsTotalYoy = "other_current_assets_total_yoy"
        case totalCurrentAssetsYoy = "total_current_assets_yoy"
        case grossPpeYoy = "gross_ppe_yoy"
        case accumulatedDepreciationYoy = "accumulated_depreciation_yoy"
        case netPpeYoy = "net_ppe_yoy"
        case longTermInvestmentsYoy = "long_term_investments_yoy"
        case goodwillYoy = "goodwill_yoy"
        case otherIntangiblesYoy = "other_intangibles_yoy"
        case fdLoansAndLeasesLongTermYoy = "fd_loans_and_leases_long_term_yoy"
        case fdOtherLongTermAssetsYoy = "fd_other_long_term_assets_yoy"
        case otherAssetsTotalYoy = "other_assets_total_yoy"
        case totalAssetsYoy = "total_assets_yoy"
        case accountsPayableYoy = "accounts_payable_yoy"
        case accruedExpensesYoy = "accrued_expenses_yoy"
        case shortTermBorrowingsYoy = "short_term_borrowings_yoy"
        case longTermDebtOrCapitalLeasesYoy = "long_term_debt_or_capital_leases_yoy"
        case fdDebtCurrentYoy = "fd_debt_current_yoy"
        case fdOtherCurrentLiabiliesYoy = "fd_other_current_liabilies_yoy"
        case otherCurrentLiabilitiesTotalYoy = "other_current_liabilities_total_yoy"
        case totalCurrentLiabilitiesYoy = "total_current_liabilities_yoy"
        case longTermDebtYoy = "long_term_debt_yoy"
        case capitalLeasesYoy = "capital_leases_yoy"
        case fdDebtNonCurrentYoy = "fd_debt_non_current_yoy"
        case fdOtherNonCurrentLiabilitiesYoy = "fd_other_non_current_liabilities_yoy"
        case otherLiabilitiesTotalYoy = "other_liabilities_total_yoy"
        case totalLiabilitiesYoy = "total_liabilities_yoy"
        case preferredStockOthersYoy = "preferred_stock_others_yoy"
        case totalPreferredEquityYoy = "total_preferred_equity_yoy"
        case commonStockAPICYoy = "common_stock_apic_yoy"
        case retainedEarningsYoy = "retained_earnings_yoy"
        case treasuryStockOtherYoy = "treasury_stock_other_yoy"
        case totalCommonEquityYoy = "total_common_equity_yoy"
        case minorityInterestYoy = "minority_interest_yoy"
        case totalEquityYoy = "total_equity_yoy"
        case totalLiabilitiesAndEquityYoy = "total_liabilities_and_equity_yoy"
        case currentRatioYoy = "current_ratio_yoy"
        case totalLiabilitiesRatioYoy = "total_liabilities_ratio_yoy"
    }
}

// MARK: 现金流量表
struct YXStockDetailFinancialListCashFlowModel: Codable {
    let list: YXStockDetailFinancialListCashFlowInfo?
    let yoy: YXStockDetailFinancialListCashFlowYOYInfo? //yoy2, yoy3, yoy5
}

struct YXStockDetailFinancialListCashFlowInfo: Codable {
    let symbol, secuCode: String?
    let calendarYear, calendarQuarter, fiscalYear, fiscalQuarter: Int?
    let periodTypeID: Int?
    let periodTypeName: String?
    let netIncome, ddaTotal, otherAmortization, onciTotal: Double?
    let changeInNoa, cashFromOperations, capitalExpenditure, saleOfPpae: Double?
    let cashAcquisitions, divestitures, oiaTotal, cashFromInvesting: Double?
    let shortTermDebtIssued, longTermDebtIssued, totalDebetIssued, shortTermDebtRepaid: Double?
    let longTermDebtRepaid, totalDebetRepaid, issuanceOfCS, repurchaseOfCS: Double?
    let issuanceOfPS, repurchaseOfPS, totalDividendsPaid, ofaTotal: Double?
    let cashFromFinancing, ferAdjustments, mcfAdjustments, netChangeInCash: Double?
    let currUnit: String?
    let endDate, currName: String?

    enum CodingKeys: String, CodingKey {
        case symbol
        case secuCode = "secu_code"
        case calendarYear = "calendar_year"
        case calendarQuarter = "calendar_quarter"
        case fiscalYear = "fiscal_year"
        case fiscalQuarter = "fiscal_quarter"
        case periodTypeID = "period_type_id"
        case periodTypeName = "period_type_name"
        case netIncome = "net_income"
        case ddaTotal = "dda_total"
        case otherAmortization = "other_amortization"
        case onciTotal = "onci_total"
        case changeInNoa = "change_in_noa"
        case cashFromOperations = "cash_from_operations"
        case capitalExpenditure = "capital_expenditure"
        case saleOfPpae = "sale_of_ppae"
        case cashAcquisitions = "cash_acquisitions"
        case divestitures
        case oiaTotal = "oia_total"
        case cashFromInvesting = "cash_from_investing"
        case shortTermDebtIssued = "short_term_debt_issued"
        case longTermDebtIssued = "long_term_debt_issued"
        case totalDebetIssued = "total_debet_issued"
        case shortTermDebtRepaid = "short_term_debt_repaid"
        case longTermDebtRepaid = "long_term_debt_repaid"
        case totalDebetRepaid = "total_debet_repaid"
        case issuanceOfCS = "issuance_of_cs"
        case repurchaseOfCS = "repurchase_of_cs"
        case issuanceOfPS = "issuance_of_ps"
        case repurchaseOfPS = "repurchase_of_ps"
        case totalDividendsPaid = "total_dividends_paid"
        case ofaTotal = "ofa_total"
        case cashFromFinancing = "cash_from_financing"
        case ferAdjustments = "fer_adjustments"
        case mcfAdjustments = "mcf_adjustments"
        case netChangeInCash = "net_change_in_cash"
        case currUnit = "curr_unit"
        case endDate = "end_date"
        case currName = "curr_name"
    }
}

struct YXStockDetailFinancialListCashFlowYOYInfo: Codable {
    let netIncomeYoy: Double?
    let ddaTotalYoy, otherAmortizationYoy, onciTotalYoy, changeInNoaYoy: Double?
    let cashFromOperationsYoy, capitalExpenditureYoy, saleOfPpaeYoy, cashAcquisitionsYoy: Double?
    let divestituresYoy, oiaTotalYoy, cashFromInvestingYoy, shortTermDebtIssuedYoy: Double?
    let longTermDebtIssuedYoy, totalDebetIssuedYoy, shortTermDebtRepaidYoy, longTermDebtRepaidYoy: Double?
    let totalDebetRepaidYoy, issuanceOfCSYoy, repurchaseOfCSYoy, issuanceOfPSYoy: Double?
    let repurchaseOfPSYoy, totalDividendsPaidYoy, ofaTotalYoy, cashFromFinancingYoy: Double?
    let ferAdjustmentsYoy, mcfAdjustmentsYoy, netChangeInCashYoy: Double?

    enum CodingKeys: String, CodingKey {
        case netIncomeYoy = "net_income_yoy"
        case ddaTotalYoy = "dda_total_yoy"
        case otherAmortizationYoy = "other_amortization_yoy"
        case onciTotalYoy = "onci_total_yoy"
        case changeInNoaYoy = "change_in_noa_yoy"
        case cashFromOperationsYoy = "cash_from_operations_yoy"
        case capitalExpenditureYoy = "capital_expenditure_yoy"
        case saleOfPpaeYoy = "sale_of_ppae_yoy"
        case cashAcquisitionsYoy = "cash_acquisitions_yoy"
        case divestituresYoy = "divestitures_yoy"
        case oiaTotalYoy = "oia_total_yoy"
        case cashFromInvestingYoy = "cash_from_investing_yoy"
        case shortTermDebtIssuedYoy = "short_term_debt_issued_yoy"
        case longTermDebtIssuedYoy = "long_term_debt_issued_yoy"
        case totalDebetIssuedYoy = "total_debet_issued_yoy"
        case shortTermDebtRepaidYoy = "short_term_debt_repaid_yoy"
        case longTermDebtRepaidYoy = "long_term_debt_repaid_yoy"
        case totalDebetRepaidYoy = "total_debet_repaid_yoy"
        case issuanceOfCSYoy = "issuance_of_cs_yoy"
        case repurchaseOfCSYoy = "repurchase_of_cs_yoy"
        case issuanceOfPSYoy = "issuance_of_ps_yoy"
        case repurchaseOfPSYoy = "repurchase_of_ps_yoy"
        case totalDividendsPaidYoy = "total_dividends_paid_yoy"
        case ofaTotalYoy = "ofa_total_yoy"
        case cashFromFinancingYoy = "cash_from_financing_yoy"
        case ferAdjustmentsYoy = "fer_adjustments_yoy"
        case mcfAdjustmentsYoy = "mcf_adjustments_yoy"
        case netChangeInCashYoy = "net_change_in_cash_yoy"
    }
}

//MARK: sh, hz股票 利润、资产、现金流 Model

struct YXStockDetailFinancialListAStockModel: Codable {
    let compinfo: YXStockDetailFinancialListAStockCompinfo?
    let list: YXStockDetailFinancialListAStockList?
    let yoy: YXStockDetailFinancialListAStockYoy?  //yoy2, yoy3, yoy5
}

struct YXStockDetailFinancialListAStockCompinfo: Codable {
    let uniqueSecuCode, reportPeriod, stmnoteAuditCategoryText, secuAbbr: String?
    let crncyCode: String?

    enum CodingKeys: String, CodingKey {
        case uniqueSecuCode = "unique_secu_code"
        case reportPeriod = "report_period"
        case stmnoteAuditCategoryText = "stmnote_audit_category_text"
        case secuAbbr = "secu_abbr"
        case crncyCode = "crncy_code"
    }
}

struct YXStockDetailFinancialListAStockList: Codable {
    let totalRevenues: Double?
    let totalProfit, totalProfitRate, retainedProfits: Double?
    let retainedProfitsRate: Double?
    let roa: Double?
    let roe, eps: Double?
    let totalCurrentAssets, totalCurrentLiabilities, currentRate, totalAssets: Double?
    let totalLiabilities: Double?
    let totalLiabilitiesRate: Double?
    let totalEquity, operationsCash, investingCash, financingCash: Double?
    let totalCash: Double?

    enum CodingKeys: String, CodingKey {
        case totalRevenues = "total_revenues"
        case totalProfit = "total_profit"
        case totalProfitRate = "total_profit_rate"
        case retainedProfits = "retained_profits"
        case retainedProfitsRate = "retained_profits_rate"
        case roa, roe, eps
        case totalCurrentAssets = "total_current_assets"
        case totalCurrentLiabilities = "total_current_liabilities"
        case currentRate = "current_rate"
        case totalAssets = "total_assets"
        case totalLiabilities = "total_liabilities"
        case totalLiabilitiesRate = "total_liabilities_rate"
        case totalEquity = "total_equity"
        case operationsCash = "operations_cash"
        case investingCash = "investing_cash"
        case financingCash = "financing_cash"
        case totalCash = "total_cash"
    }
}

struct YXStockDetailFinancialListAStockYoy: Codable {
    let totalRevenuesYoy: Double?
    let totalProfitYoy, totalProfitRateYoy, retainedProfitsYoy: Double?
    let retainedProfitsRateYoy: Double?
    let roaYoy: Double?
    let roeYoy, epsYoy: Double?
    let totalCurrentAssetsYoy, totalCurrentLiabilitiesYoy, currentRateYoy, totalAssetsYoy: Double?
    let totalLiabilitiesYoy: Double?
    let totalLiabilitiesRateYoy: Double?
    let totalEquityYoy, operationsCashYoy, investingCashYoy, financingCashYoy: Double?
    let totalCashYoy: Double?

    enum CodingKeys: String, CodingKey {
        case totalRevenuesYoy = "total_revenues_yoy"
        case totalProfitYoy = "total_profit_yoy"
        case totalProfitRateYoy = "total_profit_rate_yoy"
        case retainedProfitsYoy = "retained_profits_yoy"
        case retainedProfitsRateYoy = "retained_profits_rate_yoy"
        case roaYoy = "roa_yoy"
        case roeYoy = "roe_yoy"
        case epsYoy = "eps_yoy"
        case totalCurrentAssetsYoy = "total_current_assets_yoy"
        case totalCurrentLiabilitiesYoy = "total_current_liabilities_yoy"
        case currentRateYoy = "current_rate_yoy"
        case totalAssetsYoy = "total_assets_yoy"
        case totalLiabilitiesYoy = "total_liabilities_yoy"
        case totalLiabilitiesRateYoy = "total_liabilities_rate_yoy"
        case totalEquityYoy = "total_equity_yoy"
        case operationsCashYoy = "operations_cash_yoy"
        case investingCashYoy = "investing_cash_yoy"
        case financingCashYoy = "financing_cash_yoy"
        case totalCashYoy = "total_cash_yoy"
    }
}
