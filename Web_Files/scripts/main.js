// Animations
AOS.init({
  anchorPlacement: 'top-left',
  duration: 1000
});

// Add your javascript here


// My Code 
var counterContainer = document.querySelector(".website-counter");
// var resetButton = document.querySelector("#reset");
var visitCount = localStorage.getItem("page_view");
var counterText = "Your contribution to the Visitor Count: "

// Check if page_view entry is present
if (visitCount) {
    visitCount = Number(visitCount) + 1;
    localStorage.setItem("page_view", visitCount);
} else {
    visitCount = 1;
    localStorage.setItem("page_view", 1);
}
counterContainer.innerHTML = counterText + visitCount;

// API Call to update and get DDB visitor count
fetch('https://sw0sdet3ol.execute-api.us-east-1.amazonaws.com/update')
    .then(() => fetch('https://sw0sdet3ol.execute-api.us-east-1.amazonaws.com/retrieve-count'))
    .then(response => response.json())
    .then((data) => {
        // Log the data to validate
        console.log(data);
        // Update the HTML and Parse the JSON. This also removes the quotation marks ""
        document.getElementById('replaceMe').innerText = JSON.parse(data);
    })
    .catch((error) => {
        console.error('There has been a problem with the fetch operation:', error);
    });


