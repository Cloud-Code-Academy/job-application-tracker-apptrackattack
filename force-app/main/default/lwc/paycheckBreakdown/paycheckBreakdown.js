import { LightningElement } from 'lwc';

export default class PaycheckBreakdown extends LightningElement {
  currency = new Intl.NumberFormat('en-US', {style: 'currency', currency: 'USD'});

  federalTaxBrackets = [
    {min: 0,       max: 11_600,  rate: 0.10},
    {min: 11_600,  max: 47_150,  rate: 0.12},
    {min: 47_150,  max: 100_525, rate: 0.22},
    {min: 100_525, max: 191_950, rate: 0.24},
    {min: 191_950, max: 243_725, rate: 0.32},
    {min: 243_725, max: null,    rate: 0.34},
  ];
  // FICA calculations: Social Security + Medicare
  wageBaseLimit = 168_600;
  ssTaxRate = 0.062;
  medicareTaxRate = 0.0145
  additionalMedicareTax = 0.009;
  ficaTaxBrackets = [
    {min: 0,       max: this.wageBaseLimit, rate: this.ssTaxRate},
    {min: 0,       max: 200_000,            rate: this.medicareTaxRate},
    {min: 200_000, max: null,               rate: (this.medicareTaxRate + this.additionalMedicareTax)}
  ];

  salary = 95_000;
  topMarginalTaxRate;
  federalTaxesOwed = this.calcAnnualTaxes(this.federalTaxBrackets);
  // federalTaxesOwed = this.calcAnnualFederalTaxes();
  salaryAfterFederalTax = this.salary - this.federalTaxesOwed;

  annualFICA = this.calcAnnualFICA();
  biweeklyFICA;
  monthlyFICA;

  get formattedSalary() {
    return this.currency.format(this.salary);
  }

  get formattedBiweeklySalary() {
    return this.currency.format((this.salary / 52 * 2).toFixed(2));
  }

  get formattedMonthlySalary() {
    return this.currency.format((this.salary / 12).toFixed(2));
  }

  get effectiveFederalTaxRate () {
    return ((this.federalTaxesOwed / this.salary) * 100).toFixed(2);
  }

  get formattedTopMarginalTaxRate() {
    console.log('this.topMarginalTaxRate:', this.topMarginalTaxRate);
    return this.topMarginalTaxRate * 100;
  }

  get formattedBiweeklyFederalTaxes() {
    return this.currency.format(((this.federalTaxesOwed / 52) * 2).toFixed(2));
  }

  get formattedMonthlyFederalTaxes() {
    return this.currency.format((this.federalTaxesOwed / 12).toFixed(2));
  }

  get formattedAnnualFederalTaxes() {
    return this.currency.format((this.federalTaxesOwed).toFixed(2));
  }

  get formattedBiweeklyFICA() {
    this.biweeklyFICA = (this.annualFICA / 52) * 2;
    return this.currency.format((this.biweeklyFICA).toFixed(2));
  }

  get formattedMonthlyFICA() {
    this.monthlyFICA = this.annualFICA / 12;
    return this.currency.format((this.monthlyFICA).toFixed(2));
  }

  get formattedAnnualFICA() {
    return this.currency.format((this.annualFICA).toFixed(2));
  }

  get formattedTakeHomeBiWeeklySalary() {
    return this.currency.format(((this.salaryAfterFederalTax / 52 - this.annualFICA / 52) * 2).toFixed(2));
  }

  get formattedTakeHomeMonthlySalary() {
    return this.currency.format(((this.salaryAfterFederalTax / 12 - this.annualFICA / 12)).toFixed(2));
  }

  get formattedTakeHomeAnnualSalary() {
    return this.currency.format((this.salaryAfterFederalTax - this.annualFICA).toFixed(2));
  }

  calcAnnualTaxes(taxBrackets) {
    let totalTaxes = 0;
    let topTaxRate;
    for (const bracket of this.federalTaxBrackets) {
      if (this.salary > bracket.min && bracket.max === null) {
        totalTaxes += (this.salary - bracket.min) * bracket.rate;
        topTaxRate = bracket.rate;
        console.log('topTaxRate: ', topTaxRate);
      } else if (this.salary > bracket.min) {
        totalTaxes += (Math.min(this.salary, bracket.max) - bracket.min) * bracket.rate;
        topTaxRate = bracket.rate;
        console.log('topTaxRate: ', topTaxRate);
      }
    }
    if (taxBrackets === this.federalTaxBrackets){
      console.log('Inside calcAnnualTaxes...');
      this.topMarginalTaxRate = topTaxRate;
      console.log('this.TopMarginalTaxRate: ', this.topMarginalTaxRate);
    }
    return totalTaxes;
  }

  calcAnnualFICA() {
    let totalFICA = 0;
    for (const bracket of this.ficaTaxBrackets) {
      if (this.salary > bracket.min && bracket.max === null) {
        totalFICA += (this.salary - this.bracket.min) * bracket.rate;
      } else if (this.salary > bracket.min) {
        totalFICA += (Math.min(this.salary, bracket.max) - bracket.min) * bracket.rate;
      }
    }
    return totalFICA;
  }

  calcAnnualSocialSecurity() {
    return this.salary * 0.062;
  }
}