const currentUrl = window.location.hostname;
const apiUrl = `https://${currentUrl}/prod/deployment`;

async function fetchData() {
    console.log('Data:', apiUrl);
    try {
        const response = await fetch(apiUrl, {
            method: 'POST'
        });
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        const data = await response.json();
        console.log('Data:', data);
        document.getElementById('outputTextbox').innerText = JSON.stringify(data, null, 2);
        showSuccessPrompt();
    } catch (error) {
        console.error('Error fetching data:', error);
        document.getElementById('outputTextbox').innerText = 'Error fetching data. Please try again later.';
    }
}

async function putData() {
    const inputData = document.getElementById('myTextBox').value;
    try {
        const response = await fetch(apiUrl, {
            method: 'POST',
            body: JSON.stringify({ Data: inputData, Type: 'PUT' }),
            headers: {
                'Content-Type': 'application/json'
            }
        });
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        const data = await response.json();
        console.log('Data:', data);
        showSuccessPrompt();
    } catch (error) {
        console.error('Error pushing data:', error);
        document.getElementById('outputTextbox').innerText = 'Error pushing data. Please try again later.';
    }
}

function showSuccessPrompt() {
    const promptElement = document.getElementById('successPrompt');
    promptElement.style.display = 'block';
    setTimeout(() => {
        promptElement.style.display = 'none';
    }, 3000);
}