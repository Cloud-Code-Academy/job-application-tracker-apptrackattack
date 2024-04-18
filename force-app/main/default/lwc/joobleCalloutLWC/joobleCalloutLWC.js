import { LightningElement } from 'lwc';
import getJoobleListings from '@salesforce/apex/JoobleCallout.getJoobleListings';

const columns = [
  { label: 'Company', fieldName: 'Company_Name__c', wrapText: true },
  { label: 'Position Title', fieldName: 'recordURL', type: 'url',
      typeAttributes: { label: { fieldName: 'Position_Title__c' }, target: '_blank' }, wrapText: true },
  { label: 'Listing Date', fieldName: 'Listing_Date__c', type: 'date-local' }
];

export default class JoobleCalloutLWC extends LightningElement {
  showFooter = true;
  keywords = '';
  location = '';
  dateRangeDays = '0';
  fromSearchDate = '';
  columns = columns;
  searchResults;
  searchRunning = false;
  showResults = false;
  picklistPlaceholder = '-select-';
  selectedValue = '';
  numberOfResults = 0;
  resultMessage = null;

  get options() {
      return [
          { label: 'Today',        value: '0' },
          { label: 'Last 3 Days',  value: '3' },
          { label: 'Last 7 Days',  value: '7' },
          { label: 'Last 14 Days', value: '14' },
          { label: 'Last 21 Days', value: '21' }
      ];
  }

  get resultMessage() {
      return this.resultMessage;
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
    this.resultMessage = null;
    this.searchRunning = true;
    console.log('searchHandler');
    console.log(this.keywords, this.location, this.dateRangeDays, this.fromSearchDate);
    getJoobleListings({keywords: this.keywords, location: this.location, fromSearchDate: this.fromSearchDate})
      .then(result => {
        console.log(result);
        this.searchResults = result;
        this.numberOfResults = this.searchResults.length;

        // The following creates a link to the Application record via the Position Title
        this.searchResults.forEach(element => {
          element.recordURL = `/${element.Id}`;
        });
        if (this.numberOfResults > 0) {
          this.resultMessage = this.numberOfResults === 1 ? `Found 1 Jooble listing:` : `Found ${this.numberOfResults} Jooble listings:`;
          this.showResults = true;
          this.showFooter = false;
        } else {
          this.resultMessage = 'No job listings found';
          this.showResults = false;
          this.showFooter = true;
        }
        this.searchRunning = false;
      })
      .catch(error => {
        console.log(error);
      });
  }

  reset = function() {
    this.showFooter = true;
    this.keywords = '';
    this.location = '';
    this.picklistPlaceholder = '-select-';
    this.selectedValue = '';
    this.dateRangeDays = '0';
    this.fromSearchDate = '';
    this.searchResults = null;
    this.searchRunning = false;
    this.showResults = false;
    this.resultMessage = null;
  }

  calcDate = function() {
    const today = new Date();
    const dte   = new Date(today.setDate(today.getDate() - this.dateRangeDays));
    const day   = dte.getDate() >= 10 ? dte.getDate() : '0' + dte.getDate();
    const month = (dte.getMonth() + 1) >=10 ? (dte.getMonth() + 1) : '0' + (dte.getMonth() + 1);
    const year  = dte.getFullYear();
    this.fromSearchDate = `${year}-${month}-${day}`;
  }

  handleChange(event) {
    this.selectedValue = event.detail.value;
    this.dateRangeDays = event.target.value;
    this.calcDate();
  }
}