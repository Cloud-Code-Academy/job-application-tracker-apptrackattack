import { LightningElement } from 'lwc';

export default class JoobleCalloutLWC extends LightningElement {
  keywords = '';
  location = '';
  dateRangeDays = '0';
  dateFrom = '';

  get options() {
      return [
          { label: 'Today',        value: '0' },
          { label: 'Last 3 Days',  value: '3' },
          { label: 'Last 7 Days',  value: '7' },
          { label: 'Last 14 Days', value: '14' },
          { label: 'Last 21 Days', value: '21' }
      ];
  }

  handleChange(event) {
      this.value = event.detail.value;
  }

  keywordHandler(event) {
    this.keywords = event.target.value;
  }

  locationHandler(event) {
    this.location = event.target.value;
  }

  searchHandler(event) {
    console.log('searchHandler');
    console.log(this.keywords, this.location, this.dateRangeDays, this.dateFrom);
  }

  calcDate = function() {
    const today = new Date();
    const dte   = new Date(today.setDate(today.getDate() - this.dateRangeDays));
    const day   = dte.getDate() >= 10 ? dte.getDate() : '0' + dte.getDate();
    const month = (dte.getMonth() + 1) >=10 ? (dte.getMonth() + 1) : '0' + (dte.getMonth() + 1);
    const year  = dte.getFullYear();
    this.dateFrom = `${year}-${month}-${day}`;
  }

  dateHandler(event) {
    this.dateRangeDays = event.target.value;
    this.calcDate();
  }
}