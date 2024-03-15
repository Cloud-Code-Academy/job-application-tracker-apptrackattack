import { LightningElement } from 'lwc';

export default class PaycheckBreakdown extends LightningElement {
  formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD'
  });
  taxBracket1 = 0.1;
  taxBracket2 = 0.12;
  taxBracket3 = 0.22;
  taxBracket4 = 0.24;
  taxbracket5 = 0.32;

  salary = 100_000;
  salaryAfterFederalTax;
  biweeklyFederalTaxes;
  annualFederalTaxes;
  finishCalculatingFederalTax = false;
  topMarginalTaxRate;
  annualSocialSecurity = this.calcAnnualSocialSecurity();
  biweeklySocialSecurity;
  monthlySocialSecurity;

  get formattedSalary() {
    return this.formatter.format(this.salary);
  }

  get formattedBiweeklySalary() {
    return this.formatter.format((this.salary/52 * 2).toFixed(2));
  }

  get formattedMonthlySalary() {
    return this.formatter.format((this.salary/12).toFixed(2));
  }

  get effectiveFederalTaxRate(){
    if (this.salary >= 11000) {
      this.salaryAfterFederalTax = 11000 * (1 - this.taxBracket1);
    } else {
      this.salaryAfterFederalTax = this.salary * (1 - this.taxBracket1);
      this.finishCalculatingFederalTax = true;
      this.topMarginalTaxRate = this.taxBracket1;
    }
    if (this.salary >= 44725 && this.finishCalculatingFederalTax === false) {
      this.salaryAfterFederalTax += (44725 - 11000) * (1 - this.taxBracket2);
    } else {
      this.salaryAfterFederalTax += (this.salary - 11000) * (1 - this.taxBracket2);
      this.finishCalculatingFederalTax = true;
      this.topMarginalTaxRate = this.taxBracket2;
    }
    if (this.salary >= 95375 && this.finishCalculatingFederalTax === false) {
      this.salaryAfterFederalTax += (95375 - 44725) * (1 - this.taxBracket3);
    } else {
      this.salaryAfterFederalTax += (this.salary - 44725) * (1 - this.taxBracket3);
      this.finishCalculatingFederalTax = true;
      this.topMarginalTaxRate = this.taxBracket3;
    }
    if (this.salary >= 182100 && this.finishCalculatingFederalTax === false) {
      this.salaryAfterFederalTax += (182100 - 95375) * (1 - this.taxBracket4);
    } else if (this.finishCalculatingFederalTax === false) {
      this.salaryAfterFederalTax += (this.salary - 95375) * (1 - this.taxBracket4);
      this.finishCalculatingFederalTax = true;
      this.topMarginalTaxRate = this.taxBracket4;
    }

    return ((1 - (this.salaryAfterFederalTax / this.salary)) * 100).toFixed(2);
  }

  get formattedTopMarginalTaxRate() {
    return this.topMarginalTaxRate * 100;
  }

  get formattedBiweeklyFederalTaxes() {
    this.biweeklyFederalTaxes = (this.calcAnnualFederalTaxes()/52) * 2;
    return this.formatter.format((this.biweeklyFederalTaxes).toFixed(2));
  }

  get formattedMonthlyFederalTaxes() {
    return this.formatter.format((this.calcAnnualFederalTaxes()/12).toFixed(2));
  }

  get formattedAnnualFederalTaxes() {
    return this.formatter.format((this.calcAnnualFederalTaxes()).toFixed(2));
  }

  get formattedBiweeklySocialSecurity() {
    this.biweeklySocialSecurity = (this.annualSocialSecurity / 52) * 2;
    return this.formatter.format((this.biweeklySocialSecurity).toFixed(2));
  }

  get formattedMonthlySocialSecurity() {
    this.monthlySocialSecurity = this.annualSocialSecurity / 12;
    return this.formatter.format((this.monthlySocialSecurity).toFixed(2));
  }

  get formattedAnnualSocialSecurity() {
    return this.formatter.format((this.annualSocialSecurity).toFixed(2));
  }

  calcAnnualFederalTaxes() {
    return this.salary - this.salaryAfterFederalTax;
  }

  calcAnnualSocialSecurity() {
    return this.salary * 0.062;
  }
}