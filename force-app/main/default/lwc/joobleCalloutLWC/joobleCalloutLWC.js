import { LightningElement } from 'lwc';

export default class JoobleCalloutLWC extends LightningElement {
  keywords = '';
  keywordList = [];
  location = '';
  dateRangeDays = '0';
  dateFrom = '';

    get options() {
        return [
            { label: 'Today',        value: '0' },
            { label: 'Last 3 Days',  value: '3' },
            { label: 'Last 7 Days',  value: '7' },
            { label: 'Last 14 Days', value: '14' },
            { label: 'Last 21 Days', value: '21' },
            { label: 'Last 28 Days', value: '28' }
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

  keywordHandler(event) {
    this.keywords = event.target.value;
    console.log('keywordHandler');
    console.log('keywords: ', this.keywords);

  }

  locationHandler(event) {
    this.location = event.target.value;
    console.log('locationHandler');
    console.log(this.location);
  }

  searchHandler(event) {
    console.log('searchHandler');
    this.keywordList = this.keywords.split(' ');
    console.log(this.keywords, this.location, this.dateRangeDays, this.dateFrom, this.keywordList);
    console.log('JSON.stringify: ', JSON.stringify(this.keywordList));
    console.table('table', this.keywordList);
  }

  calcDate = function() {
    const today = new Date();
    const dte = new Date(today.setDate(today.getDate() - this.dateRangeDays));
    const day = dte.getDate() >= 10 ? dte.getDate() : '0' + dte.getDate();
    const month = (dte.getMonth() + 1) >=10 ? (dte.getMonth() + 1) : '0' + (dte.getMonth() + 1);
    const year = dte.getFullYear();
    this.dateFrom = `${year}-${month}-${day}`;
  }

  dateHandler(event) {
    console.log('Entered dateHandler...');
    this.dateRangeDays = event.target.value;
    console.log('set this.dateRangeDays');
    this.calcDate();
  }
}