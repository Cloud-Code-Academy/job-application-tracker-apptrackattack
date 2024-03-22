import { LightningElement, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ESTIMATED_SALARY_FIELD from '@salesforce/schema/Application__c.Estimated_Salary__c';

const fields = [
    'Application__c.Estimated_Salary__c'
];

export default class PaycheckBreakdown extends LightningElement {
  @api recordId;
  salary = 0;

  @wire(getRecord, { recordId: '$recordId', fields: [ESTIMATED_SALARY_FIELD]})
  applicationWireHandler({ error, data }) {
      if (data) {
        console.log('Inside @Wire. Just got the salary from the record page');
        this.salary = getFieldValue(data, ESTIMATED_SALARY_FIELD);
      } else if (error) {
          console.log('There was a problem getting Estimated_Salary__c from the record page');
      }
  }

  SINGLE_STANDARD_DEDUCTION = 14_600;
  currency = new Intl.NumberFormat('en-US', {style: 'currency', currency: 'USD'});

  // Federal Tax properties, tax brackets 2024
  federalTaxBrackets = [
    {min: 0,       max: 11_600,  rate: 0.10},
    {min: 11_600,  max: 47_150,  rate: 0.12},
    {min: 47_150,  max: 100_525, rate: 0.22},
    {min: 100_525, max: 191_950, rate: 0.24},
    {min: 191_950, max: 243_725, rate: 0.32},
    {min: 243_725, max: 609_350, rate: 0.35},
    {min: 609_350, max: null,    rate: 0.37}
  ];
  federalTaxesOwed;
  salaryAfterFederalTax;
  topMarginalTaxRate;

  // FICA (Social Security + Medicare) properties, tax brackets 2024
  wageBaseLimit = 168_600;
  ssTaxRate = 0.062;
  medicareTaxRate = 0.0145
  additionalMedicareTax = 0.009;
  ficaTaxBrackets = [
    {min: 0,       max: this.wageBaseLimit, rate: this.ssTaxRate},
    {min: 0,       max: 200_000,            rate: this.medicareTaxRate},
    {min: 200_000, max: null,               rate: (this.medicareTaxRate + this.additionalMedicareTax)}
  ];
  annualFICA;
  biweeklyFICA;
  monthlyFICA;

  // Effective & Marginal Tax Rate Calculations
  get effectiveFederalTaxRate () {
    return (((this.calcAnnualTaxes(this.federalTaxBrackets)) / this.salary) * 100).toFixed(2);
  }
  get formattedTopMarginalTaxRate() {
    return this.topMarginalTaxRate * 100;
  }

  // Salary Calculations
  get formattedSalary() {
    return this.currency.format(this.salary);
  }
  get formattedBiweeklySalary() {
    this.federalTaxesOwed = this.calcAnnualTaxes(this.federalTaxBrackets);
    return this.currency.format((this.salary / 52 * 2).toFixed(2));
  }
  get formattedMonthlySalary() {
    return this.currency.format((this.salary / 12).toFixed(2));
  }

  // Federal Tax Calculations
  get formattedBiweeklyFederalTaxes() {
    return this.currency.format(((this.federalTaxesOwed / 52) * 2).toFixed(2));
  }
  get formattedMonthlyFederalTaxes() {
    return this.currency.format((this.federalTaxesOwed / 12).toFixed(2));
  }
  get formattedAnnualFederalTaxes() {
    return this.currency.format((this.federalTaxesOwed).toFixed(2));
  }

  // FICA Calculations
  get formattedBiweeklyFICA() {
    this.biweeklyFICA = (this.calcAnnualTaxes(this.ficaTaxBrackets) / 52) * 2;
    return this.currency.format((this.biweeklyFICA).toFixed(2));
  }
  get formattedMonthlyFICA() {
    this.monthlyFICA = this.annualFICA / 12;
    return this.currency.format((this.monthlyFICA).toFixed(2));
  }
  get formattedAnnualFICA() {
    return this.currency.format((this.annualFICA).toFixed(2));
  }

  // Take Home Pay Calculations
  get formattedTakeHomeBiWeeklySalary() {
    return this.currency.format(((this.salaryAfterFederalTax / 52 - this.annualFICA / 52) * 2).toFixed(2));
  }
  get formattedTakeHomeMonthlySalary() {
    return this.currency.format(((this.salaryAfterFederalTax / 12 - this.annualFICA / 12)).toFixed(2));
  }
  get formattedTakeHomeAnnualSalary() {
    return this.currency.format((this.salaryAfterFederalTax - this.annualFICA).toFixed(2));
  }

  // Funciton used to calculate both Federal & FICA payroll taxes
  calcAnnualTaxes(taxBrackets) {
    console.log('Inside calcAnnualTaxes function. this.Salary: ' + this.salary);
    let totalTaxes = 0;
    let topTaxRate;
    let deductionAdjustedSalary = this.salary - this.SINGLE_STANDARD_DEDUCTION;
    for (const bracket of taxBrackets) {
      if (deductionAdjustedSalary > bracket.min && bracket.max === null) {
        totalTaxes += (deductionAdjustedSalary - bracket.min) * bracket.rate;
        topTaxRate = bracket.rate;
      } else if (deductionAdjustedSalary > bracket.min) {
        totalTaxes += (Math.min(deductionAdjustedSalary, bracket.max) - bracket.min) * bracket.rate;
        topTaxRate = bracket.rate;
      }
      console.log('Inside calcAnnualTaxes bracket loop. Total Taxes: ' + totalTaxes);
    }
    if (taxBrackets === this.federalTaxBrackets){
      this.federalTaxesOwed = totalTaxes;
      console.log('Just got the federal taxes owed: ' + totalTaxes);
      this.salaryAfterFederalTax = this.salary - totalTaxes;
      this.topMarginalTaxRate = topTaxRate;
    } else if (taxBrackets = this.ficaTaxBrackets) {
      this.annualFICA = totalTaxes;
      console.log('Just got the annual FICA owed: ' + this.annualFICA);
    }
    return totalTaxes;
  }

  salaryHandler(event) {
    console.log('Entered salaryHandler...');
    if (event.key === 'Enter' || event.key === 'Tab') {
        this.salary = Number(event.target.value);
        console.log('Just set the salary to: ' + this.salary);
    } 
  }

  selectHandler(event) {
    // This function is used to select the entire input value when the user clicks on the input field
    event.target.selectionStart = 0 ;
    if(event.target.value){
       event.target.selectionEnd = event.target.value.toString().length ;
    }else{
       event.target.selectionEnd = 0 ;
    }
 }
}