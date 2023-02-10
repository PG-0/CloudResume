import requests
# Requests is a HTTP library for python

endpoint = "https://sw0sdet3ol.execute-api.us-east-1.amazonaws.com/update"

response = requests.get(endpoint)

print(response)

data = response.json()
print("Message from Update Count API:" + data)

status_code = response.status_code
print("Status Code: ", status_code)


# Sanity check to make sure that the endpoint works
def test_can_call_endpoint():
    response = requests.get(endpoint)
    assert response.status_code == 200

# Resources used: 
# https://www.youtube.com/watch?v=7dgQRVqF1N0 (Thank you Pixegami)
# Command to run pytest " python3 -m pytest -v -s" -> Prints results