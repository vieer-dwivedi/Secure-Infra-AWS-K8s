const currentUrl = window.location.hostname;
const apiUrl = `https://${currentUrl}/backend`;

async function fetchData() {
    console.log('Fetching data from:', apiUrl);
    try {
        const response = await fetch(apiUrl, {
            method: 'GET'
        });
        if (!response.ok) {
            throw new Error(`Network response was not ok: ${response.statusText}`);
        }
        const contentType = response.headers.get("content-type");
        let data;
        if (contentType && contentType.indexOf("application/json") !== -1) {
            data = await response.json();
            document.getElementById('outputTextbox').innerText = JSON.stringify(data, null, 2);
        } else {
            data = await response.text();
            document.getElementById('outputTextbox').innerText = data;
        }
        console.log('Fetched data:', data);
        showSuccessPrompt();
    } catch (error) {
        console.error('Error fetching data:', error);
        document.getElementById('outputTextbox').innerText = 'Error fetching data. Please try again later.';
    }
}

async function putData() {
    const inputData = document.getElementById('myTextBox').value;
    console.log('Pushing data to:', apiUrl, 'with payload:', inputData);
    try {
        const response = await fetch(apiUrl, {
            method: 'PUT',
            body: JSON.stringify({ "data": inputData }),
            headers: {
                'Content-Type': 'application/json'
            }
        });
        if (!response.ok) {
            throw new Error(`Network response was not ok: ${response.statusText}`);
        }
        const contentType = response.headers.get("content-type");
        let data;
        if (contentType && contentType.indexOf("application/json") !== -1) {
            data = await response.json();
            document.getElementById('outputTextbox').innerText = JSON.stringify(data, null, 2);
        } else {
            data = await response.text();
            document.getElementById('outputTextbox').innerText = data;
        }
        console.log('Response data:', data);
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
