const currentUrl = window.location.hostname;
const apiUrl = 'https://' + currentUrl + '/prod/deployment';

function fetchData() {
    fetch(apiUrl, {
        method: 'POST'
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        return response.json();
    })
    .then(data => {
        displayOutput(data);
        showSuccessPrompt();
    })
    .catch(error => {
        console.error('Error fetching data:', error);
        displayOutput('Error fetching data. Please try again later.');
    });
}

function putData() {
    const inputData = document.getElementById('myTextBox').value;
    fetch(apiUrl, {
        method: 'POST', 
        body: JSON.stringify({ Data: inputData , Type : 'PUT' }),
        headers: {
            'Content-Type': 'application/json'
